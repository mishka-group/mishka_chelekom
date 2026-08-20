defmodule MishkaMob.Components.MishkaActionIcon do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Action Icon** — a compact
  icon-only button (the ✕ on a card, the ⋯ on a row, the ← in a header).

  A square tap target holding a glyph or nodes. `MishkaMob.Components.MishkaCloseButton`
  is this component with a fixed ✕ and a `:radius_pill` shape, which is why it
  is a wrapper rather than a copy.

  ## Tap targets stay finger-sized

  `size` defaults to **40**, not to the glyph's own size. An icon button drawn to
  fit its glyph is a ~16 dp target, well under the ~44 dp both platforms'
  guidelines ask for, and it is the single most common way icon buttons end up
  frustrating on a phone. Shrink it deliberately if a design needs it; the
  default will not do it for you.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `icon` | string | `nil` | The glyph. Children override it. |
  | `on_tap` | event tag (atom) | — | Sent as `{:tap, tag}`. |
  | `disabled` | boolean | `false` | Wires no handler, mutes the glyph and drops a `:filled` fill to `:surface`. |
  | `size` | number | `40` | Tap-target edge, not the glyph size. |
  | `variant` | `:plain` `:filled` | `:plain` | Transparent, or on a raised surface. |
  | `shape` | `:rounded` `:circle` | `:rounded` | `:circle` uses an exact `size / 2` radius. |
  | `color` | color token / ARGB int | `:on_surface` | Glyph colour. |
  | `background` | color token / ARGB int | `:surface_raised` | Fill when `variant: :filled`. |
  | `shadow` | string | `nil` | Drop shadow on the tap target. See below. |
  | `border_color` | color token / ARGB int | `nil` | Hairline colour. Nothing draws unless you set it. |
  | `border_width` | number (dp) | `1` | Read only when `border_color` is set. |

  `label` is not ported: it is an `aria-label`, and Mob exposes no accessible
  name on a box. `type` (submit/reset) is form plumbing.

  ## A floating disc is defined by its shadow

  `variant: :filled` paints a fill and stops there, which reads as a flat patch
  rather than as a button sitting above the page. The shadow is the whole
  difference, and it is the caller's to choose — so `shadow` is a string handed
  to the container untouched, in CSS `box-shadow` order and units of dp:

      shadow: "0 1 2 0 #0D1A1917"

  `dx dy blur spread #AARRGGBB`. Stack layers by separating them with a
  vertical bar, ambient first, key light second, exactly as CSS does:

      shadow: "0 1 2 0 #0D1A1917 | 0 8 16 -12 #801A1917"

  Omit it and the node carries no `shadow` key at all — not a null one — so
  nothing about an existing icon changes.

  `disabled` does not touch it. It mutes the glyph and drops a `:filled` fill
  because it has no other way to say "inert", but a shadow it was handed is a
  deliberate choice, and quietly withdrawing a prop the caller passed is the
  behaviour this component exists to avoid. Pass the flatter shadow yourself
  when the disabled state should sit lower.

  ## Borders

  A hairline is `border_color` plus `border_width`; `border_width` alone draws
  nothing, because the renderer needs both (it honours a border on a box only
  when the colour is set and the width is non-zero). The default is no border,
  which is what this component has always drawn.

  ## Children carry their own disabled state

  `disabled` recolours the glyph it draws itself. It cannot recolour nodes you
  pass as children — Mob has no opacity or alpha anywhere in its renderer, so
  there is nothing to dim them with and rewriting arbitrary nodes is not this
  component's business. The container still reads as disabled (the fill drops to
  `:surface`, and no handler is wired), but a child that must look inert has to
  say so itself.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaActionIcon>`). Children override the glyph."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: action_icon(props, children)

  @doc """
  The action-icon node.

      action_icon(icon: "⋯", on_tap: :menu)
      action_icon(icon: "←", variant: :filled, shape: :circle, on_tap: :back)

      action_icon(
        icon: "→",
        variant: :filled,
        shape: :circle,
        shadow: "0 1 2 0 #0D1A1917 | 0 8 16 -12 #801A1917",
        on_tap: :next
      )
  """
  @spec action_icon(map() | keyword(), [map()]) :: map()
  def action_icon(props \\ %{}, content \\ []) do
    props = Map.new(props)
    disabled? = truthy?(Map.get(props, :disabled, false))
    size = Map.get(props, :size, 40)

    node = ~MOB"""
    <Box
      width={size}
      height={size}
      align={:center}
      corner_radius={radius(Map.get(props, :shape, :rounded), size)}
      background={background(props, disabled?)}
    >
      {glyph(props, content, disabled?)}
    </Box>
    """

    %{node | props: Map.merge(node.props, container(props, disabled?))}
  end

  @doc """
  The corner radius for a shape — a circle is `size / 2` so it stays round at
  any size.

      iex> MishkaMob.Components.MishkaActionIcon.radius(:circle, 40)
      20.0
      iex> MishkaMob.Components.MishkaActionIcon.radius(:rounded, 40)
      :radius_md
  """
  @spec radius(atom(), number()) :: number() | atom()
  def radius(:circle, size), do: size / 2
  def radius(_rounded, _size), do: :radius_md

  # Locals, not inline Map.get/3: inside the parenthesised ~MOB(...) form the
  # first `)` closes the sigil, so a call with arguments cannot be interpolated
  # there.
  defp glyph(props, [], disabled?) do
    color = if disabled?, do: :muted, else: Map.get(props, :color, :on_surface)
    icon = Map.get(props, :icon)

    ~MOB"""
    <Text text={icon} text_size={:lg} text_color={color} />
    """
  end

  defp glyph(_props, content, _disabled?), do: ~MOB(<Row>
  {content}
</Row>)

  # A disabled FILLED icon keeps a fill, but not the caller's — muting only the
  # glyph left it looking live, and the caller's colour is usually the loud one.
  # MishkaChip resolves its background the same way.
  defp background(props, disabled?) do
    cond do
      Map.get(props, :variant, :plain) != :filled -> :transparent
      disabled? -> :surface
      true -> Map.get(props, :background, :surface_raised)
    end
  end

  # Container props that are absent unless the caller asks for them, merged onto
  # the sigil's node rather than written inside it: an attribute interpolating
  # `nil` still lands in the map, and the renderer serialises it as a JSON
  # `null` the native side then has to interpret. A key that was never put is
  # simply not there. `on_tap` has always been merged this way; the rest join it.
  defp container(props, disabled?) do
    border_color = Map.get(props, :border_color)

    %{}
    |> put_some(:on_tap, handler(props, disabled?))
    |> put_some(:shadow, Map.get(props, :shadow))
    |> put_some(:border_color, border_color)
    |> put_some(:border_width, border_color && Map.get(props, :border_width, 1))
  end

  defp put_some(map, _key, nil), do: map
  defp put_some(map, key, value), do: Map.put(map, key, value)

  defp handler(_props, true), do: nil
  defp handler(props, _), do: Event.handler(Map.get(props, :on_tap))

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
