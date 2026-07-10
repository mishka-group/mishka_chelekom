# meter (headless)

An unstyled, accessible scalar gauge for a measurement within a known range (e.g. disk usage, battery level) — distinct from a `progress` bar which tracks task completion. Implements the [WAI-ARIA APG Meter pattern](https://www.w3.org/WAI/ARIA/apg/patterns/meter/). Ships **no** JavaScript.

## Generate

```bash
mix mishka.ui.gen.headless meter
```

Generates `lib/<app>_web/components/headless/meter.ex`. No JS engine to wire up — pure markup.

## Anatomy

Root is `<div role="meter">` with `class="chelekom-meter"`. Parts marked with `data-part`:

| Part | Element | `data-part` | Class | Rendered |
|------|---------|-------------|-------|----------|
| root | `div` | — | `chelekom-meter` | always |
| label | `span` | `label` | `chelekom-meter__label` | only when `label` attr is set |
| track | `div` | `track` | `chelekom-meter__track` | always |
| indicator | `div` | `indicator` | `chelekom-meter__indicator` | always (child of track) |

The `indicator` exposes the fill ratio via CSS custom property: `style="--chelekom-meter: <ratio>;"`, where `ratio = (value - min) / (max - min)` (`0` when `max <= min`).

## ARIA & keyboard

- **root** — `role="meter"` with `aria-valuemin={@min}`, `aria-valuemax={@max}`, `aria-valuenow={@value}`. When `label` is provided, `aria-labelledby="#{@id}-label"` points at the label span (which carries that matching `id`); omitted when `label` is `nil`.
- **Keyboard: none.** A meter is a read-only display per the APG pattern (`aria_pattern.keyboard` is empty) — no keyboard interactions.

## State

**No JS.** `state_attributes` and `hooks` are empty — no `data-*` paired-presence attributes, no engine. Fully driven by the `value`/`min`/`max` assigns, rendered into `aria-valuenow`/`aria-valuemin`/`aria-valuemax` and the `--chelekom-meter` ratio. Update the gauge by changing assigns (re-render) server-side.

## Example

```heex
<.meter id="disk" label="Disk usage" value={72} min={0} max={100} />
```

Attrs: `id` (required), `value` (required integer, within `[min, max]`), `min` (default `0`), `max` (default `100`), `label` (default `nil` — sets accessible label + `aria-labelledby`), `class`, `rest` (global). No slots — values via attrs only.

## Styling

Ships **no** colors or spacing — structural markup only. Style via `chelekom-meter*` classes (`chelekom-meter`, `__label`, `__track`, `__indicator`) and the `--chelekom-meter` ratio custom property on the indicator:

```css
.chelekom-meter__track {
  height: 0.5rem;
  background: #e5e7eb;
  border-radius: 9999px;
}
.chelekom-meter__indicator {
  height: 100%;
  width: calc(var(--chelekom-meter) * 100%); /* fill width follows value */
  background: #16a34a;
  border-radius: inherit;
}
```

Add custom classes to the root via `class`.
