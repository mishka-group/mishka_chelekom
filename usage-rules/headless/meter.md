# meter (headless)

An unstyled, accessible scalar gauge for a measurement within a known range (e.g. disk usage, battery level) — distinct from a `progress` bar which tracks task completion. Implements the [WAI-ARIA APG Meter pattern](https://www.w3.org/WAI/ARIA/apg/patterns/meter/). Ships **no** JavaScript.

## Generate

```bash
mix mishka.ui.gen.headless meter
```

Generates `lib/<app>_web/components/headless/meter.ex`. No JS engine to wire up — this component is pure markup.

## Anatomy

The root is a `<div role="meter">` with `class="chelekom-meter"`. Parts are marked with `data-part`:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-meter` | always rendered |
| label | `span` | `label` | `chelekom-meter__label` | rendered only when `label` attr is set |
| track | `div` | `track` | `chelekom-meter__track` | always rendered |
| indicator | `div` | `indicator` | `chelekom-meter__indicator` | always rendered (child of track) |

The `indicator` exposes the fill ratio via the `--chelekom-meter` CSS custom property: `style="--chelekom-meter: <ratio>;"`, where `ratio = (value - min) / (max - min)` (or `0` when `max <= min`).

## ARIA & keyboard

Roles and aria attributes (all wired statically by the template):

- **root** — `role="meter"` with `aria-valuemin={@min}`, `aria-valuemax={@max}`, and `aria-valuenow={@value}`. When a `label` is provided, `aria-labelledby="#{@id}-label"` points at the label span (which carries the matching `id`); omitted when `label` is `nil`.

Keyboard: **none.** A meter is a read-only display per the APG Meter pattern (`aria_pattern.keyboard` is empty), so there are no keyboard interactions.

## State

**No JS.** `state_attributes` and `hooks` are empty — there are no `data-*` paired-presence attributes and no engine to toggle them. The gauge is fully driven by the `value`/`min`/`max` assigns, which the template renders into `aria-valuenow`/`aria-valuemin`/`aria-valuemax` and the `--chelekom-meter` ratio. To update the gauge, change the assigns (re-render) on the server.

## Example

```heex
<.meter id="disk" label="Disk usage" value={72} min={0} max={100} />
```

Attrs: `id` (required), `value` (required integer, within `[min, max]`), `min` (default `0`), `max` (default `100`), `label` (default `nil` — sets the accessible label and wires `aria-labelledby`), `class`, and `rest` (global). The component has no slots; pass values via attrs only.

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-meter*` classes (`chelekom-meter`, `__label`, `__track`, `__indicator`) and the `--chelekom-meter` ratio custom property on the indicator, e.g.:

```css
.chelekom-meter__track {
  height: 0.5rem;
  background: #e5e7eb;
  border-radius: 9999px;
}
.chelekom-meter__indicator {
  height: 100%;
  /* fill width follows the value */
  width: calc(var(--chelekom-meter) * 100%);
  background: #16a34a;
  border-radius: inherit;
}
```

Add your own classes to the root via the `class` attr.
