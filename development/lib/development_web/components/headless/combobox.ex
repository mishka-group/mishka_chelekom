defmodule DevelopmentWeb.Components.Headless.Combobox do
  @moduledoc """
  Headless **combobox** (autocomplete) — a text input that filters a listbox.

  Behavior via the shared `HeadlessCombobox` JS engine: typing in the `input` filters the
  options (non-matching items get `data-hidden`), ArrowDown opens and moves a roving
  highlight (`data-highlighted` + `aria-activedescendant`), Enter/click selects (filling the
  input and a hidden `value` input), and Escape closes. The engine wires `role="combobox"`,
  `aria-controls`, `aria-expanded` and `aria-autocomplete` on the input at runtime; the
  listbox is `role="listbox"` and options are `role="option"`. Style via `chelekom-combobox*`
  classes and the `data-open`/`data-closed`/`data-highlighted`/`data-hidden` state attributes.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/combobox/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors the popup and option ids)"
  attr :name, :string, default: nil, doc: "Name for the hidden form input"
  attr :value, :string, default: nil, doc: "Currently selected value"
  attr :placeholder, :string, default: nil, doc: "Input placeholder text"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :option, required: true do
    attr :value, :string, required: true
  end

  def combobox(assigns) do
    ~H"""
    <div id={@id} phx-hook="HeadlessCombobox" class={["chelekom-combobox", @class]} {@rest}>
      <input
        type="text"
        data-part="input"
        aria-controls={"#{@id}-popup"}
        aria-expanded="false"
        placeholder={@placeholder}
        autocomplete="off"
        class="chelekom-combobox__input"
      />
      <input :if={@name} type="hidden" data-part="value" name={@name} value={@value} />
      <ul
        id={"#{@id}-popup"}
        data-part="popup"
        role="listbox"
        data-closed
        class="chelekom-combobox__popup"
      >
        <li
          :for={{opt, i} <- Enum.with_index(@option)}
          id={"#{@id}-opt-#{i}"}
          role="option"
          data-part="item"
          data-value={opt.value}
          aria-selected={to_string(opt.value == @value)}
          class="chelekom-combobox__item"
        >
          {render_slot(opt)}
        </li>
      </ul>
    </div>
    """
  end
end
