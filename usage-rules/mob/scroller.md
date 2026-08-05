# scroller (mob)

A horizontal rail of items with prev/next arrows. See [README](README.md) for the rules every Mob
component shares.

## Generate
`mix mishka.ui.gen.mob scroller` → `lib/<app>/components/scroller.ex`, tag `<Scroller>`.
With `--module-prefix mishka_` it is `<MishkaScroller>`.

## What it renders

```
column  fill_width
├── scroll   axis: horizontal, carries the id — this is a scroll_area
├── spacer   space
└── row      ‹ and › as ActionIcons, pushed right by a weighted Spacer
```

The scrolling is [`scroll_area`](scroll_area.md); what this adds is the arrows.

## Example

```elixir
~MOB"""
<MishkaScroller id="gallery" on_prev={:back} on_next={:fwd} height={76}>
  {[rail()]}
</MishkaScroller>
"""

# Scrolling is a side effect on a live widget — the offset lives in the native
# view, so there is no assign to set and nothing re-renders.
def handle_info({:tap, :fwd}, socket) do
  MishkaScroller.nudge("gallery", :next)
  {:noreply, socket}
end

def handle_info({:tap, :back}, socket) do
  MishkaScroller.nudge("gallery", :prev)
  {:noreply, socket}
end
```

Children are the rail's items — put them in a `Row`.

## Props

| Prop | Values | Default |
|---|---|---|
| `id` | string | `nil` — **required** for `nudge/3`; registers the native scroll view |
| `on_prev` / `on_next` | event tag (atom) | — sent as `{:tap, tag}` |
| `controls` | boolean | `true` — show the arrows at all |
| `height` | number | `nil` — rail height |
| `space` | number | `8` — gap between the rail and the controls |

Helpers: `nudge/3`.

Not ported: `scroll_by` (the pixel step is `nudge/3`'s `:step` option), `prev_label` / `next_label`
(aria-labels) and the `*_class` attrs.

## Five things to know

**The arrows do not scroll by themselves.** They emit tags; `nudge/3` is the side effect your
handler performs. This component shipped with arrows that emitted their tags into a screen that only
counted them — a rail that scrolls when swiped but not when you press its own arrows.

**`nudge/3` is a side effect, not an assign.** The offset lives in the native widget. There is
nothing to put in the socket, and nothing re-renders — so if you want visible feedback that the
handler ran (as distinct from "the rail is already at the end"), assign something yourself.

**An `id` is mandatory for nudging.** It is what registers the scroll view natively; without one
`nudge/3` has nothing to address and returns `{:error, _}`.

**The default step is 80% of the visible width**, so a nudge always leaves a sliver of the previous
tile on screen. Paging by a full viewport loses the reader's place. Override with `step:`.

**An arrow with no handler renders disabled rather than vanishing.** It is an ActionIcon — a Box
whose `on_tap` is simply omitted, which for a Box is genuinely inert, not merely grey.

## Known platform gaps

`nudge/3` calls `:mob_nif.scroll_to/3`, Mob's test-harness NIF, because there is no screen-facing
scroll API. That has two consequences (`development/mob/IOS_TODO.md` items 14-16):

- **it does not exist on an iOS release build** — the implementation and its NIF-table entry are
  inside `#if !MOB_RELEASE`, so the Erlang stub raises. `nudge/3` rescues and returns `:unsupported`
  rather than taking the screen process down, but the arrows are inert there.
- **it blocks the calling scheduler** for up to two seconds on Android and is not dirty-flagged.
- Android's `scroll_info` reports the measured *width* in the height fields for a horizontal rail,
  so `nudge/3` reads only the x-axis figures. For the same reason `Mob.Test.scroll_to(node, id,
  {:page, n})` is a silent no-op on any horizontal scroller — it always pages on Y.

Android is otherwise complete: the scroll NIF is registered in every build.

## Related
`scroll_area` (the rail without arrows), `marquee`, `carousel`, `action_icon` (the arrows).
