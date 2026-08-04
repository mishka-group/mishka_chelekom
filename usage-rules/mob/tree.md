# tree (mob)

Hierarchical data — expandable, selectable, checkable, with headers and async branches. See
[README](README.md) for the event shapes every Mob component shares.

## Generate
`mix mishka.ui.gen.mob tree` → `lib/<app>/components/tree.ex`, tag `<Tree />`. Pulls in `checkbox`
as a sibling. With `--module-prefix mishka_` it is `<MishkaTree />`.

## What it renders

One flat `Column` of indented rows — exactly the nodes on screen and nothing else. Each row is a
tappable Box holding a disclosure, an optional checkbox, an optional icon, the label, an optional
loader and an optional trailing note.

## Nodes

A node is a map with `:label` and `:value`, optionally `:children`, `:icon`, `:meta` (a trailing
note — a size, a count, a date), and three keys that change what the row *is*:

| Key | What it makes the node |
|---|---|
| `disabled: true` | Inert — no tap, no hold, no checkbox, muted ink |
| `selectable: false` | A category header: never selected, and a tap opens its branch instead |
| `has_children: true` | A branch whose contents have not been fetched — the first tap is a request |

```elixir
[
  %{label: "PROJECT", value: "project", selectable: false, children: [
    %{label: "README.md", value: "readme", icon: "📄", meta: "2 KB"},
    %{label: "assets", value: "assets", icon: "📁", has_children: true}
  ]},
  %{label: "mix.exs", value: "mix.exs", icon: "📄", disabled: true}
]
```

**Give every node a `value`.** Everything — expansion, selection, checks, test tags — is keyed on
it, and two nodes sharing one move together.

## Controlled, like the accordion

Every bit of state — `expanded`, `selected`, `checked`, `loading` — lives in your screen and comes
back in as a prop. The component is a pure function of them.

```elixir
~MOB"""
<MishkaTree
  id="files"
  nodes={@nodes}
  expanded={@expanded}
  selected={@selected}
  checked={@checked}
  with_checkboxes={true}
  on_expand={:open}
  on_collapse={:close}
  on_select={:pick}
  on_check={:check}
  on_range_select={:range}
/>
"""

# Every per-node event arrives as {:tap, {tag, node_value}} — one clause per tag
# serves the whole tree.
def handle_info({:tap, {:open, value}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :expanded, MishkaTree.toggle_expand(value, socket.assigns.expanded))}
end

def handle_info({:tap, {:close, value}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :expanded, MishkaTree.toggle_expand(value, socket.assigns.expanded))}
end

# `multiple` is an option here rather than a prop, because the screen owns the
# selection. Remember the tap: it is the anchor the next hold measures from.
def handle_info({:tap, {:pick, value}}, socket) do
  {:noreply,
   socket
   |> Mob.Socket.assign(:selected, MishkaTree.toggle_select(value, socket.assigns.selected, multiple: true))
   |> Mob.Socket.assign(:anchor, value)}
end

# A long press is Shift+click. select_range/4 reads the run off what is on
# screen and drops the rows that cannot be selected.
def handle_info({:tap, {:range, value}}, socket) do
  run = MishkaTree.select_range(@nodes, socket.assigns.expanded, socket.assigns.anchor, value)
  {:noreply, Mob.Socket.assign(socket, :selected, Enum.uniq(socket.assigns.selected ++ run))}
end

# Checking a directory checks what is inside it, which is what the web does.
def handle_info({:tap, {:check, value}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :checked, MishkaTree.toggle_check(@nodes, value, socket.assigns.checked))}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

An async branch answers `on_load_children` rather than `on_expand`, so the fetch and the opening are
two separate decisions:

```elixir
def handle_info({:tap, {:fetch, value}}, socket) do
  Task.start(fn -> fetch_and_send(self_pid, value) end)
  {:noreply, Mob.Socket.assign(socket, :loading, [value])}
end

# When the children land: store them, clear the loader, and open the branch.
def handle_info({:children, value, kids}, socket) do
  {:noreply,
   socket
   |> Mob.Socket.assign(:nodes, put_children(socket.assigns.nodes, value, kids))
   |> Mob.Socket.assign(:loading, [])
   |> Mob.Socket.assign(:expanded, [value | socket.assigns.expanded])}
end
```

## Props

| Prop | Values | Default |
|---|---|---|
| `nodes` | list of node maps | `[]` |
| `id` | string | `"tree"` — prefix for every test tag |
| `expanded` | list of values, or `:all` | `[]` |
| `selected` / `checked` / `loading` | lists of values | `[]` — all live in the screen |
| `with_checkboxes` | boolean | `false` |
| `check_strictly` | boolean | `false` — do not cascade to descendants |
| `with_expand_icon` | boolean | `true` |
| `expand_icon` / `collapse_icon` | strings | `"▸"` / `"▾"` |
| `loader_icon` | string | `"…"` — drawn on a row that is in `loading` |
| `with_lines` | boolean | `false` — guide lines per level |
| `level_offset` | number | `18` — indent per depth |
| `expand_on_click` | boolean | `true` — a row tap toggles a branch |
| `select_on_click` | boolean | `true` — a row tap selects anything else |
| `allow_range_selection` | boolean | `true` — a hold reports `on_range_select` |
| `on_expand` / `on_collapse` | event tags | `{:tap, {tag, value}}` |
| `on_select` / `on_check` | event tags | `{:tap, {tag, value}}` |
| `on_load_children` | event tag | first tap on a `has_children` branch |
| `on_range_select` | event tag | a long press on a row |

Helpers: `visible/2` (the rows actually on screen), `expanded_values/1` (what `:all` means),
`check_state/4`, `toggle_check/4`, `toggle_expand/3`, `toggle_select/3`, `select_range/4`,
`subtree_values/2`, and the tag builders `row_tag/2` · `toggle_tag/2` · `check_tag/2` ·
`state_tag/3`.

The `<:expand_icon>` and `<:loader>` slots become the glyph props above — a slot renders arbitrary
markup, and what a native row can actually vary is the character.

Not ported: `draggable` / `with_drag_handle` / `allow_drop` / `on_drag_drop` and `<:drag_icon>`, the
`expand_on_space` / `check_on_space` keyboard attrs and the rest of the APG key map,
`keep_mounted`, `clear_selection_on_outside_click`, `aria_label` / `drag_handle_label`, `name`,
`on_target`, the `*_class` attrs, and the `<:node>` slot — a node's `:icon` and `:meta` keys are the
parts of a custom label a row has room for.

## Seven things to know

**The layout is flat, deliberately.** The web nests `<ul>` inside `<li>`; the obvious port is
nested `Column`s, and it is the wrong shape — every level costs a layout node whether or not it is
expanded. `visible/2` flattens the hierarchy into exactly the rows on screen, each with its depth,
and the component renders one flat `Column` of indented rows. A collapsed branch costs one row
instead of a hidden subtree — which is also why `keep_mounted` has nothing to port: there is no
hidden subtree to keep.

**A tap does one thing.** On the web a click can expand *and* select, because the engine handles
the event and then decides. A Mob node carries a single `on_tap`, so the row picks: a branch that
may expand expands, and everything else selects. The disclosure keeps its own handler either way,
so `expand_on_click: false` still leaves the tree navigable. A `selectable: false` header always
toggles its branch, whatever `expand_on_click` says — that is what the web does with a category
heading, and it is the only way a heading can be a row without pretending to be a destination.

**`select_on_click` defaults to `true` here, and to `false` on the web.** A pointer has a second
button and a modifier key to spare; a finger has neither, and a row that reports nothing when
tapped is dead UI on a phone. It is still a prop — set it `false` on a checkbox tree, where the
selection is the checkbox.

**A long press is Shift+click.** Range selection is the one APG behaviour that survived the loss of
the keyboard, because a row has exactly one gesture left. Hold one and `on_range_select` fires;
`select_range/4` turns your anchor and that value into the run between them, read off `visible/2`
so it follows what the reader can see. Rows that cannot be selected — disabled, or a header — drop
out of the middle rather than joining. The plain tap survives untouched: `combinedClickable` takes
both handles.

**`multiple` is not a prop, it is an option.** The tree is controlled, so the screen owns
`selected` and the mode belongs to the reducer: `toggle_select(value, selected, multiple: true)`
adds and removes, without it a tap replaces and a second tap on the sole selection clears it.

**`check_strictly` reaches the indicator, not only the reducer.** A parent's checkbox is normally
derived from its leaves — checked when they all are, **indeterminate** when only some, shown as a
dash rather than only a colour so it survives a colourblind reading. Strict mode reports the
parent's own membership instead. Without that, a strict tick went into the list and the box it was
made in stayed empty, and the second tap could never turn it off.

**Every part carries an `:id`, and the stateful ones carry the state.** Mob turns `:id` into a
native testTag. The tap targets keep stable names — `<id>-row-<value>`, `<id>-toggle-<value>`,
`<id>-check-<value>` — because a target renamed by the act of using it can only be used once. The
state goes on the parts *inside* them: `<id>-<value>-open`/`-closed` on the arrow,
`-selected`/`-idle` on the label, `-checked`/`-mixed`/`-empty` on the indicator, `-loading` on the
loader. Nothing else in the row is readable: an arrow is `▸` on every branch alike, and selection
is a tint. Rows and controls are tappable, and a clickable node merges its children's semantics —
so a device test reaches the state tags with `useUnmergedTree = true`.

## Known platform gap

**No drag and drop.** `draggable`, `with_drag_handle`, `allow_drop` and `on_drag_drop` have no
port. Mob's only drag gesture belongs to a `:canvas`, that canvas must be STATIC, and a tree that
reorders is a tree that redraws — the two requirements cancel out. Reordering belongs to an edit
mode with move-up / move-down controls until a bridge exposes a real drag on a laid-out node.

**No keyboard, so no key map.** `expand_on_space`, `check_on_space` and the whole APG arrow/Home/End
navigation describe a focus ring the platform does not give a component. Range selection is the one
behaviour of the set that ported, and it ported onto a gesture rather than a key.

**No outside, and no form.** `clear_selection_on_outside_click` needs a document to click outside
of; clear the selection from your own control instead. `name` posts the checked values natively on
the web — here `checked` is already a list in your assigns, which is the whole of what the form
field was for.

**`weight` is read nowhere in the iOS renderer** (`development/mob/IOS_TODO.md`, item 13). The
label is the row's one weighted child, so on Android it absorbs the slack and pushes `:meta` to the
right edge; on iOS both fall back to intrinsic widths and a long name crowds the note. **`max_lines`
is not read on iOS either** (item 9), so a label too long for its row wraps character by character
there instead of ellipsising.

**No accessibility labels.** `aria_label` and `drag_handle_label` have no channel. The test tags are
not a substitute — they are invisible to a screen reader.

## Related
`tree_select` (a trigger showing the selection with a tree in a panel beneath — it renders whatever
tree you hand it), `checkbox` (what the checkboxes are), `accordion` (one level, not a hierarchy),
`context_menu` (the other component built on a long press).
