defmodule MishkaChelekom.CmsBundle.Heex do
  @moduledoc """
  HEEx parsing for the v3 bundle exporter. One public surface for
  three jobs:

    * `tokenize/2` — return a unified token stream for raw `.heex`
      source by composing `EEx.tokenize/1` with
      `Phoenix.LiveView.TagEngine.Tokenizer.tokenize/5`. This is the same recipe
      `Phoenix.LiveView.HTMLFormatter` (the official `mix format`
      plugin for HEEx) uses internally — neither tokenizer alone
      handles raw HEEx (`EEx.tokenize` leaves HTML opaque inside
      `:text` tokens; `Phoenix.LiveView.TagEngine.Tokenizer` raises on `<%= … %>`
      mid-content).

    * `extract/2` — find every top-level chelekom-component invocation
      in a HEEx demo file and return its **verbatim source** plus
      line. Used by `mix mishka.ui.export --cms` to populate
      `extra.demo_examples` per component.

    * `rewrite/3` — rewrite sibling `<.X>` references to
      `<.component component_name="<kit>-<X-slug>" site={…} …/>`. Used
      by the bundle exporter to make cross-component calls go through
      the runtime helper.

  Source slicing (line/column → byte range) is private to this
  module — only `extract/2` and `rewrite/3` need it.

  ## Token shapes

      {:tag, name, attrs, meta}              — `<div>`, `<input/>`
      {:local_component, name, attrs, meta}  — `<.button>`, `<.icon/>`
      {:remote_component, "Mod.X", attrs, meta}
      {:slot, name, attrs, meta}             — `<:inner_block>`
      {:close, kind, name, meta}             — matching close tag
      {:text, raw, meta}                     — text between tags
      {:eex, type, expr, meta}               — `<%= … %>` etc.
      {:eex_comment, body, meta}             — `<%!-- … --%>`

  ## Failure mode

  All three public fns return *something safe* on parse failure:

    * `tokenize/2` → `{:error, message}`
    * `extract/2`  → `[]`
    * `rewrite/3`  → input unchanged

  Strict callers (e.g. `mix mishka.ui.verify`) can compare against
  `tokenize/2` directly to surface errors at author time.
  """

  @type token :: tuple()
  @type extraction :: %{component: String.t(), source: String.t(), line: pos_integer()}
  @type sibling_set :: MapSet.t(String.t())

  ## ─── tokenize ──────────────────────────────────────────────────────

  @doc """
  Tokenize raw HEEx source. Returns `{:ok, tokens}` in source order or
  `{:error, message}` on parse failure.
  """
  @spec tokenize(String.t(), keyword()) :: {:ok, [token()]} | {:error, String.t()}
  def tokenize(source, opts \\ []) when is_binary(source) do
    file = Keyword.get(opts, :file, "nofile")

    with {:ok, eex_nodes} <- safe_eex_tokenize(source) do
      try do
        {tokens, cont} =
          Enum.reduce(eex_nodes, {[], {:text, :enabled}}, &reduce_eex_node(&1, &2, source, file))

        # `Phoenix.LiveView.TagEngine.Tokenizer.finalize/4` already reverses the
        # prepend-accumulator into source order — return as-is.
        {:ok, Phoenix.LiveView.TagEngine.Tokenizer.finalize(tokens, file, cont, source)}
      rescue
        e in Phoenix.LiveView.TagEngine.Tokenizer.ParseError -> {:error, Exception.message(e)}
        e -> {:error, Exception.message(e)}
      catch
        kind, reason -> {:error, "#{inspect(kind)}: #{inspect(reason)}"}
      end
    end
  end

  defp safe_eex_tokenize(source) do
    case EEx.tokenize(source, []) do
      {:ok, tokens} -> {:ok, tokens}
      {:error, line, col, msg} -> {:error, "EEx parse error at #{line}:#{col} — #{msg}"}
      {:error, msg} -> {:error, "EEx parse error — #{inspect(msg)}"}
    end
  rescue
    e -> {:error, Exception.message(e)}
  end

  defp reduce_eex_node({:text, chars, meta}, {tokens, cont}, source, file) do
    text = List.to_string(chars)
    pos = [line: meta.line, column: meta.column]

    state =
      Phoenix.LiveView.TagEngine.Tokenizer.init(0, file, source, Phoenix.LiveView.HTMLEngine)

    Phoenix.LiveView.TagEngine.Tokenizer.tokenize(text, pos, tokens, cont, state)
  end

  defp reduce_eex_node({:comment, chars, meta}, {tokens, cont}, _source, _file) do
    {[{:eex_comment, List.to_string(chars), meta} | tokens], cont}
  end

  defp reduce_eex_node({type, opt, expr, %{column: column, line: line}}, {tokens, cont}, _src, _f)
       when type in [:start_expr, :expr, :end_expr, :middle_expr] do
    meta = %{opt: opt, line: line, column: column}
    expr_string = expr |> List.to_string() |> String.trim()
    {[{:eex, type, expr_string, meta} | tokens], cont}
  end

  defp reduce_eex_node(_other, acc, _source, _file), do: acc

  ## ─── extract (top-level kit-component invocations) ─────────────────

  @doc """
  Walk `text`, extract every top-level invocation whose tag name is in
  `kit_components`. Returns extractions in source order. Returns `[]`
  on parse failure.

  ## Options

    * `:nested` — when `true`, also emit kit invocations that sit
      *inside* another kit invocation. Off by default: a `<.card>` demo
      would otherwise yield a separate row for each `<.card_title>` it
      contains, duplicating the parent's own row. Turn it on to reach
      the components that only ever appear nested (`card_title`, `td`,
      `progress_section`), which have no top-level occurrence anywhere.
  """
  @spec extract(String.t() | nil, sibling_set(), keyword()) :: [extraction()]
  def extract(text, kit_components, opts \\ [])
  def extract(nil, _kit, _opts), do: []
  def extract("", _kit, _opts), do: []

  def extract(text, kit_components, opts) when is_binary(text) do
    if MapSet.size(kit_components) == 0 do
      []
    else
      case tokenize(text, file: "extractor") do
        {:ok, tokens} ->
          table = build_offset_table(text)
          nested? = Keyword.get(opts, :nested, false)
          walk_extract(tokens, text, table, kit_components, [], [], nested?)

        {:error, _msg} ->
          []
      end
    end
  end

  # State carried through the walker:
  #   stack — list of `{kind, name, attrs, meta}` of currently-open
  #           tags, innermost first.
  #   acc   — completed extractions, reversed at the end.
  #
  # We only emit when popping a `:local_component` whose name is in
  # `kit` AND which sits at the *outer* edge of any kit component on
  # the stack — i.e. nested kit calls inside an already-captured kit
  # call don't get a separate row.

  defp walk_extract([], _src, _table, _kit, _stack, acc, _nested?), do: Enum.reverse(acc)

  defp walk_extract(
         [{:local_component, name, _attrs, %{closing: :self} = meta} | rest],
         src,
         table,
         kit,
         stack,
         acc,
         nested?
       ) do
    if MapSet.member?(kit, name) and emit?(stack, kit, nested?) do
      {from, to} = self_closing_bounds(meta)
      base = slice!(src, table, from: from, to: to)
      snippet = wrap_with_ancestors(base, stack)

      walk_extract(
        rest,
        src,
        table,
        kit,
        stack,
        [%{component: name, source: snippet, line: meta.line} | acc],
        nested?
      )
    else
      walk_extract(rest, src, table, kit, stack, acc, nested?)
    end
  end

  defp walk_extract([{kind, name, attrs, meta} | rest], src, table, kit, stack, acc, nested?)
       when kind in [:local_component, :remote_component, :tag, :slot] do
    walk_extract(rest, src, table, kit, [{kind, name, attrs, meta} | stack], acc, nested?)
  end

  defp walk_extract(
         [{:close, kind, name, close_meta} | rest],
         src,
         table,
         kit,
         stack,
         acc,
         nested?
       )
       when kind in [:local_component, :remote_component, :tag, :slot] do
    case pop_matching(stack, kind, name) do
      {{^kind, ^name, _attrs, open_meta}, rest_stack} ->
        cond do
          kind == :local_component and MapSet.member?(kit, name) and
              emit?(rest_stack, kit, nested?) ->
            from = %{line: open_meta.line, column: open_meta.column}
            to = close_end(close_meta)
            base = slice!(src, table, from: from, to: to)
            snippet = wrap_with_ancestors(base, rest_stack)

            walk_extract(
              rest,
              src,
              table,
              kit,
              rest_stack,
              [%{component: name, source: snippet, line: open_meta.line} | acc],
              nested?
            )

          true ->
            walk_extract(rest, src, table, kit, rest_stack, acc, nested?)
        end

      :no_match ->
        walk_extract(rest, src, table, kit, stack, acc, nested?)
    end
  end

  defp walk_extract([_other | rest], src, table, kit, stack, acc, nested?) do
    walk_extract(rest, src, table, kit, stack, acc, nested?)
  end

  defp emit?(_stack, _kit, true), do: true
  defp emit?(stack, kit, false), do: not inside_kit_component?(stack, kit)

  defp inside_kit_component?(stack, kit) do
    Enum.any?(stack, fn
      {:local_component, name, _attrs, _meta} -> MapSet.member?(kit, name)
      _ -> false
    end)
  end

  defp pop_matching(stack, kind, name) do
    case Enum.split_while(stack, fn {k, n, _, _} -> not (k == kind and n == name) end) do
      {_skipped, []} -> :no_match
      {_skipped, [match | rest]} -> {match, rest}
    end
  end

  defp self_closing_bounds(meta) do
    {to_line, to_col} = meta.inner_location
    {%{line: meta.line, column: meta.column}, %{line: to_line, column: to_col}}
  end

  defp close_end(%{line: line, column: col, tag_name: name}) when is_binary(name) do
    %{line: line, column: col + byte_size("</#{name}>")}
  end

  defp close_end(%{line: line, column: col}), do: %{line: line, column: col}

  # Re-wrap an extracted snippet with any enclosing `:for=` / `:if=`
  # directives so the snippet renders self-contained when fed back
  # into the harness.
  defp wrap_with_ancestors(snippet, stack) do
    pairs =
      stack
      |> Enum.reverse()
      |> Enum.flat_map(&directive_wrapper/1)

    case pairs do
      [] ->
        snippet

      _ ->
        opens = Enum.map_join(pairs, "", fn {open, _close} -> open end)

        closes =
          pairs |> Enum.reverse() |> Enum.map_join("", fn {_open, close} -> close end)

        opens <> snippet <> closes
    end
  end

  defp directive_wrapper({kind, name, attrs, _meta}) do
    case directive_attrs(attrs) do
      [] ->
        []

      directives ->
        directive_text = Enum.map_join(directives, " ", fn {k, v} -> "#{k}={#{v}}" end)

        tag_name =
          case kind do
            :local_component -> "." <> name
            _ -> name
          end

        [{"<#{tag_name} #{directive_text}>", "</#{tag_name}>"}]
    end
  end

  defp directive_attrs(attrs) do
    Enum.flat_map(attrs, fn
      {":" <> _ = key, {:expr, value, _meta}, _} -> [{key, value}]
      _ -> []
    end)
  end

  ## ─── rewrite (sibling refs → runtime component helper) ─────────────

  @doc """
  Rewrite a template body. Every `<.NAME …>` whose `NAME` is in
  `siblings` becomes `<.component component_name="<kit>-<slug>"
  site={assigns[:site]} …>`; matching `</.NAME>` becomes
  `</.component>`. Other tags, EEx blocks, and string literals are
  preserved verbatim.

  Returns the input unchanged on parse failure.
  """
  @spec rewrite(String.t() | nil, sibling_set(), String.t()) :: String.t() | nil
  def rewrite(nil, _siblings, _kit), do: nil
  def rewrite("", _siblings, _kit), do: ""

  def rewrite(template, siblings, kit_name) when is_binary(template) do
    if MapSet.size(siblings) == 0 do
      template
    else
      case tokenize(template, file: "rewriter") do
        {:ok, tokens} -> apply_sibling_rewrites(template, tokens, siblings, kit_name)
        {:error, _msg} -> template
      end
    end
  end

  defp apply_sibling_rewrites(source, tokens, siblings, kit_name) do
    table = build_offset_table(source)

    replacements =
      Enum.flat_map(tokens, fn
        {:local_component, name, _attrs, meta} ->
          if MapSet.member?(siblings, name) do
            [{open_range(meta), open_replacement(name, kit_name)}]
          else
            []
          end

        {:close, :local_component, name, meta} ->
          if MapSet.member?(siblings, name) do
            [{close_range(meta), "</.component>"}]
          else
            []
          end

        _ ->
          []
      end)

    splice_replacements(source, table, replacements)
  end

  defp splice_replacements(source, _table, []), do: source

  defp splice_replacements(source, table, replacements) do
    sorted =
      Enum.sort_by(replacements, fn {%{from: from}, _} -> {from.line, from.column} end)

    {cursor, parts} =
      Enum.reduce(sorted, {0, []}, fn {%{from: from, to: to}, replacement}, {cursor, parts} ->
        from_b = byte_offset(table, from.line, from.column)
        to_b = byte_offset(table, to.line, to.column)
        head = binary_part(source, cursor, from_b - cursor)
        {to_b, [replacement, head | parts]}
      end)

    tail = binary_part(source, cursor, byte_size(source) - cursor)
    [tail | parts] |> Enum.reverse() |> IO.iodata_to_binary()
  end

  # Replace just the head `<.NAME` of an opening tag — leaves the rest
  # of the tag (attrs + `>` / `/>`) flowing through untouched.
  defp open_range(meta) do
    %{
      from: %{line: meta.line, column: meta.column},
      to: %{line: meta.line, column: meta.column + byte_size("<#{meta.tag_name}")}
    }
  end

  defp close_range(meta) do
    %{
      from: %{line: meta.line, column: meta.column},
      to: %{line: meta.line, column: meta.column + byte_size("</#{meta.tag_name}>")}
    }
  end

  # `assigns[:site]` (Access protocol) is used instead of `@site` so
  # siblings called from inside private helpers / slot inner_blocks
  # don't crash with `KeyError` on the missing `:site` assign — the
  # Access form returns `nil`, and the runtime helper coerces `nil` →
  # "Global".
  defp open_replacement(name, kit_name) do
    target = kit_name <> "-" <> slug(name)
    ~s|<.component component_name="#{target}" site={assigns[:site]}|
  end

  defp slug(name), do: name |> String.downcase() |> String.replace("_", "-")

  ## ─── source slicing (line/column → byte) ───────────────────────────

  defp build_offset_table(source) do
    lines = String.split(source, "\n", trim: false)

    {offsets, _} =
      Enum.map_reduce(lines, 0, fn line, offset ->
        {offset, offset + byte_size(line) + 1}
      end)

    List.to_tuple(offsets)
  end

  defp slice!(source, table, opts) do
    %{line: from_line, column: from_col} = Keyword.fetch!(opts, :from)
    %{line: to_line, column: to_col} = Keyword.fetch!(opts, :to)

    from_byte = byte_offset(table, from_line, from_col)
    to_byte = byte_offset(table, to_line, to_col)

    binary_part(source, from_byte, max(0, to_byte - from_byte))
  end

  defp byte_offset(table, line, column), do: elem(table, line - 1) + (column - 1)
end
