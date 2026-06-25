# toggle_group (headless)

An unstyled, accessible toolbar of toggle buttons (single or multiple pressed): markup + WAI-ARIA wiring, with behavior delegated to two shared JS engines, `RovingTabindex` (root navigation) and `Toggle` (per-item pressed state). Implements the [WAI-ARIA APG Toolbar pattern](https://www.w3.org/WAI/ARIA/apg/patterns/toolbar/).

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

The root is a `<div>` carrying `phx-hook="RovingTabindex"` and `class="chelekom-toggle-group"`. Each item is a `<button>` carrying `phx-hook="Toggle"`, marked with `data-part="item"` (the hook the `RovingTabindex` engine queries):

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-toggle-group` | always rendered |
| item | `button` | `item` | `chelekom-toggle-group__item` | `<:item>` slot (required, repeatable) |

The root carries `data-orientation="horizontal"`. Each item button is given `id="#{@id}-item-#{i}"`, plus `data-value` (from the slot's `value` attr) and `data-disabled` (from the slot's `disabled` attr, or omitted). `RovingTabindex` queries `[data-part="item"]` inside the root and skips any with `data-disabled`.

## ARIA & keyboard

Roles and aria attributes (wired by the template + engines):

- **root** — `role="group"`, `data-orientation="horizontal"`.
- **item** — `role="button"`, `aria-pressed` (rendered as `"false"`, toggled by `Toggle`), `tabindex="-1"` initially. `RovingTabindex` keeps exactly one item at `tabindex="0"`.

Keyboard:

- **Left/Right** — move focus between toggles (`RovingTabindex`; wraps around, rolls `tabindex`). Set `data-orientation="vertical"` on the root for Up/Down instead.
- **Home** — focus first toggle. **End** — focus last toggle (`RovingTabindex`).
- **Enter/Space** — toggle the focused item's pressed state. Both engines handle these keys: `RovingTabindex` calls its `activate` (rolls focus / sets `data-highlighted`) and `Toggle` flips `aria-pressed`.

## State

Paired-presence (Base-UI style) attributes:

- `data-on` / `data-off` — on each item, toggled by the `Toggle` engine on every click/Enter/Space (mutually exclusive). The template renders `data-off` initially. `Toggle` no-ops on items carrying `data-disabled`.
- `data-highlighted` — on each item, toggled by `RovingTabindex` to mark the active item.
- `data-orientation` — on the root (`horizontal` by default), read by `RovingTabindex` to pick the arrow axis.

Both engines run together: `RovingTabindex` (root) manages focus/`tabindex`/`data-highlighted`; `Toggle` (each item) manages `aria-pressed`/`data-on`/`data-off`. The toggle group keeps no server state, so multiple items can be pressed at once unless you constrain it yourself.

## Example

```heex
<.toggle_group id="text-align">
  <:item value="left">Left</:item>
  <:item value="center">Center</:item>
  <:item value="right">Right</:item>
  <:item value="justify" disabled>Justify</:item>
</.toggle_group>
```

Attrs: `id` (required), `class`, and `rest` (global). Slot: `item` (required, repeatable) with per-item attrs `value` (string) and `disabled` (boolean). The `value` becomes `data-value` on the button; `disabled` becomes `data-disabled` (which excludes the item from roving navigation and from toggling).

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-toggle-group*` classes (`chelekom-toggle-group`, `__item`) and the `data-on` / `data-off`, `data-highlighted`, `data-disabled`, and `data-orientation` state attributes, e.g.:

```css
.chelekom-toggle-group__item[data-off]         { /* unpressed styles */ }
.chelekom-toggle-group__item[data-on]          { /* pressed styles */ }
.chelekom-toggle-group__item[data-highlighted] { /* focused item */ }
.chelekom-toggle-group__item[data-disabled]    { opacity: 0.5; pointer-events: none; }
```

Add your own classes to the root via the `class` attr.