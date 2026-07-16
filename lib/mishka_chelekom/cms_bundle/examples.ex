defmodule MishkaChelekom.CmsBundle.Examples do
  @moduledoc """
  Turn a component's harvested snippets into the ordered, per-option
  tagged example set the v3 bundle ships.

  ## Sources, in preference order

    * `:docs` — the function's own `@doc "## Examples"` fences. Written
      per function by the kit author, minimal, with real content. This
      is where the **base** example comes from (121 of 136 components
      have one).
    * `:page` — `code_string(N)` snippets off the vendored docs page,
      each tagged with the `<.heading2>` section it sits under. These
      enumerate one invocation per option value
      (`<.card color="primary" variant="outline">…`), which is what
      makes per-option tagging possible.
    * `:demo` — invocations scraped from the docs page markup. Last
      resort: the markup interleaves page scaffolding with the demo.

  ## Output

  `examples` is the flat `{:array, :string}` the CMS `Component`
  attribute accepts; `extra.examples` is the same list with metadata,
  each entry carrying its own `source` so the two can never drift out
  of alignment. Base first, then broadest option coverage first.

  ## Why `requires`

  MishkaCMS installs a component **minimal by default** — only its
  default variant — and `UiKitHandler.narrow_component/3` physically
  drops the helper clauses the selection rules out. An example pinned
  to `variant="outline"` is dead markup on such an install. `requires`
  lets the consumer hide it. The installed universe is recoverable from
  `helpers[].discriminators`, which narrowing rewrites, so the consumer
  never needs anything this module does not already ship.
  """

  alias MishkaChelekom.CmsBundle.Heex

  # Same axes MishkaCMS's UiKitCatalog offers for per-component narrowing.
  @axes ~w(variant color size padding space rounded border)

  @type source_kind :: :docs | :page | :demo
  @type candidate :: %{
          source: String.t(),
          section: String.t() | nil,
          label: String.t() | nil,
          kind: source_kind(),
          assigns: map()
        }

  @doc """
  The option values this component actually ships, folded from its
  helpers' discriminators — the same fold
  `UiKitHandler.component_features/1` does at install time.
  """
  @spec option_universe(map()) :: %{optional(String.t()) => MapSet.t(String.t())}
  def option_universe(component) do
    for helper <- component["helpers"] || [],
        clause <- helper["discriminators"] || [],
        reduce: %{} do
      acc ->
        axis = clause["axis"]
        values = MapSet.new(clause["values"] || [])
        Map.update(acc, axis, values, &MapSet.union(&1, values))
    end
  end

  @doc """
  Build `{examples, extra_examples}` for one component.

  `groups` is a keyword-ish map of `%{docs: [...], page: [...], demo: [...]}`
  whose entries are raw snippet blocks (`:docs`) or maps with
  `:source`/`:section`/`:label`/`:assigns`.
  """
  @spec build(map(), map(), MapSet.t(String.t()), String.t(), pos_integer()) ::
          {[String.t()], [map()]}
  def build(component, groups, kit_set, kit_name, max) do
    fn_name = component["extra"]["function"]
    self_name = component["name"]
    universe = option_universe(component)

    selected =
      [:docs, :page, :demo]
      |> Enum.flat_map(fn kind ->
        groups
        |> Map.get(kind, [])
        |> Enum.flat_map(&expand(&1, kind, fn_name, kit_set, kit_name))
      end)
      |> Enum.uniq_by(& &1.source)
      |> Enum.map(&tag(&1, universe, self_name))
      |> select(max, attr_defaults(component), universe)

    {Enum.map(selected, & &1["source"]), selected}
  end

  # One raw block may hold several sibling invocations (the docs
  # enumerate one per option value). Split into individual top-level
  # invocations of this function, then normalize each.
  defp expand(block, kind, fn_name, kit_set, kit_name) do
    {raw, section, label, assigns} = unpack(block)

    raw
    |> invocations(fn_name, kit_set)
    |> Enum.map(fn ext ->
      source =
        ext.source
        |> Heex.rewrite(kit_set, kit_name)
        |> MishkaChelekom.CmsBundle.Sanitize.normalize(assigns)

      %{source: source, section: section, label: label, kind: kind, assigns: assigns}
    end)
    |> Enum.filter(&MishkaChelekom.CmsBundle.Sanitize.self_contained?(&1.source))
  end

  # Components that only ever appear nested (`card_title`, `td`,
  # `progress_section`) have no top-level occurrence to find — even
  # their own `@doc` wraps them in their parent. Descend only when the
  # cheap pass comes back empty, so a `<.card>` demo still yields one
  # row rather than one per sub-component.
  defp invocations(raw, fn_name, kit_set) do
    case mine(raw, fn_name, kit_set, []) do
      [] -> mine(raw, fn_name, kit_set, nested: true)
      found -> found
    end
  end

  defp mine(raw, fn_name, kit_set, opts) do
    raw
    |> Heex.extract(kit_set, opts)
    |> Enum.filter(&(to_string(&1.component) == to_string(fn_name)))
  end

  defp unpack(block) when is_binary(block), do: {block, nil, nil, %{}}

  defp unpack(%{} = b) do
    {b[:source] || b["source"], b[:section] || b["section"], b[:label] || b["label"],
     b[:assigns] || b["assigns"] || %{}}
  end

  # `requires` comes from the snippet's real attrs, never the section id:
  # ids flip direction, use a different word than the prop
  # (`badge-radius` documents `rounded`), and carry typos. An attr value
  # outside the component's own universe is a Tailwind passthrough
  # (`variant="bg-[#2B6392]"`), not an option — drop it.
  defp tag(candidate, universe, self_name) do
    {root_attrs, refs} = dissect(candidate.source)

    axes =
      for axis <- @axes,
          value = Map.get(root_attrs, axis),
          is_binary(value),
          allowed = Map.get(universe, axis),
          allowed && MapSet.member?(allowed, value),
          into: %{} do
        {axis, [value]}
      end

    components = refs |> Enum.reject(&(&1 == self_name)) |> Enum.uniq() |> Enum.sort()

    requires = if components == [], do: axes, else: Map.put(axes, "components", components)

    %{
      "source" => candidate.source,
      "label" => candidate.label,
      "section" => candidate.section,
      "base" => false,
      "requires" => requires,
      "__kind__" => candidate.kind,
      "__axes__" => axes
    }
  end

  # Attrs of the outermost tag, plus every `component_name="…"` the
  # snippet dispatches to.
  defp dissect(source) do
    case Heex.tokenize(source, file: "example") do
      {:ok, tokens} ->
        refs =
          Enum.flat_map(tokens, fn
            {:local_component, "component", attrs, _} ->
              List.wrap(literal(attrs, "component_name"))

            _ ->
              []
          end)

        root =
          Enum.find_value(tokens, %{}, fn
            {:local_component, "component", attrs, _} -> literal_attrs(attrs)
            _ -> nil
          end)

        {root, refs}

      {:error, _} ->
        {%{}, []}
    end
  end

  defp literal_attrs(attrs) do
    for {name, {:string, value, _}, _} <- attrs, into: %{}, do: {name, value}
  end

  defp literal(attrs, key) do
    Enum.find_value(attrs, fn
      {^key, {:string, value, _}, _} -> value
      _ -> nil
    end)
  end

  # Base first, then one example per distinct option VALUE, walking the
  # axes in @axes order so the visually decisive ones (variant, then
  # color) are covered before a slot goes to `space` or `border`. A
  # plain greedy loses that: `<.card space="small">` and
  # `<.card variant="outline" color="natural">` are equally close to the
  # defaults, so the shorter one wins every tie and the variants fall
  # off the end of the cap.
  defp select([], _max, _defaults, _universe), do: []

  defp select(candidates, max, defaults, universe) do
    {base, rest} = take_base(candidates, defaults)
    ranked = Enum.sort_by(rest, &sort_key(&1, defaults))

    covered_by_axis =
      for axis <- @axes,
          value <- Map.get(universe, axis, MapSet.new()) |> Enum.sort(),
          do: {axis, value}

    by_value = Enum.reduce(covered_by_axis, [base], &take_for(&1, &2, ranked, max))

    chosen = fill(by_value, ranked, max) -- [base]

    [base |> Map.put("base", true) |> Map.update("label", "Base", &(&1 || "Base")) | chosen]
    |> Enum.take(max)
    |> Enum.map(&Map.drop(&1, ["__kind__", "__axes__"]))
  end

  defp take_for({axis, value}, acc, ranked, max) do
    cond do
      length(acc) >= max ->
        acc

      Enum.any?(acc, &(&1["__axes__"][axis] == [value])) ->
        acc

      true ->
        case Enum.find(ranked, &(&1["__axes__"][axis] == [value] and &1 not in acc)) do
          nil -> acc
          found -> acc ++ [found]
        end
    end
  end

  # Composite examples pin no option at all (`<.card>` wrapping a title,
  # content and footer) so no axis target ever reaches them — yet they
  # are the ones worth dragging onto a page. Give them the slots the
  # axis pass left over.
  defp fill(acc, ranked, max) do
    ranked
    |> Enum.reject(&(&1 in acc))
    |> Enum.reduce(acc, fn c, acc ->
      if length(acc) >= max, do: acc, else: acc ++ [c]
    end)
  end

  # The base is whatever sits closest to the component's own defaults —
  # that is what "base" means, and defaults are the one configuration
  # every install is guaranteed to have. Only then prefer the author's
  # `@doc`, which is otherwise the richest source but is sometimes
  # written to showcase one variant (`button/1`'s doc demos
  # `inverted_gradient`) and would make a misleading base.
  defp take_base(candidates, defaults) do
    base =
      Enum.min_by(candidates, fn c ->
        {off_default(c, defaults), if(c["__kind__"] == :docs, do: 0, else: 1),
         map_size(c["__axes__"]), byte_size(c["source"])}
      end)

    {base, List.delete(candidates, base)}
  end

  # Prefer curated sources, then examples that differ from the defaults
  # on as few axes as possible: `variant="outline" color="natural"`
  # survives a minimal install where `variant="outline" color="info"`
  # does not, and it still retires the `variant=outline` slot. Without
  # this the greedy pass happily spends every slot on one variant in
  # twelve colors.
  defp sort_key(c, defaults) do
    kind_rank = %{docs: 0, page: 1, demo: 2}

    {Map.fetch!(kind_rank, c["__kind__"]), off_default(c, defaults), byte_size(c["source"])}
  end

  defp off_default(c, defaults) do
    Enum.count(c["__axes__"], fn {axis, [value]} -> Map.get(defaults, axis) != value end)
  end

  defp attr_defaults(component) do
    for attr <- component["attrs"] || [],
        default = get_in(attr, ["opts", "default"]),
        is_binary(default),
        into: %{},
        do: {attr["name"], default}
  end
end
