# action_icon (mob)

A compact icon-only button — the ⋯ on a row, the ← in a header, the ✕ on a card. See
[README](README.md) for the event shapes every Mob component shares.

## Generate
`mix mishka.ui.gen.mob action_icon` → `lib/<app>/components/action_icon.ex`, tag `<ActionIcon />`.
With `--module-prefix mishka_` it is `<MishkaActionIcon />`.

## What it renders

```
box    width/height: size, align: :center, corner_radius from shape   → on_tap
└── text   the glyph, or your children
```

## Example

```elixir
def render(assigns) do
  ~MOB"""
  <Row>
    <MishkaActionIcon icon="⋯" on_tap={:menu} />
    <MishkaActionIcon icon="←" variant={:filled} shape={:circle} on_tap={:back} />
  </Row>
  """
end

# An icon button has no value of its own, so the tag IS the message. Give each
# one its own — three buttons sharing :tap arrive identically and name nothing.
def handle_info({:tap, :menu}, socket) do
  {:noreply, Mob.Socket.assign(socket, :menu_open, true)}
end

def handle_info({:tap, :back}, socket), do: {:noreply, Mob.Socket.pop_screen(socket)}

def handle_info(_msg, socket), do: {:noreply, socket}
```

For a list, put the row's identity in the tag: `on_tap={{:delete, item.id}}` arrives as
`{:tap, {:delete, 7}}`.

## Props

| Prop | Values | Default |
|---|---|---|
| `icon` | string | `nil` — children override it |
| `on_tap` | event tag | `{:tap, tag}` |
| `disabled` | boolean | `false` |
| `size` | number | `40` — the tap target, not the glyph |
| `variant` | `:plain` · `:filled` | `:plain` |
| `shape` | `:rounded` · `:circle` | `:rounded` |
| `color` | colour token / ARGB | `:on_surface` |
| `background` | colour token / ARGB | `:surface_raised` — only when `variant: :filled` |

Helper: `radius(shape, size)` → `size / 2` for `:circle`, `:radius_md` otherwise.

Not ported: `label` (an `aria-label` — Mob exposes no accessible name on a box) and `type`
(submit/reset is form plumbing).

## Three things to know

**`size` is the tap target, not the glyph.** It defaults to **40** deliberately. An icon button
drawn to fit its glyph is a ~16 dp target, well under the ~44 dp both platforms ask for, and it is
the most common way icon buttons end up frustrating on a phone. Shrinking it is a decision you
make, not one the default makes for you — the glyph stays `:lg` either way.

**`background` does nothing while `variant` is `:plain`.** A plain icon is `:transparent` by
design, so setting a fill without also setting `variant: :filled` renders exactly as before and
raises nothing. If your colour is not showing, this is why.

**`disabled` drops the handler rather than guarding it.** A disabled icon is wired to nothing, so
no event is sent and none needs ignoring — and the glyph goes `:muted`, which overrides `color`.

## Related
`close_button` — this component with `icon: "✕"` and `shape: :circle` applied via `Map.put_new/3`,
so it takes every prop here and you can still override both. It exists because "close" appears
everywhere and deserves one spelling.

```elixir
~MOB"<MishkaCloseButton on_tap={:dismiss} />"
```
