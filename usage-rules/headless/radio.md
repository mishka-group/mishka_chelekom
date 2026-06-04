# radio (headless)

A single, unstyled radio control (label + native input + indicator). For use inside a
`radio_group` or a native `<fieldset>`. WAI-ARIA Radio pattern; relies on native radio
semantics (no JS).

## Generate
`mix mishka.ui.gen.headless radio` → `lib/<app>_web/components/headless/radio.ex`.

## Anatomy
A `<label>` wrapping: `input` (`data-part="input"`, native `type="radio"`), `indicator`
(`data-part="indicator"`, `aria-hidden`), and `label` (`data-part="label"`).

## ARIA & keyboard
Native radio behavior — arrow keys move within a `name` group; only one selected.

## State
`data-disabled` on the label when disabled; style the native `:checked` state (or a
`data-checked` you toggle) on the input.

## Example
```heex
<.radio :for={{label, v} <- [{"Email","email"}, {"SMS","sms"}]}
  id={"notify-#{v}"} name="notify" value={v} checked={v == "email"}>
  {label}
</.radio>
```
Attrs: `id` (req), `name`, `value`, `checked`, `disabled`, `class`, `rest`. Slot: `inner_block`
(the label).

## Styling
Ships no colors. Hide the native input and style the `chelekom-radio__indicator` off
`:checked` (e.g. `.chelekom-radio__input:checked + .chelekom-radio__indicator{ … }`).
