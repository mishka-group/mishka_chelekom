# drawer (headless)

An unstyled, focus-trapped panel that slides in from an edge — same behavior as `dialog`
(WAI-ARIA Dialog-Modal pattern), plus a `side`.

## Generate
`mix mishka.ui.gen.headless drawer` → `lib/<app>_web/components/headless/drawer.ex` (wires the
`FocusTrap` JS engine).

## Anatomy
Root `div[phx-hook="FocusTrap"][data-side]`. `data-part`s: `trigger`, `backdrop` (auto,
`aria-hidden`), `popup` (`role="dialog"` `aria-modal` `data-side`), `title`, `description`,
`close`. Put `data-close` on a button to close.

## ARIA & keyboard
- **Escape** closes; **Tab** is trapped inside the popup; focus returns to the opener on close.
- Backdrop click closes (unless `data-close-on-outside="false"`).

## State
Paired-presence `data-open`/`data-closed` on root + popup (toggled by `FocusTrap`); `data-side`
(`left`/`right`/`top`/`bottom`) drives your slide animation.

## Example
```heex
<.drawer id="filters" side="right">
  <:trigger>Filters</:trigger>
  <:title>Filters</:title>
  <:description>Refine the results.</:description>
  <p>…filter controls…</p>
  <:close><button data-close>Done</button></:close>
</.drawer>
```
Attrs: `id` (req), `open`, `side` (default `right`), `labelledby`, `describedby`, `class`, `rest`.
Slots: `trigger`, `title`, `description`, `inner_block` (required, body), `close`.

## Styling
Ships no colors. Pin the popup to an edge and animate off `data-side` + `data-open`/`data-closed`,
e.g. `.chelekom-drawer__popup[data-side=right]{ right:0; … }`.
