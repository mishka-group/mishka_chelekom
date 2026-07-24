defmodule DevelopmentWeb.Components.Headless.Toggle do
  @moduledoc """
  Headless **toggle** — a two-state pressed button (Base UI parity).

  The root element **is** a `<button>` wired to the shared `Toggle` JS engine: clicking (or
  Enter/Space) flips the pressed state, toggling `aria-pressed` and `data-pressed` (present only when
  on). `disabled` ignores interaction (native + `data-disabled`); `on_change` pushes a LiveView event
  `{pressed}`. `value` identifies the toggle when used inside a toggle group.

  **Optional form submission** (a Phoenix extension over Base UI): give it a `name` and the toggle
  renders a hidden checkbox the engine keeps in sync, so it submits `value` (default `"on"`) when on —
  and `unchecked_value` when off (a companion hidden input), exactly like the switch.

  State attributes: `data-pressed`, `data-disabled`. Style via the `chelekom-toggle` class and the
  `data-pressed` / `data-disabled` hooks — this component ships **no** colors, spacing or typography.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/button/

  **Documentation:** https://mishka.tools/chelekom/docs/headless/toggle
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Unique id for the button"
  attr :pressed, :boolean, default: false, doc: "Initial/controlled pressed state"
  attr :disabled, :boolean, default: false, doc: "Ignore interaction (data-disabled)"

  attr :value, :string,
    default: nil,
    doc: "The toggle's value — its group identity and (with name) the value submitted when on"

  attr :name, :string,
    default: nil,
    doc: "Optional: submit the toggle as a form field (hidden checkbox)"

  attr :unchecked_value, :string,
    default: nil,
    doc: "Value submitted when off (adds a companion hidden input)"

  attr :form, :string,
    default: nil,
    doc: "Form id owning the hidden input (when rendered outside the form)"

  attr :on_change, :string, default: nil, doc: "LiveView event pushed on toggle ({pressed})"
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
      disabled={@disabled}
      data-pressed={@pressed}
      data-disabled={@disabled}
      data-value={@value}
      data-on-change={@on_change}
      class={["chelekom-toggle", @class]}
      {@rest}
    >
      <input
        :if={@name && @unchecked_value}
        type="hidden"
        name={@name}
        value={@unchecked_value}
        form={@form}
      />
      <input
        :if={@name}
        type="checkbox"
        data-part="input"
        name={@name}
        value={@value || "on"}
        checked={@pressed}
        disabled={@disabled}
        form={@form}
        tabindex="-1"
        aria-hidden="true"
        class="chelekom-toggle__input chelekom-sr-only"
      />
      {render_slot(@inner_block)}
    </button>
    """
  end
end
