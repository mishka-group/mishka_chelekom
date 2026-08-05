# drawer (mob)

An edge-anchored panel over a dimmed backdrop, with a drag handle, snap points and
swipe-to-dismiss. See [README](README.md) for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob drawer` → `lib/<app>/components/drawer.ex`, tag `<Drawer>`.
With `--module-prefix mishka_` it is `<MishkaDrawer>`.

## What it renders

While `open`, a full-screen `box` — the single stacking primitive on both platforms — holding the
backdrop and the panel. While closed, **nothing at all**, unless `swipe_area` is on:

```
box       the overlay, carries `id`         (open only)
├── box   the scrim, carries `<id>-scrim`   dismisses on tap
└── row   the positioner
    ├── spacer weight={1}                   pushes the panel to its edge
    └── box  the panel, `<id>-panel`        the handle, the header, then your children
```

Put it in the screen's root `box`, alongside your page content — a composite cannot portal itself
anywhere.

## Example

```elixir
~MOB"""
<Box fill_width={true} fill_height={true}>
  {page(assigns)}
  {MishkaDrawer.trigger("Filters", on_open: :open_sheet, test_id: "filters")}

  <MishkaDrawer
    id="sheet"
    open={@sheet_open?}
    side={:bottom}
    handle={true}
    snap_points={[180, 300, 440]}
    snap={@snap}
    title="Filters"
    on_swipe={:sheet}
    on_close={:close_sheet}
  >
    {rows(assigns)}
  </MishkaDrawer>
</Box>
"""

def handle_info({:tap, :open_sheet}, socket),  do: {:noreply, assign(socket, :sheet_open?, true)}
def handle_info({:tap, :close_sheet}, socket), do: {:noreply, assign(socket, :sheet_open?, false)}

# The handle is a canvas, so the gesture arrives as {:drag, tag, payload} and the
# SCREEN folds it — a composite has no state to fold it in.
def handle_info({:drag, :sheet, payload}, socket) do
  {sheet, grab} =
    MishkaDrawer.swipe(payload, socket.assigns.grab,
      side: :bottom,
      snap_points: [180, 300, 440],
      open: socket.assigns.sheet_open?,
      snap: socket.assigns.snap
    )

  {:noreply,
   socket
   |> assign(:sheet_open?, sheet.open?)
   |> assign(:snap, sheet.snap)
   |> assign(:grab, grab)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

`grab` starts as `nil` and returns to `nil` when the gesture ends. Keep it in an assign.

## Props

| Prop | Values | Default |
|---|---|---|
| `open` | boolean | `false` — the drawer draws nothing when closed |
| `id` | string | `nil` — the test tag every part hangs off |
| `side` | `:left` `:right` `:top` `:bottom` | `:right` |
| `size` | `:xs` `:sm` `:md` `:lg` `:xl` | `:lg` — panel width, 240–384dp. Left/right only |
| `title` / `description` | string | `nil` — the built-in header |
| `header` | boolean | `true` — false drops the title, description and ✕ |
| `handle` | boolean | `false` — the drag pill, and the only swipe surface |
| `handle_color` | ARGB **int** | grey — canvas ops take ints, not tokens |
| `scrim` | boolean | `true` — false is the web's `modal={false}` |
| `scrim_color` | colour token / ARGB int | `0x99000000` |
| `dismissible` | boolean | `true` — false leaves the backdrop blocking but inert |
| `background` / `padding` / `corner_radius` | token or number | `:surface` / `:space_lg` / none |
| `snap_points` | list | `[]` — sheet heights in dp, or fractions of `extent` |
| `snap` / `extent` | number | smallest point / `nil` |
| `snap_sequential` | boolean | `false` — one point per flick |
| `threshold` | number | `64` — dp of travel before a swipe counts |
| `swipe_direction` | `:up` `:down` `:left` `:right` | from `side` |
| `swipe_area` | boolean | `false` — a drag patch on the edge while closed |
| `on_close` | event tag | — `{:tap, tag}` from the backdrop and the ✕ |
| `on_swipe` | event tag | — `{:drag, tag, payload}` from the handle and the swipe area |

Helpers: `trigger/2`, `swipe/3`, `snap_heights/1`, `snap_index/1`, `dismiss_direction/1`.

Test tags, given `id="sheet"`: `sheet` (present only while open), `sheet-scrim`, `sheet-panel`,
`sheet-title`, `sheet-description`, `sheet-close`, `sheet-handle`, `sheet-swipe-area`, and
`sheet-snap-<n>` for the active snap point.

Not ported: focus trapping and `modal="trap-focus"`, the iOS-style page indent behind an open
drawer, the `aria-*` wiring, and the `*_class` attrs.

## Seven things to know

**The trigger and the open state are yours.** The web renders its `<:trigger>` inside the drawer's
own markup; here `trigger/2` returns an ordinary node you place where you want it, and the screen
owns `open`. That is also what lets one drawer be opened from three places.

**`handle` is not decoration — it is the swipe surface.** `on_drag` is a registered Mob handler but
**only a `:canvas` carries it**, so the pill is a canvas and there is nothing to swipe without it.
A drawer with `on_swipe` and no `handle` renders correctly and never moves once open.

**The panel does not follow the finger; it settles when you lift it.** A canvas reports
*canvas-local* coordinates, so redrawing the sheet at a new height on every sample would slide the
handle under the finger — a ruler moving along with what it measures, which collapses the gesture
into a fraction of its travel. Nothing moves mid-gesture, so `swipe/3` anchors on the `began` phase
and the arithmetic is exact. Mob has no animation either, so there would be nothing to interpolate.

**Snap points are dp, not fractions of the viewport.** A composite cannot measure the screen, so
either give heights in dp or give fractions plus an `extent` saying what they are fractions of. A
fraction with no `extent` is dropped and logged rather than rendering a 0.4dp sheet. They apply to
`:top`/`:bottom` only, exactly as on the web.

**`dismissible: false` keeps the backdrop, and the backdrop keeps absorbing.** It only governs the
outside tap — the ✕ still closes. The inert backdrop still needs its tap handler, because a filled
`Box` with none gets no hit-test shape natively and every tap would fall through to the page behind
a supposedly modal panel. Give a non-dismissible drawer its own way out; there is no Escape here.

**One fold serves both directions.** `swipe/3` reads `open:` from the props you hand it: while the
drawer is open a drag toward its edge dismisses, and while it is closed the same payload is coming
from the `swipe_area` patch, where a drag *inwards* opens. Pass the current `open?` or the gesture
will run the wrong way.

**Use `x`/`y`, never `dx`/`dy`.** On iOS those are cumulative translation; on Android they are
per-sample deltas, so anything built on them behaves differently per platform. `swipe/3` reads only
`x`/`y`, and `phase` arrives as an **atom** (`:began` / `:dragging` / `:ended`).

## Known platform gap

**Escape has no equivalent, on either platform.** `close_on_escape` is not ported: a phone's Escape
is the system back gesture, and `Mob.Screen` intercepts `{:mob, :back}` before any screen's
`handle_info/2` to pop the navigation stack. Back therefore closes the whole screen, drawer and
all, and a drawer cannot claim it.

**`swipe_area` is a patch, not the whole edge.** It is 16dp across and 320dp along, centred on the
drawer's edge, because a canvas must declare its size in dp and the screen's size is not knowable
from Elixir — an over-declared canvas scales its coordinates instead of clipping. It also
intercepts touches inside its own bounds (that is what it is for), so it will not scroll a page
under it, and on an Android device using gesture navigation the system's own back swipe owns the
same strip. Treat it as a second way in, never the only one.

**iOS does not round a `:top`/`:bottom` sheet.** `corner_radius` clips on a Compose `Column` and on
a `Box` on both platforms, but a SwiftUI `VStack` does not — and a full-width sheet has to be a
Column, because a Compose `Box` wraps its content and collapses the sheet to content width. Side
drawers round on both.

**The overlay sits inside the top safe-area inset.** Mob opts no node out of it, so a panel starts
just below the status bar rather than under it. That is ordinary mobile drawer behaviour, not a
layout bug to chase.

## Related
`dialog` / `alert_dialog` (the same overlay, centred and without the gestures), `menu` (rows to put
inside one), `popover`, `scroll_area` (wrap a snapped sheet's body in one when the content is
taller than the point).
