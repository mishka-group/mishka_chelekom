# menu (headless)

A menu button: a trigger that opens a roving-focus popup of actionable menu items. Implements the WAI-ARIA APG [Menu Button](https://www.w3.org/WAI/ARIA/apg/patterns/menu-button/) pattern.

## Generate

```
mix mishka.ui.gen.headless menu
```

Generates `lib/<app>_web/components/headless/menu.ex` defining `<prefix>menu/1`. Requires the two JS hooks `Popup` and `RovingTabindex` to be imported and registered in your `LiveSocket` hooks:

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

The root `<div>` carries `phx-hook="Popup"`; the popup `<div>` carries `phx-hook="RovingTabindex"` with `data-orientation="vertical"`. Engines locate parts purely via the `data-part` hooks.

## ARIA & keyboard

- **trigger** — `aria-haspopup="menu"` (static in the template); `aria-expanded` and `aria-controls` are set at runtime by `Popup`.
- **popup** — `role="menu"`.
- **item** — `role="menuitem"`, `tabindex="-1"` (one item is rolled to `tabindex="0"` by `RovingTabindex`), `data-disabled` set when the slot entry is disabled (disabled items are skipped by navigation).

Keyboard (APG "Menu Button"):

- **Down / Up** — move highlight between items (vertical orientation; `RovingTabindex`).
- **Home / End** — first / last item.
- **Enter / Space** — activate the focused item (`RovingTabindex`).
- **Escape** — close the menu and return focus to the trigger (`Popup`).

On open, `Popup` focuses the first item; outside-click also closes.

## State

Paired-presence `data-*` attributes are toggled by the engines (the matching opposite attribute is removed):

| Attribute | On part | Toggled by |
| --- | --- | --- |
| `data-open` / `data-closed` | popup | `Popup` (`show`/`hide`) |
| `data-highlighted` | item | `RovingTabindex` (on activate) |
| `data-side` | popup | `Popup` (mirrors `data-side`) |
| `data-disabled` | item | template (from slot `disabled`) |

`Popup` also exposes the resolved side via the `--chelekom-side` CSS custom property and sets `aria-expanded` on the trigger. The popup starts with `data-closed` in the template.

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

Attributes: `id` (required), `side` (`"top" | "right" | "bottom" | "left"`, default `"bottom"`), `class`, plus any global attrs via `:rest`. Slots: `:trigger` (required) and `:item` (required, repeatable, accepts a `disabled` boolean).

## Styling

Ships **no colors or visual styling** — only behavior, ARIA, and state hooks. Style the structural classes and the state attributes yourself:

- `.chelekom-menu` — root wrapper
- `.chelekom-menu__trigger` — the button
- `.chelekom-menu__popup` — the `role="menu"` container
- `.chelekom-menu__item` — each `menuitem`

Drive visibility and emphasis from the data-state attributes, e.g.:

```css
.chelekom-menu__popup[data-closed] { display: none; }
.chelekom-menu__popup[data-open]   { display: block; }
.chelekom-menu__item[data-highlighted] { /* hover/focus emphasis */ }
.chelekom-menu__item[data-disabled]    { opacity: .5; pointer-events: none; }
```

Use `--chelekom-side` / `[data-side="…"]` on the popup for side-aware positioning.
