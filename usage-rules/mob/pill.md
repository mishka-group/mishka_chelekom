# pill (mob)

A compact token — a label, optionally with a trailing ✕. See [README](README.md) for the event
shapes every Mob component shares.

## Generate
`mix mishka.ui.gen.mob pill` → `lib/<app>/components/pill.ex`, tag `<Pill />`. With
`--module-prefix mishka_` it is `<MishkaPill />`.

## Pill or Chip?

A **chip is selected**, a **pill is removed**. A chip carries `checked` and toggles; a pill
carries content and offers a ✕. If you find yourself giving a pill a checked state you want
`chip`.

## What it renders

```
box      corner_radius: :radius_pill, fill_width: false   → on_tap  (the body)
└── row
    ├── text   the label, or your children
    └── row    ✕                                          → on_remove
```

## Example

```elixir
def render(assigns) do
  ~MOB"""
  <MishkaPill label="elixir" with_remove={true} on_remove={{:drop, :elixir}} on_tap={{:pick, :elixir}} />
  """
end

# The body and the ✕ are separate targets carrying separate tags, so one pill
# both selects and dismisses without the two ever colliding.
def handle_info({:tap, {:pick, id}}, socket), do: {:noreply, assign(socket, :picked, id)}

def handle_info({:tap, {:drop, id}}, socket) do
  {:noreply, assign(socket, :tags, List.delete(socket.assigns.tags, id))}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

Both props deliver `{:tap, tag}` — a pill has no value of its own, so **put the identity in the
tag**. `on_remove={:drop}` on ten pills gives you ten identical events and no way to tell which
was dismissed.

## Props

| Prop | Values | Default |
|---|---|---|
| `label` | string | `nil` — children override it |
| `with_remove` | boolean | `false` — render the ✕ |
| `on_remove` | event tag | `{:tap, tag}` from the ✕ |
| `on_tap` | event tag | `{:tap, tag}` from the body |
| `disabled` | boolean | `false` |
| `background` | colour token / ARGB | `:surface_raised` |
| `color` | colour token / ARGB | `:on_surface` |
| `disabled_color` | colour token / ARGB | `:muted` |

Not ported from the web component: `remove_label` (an `aria-label` — Mob exposes no accessible
name on a text node) and the `id` / `*_class` attrs.

## Three things to know

**It hugs its label, and that is a prop.** The root Box passes `fill_width={false}`, which is what
lets several sit in one Row the way they do on the web. A Box with neither `width` nor
`fill_width` **fills its parent** — so a hand-rolled pill comes out a full-width bar and only one
fits per line. If yours does that, this is why.

**On iOS it does not hug.** `MobBox` decodes `fill_width` and never reads it — only an explicit
width stops a Box filling there, and a label's width is not known here — so a pill still spans the
row on iOS. `mishka_chip` hit the same wall and reached the same answer: a `Button` would hug on
both, but Material3's minimum size and content padding make it too big for a pill and clip long
labels, which is worse than being right on one platform. The fix belongs in the dependency
(`development/mob/IOS_TODO.md`, item 6): one line teaching `MobBox` to honour the prop corrects both
components with no Elixir change.

**Rows do not wrap.** Mob has `Box`, `Column` and `Row` and no flow layout, and no geometry is
reported back to `render/1` — nothing can ask how many pills fit. Chunk by a **declared** count
and stack the rows:

```elixir
tags
|> Enum.chunk_every(3)
|> Enum.map(fn chunk ->
  pills = chunk |> Enum.map(&pill_for/1) |> Enum.intersperse(~MOB(<Spacer size={8} />))
  ~MOB"<Row>{pills}</Row>"
end)
|> then(&~MOB"<Column fill_width={true}>{&1}</Column>")
```

`overflow_list` takes a declared count for exactly the same reason. For a bordered box of tokens
beside a text field, reach for `pills_input` rather than building it.

**`disabled` drops the handlers, it does not guard them.** A disabled pill is wired to nothing at
all — body and ✕ both — so no event is sent and none needs ignoring on the receiving end. It also
swaps the label to `disabled_color`.

## Related
`chip` (selectable), `pills_input` (a bordered field holding pills), `tags_input` (owns its
tokens as strings, and renders them as pills for you).
