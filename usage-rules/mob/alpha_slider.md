# alpha_slider (mob)

An opacity track, 0–100, drawn over a checkerboard so the transparency actually shows through.
Same shape as [hue_slider](hue_slider.md) — read that one first; this file is the differences.

## Generate
`mix mishka.ui.gen.mob alpha_slider` → `lib/<app>/components/alpha_slider.ex`, tag
`<AlphaSlider />`. With `--module-prefix mishka_` it is `<MishkaAlphaSlider />`.

## What it renders

```
column
├── row      "Opacity" … "60%"    only with label: / show_value: true
└── canvas   checkerboard + colour ramp + marker
```

That is all of it. A preview of the colour at that opacity is a **screen's** job.

## Example

```elixir
def render(assigns) do
  ~MOB"""
  <AlphaSlider value={@alpha} color="#3b82f6" label="Opacity" show_value={true} on_change={:alpha} />
  """
end

# The track IS the control, so what arrives is a touch POSITION, not a number.
def handle_info({:drag, :alpha, %{x: x}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :alpha, AlphaSlider.alpha_at(x))}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

**`on_change` delivers `{:drag, tag, %{x:, y:, dx:, dy:, phase:}}`, not `{:change, tag, float}`.**
Matching the old shape compiles, renders a perfect track, and does nothing. `alpha_at/2` inverts
the marker; pass the same `width` if you overrode it.

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | number, 0–100 | `100` |
| `color` | hex string | `"#000000"` — the colour the ramp fades |
| `width` / `height` | number, logical units | `300` / `16` |
| `label` | string | `nil` |
| `show_value` | boolean | `false` — renders `60%` |
| `on_change` | event tag | see above |

Helper: `alpha_at(x, width \\ 300)` → float.

## Differences from hue_slider

**0–100, not 0–1.** It is a percentage, and `show_value` renders `60%`. Passing `0.6` gives you
0.6% opacity, not 60%.

**It clamps, it does not wrap.** Hue is circular so 360 needed care; opacity is not, so
out-of-range values pin to the nearest end. 300 lands at the right edge and stays there.

**`color` changes what the ramp fades, not the value.** The track is that colour going from fully
transparent to fully opaque over a checkerboard — so a light `color` on a light theme is hard to
read at the transparent end. That is the colour's fault, not the component's.
