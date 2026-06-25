# checkbox (headless)

An unstyled, accessible single checkable control: markup + WAI-ARIA wiring + a synced hidden form input, with behavior delegated to the shared `Toggle` JS engine. Implements the [WAI-ARIA APG Checkbox pattern](https://www.w3.org/WAI/ARIA/apg/patterns/checkbox/).

## Generate

```bash
mix mishka.ui.gen.headless checkbox
```

Generates `lib/<app>_web/components/headless/checkbox.ex`. Wire up the JS engine in `app.js`:

```js
import Toggle from "./toggle.js";
const Hooks = { Toggle };
```

## Anatomy

The root is a `<button type="button">` carrying `phx-hook="Toggle"`, `role="checkbox"`, and `class="chelekom-checkbox"`. Parts are marked with `data-part` hooks the engine queries:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `button` | — | `chelekom-checkbox` | always rendered |
| input | `input` | `input` | `chelekom-checkbox__input chelekom-sr-only` | always rendered (hidden, synced for form submission) |
| indicator | `span` | `indicator` | `chelekom-checkbox__indicator` | always rendered |
| label | `span` | `label` | `chelekom-checkbox__label` | `inner_block` (required) |

`Toggle` queries `[data-part="input"]` to keep the hidden native checkbox in sync.

## ARIA & keyboard

Roles and aria attributes (wired by the template + engine):

- **root** — `role="checkbox"` with `aria-checked` (initialized from the `checked` attr, then toggled `"true"`/`"false"` by the engine).
- **input** — hidden native `<input type="checkbox">` with `tabindex="-1"` and `aria-hidden="true"` (carries `name`/`value`/`checked`/`disabled` for form submission).
- **indicator** — `aria-hidden="true"` (decorative).

Keyboard (handled by `Toggle`):

- **Space** — toggles checked.
- **Enter** — toggles checked.

The engine ignores activation while `data-disabled` is present on the root.

## State

Paired-presence (Base-UI style) attributes, toggled by the `Toggle` engine on the root:

- `data-checked` — present when checked.
- `data-unchecked` — present when unchecked.

The two are always mutually exclusive. `aria-checked` mirrors the same state, and the hidden input's `.checked` is updated to match. `data-disabled` is rendered from the `disabled` assign (present only when disabled) and gates all toggling. The template renders the initial `data-checked`/`data-unchecked` from the `checked` assign; thereafter `Toggle` re-syncs on click and Enter/Space.

## Example

```heex
<.checkbox id="terms" name="accept_terms" value="yes" checked={false}>
  I accept the terms and conditions
</.checkbox>
```

Attrs: `id` (required), `name` (hidden input name, default `nil`), `checked` (boolean, default `false`), `value` (submitted value when checked, default `"true"`), `disabled` (boolean, default `false`), `class`, and `rest` (global). Slot: `inner_block` (required, the label). To drive it from the server, toggle the `checked` assign; for form submission, set `name` so the hidden input posts `value` when checked.

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-checkbox*` classes (`chelekom-checkbox`, `__input`, `__indicator`, `__label`) and the `data-checked` / `data-unchecked` / `data-disabled` state attributes, e.g.:

```css
.chelekom-checkbox__indicator                       { /* base box */ }
.chelekom-checkbox[data-checked] .chelekom-checkbox__indicator   { /* checked styles */ }
.chelekom-checkbox[data-unchecked] .chelekom-checkbox__indicator { /* unchecked styles */ }
.chelekom-checkbox[data-disabled]                   { /* disabled styles */ }
```

The `chelekom-sr-only` class visually hides the native input while keeping it in the form. Add your own classes to the root via the `class` attr.
