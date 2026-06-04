# fieldset (headless)

An unstyled group of related form controls: a native `<fieldset>` with an optional `<legend>`. No formal WAI-ARIA APG pattern applies — the native `fieldset`/`legend` elements supply the grouping semantics and accessible name.

## Generate

```bash
mix mishka.ui.gen.headless fieldset
```

Generates `lib/<app>_web/components/headless/fieldset.ex`. No JS engine to wire up — this component ships no scripts and no hooks.

## Anatomy

The root is a native `<fieldset>` carrying `class="chelekom-fieldset"`. The single part is the `<legend>`, marked with a `data-part` hook (purely a styling/query anchor here — no engine consumes it):

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `fieldset` | — | `chelekom-fieldset` | always rendered |
| legend | `legend` | `legend` | `chelekom-fieldset__legend` | `<:legend>` slot (rendered only when provided) |
| fields | — | — | — | `inner_block` (required, the grouped controls) |

## ARIA & keyboard

No explicit ARIA wiring and no JS. The `aria_pattern` is "Fieldset (no formal APG pattern)" with an empty keyboard list.

- The native `<fieldset>` exposes a `group` role and groups its descendant form controls.
- The native `<legend>` provides the group's accessible name; it is rendered only when the `<:legend>` slot is present.
- Keyboard behavior is the browser's native tab order through the contained controls — nothing is added or trapped.

## State

No state attributes. The `.exs` declares `state_attributes: []` and `hooks: []`, and the template adds no `data-open`/`data-closed`-style paired-presence attributes. **No JS** — there is nothing to toggle.

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

Attrs: `id` (default `nil`), `class` (extra classes for the root), and `rest` (global). Slots: `legend` (optional group label rendered as a `<legend>`) and `inner_block` (required, the grouped form controls). Omit `<:legend>` to render a fieldset with no legend.

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-fieldset*` classes (`chelekom-fieldset`, `chelekom-fieldset__legend`) and the `data-part="legend"` hook, e.g.:

```css
.chelekom-fieldset        { /* border / padding */ }
.chelekom-fieldset__legend { /* label typography */ }
[data-part="legend"]       { /* or target the part directly */ }
```

Add your own classes to the root via the `class` attr. There are no state `data-*` attributes to style against.