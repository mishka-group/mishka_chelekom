defmodule DevelopmentWeb.Components.Headless.Select do
  @moduledoc """
  Headless **select** (listbox) — a button that opens a single-select option list.

  Two cooperating engines: `Popup` (open/close, dismissal) and `RovingTabindex` (arrow keys,
  Home/End, selection). A hidden native `<input>` carries the value for form submission.
  ARIA: trigger `role="combobox"` + `aria-haspopup="listbox"` + `aria-expanded`; list
  `role="listbox"`; options `role="option"` + `aria-selected`. Style via `chelekom-select*`.

  > Note: full value/label two-way sync on selection is provided by the `form_integration`
  > engine (roadmap); this v1 wires open/close, keyboard navigation, ARIA and the hidden input.

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
        {@value || @placeholder}
      </button>
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
          {render_slot(opt)}
        </li>
      </ul>
    </div>
    """
  end
end
