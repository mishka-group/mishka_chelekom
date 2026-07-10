# toolbar (headless)

An unstyled, accessible toolbar: a group of controls with roving focus (exactly one `tabindex=0`), arrow-key navigation delegated to the shared `RovingTabindex` JS engine. Implements the [WAI-ARIA APG Toolbar pattern](https://www.w3.org/WAI/ARIA/apg/patterns/toolbar/).

## Generate

```bash
mix mishka.ui.gen.headless toolbar
```

Generates `lib/<app>_web/components/headless/toolbar.ex`. Wire up the JS engine in `app.js`:

```js
import RovingTabindex from "./roving_tabindex.js";
const Hooks = { RovingTabindex };
```

## Anatomy

Root is a `<div>` with `phx-hook="RovingTabindex"` and `class="chelekom-toolbar"`. `RovingTabindex` queries `[data-part="item"]` inside the root and skips any with `data-disabled`.

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-toolbar` | always rendered |
| item | `button` | `item` | `chelekom-toolbar__item` | `<:item>` slot (required, one button per slot entry) |

## ARIA & keyboard

- **root** — `role="toolbar"`, plus `aria-orientation` and `data-orientation` mirroring the `orientation` attr (`"horizontal"` or `"vertical"`).
- **item** — `<button type="button">` with `data-part="item"`. `tabindex` is `"0"` on the first item and `"-1"` on the rest initially; the engine rolls it as focus moves. A disabled item (via the slot's `disabled`) gets `data-disabled` and is skipped during navigation.

Keyboard (handled by `RovingTabindex`):

- **Left/Right** — move focus among items (horizontal orientation, the default).
- **Up/Down** — move focus among items (vertical orientation).
- **Home** / **End** — focus first / last item.
- **Tab** — moves focus out of the toolbar (only one item is tabbable).

Arrow navigation wraps around the ends. Enter/Space activate the focused item (the engine's `activate`, which rolls focus and toggles `data-highlighted`).

## State

Paired-presence (Base-UI style) attributes on items, toggled by the `RovingTabindex` engine:

- `data-highlighted` — present on the active/selected item, cleared on others; set by the engine's `activate` on click or Enter/Space. Engine-driven only — no initial highlighted state from the template.
- `data-disabled` — rendered by the template from the slot's `disabled`; disabled items are excluded from roving focus.

The engine also manages each item's `tabindex` (rolling the single `"0"`).

## Example

```heex
<.toolbar id="format-bar" orientation="horizontal">
  <:item>Bold</:item>
  <:item>Italic</:item>
  <:item disabled>Underline</:item>
  <:item>Link</:item>
</.toolbar>
```

Attrs: `id` (required), `orientation` (`"horizontal"` default, or `"vertical"`), `class`, `rest` (global). Slot: `item` (required) — each entry renders as a button; pass `disabled` on a `<:item>` to mark it `data-disabled` and skip it in navigation.

## Styling

Ships **no** colors or spacing — structural markup only. Style via the `chelekom-toolbar*` classes (`chelekom-toolbar`, `__item`) and the `data-orientation` / `data-highlighted` / `data-disabled` state attributes:

```css
.chelekom-toolbar[data-orientation="vertical"] { flex-direction: column; }
.chelekom-toolbar__item[data-highlighted]      { /* active styles */ }
.chelekom-toolbar__item[data-disabled]         { opacity: 0.5; pointer-events: none; }
```

Add your own classes to the root via the `class` attr.
