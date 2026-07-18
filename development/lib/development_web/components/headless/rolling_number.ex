defmodule DevelopmentWeb.Components.Headless.RollingNumber do
  @moduledoc """
  Headless **rolling number** — animate a number to its value (Mantine RollingNumber parity).

  The `RollingNumber` engine rolls from 0 up to `value` on mount and animates to the new number
  whenever LiveView re-renders with a different `value` (requestAnimationFrame, ease-out). `duration`
  (ms) sets the speed, `locale` the thousands grouping; `prefers-reduced-motion` jumps straight to the
  value. The static `value` is rendered as fallback text for no-JS / screen readers.

  Ships **no** styling — style via `chelekom-rolling-number`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/rolling_number
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (carries the RollingNumber hook)"
  attr :value, :integer, required: true, doc: "The target number"
  attr :duration, :integer, default: 800, doc: "Animation duration in ms"
  attr :locale, :string, default: nil, doc: "BCP-47 locale for thousands grouping"
  attr :class, :any, default: nil, doc: "Extra classes"
  attr :rest, :global

  def rolling_number(assigns) do
    ~H"""
    <span
      id={@id}
      phx-hook="RollingNumber"
      data-part="root"
      data-value={@value}
      data-duration={@duration}
      data-locale={@locale}
      class={["chelekom-rolling-number", @class]}
      {@rest}
    >{@value}</span>
    """
  end
end
