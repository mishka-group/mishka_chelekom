# toast (mob)

Transient messages stacked at an edge of the screen. See [README](README.md) for the rules every
Mob component shares.

## Generate
`mix mishka.ui.gen.mob toast` → `lib/<app>/components/toast.ex` plus a `Toast.Queue` submodule, tag
`<Toast />`. With `--module-prefix mishka_` it is `<MishkaToast />`.

## What it renders

A viewport stretched over the whole screen, with the cards pinned to one edge by a flexible spacer.

```
box  fill_width, fill_height, padding
└── column  fill_width, fill_height
    ├── spacer  weight: 1        ← only when position: :bottom
    ├── column  the cards, separated by spacer(space)
    │   └── box  per card
    │       └── row
    │           ├── box  width: 4   the accent bar
    │           ├── box  weight: 1  title/description or your body
    │           └── the ✕            width: 32
    └── spacer  weight: 1        ← only when position: :top
```

Return it from a screen's root `:box` or a showcase's `overlay/1`, the same way Drawer and Dialog
overlay the page. With an empty list it renders a bare `<Column />`, so it costs nothing when idle.

**This is the web component's own layout.** The headless toast ships no CSS — positioning and the
collapsible stack are entirely consumer CSS, and the JS engine only writes layout vars
(`--toast-index`, `--toast-offset-y`). Unstyled, its `<ol>` of `<li>` is a plain vertical list,
which is what you see above. The layered "peek behind, scale down, fan out on hover" stack people
picture is a stylesheet in Chelekom's *web showcase*, and it does not port: it needs
`transform: scale` and `opacity`, which Mob has on neither Box nor Text, and its triggers are
pointerenter/focusin, which Mob has at all only inside text inputs.

## Example

```elixir
# The viewport goes over the page, not in it.
def render(assigns) do
  ~MOB"""
  <Box fill_width={true} fill_height={true}>
    {page(assigns)}
    <MishkaToast toasts={@toasts} on_dismiss={:drop} position={:bottom} />
  </Box>
  """
end

# The ✕ sends {:tap, {tag, toast_id}}, so ONE clause serves every card.
def handle_info({:tap, {:drop, id}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :toasts, Queue.dismiss(socket.assigns.toasts, id))}
end

# Pushing applies limit and dedup_key; stamp :at if you want it to expire.
def handle_info({:tap, :save}, socket) do
  entry = %{
    id: System.unique_integer([:positive]),
    title: "Saved",
    variant: :success,
    at: System.monotonic_time(:millisecond)
  }

  toasts = Queue.push(socket.assigns.toasts, entry, limit: 3, dedup_key: :title)
  {:noreply, Mob.Socket.assign(socket, :toasts, toasts)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

## Props

| Prop | Values | Default |
|---|---|---|
| `toasts` | list of maps | `[]` |
| `position` | `:top` · `:bottom` | `:bottom` |
| `on_dismiss` | event tag (atom) | `nil` — no ✕ is rendered without it |
| `close_icon` | string | `"✕"` |
| `padding` | spacing token / number | `:space_lg` |
| `space` | number | `10` — gap between cards |

A toast map is `%{id:, title:, description:, variant:, at:, duration:, content:}`. Only `id` really
matters (dismissal needs it). `variant` tints the accent bar — `:info` (default), `:success`,
`:warning`, `:danger`; anything unrecognised falls back to `:info` rather than raising.

## Slots

| Slot | Chelekom | Notes |
|---|---|---|
| `<MishkaToastItem>` | `<:toast>` | A toast written in markup. Renders before the queued ones. |
| `<MishkaToastClose>` | `<:close>` | Content for every card's ✕, replacing `close_icon`. |

```elixir
~MOB"""
<MishkaToast toasts={@toasts} on_dismiss={:drop}>
  <MishkaToastItem id={:welcome} title="Welcome" variant={:info}>
    <Text text="Written in markup, not queued." text_size={:sm} />
  </MishkaToastItem>
  <MishkaToastClose>
    <Text text="Dismiss" text_size={:sm} text_color={:muted} />
  </MishkaToastClose>
</MishkaToast>
"""
```

A `<MishkaToastItem>`'s attrs are the keys of a toast map and its children are the body. A `title`
stays as a header above that body; with no title the body is the whole card, which is the web
`<:toast>` slot's shape. A queued toast can carry a body the same way — put nodes under `:content`
in its map — which is how a dynamic toast gets buttons in it.

Slot tags are matched on `:type` among the children and consumed by `expand/3`, so no marker node
reaches the renderer.

Not ported: the `*_class` attrs, `close_label` (an `aria-label`), the `aria-live` region itself, and
`<:trigger>`. The trigger is architectural rather than an oversight — the viewport is a fill-size
overlay, so a button inside it would sit under an invisible full-screen Box. Put the trigger on the
page.

## Four things to know

**A static item cannot dismiss itself.** It lives in the render tree, never in the screen's list, so
`Queue.dismiss/2` has nothing to remove. Its ✕ still fires — handle that id by flipping whatever
flag renders the markup:

```elixir
def handle_info({:tap, {:drop, :welcome}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :show_welcome?, false)}
end
```

**Timers belong to the screen, never to the component.** A component that started its own timer
would start a fresh one on every render. `Queue.expire/3` is a pure function over the list — drive
it from a tick you own:

```elixir
def handle_info(:sweep, socket) do
  Process.send_after(self(), :sweep, 1_000)
  {:noreply, Mob.Socket.assign(socket, :toasts, Queue.expire(socket.assigns.toasts, 5_000))}
end
```

A toast with no `:at` never expires, and so does one with `duration: 0` — matching the web engine,
where `0` disables auto-dismiss. A toast's own `:duration` overrides the value you pass.

**`limit` drops, it does not hide.** `Queue.push(toasts, t, limit: 3)` keeps the newest three and
discards the rest; the web engine keeps them in the DOM marked `data-limited` so they can reappear.
Hiding is not expressible here — Mob has no opacity on ordinary nodes, so a retained toast would be
a fully opaque card taking up space. If you want the web behaviour, keep the full list yourself and
pass `Enum.take(all, -3)` to the component.

**The card's body takes `weight`, not `fill_width`.** This one shipped as a bug. A Compose `Row`
measures a non-weighted child against the space left over, so a `fill_width` body claimed the whole
row and the trailing ✕ was measured at **width 0** — rendered, in the tree, "clickable" to a test
harness, and impossible to hit with a finger. iOS was fine, because an `HStack` serves its
fixed-size children first, which is exactly what let it survive review. `<Box weight={1}>` is the
fix and the house idiom for any flexible-body-plus-fixed-trailing-control row; Combobox and
NumberField wrap their inputs the same way. It works on both platforms because a Box with no
explicit width defaults to filling — the weighted slot on Android, `maxWidth: .infinity` on iOS.

## Related
`dialog` (blocking, needs an answer), `loading_overlay` (busy rather than done), `empty_state` (the
other component whose actions arrive as nodes), `action_icon` (what the ✕ is).
