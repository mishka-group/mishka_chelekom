# preview_card (mob)

A trigger you hold, and the card of detail it reveals. See [README](README.md) for the rules every
Mob component shares.

## Generate
`mix mishka.ui.gen.mob preview_card` → `lib/<app>/components/preview_card.ex`, tag `<PreviewCard>`.
With `--module-prefix mishka_` it is `<MishkaPreviewCard>`.

## What it renders

The trigger, always. Then, when `open`, a gap, an optional arrow, and a `popover` panel holding an
avatar, a title, a subtitle, a description and a footer — every part optional. Closed, it is the
trigger and **nothing else**; with no trigger it is the panel alone.

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
| `open` | boolean | `false` — the panel draws nothing when closed |
| `trigger` | node / [node] | `nil` — the trigger slot as data. Omit it *and* the tag, and only the panel renders |
| `on_hold` | event tag | — `{:tap, {tag, id}}` on a long press |
| `on_tap` | event tag | — `{:tap, {tag, id}}` on a plain tap |
| `side` | `:bottom` `:top` `:left` `:right` | `:bottom` |
| `align` | `:start` `:center` `:end` | `:center` |
| `side_offset` / `align_offset` | number | `8` / `0` |
| `arrow` / `arrow_color` | boolean / colour token | `false` / `:border` |
| `title` / `subtitle` / `description` | string | `nil` |
| `initials` / `image` | string | `nil` — omit both and there is no avatar |
| `avatar_color` | colour token / ARGB int | `:primary` |

Everything `popover` accepts is forwarded (`width`, `background`, `corner_radius`, `padding`,
`border_*`, `offset_x`, `offset_y`).

## Six things to know

**A long press is the hover.** The web reveals this on pointer-enter; a phone has no pointer, and the
gesture that stands in for hover on a touch screen is a hold. It is registered on both platforms
(`Mob.Renderer`'s `on_long_press`, `.onLongPressGesture` on iOS, `combinedClickable` on Android), so
the trigger is a real part here and not a caller's invention. This port shipped without one, which
is what made `id`, `side` and `align` look unportable.

**A tap is not a hold, and they are separate props.** `on_tap` fires on an ordinary tap and `on_hold`
on the press — the web's trigger is usually a link, and tapping a link should still follow it. One
repurposed handler would have made the two indistinguishable.

**The card owns no state.** `on_hold` *asks* for a change and reports `{:tap, {tag, id}}`; the screen
decides. Holding the open one again closes it, and with one `open` assign holding another moves the
card rather than opening a second. Nothing else closes it — there is no pointer to move away from
and no Escape (see below), so if a card can be opened it must also be closable.

**`side` is an order and an axis, not an anchor.** There is still no measured positioning — see
`popover`, whose moduledoc explains why a render function cannot obtain its trigger's rectangle.
But with the trigger *inside* the component, `:bottom` / `:top` are a Column with the panel after or
before it, and `:left` / `:right` are a Row. On the horizontal axis **both** halves carry a weight —
an unweighted Box fills its parent and Compose measures a Row's unweighted children first, so
whichever half went unweighted would take the whole row. That also means roughly half the width
each, which on a phone is cramped: reach for `:bottom`.

**`align` moves the arrow, and only the arrow.** The panel spans its container, so alignment has
nothing else to act on. With `arrow={false}` it has no visible effect at all — and `align_offset`
nudges the arrow, not the card.

**`id` is the testTag root as well as the event value.** A device test can read neither a colour, nor
a glyph, nor a position, so every state that has no text is folded into a tag:

| Tag | What it says |
|---|---|
| `<id>-open` / `<id>-closed` | the web's `data-open` / `data-closed` |
| `<id>-trigger` | the thing to hold — **stable**, because a tag that changed with the state could not be found in order to change it |
| `<id>-popup-<side>` | the panel, and which side it took |
| `<id>-arrow-<align>` | the arrow, and where along the edge it sits |
| `<id>-title` `<id>-subtitle` `<id>-description` `<id>-avatar` `<id>-footer` | the parts |

## Known platform gap

**There is no hover, so `delay` and `close_delay` have nothing to delay.** They exist on the web to
stop a card flickering as the pointer crosses the trigger. A long press already has a hold time of
its own, set by the platform, and a second timer on top of it would only make the gesture feel
broken.

**There is no Escape, and the back gesture is not yours.** `close_on_escape` has no native
counterpart: iOS has no back gesture, and on Android `Mob.Screen.handle_info/2` intercepts
`{:mob, :back}` before the screen's own clauses and pops the nav stack. A component cannot claim it.
So always leave a way out — the hold that opened the card should close it.

**Anchored positioning, edge-flip and the viewport clamp do not port.** The web repositions the
popup on scroll and resize against a measured trigger rectangle; Mob feeds no geometry back into
`render/1`. `side` gets you the order and the axis, and that is the whole of it.

**On iOS the horizontal sides split unevenly.** SwiftUI has no layout weight, so `:left` / `:right`
give the panel its natural fill and squeeze the trigger. The arrow's `align` is fine on both — it
uses flexible spacers, which map to a plain SwiftUI `Spacer()`.

**The arrow is a glyph, not a drawn triangle.** `Mob.Canvas` could draw one, but a canvas must never
be declared wider than the space it is given, and a text glyph scales with the theme and needs no
declared size. It is coloured with a token like everything else — never hardcode an ink.

## Related
`popover` (the panel surface this builds on), `context_menu` (the other long-press component —
same gesture, different payload), `tooltip`, `avatar` (the header's picture), `scroller` (shares
this component's gallery page).
