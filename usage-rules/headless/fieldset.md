# fieldset (headless)

An unstyled group of related form controls: a native `<fieldset>` with an optional `<legend>`. No formal WAI-ARIA APG pattern applies — the native `fieldset`/`legend` elements supply the grouping semantics and accessible name.

## Generate

```bash
mix mishka.ui.gen.headless fieldset
```

Generates `lib/<app>_web/components/headless/fieldset.ex`. No JS engine to wire up — this component ships no scripts and no hooks.

## Anatomy

Root is a native `<fieldset>` carrying `class="chelekom-fieldset"`. The single part is the `<legend>`, marked with a `data-part` hook (purely a styling/query anchor — no engine consumes it):

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `fieldset` | — | `chelekom-fieldset` | always rendered |
| legend | `legend` | `legend` | `chelekom-fieldset__legend` | `<:legend>` slot (rendered only when provided) |
| fields | — | — | — | `inner_block` (required, the grouped controls) |

## ARIA & keyboard

No explicit ARIA wiring and no JS. `aria_pattern` is "Fieldset (no formal APG pattern)" with an empty keyboard list.

- Native `<fieldset>` exposes a `group` role and groups its descendant form controls.
- Native `<legend>` provides the group's accessible name; rendered only when `<:legend>` is present.
- Keyboard behavior is the browser's native tab order — nothing added or trapped.

## State

No state attributes. `.exs` declares `state_attributes: []` and `hooks: []`; the template adds no `data-open`/`data-closed`-style presence attributes. **No JS** — nothing to toggle.

## Example

```heex
<.fieldset id="billing">
  <:legend>Billing address</:legend>

  <label for="street">Street</label>
  <input id="street" name="street" type="text" />

  <label for="city">City</label>
  <input id="city" name="city" type="text" />
</.fieldset>
```

Attrs: `id` (default `nil`), `class` (extra classes for root), `rest` (global). Slots: `legend` (optional group label, rendered as `<legend>`) and `inner_block` (required, the grouped form controls). Omit `<:legend>` to render a fieldset with no legend.

## Styling

Ships **no** colors or spacing — structural markup only. Style via classes/part hook:

```css
.chelekom-fieldset        { /* border / padding */ }
.chelekom-fieldset__legend { /* label typography */ }
[data-part="legend"]       { /* or target the part directly */ }
```

Add custom classes to the root via `class`. No state `data-*` attributes to style against.
