# tooltip (mob)

A short hint about the control it wraps, revealed by a long press. See [README](README.md) for the
rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob tooltip` → `lib/<app>/components/tooltip.ex`, tag `<Tooltip>`. With
`--module-prefix mishka_` it is `<MishkaTooltip>`.

## What it renders

```
anchored  side · align · side_offset · align_offset carried as props
├── box   the trigger — `<id>-trigger`, in flow, hugs its child, carries the hold and the tap
│   └── …    your children
└── box   the hint — `<id>-open`, in its OWN window over the page, tappable to dismiss
    └── text  one line, ellipsised
```

The trigger is child [0] and the bubble child [1] for **every** side — `side` is a prop on the
anchored node, not an ordering trick. Closed, the node has one child: the trigger alone, no window.

With `arrow={true}` the bubble is wrapped in a stacking box aligned to the edge that faces the
trigger:

```
box     hugs the bubble, aligned :bottom_center / :top_center / :trailing / :leading
├── column  the hint, plus a strip the arrow's own depth  ← a ROW for `:left` / `:right`,
│           since the strip has to sit beside the bubble rather than under it
└── canvas  a filled triangle — `<id>-arrow-<side>`
```

Because that box hugs, the triangle centres on the *bubble's* edge — the web's `left: 50%`.

Pass no children and there is nothing to anchor to: you get the bare bubble alone, for a screen that
places its own, and `offset_x` / `offset_y` move it directly.

## Example

```elixir
~MOB"""
<MishkaTooltip
  id="tip-copy"
  text="Copy to clipboard"
  open={@tip == :copy}
  side={:bottom}
  arrow={true}
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
| `side` | `:top` `:bottom` `:left` `:right` | `:top` — strings accepted too; flips when that side has no room |
| `align` | `:start` `:center` `:end` | `:center` |
| `side_offset` | number | `6` — the gap to the trigger, in dp |
| `align_offset` | number | `0` — nudge along the alignment axis; positive pushes *inward* on `:end` |
| `arrow` | boolean | `false` |
| `disabled` | boolean | `false` — never opens, and wires no hold |
| `close_on_tap` | boolean | `true` — tapping the bubble dismisses it |
| `background` | colour token / ARGB int | `0xFF111827` |
| `color` | colour token / ARGB int | `0xFFFFFFFF` |
| `text_size` | size token | `:sm` |
| `offset_x` / `offset_y` | number | `nil` — raw nudge on the bubble, applied last; independent of `align_offset` |
| `fill_width` | boolean | — no longer read |
| `id` | string | `nil` — the stem every part's tag derives from |

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

**`side` places the bubble now; it no longer orders it.** The trigger renders in flow as child [0]
of an `:anchored` node, and the bubble is child [1], drawn in its own window
(`androidx.compose.ui.window.Popup`) over the page. It takes no space, it can sit above or left of
the control it describes, and no rounded box or scroll clips it. Placement is the web's
`positionPopup()` transliterated: `side_offset` off the chosen side, `align_offset` along the cross
axis, a main-axis flip when the requested side has no room and the opposite one does, then a clamp
into the window with 8dp of edge padding plus the safe-area inset. What that replaced: the bubble
used to be the trigger's **sibling** in a `Column` or a `Row`, placed across the side by flexible
spacers — so opening a hint on one icon button shoved the buttons beside it aside, `side={:top}`
only meant "earlier in the stack", and nothing flipped because nothing in flow knows where the edge
is.

**`fill_width` is no longer read.** It was the one prop with no web counterpart: the stack filled its
parent so `align` had spare width to place the bubble in, and you turned it off to fit several
tooltips into one Row, because Compose measures a Row's unweighted children first and a filling
tooltip starved its siblings — a toolbar of three hinted icons rendered as one. Both jobs are gone.
The trigger always hugs the control it wraps, and `align` is arithmetic on the trigger's own measured
box rather than room in a lane. Passing it is harmless, so an old call site does not break; it simply
does nothing.

**Give it an `id` or a device test has nothing to hold onto.** The trigger's tag is `<id>-trigger`
and it is **stable** — unlike `popover`, whose trigger changes appearance when its panel opens, this
one looks identical either way, and a stable tag is what lets a test hold it open *and* closed. The
state lives where it is visible: `<id>-open` exists exactly while the hint does. The arrow's tag
carries the side (`<id>-arrow-top`) because a drawn triangle has no text and no glyph — there is
nothing else about it a device test can read.

**Tapping the hint is the Escape, and `disabled` beats `open`.** The web closes on blur,
pointer-leave or Escape; a phone has none of the three, so `close_on_escape` becomes `close_on_tap`
and the bubble itself is the dismissal. Set it `false` and only a second hold closes the hint. The
bubble's own window will not help you: it has no back-press and no outside tap, deliberately, so it
cannot desynchronise from the assign that produced it. `open` still lives in the screen. `disabled`
switches off the *hint*, not the control: no hold handler is wired, `open={true}` cannot win, and
`on_tap` still fires.

**Set the ink whenever you set the fill.** The default is a hardcoded near-black with white text,
and deliberately so — a hint has to read over *any* surface and there is no theme token for an
inverted one. The moment you pass a `background` of your own that reasoning stops applying, so pass
`color` with it. Reach for a token when one fits (`background={:primary}` with
`color={:on_primary}`); a literal is for the cases where none does.

## Known platform gap

**The anchoring is Android-only.** There is no `:anchored` primitive on iOS, and `deps/mob/ios` is a
checksum-locked hex dependency that cannot be edited from this repo. An unknown node type there falls
through to `MobNodeTypeColumn`, so on iOS a tooltip degrades to what it used to be on both platforms:
the bubble stacked with its trigger, in flow, displacing the page. It neither errors nor blanks.
`development/mob/IOS_TODO.md` §17 records it.

Two older entries land on the bubble itself, so the hint is shaped correctly on Android and stretched
on iOS:

* **`MobBox` never reads `fill_width`** (item 6). The bubble is a Box asking to hug its text; on iOS
  it fills its parent instead, so a hint renders as a full-width bar — and the arrow's stacking Box
  centres its triangle on the screen rather than on the bubble's edge.
* **`max_lines` is never read** by the iOS renderer, so a hint too long for its row wraps there
  instead of ellipsising.

Neither affects the gesture: `on_long_press` is `.onLongPressGesture(minimumDuration: 0.5)` on iOS
and `combinedClickable` on Android, and the arrow is a `Mob.Canvas` path both renderers draw.

A hint is one ellipsised line by design, whichever platform it lands on. When the text needs more
room than that, it is not a tooltip — use `popover`.

## Related
`popover` (the same anchoring, a panel rather than a hint), `context_menu` (the other long-press
component), `action_icon` (the control a tooltip most often wraps), `toast`.
