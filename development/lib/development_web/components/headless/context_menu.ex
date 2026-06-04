defmodule DevelopmentWeb.Components.Headless.ContextMenu do
  @moduledoc """
  Headless **context menu** — a right-click (context) menu over an arbitrary area.

  Two cooperating engines: `Popup` on the root (`data-trigger="contextmenu"`) opens the
  menu at the pointer on right-click and closes it on outside-click / Escape; and
  `RovingTabindex` on the menu (arrow keys, Home/End). ARIA: list `role="menu"`; items
  `role="menuitem"`. Style via the `chelekom-context-menu*` classes and the
  `data-open` / `data-closed` state attributes — this component ships **no** colors or spacing.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/menu/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors aria relationships)"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  slot :trigger, required: true, doc: "The area to right-click to open the menu"

  slot :item, required: true do
    attr :disabled, :boolean
  end

  def context_menu(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Popup"
      data-trigger="contextmenu"
      class={["chelekom-context-menu", @class]}
      {@rest}
    >
      <div data-part="trigger" class="chelekom-context-menu__trigger">
        {render_slot(@trigger)}
      </div>
      <div
        id={"#{@id}-popup"}
        data-part="popup"
        role="menu"
        phx-hook="RovingTabindex"
        data-orientation="vertical"
        data-closed
        class="chelekom-context-menu__popup"
      >
        <button
          :for={item <- @item}
          type="button"
          role="menuitem"
          data-part="item"
          data-disabled={item[:disabled] || nil}
          tabindex="-1"
          class="chelekom-context-menu__item"
        >
          {render_slot(item)}
        </button>
      </div>
    </div>
    """
  end
end
