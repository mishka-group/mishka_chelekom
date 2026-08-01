# splitter (mob)

Two resizable panes with a draggable divider. See [README](README.md) for the rules every Mob
component shares.

## Generate
`mix mishka.ui.gen.mob splitter` → `lib/<app>/components/splitter.ex`, tag `<Splitter>`.
With `--module-prefix mishka_` it is `<MishkaSplitter>`.

## What it renders

```
row (or column)        the whole splitter, carries `id`
├── box     pane 1     width (or height) in dp
├── box     the grip   a CANVAS inside — the only node that carries on_drag
└── box     pane 2
```

## Example

```elixir
~MOB"""
<MishkaSplitter value={@split} extent={300} on_change={:split} id="panes">
  {[editor(), preview()]}
</MishkaSplitter>
"""

# A canvas reports canvas-LOCAL coordinates, so the arithmetic is relative:
# drag/3 anchors on the "began" phase and adds the distance travelled since.
def handle_info({:drag, :split, payload}, socket) do
  {value, grab} =
    MishkaSplitter.drag(payload, socket.assigns.grab,
      value: socket.assigns.split,
      extent: 300
    )

  {:noreply, socket |> assign(:split, value) |> assign(:grab, grab)}
end
```

`grab` starts as `nil` and returns to `nil` when the drag ends. Keep it in an assign.

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | 0–100 | `50` — the first pane's share |
| `orientation` | `:horizontal` / `:vertical` | `:horizontal` |
| `extent` | number | `320` — total dp to divide |
| `min` / `max` | 0–100 | `10` / `90` |
| `disabled` | boolean | `false` — greys the grip and unwires it |
| `grip` | number | `24` — thickness of the drag target |
| `grip_color` | ARGB **int** | grey — canvas ops take ints, not tokens |
| `on_change` | event tag | — `{:drag, tag, payload}` |
| `id` | string | `nil` — panes get `<id>-pane-1`/`-2`, the grip `<id>-grip` |

Helpers: `drag/3`, `sizes/1`, `split/1`, `grip_id/1`, `pane_id/2`.

Not ported: keyboard resizing (`Arrow`/`Home`/`End` — a Mob canvas takes no focus, so there is
nothing to receive the keys) and the `*_class` attrs.

## Five things to know

**The divider is the handle.** This component used to ship a `Slider` bolted under the panes, on
the stated grounds that "Mob delivers no pointer coordinates to `render/1`". That was wrong:
`Mob.Renderer` registers `on_drag` alongside `on_tap` and `on_change`, and four components in this
library already use it. Do not add a second control — the divider is it.

**Only a `:canvas` carries `on_drag`,** which drives the whole design. It also means the node must
be built as a literal map: `Mob.UI.canvas/1` is `Map.take(props, [:width, :height, :draw])` and
silently drops every handler, and `Canvas` is not in the `~MOB` tag whitelist either.

**The arithmetic is relative, not absolute.** A canvas reports coordinates local to *itself*, and
the grip is small — so `x` is meaningless as a position but exact as a distance, because the canvas
keeps reporting while the finger travels outside its bounds. `drag/3` anchors on `"began"` and adds
the distance since. This is why you need the `grab` assign.

**Use `x`/`y`, never `dx`/`dy`.** On iOS those are cumulative translation; on Android they are
per-sample deltas. Anything built on them behaves differently on each platform. `drag/3` reads only
`x`/`y`.

**Panes are sized in dp, not weighted.** Compose has `weight` and SwiftUI does not, so a weighted
split would work on Android and collapse on iOS. Hence `extent` — the total the splitter divides.
`sizes/1` does that arithmetic and is public, so a screen that knows its own dimensions (via
`:mob_nif.screen_info/0`) can ask for the numbers without rendering.

## Related
`separator` (a rule with no panes and no drag), `scroll_area`, `tabs`.
