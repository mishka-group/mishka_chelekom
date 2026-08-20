defmodule MishkaMob.Components.MishkaPill do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Pill** — a compact label with
  an optional trailing remove button (a token, a tag, a filter you can dismiss).

  ## Pill or Chip?

  They look alike and are easy to confuse, so the port keeps them distinct in the
  way that matters: a **Chip is selected**, a **Pill is removed**. A chip carries
  `checked` and toggles; a pill carries content and offers a ✕. If you find
  yourself giving a pill a checked state, you want
  `MishkaMob.Components.MishkaChip`.

  ## The remove button is its own tap target

  `with_remove` renders a ✕ that carries its own handler, so tapping the label
  and tapping the ✕ are different events — the pill itself can stay inert while
  only its ✕ responds, which is the usual behaviour for a token in an input.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `label` | string | `nil` | The pill's text. Children override it. |
  | `with_remove` | boolean | `false` | Render the trailing ✕. |
  | `on_remove` | event tag (atom) | — | Sent as `{:tap, tag}` when the ✕ is tapped. |
  | `on_tap` | event tag (atom) | — | Makes the pill body itself tappable. |
  | `disabled` | boolean | `false` | Mutes it and wires no handlers, including the ✕. |
  | `background` | color token / ARGB int | `:surface_raised` | Pill fill. |
  | `color` | color token / ARGB int | `:on_surface` | Label colour. |
  | `disabled_color` | color token / ARGB int | `:muted` | Label colour while disabled. |
  | `corner_radius` | radius token / number | `:radius_pill` | Corner rounding. |
  | `padding` | spacing token / number | `:space_sm` | Inside the pill, all four sides. |
  | `padding_top` / `padding_right` / `padding_bottom` / `padding_left` | spacing token / number | unset | One edge, overriding `padding` on that side only. |
  | `width` | number | unset | Exact width. Unset, the pill hugs its label. |
  | `height` | number | unset | Exact height. Unset, the pill hugs its label. |
  | `fill_width` | boolean | `false` | Span the parent instead of hugging. |
  | `align` | `:center`, `:leading`, `:trailing`, … | unset (top-leading) | Where the content sits when `width` / `height` leave it room. |
  | `border_color` | color token / ARGB int | unset | Outline colour. Draws only alongside `border_width`. |
  | `border_width` | number | unset (no outline) | Outline width. |
  | `shadow` | shadow spec string | unset | Passed straight through to the root Box — see "Shadows" below. |
  | `text_size` | text token / number | `:base` | Label size. |
  | `font_weight` | `:regular`, `:medium`, `:semibold`, `:bold`, `:light`, `:thin` | unset (regular) | Label weight — and the ✕'s. |
  | `letter_spacing` | number (sp) | unset | Tracking on the label. |
  | `line_height` | number | unset | Multiplier of `text_size`; ignored without one. |
  | `remove_gap` | number | `8` | Space between the label and the ✕. |
  | `remove_size` | text token / number | whatever `text_size` is | The ✕'s size, when it should differ from the label's. |

  Every prop below `disabled_color` is a later addition and every one of them
  defaults to exactly what the pill drew before it existed: the ones with a
  token default (`corner_radius`, `padding`, `text_size`, `remove_gap`) name the
  value that used to be hardcoded, and the ones marked *unset* are **left off
  the node entirely** rather than passed as `nil` — not the same thing once the
  tree is serialised, as the note beside the private `overrides` explains.

  Not ported: `remove_label` (an `aria-label` for the ✕ — Mob exposes no
  accessible name on a text node) and the `id` / `*_class` attrs.

  ## Sizing: padding is applied BEFORE width and height

  The bridge builds the node's modifier chain padding-first, so `width` and
  `height` measure the box *inside* the padding: `height: 30, padding: 8` is 46
  tall on screen, not 30. Pin the outer dimension by pairing the two —
  `height: 14, padding: 8` — or drop the padding on the axis you are pinning.

  A number is required; `width`/`height` are not spacing props, so a token like
  `:space_md` reaches the bridge unresolved and is ignored. Negative padding
  throws on the native side, so never compute one.

  ## Text size takes a number, and a number skips the type scale

  `text_size` (and `remove_size`) accept a token — `:sm`, `:base` — or a raw
  number in sp, which is what a design pinned to 11.5 needs. Only the token form
  is multiplied by the theme's `type_scale`, so a numeric size stays put when the
  user scales their type. That is the trade: exactness against accessibility.

  ## Shadows

  `shadow` is not interpreted here — it rides on the root Box for the bridge to
  read, in CSS `box-shadow` order (`"dx dy blur spread #AARRGGBB"`, further
  layers after a pipe). A bridge without shadow support ignores the prop, as it
  ignores any key it does not know, so passing one is never a rendering risk.

  ## It hugs its label

  The root Box passes `fill_width={false}` by default, so a pill is exactly as
  wide as its text plus padding. That is what lets several sit in one Row the way
  they do on the web. It matters because a Box with neither `width` nor
  `fill_width` fills its parent, which made every pill a full-width bar. Pass
  `fill_width={true}` for a pill that really should span its container.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  # Root-Box props that must be ABSENT when the caller says nothing, rather than
  # present-and-nil. See `overrides/2` for why the difference is visible.
  @box_overrides ~w(
    width height align shadow border_color border_width
    padding_top padding_right padding_bottom padding_left
  )a

  # Typography, absent for the same reason. `letter_spacing` and `line_height`
  # have no safe neutral value at all — Compose resolves an unset one from the
  # ambient text style, and Material's body style is not 0 / 1.0, so writing
  # those "neutral" numbers would visibly retrack and re-lead every existing
  # pill. `font_weight` does have one (`:regular`), and is still left off, so
  # that a pill nobody restyled builds the map it always built, key for key.
  @text_overrides ~w(font_weight letter_spacing line_height)a

  # The ✕ follows the label's weight but not its tracking: letter-spacing is
  # applied after every character including the last, which on a lone glyph is
  # just a gap between it and the pill's edge.
  @glyph_overrides ~w(font_weight)a

  @doc """
  Composite expander (`<MishkaPill>`). Children replace the `label` prop.
  """
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: pill(props, children)

  @doc """
  The pill node. `content` overrides the `label` prop when given.

      pill(label: "elixir", with_remove: true, on_remove: {:drop, :elixir})

  Sized to a design rather than to its text — this one is 30pt tall, because
  padding is applied before height and 9 + 12 + 9 is what the bridge measures:

      pill(label: "PRO", height: 12, padding_top: 9, padding_bottom: 9,
           padding_left: 12, padding_right: 12, text_size: 11.5,
           font_weight: :semibold, align: :center)
  """
  @spec pill(map() | keyword(), [map()]) :: map()
  def pill(props \\ %{}, content \\ []) do
    props = Map.new(props)
    disabled? = truthy?(Map.get(props, :disabled, false))

    node = ~MOB"""
    <Box
      background={Map.get(props, :background, :surface_raised)}
      corner_radius={Map.get(props, :corner_radius, :radius_pill)}
      padding={Map.get(props, :padding, :space_sm)}
      fill_width={truthy?(Map.get(props, :fill_width, false))}
    >
      <Row>
        {label(props, content, disabled?)}
        {remove(props, disabled?)}
      </Row>
    </Box>
    """

    node
    |> merge_props(overrides(props, @box_overrides))
    |> wire(tap(props, disabled?, :on_tap))
  end

  # max_lines: 1 — a pill is a single-line token by nature, and the failure mode
  # without it is ugly rather than merely tight: a Compose Text squeezed narrower
  # than its content wraps CHARACTER BY CHARACTER, so a pill that does not quite
  # fit its row renders as a vertical stack of letters. Ellipsised is wrong by a
  # little; stacked letters look broken. It stays fixed for that reason — the
  # dimension props above change the pill's shape, never its line count.
  defp label(props, [], disabled?) do
    ~MOB"""
    <Text
      text={Map.get(props, :label)}
      text_size={text_size(props)}
      text_color={color(props, disabled?)}
      max_lines={1}
    />
    """
    |> merge_props(overrides(props, @text_overrides))
  end

  defp label(_props, content, _disabled?), do: ~MOB(<Row>
  {content}
</Row>)

  # The ✕ is a separate tap target from the pill body, so a token can be
  # removable without the whole pill being tappable.
  #
  # It follows the label's size and weight unless `remove_size` says otherwise:
  # a semibold 11.5sp pill with a regular 16sp ✕ reads as a mistake, and the
  # fallback chain keeps the unstyled pill at the `:base` it always drew.
  defp remove(props, disabled?) do
    if truthy?(Map.get(props, :with_remove, false)) do
      node = ~MOB"""
      <Row>
        <Spacer size={Map.get(props, :remove_gap, 8)} />
        {glyph(props, disabled?)}
      </Row>
      """

      wire(node, tap(props, disabled?, :on_remove))
    else
      ~MOB(<Row />)
    end
  end

  defp glyph(props, disabled?) do
    ~MOB"""
    <Text
      text="✕"
      text_size={Map.get(props, :remove_size, text_size(props))}
      text_color={color(props, disabled?)}
    />
    """
    |> merge_props(overrides(props, @glyph_overrides))
  end

  defp text_size(props), do: Map.get(props, :text_size, :base)

  defp color(props, true), do: Map.get(props, :disabled_color, :muted)
  defp color(props, _), do: Map.get(props, :color, :on_surface)

  defp tap(_props, true, _key), do: nil
  defp tap(props, _disabled, key), do: Event.handler(Map.get(props, key))

  defp wire(node, nil), do: node
  defp wire(node, handler), do: %{node | props: Map.put(node.props, :on_tap, handler)}

  # A prop the caller never set must be ABSENT from the node, not present as
  # `nil`. The tree is serialised with `:json.encode/1`, which renders the atom
  # `nil` as the STRING "nil" — so a defaulted `height: nil` would reach the
  # bridge as `"height":"nil"`, and a bridge that coerces with -doubleValue
  # reads that as 0.0 and collapses the pill. Taking only the keys the caller
  # supplied is also what makes an untouched pill's props map identical, key for
  # key, to the one it built before any of these props existed.
  defp overrides(props, keys) do
    props
    |> Map.take(keys)
    |> Map.reject(fn {_key, value} -> is_nil(value) end)
  end

  defp merge_props(node, extra) when map_size(extra) == 0, do: node
  defp merge_props(node, extra), do: %{node | props: Map.merge(node.props, extra)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
