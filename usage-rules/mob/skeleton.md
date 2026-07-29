# skeleton (mob)

A placeholder for content that has not arrived — the grey blocks a list shows while it loads. See
[README](README.md) for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob skeleton` → `lib/<app>/components/skeleton.ex`, tag `<Skeleton />`. With
`--module-prefix mishka_` it is `<MishkaSkeleton />`.

## It does not shimmer, and cannot

Every skeleton on the web pulses. **Mob exposes no animation primitive at all** — no opacity, no
alpha, no transition — and the only animated things the bridge draws are Material's two progress
indicators. So this is a static placeholder, which is the honest version rather than a worse
imitation of the moving one.

If you want to say *work is happening* rather than *content goes here*, reach for
[loading_overlay](loading_overlay.md) or `progress`. Those really do animate.

## What it renders

```
:block    box                          fills, unless given a width
:circle   box  width = height = size, radius size/2
:text     column
          ├── row → box(weight 1.0)    a full-width bar
          ├── spacer(gap)
          └── row → box(weight 0.6) + spacer(weight 0.4)    the short last line
```

## Example

```elixir
# Both branches must build the SAME shape at the SAME sizes, or the content
# jumps when it arrives — which is the one thing a skeleton exists to prevent.
if @loaded do
  ~MOB"<MishkaAvatar name={@user.name} size={40} />"
else
  ~MOB"<MishkaSkeleton shape={:circle} size={40} />"
end
```

No events — a placeholder is not interactive, and it wires no handlers anywhere in its tree.

## Props

| Prop | Values | Default |
|---|---|---|
| `shape` | `:block` · `:text` · `:circle` | `:block` |
| `width` | number | fills — an exact width stops it filling |
| `height` | number | `12` text / `80` block |
| `size` | number | `40` — circle diameter, both axes |
| `lines` | integer | `3` — `:text` only |
| `last_line` | 0.0–1.0 | `0.6` — `:text` only, clamped |
| `gap` | number | `8` — `:text` only |
| `color` | colour token / ARGB | `:surface_raised` |
| `corner_radius` | radius token / number | pill / `size/2` / `:radius_md` |

Helper: `shares(lines, last_line)` → the width share of each bar.

## Three things to know

**The short last line is a Row weight, not a width.** No geometry is reported back to `render/1`,
so nothing here can know how wide the parent is — but weights are relative, so a bar at
`weight: 0.6` beside a spacer at `weight: 0.4` is 60% of whatever it lands in. That is the same
trick that lets `overflow_list` and `pill` work without measuring.

**A block fills unless you give it a width.** That is what a card placeholder wants. A circle
always hugs, because an avatar that stretched across the row would be nonsense — both are set
explicitly, since a Box given neither `width` nor `fill_width` fills its parent.

**Match the real thing.** A skeleton whose sizes differ from the content that replaces it makes
the page jump on arrival, which is worse than showing nothing. Use the same `size` on the circle
as on the avatar, and the same `height` on the text bars as the line height beside them.

## Related
`loading_overlay` (covers content that exists), `progress` (an animated indicator),
`avatar` (what a `:circle` skeleton usually stands in for).
