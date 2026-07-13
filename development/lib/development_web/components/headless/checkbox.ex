defmodule DevelopmentWeb.Components.Headless.Checkbox do
  @moduledoc """
  Headless **checkbox** — a single checkable control (Base UI parity).

  Behaviour via the shared `Toggle` engine: clicking (or Enter/Space) flips the checked state, syncs
  a hidden native `<input type="checkbox">` for form submission, toggles `aria-checked` and the
  `data-checked`/`data-unchecked` state attributes, and mirrors them onto the `indicator`.

  Options: `indeterminate` (a mixed state — `aria-checked="mixed"` + `data-indeterminate`; the next
  toggle resolves to checked) · `readonly` · `required` · `on_change` (LiveView event `{checked}`).
  Mark a checkbox `parent` and wrap a set of checkboxes in `phx-hook="CheckboxGroup"` to get a
  tristate "select all" (parent reflects all/none/some and toggles every child).

  ARIA: `role="checkbox"` + `aria-checked` (`true`/`false`/`mixed`), `aria-readonly`/`aria-required`
  when set. Style via the `chelekom-checkbox*` classes — ships **no** colors or spacing.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/checkbox/

  **Documentation:** https://mishka.tools/chelekom/docs/headless/checkbox
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors the control)"
  attr :name, :string, default: nil, doc: "Name for the hidden form input"
  attr :checked, :boolean, default: false, doc: "Initial/controlled checked state"
  attr :indeterminate, :boolean, default: false, doc: "Mixed state (aria-checked=\"mixed\")"
  attr :value, :string, default: "true", doc: "Submitted value when checked"
  attr :disabled, :boolean, default: false, doc: "Disable interaction"
  attr :readonly, :boolean, default: false, doc: "Block toggling but stay focusable"
  attr :required, :boolean, default: false, doc: "Mark as required for native validation"
  attr :parent, :boolean, default: false, doc: "Tristate \"select all\" parent of a CheckboxGroup"
  attr :on_change, :string, default: nil, doc: "LiveView event pushed on toggle ({checked})"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :indicator_class, :any, default: nil, doc: "Extra classes for the indicator box"
  attr :label_class, :any, default: nil, doc: "Extra classes for the label"
  attr :rest, :global

  slot :indicator, doc: "Visual content of the indicator box (e.g. a check svg)"
  slot :inner_block, required: true, doc: "The checkbox label"

  def checkbox(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      phx-hook="Toggle"
      role="checkbox"
      aria-checked={aria_checked(@checked, @indeterminate)}
      aria-readonly={@readonly && "true"}
      aria-required={@required && "true"}
      data-disabled={@disabled}
      data-readonly={@readonly}
      data-required={@required}
      data-parent={@parent}
      data-checked={@checked && !@indeterminate}
      data-unchecked={!@checked && !@indeterminate}
      data-indeterminate={@indeterminate}
      data-value={@value}
      data-on-change={@on_change}
      class={["chelekom-checkbox", @class]}
      {@rest}
    >
      <input
        type="checkbox"
        data-part="input"
        name={@name}
        value={@value}
        checked={@checked && !@indeterminate}
        disabled={@disabled}
        required={@required}
        tabindex="-1"
        aria-hidden="true"
        class="chelekom-checkbox__input chelekom-sr-only"
      />
      <span
        data-part="indicator"
        aria-hidden="true"
        data-checked={@checked && !@indeterminate}
        data-unchecked={!@checked && !@indeterminate}
        data-indeterminate={@indeterminate}
        class={["chelekom-checkbox__indicator", @indicator_class]}
      >
        {render_slot(@indicator)}
      </span>
      <span data-part="label" class={["chelekom-checkbox__label", @label_class]}>{render_slot(
        @inner_block
      )}</span>
    </button>
    """
  end

  defp aria_checked(_checked, true), do: "mixed"
  defp aria_checked(checked, _), do: to_string(checked)
end
