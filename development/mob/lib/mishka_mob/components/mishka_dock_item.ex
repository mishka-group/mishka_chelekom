defmodule MishkaMob.Components.MishkaDockItem do
  @moduledoc """
  One item in a `MishkaDock`: an icon centred in a well, sharing the bar's
  width equally.

  The item is `weight: 1.0` by default, so four items become four equal
  segments without arithmetic at the call site. The active look is entirely
  props: the well's fill and the glyph's colour and family. A dock that
  highlights the current tab passes `active_background`, `active_color` and,
  when the icon set has a filled variant, `active_font_family`; the inactive
  look is the same three props without the prefix.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `icon` | string | `nil` | The glyph. Children override it. |
  | `on_tap` | event tag | — | Sent as `{:tap, tag}`. |
  | `active` | boolean | `false` | Chooses the active or inactive look. |
  | `well_size` | number | `46` | The disc's width and height. |
  | `well_radius` | number | `well_size / 2` | Disc corners. |
  | `background` / `active_background` | color token / ARGB int | `:transparent` | Disc fill. |
  | `color` / `active_color` | color token / ARGB int | `:on_surface` | Glyph ink. |
  | `font_family` / `active_font_family` | string | unset | The icon font; separate families allow a filled active glyph. |
  | `icon_size` | number | `22` | Glyph size. |
  | `weight` | number | `1.0` | Share of the dock's row. |
  | `id` | string | unset | Native testTag on the item. |

  **Documentation:** https://mishka.tools/chelekom/docs/mob/dock
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaDockItem>`). Children override the glyph."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: dock_item(props, children)

  @doc """
  The item node.

      dock_item(icon: "home", active: true, on_tap: :home,
                active_background: 0xFFEFECE7, active_color: 0xFF1A1917)
  """
  @spec dock_item(map() | keyword(), [map()]) :: map()
  def dock_item(props \\ %{}, content \\ []) do
    props = Map.new(props)
    active? = truthy?(Map.get(props, :active, false))
    size = Map.get(props, :well_size) || 46
    radius = Map.get(props, :well_radius) || size / 2

    assigns = %{
      size: size,
      radius: radius,
      background: look(props, active?, :background),
      glyph: glyph(props, content, active?)
    }

    ~MOB"""
    <Box weight={1.0} align={:center}>
      <Box width={@size} height={@size} background={@background} corner_radius={@radius} align={:center}>
        {@glyph}
      </Box>
    </Box>
    """
    |> merge_props(item_props(props))
  end

  defp item_props(props) do
    %{}
    |> put_some(:weight, Map.get(props, :weight) || 1.0)
    |> put_some(:on_tap, Event.handler(Map.get(props, :on_tap)))
    |> put_some(:id, Map.get(props, :id))
  end

  defp look(props, true, :background), do: Map.get(props, :active_background) || :transparent
  defp look(props, false, :background), do: Map.get(props, :background) || :transparent

  defp look(props, true, :color), do: Map.get(props, :active_color) || :on_surface
  defp look(props, false, :color), do: Map.get(props, :color) || :on_surface

  defp look(props, true, :family),
    do: Map.get(props, :active_font_family) || Map.get(props, :font_family)

  defp look(props, false, :family), do: Map.get(props, :font_family)

  defp glyph(_props, content, _active?) when content != [] do
    assigns = %{content: content}

    ~MOB"""
    <Row>
      {@content}
    </Row>
    """
  end

  defp glyph(props, [], active?) do
    assigns = %{
      text: Map.get(props, :icon) || "",
      family: look(props, active?, :family),
      size: Map.get(props, :icon_size) || 22,
      color: look(props, active?, :color)
    }

    ~MOB"""
    <Text text={@text} font_family={@family} text_size={@size} text_color={@color} max_lines={1} />
    """
    |> drop_nil_family()
  end

  defp drop_nil_family(%{props: %{font_family: nil}} = node),
    do: %{node | props: Map.delete(node.props, :font_family)}

  defp drop_nil_family(node), do: node

  defp merge_props(node, extra) when map_size(extra) == 0, do: node
  defp merge_props(node, extra), do: %{node | props: Map.merge(node.props, extra)}

  defp put_some(map, _key, nil), do: map
  defp put_some(map, key, value), do: Map.put(map, key, value)

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
