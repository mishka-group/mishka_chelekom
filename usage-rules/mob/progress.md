# progress (mob)

A determinate or indeterminate progress bar, optionally labelled. See [README](README.md) for the
rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob progress` → `lib/<app>/components/progress.ex`, tag `<Progress />`. With
`--module-prefix mishka_` it is `<MishkaProgress />`.

## It really animates — one of the few things that does

This wraps Mob's native `Progress` (a Compose `LinearProgressIndicator` / SwiftUI `ProgressView`),
so the **indeterminate** bar loops on its own with no per-frame work from the BEAM. Along with
screen transitions it is essentially the only self-animating thing the bridge draws: ordinary
nodes expose no opacity, alpha or transition at all — see [skeleton](skeleton.md) for what that
rules out.

So when you want to say *work is happening*, reach for this or
[loading_overlay](loading_overlay.md), not for a placeholder.

## What it renders

```
progress                      a bare bar, when there is no label and no readout

column                        otherwise
├── row  label … readout      or just one of them
├── spacer(6)
└── progress
```

## Example

```elixir
~MOB"""
<MishkaProgress value={@percent} label="Uploading" show_value={true} />
<MishkaProgress value={3} max={5} label="Step" value_text="3 of 5" show_value={true} />
<MishkaProgress />
"""
```

No events — a progress bar reports, it does not collect. The value comes from your screen.

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | number or `nil` | `nil` — **`nil` is indeterminate** |
| `min` / `max` | number | `0` / `100` |
| `label` | string | `nil` |
| `show_value` | boolean | `false` |
| `value_text` | string | `nil` — overrides the rounded percentage |
| `color` | colour token / ARGB | the platform's |

Helper: `fraction(props)` → the `0.0..1.0` the native widget wants, or `nil` when indeterminate.

Not ported: `id` and the `*_class` attrs — they exist to anchor `aria-labelledby` and style DOM
parts.

## Three things to know

**Omitting `value` is not "zero", it is indeterminate.** `nil` gives the looping bar, and the
readout is dropped even when `show_value` is set, because there is no percentage to report. If you
mean empty, pass `value: 0`.

**The range is translated and clamped.** Chelekom expresses `value` inside `[min, max]`; the
native widget wants a fraction. `fraction/1` converts, and a value outside the range renders a
full or empty bar rather than one that overshoots its track. A degenerate range (`max == min`)
reads as `0.0` rather than raising.

**An indeterminate bar and device tests: mind the idling clock.** Compose's idling link can stall
on a screen that animates forever, and `performScrollTo` waits for idle — the suite hit
`IdlingResourceTimeoutException` once in a run where such a page had just been added. This page's
own tests then walked it with the ordinary helpers and passed, so the mechanism is not as simple
as "an indeterminate bar always hangs the suite". Do NOT reach for
`compose.mainClock.autoAdvance = false`: it freezes the whole render loop, and since this app's
trees arrive from the BEAM asynchronously, nothing renders at all — every assertion then times
out. Try the normal helpers first.

## Related
`meter` (a static gauge for a measurement, not a task in flight), `loading_overlay` (this bar over
a region, absorbing taps), `semi_circle_progress` (the same value as an arc),
`skeleton` (a placeholder, which cannot animate).
