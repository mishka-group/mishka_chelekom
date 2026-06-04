defmodule DevelopmentWeb.Components.Headless.OtpField do
  @moduledoc """
  Headless **OTP field** — a one-time-code input of single-character boxes.

  Behavior via the shared `Otp` engine: typing auto-advances, Backspace moves back, arrows
  navigate, and pasting a code distributes it across the boxes. The combined value is mirrored
  to a hidden input for form submission, and a `chelekom:complete` DOM event fires when full.
  Style the `chelekom-otp_field*` classes — this component ships no styling.
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true
  attr :name, :string, default: nil, doc: "Name for the hidden form input carrying the code"
  attr :length, :integer, default: 6, doc: "Number of digit boxes"
  attr :class, :any, default: nil
  attr :rest, :global

  def otp_field(assigns) do
    ~H"""
    <div id={@id} phx-hook="Otp" role="group" class={["chelekom-otp_field", @class]} {@rest}>
      <input :if={@name} type="hidden" name={@name} data-part="value" class="chelekom-sr-only" />
      <input
        :for={i <- 1..@length}
        type="text"
        id={"#{@id}-#{i}"}
        data-part="input"
        autocomplete="one-time-code"
        class="chelekom-otp_field__input"
      />
    </div>
    """
  end
end
