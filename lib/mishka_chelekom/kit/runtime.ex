defmodule MishkaChelekom.Kit.Runtime do
  @moduledoc """
  Runtime support for the wrappers the Kit generates — pure `assigns` (map) manipulation, so a
  wrapper stays a thin delegator to the real component. One `transform/2` handles both worlds:

    * styled (`spec.attrs`) — remap a customized color/variant/size value to the component's neutral
      `base`, then layer your classes as Tailwind-v4 `!important` (so they win without a class-merge,
      since the generated components don't run one), preserving the attr's type (atom/string);
    * headless (`spec.class`) — add the compiled `[&_[data-part=…]]:` classes to the root.
  """

  @doc "Transform assigns for a customized component before delegating to the real one."
  def transform(assigns, spec) do
    assigns
    |> apply_defaults(spec.default)
    |> apply_class(spec[:class])
    |> apply_dimensions(spec[:attrs], spec.base)
  end

  @doc "Mark every utility in a class string as `!important` (Tailwind v4 trailing-`!`). Idempotent."
  def important(classes) do
    classes
    |> String.split()
    |> Enum.map_join(" ", fn
      "" -> ""
      token -> if String.ends_with?(token, "!"), do: token, else: token <> "!"
    end)
  end

  # --- internals -----------------------------------------------------------------------

  defp apply_defaults(assigns, default) do
    Enum.reduce(default, assigns, fn {k, v}, acc ->
      if Map.get(acc, k) in [nil, ""], do: Map.put(acc, k, v), else: acc
    end)
  end

  defp apply_class(assigns, nil), do: assigns
  defp apply_class(assigns, class), do: add_class(assigns, class)

  defp apply_dimensions(assigns, nil, _base), do: assigns

  defp apply_dimensions(assigns, attrs, base) do
    Enum.reduce(attrs, assigns, fn {attr, rules}, acc ->
      case Map.get(rules, to_string(Map.get(acc, attr))) do
        nil ->
          acc

        classes ->
          # `classes` is already in `!important` form — precomputed at compile time by the transformer
          acc
          |> Map.put(attr, safe(Map.get(acc, attr), base))
          |> add_class(classes)
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
