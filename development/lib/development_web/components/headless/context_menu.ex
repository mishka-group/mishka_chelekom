defmodule DevelopmentWeb.Components.Headless.ContextMenu do
  @moduledoc """
  Headless **context menu** (Base UI parity) — a menu that opens at the pointer on
  right-click or touch long-press.

  Behavior is driven by the dedicated `ContextMenu` JS engine: right-click / long-press the
  `<:trigger>` area to open the menu at the cursor (clamped to the viewport); roving highlight
  + typeahead, Enter/Space activation, checkbox/radio item state, nested submenus
  (hover + ArrowRight / ArrowLeft), Escape and outside-press dismiss, focus restore.

  Composed from per-row function components (preserve order, support nesting):
  `context_menu` (root) and the rows `context_menu_item`, `context_menu_checkbox`,
  `context_menu_radio_group` + `context_menu_radio`, `context_menu_link`,
  `context_menu_separator`, `context_menu_group`, and `context_menu_submenu`.

  Ships **no** colors or spacing. Style the `chelekom-context_menu*` classes and the
  `data-open`/`data-closed`/`data-highlighted`/`data-checked`/`data-disabled`/
  `data-popup-open`/`data-starting-style` state. The popup is positioned `fixed` at the
  cursor by the engine; the scale-from-origin animation is your CSS.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/menu/
  """
  use Phoenix.Component

  # ── Root ────────────────────────────────────────────────────────────────
  #
  # TWO APIs (use whichever you like — you can even mix them):
  #   • the idiomatic `<:item>` / `<:submenu>` slots (flat rows via a `type` attr), OR
  #   • the composable `context_menu_*` row components passed as children (arbitrary order
  #     + mid-list submenus).
  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors aria relationships)"
  attr :disabled, :boolean, default: false, doc: "Disable all interaction"
  attr :on_open_change, :string, default: nil, doc: "LiveView event pushed on open/close ({open})"
  attr :on_open_change_target, :string, default: nil, doc: "Optional pushEventTo target for on_open_change"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  slot :trigger, required: true, doc: "The area to right-click / long-press to open the menu"

  slot :item, doc: "A menu row (idiomatic slot API)" do
    attr :type, :string, doc: "item (default) | checkbox | radio | link | separator | label"
    attr :disabled, :boolean
    attr :checked, :boolean, doc: "checkbox / radio"
    attr :value, :string, doc: "radio value"
    attr :name, :string, doc: "radio group name (single-selects items sharing it)"
    attr :href, :string, doc: "link href"
    attr :label, :string, doc: "group label text / typeahead override"
    attr :keep_open, :boolean, doc: "don't close the menu when activated"
    attr :on_change, :string, doc: "checkbox/radio change event ({checked}/{value})"
    attr :on_change_target, :string
  end

  slot :submenu, doc: "A nested submenu; put its rows (context_menu_item, ...) inside" do
    attr :label, :string, required: true
    attr :disabled, :boolean
  end

  slot :inner_block, doc: "Compose rows with the context_menu_* components instead of <:item>"

  def context_menu(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="ContextMenu"
      data-disabled={to_string(@disabled)}
      data-on-open-change={@on_open_change}
      data-on-open-change-target={@on_open_change_target}
      class={["chelekom-context_menu", @class]}
      {@rest}
    >
      <div data-part="trigger" class="chelekom-context_menu__trigger">
        {render_slot(@trigger)}
      </div>
      <div
        id={"#{@id}-popup"}
        data-part="popup"
        role="menu"
        tabindex="-1"
        hidden
        data-closed
        class="chelekom-context_menu__popup"
      >
        {render_slot(@inner_block)}
        <div :for={it <- @item} style="display: contents">
          <div :if={it[:type] == "separator"} role="separator" data-part="separator" data-orientation="horizontal" aria-orientation="horizontal" class="chelekom-context_menu__separator"></div>
          <div :if={it[:type] == "label"} role="presentation" data-part="group-label" class="chelekom-context_menu__group-label">{render_slot(it)}</div>
          <button
            :if={it[:type] == "checkbox"}
            type="button"
            role="menuitemcheckbox"
            data-part="checkbox-item"
            aria-checked={to_string(it[:checked] == true)}
            data-checked={it[:checked] == true}
            data-unchecked={it[:checked] != true}
            data-disabled={it[:disabled] == true}
            data-label={it[:label]}
            data-on-change={it[:on_change]}
            data-on-change-target={it[:on_change_target]}
            tabindex="-1"
            class="chelekom-context_menu__checkbox-item"
          >
            <span data-part="checkbox-item-indicator" aria-hidden="true" data-checked={it[:checked] == true} data-unchecked={it[:checked] != true} class="chelekom-context_menu__indicator">✓</span>
            {render_slot(it)}
          </button>
          <button
            :if={it[:type] == "radio"}
            type="button"
            role="menuitemradio"
            data-part="radio-item"
            data-value={it[:value]}
            data-radio-group={it[:name]}
            aria-checked={to_string(it[:checked] == true)}
            data-checked={it[:checked] == true}
            data-unchecked={it[:checked] != true}
            data-disabled={it[:disabled] == true}
            data-label={it[:label]}
            data-on-change={it[:on_change]}
            data-on-change-target={it[:on_change_target]}
            tabindex="-1"
            class="chelekom-context_menu__radio-item"
          >
            <span data-part="radio-item-indicator" aria-hidden="true" data-checked={it[:checked] == true} data-unchecked={it[:checked] != true} class="chelekom-context_menu__indicator">●</span>
            {render_slot(it)}
          </button>
          <a :if={it[:type] == "link"} href={it[:href]} role="menuitem" data-part="link-item" data-label={it[:label]} tabindex="-1" class="chelekom-context_menu__link-item">{render_slot(it)}</a>
          <button
            :if={it[:type] in [nil, "item"]}
            type="button"
            role="menuitem"
            data-part="item"
            data-disabled={it[:disabled] == true}
            data-keep-open={it[:keep_open] == true}
            data-label={it[:label]}
            tabindex="-1"
            class="chelekom-context_menu__item"
          >
            {render_slot(it)}
          </button>
        </div>
        <div
          :for={{sm, idx} <- Enum.with_index(@submenu)}
          data-part="submenu"
          class="chelekom-context_menu__submenu"
        >
          <button
            type="button"
            role="menuitem"
            data-part="submenu-trigger"
            aria-haspopup="menu"
            aria-expanded="false"
            aria-controls={"#{@id}-sub-#{idx}"}
            data-disabled={sm[:disabled] == true}
            data-label={sm[:label]}
            tabindex="-1"
            class="chelekom-context_menu__submenu-trigger"
          >
            {sm[:label]}
            <span data-part="submenu-chevron" aria-hidden="true" class="chelekom-context_menu__chevron">›</span>
          </button>
          <div
            id={"#{@id}-sub-#{idx}"}
            data-part="submenu-popup"
            role="menu"
            tabindex="-1"
            hidden
            data-closed
            class="chelekom-context_menu__submenu-popup"
          >
            {render_slot(sm)}
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ── Item ────────────────────────────────────────────────────────────────
  @doc type: :component
  attr :disabled, :boolean, default: false
  attr :label, :string, default: nil, doc: "Override the text used for typeahead"
  attr :keep_open, :boolean, default: false, doc: "Don't close the menu when activated"
  attr :class, :any, default: nil
  attr :rest, :global, doc: "e.g. phx-click for the action"
  slot :inner_block, required: true

  def context_menu_item(assigns) do
    ~H"""
    <button
      type="button"
      role="menuitem"
      data-part="item"
      data-disabled={@disabled}
      data-keep-open={@keep_open}
      data-label={@label}
      tabindex="-1"
      class={["chelekom-context_menu__item", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ── Checkbox item ─────────────────────────────────────────────────────────
  @doc type: :component
  attr :checked, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :label, :string, default: nil
  attr :on_change, :string, default: nil, doc: "LiveView event pushed on toggle ({checked})"
  attr :on_change_target, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :indicator, doc: "Override the checked glyph"
  slot :inner_block, required: true

  def context_menu_checkbox(assigns) do
    ~H"""
    <button
      type="button"
      role="menuitemcheckbox"
      data-part="checkbox-item"
      aria-checked={to_string(@checked)}
      data-checked={@checked}
      data-unchecked={!@checked}
      data-disabled={@disabled}
      data-label={@label}
      data-on-change={@on_change}
      data-on-change-target={@on_change_target}
      tabindex="-1"
      class={["chelekom-context_menu__checkbox-item", @class]}
      {@rest}
    >
      <span
        data-part="checkbox-item-indicator"
        aria-hidden="true"
        data-checked={@checked}
        data-unchecked={!@checked}
        class="chelekom-context_menu__indicator"
      >{if @indicator != [], do: render_slot(@indicator), else: "✓"}</span>
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ── Radio group + radio item ──────────────────────────────────────────────
  @doc type: :component
  attr :id, :string, default: nil
  attr :label, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def context_menu_radio_group(assigns) do
    ~H"""
    <div
      role="group"
      data-part="radio-group"
      aria-labelledby={@label && @id && "#{@id}-label"}
      class={["chelekom-context_menu__radio-group", @class]}
      {@rest}
    >
      <div
        :if={@label}
        id={@id && "#{@id}-label"}
        role="presentation"
        data-part="group-label"
        class="chelekom-context_menu__group-label"
      >
        {@label}
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc type: :component
  attr :value, :string, required: true
  attr :name, :string, default: nil, doc: "Radio group name (single-selects items sharing it; alternative to a radio_group wrapper)"
  attr :checked, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :label, :string, default: nil
  attr :on_change, :string, default: nil, doc: "LiveView event pushed on select ({value})"
  attr :on_change_target, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :indicator, doc: "Override the selected glyph"
  slot :inner_block, required: true

  def context_menu_radio(assigns) do
    ~H"""
    <button
      type="button"
      role="menuitemradio"
      data-part="radio-item"
      data-value={@value}
      data-radio-group={@name}
      aria-checked={to_string(@checked)}
      data-checked={@checked}
      data-unchecked={!@checked}
      data-disabled={@disabled}
      data-label={@label}
      data-on-change={@on_change}
      data-on-change-target={@on_change_target}
      tabindex="-1"
      class={["chelekom-context_menu__radio-item", @class]}
      {@rest}
    >
      <span
        data-part="radio-item-indicator"
        aria-hidden="true"
        data-checked={@checked}
        data-unchecked={!@checked}
        class="chelekom-context_menu__indicator"
      >{if @indicator != [], do: render_slot(@indicator), else: "●"}</span>
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ── Link item ─────────────────────────────────────────────────────────────
  @doc type: :component
  attr :href, :string, required: true
  attr :label, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def context_menu_link(assigns) do
    ~H"""
    <a
      href={@href}
      role="menuitem"
      data-part="link-item"
      data-label={@label}
      tabindex="-1"
      class={["chelekom-context_menu__link-item", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </a>
    """
  end

  # ── Separator ─────────────────────────────────────────────────────────────
  @doc type: :component
  attr :orientation, :string, default: "horizontal", values: ~w(horizontal vertical)
  attr :class, :any, default: nil
  attr :rest, :global

  def context_menu_separator(assigns) do
    ~H"""
    <div
      role="separator"
      data-part="separator"
      data-orientation={@orientation}
      aria-orientation={@orientation}
      class={["chelekom-context_menu__separator", @class]}
      {@rest}
    >
    </div>
    """
  end

  # ── Group (with label) ────────────────────────────────────────────────────
  @doc type: :component
  attr :id, :string, default: nil
  attr :label, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def context_menu_group(assigns) do
    ~H"""
    <div
      role="group"
      data-part="group"
      aria-labelledby={@label && @id && "#{@id}-label"}
      class={["chelekom-context_menu__group", @class]}
      {@rest}
    >
      <div
        :if={@label}
        id={@id && "#{@id}-label"}
        role="presentation"
        data-part="group-label"
        class="chelekom-context_menu__group-label"
      >
        {@label}
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ── Submenu ───────────────────────────────────────────────────────────────
  @doc type: :component
  attr :id, :string, required: true
  attr :label, :string, required: true, doc: "The submenu trigger text"
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global
  slot :chevron, doc: "Override the submenu chevron glyph"
  slot :inner_block, required: true, doc: "Nested submenu rows"

  def context_menu_submenu(assigns) do
    ~H"""
    <div data-part="submenu" class={["chelekom-context_menu__submenu", @class]} {@rest}>
      <button
        type="button"
        role="menuitem"
        data-part="submenu-trigger"
        aria-haspopup="menu"
        aria-expanded="false"
        aria-controls={"#{@id}-sub"}
        data-disabled={@disabled}
        data-label={@label}
        tabindex="-1"
        class="chelekom-context_menu__submenu-trigger"
      >
        {@label}
        <span data-part="submenu-chevron" aria-hidden="true" class="chelekom-context_menu__chevron">{if @chevron != [], do: render_slot(@chevron), else: "›"}</span>
      </button>
      <div
        id={"#{@id}-sub"}
        data-part="submenu-popup"
        role="menu"
        tabindex="-1"
        hidden
        data-closed
        class="chelekom-context_menu__submenu-popup"
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
