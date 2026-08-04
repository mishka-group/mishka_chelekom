# tooltip (mob)

A short hint about the control it wraps, revealed by a long press. See [README](README.md) for the
rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob tooltip` → `lib/<app>/components/tooltip.ex`, tag `<Tooltip>`. With
`--module-prefix mishka_` it is `<MishkaTooltip>`.

## What it renders

```
column  fill_width                       (a row instead when side is :left / :right)
├── row     the alignment lane — flexible spacers place the bubble across the side
│   └── box   the hint — `<id>-open`, tappable to dismiss, only while open
│       └── text  one line, ellipsised
├── spacer  side_offset — goes with the bubble, so a closed tooltip reserves nothing
└── box     the trigger — `<id>-trigger`, carries the hold and the control's own tap
    └── …   your children
```

With `side={:top}` or `:left` that sequence runs backwards, so the bubble precedes its trigger.
With `arrow={true}` the bubble is wrapped in a stacking box aligned to the edge that faces the
trigger:

```
box     aligned :bottom_center / :top_center / :trailing / :leading
├── column  the hint, plus a strip the arrow's own depth
└── canvas  a filled triangle — `<id>-arrow-<side>`
```

Pass no children and you get the bare bubble alone, for a screen that places its own.

## Example

```elixir
~MOB"""
<MishkaTooltip
  id="tip-copy"
  text="Copy to clipboard"
  open={@tip == :copy}
  side={:bottom}
  arrow={true}
  fill_width={false}
  on_open_change={{:hold, :copy}}
  on_tap={{:use, :copy}}
>
  <MishkaActionIcon icon="⧉" variant={:filled} />
</MishkaTooltip>
"""

# on_open_change carries the state the tooltip WANTS next, so one clause opens
# and closes — a second hold on the same control puts the hint away.
def handle_info({:tap, {{:hold, which}, open?}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :tip, if(open?, do: which, else: nil))}
end

# The control's own tap lives on the tooltip, not on the ActionIcon.
def handle_info({:tap, {:use, which}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :used, which)}
end
```

## Props

| Prop | Values | Default |
|---|---|---|
| `text` | string | `nil` — the hint |
| `open` | boolean | `false` — the bubble draws nothing when closed |
| `on_open_change` | event tag | — `{:tap, {tag, next_open?}}` |
| `on_tap` | event tag | — the wrapped control's own tap, `{:tap, tag}` |
| `side` | `:top` `:bottom` `:left` `:right` | `:top` — strings accepted too |
| `align` | `:start` `:center` `:end` | `:center` |
| `side_offset` | number | `6` — the gap to the trigger, in dp |
| `align_offset` | number | `0` — nudge along the alignment axis |
| `arrow` | boolean | `false` |
| `disabled` | boolean | `false` — never opens, and wires no hold |
| `close_on_tap` | boolean | `true` — tapping the bubble dismisses it |
| `background` | colour token / ARGB int | `0xFF111827` |
| `color` | colour token / ARGB int | `0xFFFFFFFF` |
| `text_size` | size token | `:sm` |
| `offset_x` / `offset_y` | number | `nil` — raw nudge; adds to `align_offset` |
| `fill_width` | boolean | `true` — turn off to sit several in one Row |
| `id` | string | `nil` — root testTag; every part derives its own from it |

Not ported: `delay`, `close_delay`, `hoverable`, `track_cursor_axis`, `group`, `close_on_escape`,
`trigger_label`, and the `*_class` attrs.

## Eight things to know

**A long press is the hover.** The web reveals a tooltip on pointer-enter or focus, and a phone has
neither — which is why this shipped for a long time as a bubble with no way to summon it. The touch
equivalent is press-and-hold, the gesture the platform already uses for reveal-more and the one
`context_menu` opens on. `delay` and `close_delay` go with the pointer: the system owns how long a
press lasts. So do `hoverable`, `track_cursor_axis` and `group`, which are all descriptions of a
cursor.

**The children are the trigger, not the content.** That is inverted from the web, where the default
slot is the tooltip's content and `<:trigger>` is named. Here the hint is one short string (`text`)
and the trigger is a whole control, so the slot goes to the thing that needs one. Pass no children
and you get the bubble on its own.

**The control's tap belongs on the tooltip.** Compose hands a gesture to the innermost clickable, so
an `action_icon` carrying its own `on_tap` inside a tooltip eats the hold and the hint never opens.
One `combinedClickable` carries both, which is why the trigger owns the tap — put the control's
handler in the tooltip's `on_tap` and leave the control itself inert.

**`side` is real, but it is layout — not floating.** The web positions the bubble from the trigger's
measured rectangle, flips it at the viewport edge and re-anchors on scroll. Nothing in Mob reports a
rendered node's geometry back to `render/1`, so the bubble is simply the trigger's neighbour in a
`Column` (`:top`, `:bottom`) or a `Row` (`:left`, `:right`), with `side_offset` as the gap. Opening
therefore **displaces** the surrounding content instead of drawing over it, and nothing flips
because nothing here knows where the edge is.

**Turn `fill_width` off to put several in one Row.** It is the one prop with no web counterpart.
Compose measures a Row's unweighted children first, in order, so a filling tooltip takes the whole
row and starves its siblings — a toolbar of three hinted icons renders as one. Turning it off also
leaves `align` nothing to align against, which is the honest trade: a stack that hugs its trigger
has no spare width to place a bubble in.

**Give it an `id` or a device test has nothing to hold onto.** The trigger's tag is `<id>-trigger`
and it is **stable** — unlike `popover`, whose trigger changes appearance when its panel opens, this
one looks identical either way, and a stable tag is what lets a test hold it open *and* closed. The
state lives where it is visible: `<id>-open` exists exactly while the hint does. The arrow's tag
carries the side (`<id>-arrow-top`) because a drawn triangle has no text and no glyph — there is
nothing else about it a device test can read.

**Tapping the hint is the Escape, and `disabled` beats `open`.** The web closes on blur,
pointer-leave or Escape; a phone has none of the three, so `close_on_escape` becomes `close_on_tap`
and the bubble itself is the dismissal. Set it `false` and only a second hold closes the hint.
`disabled` switches off the *hint*, not the control: no hold handler is wired, `open={true}` cannot
win, and `on_tap` still fires.

**Set the ink whenever you set the fill.** The default is a hardcoded near-black with white text,
and deliberately so — a hint has to read over *any* surface and there is no theme token for an
inverted one. The moment you pass a `background` of your own that reasoning stops applying, so pass
`color` with it. Reach for a token when one fits (`background={:primary}` with
`color={:on_primary}`); a literal is for the cases where none does.

## Known platform gap

Two entries in `development/mob/IOS_TODO.md` land on this component, so the bubble is shaped
correctly on Android and stretched on iOS:

* **`MobBox` never reads `fill_width`** (item 6). The bubble is a Box asking to hug its text; on iOS
  it fills its parent instead, so a hint renders as a full-width bar. That also leaves `align`
  nothing to place — the bubble is already as wide as the lane — and the arrow's stacking Box
  centres its triangle on the screen rather than on the bubble's edge.
* **`max_lines` is never read** by the iOS renderer, so a hint too long for its row wraps there
  instead of ellipsising.

Neither is specific to the tooltip and neither affects the gesture: `on_long_press` is
`.onLongPressGesture(minimumDuration: 0.5)` on iOS and `combinedClickable` on Android, and the arrow
is a `Mob.Canvas` path both renderers draw.

What is not an iOS gap but a layering one on both platforms: a bubble in flow cannot float over the
page, so a tooltip near the bottom of a scroll pushes rather than overlaps. When the hint is long
enough that this matters, it is not a tooltip — use `popover`.

## Related
`popover` (the same placement problem, a panel rather than a hint), `context_menu` (the other
long-press component), `action_icon` (the control a tooltip most often wraps), `toast`.
