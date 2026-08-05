# skeleton (mob)

A placeholder for content that has not arrived — the grey blocks a list shows while it loads. See
[README](README.md) for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob skeleton` → `lib/<app>/components/skeleton.ex`, tag `<Skeleton />`. With
`--module-prefix mishka_` it is `<MishkaSkeleton />`.

## It does not shimmer — and what it would cost to

Every skeleton on the web pulses. This one does not, for a reason worth stating precisely.

**Ordinary nodes cannot animate.** `Box`, `Text`, `Row` and `Column` expose no opacity, no alpha
and no transition, so nothing in this component's tree can fade. The only self-animating things
the bridge draws are Material's two progress indicators, which `progress` wraps.

**`Mob.UI.gpu_view/1` can.** It is a fragment-shader surface — GLES 3.0 on Android, Metal on iOS —
redrawing continuously at the display's refresh rate, so a shimmer really is expressible as a
shader. Two things make it the wrong tool here:

- the host provides **no time uniform**, so animating means pushing a new uniform from Elixir on
  every frame — a full render plus a NIF call at 60 Hz, per placeholder;
- each one is a whole `GLSurfaceView`, so a list of eight skeleton rows would allocate eight GL
  contexts to fade some grey boxes.

That is a reason *this* skeleton is static, not a reason a shader-backed one could never exist.

There is also no plugin to reach for: as of mob 0.7 every published `mob_*` package is a
capability (camera, location, biometric, scanner, bluetooth, nfc, vision, video, notify, photos,
touch, screencast, background, audio_capture) plus `mob_themes`, `mob_ash` and `mob_push`. None of
them does motion.

If you want movement to say *work is happening* rather than *content goes here*, reach for
[loading_overlay](loading_overlay.md) or `progress`. Those animate for free.

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
  ~MOB"<MishkaAvatar initials={@user.initials} size={40} />"
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
| `id` | string | — a native testTag; `:text` numbers its bars `id-0`, `id-1`, … |

Helper: `shares(lines, last_line)` → the width share of each bar.

## Three things to know

**The short last line is a Row weight, not a width — and weights are Android-only.** No geometry is
reported back to `render/1`, so nothing here can know how wide the parent is. On Android a bar at
`weight: 0.6` beside a spacer at `weight: 0.4` really is 60% of whatever it lands in. **On iOS the
renderer never parses `weight`**, so the bar and the spacer are two equally-flexible siblings in an
`HStack` and the last line lands at ~50% regardless of `last_line`. The full-width bars agree on
both — a lone flexible child gets 100% either way — which is why the divergence hides.

A portable version makes the inset rigid and the bar flexible (`<Box weight={1.0}/>` followed by
`<Box width={inset}/>`), which both engines resolve to `parent - inset`. That turns `last_line` from
a fraction into a dp inset, so it is an API change, not a silent fix. Until it lands, treat
`last_line` as an Android refinement.

**A block fills unless you give it a width.** That is what a card placeholder wants. A circle
always hugs, because an avatar that stretched across the row would be nonsense — both are set
explicitly, since a Box given neither `width` nor `fill_width` fills its parent.

**Match the real thing.** A skeleton whose sizes differ from the content that replaces it makes
the page jump on arrival, which is worse than showing nothing. Use the same `size` on the circle
as on the avatar, and the same `height` on the text bars as the line height beside them.

## Related
`loading_overlay` (covers content that exists), `progress` (an animated indicator),
`avatar` (what a `:circle` skeleton usually stands in for).
