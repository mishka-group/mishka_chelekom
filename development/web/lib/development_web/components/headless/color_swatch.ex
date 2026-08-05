defmodule DevelopmentWeb.Components.Headless.ColorSwatch do
  @moduledoc """
  Headless **color swatch** — display a single color (Mantine ColorSwatch parity).

  Renders a `<span role="img">` whose background is the given `color` (any CSS color).
  It is labelled for assistive tech (`aria-label`, defaulting to the color) and can hold
  overlay content (e.g. a ✓) in the default slot. Size, shape and border are yours.
  The value lands in an inline `style` — only pass trusted (developer-chosen) colors;
  raw user input could smuggle extra CSS declarations in.

  Ships **no** sizing or shape — style via `chelekom-color-swatch`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/color_swatch
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional unique id"
  attr :color, :string, required: true, doc: "Any CSS color for the swatch background"
  attr :label, :string, default: nil, doc: "aria-label (defaults to the color value)"
  attr :class, :any, default: nil, doc: "Extra classes for the swatch"
  attr :rest, :global

  slot :inner_block, doc: "Optional overlay content (e.g. a check icon)"

  def color_swatch(assigns) do
    ~H"""
    <span
      id={@id}
      role="img"
      aria-label={@label || @color}
      style={"background-color: #{@color}"}
      class={["chelekom-color-swatch", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end
end
