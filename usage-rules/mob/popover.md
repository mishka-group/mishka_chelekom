# popover (mob)

A trigger that toggles a panel of content beside it. See [README](README.md) for the rules every
Mob component shares.

## Generate
`mix mishka.ui.gen.mob popover` → `lib/<app>/components/popover.ex`, tag `<Popover>` plus its slot
tags. With `--module-prefix mishka_` they are `<MishkaPopover>`, `<MishkaPopoverTrigger>`, and so on.

## What it renders

```
column  fill_width, carries `id`          (a row instead when side is :left / :right)
├── box    the trigger — `<id>-trigger-open` / `<id>-trigger-closed`, tappable
├── spacer side_offset
├── text   the beak, when arrow — `<id>-arrow`
└── box    the panel — `<id>-panel`, only while open
    ├── text  `<id>-title`
    ├── text  `<id>-desc`
    ├── …     your children
    └── row   the footer — `<id>-close`, right-aligned
```

With `side={:top}` or `:left` the same sequence runs backwards, so the panel precedes its trigger.
Closed, only the trigger renders; with no `trigger` at all, only the panel.

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
| `side` | `:top` `:right` `:bottom` `:left` | `:bottom` |
| `align` | `:start` `:center` `:end` | `:start` |
| `side_offset` | number | `8` — the gap, in dp |
| `align_offset` | number | `nil` — nudge along the alignment axis |
| `title` / `description` | string | `nil` |
| `close` | string | `nil` — label for a footer action that reports it closed |
| `arrow` | boolean | `false` |
| `width` | number | `nil` — panel width; omit to fill the parent |
| `background` | colour token / ARGB int | `:surface` |
| `color` / `muted_color` | colour token / ARGB int | `:on_surface` / `:muted` |
| `corner_radius` · `padding` | radius / spacing | `:radius_md` · `:space_md` |
| `border_color` / `border_width` | colour / number | `:border` / `1` |
| `offset_x` / `offset_y` | number | `nil` — raw nudge; wins over `align_offset` |

Helpers: `panel/2` (the bare shell), `trigger_id/2`, `panel_id/1`, `title_id/1`,
`description_id/1`, `close_id/1`, `arrow_id/1`.

Not ported: `modal` and its backdrop, `dismissible`, `close_on_escape`, `initial_focus` /
`final_focus`, `labelledby` / `describedby`, `open_on_hover` / `delay` / `close_delay`, and the
`*_class` attrs.

## Seven things to know

**`side` is real, but it is layout — not floating.** The web positions the panel from the trigger's
measured rectangle and flips it at the viewport edge. Nothing in Mob reports a rendered node's
geometry back to `render/1`, so instead the panel is simply the trigger's neighbour in a `Column`
(`:bottom`, `:top`) or a `Row` (`:right`, `:left`), with `side_offset` as the gap. It **takes room**
rather than drawing over the page, and nothing flips, because nothing here knows where the edge is.
That is how native dropdowns are built anyway.

**`align` only bites once `width` does.** A panel that fills its parent looks identical at every
alignment, so `align` is for the narrow ones — and it defaults to `:start`, not the web's `center`,
because the leading edge is where a native dropdown opens and there is no measured trigger box to
centre on.

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

**Beside a trigger, the trigger hugs and the panel is weighted.** Compose measures a `Row`'s
unweighted children first, in order, so a filling trigger would take the whole row and starve the
panel to nothing. With `side={:left}` / `:right` the trigger is set to `fill_width={false}` and the
panel goes in a `weight: 1` box. Stacked sides are unaffected — both fill.

## Known platform gap

Two entries in `development/mob/IOS_TODO.md` land on the abreast layout, so `side={:left}` and
`side={:right}` are Android-only for now:

* **`MobBox` never reads `fill_width`** (item 6), so the hugging trigger stretches on iOS.
* **`weight` is read nowhere in the iOS renderer** (item 13), so the panel's `weight: 1` box and the
  `Spacer weight={1}` that pushes the chevron and the close button to the trailing edge all fall
  back to intrinsic sizes.

Neither affects `:top` / `:bottom`, which is what a phone-width layout wants regardless.

The `modal` backdrop is not an iOS gap but a layering one on both platforms: a panel in flow cannot
dim the page behind it. When the page genuinely must be blocked, use `dialog` or `drawer`, which own
the screen root.

## Related
`menu` and `preview_card` (both render through this component's `panel/2` shell), `tooltip` (the
same problem, a hint rather than a panel), `context_menu`, `select`, `drawer`, `dialog`.
