# scroll_area (mob)

A bounded region whose content scrolls. See [README](README.md) for the rules every Mob component
shares.

## Generate
`mix mishka.ui.gen.mob scroll_area` → `lib/<app>/components/scroll_area.ex`, tag `<ScrollArea>`.
With `--module-prefix mishka_` it is `<MishkaScrollArea>`.

## What it renders

A native `Scroll`, optionally inside a `Box` that supplies the bound and the decoration:

```
box     height / background / padding / corner_radius   — skipped entirely when none are set
└── scroll   axis: horizontal when orientation is :horizontal
```

The web component exists mainly to *replace* the browser's scrollbar with a styled one. There is
nothing to replace here — the platform supplies momentum, overscroll, rubber-banding and the
scrollbar, and a hand-drawn one would be worse.

## Example

```elixir
~MOB"""
<MishkaScrollArea height={220} id="feed" background={:surface} corner_radius={:radius_md}>
  {rows}
</MishkaScrollArea>
"""
```

No events. To scroll it from a handler rather than a finger, see
[`scroller`](scroller.md)'s `nudge/3` — it takes this component's `id`.

## Props

| Prop | Values | Default |
|---|---|---|
| `orientation` | `:vertical` / `:horizontal` | `:vertical` |
| `height` | number | `nil` — **required** for a vertical area to scroll at all |
| `id` | string | `nil` — registers the native scroll view so it can be scrolled by id |
| `background` | colour token / ARGB int | `nil` |
| `padding` | spacing token / number | `nil` |
| `corner_radius` | radius token / number | `nil` |

Not ported: the `*_class` attrs, which style a scrollbar the platform owns.

## Three things to know

**A scroll area needs a bound.** Content only scrolls if the viewport is smaller than it, so a
vertical area inside an already-scrolling page needs a `height`. Without one it grows to fit its
content and never scrolls — which looks like the component is broken when it is doing exactly what
it was told.

**`orientation: "both"` is not ported.** Compose's `Scroll` scrolls one axis; two-axis content wants
a horizontal scroller nested inside a vertical one, which is your composition rather than a prop.
The web component's third value is dropped rather than silently behaving like `:vertical`.

**An `id` is what makes it addressable.** It registers the native scroll view, which is what
`MishkaScroller.nudge/3` and `Mob.Test.scroll_info/2` look up. A scroll area with no `id` cannot be
read or driven at all.

## Known platform gap

**`height` is a no-op on iOS**, so a vertical scroll area does not scroll there. The bound is a Box
carrying `height` and `fill_width` but no `width`, and iOS's `MobBox` applies `fixedHeight` only in
the branch it takes when a width IS set — `development/mob/IOS_TODO.md` item 1. This is the failure
the "needs a bound" note describes, except that setting `height` cannot fix it. Android honours the
prop.

## Related
`scroller` (this plus prev/next arrows), `list`, `code` (uses a horizontal one internally).
