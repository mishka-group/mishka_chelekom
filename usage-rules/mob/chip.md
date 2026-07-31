# chip (mob)

A compact, selectable label — a filter, a tag, one of a set. See [README](README.md) for the rules
every Mob component shares.

## Generate
`mix mishka.ui.gen.mob chip` → `lib/<app>/components/chip.ex`, tag `<Chip />`. With
`--module-prefix mishka_` it is `<MishkaChip />`.

## What it renders

```
row                          ← hugs, so the chip is chip-sized
└── box  fill_width: false, corner_radius: :radius_pill, padding, on_tap
    └── text  the label
```

The `Row` is not decoration. A `Box` with neither `width` nor `fill_width` **fills its parent** on
both platforms, so an unwrapped pill stretched the whole line — one giant chip per row. A `Row` hugs
its content on both (a Compose `Row` does not fill by default; an `HStack` hugs unless told to), and
the Box then measures to its label. The radius stays on the **Box** because a Row's `corner_radius`
is clipped only on Android — it would be square on iOS.

## Example

```elixir
~MOB"""
<Row fill_width={true}>
  <MishkaChip label="Elixir" checked={:elixir in @tags} on_toggle={{:tag, :elixir}} />
  <Spacer size={8} />
  <MishkaChip label="Erlang" checked={:erlang in @tags} on_toggle={{:tag, :erlang}} />
</Row>
"""

# One clause serves every chip, because the tag carries the id.
def handle_info({:tap, {:tag, id}}, socket) do
  tags = socket.assigns.tags
  next = if id in tags, do: List.delete(tags, id), else: [id | tags]
  {:noreply, Mob.Socket.assign(socket, :tags, next)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

## Props

| Prop | Values | Default |
|---|---|---|
| `label` | string | — the chip's text |
| `checked` | boolean | `false` |
| `on_toggle` | event tag, usually `{tag, id}` | — omit for a static chip |
| `disabled` | boolean | `false` |
| `color` | colour token / ARGB int | `:primary` — the fill when checked |
| `text_color` | colour token / ARGB int | contrast — the label when checked |

Not ported: `name` / `value` / `type` / `id` and the `*_class` attrs. The web chip is a `<label>`
wrapping a real `<input type="checkbox|radio">` so it can submit inside a form; there is no form
post here, and the screen already holds the selection.

## Four things to know

**Compose the id into the tag.** `on_toggle={{:tag, :elixir}}` gives you `{:tap, {:tag, :elixir}}`
and one `handle_info` clause for the whole set. A bare `on_toggle={:tag}` renders a perfect chip
that cannot tell you *which* one was tapped.

**Checkbox versus radio is the handler, not the chip.** The web distinguishes them with
`type=`; here the difference is entirely what your clause does — toggle membership in a list, or
replace a single value. The component is the same either way. A radio set cannot be cleared, and
that is the whole reason to choose it.

**`disabled` means no handler.** Like the switch, a disabled chip simply omits its `on_toggle`, so
nothing is wired and the chip cannot move. It still paints as a normal (dimmed) chip rather than a
platform-disabled control.

**Chips do not wrap.** Neither renderer has a flow layout, so a `Row` of chips runs off the edge
rather than flowing onto a second line the way the web version does. Lay them out in `Row`s you
break yourself, or put them in a horizontal `Scroll`.

## Related
`switch` (a setting rather than a selection), `checkbox_group` / `radio_group` (the same choice with
a conventional control), `pill` (a chip that is not selectable), `toggle` (a pressed button).
