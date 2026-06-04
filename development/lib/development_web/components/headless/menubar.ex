defmodule DevelopmentWeb.Components.Headless.Menubar do
  @moduledoc """
  Headless **menubar** — a desktop-style horizontal bar of menu buttons.

  Two cooperating engines: `RovingTabindex` on the root `role="menubar"` (horizontal
  arrow-key navigation + Home/End over the top-level menu buttons, one `tabindex=0`) and
  one `Popup` per menu (click to open, outside-click/Escape to close). ARIA: root
  `role="menubar"`; each top-level button `role="menuitem"` + `aria-haspopup="menu"` +
  `aria-expanded`; each popup `role="menu"` with `role="menuitem"` children. Style via
  `chelekom-menubar*` classes and `data-open`/`data-closed`.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/menubar/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true
  attr :class, :any, default: nil
  attr :rest, :global

  slot :menu, required: true, doc: "A top-level menu; its inner block holds the menu items" do
    attr :label, :string, required: true
  end

  def menubar(assigns) do
    ~H"""
    <div
      id={@id}
      role="menubar"
      phx-hook="RovingTabindex"
      data-orientation="horizontal"
      class={["chelekom-menubar", @class]}
      {@rest}
    >
      <div
        :for={{menu, i} <- Enum.with_index(@menu)}
        id={"#{@id}-menu-#{i}"}
        phx-hook="Popup"
        class="chelekom-menubar__menu"
      >
        <button
          type="button"
          data-part="trigger"
          data-item
          role="menuitem"
          aria-haspopup="menu"
          aria-controls={"#{@id}-popup-#{i}"}
          aria-expanded="false"
          tabindex={if i == 0, do: "0", else: "-1"}
          class="chelekom-menubar__trigger"
        >
          {menu.label}
        </button>
        <div
          id={"#{@id}-popup-#{i}"}
          data-part="popup"
          role="menu"
          aria-label={menu.label}
          data-closed
          class="chelekom-menubar__popup"
        >
          {render_slot(menu)}
        </div>
      </div>
    </div>
    """
  end
end
