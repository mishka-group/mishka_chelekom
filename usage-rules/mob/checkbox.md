# checkbox (mob)

A box with three states — checked, unchecked and **indeterminate**. See [README](README.md) for the
rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob checkbox` → `lib/<app>/components/checkbox.ex`, tag `<Checkbox />`. With
`--module-prefix mishka_` it is `<MishkaCheckbox />`.

## What it renders

```
row  fill_width, on_tap          ← the whole row is the target, label included
├── box  size × size, corner_radius: :radius_sm, border
│   └── text  "✓" / "–" / ""     ← scaled to 0.7 × size
├── spacer(10)
└── text  the label
```

Mob ships no checkbox widget — its `Toggle` is a switch — so the indicator is drawn from a Box and a
glyph. That is why `size` exists, and why the glyph is sized *from* it: a fixed glyph in a resizable
box is clipped when the box shrinks and marooned when it grows.

## Example

```elixir
~MOB"""
<MishkaCheckbox label="Remember me" checked={@remember?} on_toggle={:remember} />
"""

# The component is controlled; the screen owns the state. `toggle/1` gives you
# the next {checked?, indeterminate?} pair, including the mixed→checked rule.
def handle_info({:tap, :remember}, socket) do
  {checked?, _mixed?} = MishkaCheckbox.toggle(%{checked: socket.assigns.remember?})
  {:noreply, Mob.Socket.assign(socket, :remember?, checked?)}
end
```

## Props

| Prop | Values | Default |
|---|---|---|
| `label` | string | `nil` — text beside the box |
| `checked` | boolean | `false` |
| `indeterminate` | boolean | `false` — overrides `checked` visually |
| `on_toggle` | event tag (atom) | — omit for a read-only box |
| `disabled` | boolean | `false` |
| `color` | colour token / ARGB int | `:primary` — the fill when checked or mixed |
| `text_color` | colour token / ARGB int | `:on_primary` — the tick itself |
| `size` | number | `22` — the indicator's edge |

Helper: `toggle/1`.

## Four things to know

**`size` scales the glyph too.** The tick is `0.7 × size`, so it stays inside the border at any
edge. It used to be a fixed `:base`, which meant `size` moved the box and left the glyph behind — a
small box clipped its tick into a smear and a large one left it stranded in the middle. If you
change the ratio, check both ends of the range, not just the default.

**Indeterminate wins over checked, and the glyph changes with it.** A mixed box draws a dash rather
than a tick, so the three states differ by *shape* and not only by colour — they survive a
colourblind reading. `toggle/1` resolves mixed to fully checked, which is what browsers do.

**The whole row is the tap target.** `on_tap` sits on the Row, so the label is as tappable as the
box — the web gets this free from `<label>`, and a 22dp box alone is a poor target on a phone.

**`disabled` means no handler.** Like the switch and the chip, a disabled checkbox simply omits its
handler, so nothing is wired and it cannot change. It mutes the label and the glyph, but the
platform still paints an ordinary control.

## Related
`switch` (a setting that takes effect at once), `checkbox_group` (several of these with one handler),
`radio_group` (one of many, never none), `chip` (the same choice as a compact label).
