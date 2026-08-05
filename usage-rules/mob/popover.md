# popover (mob)

A trigger that toggles a panel of content beside it. See [README](README.md) for the rules every
Mob component shares.

## Generate
`mix mishka.ui.gen.mob popover` → `lib/<app>/components/popover.ex`, tag `<Popover>` plus its slot
tags. With `--module-prefix mishka_` they are `<MishkaPopover>`, `<MishkaPopoverTrigger>`, and so on.

## What it renders

```
column  fill_width, carries `id`
└── anchored  side · align · side_offset · align_offset
    ├── box     [0] the anchor — the trigger, IN FLOW, hugging its content
    │           `<id>-trigger-open` / `<id>-trigger-closed`, tappable
    └── column  [1] the panel — its OWN window, drawn OVER the page, only while open
        ├── the beak, when arrow — `<id>-arrow` on the glyph itself. Centred on the
        │         panel for `:top` / `:bottom` (the web's `left: 50%`); on `:left` /
        │         `:right` it is the bare glyph in a row, at the panel's leading edge.
        └── box   the surface — `<id>-panel`, hugging its content
            ├── text  `<id>-title`
            ├── text  `<id>-desc`
            ├── …     your children
            └── row   the footer — `<id>-close`, right-aligned
```

The root is a `column` whatever the `side`, and the trigger is child `[0]` with the panel `[1]` in
that order for every side — nothing shares a line with the panel any more. Without an arrow there is
no wrapper at all and the surface *is* child `[1]`; with `side={:top}` / `:left` the beak trails the
surface instead of leading it, and `:left` / `:right` make that wrapper a `row`.

Closed, the anchored node holds the trigger alone and opens no window. With no `trigger` at all
there is nothing to anchor to, so the panel simply renders in place — the `menu`-in-a-drawer case.

## Example

```elixir
~MOB"""
<MishkaPopover id="details" open={@open?} open_on_hold={true} on_open_change={:details}>
  <MishkaPopoverTrigger text="Order details" />
  <MishkaPopoverTitle text="Shipped 2 days ago" />
  <MishkaPopoverDescription text="Tracking arrives by email." />
  <MishkaPopoverArrow />
  <Text text="Two of three parcels have left the warehouse." />
  <MishkaPopoverClose text="Got it" />
</MishkaPopover>
"""

# The component sends the state it WANTS, so one clause serves the trigger, the
# long press and the footer's close button alike.
def handle_info({:tap, {:details, open?}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :open?, open?)}
end
```

## Slots

Every part the web declares as a slot is a tag here, and each has a shorthand prop for the plain
string case:

| Slot | Chelekom | Function | Takes | Shorthand prop |
|---|---|---|---|---|
| `<MishkaPopoverTrigger>` | `<:trigger>` | `trigger/1` | a label, or markup | `trigger` |
| `<MishkaPopoverTitle>` | `<:title>` | `title/1` | a line, or markup | `title` |
| `<MishkaPopoverDescription>` | `<:description>` | `description/1` | a line, or markup | `description` |
| `<MishkaPopoverClose>` | `<:close>` | `close/1` | a label, or your own controls | `close` |
| `<MishkaPopoverArrow>` | `<:arrow>` | `arrow/0` | nothing, a glyph, or markup | `arrow` |
| bare children | `<:inner_block>` | — | the panel's body | — |

Write `text="…"` and the component styles the part exactly as the shorthand prop does; write markup
inside the tag and the styling is yours, wrapped in a Column that wears the part's testTag. A slot
wins over its shorthand, and **order does not matter** — the slots are matched on `:type` among the
children, consumed there, and each is placed where the anatomy says.

Tag and function build the identical node, so reach for the function when the parts come from
**data** — a comprehension can return `trigger/1`, and there is no way to write a tag from one:

```elixir
rows = Enum.map(@parcels, &line/1)

~MOB"""
<MishkaPopover id="order" open={@open?} on_open_change={:order}>
  {[MishkaPopover.trigger("Order details"), MishkaPopover.title(@status) | rows]}
</MishkaPopover>
"""
```

## Props

| Prop | Values | Default |
|---|---|---|
| `id` | string | `nil` — root testTag; every part derives its own from it |
| `open` | boolean | `false` — the panel draws nothing when closed |
| `trigger` | string / node / nodes | `nil` — omit it and you place your own |
| `on_open_change` | event tag | — `{:tap, {tag, next_open?}}` |
| `open_on_hold` | boolean | `false` — a long press on the trigger opens it |
| `disabled` | boolean | `false` — wires no handler, so the trigger is inert |
| `chevron` | boolean | `true` — the ▾/▴ on the trigger |
| `side` | `:top` `:right` `:bottom` `:left` | `:bottom` — which side of the trigger the panel takes |
| `align` | `:start` `:center` `:end` | `:start` — across that side, against the trigger's own box |
| `side_offset` | number | `8` — the gap, in dp |
| `align_offset` | number | `nil` — nudge along the alignment axis; positive pushes *inward* on `:end` |
| `flip` | boolean | `true` — turn to the opposite side when the requested one has no room |
| `clamp` | boolean | `true` — keep the panel inside the window |
| `edge_padding` | number | `8` — kept clear of the window edges, on top of the safe-area inset |
| `title` / `description` | string | `nil` |
| `close` | string | `nil` — label for a footer action that reports it closed |
| `arrow` | boolean | `false` |
| `width` | number | `nil` — panel width; omit and the panel hugs its content |
| `background` | colour token / ARGB int | `:surface` |
| `color` / `muted_color` | colour token / ARGB int | `:on_surface` / `:muted` |
| `corner_radius` · `padding` | radius / spacing | `:radius_md` · `:space_md` |
| `border_color` / `border_width` | colour / number | `:border` / `1` |
| `offset_x` / `offset_y` | number | `nil` — raw nudge, applied last, on top of the two offsets rather than instead of them |

Helpers: `panel/2` (the bare shell), `trigger_id/2`, `panel_id/1`, `title_id/1`,
`description_id/1`, `close_id/1`, `arrow_id/1`.

Not ported: `modal` and its backdrop, `dismissible`, `close_on_escape`, `initial_focus` /
`final_focus`, `labelledby` / `describedby`, `open_on_hover` / `delay` / `close_delay`, and the
`*_class` attrs.

## Seven things to know

**`side` is real, and it floats.** The panel is child `[1]` of an `anchored` node, which draws it in
its own window over the page. It used to be the trigger's neighbour in a `Column` (`:bottom`, `:top`)
or a `Row` (`:right`, `:left`), with `side_offset` as a spacer between them — that was layout, not
floating, so opening pushed every sibling below the popover down the page and `side={:top}` was a
lie: a panel "above" its trigger ate the same vertical space either way. Now it takes no room, it
genuinely sits above or left of its trigger, and no ancestor can clip it, which matters because a
`box` with a `corner_radius` clips and a vertical `scroll` clips its main axis. Positioning is the
web's `positionPopup()` transliterated: `side` and `side_offset`, `align` and `align_offset` across
it, a main-axis flip when the requested side has no room *and* the opposite one does, then a clamp
into the window that keeps 8dp plus the safe-area inset clear of every edge.

**`align` is measured against the trigger, not the parent.** It used to be nearly decorative — the
panel filled its parent, and a filling panel looks identical at every alignment. Both halves hug now,
so `:start`, `:center` and `:end` each place the panel against the trigger's own box. The default is
still `:start` rather than the web's `center`, because the leading edge is where a native dropdown
opens.

**One handler serves the trigger, the hold and the close.** `on_open_change` sends
`{:tap, {tag, next_open?}}` — the state it *wants*, not a bare toggle — so a screen assigns what it
is handed and never has to work out which control was pressed. Nothing closes the panel but you.

**A long press is the hover.** `open_on_hover` has no meaning on a phone, but its intent does:
`open_on_hold={true}` puts the same open on the trigger's long press, the equivalent `context_menu`
already uses for the web's right-click. A hold only ever *opens* — a hover never toggled either —
and the ordinary tap still toggles, so the two do not fight. `delay` and `close_delay` are hover
timings and the system owns how long a press lasts.

**Give it an `id` or a device test has nothing to hold onto.** Every part derives its tag from it,
and the trigger's *state* is folded in — `<id>-trigger-open` / `<id>-trigger-closed` — because the
only other thing that says the panel is up is the trigger's fill, and a device test can read a tag
but not a colour. The panel's presence is its own assertion: `<id>-panel` does not exist while
closed.

**Set the ink whenever you set the fill.** `:on_surface` is the theme's ink for a *theme* surface.
The moment you pass your own `background` it stops being one, and a violet panel keeps near-black
text — so `color` and `muted_color` are props too, and they are the pair to reach for.

**Both halves hug, and that is load-bearing.** The trigger used to fill the width when stacked and
the panel used to fill its parent; neither does now. A full-width trigger makes `align={:end}` mean
"the screen's right edge" instead of "the trigger's" — the web anchors to a content-sized `<button>`
— and a filling panel inside a popup window means the whole SCREEN, after which the clamp pins it to
the leading edge whatever `side` or `align` asked for. Pass `width` when the panel needs a fixed one.
The panel hugs because popover passes `fill_width: false` on the way in — `panel/2` itself still
fills by default, which is how `menu` keeps the shell it always had. Pass `fill_width: true` to get
the old filling panel back.

## Known platform gap

**iOS has no anchored node.** The primitive lives in the Android bridge only; `deps/mob/ios` is a
checksum-locked hex dependency and cannot be edited from this repo. An unknown node type on iOS falls
through to `MobNodeTypeColumn`, so there the popover degrades to the old stacked accordion — trigger
and panel in a Column, the panel taking room rather than drawing over the page, and appearing *below*
the trigger whatever the `side`, because the panel is always child `[1]` now. It neither errors nor
blanks, and every tag stays where a device test expects it. Floating is Android-only for the moment;
`development/mob/IOS_TODO.md` §17 records it.

`modal` is a deliberate omission rather than a gap: the panel's window is sized to the panel, so
there is nothing there to dim the page with, and that window never dismisses itself — no back-press,
no outside tap, because the screen owns `open`. When the page genuinely must be blocked, use `dialog`
or `drawer`, which own the screen root.

## Related
`menu` and `preview_card` (both render through this component's `panel/2` shell), `tooltip` (the
same problem, a hint rather than a panel), `context_menu`, `select`, `drawer`, `dialog`.
