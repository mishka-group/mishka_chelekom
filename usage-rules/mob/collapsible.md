# collapsible (mob)

A trigger that shows and hides **one** region — the WAI-ARIA disclosure pattern. See
[README](README.md) for the event shapes every Mob component shares.

## Generate
`mix mishka.ui.gen.mob collapsible` → `lib/<app>/components/collapsible.ex`, tag
`<Collapsible />`. With `--module-prefix mishka_` it is `<MishkaCollapsible />`.

## Collapsible or accordion?

They render the identical row, and the difference is the **event shape**.

| | collapsible | [accordion](accordion.md) |
|---|---|---|
| regions | exactly one | many |
| `open` | a boolean | a list of ids |
| event | `{:tap, tag}` | `{:tap, {tag, item_id}}` |
| has | — | `multiple`, `collapsible`, per-item `disabled` |

An accordion widens its tag so one handler can serve many rows. That is noise when there is only
ever one region, which is why this is its own component rather than a one-item accordion —
reusing it would leak a multi-item event into a single-item API.

There is also `spoiler`: same idea, but the control sits **under** the content rather than above
it, for "show more" rather than "details".

## What it renders

```
box    fill_width, background, corner_radius
└── column
    ├── box   the trigger — title + chevron          → on_tap
    └── column the region, only when open and non-empty
```

## Example

```elixir
~MOB"""
<MishkaCollapsible title="Details" open={@open?} on_toggle={:toggle}>
  {body()}
</MishkaCollapsible>
"""

# A bare tag: there is only one region, so nothing needs identifying.
def handle_info({:tap, :toggle}, socket) do
  {:noreply, Mob.Socket.assign(socket, :open?, not socket.assigns.open?)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

The open state lives in **your screen** — a composite is a pure function of its props.

## Props

| Prop | Values | Default |
|---|---|---|
| `title` | string | `nil` |
| `open` | boolean | `false` — lives in the screen |
| `disabled` | boolean | `false` — wires no handler |
| `on_toggle` | event tag | `{:tap, tag}` |
| `chevron` | boolean | `true` |
| `background` | colour token / ARGB | `:surface_raised` |
| `color` | colour token / ARGB | `:on_surface` — title and chevron |
| `corner_radius` | radius token / number | `:radius_md` |
| `padding` | spacing token / number | `:space_md` |

Not ported: `id` and the `*_class` attrs, and `hidden_until_found` — it exists so a browser's
find-in-page can reveal collapsed text, and there is no find-in-page over native views.

## Three things to know

**Set `color` whenever you set `background`.** The default ink is `:on_surface`, which is the
theme's colour for a *theme* surface — and the moment you pass your own `background` it stops
being one. A violet panel with the default ink keeps near-black text, and the title becomes hard
to read. `mark` learned the same lesson, which is why its fill and ink are a matched pair.

**`disabled` wins over `color`.** A disabled row goes `:muted` whatever you asked for, because it
should read as inert first and branded second. It also wires no handler at all, so nothing is sent
and nothing needs ignoring.

**The trigger is a Box, not a Button.** A Material Button centres its label, and a disclosure
header has to read from the leading edge. `on_tap` is applied as a clickable modifier to every
node type *except* button, so a tappable Box behaves identically with the right alignment.

## Related
`accordion` (many regions, one open set), `spoiler` (control below the content), `tree` (a
hierarchy rather than a flat region).
