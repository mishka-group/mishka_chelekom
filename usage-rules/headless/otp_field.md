# otp_field (headless)

Unstyled one-time-code input: a row of single-character boxes with auto-advance, paste
distribution, and a hidden combined value for form submission.

## Generate
`mix mishka.ui.gen.headless otp_field` → `lib/<app>_web/components/headless/otp_field.ex`
(wires the `Otp` JS engine).

## Anatomy
Root `div[phx-hook="Otp"][role="group"]`. Parts: one `input` (`data-part="input"`) per digit,
plus a hidden `value` (`data-part="value"`) carrying the joined code.

## Behavior (Otp engine)
- Typing advances to the next box; Backspace clears and moves back; Arrow Left/Right navigate.
- Pasting a code distributes its characters across the boxes.
- `chelekom:complete` DOM event fires when every box is filled.

## Example
```heex
<.otp_field id="code" name="code" length={6} />
```

Attrs: `id` (required), `name` (hidden input name), `length` (default `6`), `class`, `rest`.

## Styling
Ships no colors. Root is `display:inline-flex; gap` by default — size/lay out the boxes via
the `chelekom-otp_field__input` class.
