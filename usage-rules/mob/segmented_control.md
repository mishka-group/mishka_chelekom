# segmented_control (mob)

A joined strip of options where exactly one is always selected. See [README](README.md) for the
rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob segmented_control` → `lib/<app>/components/segmented_control.ex`, tag
`<SegmentedControl />`. With `--module-prefix mishka_` it is `<MishkaSegmentedControl />`.

## What it renders

```
column  fill_width
├── text  the heading            ← omitted when absent
└── box  the track (fill_width: false, background, corner_radius, track_padding)
    └── row
        └── box  per segment (fill_width: false, padding, segment_radius, on_tap)
            └── text  the label
```

## Which of the three do you want?

| | Re-tapping the selected one | Can be empty? |
|---|---|---|
| `segmented_control` | **nothing happens** | never |
| `radio_group` | keeps it selected | not once chosen |
| `toggle_group` (single) | **clears it** | yes |

That is the whole reason `select/2` exists and simply returns the tapped id: the rule is "always
something", and stating it beats each screen rediscovering it. When an empty selection is
meaningful, you want `toggle_group`.

## Example

```elixir
~MOB"""
<MishkaSegmentedControl value={@view} on_change={:view} id="view">
  {[option(:day, "Day"), option(:week, "Week"), option(:month, "Month")]}
</MishkaSegmentedControl>
"""

def handle_info({:tap, {:view, id}}, socket) do
  next = MishkaSegmentedControl.select(socket.assigns.view, id)
  {:noreply, Mob.Socket.assign(socket, :view, next)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

Options are children built with `option/3`: `option(id, label, disabled: false)`.

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | option id | first option — an unknown id falls back to the first |
| `label` | string | `nil` — heading above the strip |
| `on_change` | event tag (atom) | — sent as `{:tap, {tag, option_id}}` |
| `disabled` | boolean | `false` — disables every segment |
| `color` | colour token / ARGB int | `:primary` — the selected fill |
| `text_color` | colour token / ARGB int | `:on_primary` — the selected label |
| `label_color` | colour token / ARGB int | `:on_surface` — an unselected label |
| `background` | colour token / ARGB int | `:surface_raised` — the track |
| `padding` | spacing token / number | `:space_sm` — inside each segment |
| `track_padding` | number | `3` — inset between track and segments |
| `corner_radius` | radius token / number | `:radius_md` — the track |
| `segment_radius` | radius token / number | `:radius_sm` — a segment |
| `border_color` / `border_width` | colour / number | `nil` / `0` |
| `text_size` | text token | `:base` |
| `fill_width` | boolean | `false` |
| `id` | string | `nil` — prefix for each segment's test tag |

Helpers: `select/2`, `selected/2`, `option/3`.

Not ported: `name` (form plumbing) and the `*_class` attrs.

## Five things to know

**There is always a selection, including before the user picks one.** `selected/2` falls back to the
first option when `value` is `nil` or names an option that is not there, so the strip never renders
blank. Do not add your own "nothing selected" branch — it is unreachable, and it will disagree with
what the control paints.

**Styling is yours.** Like the headless original the component ships no look; every visual is a prop
with a legible default. There is no separate "pill" or "outlined" variant — those are prop
combinations, and the showcase builds both from the same component.

**It hugs its labels, and so do its segments.** A Box given neither a width nor `fill_width` fills
its parent, which made the first segment eat the whole strip and the track stretch to the screen
edge. Both hug now. `fill_width={true}` makes the *track* span its container, but the **segments
stay content-sized** and cluster at the leading edge — equal widths need layout `weight`, which
Compose has and Mob's iOS mapping does not, so a weighted strip would be right on Android and
collapse on iOS. The Tabs port makes the same compromise for the same reason.

**`disabled` greys the selection rather than hiding it.** A locked control still shows which option
it is locked into, and disabling wires no handler, so it is inert rather than merely grey. A single
option can be disabled on its own with `option(:archive, "Archive", disabled: true)`.

**`id` carries the state, because selection is only a colour.** Given `id="view"`, the `:week`
segment is tagged `"view-week-selected"` or `"view-week-idle"`. Nothing in the accessibility tree
distinguishes a selected segment otherwise. Pass `useUnmergedTree = true` when reading it: a tappable
segment merges its label's semantics over its own tag.

## Known platform gap

On **iOS** a Box ignores `fill_width` entirely, so neither the track nor its segments hug —
`development/mob/IOS_TODO.md` item 6. A `fill_width` Row also centres its content there (item 8).
Android is correct.

## Related
`toggle_group` (the same strip, but clearable), `radio_group` (pick one from a list, with labels),
`tabs` (navigation rather than a value), `chip` (a filter you can turn off).
