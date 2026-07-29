# color_swatch (mob)

A block of a single colour, optionally selectable. See [README](README.md) for the event shapes
every Mob component shares, and [color_picker](color_picker.md) for choosing a colour rather than
showing one.

## Generate
`mix mishka.ui.gen.mob color_swatch` → `lib/<app>/components/color_swatch.ex`, tag
`<ColorSwatch />`. With `--module-prefix mishka_` it is `<MishkaColorSwatch />`.

## What it renders

```
box    the ring — border, corner_radius from shape          → on_tap
├── box   the checkerboard, only below full alpha
└── box   the colour itself
    └── text  ✓, when selected (children replace it)
```

## Example

```elixir
def render(assigns) do
  swatches =
    Enum.map(@palette, fn {id, color} ->
      ~MOB"<MishkaColorSwatch color={color} selected={@picked == id} on_tap={{:pick, id}} />"
    end)

  ~MOB"<Row>{swatches}</Row>"
end

# A swatch carries NO value. The tag is what identifies it, so put the id there
# and one handler serves the whole palette.
def handle_info({:tap, {:pick, id}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :picked, id)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

**`on_tap={:pick}` on ten swatches gives you ten identical events and no way to tell them apart.**
The component knows its own colour and does not send it — that is deliberate and consistent with
every other single-item control in the kit (chip, checkbox, radio, theme_icon all do the same).

## Props

| Prop | Values | Default |
|---|---|---|
| `color` | ARGB int / colour token | `nil` |
| `size` | number | `36` — the edge |
| `shape` | `:rounded` · `:circle` · `:square` | `:rounded` |
| `selected` | boolean | `false` — a 2px ring and a ✓ |
| `on_tap` | event tag | `{:tap, tag}` |
| `disabled` | boolean | `false` |
| `checkerboard` | boolean | auto — on below full alpha |

Helper: `translucent?(color)` → whether the checkerboard would appear.
Not ported: `label` (an `aria-label` — Mob exposes no accessible name) and `id` / `*_class`.

## Three things to know

**A translucent swatch without a checkerboard is a lie.** The same ARGB reads differently over a
light and a dark surface, so below `0xFF` alpha the colour is drawn over a checkerboard — the
convention every colour picker uses. Opaque colours skip it, because the extra nodes would be
waste. `checkerboard={true}` forces it on; `false` turns it off.

**`disabled` drops the handler, it does not guard it.** Nothing is sent, so nothing needs ignoring
on the receiving end. The colour still shows — a disabled swatch is still information.

**Children replace the ✓, not the colour.** Pass content and it renders centred over the swatch
instead of the tick, which is how you put a lock or a count on one.

## Related
`color_picker` (choose a colour), `color_input` (a hex field with a swatch that opens a picker),
`hue_slider` / `alpha_slider` (single axes).
