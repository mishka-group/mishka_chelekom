# context_menu (headless)

An unstyled, accessible right-click (context) menu over an arbitrary area: markup + WAI-ARIA wiring, with behavior delegated to two shared JS engines (`Popup` + `RovingTabindex`). Implements the [WAI-ARIA APG Menu pattern](https://www.w3.org/WAI/ARIA/apg/patterns/menu/).

## Generate

```bash
mix mishka.ui.gen.headless context_menu
```

Generates `lib/<app>_web/components/headless/context_menu.ex`. Wire up the JS engines in `app.js`:

```js
import Popup from "./popup.js";
import RovingTabindex from "./roving_tabindex.js";
const Hooks = { Popup, RovingTabindex };
```

## Anatomy

The root is a `<div>` carrying `phx-hook="Popup"`, `data-trigger="contextmenu"`, and `class="chelekom-context-menu"`. The popup is a nested `<div>` carrying `phx-hook="RovingTabindex"` and `data-orientation="vertical"`. Parts are marked with `data-part` hooks the engines query:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-context-menu` | always rendered |
| trigger | `div` | `trigger` | `chelekom-context-menu__trigger` | `<:trigger>` slot (required) |
| popup | `div` | `popup` | `chelekom-context-menu__popup` | always rendered (`role="menu"`) |
| item | `button` | `item` | `chelekom-context-menu__item` | `<:item>` slot (required, repeated) |

`Popup` queries `[data-part="trigger"]` and `[data-part="popup"]` inside the root. `RovingTabindex` queries `[data-part="item"]` inside the popup (skipping any with `data-disabled`).

## ARIA & keyboard

Roles and aria attributes (wired by the template + engines):

- **trigger** — right-click target. `Popup` sets `aria-controls` (pointing at `#{@id}-popup`) and `aria-expanded` (toggled `false`/`true`).
- **popup** — `role="menu"`, `data-orientation="vertical"`.
- **item** — `role="menuitem"`, `tabindex="-1"`, plus `data-disabled` when the `<:item disabled>` attr is set.

Keyboard (handled by `RovingTabindex` on the popup, `Popup` on the root):

- **Down/Up** — move focus among items (vertical orientation), wrapping at the ends.
- **Home/End** — focus the first / last item.
- **Enter/Space** — activate the focused item (`RovingTabindex` toggles `data-highlighted`).
- **Escape** — closes the menu and returns focus to the trigger (`Popup`).

Right-clicking the trigger calls `e.preventDefault()` and opens the menu at the pointer (`position: fixed` at `clientX`/`clientY`); right-clicking again toggles it closed. On open, `Popup` focuses the first menu item. Clicking outside the root closes the menu. Disabled items are skipped during navigation.

## State

Paired-presence (Base-UI style) attributes:

- `data-open` — present on the popup when the menu is open (toggled by `Popup`).
- `data-closed` — present on the popup when closed (rendered initially in the template, toggled by `Popup`); the two are mutually exclusive.
- `data-side` — written on the popup by `Popup` on open (default `bottom`); also exposed as the `--chelekom-side` CSS var.
- `data-highlighted` — toggled on the activated item by `RovingTabindex`.
- `data-disabled` — rendered by the template from `<:item disabled>`; excludes the item from roving navigation.

`Popup` also mirrors open state on the trigger via `aria-expanded`. The template renders the popup with an initial `data-closed`.

## Example

```heex
<.context_menu id="canvas-menu">
  <:trigger>
    <div class="canvas">Right-click anywhere here</div>
  </:trigger>

  <:item><span phx-click="cut">Cut</span></:item>
  <:item><span phx-click="copy">Copy</span></:item>
  <:item><span phx-click="paste">Paste</span></:item>
  <:item disabled><span>Delete</span></:item>
</.context_menu>
```

Attrs: `id` (required, anchors the aria relationships), `class` (extra classes for the root), and `rest` (global). Slots: `trigger` (required, the right-click area) and `item` (required, repeated; supports a `disabled` boolean attr). Each item renders as a `<button type="button">`.

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-context-menu*` classes (`chelekom-context-menu`, `__trigger`, `__popup`, `__item`) and the `data-*` state attributes, e.g.:

```css
.chelekom-context-menu__popup[data-closed]      { display: none; }
.chelekom-context-menu__popup[data-open]        { /* visible styles */ }
.chelekom-context-menu__item[data-highlighted]  { /* active item */ }
.chelekom-context-menu__item[data-disabled]     { opacity: 0.5; pointer-events: none; }
```

Add your own classes to the root via the `class` attr.
