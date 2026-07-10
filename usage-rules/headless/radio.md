# radio (headless)

Single, unstyled radio control (label + native input + indicator). Use inside a `radio_group` or a native `<fieldset>`. Follows WAI-ARIA Radio pattern via native radio semantics (no JS).

## Generate
`mix mishka.ui.gen.headless radio` → `lib/<app>_web/components/headless/radio.ex`.

## Anatomy
`<label>` wrapping:
- `input` — `data-part="input"`, native `type="radio"`
- `indicator` — `data-part="indicator"`, `aria-hidden`
- `label` — `data-part="label"`

## ARIA & keyboard / state
Native radio behavior — arrow keys move within a `name` group; only one selected. `data-disabled` set on the label when disabled; style native `:checked` (or a `data-checked` you toggle) on the input.

## Example
```heex
<.radio :for={{label, v} <- [{"Email","email"}, {"SMS","sms"}]}
  id={"notify-#{v}"} name="notify" value={v} checked={v == "email"}>
  {label}
</.radio>
```
Attrs: `id` (req), `name`, `value`, `checked`, `disabled`, `class`, `rest`. Slot: `inner_block` (the label).

## Styling
Ships no colors. Hide the native input and style `chelekom-radio__indicator` off `:checked`, e.g. `.chelekom-radio__input:checked + .chelekom-radio__indicator{ … }`.
