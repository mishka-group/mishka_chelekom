# hue_slider (mob)

A rainbow strip you touch to pick a hue, 0–360°. Drawn on a canvas — real bands, not an
approximation. See [README](README.md) for the event shapes every Mob component shares.

## Generate
`mix mishka.ui.gen.mob hue_slider` → `lib/<app>/components/hue_slider.ex`, tag `<HueSlider />`.
With `--module-prefix mishka_` it is `<MishkaHueSlider />`.

## What it renders

```
column
├── row      "Hue" … "238°"     only with label: / show_value: true
└── canvas   the spectrum + marker
```

That is the whole component. A colour swatch showing the hex is a **screen's** job, not the
slider's — the gallery draws one to prove the value is live.

## Example

```elixir
def render(assigns) do
  ~MOB"""
  <HueSlider value={@hue} label="Hue" show_value={true} on_change={:hue} />
  """
end

# The strip IS the control, so what arrives is a touch POSITION, not a number.
def handle_info({:drag, :hue, %{x: x}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :hue, HueSlider.hue_at(x))}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

**`on_change` delivers `{:drag, tag, %{x:, y:, dx:, dy:, phase:}}` — not `{:change, tag, float}`.**
Matching on `{:change, …}` compiles, renders a perfect strip, and does nothing. `hue_at/2` is the
inverse of the marker, so the colour under the finger is the colour selected; pass the same
`width` you gave the component if you overrode it.

`phase` is `"began"` on touch-down — which is why a **tap** sets the hue, not just a drag —
`"dragging"` while moving, `"ended"` on release. Ignore it unless you want commit-on-release.

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | number, degrees | `0` |
| `width` / `height` | number, logical units | `300` / `16` |
| `label` | string | `nil` |
| `show_value` | boolean | `false` — renders `238°` |
| `on_change` | event tag | see above |

Helper: `hue_at(x, width \\ 300)` → float.

## Two things that surprise people

**There is no slider under the strip.** There used to be, because Mob's tap path carries no
position. It does now — `{:drag, …}` — so the drawn thing is the control. If you see a
`<Slider>` in a colour component you are on an old version.

**360 is the far end, not the near one.** Hue is circular and `wrap_hue/1` is `fmod`, so
`fmod(360.0, 360.0) == 0.0` used to teleport the marker back to the left edge at maximum. Only
out-of-range values wrap now. Keep this in mind if you write your own inverse: clamp into
`[0, width]` rather than wrapping.

## Related
`alpha_slider` (same shape, 0–100), `angle_slider` (a dial), `color_picker` (hue strip + a
saturation/value square — that square still uses sliders, because one gesture cannot emit two
events).
