defmodule MishkaMob.Components.MishkaDock do
  @moduledoc """
  A headless bottom dock: one floating bar holding the icon items, with an
  optional action node beside it.

  `MishkaDockItem` draws an item — an icon centred in a well, tappable, with
  the active colours passed in. The dock owns the bar: its fill, corners,
  height, shadow and the padding that lifts it off the screen edge.

  The component is a `Row`, not a fixed overlay. A screen that wants the bar
  pinned to the bottom wraps it in a full-size `Box align="bottom"` itself;
  a screen that places it inline gets exactly what it asked for.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `background` | color token / ARGB int | `:surface_raised` | Bar fill. |
  | `height` | number | `64` | Bar height. |
  | `corner_radius` | radius token / number | `:radius_pill` | Bar corners. |
  | `shadow` | shadow spec string | unset | Drop shadow on the bar. |
  | `padding` | spacing token / number | unset | Around the bar row. |
  | `padding_top` / `padding_right` / `padding_bottom` / `padding_left` | spacing token / number | unset | One edge. |
  | `fab` | node | unset | Drawn after the bar, in the same row — the action disc beside it. |
  | `fill_width` | boolean | `true` | Span the parent. |
  | `id` | string | unset | Native testTag on the bar. |

  Children are the items, placed in a fill-width row inside the bar.

  **Documentation:** https://mishka.tools/chelekom/docs/mob/dock
  """

  import Mob.Sigil

  @doc "Composite expander (`<MishkaDock>`). Children are the items."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: dock(props, children)

  @doc """
  The dock node.

      dock(%{background: 0xFFFBFAF8, padding_left: 18, padding_right: 18,
             padding_bottom: 30, fab: fab_node}, items)
  """
  @spec dock(map() | keyword(), [map()]) :: map()
  def dock(props \\ %{}, items \\ []) do
    props = Map.new(props)

    assigns = %{
      items: items,
      fab: Map.get(props, :fab),
      height: Map.get(props, :height) || 64,
      radius: Map.get(props, :corner_radius) || :radius_pill
    }

    bar =
      ~MOB"""
      <Box weight={1.0} height={@height} corner_radius={@radius} align={:center}>
        <Row fill_width={true} fill_height={true} align={:center}>
          {@items}
        </Row>
      </Box>
      """
      |> merge_props(bar_props(props))

    assigns = Map.put(assigns, :bar, bar)

    ~MOB"""
    <Row fill_width={true} align={:center}>
      {@bar}
      {@fab}
    </Row>
    """
    |> merge_props(row_props(props))
  end

  defp row_props(props) do
    %{}
    |> put_some(:fill_width, Map.get(props, :fill_width, true))
    |> put_some(:padding, Map.get(props, :padding))
    |> put_some(:padding_top, Map.get(props, :padding_top))
    |> put_some(:padding_right, Map.get(props, :padding_right))
    |> put_some(:padding_bottom, Map.get(props, :padding_bottom))
    |> put_some(:padding_left, Map.get(props, :padding_left))
  end

  # Only the props the caller actually set reach the bar; an unset shadow is
  # absent from the node rather than an explicit nil.
  defp bar_props(props) do
    %{}
    |> put_some(:background, Map.get(props, :background))
    |> put_some(:shadow, Map.get(props, :shadow))
    |> put_some(:border_color, Map.get(props, :border_color))
    |> put_some(:border_width, Map.get(props, :border_width))
    |> put_some(:id, Map.get(props, :id))
  end

  defp merge_props(node, extra) when map_size(extra) == 0, do: node
  defp merge_props(node, extra), do: %{node | props: Map.merge(node.props, extra)}

  defp put_some(map, _key, nil), do: map
  defp put_some(map, key, value), do: Map.put(map, key, value)
end
