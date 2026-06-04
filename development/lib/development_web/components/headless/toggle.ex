defmodule DevelopmentWeb.Components.Headless.Toggle do
  @moduledoc """
  Headless **toggle** — a two-state pressed button (on / off).

  The root element **is** a `<button>` wired to the shared `Toggle` JS engine: clicking
  (or Enter/Space) flips the pressed state. ARIA: `aria-pressed` reflects the current state;
  the matching `data-on` / `data-off` attributes are toggled for styling. Style via the
  `chelekom-toggle` class and the `data-on` / `data-off` state attributes — this component
  ships **no** colors, spacing, or typography.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/button/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Unique id for the button"
  attr :pressed, :boolean, default: false, doc: "Initial/controlled pressed state"
  attr :class, :any, default: nil, doc: "Extra classes for the root button"
  attr :rest, :global

  slot :inner_block, required: true, doc: "The toggle label / content"

  def toggle(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      phx-hook="Toggle"
      aria-pressed={to_string(@pressed)}
      data-on={@pressed}
      data-off={!@pressed}
      class={["chelekom-toggle", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end
end
