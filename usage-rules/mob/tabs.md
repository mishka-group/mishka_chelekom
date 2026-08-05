# tabs (mob)

A tab strip with one visible panel. See [README](README.md) for the rules every Mob component
shares.

## Generate
`mix mishka.ui.gen.mob tabs` → `lib/<app>/components/tabs.ex`, tags `<Tabs>` and `<Tab>`.
With `--module-prefix mishka_` they are `<MishkaTabs>` and `<MishkaTab>`.

## What it renders

```
column  fill_width, carries `id`
├── scroll   axis: horizontal — the strip, <id>-strip
│   └── row      one trigger per tab, <id>-tab-<tab_id>-<state>
└── column   the active tab's own children, <id>-panel
```

## Example

```elixir
~MOB"""
<MishkaTabs active={@tab} on_change={:pick} id="main">
  <MishkaTab id={:overview} label="Overview">
    <Text text="What this thing is." />
  </MishkaTab>
  <MishkaTab id={:specs} label="Specs">
    <Text text="How big it is." />
  </MishkaTab>
  <MishkaTab id={:support} label="Support">
    <Text text="Who to ask." />
  </MishkaTab>
</MishkaTabs>
"""

# One clause serves every tab — the message carries the tab's own id.
def handle_info({:tap, {:pick, id}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :tab, id)}
end
```

## Props

| Prop | Values | Default |
|---|---|---|
| `active` | tab id | first tab — a stale id falls back rather than showing nothing |
| `on_change` | event tag (atom) | — sent as `{:tap, {tag, tab_id}}` |
| `indicator` | boolean | `true` — underline the active tab |
| `color` | colour token / ARGB int | `:primary` — active label and underline |
| `space` | number | `18` — gap between tabs |
| `scrollable` | boolean | `true` — the strip drags sideways when the tabs overflow |
| `id` | string | `nil` — test tags, see below |

Per tab (`<MishkaTab>` props): `id` (defaults to its index), `label`, `disabled`. A tab's children
are its panel.

**Tags or a list, whichever suits.** `<MishkaTab>` is a slot tag — matched on `:type` among the
parent's children and consumed by `expand/3`, so it never reaches the renderer. `tab/4` builds the
identical node, which is what you want when the tabs come from data:

```elixir
<MishkaTabs active={@tab} on_change={:pick}>
  {Enum.map(@folders, fn {id, label, body} -> tab(id, label, body) end)}
</MishkaTabs>
```

Helpers: `active/2`, `tab/4`, `strip_id/1`, `tab_id/3`, `panel_id/1`.

Not ported: `orientation: "vertical"`, `activate_on_focus` (there is no focus ring to follow),
`default_value` (the screen holds the state, so "uncontrolled" has no meaning) and the `*_class`
attrs.

## Five things to know

**The strip scrolls, because a Row cannot wrap.** This shipped as a bare `Row`, so the fifth tab —
or any set of long labels — was drawn past the screen edge and could never be reached. It is a
horizontal `Scroll` now: drag it with a finger. The bug was invisible on the showcase page because
every example there happened to fit, which is the kind of thing only a device shows you.

**Do not reach for Mob's native `tab_bar`.** On Android it is a Material `NavigationBar` pinned to
the bottom of the screen; on iOS a SwiftUI `TabView`. That is app-level navigation, not an inline
strip, and neither scrolls sideways. This component is built from `Row`, `Box` and `Text` for that
reason.

**The inner Row must not fill.** A `fill_width` Row inside a horizontal `Scroll` is pinned to the
viewport and there is nothing left to scroll. `scrollable: false` restores the old filling Row for
strips that genuinely fit.

**One handler serves every tab.** `on_change` sends `{:tap, {tag, tab_id}}`, so you match the strip
once and read the id from the message. Without `on_change` the strip renders identically and does
nothing at all — no warning, because a decorative strip is a legitimate thing to want.

**The state is in the tag, because colour is not in the tree.** A tab says which one it is with a
colour and a 2dp underline, and a device test can read neither. With an `id` set the triggers are
`<id>-tab-<tab_id>-active` / `-idle` / `-disabled`, so "which tab is selected" is a tag query. Note
the trigger is a tappable Column, which **merges** its children's semantics — tag queries need
`useUnmergedTree = true`.

## Related
`segmented_control` (a small fixed set of choices, not panels), `accordion` (many panels open at
once), `nav_link`, `scroll_area` (what the strip is built on).
