# color_input (mob)

A hex field with a colour swatch and a picker panel. Type the colour or pick it. Wraps
[color_picker](color_picker.md) — read that one for the panel's two controls.

## Generate
`mix mishka.ui.gen.mob color_input` → `lib/<app>/components/color_input.ex`, tag
`<ColorInput />`. Pulls in `color_picker` and `hue_slider` as siblings.

## What it renders

```
column
├── label                                    when label: is set
├── row     swatch · hex TextField · ▾       swatch and ▾ both send on_toggle
└── panel   a ColorPicker                    only when open: true
```

## Example

```elixir
def render(assigns) do
  ~MOB"""
  <ColorInput
    value={@hex} open={@open}
    on_change={:hex} on_toggle={:toggle}
    on_hue={:hue} on_area={:area}
    hue={@hue} saturation={@sat} value_pct={@val}
  />
  """
end

# Typed text. Only accept it once it parses, or every keystroke on the way to
# "#3b82f6" repaints the panel from a half-written colour.
def handle_info({:change, :hex, text}, socket) do
  case Color.parse(text) do
    {:ok, rgb} -> {:noreply, assign_hsv(socket, text, rgb)}
    :error -> {:noreply, assign(socket, :hex, text)}
  end
end

def handle_info({:tap, :toggle}, socket) do
  {:noreply, assign(socket, :open, not socket.assigns.open)}
end

def handle_info({:drag, :hue, %{x: x}}, socket) do
  {:noreply, sync(socket, :hue, HueSlider.hue_at(x, 280))}
end

def handle_info({:drag, :area, %{x: x, y: y}}, socket) do
  {sat, val} = ColorPicker.sv_at(x, y)
  {:noreply, socket |> assign(:sat, sat) |> sync(:val, val)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | hex string | `"#3b82f6"` |
| `open` | boolean | `false` |
| `hue` / `saturation` / `value_pct` | numbers | derived from `value` |
| `label` | string | `nil` |
| `disabled` | boolean | `false` |
| `on_change` | event tag | `{:change, tag, text}` |
| `on_toggle` | event tag | `{:tap, tag}` — swatch **and** ▾ |
| `on_hue` / `on_area` | event tags | forwarded to the panel; see color_picker |

## Three things to know

**Two notations, one colour.** The field holds hex; the panel holds H/S/V. They are separate
assigns, so a handler that updates one must write the other back — otherwise the text says one
colour and the panel shows another. That is what `sync/2` is doing above.

**The swatch opens the panel, not just the ▾.** It is the most colour-like thing on the row, so
it is what a finger reaches for. `disabled` unwires both, and the field with them.

**Forwarded props are not validated.** `on_hue` and `on_area` are handed straight to the nested
picker. Pass a name the picker does not have — as this component did after `on_saturation` and
`on_value` became `on_area` — and nothing raises: the panel opens, the square draws, and
dragging it does nothing at all.
