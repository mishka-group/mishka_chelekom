# menu (headless)

A menu button: a trigger that opens a roving-focus popup of actionable menu items. Implements the WAI-ARIA APG [Menu Button](https://www.w3.org/WAI/ARIA/apg/patterns/menu-button/) pattern.

## Generate

```
mix mishka.ui.gen.headless menu
```

Generates `lib/<app>_web/components/headless/menu.ex` defining `<prefix>menu/1`. Requires the `Popup` and `RovingTabindex` JS hooks imported and registered in your `LiveSocket` hooks:

```js
import Popup from "./popup.js";
import RovingTabindex from "./roving_tabindex.js";
```

## Anatomy

| Part | data-part | Element | Role |
| --- | --- | --- | --- |
| trigger | `data-part="trigger"` | `<button>` | `aria-haspopup="menu"` |
| popup | `data-part="popup"` | `<div>` | `role="menu"` |
| item | `data-part="item"` | `<button>` | `role="menuitem"` |

Root `<div>` carries `phx-hook="Popup"`; popup `<div>` carries `phx-hook="RovingTabindex"` with `data-orientation="vertical"`. Engines locate parts purely via `data-part`.

## ARIA & keyboard

- **trigger** — `aria-haspopup="menu"` (static); `aria-expanded`/`aria-controls` set at runtime by `Popup`.
- **popup** — `role="menu"`.
- **item** — `role="menuitem"`, `tabindex="-1"` (one item rolled to `tabindex="0"` by `RovingTabindex`), `data-disabled` when slot entry is disabled (disabled items skipped by navigation).

Keyboard (APG "Menu Button"): Down/Up move highlight (vertical, `RovingTabindex`) · Home/End jump first/last · Enter/Space activate focused item · Escape closes and returns focus to trigger (`Popup`).

On open, `Popup` focuses the first item; outside-click also closes.

## State

Paired-presence `data-*` attrs toggled by the engines (matching opposite attribute removed):

| Attribute | On part | Toggled by |
| --- | --- | --- |
| `data-open` / `data-closed` | popup | `Popup` (`show`/`hide`) |
| `data-highlighted` | item | `RovingTabindex` (on activate) |
| `data-side` | popup | `Popup` (mirrors resolved side) |
| `data-disabled` | item | template (from slot `disabled`) |

`Popup` also exposes the resolved side via `--chelekom-side` CSS custom property and sets `aria-expanded` on the trigger. The popup starts with `data-closed` in the template.

## Example

```heex
<.menu id="actions-menu" side="bottom" class="relative inline-block">
  <:trigger>
    Actions
  </:trigger>

  <:item>Edit</:item>
  <:item>Duplicate</:item>
  <:item disabled>Archive</:item>
  <:item>Delete</:item>
</.menu>
```

Attributes: `id` (required) · `side` (`"top" | "right" | "bottom" | "left"`, default `"bottom"`) · `class` · plus global attrs via `:rest`.
Slots: `:trigger` (required) · `:item` (required, repeatable, accepts `disabled` boolean).

## Styling

Ships **no colors or visual styling** — only behavior, ARIA, and state hooks. Style these structural classes and drive appearance from the state attributes:

- `.chelekom-menu` — root wrapper
- `.chelekom-menu__trigger` — the button
- `.chelekom-menu__popup` — the `role="menu"` container
- `.chelekom-menu__item` — each `menuitem`

```css
.chelekom-menu__popup[data-closed] { display: none; }
.chelekom-menu__popup[data-open]   { display: block; }
.chelekom-menu__item[data-highlighted] { /* hover/focus emphasis */ }
.chelekom-menu__item[data-disabled]    { opacity: .5; pointer-events: none; }
```

Use `--chelekom-side` / `[data-side="…"]` on the popup for side-aware positioning.
