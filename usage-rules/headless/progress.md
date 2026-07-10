# progress (headless)

An unstyled, accessible **determinate** progress bar: a single `role="progressbar"` element with WAI-ARIA value wiring, plus an inner indicator carrying a `--chelekom-progress` ratio you scale in CSS. Implements the [WAI-ARIA `progressbar` role](https://www.w3.org/TR/wai-aria-1.2/#progressbar). No JS.

## Generate

```bash
mix mishka.ui.gen.headless progress
```

Generates `lib/<app>_web/components/headless/progress.ex`. Ships no `phx-hook` and no scripts — no JS engine to wire up.

## Anatomy

Root is `<div role="progressbar">` with `class="chelekom-progress"`. No named slots — value comes entirely from attrs.

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-progress` | always rendered |
| indicator | `div` | `indicator` | `chelekom-progress__indicator` | always rendered |

The indicator sets an inline `style="--chelekom-progress: <ratio>"` where `ratio = @value / @max` (a `0..1` number) for you to consume in CSS (e.g. `transform: scaleX(...)`).

## ARIA & keyboard

Root `role="progressbar"` attrs (wired statically by the template):

- `aria-valuemin="0"` (constant)
- `aria-valuemax={@max}` (defaults to `100`)
- `aria-valuenow={@value}` (required)
- `aria-label={@label}` (optional accessible name)

Keyboard: **none.** The Progressbar pattern is a non-interactive status indicator — the `.exs` `aria_pattern` lists no `keyboard` interactions and the component handles no key events.

## State

**No JS** — the `.exs` `state_attributes`, `hooks`, and `scripts` are all empty. No `data-open`/`data-closed` style paired-presence attributes, nothing toggles them. State is purely the live `aria-valuenow` value and the `--chelekom-progress` ratio, both re-rendered server-side whenever the `value` assign changes.

## Attrs

`value` (integer, **required**, between `0` and `max`) · `max` (integer, default `100`) · `id` (optional) · `label` (optional accessible name) · `class` (extra classes for the root) · `rest` (global). No slots. To advance the bar from the server, update the `value` assign.

## Example

```heex
<.progress id="upload" value={@uploaded} max={100} label="Upload progress" />

<.progress
  id="steps"
  value={@current_step}
  max={5}
  label="Onboarding progress"
  class="my-progress"
/>
```

## Styling

Ships **no** colors or spacing — only structural markup. Style via the `chelekom-progress*` classes (`chelekom-progress`, `chelekom-progress__indicator`) and the `--chelekom-progress` ratio (`0..1`) the indicator exposes inline:

```css
.chelekom-progress {
  /* track styles: height, background, border-radius, overflow: hidden */
}
.chelekom-progress__indicator {
  height: 100%;
  transform-origin: left;
  transform: scaleX(var(--chelekom-progress));
}
```

Add your own classes to the root via the `class` attr.
