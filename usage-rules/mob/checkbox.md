# checkbox (mob)

A box with three states — checked, unchecked and **indeterminate**. See [README](README.md) for the
rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob checkbox` → `lib/<app>/components/checkbox.ex`, tag `<Checkbox />`. With
`--module-prefix mishka_` it is `<MishkaCheckbox />`.

## What it renders

```
row  fill_width, on_tap          ← the whole row is the target, label included
├── box  size × size, corner_radius: :radius_sm, border, id: "<id>-checked|mixed|empty"
│   └── canvas  size × size      ← the mark: 2 lines for a tick, 1 for a dash, 0 for empty
├── spacer(10)
└── text  the label
```

Mob ships no checkbox widget — its `Toggle` is a switch — so the indicator is drawn from a Box, and
the mark is **drawn on a canvas** rather than typed as a glyph. That is why `size` exists: every
coordinate in the mark is a fraction of it, so it lands correctly at any edge.

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
| `id` | string | `nil` — becomes the indicator's testTag, suffixed with its state |

Helper: `toggle/1`.

## Five things to know

**The mark is drawn, not typed — do not put it back to a glyph.** It was a `"✓"` Text once, and it
could not be centred at any font size: a glyph sits on its *baseline* with descent space beneath, so
it rides high inside its box. That offset is invisible at 26dp and obvious at 16dp, and scaling the
ratio (0.7, then 0.55) only moves it. Lines have no metrics, so `Mob.Canvas.line` puts the mark
exactly where the fractions say at every size.

**A drawn mark is invisible to tests, so `id` carries the state.** There is no text to assert on, so
the indicator's testTag becomes `"<id>-checked"`, `"<id>-mixed"` or `"<id>-empty"` — the same trick
`mishka_skeleton` uses for bars that carry no text. In a device test, pass `useUnmergedTree = true`:
the tappable Row merges its children's semantics and swallows the tag.

**Indeterminate wins over checked, and the shape changes with it.** A mixed box draws one horizontal
line rather than two angled ones, so the three states differ by *shape* and not only by colour —
they survive a colourblind reading. `toggle/1` resolves mixed to fully checked, which is what
browsers do.

**The whole row is the tap target.** `on_tap` sits on the Row, so the label is as tappable as the
box — the web gets this free from `<label>`, and a 22dp box alone is a poor target on a phone.

**`disabled` means no handler.** Like the switch and the chip, a disabled checkbox simply omits its
handler, so nothing is wired and it cannot change. It mutes the label and the glyph, but the
platform still paints an ordinary control.

## Related
`switch` (a setting that takes effect at once), `checkbox_group` (several of these with one handler),
`radio_group` (one of many, never none), `chip` (the same choice as a compact label).
