# number_field (headless)

An unstyled, accessible number input flanked by stepper buttons, with behavior delegated to the shared `NumberScrub` JS engine. Implements the [WAI-ARIA APG Spinbutton pattern](https://www.w3.org/WAI/ARIA/apg/patterns/spinbutton/).

## Generate

```bash
mix mishka.ui.gen.headless number_field
```

Generates `lib/<app>_web/components/headless/number_field.ex`. Wire up the JS engine in `app.js`:

```js
import NumberScrub from "./number_scrub.js";
const Hooks = { NumberScrub };
```

## Anatomy

The root is a `<div>` carrying `phx-hook="NumberScrub"` and `class="chelekom-number_field"`. There are **no slots** — the markup is fixed and configured entirely through attrs. Parts are marked with `data-part` hooks the engine queries:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-number_field` | always rendered |
| decrement | `button` | `decrement` | `chelekom-number_field__decrement` | always rendered (label `−`) |
| input | `input` | `input` | `chelekom-number_field__input` | always rendered (`type="number"`) |
| increment | `button` | `increment` | `chelekom-number_field__increment` | always rendered (label `+`) |

`NumberScrub` queries `[data-part="input"]` (falling back to the first `input`), `[data-part="increment"]`, and `[data-part="decrement"]` inside the root.

## ARIA & keyboard

Roles and aria attributes (wired by the template + engine):

- **decrement** / **increment** — buttons are `type="button"` with template-rendered `aria-label="Decrease"` / `aria-label="Increase"`.
- **input** — `type="number"` carrying `min`/`max`/`step`; the engine sets `role="spinbutton"` on mount.

Keyboard (handled by `NumberScrub`, listening on the input):

- **ArrowUp** — increment by `step`.
- **ArrowDown** — decrement by `step`.
- **PageUp** — increment by `10·step`.
- **PageDown** — decrement by `10·step`.

Clicking the increment/decrement buttons bumps the value by `±step`. The input also supports click-drag scrubbing: `pointerdown` on the input and dragging horizontally changes the value (one `step` per 4px). All changes are clamped to `min`/`max` (defaulting to `-Infinity`/`Infinity` when unset), rounded to 6 decimals, and dispatch a bubbling `input` event so LiveView/forms pick up the new value.

## State

There are **no** paired-presence `data-*` attributes. State is reflected purely through ARIA on the input, kept in sync by `NumberScrub` (via `syncAria`) on mount and on every value change:

- `aria-valuenow` — the current numeric value (always set; `0` when the input is empty/NaN).
- `aria-valuemin` — set only when a finite `min` is present.
- `aria-valuemax` — set only when a finite `max` is present.

`min`/`max`/`step` are read from the input element (`step` defaults to `1`).

## Example

```heex
<.number_field id="quantity" name="quantity" value={1} min={0} max={10} step={1} />
```

Attrs (no slots): `id` (optional), `name` (input name for form submission), `value` (current numeric value), `min`, `max`, `step` (default `1`), `class` (extra classes on the root), and `rest` (global). Place it inside a form and use the `name` attr to submit the value; drive the value from the server via the `value` assign.

## Styling

This component ships **no** colors, spacing, or typography — only structural markup. Style it via the `chelekom-number_field*` classes (`chelekom-number_field`, `__decrement`, `__input`, `__increment`) and the ARIA state set by the engine, e.g.:

```css
.chelekom-number_field { display: inline-flex; align-items: center; }
.chelekom-number_field__decrement,
.chelekom-number_field__increment { /* button styles */ }
.chelekom-number_field__input { text-align: center; }
.chelekom-number_field__input[aria-valuenow="0"] { /* state-based styling */ }
```

Add your own classes to the root via the `class` attr.