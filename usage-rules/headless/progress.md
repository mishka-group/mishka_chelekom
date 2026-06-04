# progress (headless)

An unstyled, accessible **determinate** progress bar: a single `role="progressbar"` element with the WAI-ARIA value wiring, plus an inner indicator carrying a `--chelekom-progress` ratio you scale in CSS. Implements the [WAI-ARIA APG Progressbar pattern](https://www.w3.org/WAI/ARIA/apg/patterns/progressbar/). No JS.

## Generate

```bash
mix mishka.ui.gen.headless progress
```

Generates `lib/<app>_web/components/headless/progress.ex`. There is no JS engine to wire up — this component ships no `phx-hook` and no scripts.

## Anatomy

The root is a `<div role="progressbar">` with `class="chelekom-progress"`. It renders exactly one part, marked with a `data-part` hook:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-progress` | always rendered |
| indicator | `div` | `indicator` | `chelekom-progress__indicator` | always rendered |

There are **no named slots** — the component takes its value entirely from attrs. The indicator sets an inline `style="--chelekom-progress: <ratio>"` where `ratio = @value / @max` (a `0..1` number) for you to consume in CSS (e.g. `transform: scaleX(...)`).

## ARIA & keyboard

Roles and aria attributes (wired statically by the template):

- **root** — `role="progressbar"` with:
  - `aria-valuemin="0"` (constant),
  - `aria-valuemax={@max}` (defaults to `100`),
  - `aria-valuenow={@value}` (required),
  - `aria-label={@label}` (optional accessible name).

Keyboard: **none.** The Progressbar pattern is a non-interactive status indicator, so the `.exs` `aria_pattern` lists no `keyboard` interactions and the component handles no key events.

## State

**No JS** — the `.exs` `state_attributes`, `hooks`, and `scripts` are all empty. There are no `data-open`/`data-closed` style paired-presence attributes and nothing toggles them. State is expressed purely through the live `aria-valuenow` value and the `--chelekom-progress` ratio, both re-rendered server-side whenever the `value` assign changes.

## Example

```heex
<.progress id="upload" value={@uploaded} max={100} label="Upload progress" />
```

With a custom max and extra classes:

```heex
<.progress
  id="steps"
  value={@current_step}
  max={5}
  label="Onboarding progress"
  class="my-progress"
/>
```

Attrs: `value` (integer, **required**, between `0` and `max`), `max` (integer, default `100`), `id` (optional), `label` (optional accessible name), `class` (extra classes for the root), and `rest` (global). There are no slots. To advance the bar from the server, update the `value` assign.

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-progress*` classes (`chelekom-progress`, `chelekom-progress__indicator`) and the `--chelekom-progress` ratio (a `0..1` number) the indicator exposes inline, e.g.:

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
