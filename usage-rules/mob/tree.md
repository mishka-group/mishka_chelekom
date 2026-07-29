# tree (mob)

Hierarchical data — expandable, selectable, optionally checkable. See [README](README.md) for the
event shapes every Mob component shares.

## Generate
`mix mishka.ui.gen.mob tree` → `lib/<app>/components/tree.ex`, tag `<Tree />`. Pulls in `checkbox`
as a sibling. With `--module-prefix mishka_` it is `<MishkaTree />`.

## Nodes

A node is a map with `:label` and `:value`, optionally `:children`, `:icon`, `:meta` (a trailing
note — a size, a count, a date) and `:disabled`. Nesting is arbitrary.

```elixir
[
  %{label: "lib", value: "lib", icon: "📁", children: [
    %{label: "app.ex", value: "lib/app.ex", icon: "📄", meta: "12 KB"}
  ]},
  %{label: "mix.exs", value: "mix.exs", icon: "📄", disabled: true}
]
```

**Give every node a `value`.** Without one it is identified by its 0-based index, so inserting a
row above it silently moves whichever branch was open.

## Controlled, like the accordion

Every bit of state — `expanded`, `selected`, `checked` — lives in your screen and comes back in as
a prop. The component is a pure function of them.

```elixir
~MOB"""
<MishkaTree
  nodes={@nodes}
  expanded={@expanded}
  checked={@checked}
  with_checkboxes={true}
  on_expand={:open}
  on_collapse={:close}
  on_check={:check}
/>
"""

# Every per-node event arrives as {:tap, {tag, node_value}} — one handler per
# tag serves the whole tree.
def handle_info({:tap, {:open, value}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :expanded, MishkaTree.toggle_expand(value, socket.assigns.expanded))}
end

def handle_info({:tap, {:close, value}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :expanded, MishkaTree.toggle_expand(value, socket.assigns.expanded))}
end

# Checking a directory checks what is inside it, which is what the web does.
def handle_info({:tap, {:check, value}}, socket) do
  next = MishkaTree.toggle_check(@nodes, value, socket.assigns.checked)
  {:noreply, Mob.Socket.assign(socket, :checked, next)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

## Props

| Prop | Values | Default |
|---|---|---|
| `nodes` | list of node maps | `[]` |
| `expanded` / `selected` / `checked` | lists of values | `[]` — all live in the screen |
| `with_checkboxes` | boolean | `false` |
| `check_strictly` | boolean | `false` — do not cascade to descendants |
| `with_expand_icon` | boolean | `true` |
| `with_lines` | boolean | `false` — guide lines per level |
| `level_offset` | number | `18` — indent per depth |
| `on_expand` / `on_collapse` | event tags | `{:tap, {tag, value}}` |
| `on_select` / `on_check` | event tags | `{:tap, {tag, value}}` |

Helpers: `visible/2` (the rows actually on screen), `check_state/3`, `toggle_check/4`,
`toggle_expand/2`, `subtree_values/2`.

Not ported: `draggable` / `allow_drop` (no drag gesture), `allow_range_selection`, the
`*_on_space` keyboard attrs, `has_children` async loading, `keep_mounted`,
`clear_selection_on_outside_click`, and `name` / `id` / `*_class`.

## Four things to know

**The layout is flat, deliberately.** The web nests `<ul>` inside `<li>`; the obvious port is
nested `Column`s, and it is the wrong shape — every level costs a layout node whether or not it is
expanded. `visible/2` flattens the hierarchy into exactly the rows on screen, each with its depth,
and the component renders one flat `Column` of indented rows. A collapsed branch costs one row
instead of a hidden subtree.

**A parent's checkbox reflects its descendants.** Checked when they all are, **indeterminate**
when only some — `check_state/3` computes it, and the indeterminate state shows as a dash rather
than only a colour, so it survives a colourblind reading. `check_strictly: true` turns the cascade
off.

**The checkbox is the real Checkbox component**, not a `☑` glyph — so one inside a tree looks like
one in a form. That is also why `tree` declares `checkbox` as a dependency: generating the tree
offers to build it.

**Every control carries an `:id`.** Mob turns it into a native testTag, and neither the disclosure
arrow (`tree-toggle-<value>`) nor the checkbox (`tree-check-<value>`) has any text — so without
them a device test cannot say which row it means. Every arrow reads `▾` or `▸`.

## Related
`tree_select` (a trigger showing the selection with a tree in a panel beneath — it renders whatever
tree you hand it), `checkbox` (what the checkboxes are), `accordion` (one level, not a hierarchy).
