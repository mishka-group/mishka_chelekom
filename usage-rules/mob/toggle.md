# toggle (mob)

A button that stays pressed, as in a formatting toolbar's bold or italic. See [README](README.md)
for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob toggle` → `lib/<app>/components/toggle.ex`, tag `<Toggle />`. With
`--module-prefix mishka_` it is `<MishkaToggle />`.

## What it renders

```
box  fill_width: false, padding, corner_radius, border, on_tap
└── text  the label   ← or your children, if you pass any
```

**Beware the name.** Mob's own `<Toggle>` tag is a *switch*. This component deliberately does not
use it — see the three lookalikes below.

## Styling is yours, as on the web

The headless original ships no colours and no spacing; you style it with a stylesheet. There is no
stylesheet here, so **every visual decision is a prop**, with defaults chosen only so an unstyled
toggle is legible. That is the whole design: the component has no look of its own, and the showcase
builds a pill, a square and a segmented bar out of nothing but these props.

## Example

```elixir
~MOB"""
<Row fill_width={true}>
  <MishkaToggle label="Bold" pressed={@bold?} on_change={:bold} padding={10} corner_radius={6} />
  <Spacer size={8} />
  <MishkaToggle label="Italic" pressed={@italic?} on_change={:italic} padding={10} corner_radius={6} />
</Row>
"""

# A lone toggle owns one boolean, so its tag needs no id.
def handle_info({:tap, :bold}, socket) do
  {:noreply, Mob.Socket.assign(socket, :bold?, not socket.assigns.bold?)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

## Props

| Prop | Values | Default |
|---|---|---|
| `label` | string | `nil` — children override it |
| `pressed` | boolean | `false` |
| `on_change` | event tag (atom) | — omit for a static button |
| `disabled` | boolean | `false` |
| `color` | colour token / ARGB int | `:primary` — fill **when pressed** |
| `text_color` | colour token / ARGB int | `:on_primary` — label **when pressed** |
| `background` | colour token / ARGB int | `:surface_raised` — fill when idle |
| `label_color` | colour token / ARGB int | `:on_surface` — label when idle |
| `padding` | spacing token / number | `:space_sm` |
| `corner_radius` | radius token / number | `:radius_md` |
| `border_color` | colour token / ARGB int | `:border` |
| `border_width` | number | `1` — `0` removes the border |
| `text_size` | text token | `:base` |
| `fill_width` | boolean | `false` |
| `id` | string | `nil` — test tag, suffixed `-pressed` / `-idle` |

Not ported: `name`, `value`, `unchecked_value`, `form` (HTML form plumbing) and the `*_class`
attrs.

## Five things to know

**It hugs its label, and that is load-bearing.** `fill_width` defaults to `false` because a Box given
neither a width nor the prop **fills its parent** — which rendered every toggle as one full-width
slab and made a toolbar of them impossible. Set `fill_width={true}` deliberately, for a toggle that
really should span its container. The chip fell into the identical trap; on **iOS** a Box still
ignores the prop entirely (`IOS_TODO.md` item 6).

**Style it in pairs.** `color`/`text_color` are the pressed fill and label; `background`/`label_color`
are the idle pair. Change one without the other and you get white-on-white in one of the two states —
the most common way to make a toggle vanish.

**A disabled toggle stays filled.** Greyed rather than accented, but filled. Falling back to the idle
background would render "locked on" and "locked off" identically, so the user cannot see which state
they are locked into. Disabling wires no handler, so it is inert rather than merely grey.

**`id` carries the state, because pressed is only a colour.** A pressed toggle differs from an idle
one by its fill alone, and colour is not in the accessibility tree — nothing tells a device test
which buttons are down. The tag becomes `"<id>-pressed"` or `"<id>-idle"`. Pass
`useUnmergedTree = true` when reading it: a tappable Box merges its label's semantics over its own.

**Three lookalikes, kept apart on purpose.** A `switch` is a *setting* and wraps the platform widget;
a `chip` is a *filter*, one of a set, pill-shaped by convention; a toggle is a *pressed button*,
holding a binary fact about the thing you are editing rather than about the app. They look different
so a user can tell them apart — do not restyle one into another.

## Related
`toggle_group` (several of these sharing one selection), `switch`, `chip`, `checkbox`.
