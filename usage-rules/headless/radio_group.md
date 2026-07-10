# radio_group (headless)

Unstyled, accessible single-select radio group: markup + WAI-ARIA wiring + roving focus, behavior delegated to the shared `RovingTabindex` JS engine. Implements the [WAI-ARIA APG Radio Group pattern](https://www.w3.org/WAI/ARIA/apg/patterns/radio/).

## Generate

```bash
mix mishka.ui.gen.headless radio_group
```

Generates `lib/<app>_web/components/headless/radio_group.ex`. Wire up the JS engine in `app.js`:

```js
import RovingTabindex from "./roving_tabindex.js";
const Hooks = { RovingTabindex };
```

## Anatomy

Root is a `<div>` with `phx-hook="RovingTabindex"` and `class="chelekom-radio-group"`. Items are `<button>` elements with `data-part="item"`, queried by the engine.

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-radio-group` | always rendered |
| hidden_input | `input` | — | `chelekom-sr-only` | rendered when `@name` is set; carries the value for form submission |
| item | `button` | `item` | `chelekom-radio-group__item` | one per `<:option>` slot entry |

`RovingTabindex` queries all `[data-part="item"]` inside the root (skipping any with `data-disabled`). Each item also carries `data-value` (from the slot's `value` attr).

## ARIA & keyboard

- **root** — `role="radiogroup"`, `data-orientation="vertical"`, `data-activate-on-focus`.
- **item** — `role="radio"`, `aria-checked` (initialized `"true"` on the first option, `"false"` otherwise), `tabindex` (`0` on the active item, `-1` on the rest). The engine re-syncs `aria-checked` and `tabindex` on selection.

Keyboard (handled by `RovingTabindex`, vertical orientation — the engine also supports Left/Right when orientation is horizontal):

| Key | Effect |
|-----|--------|
| ArrowDown | Focus next radio (wraps); `data-activate-on-focus` also selects it |
| ArrowUp | Focus previous radio (wraps) and selects it |
| Home / End | Focus and select first / last radio |
| Space / Enter | Select the currently focused radio |

On selection the engine keeps exactly one item with `tabindex=0`, sets that item's `aria-checked="true"` and clears the others, then focuses the target.

## State

- `data-highlighted` — paired-presence attribute (Base-UI style), toggled by the engine: present on the currently selected item, absent on the rest.
- `aria-checked` mirrors the same selection state (`"true"` on selected, `"false"` otherwise).

Initial active item = first item with `aria-selected="true"` or `data-active`, falling back to index 0; the template seeds `aria-checked="true"` on the first option.

**Note:** selection state lives in the DOM (engine-driven) — the hidden `<input value>` reflects the server `@value`, so submit-driven persistence depends on your form handling.

## Example

```heex
<.radio_group id="plan" name="plan" value="pro">
  <:option value="free">Free</:option>
  <:option value="pro">Pro</:option>
  <:option value="enterprise">Enterprise</:option>
</.radio_group>
```

Attrs: `id` (required), `name` (hidden form input name, default `nil`), `value` (currently selected value, default `nil`), `class`, `rest` (global). Slot: `option` (required, repeatable) with required `value` attr; content renders inside the radio button. When `name` is set, a hidden `<input>` carries `value` for form submission.

## Styling

Ships **no** colors or spacing — only structural markup. Style via `chelekom-radio-group*` classes (`chelekom-radio-group`, `__item`) and the `data-highlighted` / `aria-checked` state attributes:

```css
.chelekom-radio-group__item[aria-checked="true"] { /* selected styles */ }
.chelekom-radio-group__item[data-highlighted]    { /* selected/highlighted styles */ }
.chelekom-radio-group__item:focus-visible        { /* focus ring */ }
```

Add your own classes to the root via the `class` attr.
