# angle_slider (mob)

A dial you drag to pick a direction, 0–360°. Drawn on a canvas, and the ring **is** the control.
Same shape as [hue_slider](hue_slider.md) — read that one first; this file is the differences.

## Generate
`mix mishka.ui.gen.mob angle_slider` → `lib/<app>/components/angle_slider.ex`, tag
`<AngleSlider />`. With `--module-prefix mishka_` it is `<MishkaAngleSlider />`.

## What it renders

```
column
├── row     "Direction" … "238°"   only with label: / show_value: true
└── canvas  the track, the progress arc, the knob, the centre reading
```

That is all of it. There is **no slider under the dial** — if you see one you are on an old
version, from before Mob delivered drag positions.

## Example

```elixir
def render(assigns) do
  ~MOB"""
  <MishkaAngleSlider value={@angle} label="Direction" show_value={true} on_change={:angle} />
  """
end

# The ring IS the control, so what arrives is a touch POSITION, not a number.
def handle_info({:drag, :angle, %{x: x, y: y}}, socket) do
  next = MishkaAngleSlider.angle_at(x, y)
  {:noreply, Mob.Socket.assign(socket, :angle, MishkaAngleSlider.follow(socket.assigns.angle, next))}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

**`on_change` delivers `{:drag, tag, %{x:, y:, phase:}}`, not `{:change, tag, float}`.** Matching
the old shape compiles, renders a perfect dial, and does nothing.

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | number, degrees | `0` |
| `size` | number | `160` — the dial's edge |
| `color` | ARGB int | blue — arc and knob |
| `text_color` | colour token / ARGB | `:on_surface` — the centre reading |
| `label` | string | `nil` |
| `show_value` | boolean | `false` — renders `238°` |
| `on_change` | event tag | see above |

Helpers: `angle_at(x, y, size \\ 160)`, `follow(current, new)`, `point_on_dial/4`.

## Three things that surprise people

**`angle_at/3` can return `:dead`.** Near the centre of the dial there is no meaningful angle —
a pixel either side of the middle swings the value wildly — so touches inside the inner ring
return `:dead` rather than a number. `follow/2` passes those through unchanged, which is why you
should route through it instead of assigning `angle_at/3` directly.

**0° is up, not right.** Screen maths puts 0 at three o'clock; a direction dial puts it at twelve.
`angle_at/3` already applies the rotation, and `point_on_dial/4` is its inverse — use them rather
than writing your own `atan2`, or the dial and the value will disagree by 90°.

**The seam at 360° does not teleport.** Dragging past the top used to snap the value from 359 to 0
and whip the arc the long way round. `follow/2` clamps the step: a jump of more than 180° in one
event is treated as crossing the seam and pinned to `0.0` or `360.0`, so the knob tracks the
finger instead of racing it. That is also why the maximum is a real 360 rather than wrapping to 0.

## Related
`hue_slider` (the 1-D case this builds on), `alpha_slider` (0–100), `color_picker` (a
saturation/brightness square plus a hue strip).
