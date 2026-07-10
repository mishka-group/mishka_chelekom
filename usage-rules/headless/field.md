# field (headless)

Unstyled form-field wrapper composing a label, a control, an optional description, and error messages. No formal WAI-ARIA APG pattern (catalog: "Form Field (no formal APG pattern)") — you wire `for`/control `id` and `aria-describedby` yourself.

## Generate

```bash
mix mishka.ui.gen.headless field
```

Generates `lib/<app>_web/components/headless/field.ex`. No JS engine — pure markup.

## Anatomy

Root is a `<div class="chelekom-field">` (plus `@class`) with `id` from the `id` attr. Parts carry `data-part` (styling/scoping only, nothing queries them in JS):

| Part | Element | `data-part` | Class | Rendered when |
|------|---------|-------------|-------|------|
| root | `div` | — | `chelekom-field` | always |
| label | `label` | `label` | `chelekom-field__label` | `label` attr set; `for={@for}` |
| control | `div` | `control` | `chelekom-field__control` | always (wraps required `inner_block`) |
| description | `p` | `description` | `chelekom-field__description` | `<:description>` slot present; `id="#{@id}-desc"` when `id` is set |
| error | `p` | `error` | `chelekom-field__error` | one `<p>` per message in `errors` list |

## Attrs & slots

- `id` — anchors description/error ids.
- `for` — associates the label with your control's id.
- `label` — visible label text; `<label>` only renders when set.
- `errors` — list of messages, default `[]`.
- `class` — extra root classes.
- `rest` — global attrs.
- `inner_block` slot (required) — your form control.
- `description` slot (optional) — help text; `<p>` only renders when provided.

## ARIA & keyboard

No formal APG pattern, no keyboard interactions (catalog `keyboard: []`), no `role`/`aria-*` set for you. Association is manual:

- Give your control the same `id` as the label's `for`.
- Description renders with `id="#{@id}-desc"` (when `id` is set) — point your control's `aria-describedby` at it to associate help text/errors with the control.

## State

No JS — catalog's `state_attributes`, `hooks`, `scripts` are all empty; no paired-presence `data-*` state. Error visibility is driven purely by the server-rendered `errors` list (one `data-part="error"` `<p>` per message).

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

## Styling

Ships **no** colors, spacing, or typography — structural markup only. Style via `chelekom-field*` classes (`chelekom-field`, `__label`, `__control`, `__description`, `__error`) and `data-part` hooks:

```css
.chelekom-field__label       { /* label styles */ }
.chelekom-field__error       { /* error styles */ }
.chelekom-field [data-part="control"] input { /* control styles */ }
```

Add root-level classes via the `class` attr.
