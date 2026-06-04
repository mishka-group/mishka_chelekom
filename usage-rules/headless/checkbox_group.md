# checkbox_group (headless)

An unstyled, accessible group of native checkboxes: each option is a real `<input type="checkbox">` inside its `<label>`, so toggling, keyboard activation, and form submission are handled by the browser. Implements the [WAI-ARIA APG Checkbox pattern](https://www.w3.org/WAI/ARIA/apg/patterns/checkbox/).

## Generate

```bash
mix mishka.ui.gen.headless checkbox_group
```

Generates `lib/<app>_web/components/headless/checkbox_group.ex`. No JS engine to wire up — this component ships no scripts.

## Anatomy

The root is a `<div role="group">` with `class="chelekom-checkbox_group"`. Parts are marked with `data-part` hooks:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-checkbox_group` | always rendered |
| label | `span` | `label` | `chelekom-checkbox_group__label` | `<:label>` slot (rendered only when present) |
| item | `label` | `item` | `chelekom-checkbox_group__item` | `<:item>` slot (required, one per option) |
| input | `input` | `input` | `chelekom-checkbox_group__input` | native checkbox inside each item |

Each `<:item>` accepts `value` (required), `checked` (boolean), and `disabled` (boolean). Inputs share `name="<name>[]"` so the selected values submit as a list. The item's inner block renders after the input as its visible label text.

## ARIA & keyboard

Roles and aria attributes (wired by the template):

- **root** — `role="group"`, plus `aria-labelledby="#{@id}-label"` when a `<:label>` slot is present (otherwise omitted).
- **label** — `id="#{@id}-label"`, referenced by the root's `aria-labelledby`.
- **input** — native `<input type="checkbox">`; gets `checked` / `disabled` from the item attrs.

Keyboard (native browser behavior — no JS):

- **Space** — toggles the focused checkbox.
- **Tab** — moves between checkboxes.

## State

This component has **no JS** (the `.exs` lists no scripts). The only state attribute is `data-disabled`, rendered statically by the template:

- `data-disabled` — present on the `item` (`<label>`) when that item's `disabled` attr is set; the input also gets the native `disabled` attribute.

There are no engine-toggled paired-presence attributes; checked/disabled state is driven by the native inputs and the slot attrs.

## Example

```heex
<.checkbox_group id="prefs" name="notifications">
  <:label>Email notifications</:label>

  <:item value="product" checked>Product updates</:item>
  <:item value="security">Security alerts</:item>
  <:item value="marketing" disabled>Marketing (unavailable)</:item>
</.checkbox_group>
```

Attrs: `id` (required), `name` (base form name; inputs submit as `name[]`), `class`, and `rest` (global). Slots: `label` (optional, wired to `aria-labelledby`), `item` (required, repeatable — each with `value` required, plus optional `checked` and `disabled`). Omit `name` to render inputs without a form name.

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-checkbox_group*` classes (`chelekom-checkbox_group`, `__label`, `__item`, `__input`) and the `data-disabled` state attribute, e.g.:

```css
.chelekom-checkbox_group__item[data-disabled] { opacity: 0.5; cursor: not-allowed; }
.chelekom-checkbox_group__input:checked       { /* checked styles */ }
```

Add your own classes to the root via the `class` attr.