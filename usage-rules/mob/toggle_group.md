# toggle_group (mob)

A row of toggle buttons sharing one selection, in single or multiple mode. See
[README](README.md) for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob toggle_group` → `lib/<app>/components/toggle_group.ex`, tag
`<ToggleGroup />`. With `--module-prefix mishka_` it is `<MishkaToggleGroup />`.

## What it renders

```
row | column  fill_width
└── <MishkaToggle /> per item, separated by `space`
```

It **composes `toggle`**, so a lone toggle and a grouped one are the same button, and the group has
no look of its own. Every styling prop the Toggle understands — `color`, `text_color`, `background`,
`label_color`, `padding`, `corner_radius`, `border_color`, `border_width`, `text_size` — is passed
straight through to each item. You style the group by styling its buttons.

## Example

```elixir
~MOB"""
<MishkaToggleGroup value={@align} on_change={:align} id="align">
  <MishkaToggleGroupItem id={:left} label="Left" />
  <MishkaToggleGroupItem id={:center} label="Center" />
  <MishkaToggleGroupItem id={:right} label="Right" />
</MishkaToggleGroup>
"""

# press/3 is the reducer. In single mode, pressing the pressed one CLEARS.
def handle_info({:tap, {:align, id}}, socket) do
  next = MishkaToggleGroup.press(socket.assigns.align, id, false)
  {:noreply, Mob.Socket.assign(socket, :align, next)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

## Items

An item is a slot child: `<MishkaToggleGroupItem id={:left} label="Left" />`, taking `id` (required
— what `on_change` reports and the stem of the testTag), `label` and `disabled`.

`item/3` builds the identical node — `item(id, label, disabled: false)` — so the two forms mix
freely inside one group. Write the tags out when you are writing the items out, and reach for the
function when they come from data:

```elixir
~MOB"""
<MishkaToggleGroup value={@view} on_change={:view}>
  {Enum.map(@views, fn {id, label} -> MishkaToggleGroup.item(id, label) end)}
</MishkaToggleGroup>
"""
```

### A segmented bar

There is no segmented-control component; a segmented bar is this one, styled. No gap, borderless
items, a transparent idle fill, wrapped in a rounded track you draw yourself:

```elixir
~MOB"""
<Box fill_width={false} border_width={1} border_color={:border} corner_radius={9} padding={3}>
  <MishkaToggleGroup
    value={@align}
    on_change={:align}
    space={0}
    padding={10}
    corner_radius={6}
    border_width={0}
    background={:transparent}
    fill_width={false}
  >
    <MishkaToggleGroupItem id={:left} label="Left" />
    <MishkaToggleGroupItem id={:center} label="Center" />
    <MishkaToggleGroupItem id={:right} label="Right" />
  </MishkaToggleGroup>
</Box>
"""
```

Keep the items **inset** from the track rather than flush to its corners: `corner_radius` is a
single number on both renderers, so a flush first or last segment would square off the track's
rounded ends. The 3dp of track padding is what avoids that.

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | id, list of ids, or `nil` | `nil` — a list in multiple mode |
| `multiple` | boolean | `false` |
| `on_change` | event tag (atom) | — sent as `{:tap, {tag, item_id}}` |
| `disabled` | boolean | `false` — disables every item |
| `orientation` | `:horizontal` / `:vertical` | `:horizontal` |
| `space` | number | `8` — `0` joins them into one bar |
| `fill_width` | boolean | `true` — the *container's* width |
| `id` | string | `nil` — prefix for each item's test tag |
| styling props | see `toggle` | forwarded to every item |

Helpers: `press/3`, `pressed?/2`.

Not ported: `name`, `form` (form plumbing), `loop` (arrow-key focus — there is no focus ring to
move) and the `*_class` attrs.

## Five things to know

**Single mode has an empty state, and that is the whole point.** Pressing the pressed button
**clears** the group back to `nil`. That is the difference from a `radio_group`, which cannot be
cleared, and from a segmented control, which always keeps a selection. It is one line in `press/3`,
so it is exactly the kind of thing that gets "simplified" into a radio by accident — use the helper.

**`value` changes shape with `multiple`.** A list in multiple mode, a bare value in single mode,
matching the web component's `value` attr. `pressed?/2` handles both, so ask it rather than
pattern-matching the assign yourself.

**Two different `fill_width`s.** The group's own prop is the **container's** width; each item's is
set for you from the orientation. Horizontally an item must hug — one that fills takes the whole row
and pushes its siblings off the screen. Stacked, items fill so they share one width instead of
forming a ragged staircase. Set the group's `fill_width={false}` when you wrap it in a track, or the
track stretches to the screen edge around three short buttons.

**`id` carries the state, because pressed is only a colour.** Given `id="align"`, the `:center` item
is tagged `"align-center-pressed"` or `"align-center-idle"`. A pressed button differs by fill alone
and colour is not in the accessibility tree, so those tags are all a device test can read. Pass
`useUnmergedTree = true`.

**`space={0}` emits no spacer at all**, rather than a zero-sized one. A Spacer whose size is `0` is
not a 0pt gap on iOS — `fixedSize == 0` means "fill the available space", so the buttons would be
flung apart instead of joined, which is the opposite of what `space={0}` is for.

## Known platform gap

On **iOS** a Box ignores `fill_width` entirely, so a hugging item or a hugging track still spans its
parent — `development/mob/IOS_TODO.md` item 6. A `fill_width` Row also centres its content there
(item 8). Android is correct.

## Related
`toggle` (one button on its own), `radio_group` (pick exactly one, never none), `chip` (the same
choice as compact labels), `checkbox_group` (pick any, with a select-all parent).
