defmodule DevelopmentWeb.Components.Headless.Menu do
  @moduledoc """
  Headless **menu** (menu button) — a trigger that opens a roving-focus menu, with optional
  separators and nested submenus.

  Two cooperating engines: `Popup` on the root (open/close, outside-click/Escape) and
  `RovingTabindex` on the menu (arrow keys, Home/End). A `<:submenu label>` opens its own nested
  `Popup` menu; `<:item separator>` renders a divider. ARIA: trigger `aria-haspopup="menu"` +
  `aria-expanded`; list `role="menu"`; items `role="menuitem"`. Style via `chelekom-menu*`.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/menu-button/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true
  attr :side, :string, default: "bottom", values: ~w(top right bottom left)
  attr :class, :any, default: nil
  attr :rest, :global

  slot :trigger, required: true

  slot :item, required: true do
    attr :disabled, :boolean
    attr :separator, :boolean
  end

  slot :submenu do
    attr :label, :string, required: true
  end

  def menu(assigns) do
    ~H"""
    <div id={@id} phx-hook="Popup" data-side={@side} class={["chelekom-menu", @class]} {@rest}>
      <button type="button" data-part="trigger" aria-haspopup="menu" class="chelekom-menu__trigger">
        {render_slot(@trigger)}
      </button>
      <div
        id={"#{@id}-popup"}
        data-part="popup"
        role="menu"
        phx-hook="RovingTabindex"
        data-orientation="vertical"
        data-closed
        class="chelekom-menu__popup"
      >
        <div :for={item <- @item} class="contents">
          <div
            :if={item[:separator]}
            role="separator"
            data-part="separator"
            class="chelekom-menu__separator"
          >
          </div>
          <button
            :if={!item[:separator]}
            type="button"
            role="menuitem"
            data-part="item"
            data-disabled={item[:disabled] || nil}
            tabindex="-1"
            class="chelekom-menu__item"
          >
            {render_slot(item)}
          </button>
        </div>

        <div
          :for={{sub, i} <- Enum.with_index(@submenu)}
          id={"#{@id}-sub-#{i}"}
          phx-hook="Popup"
          data-side="right"
          class="chelekom-menu__submenu"
        >
          <button
            type="button"
            role="menuitem"
            data-part="item"
            aria-haspopup="menu"
            aria-controls={"#{@id}-sub-#{i}-popup"}
            tabindex="-1"
            class="chelekom-menu__item chelekom-menu__subtrigger"
          >
            {sub.label}
          </button>
          <div
            id={"#{@id}-sub-#{i}-popup"}
            data-part="popup"
            role="menu"
            phx-hook="RovingTabindex"
            data-orientation="vertical"
            data-closed
            class="chelekom-menu__popup chelekom-menu__subpopup"
          >
            {render_slot(sub)}
          </div>
        </div>
      </div>
    </div>
    """
  end
end
