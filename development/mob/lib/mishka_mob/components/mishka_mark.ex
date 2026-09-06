defmodule MishkaMob.Components.MishkaMark do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Mark** — highlighted text, the
  native equivalent of `<mark>`.

  A `Text` node cannot carry a background of its own, so a mark is a `Text`
  inside a tinted `Box`. That is the whole component; it exists as its own module
  because `MishkaMob.Components.MishkaHighlight` builds on it, and because a
  highlight colour that agrees across the app is worth having in one place.

  ## It is as wide as its text

  The Box passes `fill_width={false}`, without which it fills its parent and the
  mark becomes a full-width bar rather than a highlighted word — which is the
  opposite of what `<mark>` means. A Box given neither `width` nor `fill_width`
  fills, so this is not optional.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `text` | string | `nil` | The text to highlight. |
  | `background` | color token / ARGB int | `0xFFFDE68A` (amber) | Highlight fill. |
  | `color` | color token / ARGB int | `0xFF111827` | Text colour — dark, so it stays legible on a light highlight in either theme. |
  | `text_size` | size token | `:base` | Text size. |

  The colours default to explicit ARGB rather than theme tokens on purpose: a
  highlight has to stay readable against *itself*, so pairing a light fill with
  dark text is more reliable than a `:surface` / `:on_surface` pair that flips
  with the theme and can end up light-on-light.
  """

  import Mob.Sigil

  @fill 0xFF_FD_E6_8A
  @ink 0xFF_11_18_27

  @doc "Composite expander (`<MishkaMark />`). Delegates to `mark/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: mark(props)

  @doc """
  The mark node.

      mark(text: "BEAM")
      mark(text: "BEAM", background: 0xFFBBF7D0)
  """
  @spec mark(map() | keyword()) :: map()
  def mark(props \\ %{}) do
    props = Map.new(props)

    # Bound to locals first: inside a ~MOB expression `@foo` is rewritten to
    # `assigns.foo` (the HEEx shorthand), so a module attribute cannot be read
    # there — it compiles to a reference to a non-existent `assigns`.
    fill = Map.get(props, :background) || @fill
    ink = Map.get(props, :color) || @ink
    size = Map.get(props, :text_size) || :base
    # A missing label must render as nothing, not as the word "nil": an
    # interpolated nil still lands in the props map, and `:json` encodes an
    # atom as a string, so the wire carries "text":"nil" and the widget
    # draws it.
    text = Map.get(props, :text) || ""

    ~MOB"""
    <Box background={fill} corner_radius={:radius_sm} padding={2} fill_width={false}>
      <Text text={text} text_size={size} text_color={ink} />
    </Box>
    """
  end

  @doc "The default highlight fill, so other components can match it."
  @spec default_fill() :: integer()
  def default_fill, do: @fill

  @doc "The default highlight ink."
  @spec default_ink() :: integer()
  def default_ink, do: @ink
end
