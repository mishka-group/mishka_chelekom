# number_field (mob)

A numeric input with decrement and increment buttons. See [README](README.md) for the rules every
Mob component shares.

## Generate
`mix mishka.ui.gen.mob number_field` → `lib/<app>/components/number_field.ex`, tag
`<NumberField />`. With `--module-prefix mishka_` it is `<MishkaNumberField />`.

## What it renders

```
box  the strip — border, corner_radius, fill_width: false
└── row
    ├── box  the − stepper (size × size)
    ├── box  a 1dp hairline
    ├── box  the value slot  →  text_field  centred, no box of its own
    ├── box  a 1dp hairline
    └── box  the + stepper
```

**One control, not three.** It was a stepper, a gap, a bordered field that filled the row, and
another stepper — so the two buttons drifted to opposite edges of the screen with a wide empty box
marooned between them. The web draws a single bordered strip and so does this.

## Example

```elixir
~MOB"""
<MishkaNumberField
  value={@qty}
  min={1}
  max={10}
  on_change={:qty}
  on_step={:qty_step}
  id="qty"
/>
"""

# The buttons and the keyboard go through the same two pure functions.
def handle_info({:tap, {:qty_step, dir}}, socket) do
  next = MishkaNumberField.step(socket.assigns.qty, dir, step: 1, min: 1, max: 10)
  {:noreply, Mob.Socket.assign(socket, :qty, next)}
end

def handle_info({:change, :qty, text}, socket) do
  {:noreply, Mob.Socket.assign(socket, :qty, MishkaNumberField.parse(text, min: 1, max: 10))}
end
```

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | number or `nil` | `nil` |
| `min` / `max` | number or `nil` | `nil` — unbounded |
| `step` | number | `1` — also picks the keypad |
| `format` | `:plain` / `:currency` / `:percent` | `:plain` |
| `decimals` | integer | derived from `step` |
| `placeholder` | string | `nil` |
| `disabled` | boolean | `false` |
| `on_change` / `on_step` | event tags | — |
| `size` | number | `56` — stepper edge and strip height |
| `value_width` | number | estimated from the rendered text |
| `fill_width` | boolean | `false` |
| `background` / `border_color` / `border_width` / `corner_radius` | | the strip |
| `id` | string | `nil` — tags the value, and `<id>-down` / `<id>-up` |

Helpers: `parse/2`, `step/3`, `to_text/2`, `decimals_for/1`, `format/3`, `at_bound?/3`.

Not ported: `name` (form plumbing), `small_step` / `large_step` (modifier-key gestures — there is no
shift or alt on a phone), `snap_on_step`, `allow_out_of_range` (this always clamps), press-and-hold
to repeat, and scrub-to-change. See "What is missing" below.

## Five things to know

**The parsing is the component.** A numeric input's real work is turning what the user typed into a
number: partial input while typing (`"-"`, `"1."`, `""`), values outside the range, and step
arithmetic that must not drift. `parse/2` returns `nil` for "not a number *yet*" rather than
snapping to zero, and `step/3` rounds to the step's own precision — stepping `0.1` from `0.3` gives
`0.4`, not `0.4000000000000001`. Call them; do not re-derive them per screen.

**Stepping from empty lands ON `min`.** `step(nil, :up, min: 5)` is `5`, not `6`. The first press
establishes the starting point rather than jumping a step past it.

**`format` changes how the value READS, never what you store.** `:percent` is the one to watch: it
renders a **fraction** as a percentage, so an assign of `0.075` shows as `7.5%`. The number on the
screen is not the number in your state, and `parse/2` still speaks in the stored units.

**A stepper goes inert at its bound, not just when disabled.** At `max` the `+` is unwired and
muted, because a button that cannot do anything should not look pressable — the web sets `disabled`
there for the same reason. `at_bound?/3` is exposed if you need the same answer.

**Size the value slot when you know better.** There is no text measurement on this side of the
bridge, so the slot's width is estimated from the string about to be rendered (~16dp a character,
never below 96). A fixed width clipped `"$1,999.99"` to `"99.99"`. Pass `value_width` to take the
decision back, or `fill_width={true}` to let the slot take the leftover space instead.

## What is missing, and why

The web version has three behaviours this port does not:

- **Modifier steps** (`shift` ⇒ ±100, `alt` ⇒ ±0.01). There are no modifier keys on a phone.
- **Press-and-hold to repeat.** Blocked on the Android side rather than by design: `MobBridge.kt`
  has no long-press event at all, while iOS already has `onLongPress`. Adding it needs a repeat
  timer in the bridge, not just an event.
- **Scrub-to-change** (drag the label left/right). A pointer gesture; `{:drag, tag, payload}` exists
  in the bridge, so this is the most portable of the three if it is ever wanted.

## Related
`field` (label, hint and errors around this), `slider` (a range you drag rather than type),
`otp_field`, `mask_input`.
