# empty_state (mob)

The placeholder a list shows when it has nothing in it — an indicator, a title, supporting text and
optional actions. See [README](README.md) for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob empty_state` → `lib/<app>/components/empty_state.ex`, tag
`<EmptyState />`. With `--module-prefix mishka_` it is `<MishkaEmptyState />`.

## What it renders

Two genuinely different layouts, not a styling nicety.

```
:center                                :leading
box  fill_width, align: :center        row
└── column                             ├── column  the indicator
    ├── column  the indicator          ├── spacer(14)
    ├── column  title + description    └── column  title + description
    └── column  spacer + actions row              + actions row
```

`:center` fills a blank screen. `:leading` sits inside a card or a section **without looking like
the screen has failed**, which is the reason both exist.

## Example

```elixir
# It is what a list shows INSTEAD of itself, so the usual shape is a branch.
if @projects == [] do
  ~MOB"""
  <MishkaEmptyState
    indicator="📁"
    title="No projects yet"
    description="Create one to get started."
    actions={[new_button(), import_button()]}
  />
  """
else
  project_list(@projects)
end

# The buttons are yours, so the handlers are the ordinary ones.
def handle_info({:tap, :new_project}, socket) do
  {:noreply, Mob.Socket.assign(socket, :projects, ["Untitled" | socket.assigns.projects])}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

The component itself has **no events**. Everything tappable in it is a node you supplied.

## Props

| Prop | Values | Default |
|---|---|---|
| `title` | string | `nil` |
| `description` | string | `nil` |
| `align` | `:center` · `:leading` | `:center` |
| `indicator` | string | `nil` — a glyph or emoji |
| `padding` | spacing token / number | `:space_xl` |
| `actions` | list of nodes | `[]` |

Children (the tag's inner block) replace the `indicator` glyph with any nodes — an illustration,
an avatar, a drawing.

Not ported: `id` and the `*_class` attrs.

## Three things to know

**`actions` is a prop, not a slot.** The tag's children are the *indicator*, and a second slot
cannot be expressed in `~MOB` markup — so the actions row comes in as a list of nodes.
`dialog` and `alert_dialog` make the same trade for the same reason.

**Every part is optional, including all of them.** No title, no description, no indicator and no
actions renders an empty block rather than raising. That is deliberate — a caller assembling one
from data should not have to guard each field — but it does mean a typo in a prop name shows up as
a missing line rather than an error.

**The actions row does not wrap.** It is a plain `Row`, and Mob has no flow layout — so two wide
buttons inside the default `:space_xl` padding push the second one past the edge, where it is
never laid out and cannot be tapped at all. Nothing clips or complains; the button is simply not
there. Keep action labels short, or drop the padding.

**Actions wired to nothing look identical to actions that work.** The buttons are yours, so
nothing in this component can check them; a `on_tap` pointing at a tag no `handle_info` matches
renders a perfect button that does nothing. If your empty state has a "Create" button, make sure
tapping it makes the empty state *go away* — that round trip is the whole feature.

## Related
`skeleton` (content that is *coming*, rather than absent), `dialog` (the other component whose
`actions` is a prop), `loading_overlay` (a list that is busy rather than empty).
