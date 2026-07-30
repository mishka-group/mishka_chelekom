# semi_circle_progress (mob)

A half-circle gauge — a 180° arc with a readout in the middle. See [README](README.md) for the rules
every Mob component shares.

## Generate
`mix mishka.ui.gen.mob semi_circle_progress` → `lib/<app>/components/semi_circle_progress.ex`, tag
`<SemiCircleProgress />`. With `--module-prefix mishka_` it is `<MishkaSemiCircleProgress />`.

## What it renders

A real arc, drawn on `Mob.UI.canvas/1` with two `Mob.Canvas.arc/6` ops.

```
column  fill_width
├── box  fill_width, align: :center      ← a Column cannot centre; the Box does
│   └── canvas  size x 0.54*size
│       ├── arc  180°→360°   track, butt cap
│       ├── arc  180°→180+180*frac   indicator, round cap  (omitted at zero)
│       └── text  the readout, anchored centre
├── spacer(8)
└── box  fill_width, align: :center
    └── text  the label
```

Every number is a ratio off the web component's `viewBox="0 0 200 108"`, whose paths are
`d="M 10 100 A 90 90 0 0 1 190 100"` — an exact semicircle bulging **up**, centre (100, 100),
radius 90:

| Derived | From | At `size: 140` |
|---|---|---|
| canvas height | `0.54 × size` (108/200) | 76 |
| `thickness` | `0.06 × size` (the canonical `stroke-width: 12` in `w-48`) | 8.4 |
| radius | `size/2 − thickness` | 61.6 |
| centre | `(size/2, size/2)` | (70, 70) |

So the gauge keeps the web proportions at any size instead of carrying numbers invented for one.

## Example

```elixir
~MOB"""
<MishkaSemiCircleProgress value={@battery} label="Battery" />
"""

# The gauge is a display — it emits nothing. Whatever moves the value is yours.
def handle_info({:tap, :charge}, socket) do
  {:noreply, Mob.Socket.assign(socket, :battery, clamp(socket.assigns.battery + 15))}
end

defp clamp(value), do: value |> max(0) |> min(100)
```

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | number **or numeric string** | `min` |
| `min` / `max` | number | `0` / `100` |
| `label` | string | `nil` — caption under the gauge |
| `value_text` | string | `nil` — replaces the percentage readout |
| `color` | color token / ARGB int | `:primary` |
| `size` | number | `140` — width in dp; height follows |
| `thickness` | number | `0.06 × size` |

`label` is the web component's `aria-label`. Mob has no accessibility layer to announce into, so it
renders as a visible caption rather than being dropped.

Not ported: `svg_class`, `track_class`, `indicator_class`, `label_class`, `id`. The web
`inner_block` slot — an arbitrary centred readout — is the `value_text` string here, because the
readout is painted into the canvas and a canvas draws **ops, not nodes**.

## Five things to know

**Clamp the value at the call site, not just in the component.** The arc clamps its own fraction, so
an unbounded assign looks harmless — and then a "+15" button walks the number to 250 while the
needle sits at full, and the next *ten* taps of "−15" do nothing visible. Every gauge on this page
shipped with that bug at least once (progress, meter, and this one).

**The indicator op is omitted at a zero sweep — do not "simplify" that away.** The indicator carries
a round cap to match the web, and a round-capped stroke with nothing to stroke paints a cap-sized
dot at the left end. Neither renderer guards it: Compose `drawArc` and SwiftUI `Path.addArc` are
called straight through. Guard the computed *sweep*, not the fraction.

**Only the indicator is round-capped.** The web sets `stroke-linecap="round"` on the indicator path
and leaves the track at the SVG default, so the track gets no `:cap` at all. `:cap` does reach arcs
on both platforms and both default to butt when omitted.

**A canvas is fixed-size dp.** It has no `fill_width`, so the gauge is exactly `size` wide and is
centred by the Box around it. Do not wrap it in a `Column` and expect `align` to help — Mob maps a
Column to a bare Compose `Column` and a leading `VStack`, and **neither aligns its children**.

**`canvas` is not a tag.** It is absent from `priv/tags/{android,ios}.txt`, so `<Canvas>` inside a
`~MOB` sigil warns, and this project builds with `--warnings-as-errors`. Call `Mob.UI.canvas/1` as
an interpolated expression instead, and pass `extra: [:canvas]` to `assert_renderable/2` in tests.

## Related
`progress` (the linear gauge; shares `fraction/1`, including numeric-string parsing), `meter`
(a progress bar with a scale), `angle_slider` (the other real arc, and a dial you can turn),
`rolling_number` (the companion on this page).
