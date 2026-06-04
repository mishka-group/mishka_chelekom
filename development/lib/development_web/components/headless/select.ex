defmodule DevelopmentWeb.Components.Headless.Select do
  @moduledoc """
  Headless **select** (listbox) — a button that opens a single-select option list.

  Two cooperating engines: `Popup` (open/close, dismissal) and `RovingTabindex` (arrow keys,
  Home/End, selection). A hidden native `<input>` carries the value for form submission.

  Anatomy (Base-UI-style parts): `trigger` (with a `value` and an `icon`), a `positioner`
  wrapping the `popup` listbox, and each `option` split into an `item-indicator` (selected ✓)
  and `item-text`. ARIA: trigger `role="combobox"` + `aria-haspopup="listbox"`; list
  `role="listbox"`; options `role="option"` + `aria-selected`. Style via `chelekom-select*`.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/combobox/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true
  attr :name, :string, default: nil, doc: "Name for the hidden form input"
  attr :value, :string, default: nil, doc: "Currently selected value"
  attr :placeholder, :string, default: "Select…"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :option, required: true do
    attr :value, :string, required: true
  end

  def select(assigns) do
    ~H"""
    <div id={@id} phx-hook="Popup" class={["chelekom-select", @class]} {@rest}>
      <input :if={@name} type="hidden" name={@name} value={@value} class="chelekom-sr-only" />

      <button
        type="button"
        data-part="trigger"
        role="combobox"
        aria-haspopup="listbox"
        aria-controls={"#{@id}-popup"}
        class="chelekom-select__trigger"
      >
        <span data-part="value" class="chelekom-select__value">{@value || @placeholder}</span>
        <span data-part="icon" aria-hidden="true" class="chelekom-select__icon">▾</span>
      </button>

      <div data-part="positioner" class="chelekom-select__positioner">
        <ul
          id={"#{@id}-popup"}
          data-part="popup"
          role="listbox"
          phx-hook="RovingTabindex"
          data-orientation="vertical"
          data-closed
          class="chelekom-select__popup"
        >
          <li
            :for={opt <- @option}
            role="option"
            data-part="item"
            data-value={opt.value}
            aria-selected={to_string(opt.value == @value)}
            tabindex="-1"
            class="chelekom-select__option"
          >
            <span data-part="item-indicator" aria-hidden="true" class="chelekom-select__indicator">
              ✓
            </span>
            <span data-part="item-text" class="chelekom-select__text">{render_slot(opt)}</span>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
