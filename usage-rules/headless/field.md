# field (headless)

An unstyled form-field wrapper that composes a label, a control, an optional description and a list of error messages. No formal WAI-ARIA APG pattern (catalog pattern: "Form Field (no formal APG pattern)") — you wire `for`/control `id` and `aria-describedby` yourself.

## Generate

```bash
mix mishka.ui.gen.headless field
```

Generates `lib/<app>_web/components/headless/field.ex`. No JS engine to wire up — this component is pure markup.

## Anatomy

The root is a `<div>` carrying `class="chelekom-field"` (plus your `@class`) and the `id` from the `id` attr. Inner parts are marked with `data-part` for styling/scoping (no JS queries them):

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-field` | always rendered |
| label | `label` | `label` | `chelekom-field__label` | rendered when `label` attr is set; `for={@for}` |
| control | `div` | `control` | `chelekom-field__control` | wraps `inner_block` (required) |
| description | `p` | `description` | `chelekom-field__description` | rendered when `<:description>` slot is present; `id="#{@id}-desc"` when `id` is set |
| error | `p` | `error` | `chelekom-field__error` | one `<p>` per message in the `errors` list |

## ARIA & keyboard

No formal APG pattern and **no keyboard interactions** (catalog `keyboard: []`). The component does not set any `role` or `aria-*` attributes for you. Association is manual:

- Give your control the same `id` as the label's `for` (the `for` attr).
- The description renders with `id="#{@id}-desc"` (when `id` is set) — point your control's `aria-describedby` at that id to associate the help text (and errors) with the control.

## State

No JS — the catalog's `state_attributes`, `hooks`, and `scripts` are all empty. There are no `data-*` paired-presence state attributes and nothing toggles them. Error visibility is driven entirely by the server-rendered `errors` list (one `data-part="error"` paragraph per message).

## Example

```heex
<.field id="email" for="user_email" label="Email" errors={@errors}>
  <:description>We'll only use this to contact you.</:description>

  <input
    type="email"
    id="user_email"
    name="user[email]"
    aria-describedby="email-desc"
  />
</.field>
```

Attrs: `id` (anchors the description/error ids), `for` (associates the label with your control's id), `label` (visible label text, the `<label>` only renders when set), `errors` (list of messages, default `[]`), `class` (extra root classes), and `rest` (global). Slots: `inner_block` (required, your form control) and `description` (optional help text). The description `<p>` only renders when the `<:description>` slot is provided.

## Styling

This component ships **no** colors, spacing or typography — only structural markup. Style it via the `chelekom-field*` classes (`chelekom-field`, `__label`, `__control`, `__description`, `__error`) and the `data-part` hooks, e.g.:

```css
.chelekom-field__label       { /* label styles */ }
.chelekom-field__error       { /* error styles */ }
.chelekom-field [data-part="control"] input { /* control styles */ }
```

Add your own classes to the root via the `class` attr.
