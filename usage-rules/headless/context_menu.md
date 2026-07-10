# context_menu (headless)

An unstyled, accessible right-click (context) menu over an arbitrary area: markup + WAI-ARIA wiring, behavior delegated to two shared JS engines (`Popup` + `RovingTabindex`). Implements the [WAI-ARIA APG Menu pattern](https://www.w3.org/WAI/ARIA/apg/patterns/menu/).

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

Root `<div>` carries `phx-hook="Popup"`, `data-trigger="contextmenu"`, `class="chelekom-context-menu"`. Popup is a nested `<div>` carrying `phx-hook="RovingTabindex"` and `data-orientation="vertical"`.

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-context-menu` | always rendered |
| trigger | `div` | `trigger` | `chelekom-context-menu__trigger` | `<:trigger>` slot (required) |
| popup | `div` | `popup` | `chelekom-context-menu__popup` | always rendered (`role="menu"`) |
| item | `button` | `item` | `chelekom-context-menu__item` | `<:item>` slot (required, repeated) |

`Popup` queries `[data-part="trigger"]` and `[data-part="popup"]` inside the root. `RovingTabindex` queries `[data-part="item"]` inside the popup (skipping any with `data-disabled`).

## ARIA & keyboard

- **trigger** — right-click target; `Popup` sets `aria-controls` (→ `#{@id}-popup`) and `aria-expanded` (`false`/`true`).
- **popup** — `role="menu"`, `data-orientation="vertical"`.
- **item** — `role="menuitem"`, `tabindex="-1"`, plus `data-disabled` when `<:item disabled>` is set.

Keyboard (`RovingTabindex` on the popup, `Popup` on the root):

- **Down/Up** — move focus among items (vertical), wrapping at the ends.
- **Home/End** — focus first / last item.
- **Enter/Space** — activate the focused item (`RovingTabindex` toggles `data-highlighted`).
- **Escape** — closes the menu, returns focus to the trigger.

Right-clicking the trigger calls `e.preventDefault()` and opens the menu at the pointer (`position: fixed` at `clientX`/`clientY`); right-clicking again toggles it closed. On open, `Popup` focuses the first menu item. Clicking outside the root closes the menu. Disabled items are skipped during navigation.

## State

Paired-presence (Base-UI style) attributes:

| Attribute | Meaning |
|-----------|---------|
| `data-open` | present on the popup when open (toggled by `Popup`) |
| `data-closed` | present on the popup when closed (initial in template, toggled by `Popup`); mutually exclusive with `data-open` |
| `data-side` | written on the popup by `Popup` on open (default `bottom`); also exposed as `--chelekom-side` CSS var |
| `data-highlighted` | toggled on the activated item by `RovingTabindex` |
| `data-disabled` | rendered from `<:item disabled>`; excludes the item from roving navigation |

`Popup` also mirrors open state on the trigger via `aria-expanded`.

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

- **Attrs**: `id` (required, anchors aria relationships), `class` (extra classes for root), `rest` (global).
- **Slots**: `trigger` (required, the right-click area); `item` (required, repeated; supports boolean `disabled`). Each item renders as `<button type="button">`.

## Styling

Ships **no** colors or spacing — only structural markup. Style via `chelekom-context-menu*` classes (`chelekom-context-menu`, `__trigger`, `__popup`, `__item`) and the `data-*` state attributes:

```css
.chelekom-context-menu__popup[data-closed]      { display: none; }
.chelekom-context-menu__popup[data-open]        { /* visible styles */ }
.chelekom-context-menu__item[data-highlighted]  { /* active item */ }
.chelekom-context-menu__item[data-disabled]     { opacity: 0.5; pointer-events: none; }
```

Add custom classes to the root via the `class` attr.
