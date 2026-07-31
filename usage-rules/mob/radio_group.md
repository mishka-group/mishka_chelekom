# radio_group (mob)

A labelled set of mutually exclusive options. See [README](README.md) for the rules every Mob
component shares.

## Generate
`mix mishka.ui.gen.mob radio_group` → `lib/<app>/components/radio_group.ex`, tag `<RadioGroup />`.
With `--module-prefix mishka_` it is `<MishkaRadioGroup />`.

## What it renders

```
column  fill_width
├── text  the group label            ← omitted when absent
├── spacer(10)
└── column | row  the options, spaced by `space`
    └── <MishkaRadio /> per option
```

It **composes `radio`** rather than redrawing the circle, so a lone radio and a grouped one are the
same control. What the group adds is the three things a lone radio cannot know about itself: which
option is selected, a group heading, and a group-wide `disabled` that cascades.

## Example

```elixir
~MOB"""
<MishkaRadioGroup label="Plan" value={@plan} on_change={:plan} id="plan">
  {[
    option(:free, "Free"),
    option(:pro, "Pro"),
    option(:team, "Team", disabled: true)
  ]}
</MishkaRadioGroup>
"""

# Every option reports the SAME tag widened with its own id, so one clause
# serves the group — that is what replaces the browser's shared `name`.
def handle_info({:tap, {:plan, id}}, socket) do
  next = MishkaRadioGroup.select(socket.assigns.plan, id)
  {:noreply, Mob.Socket.assign(socket, :plan, next)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

Options are children built with `option/3`: `option(id, label, disabled: false)`.

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | option id | `nil` — the selected option |
| `label` | string | `nil` — group heading |
| `on_change` | event tag (atom) | — sent as `{:tap, {tag, option_id}}` |
| `disabled` | boolean | `false` — disables every option |
| `orientation` | `:vertical` / `:horizontal` | `:vertical` |
| `space` | number | `12` — gap between options |
| `color` / `size` | see `radio` | — passed to every option |
| `id` | string | `nil` — prefix for each option's test tag |

Helper: `select/2`.

Not ported: `name`, `required`, `form` (HTML form plumbing) and the `*_class` attrs. `readonly`
collapses into `disabled`.

## Five things to know

**One handler serves the group.** Each option widens the group's `on_change` with its own id, so
`{:tap, {:plan, :pro}}` arrives whichever option was tapped. Do not hand-build that pair — the group
uses `Event.handler/2` because by the time a composite tag reaches the component it has *already*
been widened to `{screen_pid, tag}`, and pairing that with an id yields `{{pid, tag}, id}`, which the
renderer registers and no `handle_info` clause will ever match.

**`select/2` is the rule, and it is deliberately boring.** It returns the tapped id — including when
that id is already selected, so re-tapping keeps the selection rather than clearing the group. That
is exactly where a radio group differs from a checkbox, and it is a single line, so it is easy to
"simplify" into a toggle by accident. Use the helper.

**`disabled` cascades, and an option can opt out on its own.** A group-wide `disabled` disables every
option; `option(:team, "Team", disabled: true)` disables just that one. Either way disabling means
*no handler is wired*, so the option is inert rather than merely grey — a control that looks disabled
and still reports is the failure mode worth watching for.

**`orientation={:horizontal}` also stops each option from filling.** A radio's row spans its parent
by default, so the label joins the tap target. Laid side by side that is fatal: the first option
takes the entire width and the rest are pushed off-screen — present in the tree, invisible on the
device. The group passes `fill_width: false` to every option when it lays them in a Row, which is
why you never have to think about it here but *do* if you build the row yourself.

**`id` makes one option addressable.** Given `id="plan"`, the `:pro` option's ring is tagged
`"plan-pro-selected"` or `"plan-pro-empty"`. Without a group id the options stay untagged, because
there is nothing to prefix with. The state has to live in the tag — see [radio](radio.md) for why.

## Related
`radio` (one option on its own), `checkbox_group` (pick any of a set), `chip` (the same choice as
compact labels), `switch` (a setting rather than a choice).
