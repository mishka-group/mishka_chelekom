defmodule DevelopmentWeb.Components.Headless.CheckboxGroup do
  @moduledoc """
  Headless **checkbox group** — a labelled group of native checkboxes.

  No JS engine: each item is a native `<input type="checkbox">` inside its `<label>`, so
  toggling, keyboard activation (Space) and form submission are handled by the browser.
  Inputs share `name="<name>[]"` so the selected values submit as a list. ARIA: root
  `role="group"` wired to an optional visible label via `aria-labelledby`. Style via the
  `chelekom-checkbox_group*` classes — this component ships **no** colors or spacing.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/checkbox/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors the group label relationship)"
  attr :name, :string, default: nil, doc: "Base form name; inputs submit as `name[]`"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  slot :label, doc: "Accessible group label (wired to aria-labelledby)"

  slot :item, required: true, doc: "A checkbox option" do
    attr :value, :string, required: true
    attr :checked, :boolean
    attr :disabled, :boolean
  end

  def checkbox_group(assigns) do
    ~H"""
    <div
      id={@id}
      role="group"
      aria-labelledby={(@label != [] && "#{@id}-label") || nil}
      class={["chelekom-checkbox_group", @class]}
      {@rest}
    >
      <span
        :if={@label != []}
        id={"#{@id}-label"}
        data-part="label"
        class="chelekom-checkbox_group__label"
      >
        {render_slot(@label)}
      </span>
      <label
        :for={item <- @item}
        data-part="item"
        data-disabled={item[:disabled] || nil}
        class="chelekom-checkbox_group__item"
      >
        <input
          type="checkbox"
          data-part="input"
          name={@name && "#{@name}[]"}
          value={item.value}
          checked={item[:checked] || nil}
          disabled={item[:disabled] || nil}
          class="chelekom-checkbox_group__input"
        />
        {render_slot(item)}
      </label>
    </div>
    """
  end
end
