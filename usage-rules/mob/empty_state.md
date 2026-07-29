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
  >
    <MishkaEmptyStateActions>
      <Button text="New" on_tap={{self(), :new_project}} />
      <Button text="Import" on_tap={{self(), :import_projects}} />
    </MishkaEmptyStateActions>
  </MishkaEmptyState>
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
| `actions` | list of nodes | `[]` — prefer the slot |

## Slots

All three of the web component's slots are ported as tags:

| Slot | Chelekom | Falls back to |
|---|---|---|
| `<MishkaEmptyStateIndicator>` | `<:indicator>` | the `indicator` glyph prop |
| `<MishkaEmptyStateActions>` | `<:actions>` | the `actions` prop |
| bare children | `<:inner_block>` | — rendered after the description |

Slot tags are not in Mob's tag whitelist, so `~MOB` emits a "pass-through" warning for them. It is
cosmetic — the tag still expands correctly — and `<MishkaAccordionItem>` has the same wrinkle.

Not ported: `id` and the `*_class` attrs.

## Three things to know

**Let the component own the actions row.** A `Row` gives the first child every pixel it asks for,
and a control that has not been told to hug asks for all of them — so a hand-built row of two
buttons lays the first across the full width and measures the second to **zero**, parked past the
right edge. It stays in the node tree and a test harness will happily "click" it; only a finger can
tell. The component sets `fill_width: false` on each action, which is the reason to pass them
through the slot rather than assembling the row yourself.

Not `weight`. Weights place the buttons too, but `weight` is `Modifier.weight` and Mob's iOS
renderer has no equivalent — the row would divide evenly on Android and not on iOS. Hugging is
honoured on both, and it is what an `HStack` does natively.

**Every part is optional, including all of them.** No title, no description, no indicator and no
actions renders an empty block rather than raising. That is deliberate — a caller assembling one
from data should not have to guard each field — but it does mean a typo in a prop name shows up as
a missing line rather than an error.

**Actions wired to nothing look identical to actions that work.** The buttons are yours, so
nothing in this component can check them; a `on_tap` pointing at a tag no `handle_info` matches
renders a perfect button that does nothing. If your empty state has a "Create" button, make sure
tapping it makes the empty state *go away* — that round trip is the whole feature.

## Related
`skeleton` (content that is *coming*, rather than absent), `dialog` (the other component whose
`actions` is a prop), `loading_overlay` (a list that is busy rather than empty).
