# menubar (headless)

An unstyled, accessible desktop-style horizontal bar of menu buttons: markup + WAI-ARIA wiring, with behavior delegated to the shared `RovingTabindex` (root navigation) and `Popup` (per-menu open/close) JS engines. Implements the [WAI-ARIA APG Menubar pattern](https://www.w3.org/WAI/ARIA/apg/patterns/menubar/).

## Generate

```bash
mix mishka.ui.gen.headless menubar
```

Generates `lib/<app>_web/components/headless/menubar.ex`. Wire up the JS engines in `app.js`:

```js
import RovingTabindex from "./roving_tabindex.js";
import Popup from "./popup.js";
const Hooks = { RovingTabindex, Popup };
```

## Anatomy

The root is a `<div role="menubar">` carrying `phx-hook="RovingTabindex"` and `class="chelekom-menubar"`. Each `<:menu>` slot renders a per-menu wrapper carrying `phx-hook="Popup"`, holding a trigger button and a popup. Parts are marked with `data-part` hooks the `Popup` engine queries:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-menubar` | always rendered |
| menu wrapper | `div` | — | `chelekom-menubar__menu` | one per `<:menu>` slot |
| trigger | `button` | `trigger` | `chelekom-menubar__trigger` | per menu (uses `menu.label`) |
| popup | `div` | `popup` | `chelekom-menubar__popup` | per menu, holds `render_slot(menu)` |

Each menu wrapper is its own `Popup` instance; `Popup` queries `[data-part="trigger"]` and `[data-part="popup"]` within that wrapper. The popup id is `#{@id}-popup-#{i}` and the wrapper id is `#{@id}-menu-#{i}`.

Note: the trigger button carries `data-item` (not `data-part="item"`). `RovingTabindex` queries `[data-part="item"]`, so the template's initial `tabindex` (`0` on the first trigger, `-1` on the rest) is what's authored statically; arrow-key roving across triggers only engages for items marked `data-part="item"`.

## ARIA & keyboard

Roles and aria attributes (wired by the template + engines):

- **root** — `role="menubar"`, `data-orientation="horizontal"`.
- **trigger** — `role="menuitem"`, `aria-haspopup="menu"`, `aria-controls="#{@id}-popup-#{i}"`, and `aria-expanded` (authored `"false"`, toggled to `"true"`/`"false"` by `Popup` on open/close).
- **popup** — `role="menu"`, `aria-label={menu.label}`.

Keyboard (per the Menubar APG pattern; `Popup` handles open/close, `RovingTabindex` handles root navigation between items it finds):

- **Left / Right** — move between menus.
- **Home / End** — first / last menu.
- **Enter / Space** — open the focused menu.
- **Escape** — close the open menu (and return focus to its trigger).

`Popup` opens a menu on trigger click (toggle), closes on outside-click or Escape, and on open moves focus to the first `[data-part="item"]`, `[role="menuitem"]`, `[role="option"]`, `a`, or `button` inside the popup.

## State

Paired-presence (Base-UI style) attributes on each **popup**, toggled by the `Popup` engine:

- `data-open` — present when that menu is open.
- `data-closed` — present when that menu is closed.

The two are mutually exclusive per popup. The template renders the initial `data-closed`; thereafter `Popup` toggles `data-open`/`data-closed` (and sets `data-side` + the `--chelekom-side` CSS var) on show/hide, and mirrors the open state into the trigger's `aria-expanded`.

## Example

```heex
<.menubar id="app-menubar">
  <:menu label="File">
    <button type="button" role="menuitem" phx-click="new">New</button>
    <button type="button" role="menuitem" phx-click="open">Open</button>
    <button type="button" role="menuitem" phx-click="save">Save</button>
  </:menu>

  <:menu label="Edit">
    <button type="button" role="menuitem" phx-click="undo">Undo</button>
    <button type="button" role="menuitem" phx-click="redo">Redo</button>
  </:menu>

  <:menu label="View">
    <button type="button" role="menuitem" phx-click="zoom_in">Zoom In</button>
    <button type="button" role="menuitem" phx-click="zoom_out">Zoom Out</button>
  </:menu>
</.menubar>
```

Attrs: `id` (required), `class`, and `rest` (global). Slot: `menu` (required, repeatable) with a required `label` attr; its inner block holds the menu items. Give each item `role="menuitem"` so `Popup` can focus it on open.

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-menubar*` classes (`chelekom-menubar`, `__menu`, `__trigger`, `__popup`) and the `data-open` / `data-closed` state attributes, e.g.:

```css
.chelekom-menubar__popup            { position: absolute; }
.chelekom-menubar__popup[data-open]   { /* visible styles */ }
.chelekom-menubar__popup[data-closed] { display: none; }
```

Add your own classes to the root via the `class` attr.