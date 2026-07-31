# chip (mob)

A compact, selectable label — a filter, a tag, one of a set. See [README](README.md) for the rules
every Mob component shares.

## Generate
`mix mishka.ui.gen.mob chip` → `lib/<app>/components/chip.ex`, tag `<Chip />`. With
`--module-prefix mishka_` it is `<MishkaChip />`.

## What it renders

```
button  fill_width: false, corner_radius: :radius_pill, text, on_tap
```

One node, and it must be a **Button**. A `Box` with neither `width` nor `fill_width` *fills its
parent* on both platforms — that is why the chip shipped full width — and `fill_width={false}` does
not rescue it, because iOS's `MobBox` never reads that prop: only an explicit width stops it
filling, and a label's width is not known here. Wrapping the Box in a hugging `Row` does not help
either; an `HStack` still offers its whole width to a flexible child.

`Button` is the only node that reads `fill_width` on **both** (`if (fillWidth) fillMaxWidth()` in
Compose, `.frame(maxWidth: fillWidth ? .infinity : nil)` in SwiftUI), and iOS clips it with
`RoundedRectangle(cornerRadius:)`, so the pill hugs *and* stays round on both.

**Do not give it a `padding`.** Padding lands inside the label on iOS but as an outer margin on
Android, where Material has already added its own content padding — stacking the two made the chip
chunky enough to ellipsise "Gleam" to "Gle…". Each platform's own button padding is closer to a chip
than anything set here, and it is the only setting that agrees.

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

**`disabled` means no handler — but it still shows what is selected.** A disabled chip omits its
`on_toggle`, so nothing is wired and it cannot move. It does *not* lose its checked state: a
locked-on chip is muted rather than reset to the unchecked fill, because otherwise "locked on" and
"locked off" render identically and the user cannot see what they are locked into. The web keeps the
two orthogonal for the same reason.

**Chips do not wrap.** Neither renderer has a flow layout, so a `Row` of chips runs off the edge
rather than flowing onto a second line the way the web version does. Lay them out in `Row`s you
break yourself, or put them in a horizontal `Scroll`.

## Related
`switch` (a setting rather than a selection), `checkbox_group` / `radio_group` (the same choice with
a conventional control), `pill` (a chip that is not selectable), `toggle` (a pressed button).
