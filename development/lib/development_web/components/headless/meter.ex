defmodule DevelopmentWeb.Components.Headless.Meter do
  @moduledoc """
  Headless **meter** — a scalar gauge for a measurement within a known range.

  A meter represents a known value within a defined range (e.g. disk usage,
  battery level), distinct from a `progress` bar which tracks task completion.
  This component ships **no** JavaScript: the root carries `role="meter"` with
  `aria-valuemin` / `aria-valuemax` / `aria-valuenow` (clamped into the range) and
  `aria-valuetext` (a human-readable readout), and the inner `data-part="indicator"`
  exposes the fill ratio via the `--chelekom-meter` CSS custom property so you can
  style the gauge however you like. Pass `show_value` to render a `data-part="value"`
  text readout (e.g. "72%"); override the text with `value_text`.

  Style via the `chelekom-meter*` classes — this component ships no colors or
  spacing.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/meter/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors aria relationships)"
  attr :value, :integer, required: true, doc: "Current value (clamped into [min, max])"
  attr :min, :integer, default: 0, doc: "Lower bound of the range"
  attr :max, :integer, default: 100, doc: "Upper bound of the range"
  attr :label, :string, default: nil, doc: "Accessible label (wired to aria-labelledby)"

  attr :value_text, :string,
    default: nil,
    doc:
      ~s|Human-readable value for `aria-valuetext` + the readout (defaults to a percent, e.g. "72%")|

  attr :show_value, :boolean, default: false, doc: ~s|Render a `data-part="value"` text readout|
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :label_class, :any, default: nil, doc: ~s|Extra classes for the `data-part="label"`|
  attr :value_class, :any, default: nil, doc: ~s|Extra classes for the `data-part="value"`|
  attr :track_class, :any, default: nil, doc: ~s|Extra classes for the `data-part="track"`|

  attr :indicator_class, :any,
    default: nil,
    doc: ~s|Extra classes for the `data-part="indicator"`|

  attr :rest, :global

  def meter(assigns) do
    lo = assigns.min
    hi = assigns.max
    # clamp the value into the range so the fill never overflows and aria-valuenow stays valid
    clamped = assigns.value |> Kernel.max(lo) |> Kernel.min(hi)
    ratio = if hi > lo, do: (clamped - lo) / (hi - lo), else: 0.0

    assigns =
      assigns
      |> assign(:value, clamped)
      |> assign(:ratio, ratio)
      |> assign(:value_text, assigns.value_text || "#{round(ratio * 100)}%")

    ~H"""
    <div
      id={@id}
      role="meter"
      aria-valuemin={@min}
      aria-valuemax={@max}
      aria-valuenow={@value}
      aria-valuetext={@value_text}
      aria-labelledby={@label && "#{@id}-label"}
      class={["chelekom-meter", @class]}
      {@rest}
    >
      <span
        :if={@label}
        id={"#{@id}-label"}
        data-part="label"
        class={["chelekom-meter__label", @label_class]}
      >
        {@label}
      </span>
      <span
        :if={@show_value}
        data-part="value"
        class={["chelekom-meter__value", @value_class]}
      >{@value_text}</span>
      <div data-part="track" class={["chelekom-meter__track", @track_class]}>
        <div
          data-part="indicator"
          class={["chelekom-meter__indicator", @indicator_class]}
          style={"--chelekom-meter: #{@ratio}; width: calc(var(--chelekom-meter) * 100%); height: 100%;"}
        >
        </div>
      </div>
    </div>
    """
  end
end
