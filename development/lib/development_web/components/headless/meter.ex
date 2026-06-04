defmodule DevelopmentWeb.Components.Headless.Meter do
  @moduledoc """
  Headless **meter** — a scalar gauge for a measurement within a known range.

  A meter represents a known value within a defined range (e.g. disk usage,
  battery level), distinct from a `progress` bar which tracks task completion.
  This component ships **no** JavaScript: the root carries `role="meter"` with
  `aria-valuemin` / `aria-valuemax` / `aria-valuenow`, and the inner
  `data-part="indicator"` exposes the fill ratio via the `--chelekom-meter`
  CSS custom property so you can style the gauge however you like.

  Style via the `chelekom-meter*` classes — this component ships no colors or
  spacing.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/meter/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors aria relationships)"
  attr :value, :integer, required: true, doc: "Current value within [min, max]"
  attr :min, :integer, default: 0, doc: "Lower bound of the range"
  attr :max, :integer, default: 100, doc: "Upper bound of the range"
  attr :label, :string, default: nil, doc: "Accessible label (wired to aria-labelledby)"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  def meter(assigns) do
    assigns =
      assign(
        assigns,
        :ratio,
        if(assigns.max > assigns.min,
          do: (assigns.value - assigns.min) / (assigns.max - assigns.min),
          else: 0
        )
      )

    ~H"""
    <div
      id={@id}
      role="meter"
      aria-valuemin={@min}
      aria-valuemax={@max}
      aria-valuenow={@value}
      aria-labelledby={@label && "#{@id}-label"}
      class={["chelekom-meter", @class]}
      {@rest}
    >
      <span :if={@label} id={"#{@id}-label"} data-part="label" class="chelekom-meter__label">
        {@label}
      </span>
      <div data-part="track" class="chelekom-meter__track">
        <div
          data-part="indicator"
          class="chelekom-meter__indicator"
          style={"--chelekom-meter: #{@ratio};"}
        >
        </div>
      </div>
    </div>
    """
  end
end
