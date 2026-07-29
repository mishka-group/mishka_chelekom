# meter (mob)

A gauge for a **measurement** inside a known range — disk usage, battery, a rating. See
[README](README.md) for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob meter` → `lib/<app>/components/meter.ex`, tag `<Meter />`. Pulls in
`progress` as a sibling. With `--module-prefix mishka_` it is `<MishkaMeter />`.

## Meter or progress?

A meter reads **how full something is**. [progress](progress.md) reads **how far a task has got**.
On the web that is `role="meter"` versus `role="progressbar"` — a difference a screen reader
announces and nothing else. Mob exposes no roles, so the port keeps the two distinctions that
survive:

| | meter | progress |
|---|---|---|
| `value` | **required** — a meter always reads something | optional |
| no value | an **empty gauge** | the **indeterminate** looping bar |

"We don't know how full the disk is" is not a thing a meter says, so an absent value renders empty
rather than animating.

## What it renders

The same native bar Progress draws — it delegates, and shares `fraction/1` for the range maths
rather than duplicating clamping that would then drift.

```
column                     when there is a label or a readout
├── row  label … readout
├── spacer(6)
└── progress               the gauge itself
```

## Example

```elixir
~MOB"""
<MishkaMeter value={@used} label="Disk" show_value={true} height={14} color={band(@used)} />
<MishkaMeter value={3} max={5} value_text="3 of 5 bars" show_value={true} />
"""

# Colour from the value, so the gauge warns before the number is read.
defp band(v) when v >= 85, do: 0xFFDC2626
defp band(v) when v >= 60, do: 0xFFF59E0B
defp band(_v), do: 0xFF16A34A
```

No events — a meter reports, it does not collect.

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | number | `min` — effectively required |
| `min` / `max` | number | `0` / `100` |
| `label` | string | `nil` |
| `show_value` | boolean | `false` |
| `value_text` | string | `nil` — overrides the percentage |
| `color` | colour token / ARGB | the platform's |
| `height` | number | the platform's (~4) |

Helper: `ratio(props)` → the `0.0..1.0` fill, the native equivalent of the web's
`--chelekom-meter` custom property.

Not ported: `id` and the `*_class` attrs — they anchor `aria-*` relationships and style DOM parts.

## Three things to know

**Clamp what you STORE, not just what you draw.** `ratio/1` clamps the fill to `0.0..1.0`, so a
value past the end draws a full gauge — but if your assign keeps climbing behind it, coming back
down takes as many wasted taps as you spent going up. The bar looks right and the controls feel
broken. Both this component's demo and Progress's had exactly that bug.

**`height` is worth setting.** The platform default is a hairline (~4 dp), which is fine for a task
in flight and poor for a value someone is meant to read at a glance. It is forwarded to the native
widget, so the indicator really thickens rather than being padded.

**It is not drawn by hand, deliberately.** A `Row` of two weighted boxes was the obvious way to
build a proportional fill — and `weight` is a Compose concept Mob's iOS mapping does not
implement, so the gauge would have been proportional on Android and broken on iOS. The native
widget is proportional on both.

## Related
`progress` (a task in flight, and the widget this delegates to), `semi_circle_progress` (the same
value as an arc), `rolling_number` (the number beside a gauge, animated).
