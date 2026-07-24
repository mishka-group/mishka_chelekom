defmodule MishkaMob.Components.MishkaFieldset do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Fieldset** — a group of
  related controls under a legend.

  `<fieldset disabled>` in a browser disables every control inside it, for free.
  There is no such cascade here: a Mob node tree has no ownership relationship
  that would let a parent switch off its descendants, and rewriting arbitrary
  children to inject `disabled: true` would silently mangle nodes it does not
  understand. So `disabled` here **dims the group and marks the legend**, and the
  moduledoc is explicit that the controls must be disabled by the caller. A prop
  that looked like it disabled a form but did not would be worse than none.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `legend` | string | `nil` | The group's heading. |
  | `disabled` | boolean | `false` | Mutes the legend. Does NOT cascade — see above. |
  | `space` | number | `14` | Gap between the legend and the controls. |
  | `background` | color token / ARGB int | `nil` | Optional group fill. |
  | `padding` | spacing token / number | `nil` | Optional padding. |
  | `corner_radius` | radius token / number | `nil` | Optional rounding. |

  Not ported: `id` and the `*_class` attrs.
  """

  import Mob.Sigil

  @doc "Composite expander (`<MishkaFieldset>`). Children are the controls."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: fieldset(props, children)

  @doc """
  The fieldset node.

      {fieldset([legend: "Billing address"], [line1(), city(), postcode()])}
  """
  @spec fieldset(map() | keyword(), [map()]) :: map()
  def fieldset(props \\ %{}, children \\ []) do
    props = Map.new(props)
    legend = Map.get(props, :legend)
    disabled? = truthy?(Map.get(props, :disabled, false))
    color = if disabled?, do: :muted, else: :on_surface
    space = Map.get(props, :space, 14)

    group = ~MOB"""
    <Column fill_width={true}>
      <Text text={legend} text_size={:base} text_color={color} :if={is_binary(legend)} />
      <Spacer size={space} :if={is_binary(legend)} />
      <Column fill_width={true}>
        {children}
      </Column>
    </Column>
    """

    wrap(group, props)
  end

  defp wrap(group, props) do
    box =
      %{fill_width: true}
      |> maybe(:background, Map.get(props, :background))
      |> maybe(:padding, Map.get(props, :padding))
      |> maybe(:corner_radius, Map.get(props, :corner_radius))

    if map_size(box) == 1, do: group, else: %{type: :box, props: box, children: [group]}
  end

  defp maybe(map, _key, nil), do: map
  defp maybe(map, key, value), do: Map.put(map, key, value)

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
