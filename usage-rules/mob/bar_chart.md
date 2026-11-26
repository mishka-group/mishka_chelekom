# bar_chart (mob)

**Documentation:** https://mishka.tools/chelekom/docs/mob/bar-chart

Rows of data drawn as bars against one shared scale — a ranking, or columns on a baseline. See
[README](README.md) for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob bar_chart` → `lib/<app>/components/bar_chart.ex`, tag `<BarChart />`.
With `--module-prefix mishka_` it is `<MishkaBarChart />`. It needs `progress` alongside it.

## The rows are data

Each entry is a map — `%{label: "Action", value: 6, value_text: "6h", color: 0xFF4E9A73, id:
"action", on_tap: :open_action}` — or a tuple, `{"Action", 6}` / `{"Action", 6, 0xFF4E9A73`.
Only `value` is required. The component never formats a number: `value` feeds the scale,
`value_text` is what a person reads.

## One scale, from zero

`max` unset means the loudest row. A fixed `max` is for a chart where full has to mean full.
Values above `max` clamp; an all-zero chart draws empty bars rather than dividing by zero.

## Declared widths, not measured ones

Mob reports no geometry back into `render/1`, so `label_width` (horizontal) and `value_width`
are what make a column of bars start and end on the same x. Leave them unset and each row hugs
its own text.

## Taps and selection

`on_tap` / `on_long_press` (or a row's own) go through `Event.handler/2`, so the message carries
the row: `{:tap, {tag, key}}`, `{:long_press, {tag, key}}` — `key` is the row's `id`, or its
index. The component holds no state: the screen sets `selected` (that same key) on the event and
the chart redraws. A selected row shows its reading even when `show_values` is off, so "tap a bar
and see what it is" needs no tooltip.

## A banded scale, or a ramp

`color_scale` colours a bar by where it falls instead of by a colour the row carries:

```elixir
<MishkaBarChart rows={rows()} color_scale={[{0.0, 0xFFB3564E}, {0.3, 0xFF5B7CA8}, {1.0, 0xFF8A8177}]} />
```

`:steps` (default) is strict — a bar takes the last stop at or below it, and one under the first
stop takes the first stop's colour. `scale_mode={:fade}` blends the two surrounding colours
channel by channel. Fading needs ARGB integers; a colour token cannot be mixed in Elixir, so under
`:fade` it is used as given at the stop below it. A row's own `color`, and `selected_color`, win
over the scale.

## One bar, several colours

A bar can be banded: `colors: [blue, orange, red, black]` divides the filled part evenly, and
`segments: [{0.5, blue}, {0.3, orange}, {0.2, black}]` sets the shares. Per row or once on the
chart; a row may stay a flat `color` beside them. Bands are drawn, not blended — a fade is this
with enough stops — and they stack from the start of the bar (left for a bar, up for a column).
The bar's `corner_radius` clips them, so a pill bar of four bands is still a pill.

## What it does not do

No axes, gridlines, legend, tooltip or animation. A legend is a wrap and an axis is measured
text; a chart that needs them is a page. `limit` with `more_text` covers the cap every real list
needs.

## Examples

```elixir
<MishkaBarChart rows={hours()} label_width={96} value_width={34} show_values={true} bar_size={8} />
```

```elixir
<MishkaBarChart rows={week()} orientation={:vertical} max={7} height={110} bar_size={24} />
```

```elixir
<MishkaBarChart
  rows={albums()} selected={@selected} on_tap={:select_album}
  limit={4} more_text="and 4 more" label_width={150} value_width={40}
/>
```
