defmodule MishkaChelekom.Kit.Runtime do
  @moduledoc """
  Runtime support for the wrappers the Kit generates — pure `assigns` (map) manipulation, so a
  wrapper stays a thin delegator to the real component. One `transform/2` handles both worlds:

    * styled (`spec.attrs`) — remap a customized color/variant/size value to the component's neutral
      `base`, then layer your classes (verbatim — write the `!` yourself so they win without a
      class-merge, since the generated components don't run one), preserving the attr's type;
    * headless (`spec.class`) — add your part classes (verbatim `[&_[data-part=…]]:`) to the root.
  """

  @doc "Transform assigns for a customized component before delegating to the real one."
  def transform(assigns, spec) do
    assigns =
      assigns
      |> apply_defaults(spec.default)
      |> apply_class(spec[:class])

    # Variant×color PAIR rules are most specific — apply the matching one first, and remember which
    # dimensions it consumed so the single-value rules below don't re-handle them.
    {assigns, handled} = apply_pairs(assigns, spec[:pairs], spec.base)
    apply_dimensions(assigns, spec[:attrs], spec.base, handled)
  end

  # --- internals -----------------------------------------------------------------------

  defp apply_defaults(assigns, default) do
    Enum.reduce(default, assigns, fn {k, v}, acc ->
      if Map.get(acc, k) in [nil, ""], do: Map.put(acc, k, v), else: acc
    end)
  end

  defp apply_class(assigns, nil), do: assigns
  defp apply_class(assigns, class), do: add_class(assigns, class)

  # Pair rules: apply the FIRST whose every pinned dimension matches the assigns. On a match, remap
  # each pinned dimension to base (so the real component renders neutral) and append the classes;
  # return the set of consumed dimensions so single-value rules skip them.
  defp apply_pairs(assigns, pairs, _base) when pairs in [nil, []], do: {assigns, MapSet.new()}

  defp apply_pairs(assigns, pairs, base) do
    case Enum.find(pairs, &pair_matches?(assigns, &1.match)) do
      nil ->
        {assigns, MapSet.new()}

      %{match: match, classes: classes} ->
        dims = match |> Map.keys() |> Enum.map(&String.to_existing_atom/1)

        assigns =
          dims
          |> Enum.reduce(assigns, fn d, acc -> Map.put(acc, d, safe(Map.get(acc, d), base)) end)
          |> add_class(classes)

        {assigns, MapSet.new(dims)}
    end
  end

  defp pair_matches?(assigns, match) do
    Enum.all?(match, fn {k, v} ->
      to_string(Map.get(assigns, String.to_existing_atom(k))) == v
    end)
  end

  defp apply_dimensions(assigns, nil, _base, _handled), do: assigns

  defp apply_dimensions(assigns, attrs, base, handled) do
    Enum.reduce(attrs, assigns, fn {attr, rules}, acc ->
      cond do
        MapSet.member?(handled, attr) ->
          # a pair rule already consumed this dimension
          acc

        classes = Map.get(rules, to_string(Map.get(acc, attr))) ->
          # `classes` are verbatim — exactly what you wrote in the Kit (incl. any trailing `!`)
          acc
          |> Map.put(attr, safe(Map.get(acc, attr), base))
          |> add_class(classes)

        true ->
          acc
      end
    end)
  end

  defp add_class(assigns, classes) do
    Map.update(assigns, :class, classes, fn existing -> [classes, existing] end)
  end

  # Preserve the attr's type: atom attrs (e.g. alert's `kind`) stay atoms.
  defp safe(current, base) when is_atom(current) and not is_nil(current), do: String.to_atom(base)
  defp safe(_current, base), do: base
end
