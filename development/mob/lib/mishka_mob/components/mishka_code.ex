defmodule MishkaMob.Components.MishkaCode do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Code** — inline code and code
  blocks.

  Mob's `Text` takes a `font` prop that falls back to a system family name, so
  `"monospace"` gets the platform's real mono face (Roboto Mono / SF Mono) rather
  than an approximation.

  ## Inline and block are different components wearing one name

  The web component's `block` flag switches `<code>` for `<pre><code>`, and the
  two behave differently enough that the port keeps the distinction sharp:

    * **inline** — sits in a sentence, hugs its text, no scrolling.
    * **block** — fills the width, is padded, and **scrolls horizontally**,
      because code lines do not wrap and a long line would otherwise be
      unreadable with no way to see the rest of it.

  That horizontal scroller is the part worth having: it is the difference
  between a code block you can read and one that is quietly truncated.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `text` | string | `nil` | The code. |
  | `block` | boolean | `false` | Block rather than inline. |
  | `background` | color token / ARGB int | `:surface_raised` | Fill. |
  | `color` | color token / ARGB int | `:on_surface` | Code colour. |
  | `text_size` | size token | `:sm` | Code size. |
  | `padding` | spacing token / number | `:space_md` (block) / `4` (inline) | Padding. |
  | `scroll` | boolean | `true` for blocks | Scroll a block horizontally. |

  Not ported: `id` and the `*_class` attrs. Syntax highlighting is not part of
  the headless component and would need per-token spans, which Mob's `Text` does
  not expose.
  """

  import Mob.Sigil

  @doc "Composite expander (`<MishkaCode />`). Delegates to `code/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: code(props)

  @doc """
  The code node.

      code(text: "mix mob.deploy")
      code(text: "def render(assigns), do: ~MOB(<Text text=\\"hi\\" />)", block: true)
  """
  @spec code(map() | keyword()) :: map()
  def code(props \\ %{}) do
    props = Map.new(props)

    if truthy?(Map.get(props, :block, false)), do: block(props), else: inline(props)
  end

  defp inline(props) do
    text = Map.get(props, :text)
    size = Map.get(props, :text_size, :sm)
    color = Map.get(props, :color, :on_surface)
    fill = Map.get(props, :background, :surface_raised)
    pad = Map.get(props, :padding, 4)

    ~MOB"""
    <Box background={fill} corner_radius={:radius_sm} padding={pad}>
      <Text text={text} text_size={size} text_color={color} font="monospace" />
    </Box>
    """
  end

  # Code lines do not wrap, so a block scrolls horizontally rather than
  # truncating whatever runs past the edge.
  defp block(props) do
    text = Map.get(props, :text)
    size = Map.get(props, :text_size, :sm)
    color = Map.get(props, :color, :on_surface)
    fill = Map.get(props, :background, :surface_raised)
    pad = Map.get(props, :padding, :space_md)
    line = ~MOB(<Text text={text} text_size={size} text_color={color} font="monospace" />)

    body =
      if truthy?(Map.get(props, :scroll, true)) do
        ~MOB"""
        <Scroll axis="horizontal">
          {line}
        </Scroll>
        """
      else
        line
      end

    ~MOB"""
    <Box fill_width={true} background={fill} corner_radius={:radius_md} padding={pad}>
      {body}
    </Box>
    """
  end

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
