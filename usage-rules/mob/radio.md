# radio (mob)

One option in a mutually exclusive set. See [README](README.md) for the rules every Mob component
shares.

## Generate
`mix mishka.ui.gen.mob radio` → `lib/<app>/components/radio.ex`, tag `<Radio />`. With
`--module-prefix mishka_` it is `<MishkaRadio />`.

## What it renders

```
row  fill_width, on_tap              ← the whole row is the target, label included
├── box  size × size, corner_radius: size / 2, border, align: :center
│   └── box  dot, only when checked  ← size / 2.4, floor 6
├── spacer(10)
└── text  the label
```

Same row shape as `checkbox`, with the one visual difference that carries the meaning: **a circle
with a centre dot** rather than a square with a tick. That is the whole convention for "pick one"
versus "pick any", so it is drawn rather than left to colour.

An exact `size / 2` radius is what keeps it a circle at any size — a radius *token* is a fixed
number of dp and turns a large ring into a rounded square.

## Example

```elixir
~MOB"""
<Column fill_width={true}>
  <MishkaRadio label="Free" checked={@plan == :free} on_select={{:plan, :free}} />
  <Spacer size={12} />
  <MishkaRadio label="Pro" checked={@plan == :pro} on_select={{:plan, :pro}} />
</Column>
"""

# Exclusivity is this one line. Assigning the tapped id leaves every other
# radio with checked={false}, because they all read the same assign.
def handle_info({:tap, {:plan, id}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :plan, id)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

## Props

| Prop | Values | Default |
|---|---|---|
| `label` | string | `nil` — text beside the dot |
| `checked` | boolean | `false` |
| `on_select` | event tag, usually `{tag, id}` | — omit for a read-only radio |
| `disabled` | boolean | `false` |
| `color` | colour token / ARGB int | `:primary` — ring and dot when selected |
| `text_color` | colour token / ARGB int | `:on_surface` — the label |
| `size` | number | `22` — outer circle diameter |
| `fill_width` | boolean | `true` — the row spans its parent, so the label is tappable |
| `id` | string | `nil` — test tag on the ring, suffixed with its state |

Not ported: `name`, `value`, `required` (form plumbing) and the `*_class` attrs. `readonly`
collapses into `disabled` — both omit the handler.

## Five things to know

**Exclusivity lives in the screen, not the component.** On the web a shared `name` makes the browser
enforce that only one radio in a group is selected. There is no form and no browser here, so a radio
is simply *told* whether it is `checked` — and one assign, read by every radio in the set, is what
makes them exclusive. That is why `name` is not a prop: it would describe a behaviour this component
does not perform. Get this wrong and you get two filled rings, which is why the device test asserts
there is exactly one.

**Compose the id into the tag.** `on_select={{:plan, :pro}}` gives you `{:tap, {:plan, :pro}}` and
one `handle_info` clause for the whole set. A bare `on_select={:plan}` renders a perfect radio that
cannot tell you *which* one was tapped.

**A radio set cannot be cleared, and that is the reason to choose it.** Re-tapping the selected
option leaves it selected — there is no "none" state once a choice is made. If the user must be able
to clear the choice, you want `checkbox` or a chip, not this.

**Set `fill_width={false}` for a side-by-side set.** The row fills its parent by default, which is
what makes the *label* part of the tap target — a 22dp circle alone is a poor target on a phone. But
inside a horizontal `Row`, a filling option takes the entire width and pushes its siblings off the
screen entirely: the first option looks fine and the rest are simply gone. `radio_group` passes
`false` automatically when `orientation={:horizontal}`; do the same if you lay options out yourself.
Unlike a Box, a Row honours this prop on **both** renderers.

**`id` carries the state, because a dot is not text.** The selection is a filled circle, so nothing
in the accessibility tree says which option is chosen and a device test cannot see it. The ring's
tag becomes `"<id>-selected"` or `"<id>-empty"`. In a device test pass `useUnmergedTree = true`: the
tappable Row merges its children's semantics and swallows the tag.

## Related
`radio_group` (this with a label, a value and a cascading `disabled`), `checkbox` (pick any, and
clearable), `chip` (the same choice as a compact label), `switch` (a setting rather than a choice).
