defmodule MishkaChelekom.CmsBundleExporter do
  @moduledoc """
  Converts a Mishka Chelekom `.exs` + `.eex` source pair into the
  **final** `Runtime.Component` create-params shape consumed by the
  MishkaCMS UI-kit installer (schema `mishka.ui_kit.bundle.v3`).

  This module owns every kit-specific decision. The MishkaCMS-side
  installer is a trivial loader: `Jason.decode!` + `Ash.bulk_create`.
  No re-narrowing, no rewriting, no slug-guessing happens at install
  time. Whatever this module emits is what lands in the database.

  ## Pipeline

      1. `read_exs/1`               eval `.exs`, get name/args/scripts
      2. `render_maximal/2`         EEx-eval with all-options assigns
      3. `parse_ast/1`              `Code.string_to_quoted!`
      4. `walk/1`                   collect public defs, private defps,
                                    attr/slot decls bound to each def,
                                    module attributes, prelude (alias/
                                    import/use) with Tier-1 dedup
      5. `resolve_aliased_attrs/2`  map `attr :x, JS, ...` → struct type
                                    with full module path
      6. `drop_unrepresentable_defaults/1` strip struct/map/call AST
                                    defaults that can't survive JSON
      7. `rewrite_sibling_refs/3`   HEEx tokenizer pass on every public
                                    fn's `~H""` content; rewrite sibling
                                    tags to `<.component component_name=
                                    "<kit>-<X-slug>" .../>`
      8. `slug_names/2`             apply lowercase + hyphen rewrite to
                                    every emitted name
      9. `emit_components/3`        one component-params per public def

  Helpers (`defp`s) extracted in step 4 are inlined into every public
  function's row — they share the compiled BEAM module so cross-helper
  calls work locally. Public siblings are NOT inlined; cross-references
  go through the runtime helper via the rewrite in step 7.
  """

  ## ─── Public API ──────────────────────────────────────────────────────

  @type component_params :: map()
  @type js_hook :: %{required(String.t()) => term()}

  @doc """
  Convert one `.exs` + `.eex` pair into an ordered list of v3
  component-params (one entry per public function in the source) plus
  the script entries from the `.exs`'s `scripts:` field.

  ## Options

    * `:base64` (boolean) — when `true`, encode `template`/`body` strings
      as `"base64:" <> Base.encode64(...)`. Default `false`.
    * `:extra_siblings` (`MapSet<String.t()>`) — public-function names
      from OTHER `.exs` files in the same kit. Templates that reference
      them (e.g. `tabs.eex` calling `<.scroll_area/>`) get rewritten to
      the runtime-helper form just like same-file siblings. Default
      empty MapSet.
  """
  @spec convert(String.t(), String.t(), String.t(), String.t(), keyword()) ::
          {:ok, %{components: [component_params()], scripts: [map()]}} | {:error, term()}
  def convert(exs_source, eex_source, kit_name, kit_version, opts \\ []) do
    base64? = Keyword.get(opts, :base64, false)
    extra_siblings = Keyword.get(opts, :extra_siblings, MapSet.new())

    with {:ok, config} <- read_exs(exs_source),
         max_source = render_maximal(eex_source, config),
         {:ok, max_ast} <- parse_ast(max_source) do
      walked = walk(max_ast)

      sibling_names =
        walked.public_defs
        |> MapSet.new(& &1.name)
        |> MapSet.union(extra_siblings)

      components =
        walked.public_defs
        |> Enum.map(&attach_component_metadata(&1, walked, config, kit_name, kit_version))
        |> Enum.map(&resolve_aliased_attrs(&1, walked.aliases))
        |> Enum.map(&drop_unrepresentable_defaults/1)
        |> Enum.map(&rewrite_sibling_refs(&1, sibling_names, kit_name))
        |> Enum.map(&inject_match_destructure/1)
        |> Enum.map(&slug_names(&1, kit_name))
        |> Enum.map(&maybe_base64(&1, base64?))
        |> Enum.map(&finalize_component_params/1)

      {:ok, %{components: components, scripts: config[:scripts] || []}}
    end
  end

  @doc """
  Lightweight pre-pass: returns just the public-function names from a
  `.exs+.eex` pair. Used by the Mix task to harvest the kit-wide set
  before invoking `convert/5` per file (so cross-file `<.X/>` refs
  rewrite correctly).
  """
  @spec list_public_defs(String.t(), String.t()) :: {:ok, [String.t()]} | {:error, term()}
  def list_public_defs(exs_source, eex_source) do
    with {:ok, config} <- read_exs(exs_source),
         max_source = render_maximal(eex_source, config),
         {:ok, max_ast} <- parse_ast(max_source) do
      walked = walk(max_ast)
      {:ok, Enum.map(walked.public_defs, & &1.name)}
    end
  end

  ## ─── Step 1: read .exs ───────────────────────────────────────────────

  defp read_exs(exs_source) when is_binary(exs_source) do
    {value, _binding} = Code.eval_string(exs_source)

    case value do
      [{name, config} | _] when is_atom(name) and is_list(config) ->
        {:ok, config}

      _ ->
        {:error, :invalid_exs_shape}
    end
  rescue
    e -> {:error, {:exs_eval_failed, Exception.message(e)}}
  end

  ## ─── Step 2: render maximal source ───────────────────────────────────

  @base_assigns %{
    module: "Sentinel.Component",
    web_module: Sentinel,
    module_prefix_camel: "Sentinel",
    component_prefix: "",
    type: nil,
    variant: nil,
    color: nil,
    size: nil,
    rounded: nil,
    padding: nil,
    space: nil
  }

  defp render_maximal(eex_source, _config) do
    referenced =
      ~r/@([a-z_][a-zA-Z0-9_]*)/
      |> Regex.scan(eex_source, capture: :all_but_first)
      |> Enum.flat_map(& &1)
      |> Enum.uniq()
      |> Enum.map(&String.to_atom/1)
      |> Map.new(&{&1, nil})

    EEx.eval_string(eex_source, assigns: Map.merge(referenced, @base_assigns))
  end

  ## ─── Step 3: parse ast ───────────────────────────────────────────────

  defp parse_ast(source) do
    case Code.string_to_quoted(source, file: "ui_kit_maximal") do
      {:ok, ast} -> {:ok, ast}
      {:error, reason} -> {:error, {:parse_failed, reason}}
    end
  end

  ## ─── Step 4: walk top-level AST ──────────────────────────────────────

  @ignored_attributes ~w(moduledoc doc spec type typep opaque callback macrocallback impl behaviour)a
  @tier1_alias_modules ["Phoenix.LiveView.JS"]
  @tier1_import_modules ["Phoenix.LiveView.Utils"]
  @tier1_use_modules ["Phoenix.Component", "Gettext"]

  defp walk({:defmodule, _, [_alias, [do: body]]}) do
    nodes =
      case body do
        {:__block__, _, list} -> list
        single -> [single]
      end

    init = %{
      aliases: %{},
      prelude_lines: [],
      module_attrs: [],
      pending_attrs: [],
      pending_slots: [],
      public_defs: [],
      private_helpers: []
    }

    walked = Enum.reduce(nodes, init, &accumulate_node/2)

    %{
      walked
      | public_defs: walked.public_defs |> Enum.reverse() |> group_public_def_clauses(),
        private_helpers: walked.private_helpers |> Enum.reverse(),
        module_attrs: Enum.reverse(walked.module_attrs),
        prelude_lines: Enum.reverse(walked.prelude_lines)
    }
  end

  defp walk(_),
    do: %{
      aliases: %{},
      prelude_lines: [],
      module_attrs: [],
      pending_attrs: [],
      pending_slots: [],
      public_defs: [],
      private_helpers: []
    }

  ## ── handle each top-level node

  # Ignored doc/spec/type pragmas
  defp accumulate_node({:@, _, [{name, _, _}]}, acc)
       when name in @ignored_attributes,
       do: acc

  # Module attribute (e.g. @indicator_positions [...])
  defp accumulate_node({:@, _, [{name, _, [value]}]}, acc) do
    case stringify_value(value) do
      :__unencodable__ ->
        acc

      stringified ->
        %{acc | module_attrs: [%{name: to_string(name), value: stringified} | acc.module_attrs]}
    end
  end

  # alias Foo.Bar
  defp accumulate_node({:alias, _, [{:__aliases__, _, parts}]}, acc) do
    full = Enum.map_join(parts, ".", &Atom.to_string/1)
    short = parts |> List.last() |> Atom.to_string()
    aliases = Map.put(acc.aliases, short, full)

    if full in @tier1_alias_modules do
      %{acc | aliases: aliases}
    else
      %{acc | aliases: aliases, prelude_lines: ["alias #{full}" | acc.prelude_lines]}
    end
  end

  # import Foo.Bar, only: [...]
  defp accumulate_node({:import, _, args}, acc) do
    case parse_import(args) do
      {:tier1, _full} -> acc
      {:icon_companion, _} -> acc
      {:line, line} -> %{acc | prelude_lines: [line | acc.prelude_lines]}
      :skip -> acc
    end
  end

  # use Foo.Bar [, opts]
  defp accumulate_node({:use, _, args}, acc) do
    case parse_use(args) do
      {:tier1, _full} -> acc
      {:line, line} -> %{acc | prelude_lines: [line | acc.prelude_lines]}
      :skip -> acc
    end
  end

  # attr :name, :type, opts
  defp accumulate_node({:attr, _, args}, acc) do
    %{acc | pending_attrs: acc.pending_attrs ++ [parse_attr_call(args)]}
  end

  # slot :name, opts [, do: ...]
  defp accumulate_node({:slot, _, args}, acc) do
    %{acc | pending_slots: acc.pending_slots ++ [parse_slot_call(args)]}
  end

  # def public_fn(...) do ... end  → public function
  # def public_fn(...) do <no ~H> end → delegating clause of a multi-clause
  # public def (e.g. `def combobox(%{field: ...} = assigns)` that does some
  # assigns then calls `combobox(...)` recursively into the next clause).
  # The actual attr/slot declarations are above the FIRST clause; they
  # belong to the public def, not to any individual clause. Don't reset
  # `pending_attrs`/`pending_slots` here — let the next ~H-bodied clause
  # consume them, and `group_public_def_clauses/1` merges multi-clause
  # entries into one row.
  defp accumulate_node({:def, _, [head, [do: body]]}, acc) do
    {fn_name, args_ast, guard} = decompose_head(head)

    if contains_heex_sigil?(body) do
      {pre_template_body, template_str} = extract_template(body)

      pub = %{
        name: to_string(fn_name),
        match: match_string(args_ast),
        guard: stringify_guard(guard),
        body: maybe_to_string(pre_template_body),
        template: template_str,
        attrs: acc.pending_attrs,
        slots: acc.pending_slots
      }

      %{acc | public_defs: [pub | acc.public_defs], pending_attrs: [], pending_slots: []}
    else
      # Public def without ~H — treat as a delegating clause of a
      # multi-clause public def (`def fn(%{field: ...} = assigns) do
      # ... call_self end`). Don't reset pending_attrs; the next ~H-
      # bodied clause picks them up.
      helper = head_to_helper_entry(head, body, :public, [], [])
      %{acc | private_helpers: [helper | acc.private_helpers]}
    end
  end

  # defp helper(...) do ... end
  #
  # Phoenix Component allows `attr :foo, ... ; defp my_helper(assigns)
  # do ~H""" ... """; end` — the attr declaration applies to the next
  # def OR defp, giving the helper its own contract (defaults, change-
  # tracking). Capture pending_attrs/pending_slots into the helper
  # entry so the runtime compiler can emit them before the defp.
  # Reset pending state after consumption.
  defp accumulate_node({:defp, _, [head, [do: body]]}, acc) do
    helper =
      head_to_helper_entry(head, body, :private, acc.pending_attrs, acc.pending_slots)

    %{
      acc
      | private_helpers: [helper | acc.private_helpers],
        pending_attrs: [],
        pending_slots: []
    }
  end

  defp accumulate_node(_, acc), do: acc

  ## ── helpers used by walk

  defp parse_import([{:__aliases__, _, parts}]) do
    full = Enum.map_join(parts, ".", &Atom.to_string/1)
    classify_import(full, "import #{full}")
  end

  defp parse_import([{:__aliases__, _, parts}, opts]) when is_list(opts) do
    full = Enum.map_join(parts, ".", &Atom.to_string/1)
    only_str = format_only_kw(Keyword.get(opts, :only))
    line = if only_str, do: "import #{full}, only: [#{only_str}]", else: "import #{full}"
    classify_import(full, line)
  end

  defp parse_import(_), do: :skip

  defp classify_import(full, _line) when full in @tier1_import_modules, do: {:tier1, full}

  defp classify_import(full, line) do
    cond do
      String.contains?(full, ".Components.") -> {:icon_companion, full}
      true -> {:line, line}
    end
  end

  defp format_only_kw(nil), do: nil

  defp format_only_kw(only) when is_list(only) do
    only
    |> Enum.map(fn {name, arity} -> "#{name}: #{arity}" end)
    |> Enum.join(", ")
  end

  defp parse_use([{:__aliases__, _, parts}]) do
    full = Enum.map_join(parts, ".", &Atom.to_string/1)
    if full in @tier1_use_modules, do: {:tier1, full}, else: {:line, "use #{full}"}
  end

  defp parse_use([{:__aliases__, _, parts}, opts]) when is_list(opts) do
    full = Enum.map_join(parts, ".", &Atom.to_string/1)

    if full in @tier1_use_modules do
      {:tier1, full}
    else
      opts_str = opts |> Keyword.delete(:do) |> Macro.to_string()
      {:line, "use #{full}, #{opts_str}"}
    end
  end

  defp parse_use(_), do: :skip

  defp parse_attr_call([name, type | rest]) do
    opts =
      case rest do
        [opts] when is_list(opts) -> opts
        _ -> []
      end

    base = %{name: attr_name_to_string(name), opts: attr_opts_to_map(opts)}

    case type do
      {:__aliases__, _, parts} ->
        mod = Enum.map_join(parts, ".", &Atom.to_string/1)
        Map.merge(base, %{type: "struct", struct_short: mod})

      type when is_atom(type) ->
        Map.put(base, :type, Atom.to_string(type))

      other ->
        Map.put(base, :type, inspect(other))
    end
  end

  defp parse_slot_call([name | rest]) do
    {opts, do_body} = split_slot_args(rest)

    %{
      name: attr_name_to_string(name),
      opts: attr_opts_to_map(opts),
      attrs: extract_slot_attrs(do_body)
    }
  end

  # `slot :foo, opts do ... end` parses to two arg shapes:
  #
  #   * 2 args: `[opts, [do: body]]`  — Keyword.has_key?(opts, :do) → no
  #   * 1 arg with bare opts including :do: `[[do: body]]`
  #   * 1 arg with full opts: `[opts]`
  #
  # Normalize to {opts_without_do, do_body_or_nil}.
  defp split_slot_args([]), do: {[], nil}

  defp split_slot_args([opts]) when is_list(opts) do
    {Keyword.drop(opts, [:do]), Keyword.get(opts, :do)}
  end

  defp split_slot_args([opts, [do: body]]) when is_list(opts) do
    {Keyword.drop(opts, [:do]), body}
  end

  defp split_slot_args(_), do: {[], nil}

  # Extract `attr :foo, ...` declarations nested inside a slot's
  # do-block. Each becomes a slot-level attr in the bundle so consumers
  # know the shape of slot items (`<:slide image="..." image_class="..."/>`).
  # Returns `[]` for slots without a body or with non-attr content.
  defp extract_slot_attrs(nil), do: []

  defp extract_slot_attrs({:__block__, _, statements}), do: collect_slot_attrs(statements)
  defp extract_slot_attrs(single), do: collect_slot_attrs([single])

  defp collect_slot_attrs(nodes) do
    Enum.flat_map(nodes, fn
      {:attr, _, args} -> [parse_attr_call(args)]
      _ -> []
    end)
  end

  defp attr_name_to_string(name) when is_atom(name), do: Atom.to_string(name)
  defp attr_name_to_string({name, _, _}) when is_atom(name), do: Atom.to_string(name)
  defp attr_name_to_string(other), do: to_string(other)

  defp attr_opts_to_map(opts) when is_list(opts) do
    Enum.reduce(opts, %{}, fn {k, v}, acc ->
      case opt_value(v) do
        :__drop__ -> acc
        value -> Map.put(acc, Atom.to_string(k), value)
      end
    end)
  end

  defp attr_opts_to_map(_), do: %{}

  defp opt_value(v) when is_binary(v) or is_number(v) or is_boolean(v) or is_nil(v), do: v
  defp opt_value(v) when is_atom(v), do: Atom.to_string(v)

  defp opt_value(list) when is_list(list) do
    list
    |> Enum.map(&opt_value/1)
    |> Enum.reject(&(&1 == :__drop__))
  end

  # `%StructName{...}` and function captures `&fn/N` — drop. Phoenix
  # rejects them as default values from JSON anyway.
  defp opt_value({:%, _, _}), do: :__drop__
  defp opt_value({:&, _, _}), do: :__drop__

  # Plain map literal `%{k1: v1, k2: v2}`. Round-trip through JSON as
  # an `__atom_map__`-tagged structure so the consumer can rebuild the
  # atom-keyed map at compile time. Atoms in keys/values become strings
  # with a `:` prefix to survive JSON encoding (`{:icon, ...}` →
  # `":icon"`).
  defp opt_value({:%{}, _, pairs}) when is_list(pairs) do
    case encode_atom_map(pairs) do
      {:ok, encoded} -> %{"__atom_map__" => encoded}
      :error -> :__drop__
    end
  end

  # Bare function call `f(arg1, arg2)` — can't represent in JSON.
  defp opt_value({fun, _, args}) when is_atom(fun) and is_list(args), do: :__drop__

  defp opt_value(ast) do
    try do
      Macro.to_string(ast)
    rescue
      _ -> inspect(ast)
    end
  end

  # Encode each map entry. Returns `{:ok, list}` of `{encoded_k,
  # encoded_v}` pairs OR `:error` if any value is non-JSON-encodable
  # (struct, function, AST tuple).
  defp encode_atom_map(pairs) do
    encoded =
      Enum.reduce_while(pairs, [], fn {k, v}, acc ->
        with k_enc when k_enc != :__drop__ <- encode_map_term(k),
             v_enc when v_enc != :__drop__ <- encode_map_term(v) do
          {:cont, [[k_enc, v_enc] | acc]}
        else
          _ -> {:halt, :error}
        end
      end)

    case encoded do
      :error -> :error
      list -> {:ok, Enum.reverse(list)}
    end
  end

  # Encode a single literal that may appear as a map key or value.
  # Atoms gain a `:` prefix sentinel so the consumer atomizes them.
  defp encode_map_term(v) when is_binary(v) or is_number(v) or is_boolean(v) or is_nil(v), do: v
  defp encode_map_term(v) when is_atom(v), do: ":" <> Atom.to_string(v)

  defp encode_map_term(list) when is_list(list) do
    encoded = Enum.map(list, &encode_map_term/1)
    if :__drop__ in encoded, do: :__drop__, else: encoded
  end

  defp encode_map_term(_), do: :__drop__

  defp decompose_head({:when, _, [{name, _, args}, guard]}), do: {name, args, guard}
  defp decompose_head({name, _, args}), do: {name, args, nil}

  defp match_string([{:assigns, _, _}]), do: nil
  defp match_string([single]), do: Macro.to_string(single)
  defp match_string(args) when is_list(args), do: Enum.map_join(args, ", ", &Macro.to_string/1)

  defp stringify_guard(nil), do: nil
  defp stringify_guard(g), do: Macro.to_string(g)

  defp contains_heex_sigil?(ast) do
    {_node, found} =
      Macro.prewalk(ast, false, fn
        {:sigil_H, _, _} = node, _acc -> {node, true}
        other, acc -> {other, acc}
      end)

    found
  end

  defp extract_template({:__block__, _, statements}) do
    {pre, sigil} = Enum.split_while(statements, &(not heex_sigil?(&1)))

    template_str =
      case sigil do
        [s | _] -> heex_sigil_text(s)
        _ -> ""
      end

    pre_ast =
      case pre do
        [] -> nil
        [single] -> single
        list -> {:__block__, [], list}
      end

    {pre_ast, template_str}
  end

  defp extract_template(other) do
    if heex_sigil?(other), do: {nil, heex_sigil_text(other)}, else: {other, ""}
  end

  defp heex_sigil?({:sigil_H, _, _}), do: true
  defp heex_sigil?(_), do: false

  defp heex_sigil_text({:sigil_H, _, [{:<<>>, _, parts}, _modifiers]}) do
    parts
    |> Enum.map(fn
      bin when is_binary(bin) -> bin
      _ -> ""
    end)
    |> IO.iodata_to_binary()
  end

  defp heex_sigil_text(_), do: ""

  defp maybe_to_string(nil), do: nil

  defp maybe_to_string(ast) do
    case Macro.to_string(ast) do
      "nil" -> nil
      "" -> nil
      str -> str
    end
  end

  defp head_to_helper_entry(head, body, _visibility, attrs, slots) do
    {name, args, guard} = decompose_head(head)

    args_str = args |> Enum.map(&Macro.to_string/1) |> Enum.join(", ")

    full_args =
      if guard, do: "#{args_str} when #{Macro.to_string(guard)}", else: args_str

    %{
      name: to_string(name),
      args: full_args,
      code: Macro.to_string(body),
      attrs: attrs,
      slots: slots
    }
  end

  defp stringify_value(value)
       when is_binary(value) or is_number(value) or is_boolean(value) or is_nil(value),
       do: value

  defp stringify_value(value) when is_atom(value), do: to_string(value)

  defp stringify_value(list) when is_list(list) do
    Enum.map(list, &stringify_value/1)
  end

  defp stringify_value(_), do: :__unencodable__

  ## Pattern-matched function heads (def icon(%{...})) emit multiple
  ## entries with the same name. Group them into one entry with a
  ## `clauses: [...]` list while preserving ordering.
  defp group_public_def_clauses(defs) do
    {by_name, order} =
      Enum.reduce(defs, {%{}, []}, fn d, {by_name, order} ->
        case Map.get(by_name, d.name) do
          nil ->
            {Map.put(by_name, d.name, %{primary: d, extra_clauses: []}), order ++ [d.name]}

          %{primary: _p, extra_clauses: ec} = entry ->
            {Map.put(by_name, d.name, %{entry | extra_clauses: ec ++ [d]}), order}
        end
      end)

    Enum.map(order, fn name ->
      %{primary: p, extra_clauses: ec} = Map.fetch!(by_name, name)
      Map.put(p, :__extra_clauses__, ec)
    end)
  end

  ## ─── Step 5: resolve aliased attr types ──────────────────────────────

  defp resolve_aliased_attrs(component, aliases_map) do
    new_attrs = Enum.map(component.attrs, &resolve_attr_alias(&1, aliases_map))

    # Helper attrs (carried by `defp`s with their own `attr/3`
    # declarations) need the same alias resolution. Without this,
    # `attr :on_action, JS, default: %JS{}` ships with `type: "struct",
    # struct_short: "JS"` and `struct_name: nil`, so the runtime
    # compiler emits `attr.(:on_action, Elixir, ...)` (Module.concat([])
    # → Elixir) which Phoenix rejects as "invalid type Elixir".
    new_helpers =
      component
      |> Map.get(:__private_helpers__, [])
      |> Enum.map(fn h ->
        helper_attrs = Map.get(h, :attrs, []) || []
        resolved = Enum.map(helper_attrs, &resolve_attr_alias(&1, aliases_map))
        Map.put(h, :attrs, resolved)
      end)

    component
    |> Map.put(:attrs, new_attrs)
    |> Map.put(:__private_helpers__, new_helpers)
  end

  defp resolve_attr_alias(%{type: "struct", struct_short: short} = attr, aliases_map) do
    full = Map.get(aliases_map, short, short)

    attr
    |> Map.put(:struct_name, full)
    |> Map.delete(:struct_short)
  end

  defp resolve_attr_alias(attr, _aliases_map), do: attr

  ## ─── Step 6: drop unrepresentable defaults ───────────────────────────
  ##
  ## `attr_opts_to_map/1` already drops AST defaults, but make sure no
  ## `:__drop__` sentinel slips through.
  defp drop_unrepresentable_defaults(component) do
    new_attrs = Enum.map(component.attrs, &drop_attr_unrep/1)

    new_helpers =
      component
      |> Map.get(:__private_helpers__, [])
      |> Enum.map(fn h ->
        helper_attrs = Map.get(h, :attrs, []) || []
        Map.put(h, :attrs, Enum.map(helper_attrs, &drop_attr_unrep/1))
      end)

    component
    |> Map.put(:attrs, new_attrs)
    |> Map.put(:__private_helpers__, new_helpers)
  end

  defp drop_attr_unrep(%{opts: opts} = attr) do
    cleaned = opts |> Enum.reject(fn {_k, v} -> v == :__drop__ end) |> Map.new()
    Map.put(attr, :opts, cleaned)
  end

  defp drop_attr_unrep(attr), do: attr

  ## ─── Step 7: rewrite sibling cross-refs ──────────────────────────────

  defp rewrite_sibling_refs(component, sibling_names, kit_name) do
    if MapSet.size(sibling_names) == 0 do
      component
    else
      # Self-refs are fine: `<.component component_name="..."/>` is a
      # runtime-dispatched call (`LiveViewHelpers.component/1`), not a
      # compile-time call to a local function — so a component referencing
      # itself rewrites cleanly. Helpers' `code` fields can also contain
      # HEEx (~H sigil bodies in `defp`s); rewrite those too.
      template =
        MishkaChelekom.HeexTagRewriter.rewrite(component.template, sibling_names, kit_name)

      body =
        if is_binary(component.body),
          do: MishkaChelekom.HeexTagRewriter.rewrite(component.body, sibling_names, kit_name),
          else: component.body

      helpers =
        Enum.map(component.__private_helpers__, fn h ->
          %{h | code: MishkaChelekom.HeexTagRewriter.rewrite(h.code, sibling_names, kit_name)}
        end)

      extra_clauses =
        Enum.map(component.__extra_clauses__, fn c ->
          tpl = MishkaChelekom.HeexTagRewriter.rewrite(c.template, sibling_names, kit_name)

          bdy =
            if is_binary(c.body),
              do: MishkaChelekom.HeexTagRewriter.rewrite(c.body, sibling_names, kit_name),
              else: c.body

          %{c | template: tpl, body: bdy}
        end)

      %{
        component
        | template: template,
          body: body,
          __private_helpers__: helpers,
          __extra_clauses__: extra_clauses
      }
    end
  end

  ## ─── Step 7.5: inject match destructure into body ──────────────────

  # Single-clause defs whose head pattern destructures `assigns`
  # (e.g. `def f(%{a: a, b: b} = assigns)`) lose the destructure when
  # the runtime compiler emits `def f(assigns)`. Rebind the names by
  # prepending `<match> = assigns` to the body string.
  #
  # Skip when match is nil, the bare `assigns`, or when this entry is
  # part of a multi-clause group (the compiler then uses case-dispatch
  # with the original patterns).
  defp inject_match_destructure(component) do
    if component.__extra_clauses__ != [] do
      component
    else
      case component[:match] do
        nil -> component
        "assigns" -> component
        match when is_binary(match) -> prepend_destructure(component, match)
        _ -> component
      end
    end
  end

  defp prepend_destructure(component, match) do
    line = "#{match} = assigns"

    new_body =
      case component.body do
        nil -> line
        "" -> line
        existing -> line <> "\n" <> existing
      end

    %{component | body: new_body}
  end

  ## ─── Step 8: slug names + attach metadata ────────────────────────────

  # Functions the MishkaCMS compiler injects via `use MishkaCmsWeb, :live_view`.
  # When a Chelekom file defines its own `defp translate_error(...)`, the
  # local def collides with the host's import. The host wins for templates
  # rendering field errors, so drop the local helper.
  @host_injected_signatures MapSet.new([
                              {"translate_error", 1},
                              {"translate_errors", 1},
                              {"input", 1}
                            ])

  defp attach_component_metadata(public_def, walked, config, kit_name, kit_version) do
    helpers = drop_host_injected_helpers(walked.private_helpers)
    filtered_prelude = drop_imports_colliding_with_helpers(walked.prelude_lines, helpers)

    public_def
    |> Map.put(:__component_filename__, to_string(config[:name]))
    |> Map.put(:__module_attrs__, walked.module_attrs)
    |> Map.put(:__private_helpers__, helpers)
    |> Map.put(:__prelude__, prelude_string(filtered_prelude))
    |> Map.put(:__kit_name__, kit_name)
    |> Map.put(:__kit_version__, kit_version)
    |> Map.put_new(:__extra_clauses__, [])
  end

  defp drop_host_injected_helpers(helpers) do
    Enum.reject(helpers, fn h ->
      MapSet.member?(@host_injected_signatures, {h.name, helper_arity_from_args(h.args)})
    end)
  end

  defp prelude_string([]), do: nil
  defp prelude_string(lines), do: lines |> Enum.uniq() |> Enum.join("\n")

  # Drop `import X, only: [name: arity, ...]` lines whose name+arity
  # collides with a local def/defp emitted in the same compiled module.
  # Elixir refuses to compile when an imported function and a local
  # function share the same name and arity. Chelekom-source's intent
  # in those cases is "use the imported version unless we override
  # locally" — but in our compiled module both end up at the same scope.
  # Local definition wins; the prelude `import only:` line is dropped.
  defp drop_imports_colliding_with_helpers(prelude_lines, helpers) do
    local_sigs = MapSet.new(helpers, fn h -> {h.name, helper_arity_from_args(h.args)} end)

    Enum.reject(prelude_lines, fn line ->
      case parse_import_only_line(line) do
        {:ok, only_pairs} ->
          Enum.any?(only_pairs, fn pair -> MapSet.member?(local_sigs, pair) end)

        :no_match ->
          false
      end
    end)
  end

  # Parse `import Mod, only: [name: arity, name: arity]` into the only_pairs
  # list `[{"name", arity}, ...]` so we can dedup against helper sigs.
  # Returns `:no_match` for any line that isn't an `import ... only: [...]`.
  defp parse_import_only_line(line) do
    case Code.string_to_quoted(line) do
      {:ok, {:import, _, [_mod, opts]}} when is_list(opts) ->
        case Keyword.get(opts, :only) do
          only when is_list(only) ->
            pairs =
              Enum.flat_map(only, fn
                {name, arity} when is_atom(name) and is_integer(arity) ->
                  [{Atom.to_string(name), arity}]

                _ ->
                  []
              end)

            {:ok, pairs}

          _ ->
            :no_match
        end

      _ ->
        :no_match
    end
  end

  defp helper_arity_from_args(""), do: 0
  defp helper_arity_from_args(nil), do: 0

  # Parse the args string via Elixir's tokenizer to count REAL top-level
  # arguments. Naive comma-splitting fails on tuple/list/map destructure
  # (`{msg, opts}` → 1 arg, not 2). Strip trailing `when guard` first.
  defp helper_arity_from_args(args) when is_binary(args) do
    head =
      case String.split(args, " when ", parts: 2) do
        [head_only] -> head_only
        [head_only, _guard] -> head_only
      end

    case Code.string_to_quoted("def __probe__(#{head}), do: nil") do
      {:ok, {:def, _, [{:__probe__, _, arg_list}, _]}} when is_list(arg_list) ->
        length(arg_list)

      {:ok, {:def, _, [{:__probe__, _, nil}, _]}} ->
        0

      _ ->
        head |> String.split(",", trim: true) |> length()
    end
  end

  defp slug_names(component, kit_name) do
    slug = slug(component.name)
    Map.put(component, :__slug_name__, "#{kit_name}-#{slug}")
  end

  defp slug(name) do
    name
    |> to_string()
    |> String.downcase()
    |> String.replace("_", "-")
  end

  ## ─── Step 9: maybe base64 ────────────────────────────────────────────

  defp maybe_base64(component, false), do: component

  defp maybe_base64(component, true) do
    %{
      component
      | template: encode_b64(component.template),
        body: encode_b64(component.body)
    }
  end

  defp encode_b64(nil), do: nil
  defp encode_b64(""), do: ""
  defp encode_b64(s) when is_binary(s), do: "base64:" <> Base.encode64(s)

  ## ─── Step 10: finalize component-params (final JSON shape) ──────────

  defp finalize_component_params(c) do
    helpers =
      c.__private_helpers__
      |> Enum.reject(&blank_helper?/1)
      |> Enum.map(fn h ->
        # Helpers MAY carry their own attrs/slots — Phoenix Component
        # allows `attr/3` and `slot/3` declarations to apply to a `defp`
        # (e.g. `attr :size, :string, default: "small" ; defp
        # toast_dismiss(assigns) do ~H""" ... """ end`). The runtime
        # compiler must emit these as `attr.()` calls right before the
        # helper's def so Phoenix can default them at request time.
        helper_attrs =
          h
          |> Map.get(:attrs, [])
          |> Enum.map(fn a ->
            base = %{"name" => a.name, "type" => a.type, "opts" => stringify_keys(a.opts)}

            if Map.has_key?(a, :struct_name),
              do: Map.put(base, "struct_name", a.struct_name),
              else: base
          end)

        helper_slots =
          h
          |> Map.get(:slots, [])
          |> Enum.map(fn s ->
            %{"name" => s.name, "opts" => stringify_keys(s.opts), "attrs" => s.attrs}
          end)

        %{
          "name" => h.name,
          "args" => h.args,
          "code" => h.code,
          "attrs" => helper_attrs,
          "slots" => helper_slots
        }
      end)

    attrs =
      Enum.map(c.attrs, fn a ->
        base = %{"name" => a.name, "type" => a.type, "opts" => stringify_keys(a.opts)}

        if Map.has_key?(a, :struct_name),
          do: Map.put(base, "struct_name", a.struct_name),
          else: base
      end)

    slots =
      Enum.map(c.slots, fn s ->
        %{"name" => s.name, "opts" => stringify_keys(s.opts), "attrs" => s.attrs}
      end)

    module_attributes =
      Enum.map(c.__module_attrs__, fn ma ->
        %{"name" => ma.name, "value" => ma.value}
      end)

    clauses_field =
      case c.__extra_clauses__ do
        [] ->
          nil

        list ->
          all = [c | list]

          Enum.map(all, fn entry ->
            %{
              "match" => entry.match,
              "guard" => entry[:guard],
              "body" => entry.body,
              "template" => entry.template
            }
          end)
      end

    %{
      "name" => c.__slug_name__,
      "site_id" => nil,
      "active" => true,
      "format" => "heex",
      "priority" => 50,
      "permissions" => [],
      "examples" => [],
      "template" => c.template,
      "body" => c.body,
      "attrs" => attrs,
      "slots" => slots,
      "helpers" => helpers,
      "extra" => %{
        "ui_kit" => c.__kit_name__,
        "ui_kit_version" => c.__kit_version__,
        "component" => c.__component_filename__,
        "function" => c.name,
        "prelude" => c.__prelude__,
        "module_attributes" => module_attributes,
        "clauses" => clauses_field
      }
    }
  end

  # Drop only when CODE is missing — empty `args` is valid (zero-arg
  # helpers like `def step_visibility(), do: ...`). The Helper embedded
  # resource defaults `args` to `""`, so the empty string round-trips.
  defp blank_helper?(%{args: _a, code: c}), do: c in [nil, ""]
  defp blank_helper?(_), do: true

  defp stringify_keys(%{} = m) do
    Enum.into(m, %{}, fn {k, v} -> {to_string(k), v} end)
  end

  defp stringify_keys(other), do: other
end
