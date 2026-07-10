# toggle_group (headless)

An unstyled, accessible toolbar of toggle buttons (single or multiple pressed): markup + WAI-ARIA wiring, behavior delegated to two shared JS engines, `RovingTabindex` (root navigation) and `Toggle` (per-item pressed state). Implements the [WAI-ARIA APG Toolbar pattern](https://www.w3.org/WAI/ARIA/apg/patterns/toolbar/).

## Generate

```bash
mix mishka.ui.gen.headless toggle_group
```

Generates `lib/<app>_web/components/headless/toggle_group.ex`. Wire up the JS engines in `app.js`:

```js
import RovingTabindex from "./roving_tabindex.js";
import Toggle from "./toggle.js";
const Hooks = { RovingTabindex, Toggle };
```

## Anatomy

Root is a `<div phx-hook="RovingTabindex" class="chelekom-toggle-group">`. Each item is a `<button phx-hook="Toggle" data-part="item">` (the selector `RovingTabindex` queries).

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-toggle-group` | always rendered |
| item | `button` | `item` | `chelekom-toggle-group__item` | `<:item>` slot (required, repeatable) |

Root carries `data-orientation="horizontal"`. Each item gets `id="#{@id}-item-#{i}"`, `data-value` (from the slot's `value` attr), and `data-disabled` (from the slot's `disabled` attr, or omitted). `RovingTabindex` queries `[data-part="item"]` inside the root and skips any with `data-disabled`.

## ARIA & keyboard

- **root** — `role="group"`, `data-orientation="horizontal"`.
- **item** — `role="button"`, `aria-pressed` (renders `"false"`, toggled by `Toggle`), `tabindex="-1"` initially; `RovingTabindex` keeps exactly one item at `tabindex="0"`.

| Key | Effect |
|---|---|
| Left/Right | move focus between toggles (wraps, rolls `tabindex`). Set `data-orientation="vertical"` on root for Up/Down instead. |
| Home / End | focus first / last toggle |
| Enter/Space | toggles the focused item's pressed state — `RovingTabindex` rolls focus/sets `data-highlighted`, `Toggle` flips `aria-pressed` |

## State

Paired-presence (Base-UI style) attributes:

- `data-on` / `data-off` — on each item, toggled by `Toggle` on every click/Enter/Space (mutually exclusive; template renders `data-off` initially). No-ops on items with `data-disabled`.
- `data-highlighted` — on each item, toggled by `RovingTabindex` to mark the active item.
- `data-orientation` — on the root (`horizontal` default), read by `RovingTabindex` to pick the arrow axis.

`RovingTabindex` (root) manages focus/`tabindex`/`data-highlighted`; `Toggle` (each item) manages `aria-pressed`/`data-on`/`data-off`. No server state is kept, so multiple items can be pressed at once unless you constrain it yourself.

## Example

```heex
<.toggle_group id="text-align">
  <:item value="left">Left</:item>
  <:item value="center">Center</:item>
  <:item value="right">Right</:item>
  <:item value="justify" disabled>Justify</:item>
</.toggle_group>
```

Attrs: `id` (required), `class`, `rest` (global). Slot: `item` (required, repeatable) — attrs `value` (string, → `data-value`) and `disabled` (boolean, → `data-disabled`; excludes item from roving navigation and toggling).

## Styling

Ships **no** colors or spacing — structural markup only. Style via `chelekom-toggle-group` / `chelekom-toggle-group__item` classes and the `data-on`/`data-off`, `data-highlighted`, `data-disabled`, `data-orientation` state attrs:

```css
.chelekom-toggle-group__item[data-off]         { /* unpressed styles */ }
.chelekom-toggle-group__item[data-on]          { /* pressed styles */ }
.chelekom-toggle-group__item[data-highlighted] { /* focused item */ }
.chelekom-toggle-group__item[data-disabled]    { opacity: 0.5; pointer-events: none; }
```

Add your own classes to the root via `class`.
