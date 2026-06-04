defmodule DevelopmentWeb.Components.Headless.Checkbox do
  @moduledoc """
  Headless **checkbox** — a single checkable control.

  Behavior via the shared `Toggle` JS engine: clicking (or Enter/Space) flips the checked
  state, syncs a hidden native `<input type="checkbox">` for form submission, and toggles
  `aria-checked` plus the `data-checked` / `data-unchecked` state attributes. ARIA:
  `role="checkbox"` + `aria-checked`. Style via the `chelekom-checkbox*` classes — this
  component ships **no** colors or spacing.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/checkbox/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors the control)"
  attr :name, :string, default: nil, doc: "Name for the hidden form input"
  attr :checked, :boolean, default: false, doc: "Initial/controlled checked state"
  attr :value, :string, default: "true", doc: "Submitted value when checked"
  attr :disabled, :boolean, default: false, doc: "Disable interaction"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  slot :inner_block, required: true, doc: "The checkbox label"

  def checkbox(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      phx-hook="Toggle"
      role="checkbox"
      aria-checked={to_string(@checked)}
      data-disabled={@disabled || nil}
      data-checked={@checked}
      data-unchecked={!@checked}
      class={["chelekom-checkbox", @class]}
      {@rest}
    >
      <input
        type="checkbox"
        data-part="input"
        name={@name}
        value={@value}
        checked={@checked}
        disabled={@disabled}
        tabindex="-1"
        aria-hidden="true"
        class="chelekom-checkbox__input chelekom-sr-only"
      />
      <span data-part="indicator" aria-hidden="true" class="chelekom-checkbox__indicator"></span>
      <span data-part="label" class="chelekom-checkbox__label">{render_slot(@inner_block)}</span>
    </button>
    """
  end
end
