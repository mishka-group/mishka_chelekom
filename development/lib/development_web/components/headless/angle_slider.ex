defmodule DevelopmentWeb.Components.Headless.AngleSlider do
  @moduledoc """
  Headless **angle slider** — a circular control for choosing an angle from 0–360° (Mantine
  AngleSlider parity).

  0° points up and the value increases clockwise. The `AngleSlider` JS hook handles pointer drag and
  arrow-key nudging, rotates the `thumb-layer` so the handle sits on the circle, and exposes an
  `--angle` custom property you can feed to a `conic-gradient` fill. Give it a `name` to submit the
  value with a form, and/or an `on_change` event name to receive it on the server (pushed on release
  and on each key change).

  Ships **no** styling — style via `chelekom-angle-slider` and its parts.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/angle_slider
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (carries the AngleSlider hook)"
  attr :value, :integer, default: 0, doc: "Current angle in degrees (0–360)"
  attr :step, :integer, default: 1, doc: "Degrees to snap/nudge by"
  attr :name, :string, default: nil, doc: "Form field name (renders a hidden input)"
  attr :on_change, :string, default: nil, doc: "Event pushed with %{value: deg} on change"
  attr :disabled, :boolean, default: false, doc: "Disable interaction"
  attr :show_value, :boolean, default: true, doc: "Render a centered degree label"
  attr :label, :string, default: "Angle", doc: "Accessible label"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :thumb_class, :any, default: nil, doc: "Extra classes for the thumb"
  attr :rest, :global

  def angle_slider(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="AngleSlider"
      role="slider"
      tabindex={(@disabled && "-1") || "0"}
      aria-valuemin="0"
      aria-valuemax="360"
      aria-valuenow={@value}
      aria-label={@label}
      data-value={@value}
      data-step={@step}
      data-disabled={@disabled}
      data-on-change={@on_change}
      class={["chelekom-angle-slider", @class]}
      {@rest}
    >
      <span data-part="thumb-layer" class="chelekom-angle-slider__thumb-layer">
        <span data-part="thumb" class={["chelekom-angle-slider__thumb", @thumb_class]}></span>
      </span>
      <span :if={@show_value} data-part="value" class="chelekom-angle-slider__value">{@value}°</span>
      <input :if={@name} data-part="input" type="hidden" name={@name} value={@value} />
    </div>
    """
  end
end
