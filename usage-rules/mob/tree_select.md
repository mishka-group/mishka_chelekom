# tree_select (mob)

A trigger showing the current selection, with a tree in a panel beneath it. See
[README](README.md) for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob tree_select` → `lib/<app>/components/tree_select.ex`, tag `<TreeSelect>`.
Pulls in `tree` as a sibling, because the panel is empty until you put one in it. With
`--module-prefix mishka_` it is `<MishkaTreeSelect>`.

## What it renders

```
column  fill_width                                   ← <id>
├── box  the trigger, on_tap                         ← <id>-trigger-open / -closed / -disabled
│   ├── box  weight 1
│   │   └── text  the label, or the placeholder      ← <id>-value  /  <id>-placeholder
│   └── text  the ▾ / ▴                              ← <id>-caret
└── box  the panel — your children                   ← <id>-panel, only while `open`
```

Everything inside the panel is yours; normally it is a `tree`. Closed means the panel is **not
rendered at all**, not merely hidden — the web leaves the div in place with `display:none`.

## Example

```elixir
~MOB"""
<MishkaTreeSelect
  label={@picked}
  placeholder="Choose a file…"
  open={@open?}
  on_toggle={:toggle}
  id="ts-file"
>
  {[
    tree(
      nodes: @nodes,
      id: "ts-file-tree",
      expanded: @expanded,
      on_expand: :open_node,
      on_collapse: :close_node,
      on_select: :pick
    )
  ]}
</MishkaTreeSelect>
"""

def handle_info({:tap, :toggle}, socket) do
  {:noreply, Mob.Socket.assign(socket, :open?, not socket.assigns.open?)}
end

# The tree reports the node's VALUE. What the trigger shows is up to you, and
# picking is the one thing that closes the panel — that is the whole difference
# between a tree select and a tree.
def handle_info({:tap, {:pick, value}}, socket) do
  {:noreply,
   socket
   |> Mob.Socket.assign(:picked, value)
   |> Mob.Socket.assign(:open?, false)}
end

# Expanding is not choosing: leave `open?` alone here.
def handle_info({:tap, {tag, value}}, socket) when tag in [:open_node, :close_node] do
  {:noreply,
   Mob.Socket.assign(socket, :expanded, MishkaTree.toggle_expand(value, socket.assigns.expanded))}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

## Props

| Prop | Values | Default |
|---|---|---|
| `label` | string | `nil` — the current selection |
| `placeholder` | string | `"Select…"` — shown when nothing is selected |
| `open` | boolean | `false` — lives in the screen |
| `disabled` | boolean | `false` — mutes the trigger and unwires it |
| `on_toggle` | event tag | — `{:tap, tag}` from the trigger |
| `id` | string | `nil` — tags every part, with the state folded in |

Children are the panel's contents. Helper: `display/2` (the trigger's text).

Not ported: Escape and click-away dismissal (a panel in flow has nothing to click away from) and
the `*_class` attrs.

## Six things to know

**The tree owns the selection; you own the label.** This is a shell, exactly as on the web: it
draws a trigger and a box to put a tree in, and it never touches `label`. The tree's `on_select`
hands you a node **value** — a path, an id — and the trigger shows whatever string you assign, so
mapping a value to a human label is the screen's job, not the component's.

**Picking closes the panel; expanding must not.** Both arrive as taps from the same tree, and a
screen that closes on every event has a select that shuts the moment you open a folder. Only the
`on_select` clause touches `open?`.

**Nothing dismisses the panel but you.** There is no Escape and no outside tap: the panel is in
flow beneath the trigger rather than floating over the page, because Mob has no anchored-overlay
primitive and a floating panel on a phone would cover the trigger it belongs to. Tapping the
trigger again is the dismissal. For a tree too big to sit in the page, put the same tree in a
bottom [`drawer`](drawer.md), which brings a scrim and a dismissal with it.

**Give the tree inside its own `id`.** `MishkaTree`'s `id` defaults to `"tree"`, so two tree
selects on one page hand every row the same tag and a device test can no longer say which panel it
tapped. `id: "<the select's id>-tree"` keeps them apart and reads back obviously.

**`id` carries the state, because everything else here is a colour or a glyph.** The trigger is
`<id>-trigger-open` / `-closed` / `-disabled`, the value is `<id>-value` when something is selected
and `<id>-placeholder` when it is not (the web's `data-placeholder`), and `<id>-panel` simply does
not exist while closed. A disabled trigger reports `-disabled` in place of its open state — being
disabled is otherwise nothing but a muted ink — and the panel's own tag still says whether it is
showing. The trigger merges its children's semantics, so a device test needs `useUnmergedTree =
true` to reach the value and the caret.

**An empty string is not a selection.** `label=""` shows the placeholder, which is what a cleared
form field hands back; `display/2` is that rule as a function, and it falls back for anything that
is not a string rather than rendering `inspect` output into your trigger.

## Known platform gap

**A long selection wraps on iOS instead of ellipsising.** The value sits in a `weight: 1` box with
`max_lines: 1`, because Compose measures a `Row`'s unweighted children first — an unwrapped label
takes the whole row and starves the caret — and a `Text` squeezed narrower than its content wraps
**character by character**. iOS reads neither prop: `weight` is read nowhere in the iOS renderer
(`development/mob/IOS_TODO.md` item 13) and `Text` has no `max_lines` there (item 9). The layout
survives anyway — `MobBox` with no width takes `.frame(maxWidth: .infinity)`, which lands the caret
in the same place — but a whole path in a phone-width trigger becomes two or three lines rather
than one ellipsised one. Keep labels short on iOS, or shorten them yourself before assigning.

## Related
`tree` (what goes in the panel, and where every selection event comes from), `select` (the same
shape over a flat list of options), `combobox` (type to filter), `drawer` (where a large picker
belongs on a phone).
