# number_field (headless)

An unstyled, accessible number input flanked by stepper buttons, behavior delegated to the shared `NumberScrub` JS engine. Implements the [WAI-ARIA APG Spinbutton pattern](https://www.w3.org/WAI/ARIA/apg/patterns/spinbutton/).

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

Root is a `<div>` with `phx-hook="NumberScrub"` and `class="chelekom-number_field"`. **No slots** — markup is fixed and configured entirely via attrs. `NumberScrub` queries parts via `data-part` (falling back to the first `input` for the input part):

| Part | Element | `data-part` | Class | Notes |
|------|---------|-------------|-------|-------|
| root | `div` | — | `chelekom-number_field` | always rendered |
| decrement | `button` | `decrement` | `chelekom-number_field__decrement` | `type="button"`, `aria-label="Decrease"`, label `−` |
| input | `input` | `input` | `chelekom-number_field__input` | `type="number"`, carries `min`/`max`/`step`; engine sets `role="spinbutton"` on mount |
| increment | `button` | `increment` | `chelekom-number_field__increment` | `type="button"`, `aria-label="Increase"`, label `+` |

## ARIA, keyboard & interaction

- Keyboard (on the input): **ArrowUp/ArrowDown** — ±`step`; **PageUp/PageDown** — ±`10·step`.
- Clicking increment/decrement bumps the value by `±step`.
- Click-drag scrubbing: `pointerdown` + horizontal drag on the input changes the value, one `step` per 4px.
- All changes are clamped to `min`/`max` (default `-Infinity`/`Infinity` when unset), rounded to 6 decimals, and dispatch a bubbling `input` event so LiveView/forms pick up the new value.
- No paired-presence `data-*` state attrs — state lives purely in ARIA on the input, kept in sync by `NumberScrub` (`syncAria`) on mount and every value change:
  - `aria-valuenow` — current numeric value (always set; `0` when empty/NaN).
  - `aria-valuemin` — set only when a finite `min` is present.
  - `aria-valuemax` — set only when a finite `max` is present.
- `min`/`max`/`step` are read from the input element (`step` defaults to `1`).

## Example

```heex
<.number_field id="quantity" name="quantity" value={1} min={0} max={10} step={1} />
```

Attrs (no slots): `id` (optional), `name` (input name for form submission), `value` (current numeric value), `min`, `max`, `step` (default `1`), `class` (extra classes on the root), `rest` (global). Place inside a form and use `name` to submit the value; drive `value` from the server assign.

## Styling

Ships **no** colors, spacing, or typography — structural markup only. Style via the `chelekom-number_field*` classes (`chelekom-number_field`, `__decrement`, `__input`, `__increment`) and the ARIA state set by the engine:

```css
.chelekom-number_field { display: inline-flex; align-items: center; }
.chelekom-number_field__decrement,
.chelekom-number_field__increment { /* button styles */ }
.chelekom-number_field__input { text-align: center; }
.chelekom-number_field__input[aria-valuenow="0"] { /* state-based styling */ }
```

Add your own classes to the root via the `class` attr.
