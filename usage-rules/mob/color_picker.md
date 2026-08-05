# color_picker (mob)

A saturation/brightness square with a hue strip under it. Both are drawn on canvases and both
are dragged directly. See [hue_slider](hue_slider.md) for the 1-D case this builds on.

## Generate
`mix mishka.ui.gen.mob color_picker` → `lib/<app>/components/color_picker.ex`, tag
`<ColorPicker />`. Pulls in `hue_slider` as a sibling.

## What it renders

```
column
├── canvas   the saturation/brightness square + ring   → on_area
├── canvas   the hue strip + marker (a nested HueSlider) → on_hue
└── preview  the swatch + hex, when show_preview: true
```

**No sliders.** A labelled slider per axis is a *screen's* way of driving the picker, not part
of it — the gallery keeps two to show each axis can also be set on its own.

## Example

```elixir
def render(assigns) do
  ~MOB"""
  <ColorPicker hue={@hue} saturation={@sat} value={@val} on_hue={:hue} on_area={:area} />
  """
end

# One gesture, two numbers — which is why they arrive together.
def handle_info({:drag, :area, %{x: x, y: y}}, socket) do
  {sat, val} = ColorPicker.sv_at(x, y)
  {:noreply, socket |> assign(:sat, sat) |> assign(:val, val)}
end

def handle_info({:drag, :hue, %{x: x}}, socket) do
  {:noreply, assign(socket, :hue, HueSlider.hue_at(x, 280))}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

**`on_area` replaced `on_saturation` + `on_value`.** A component cannot emit two events from one
gesture, so a drag on the square delivers one `{:drag, tag, %{x:, y:}}` and `sv_at/4` turns it
into `{saturation, brightness}`. Code written against the old pair must move.

Pass the picker's `width`/`height` to `sv_at/4` if you overrode them, and `width` to `hue_at/2`
— the strip is as wide as the square.

## Props

| Prop | Values | Default |
|---|---|---|
| `hue` | 0–360 | `210` |
| `saturation` / `value` | 0–100 | `76` / `96` |
| `width` / `height` | number | `280` / `170` |
| `on_area` | event tag | `{:drag, tag, %{x:, y:}}` → `sv_at/4` |
| `on_hue` | event tag | `{:drag, tag, %{x:}}` → `hue_at/2` |

Helpers: `sv_at(x, y, w \\ 280, h \\ 170)` → `{sat, val}`, `hex/1`.

## Two things to know

**Saturation runs left→right, brightness top→bottom.** `sv_at/4` is the exact inverse of what
the square paints, so the ring lands *under* the finger. Writing your own inverse and forgetting
to flip y puts the ring in the wrong half.

**A touch outside the square clamps.** Dragging off the edge pins to 0 or 100 rather than
reporting past it, so the ring stays on the field.
