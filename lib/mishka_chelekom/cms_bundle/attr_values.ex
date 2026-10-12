defmodule MishkaChelekom.CmsBundle.AttrValues do
  @moduledoc """
  What each attribute of a component accepts, written the way `attr/3` writes it.

  Three facts decide it, and each is read off the source rather than off a list of names:

    * **Which list.** The `.exs` `args` name the values of each axis — `variant`, `color`, `size`…
      An attribute named for an axis takes that axis's list. An attribute named something else
      takes the list of the axis its helper position is gated on: `chelekom-alert`'s `kind` reaches
      `color_variant(@variant, @kind)` in the position every `<%= if … in @color %>` clause matches
      on, so it takes the `color` list.

    * **Which args are not axes.** `type` and `only` choose which functions the generator writes;
      when every value of a list is the name of one of the file's own public functions, the list
      is that choice and belongs to no attribute. `chelekom-input-button`'s HTML `type` took
      `["button_group", "button", …]` until this was read.

    * **Closed or open.** An attribute every one of whose helper positions ends in a catch-all
      `defp helper(params) when is_binary(params)` accepts any class string beside the named
      values — `size="py-1 px-2"` is as valid as `size="small"`. Its list is shipped as
      `examples`, Phoenix's own option for a non-exhaustive list. Every other list is `values`, a
      closed set. An attribute this cannot read in full — a use outside a helper call, a
      comparison, a class list or an HTML attribute, or a helper clause that does not parse — is
      closed.

  A `values:` the `.eex` writes itself is never replaced: it is the template saying so.
  """

  alias MishkaChelekom.CmsBundle.Heex

  @typedoc "The list an attribute ships, and whether it is closed (`:values`) or open (`:examples`)."
  @type declaration :: {:values | :examples, [String.t()]}

  @declarable_types ~w(string any atom)
  @comparisons [:==, :!=, :===, :!==]

  @doc """
  The axes of a component's `args`: every list whose values are not all names of the component's
  own public functions, keyed by the arg's name.

      iex> MishkaChelekom.CmsBundle.AttrValues.axes(
      ...>   [size: ["small", "large"], type: ["button", "button_link"], helpers: [], module: ""],
      ...>   ["button", "button_link"]
      ...> )
      %{"size" => ["small", "large"]}
  """
  @spec axes(term(), [String.t() | atom()]) :: %{String.t() => [String.t()]}
  def axes(args, public_names) when is_list(args) do
    names = MapSet.new(public_names, &to_string/1)

    for {key, list} <- args,
        is_atom(key),
        is_list(list),
        values = Enum.filter(list, &is_binary/1),
        values != [],
        not Enum.all?(values, &MapSet.member?(names, &1)),
        into: %{},
        do: {Atom.to_string(key), values}
  end

  def axes(_args, _public_names), do: %{}

  @doc """
  The declaration of every attribute of `component` that has a list to ship, keyed by attribute
  name. An attribute whose `.eex` declares `values:`, or that no axis reaches, is absent.

  `component` is the exporter's own shape: `:attrs`, `:template`, `:body`, `:__extra_clauses__`
  and `:__private_helpers__` (each helper with `:name`, `:args` and `:discriminators`).
  """
  @spec declare(map(), %{String.t() => [String.t()]}) :: %{String.t() => declaration()}
  def declare(component, axes) do
    clauses = helper_clauses(Map.get(component, :__private_helpers__, []))
    uses = uses(component, Map.keys(clauses))

    for attr <- Map.get(component, :attrs, []),
        attr.type in @declarable_types,
        not Map.has_key?(attr.opts, "values"),
        attr_uses = Map.get(uses, attr.name, []),
        list = list_for(attr.name, attr_uses, clauses, axes),
        is_list(list),
        declaration = declaration(attr, list, open?(attr_uses, clauses)),
        declaration != nil,
        into: %{},
        do: {attr.name, declaration}
  end

  @doc """
  Puts a declaration on an attribute's string-keyed opts. A list the opts already carry wins.
  """
  @spec put(map(), declaration() | nil) :: map()
  def put(opts, nil), do: opts

  def put(opts, {key, list}) do
    case Map.has_key?(opts, "values") or Map.has_key?(opts, "examples") do
      true -> opts
      false -> Map.put(opts, Atom.to_string(key), list)
    end
  end

  # An attribute named for an axis takes it; one that is not takes the single axis its helper
  # positions are gated on. Two positions gated on two different axes say nothing.
  defp list_for(name, uses, clauses, axes) do
    case Map.fetch(axes, name) do
      {:ok, list} ->
        list

      :error ->
        bound =
          for {:helper, helper, arity, index, _call} <- uses,
              axis = bound_axis(Map.get(clauses, helper, []), arity, index, axes),
              axis != nil,
              uniq: true,
              do: axis

        case bound do
          [axis] -> Map.fetch!(axes, axis)
          _none_or_several -> nil
        end
    end
  end

  # Phoenix refuses a `values:` list that leaves out the attribute's own default — several
  # components default to `""` for "unset" — so a closed list is dropped for those. `examples:`
  # has no such rule.
  defp declaration(%{type: type}, list, true) when type in ["string", "any"],
    do: {:examples, list}

  defp declaration(attr, list, _open?) do
    case Map.fetch(attr.opts, "default") do
      {:ok, default} when not is_nil(default) ->
        if to_string(default) in list, do: {:values, list}, else: nil

      _no_default ->
        {:values, list}
    end
  end

  ## ─── Openness ──────────────────────────────────────────────────────

  defp open?(uses, clauses) do
    positions =
      Enum.map(uses, fn
        {:helper, helper, arity, index, call} ->
          position(Map.get(clauses, helper, []), arity, index, call)

        other ->
          other
      end)

    :open in positions and Enum.all?(positions, &(&1 in [:open, :tolerant, :harmless]))
  end

  # `:open` — a clause takes any binary in this position and matches what the call passes in the
  # others. `:tolerant` — a clause leaves this position unconstrained, so a class string here falls
  # through to it. Anything else, or a helper with a clause that does not parse, is `:closed`.
  defp position(clauses, arity, index, call) do
    heads = Enum.filter(clauses, &(&1 == :unparsed or length(&1.params) == arity))

    cond do
      heads == [] or :unparsed in heads -> :closed
      Enum.any?(heads, &open_at?(&1, index, call)) -> :open
      Enum.any?(heads, &tolerant_at?(&1, index, call)) -> :tolerant
      true -> :closed
    end
  end

  defp open_at?(%{params: params, guard: guard}, index, call) do
    case Enum.at(params, index) do
      {var, _, ctx} when is_atom(var) and is_atom(ctx) ->
        others_accept?(params, index, call) and binary_guard?(guard, var)

      _constrained ->
        false
    end
  end

  defp tolerant_at?(%{params: params, guard: guard}, index, call) do
    case Enum.at(params, index) do
      {var, _, ctx} when is_atom(var) and is_atom(ctx) ->
        others_accept?(params, index, call) and not mentions?(guard, var)

      _constrained ->
        false
    end
  end

  # Every other position is a variable, or the very literal the call passes there —
  # `size_class(@size, :icon)` reaches `size_class(params, :icon) when is_binary(params)`.
  defp others_accept?(params, index, call) do
    params
    |> Enum.zip(call)
    |> List.delete_at(index)
    |> Enum.all?(fn
      {{var, _, ctx}, _given} when is_atom(var) and is_atom(ctx) -> true
      {literal, literal} -> is_atom(literal) or is_binary(literal) or is_number(literal)
      _other -> false
    end)
  end

  defp binary_guard?({:is_binary, _, [{var, _, _}]}, var), do: true

  defp binary_guard?({op, _, [left, right]}, var) when op in [:and, :or],
    do: binary_guard?(left, var) or binary_guard?(right, var)

  defp binary_guard?(_guard, _var), do: false

  defp mentions?(nil, _var), do: false

  defp mentions?(guard, var) do
    {_ast, found?} =
      Macro.prewalk(guard, false, fn
        {^var, _, ctx} = node, _found when is_atom(ctx) -> {node, true}
        node, found -> {node, found}
      end)

    found?
  end

  ## ─── Axis binding ──────────────────────────────────────────────────

  # The axis a helper position is gated on: every clause that names a literal in this position and
  # sits inside an `<%= if … in @axis %>` agrees with that axis, at least one does, and no other
  # axis can say the same.
  defp bound_axis(clauses, arity, index, axes) do
    literal_clauses =
      for %{params: params} = clause <- clauses,
          length(params) == arity,
          literals = literals(Enum.at(params, index), clause.guard),
          literals != [],
          do: {literals, clause.discriminators}

    candidates =
      for axis <- Map.keys(axes),
          verdicts = Enum.flat_map(literal_clauses, &verdict(&1, axis)),
          verdicts != [],
          Enum.all?(verdicts),
          do: axis

    case candidates do
      [axis] -> axis
      _none_or_several -> nil
    end
  end

  defp verdict({literals, discriminators}, axis) do
    case Enum.find(discriminators, &(&1["axis"] == axis)) do
      nil ->
        []

      %{"values" => values} ->
        [Enum.any?(literals, &(&1 in Enum.map(values, fn v -> to_string(v) end)))]
    end
  end

  defp literals(literal, _guard) when is_binary(literal) or is_atom(literal),
    do: if(is_boolean(literal) or is_nil(literal), do: [], else: [to_string(literal)])

  defp literals({var, _, ctx}, guard) when is_atom(var) and is_atom(ctx),
    do: guarded_in(guard, var)

  defp literals(_pattern, _guard), do: []

  defp guarded_in({:in, _, [{var, _, _}, list]}, var) when is_list(list),
    do: for(item <- list, is_binary(item) or is_atom(item), do: to_string(item))

  defp guarded_in({op, _, [left, right]}, var) when op in [:and, :or],
    do: guarded_in(left, var) ++ guarded_in(right, var)

  defp guarded_in(_guard, _var), do: []

  ## ─── Helper clause heads ───────────────────────────────────────────

  defp helper_clauses(helpers) do
    helpers
    |> Enum.group_by(&to_string(&1.name))
    |> Map.new(fn {name, list} -> {name, Enum.map(list, &head/1)} end)
  end

  defp head(helper) do
    case Code.string_to_quoted("fn #{helper.args || ""} -> nil end") do
      {:ok, {:fn, _, [{:->, _, [[{:when, _, params_and_guard}], _]}]}} ->
        {params, [guard]} = Enum.split(params_and_guard, -1)
        %{params: params, guard: guard, discriminators: Map.get(helper, :discriminators, [])}

      {:ok, {:fn, _, [{:->, _, [params, _]}]}} ->
        %{params: params, guard: nil, discriminators: Map.get(helper, :discriminators, [])}

      _unparsed ->
        :unparsed
    end
  end

  ## ─── Uses of each attribute ────────────────────────────────────────

  # Every place a component reads each of its attributes, as `{:helper, name, arity, index, args}`,
  # `:harmless` (a comparison, a condition, a class list, an HTML attribute, rendered text) or
  # `:unknown`. A reference the parse did not reach — counted in the raw text — is `:unknown`.
  defp uses(component, helper_names) do
    helpers = MapSet.new(helper_names)
    clauses = Map.get(component, :__extra_clauses__, [])

    templates = Enum.filter([component.template | Enum.map(clauses, & &1.template)], &is_binary/1)
    bodies = Enum.filter([component.body | Enum.map(clauses, & &1.body)], &is_binary/1)

    found =
      Enum.flat_map(templates, &template_uses(&1, helpers)) ++
        Enum.flat_map(bodies, &code_uses(&1, {:top, :code}, helpers))

    by_attr = Enum.group_by(found, &elem(&1, 0), &elem(&1, 1))

    Map.new(Map.get(component, :attrs, []), fn %{name: name} ->
      parsed = Map.get(by_attr, name, [])
      written = Enum.sum(Enum.map(templates ++ bodies, &count_refs(&1, name)))
      missed = List.duplicate(:unknown, max(written - length(parsed), 0))
      {name, parsed ++ missed}
    end)
  end

  defp count_refs(text, name) do
    ~r/@#{name}\b|\bassigns\.#{name}\b|\bassigns\[:#{name}\]/
    |> Regex.scan(text)
    |> length()
  end

  defp template_uses(template, helpers) do
    case Heex.tokenize(template) do
      {:ok, tokens} -> Enum.flat_map(tokens, &token_uses(&1, helpers))
      {:error, _message} -> []
    end
  end

  defp token_uses({kind, _name, attrs, _meta}, helpers)
       when kind in [:tag, :local_component, :remote_component, :slot] and is_list(attrs) do
    context = if kind == :tag, do: :html, else: :component

    Enum.flat_map(attrs, fn
      {attr, {:expr, code, _}, _} -> code_uses(code, {:top, {context, to_string(attr)}}, helpers)
      _literal -> []
    end)
  end

  defp token_uses({:body_expr, code, _meta}, helpers),
    do: code_uses(code, {:top, :text}, helpers)

  defp token_uses({:eex, :start_expr, code, _meta}, helpers),
    do: code_uses(code <> "\nend", {:top, :text}, helpers)

  defp token_uses({:eex, :expr, code, _meta}, helpers),
    do: code_uses(code, {:top, :text}, helpers)

  defp token_uses(_token, _helpers), do: []

  defp code_uses(code, context, helpers) do
    case Code.string_to_quoted(code) do
      {:ok, ast} -> walk(ast, context, helpers, [])
      {:error, _reason} -> []
    end
  end

  defp walk(node, parent, helpers, acc) do
    case attr_ref(node) do
      {:ok, name} -> [{name, use_of(parent, helpers)} | acc]
      :error -> descend(node, parent, helpers, acc)
    end
  end

  defp descend({head, _meta, args} = node, _parent, helpers, acc) when is_list(args) do
    acc = if is_tuple(head), do: walk(head, {node, :head}, helpers, acc), else: acc

    args
    |> Enum.with_index()
    |> Enum.reduce(acc, fn {arg, index}, acc -> walk(arg, {node, index}, helpers, acc) end)
  end

  defp descend(list, parent, helpers, acc) when is_list(list),
    do: Enum.reduce(list, acc, &walk(&1, {:list, parent}, helpers, &2))

  defp descend({left, right}, _parent, helpers, acc),
    do: walk(right, :pair, helpers, walk(left, :pair, helpers, acc))

  defp descend(_leaf, _parent, _helpers, acc), do: acc

  defp attr_ref({:@, _, [{name, _, ctx}]}) when is_atom(name) and is_atom(ctx),
    do: {:ok, Atom.to_string(name)}

  defp attr_ref({{:., _, [{:assigns, _, ctx}, name]}, _, []}) when is_atom(name) and is_atom(ctx),
    do: {:ok, Atom.to_string(name)}

  defp attr_ref({{:., _, [Access, :get]}, _, [{:assigns, _, ctx}, name]})
       when is_atom(name) and is_atom(ctx),
       do: {:ok, Atom.to_string(name)}

  defp attr_ref(_node), do: :error

  defp use_of({{name, _, args}, index}, helpers) when is_atom(name) and is_integer(index) do
    cond do
      MapSet.member?(helpers, Atom.to_string(name)) ->
        {:helper, Atom.to_string(name), length(args), index, args}

      name in @comparisons ->
        :harmless

      name in [:in, :&&, :and, :if, :unless, :case, :cond] and index == 0 ->
        :harmless

      name in [:!, :not] ->
        :harmless

      true ->
        :unknown
    end
  end

  defp use_of({:list, {:top, {_context, "class"}}}, _helpers), do: :harmless
  defp use_of({:list, {:top, {:html, _attr}}}, _helpers), do: :harmless
  defp use_of({:top, {:html, _attr}}, _helpers), do: :harmless
  defp use_of({:top, {:component, "class"}}, _helpers), do: :harmless
  defp use_of({:top, :text}, _helpers), do: :harmless
  defp use_of(_parent, _helpers), do: :unknown
end
