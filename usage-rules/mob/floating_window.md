# floating_window (mob)

A titled panel that floats over a stage and is dragged by its title bar. See [README](README.md)
for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob floating_window` → `lib/<app>/components/floating_window.ex`, tag
`<FloatingWindow>`. With `--module-prefix mishka_` it is `<MishkaFloatingWindow>`.

## What it renders

One `Box` — a z-stack on both platforms — the size of the stage, holding three layers:

```
box   the stage, sized to `bounds`, carries `id`
├── box      the panel     background, border, and the 48dp title strip. NO handlers.
├── canvas   the drag surface   the whole stage, transparent, carries on_drag
└── box…     the controls  the body, the ✕, the four arrows — each at its own offset
```

The order is the design. Anything a finger must **tap** has to be above the canvas: the canvas
consumes the touch that starts on it, and on iOS a view with a background blocks the gesture of
the sibling beneath it. Anything the **drag** must reach has to be below it — which is why the
title strip and its label carry no handlers, and why the ✕ is the only thing in the bar that does
not begin a drag.

## Example

```elixir
~MOB"""
<MishkaFloatingWindow
  x={@x}
  y={@y}
  bounds={{240, 200}}
  width={160}
  height={100}
  label="Inspector"
  dragging={@grab != nil}
  on_move={:move}
  id="win"
>
  {[readout()]}
</MishkaFloatingWindow>
"""

# One prop, two events. The drag arrives as a payload; an arrow arrives as a tap.
def handle_info({:drag, :move, payload}, socket) do
  {position, grab} = MishkaFloatingWindow.drag(payload, socket.assigns.grab, window(socket.assigns))

  {:noreply, socket |> assign(:pos, position) |> assign(:grab, grab)}
end

def handle_info({:tap, {:move, direction}}, socket) do
  {:noreply, assign(socket, :pos, MishkaFloatingWindow.nudge(window(socket.assigns), direction))}
end

# The window's props, in ONE place: the folds clamp and hit-test against them,
# so they have to be the props it was actually drawn with.
defp window(assigns) do
  {x, y} = assigns.pos
  [x: x, y: y, width: 160, height: 100, bounds: {240, 200}, step: 20]
end
```

`grab` starts as `nil` and returns to `nil` when the finger lifts. Keep it in an assign.

## Props

| Prop | Values | Default |
|---|---|---|
| `x` / `y` | number | `0` — position inside the stage |
| `width` / `height` | number | `260` / `180` — a fixed rectangle |
| `bounds` | `{w, h}` | `nil` — the stage in dp. **No bounds, no drag** |
| `step` | number | `20` — how far one arrow tap moves it |
| `label` | string | `nil` — the title |
| `handle` | node(s) | `nil` — title-bar content instead of `label` |
| `dragging` | boolean | `false` — the web's `data-dragging` |
| `show_nudges` | boolean | `true` — the arrow row, when `on_move` is set |
| `on_move` | event tag | — `{:drag, tag, payload}` **and** `{:tap, {tag, :up}}` |
| `on_close` | event tag | — `{:tap, tag}` on the ✕ |
| `id` | string | `nil` — `<id>-window`, `-handle` / `-handle-dragging`, `-drag`, `-body`, `-close`, `-nudge-up` |

Children are the body.

Helpers: `drag/3`, `nudge/2`, `chrome_height/1`, `part_id/2`, `handle_id/2`.

Not ported: `handle_label` (Mob exposes no accessibility semantics to hang a role or a label on),
`class` / `handle_class` / `body_class` (no CSS), and Shift+Arrow's 1px step — there are no
modifier keys on a touch screen, so `step` is the one increment.

## Seven things to know

**It really does drag.** This component shipped saying "Mob delivers no pointer coordinates to
`render/1`, so the drag cannot be ported". That was false: `Mob.Renderer` registers `on_drag`
beside `on_tap` and several components already use it. What is true is that **only a `:canvas`
carries `on_drag`**, which is why the drag surface is a canvas and why the node is built as a
literal map — `Mob.UI.canvas/1` is `Map.take(props, [:width, :height, :draw])` and silently drops
every handler.

**The drag surface is static, and that is not an implementation detail.** A canvas reports
coordinates local to *itself*, so a canvas that travels with the window is a ruler sliding under
the finger: the window moves, the canvas moves with it, the next sample reads the same local `x`,
and the window creeps a fraction of the gesture. `splitter` measured exactly that — 10dp of travel
for a 60dp drag, with provably correct arithmetic. Hence one canvas, the size of the stage, that
never moves.

**`bounds` is the stage, and it must be the truth.** It sizes the canvas, and a canvas declared
wider than the space it gets has `MobCanvas` scale its ops to fit — after which every coordinate
it reports is in a different unit from the dp the window is positioned with, and the title bar is
somewhere other than where the fold thinks it is. Give the window a parent at least `bounds` big.
Without `bounds` there is no canvas at all, and the arrows are the only way to move it.

**Use `x`/`y`, never `dx`/`dy`.** On iOS those are cumulative translation; on Android they are
per-sample deltas. Anything built on them behaves differently on each platform. `drag/3` reads
only `x`/`y`, and `phase` arrives as an **atom** (`:began` / `:dragging` / `:ended`) — comparing it
against `"began"` matches nothing, the anchor is never set, and the window looks completely dead
while the arithmetic is fine. Both bridges fire `began` on touch-down rather than after touch
slop, so a bare tap on the bar is a zero-length drag: `dragging` blinks true and back, and the
window lands exactly where it was.

**The window is a fixed rectangle.** `width` by `height`, a 48dp title bar, and a 48dp arrow row
when `on_move` is set. The controls are placed by arithmetic rather than by layout, because that
is what lets `drag/3` decide whether a touch landed on the handle without asking the native side to
measure anything. `chrome_height/1` is that arithmetic if you need it; content taller than
`height` minus the chrome simply overflows.

**The clamp is the stage minus the window.** Both folds stop the window with its far edge against
the stage's, rather than letting it walk half out of view. That is why `nudge/2` takes the whole
prop map: `step` and `bounds` used to be documented props that nothing read, so a caller who set
them got the defaults and no complaint.

**`id` is the only handle a device test has.** A drag surface is a drawing and an arrow is a
glyph — neither carries text to query. State that shows only as colour is appended to the tag the
way `menu` does it: the title strip is `<id>-handle` when idle and `<id>-handle-dragging` while
held, mirroring the web's `data-dragging`.

## Known platform gap

**Nothing you stack over the stage yourself will take a tap.** The drag surface covers the whole
stage, so every control has to be lifted above it. The component lifts the ones it owns — the ✕,
the arrows, and the body — but a sibling you place in the same stage *beside* the window sits
under the canvas and receives nothing. Put such controls next to the stage rather than on it, or
leave `on_move` unset and there is no canvas to get in the way.

**A custom `handle` is decoration only.** It renders in layer 1, under the drag surface, so the
whole bar stays draggable — which also means a button inside it cannot be tapped. `on_close` is
the one control the bar supports.

**The title bar is not announced, on either platform.** `handle_label` and
`aria-roledescription="draggable window handle"` have nowhere to go: Mob exposes no accessibility
semantics to Compose or to SwiftUI, so a screen reader finds an unlabelled drawing. The arrows are
the mitigation the web offers for the same reason, which is why `show_nudges` defaults to `true`.

**iOS ignores `max_lines`, so a long `label` wraps instead of truncating** — and the strip is a
fixed 48dp that does not grow, so the second line spills over the body instead of pushing the bar
taller. Keep titles short, or pass a `handle` node sized the way you want it.

**No modifier keys, so no fine step.** The web moves 10px per arrow and 1px with Shift; here
`step` is the single increment, and 20dp is the default because a thumb is not a caret.

## Related
`splitter` (the same static-canvas drag, dividing two panes), `dialog` / `drawer` (panels the
platform positions for you), `popover`, `floating_indicator`.
