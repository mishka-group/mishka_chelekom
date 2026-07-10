# checkbox_group (headless)

An unstyled, accessible group of native checkboxes: each option is a real `<input type="checkbox">` inside its `<label>`, so toggling, keyboard activation, and form submission are handled by the browser. Implements the [WAI-ARIA APG Checkbox pattern](https://www.w3.org/WAI/ARIA/apg/patterns/checkbox/).

## Generate

```bash
mix mishka.ui.gen.headless checkbox_group
```

Generates `lib/<app>_web/components/headless/checkbox_group.ex`. No JS engine to wire up — this component ships no scripts.

## Anatomy

Root is `<div role="group">` with `class="chelekom-checkbox_group"`, plus `aria-labelledby="#{@id}-label"` when a `<:label>` slot is present (otherwise omitted). Parts are marked with `data-part` hooks:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-checkbox_group` | always rendered |
| label | `span` | `label` | `chelekom-checkbox_group__label` | `<:label>` slot (optional); gets `id="#{@id}-label"`, referenced by root's `aria-labelledby` |
| item | `label` | `item` | `chelekom-checkbox_group__item` | `<:item>` slot (required, one per option) |
| input | `input` | `input` | `chelekom-checkbox_group__input` | native `<input type="checkbox">` inside each item; gets `checked`/`disabled` from the item attrs |

Each `<:item>` accepts `value` (required), `checked` (boolean), and `disabled` (boolean). Inputs share `name="<name>[]"` so selected values submit as a list; the item's inner block renders after the input as its visible label text.

## ARIA & keyboard

- **Space** — toggles the focused checkbox.
- **Tab** — moves between checkboxes.

All native browser behavior — no JS.

## State

This component has **no JS** (the `.exs` lists no scripts); checked/disabled state is driven entirely by the native inputs and slot attrs. The only state attribute is:

- `data-disabled` — present on the `item` (`<label>`) when that item's `disabled` attr is set; the input also gets the native `disabled` attribute.

No engine-toggled paired-presence attributes.

## Example

```heex
<.checkbox_group id="prefs" name="notifications">
  <:label>Email notifications</:label>

  <:item value="product" checked>Product updates</:item>
  <:item value="security">Security alerts</:item>
  <:item value="marketing" disabled>Marketing (unavailable)</:item>
</.checkbox_group>
```

Attrs: `id` (required), `name` (base form name; inputs submit as `name[]`; omit to render inputs without a form name), `class`, `rest` (global). Slots: `label` (optional, wired to `aria-labelledby`), `item` (required, repeatable — each with `value` required, plus optional `checked` and `disabled`).

## Styling

Ships **no** colors or spacing — only structural markup. Style via the `chelekom-checkbox_group*` classes (`chelekom-checkbox_group`, `__label`, `__item`, `__input`) and the `data-disabled` state attribute:

```css
.chelekom-checkbox_group__item[data-disabled] { opacity: 0.5; cursor: not-allowed; }
.chelekom-checkbox_group__input:checked       { /* checked styles */ }
```

Add your own classes to the root via the `class` attr.
