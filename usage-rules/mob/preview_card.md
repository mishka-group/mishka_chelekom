# preview_card (mob)

A trigger you hold, and the card of detail it reveals. See [README](README.md) for the rules every
Mob component shares.

## Generate
`mix mishka.ui.gen.mob preview_card` → `lib/<app>/components/preview_card.ex`, tag `<PreviewCard>`.
With `--module-prefix mishka_` it is `<MishkaPreviewCard>`.

## What it renders

```
column  fill_width, carries `id`         — `<id>-open` / `<id>-closed`
└── anchored   side · align · side_offset
    ├── box    the trigger — `<id>-trigger`, tappable, IN FLOW, hugs its content
    └── box    the card — `<id>-popup-<side>`, in its OWN WINDOW over the page
        ├── row   avatar + title + subtitle
        ├── text  the description
        └── row   the footer — `<id>-footer`
```

Every part of the card is optional. With `arrow={true}` the glyph and the card are wrapped together
as the anchored node's second child — a Column for `:bottom` / `:top`, a Row for `:left` / `:right`,
the arrow leading on `:bottom` / `:right` and trailing on `:top` / `:left`.

Closed, the anchored node holds the trigger alone: no window, no card. With **no trigger at all**
there is nothing to anchor to, so the card renders in flow, where you put it.

## Example

```elixir
~MOB"""
<MishkaPreviewCard
  id="elixir"
  open={@preview == "elixir"}
  on_hold={:preview}
  on_tap={:visit}
  arrow={true}
  title="Elixir"
  subtitle="@elixir-lang"
  initials="EX"
  description="A dynamic, functional language."
>
  <MishkaPreviewCardTrigger>
    {name_chip("Elixir")}
  </MishkaPreviewCardTrigger>
  {[follow_button()]}
</MishkaPreviewCard>
"""

# A hold ASKS for a change; the screen decides what it means. Holding the open
# one closes it and holding another moves the card, so one assign is one card.
def handle_info({:tap, {:preview, id}}, socket) do
  next = if socket.assigns.preview == id, do: nil, else: id
  {:noreply, Mob.Socket.assign(socket, :preview, next)}
end

# The tap the long press did NOT swallow — the web trigger is a link.
def handle_info({:tap, {:visit, id}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :visited, id)}
end
```

## Slots

| Slot | Web | What it takes |
|---|---|---|
| `<MishkaPreviewCardTrigger>` | `<:trigger>` | the nodes you hold. No props of its own — `on_hold`, `on_tap` and the `<id>-trigger` tag are the card's |
| bare children | `<:inner_block>` | the footer, which is where actions belong |

The web's `<:arrow>` slot is not a slot here: the arrow is a glyph the component draws itself, switched
on with `arrow={true}` and coloured with `arrow_color`.

**When the function form is still right.** The `trigger` prop takes the same nodes as data, and both
forms reach the same `trigger/3` and build the identical tree. Use the tag when you are writing a card
out by hand; use the prop when a list comprehension is doing the writing and there is no markup to
hang a tag in:

```elixir
Enum.map(@people, fn {id, name} ->
  preview_card(%{id: id, open: @preview == id, trigger: name_chip(name), on_hold: :preview})
end)
```

`trigger/3` is public for the third case — a trigger that has to live somewhere the card cannot reach,
such as a list row with the card rendered at the foot of the screen.

## Props

| Prop | Values | Default |
|---|---|---|
| `id` | string | `nil` — testTag root, **and** the value the trigger events carry |
| `open` | boolean | `false` — the card draws nothing when closed |
| `trigger` | node / [node] | `nil` — the trigger slot as data. Omit it *and* the tag, and the card renders in flow |
| `on_hold` | event tag | — `{:tap, {tag, id}}` on a long press |
| `on_tap` | event tag | — `{:tap, {tag, id}}` on a plain tap |
| `side` | `:bottom` `:top` `:left` `:right` | `:bottom` — which side of the trigger the card takes; flips when that side has no room |
| `align` | `:start` `:center` `:end` | `:center` — where it sits across that axis, from the trigger's own edge |
| `side_offset` | number | `8` — the gap between trigger and card, in dp |
| `align_offset` | number | `0` — nudges the **arrow** along the card's edge. It does not move the card |
| `arrow` / `arrow_color` | boolean / colour token | `false` / `:border` |
| `title` / `subtitle` / `description` | string | `nil` |
| `initials` / `image` | string | `nil` — omit both and there is no avatar |
| `avatar_color` | colour token / ARGB int | `:primary` |

Everything `popover` accepts is forwarded (`width`, `background`, `corner_radius`, `padding`,
`border_*`, `offset_x`, `offset_y`, `fill_width`).

## Seven things to know

**A long press is the hover.** The web reveals this on pointer-enter; a phone has no pointer, and the
gesture that stands in for hover on a touch screen is a hold. It is registered on both platforms
(`Mob.Renderer`'s `on_long_press`, `.onLongPressGesture` on iOS, `combinedClickable` on Android), so
the trigger is a real part here and not a caller's invention. This port shipped without one, which
is what made `id`, `side` and `align` look unportable.

**A tap is not a hold, and they are separate props.** `on_tap` fires on an ordinary tap and `on_hold`
on the press — the web's trigger is usually a link, and tapping a link should still follow it. One
repurposed handler would have made the two indistinguishable.

**The card floats over the page.** It used to be the trigger's sibling in a Column (`:bottom`, `:top`)
or a Row (`:left`, `:right`), which meant opening one pushed everything below it down the page and
`side={:top}` was a lie — a card "above" its trigger still ate the same vertical space. The two are an
`:anchored` pair now: the trigger renders in flow, the card renders in **its own window**. So the card
takes no room, it can genuinely sit above or beside its trigger, and no ancestor clips it — which is
what this is for, since a Box with a `corner_radius` clips and a vertical Scroll clips its main axis,
and a card is nearly always inside both.

**`side` and `align` are measured now, not ordered.** They are the web's `positionPopup()`
transliterated against the trigger's real rectangle: `side` picks the side, `align` places the card
across that axis from the trigger's own edge, `side_offset` is the gap. When the requested side has no
room and the opposite one does, the card flips to it — the main axis only, never `align`, exactly as
the web flips. Then it is clamped into the window regardless, keeping 8dp plus the safe-area inset
clear of every edge, so a card near a corner is moved rather than half cut off. The root is a Column
whatever the side, and **nothing is weighted any more**: the two halves no longer share a line, so the
old "both parts carry a weight or one starves the other" rule has nothing left to apply to.

**Both halves hug, and both used to fill.** The trigger hugs its content on every side — it filled the
width when it was stacked, but anchored to a full-width trigger `align={:end}` would mean the screen's
right edge instead of the trigger's, and the web anchors to a content-sized `<button>`. The card hugs
too: inside a popup window "fill" is the whole SCREEN, after which the clamp pins the card to the
leading edge whatever `side` and `align` asked for. Set `width` for a fixed card, or `fill_width={true}`
if you want the old filling one back.

**`align_offset` moves the arrow, and only the arrow.** It nudges the glyph along the card's facing
edge, which is what it did before the card was anchored — it is not the card's own offset, and with
`arrow={false}` it has no visible effect at all. To move the card, use `side_offset` and `align`.

**`id` is the testTag root as well as the event value.** A device test can read neither a colour, nor
a glyph, nor a position, so every state that has no text is folded into a tag:

| Tag | What it says |
|---|---|
| `<id>-open` / `<id>-closed` | the web's `data-open` / `data-closed` |
| `<id>-trigger` | the thing to hold — **stable**, because a tag that changed with the state could not be found in order to change it |
| `<id>-popup-<side>` | the card, and which side it asked for |
| `<id>-arrow-<align>` | the arrow, and where along the edge it sits |
| `<id>-title` `<id>-subtitle` `<id>-description` `<id>-avatar` `<id>-footer` | the parts |

Because `side` and `align` are what the card *requested*, a flip or a clamp can land it elsewhere on a
cramped screen. The tag is the request, not the outcome.

## Known platform gap

**The card only floats on Android.** The `:anchored` node is rendered by `MobAnchored` in the Android
bridge, over `androidx.compose.ui.window.Popup`. iOS has no anchored primitive, and `deps/mob/ios` is a
checksum-locked hex dependency that cannot be edited from this repo. An unknown node type falls through
to `MobNodeTypeColumn` there, so the card degrades to the old stacked accordion — it neither errors nor
blanks, but it takes room in the page, and because it stacks in child order it lands after the trigger
whatever `side` says. `development/mob/IOS_TODO.md` §17 records it.

**There is no hover, so `delay` and `close_delay` have nothing to delay.** They exist on the web to
stop a card flickering as the pointer crosses the trigger. A long press already has a hold time of
its own, set by the platform, and a second timer on top of it would only make the gesture feel
broken.

**Nothing closes the card but you.** The card's window is created with back-press and outside-tap
dismissal switched **off**, deliberately: a window that closed itself would leave `open` true on the
screen that drew it, and the tree would no longer match the assign. `close_on_escape` has no native
counterpart either — iOS has no back gesture, and on Android `Mob.Screen.handle_info/2` intercepts
`{:mob, :back}` before the screen's own clauses and pops the nav stack. So always leave a way out: the
hold that opened the card should close it.

**The arrow is a glyph, not a drawn triangle.** `Mob.Canvas` could draw one, but a canvas must never
be declared wider than the space it is given, and a text glyph scales with the theme and needs no
declared size. It is coloured with a token like everything else — never hardcode an ink.

## Related
`popover` (the panel surface this builds on, and anchored the same way), `context_menu` (the other
long-press component — same gesture, different payload), `tooltip`, `avatar` (the header's picture),
`scroller` (shares this component's gallery page).
