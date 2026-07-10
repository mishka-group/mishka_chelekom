# menubar (headless)

An unstyled, accessible desktop-style horizontal bar of menu buttons: markup + WAI-ARIA wiring, behavior delegated to the shared `RovingTabindex` (root navigation) and `Popup` (per-menu open/close) JS engines. Implements the [WAI-ARIA APG Menubar pattern](https://www.w3.org/WAI/ARIA/apg/patterns/menubar/).

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

Root is `<div role="menubar">` with `phx-hook="RovingTabindex"` and class `chelekom-menubar`. Each `<:menu>` slot renders a per-menu wrapper with `phx-hook="Popup"`, holding a trigger button and a popup. `Popup` queries `[data-part="trigger"]`/`[data-part="popup"]` within each wrapper.

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-menubar` | always rendered |
| menu wrapper | `div` | — | `chelekom-menubar__menu` | one per `<:menu>` slot |
| trigger | `button` | `trigger` | `chelekom-menubar__trigger` | per menu (uses `menu.label`) |
| popup | `div` | `popup` | `chelekom-menubar__popup` | per menu, holds `render_slot(menu)` |

Popup id: `#{@id}-popup-#{i}`; wrapper id: `#{@id}-menu-#{i}`.

Note: the trigger button carries `data-item` (not `data-part="item"`). `RovingTabindex` queries `[data-part="item"]`, so the template's static `tabindex` (`0` on first trigger, `-1` on rest) is authored directly; arrow-key roving across triggers only engages for items marked `data-part="item"`.

## ARIA & keyboard

- **root** — `role="menubar"`, `data-orientation="horizontal"`.
- **trigger** — `role="menuitem"`, `aria-haspopup="menu"`, `aria-controls="#{@id}-popup-#{i}"`, `aria-expanded` (authored `"false"`, toggled by `Popup` on open/close).
- **popup** — `role="menu"`, `aria-label={menu.label}`.

Keyboard (per Menubar APG; `Popup` handles open/close, `RovingTabindex` handles root navigation between items it finds):

| Key | Action |
|---|---|
| Left / Right | move between menus |
| Home / End | first / last menu |
| Enter / Space | open focused menu |
| Escape | close open menu, return focus to its trigger |

`Popup` opens a menu on trigger click (toggle), closes on outside-click or Escape, and on open moves focus to the first `[data-part="item"]`, `[role="menuitem"]`, `[role="option"]`, `a`, or `button` inside the popup.

## State

Paired-presence (Base-UI style) attrs on each **popup**, toggled by `Popup`, mutually exclusive per popup:

- `data-open` — menu is open.
- `data-closed` — menu is closed (template renders this initially).

`Popup` toggles these on show/hide (also sets `data-side` + `--chelekom-side` CSS var) and mirrors open state into the trigger's `aria-expanded`.

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

Attrs: `id` (required), `class`, `rest` (global). Slot: `menu` (required, repeatable) with required `label` attr; inner block holds menu items. Give each item `role="menuitem"` so `Popup` can focus it on open.

## Styling

Ships **no** colors or spacing — structural markup only. Style via the `chelekom-menubar*` classes (`chelekom-menubar`, `__menu`, `__trigger`, `__popup`) and `data-open`/`data-closed` state attrs:

```css
.chelekom-menubar__popup            { position: absolute; }
.chelekom-menubar__popup[data-open]   { /* visible styles */ }
.chelekom-menubar__popup[data-closed] { display: none; }
```

Add custom classes to the root via `class`.
