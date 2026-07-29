# accordion (mob)

A stack of disclosure items where each header toggles its panel. See
[README](README.md) for the event shapes every Mob component shares.

## Generate
`mix mishka.ui.gen.mob accordion` → `lib/<app>/components/accordion.ex`, tags `<Accordion>` and
`<AccordionItem>`. With `--module-prefix mishka_` they are `<MishkaAccordion>` /
`<MishkaAccordionItem>`.

## Controlled, because a composite is stateless

The web engine keeps open/closed in the DOM. A Mob composite is a pure function of its props, so
**the open set lives in your screen** and comes back in as `open`. Use `toggle/3` rather than
re-deriving the rules — it is where `multiple` and `collapsible` actually live.

```elixir
~MOB"""
<MishkaAccordion open={@faq} on_toggle={:toggled}>
  <MishkaAccordionItem id={:what} title="What is it?">{body()}</MishkaAccordionItem>
  <MishkaAccordionItem id={:how} title="How does it work?">{body()}</MishkaAccordionItem>
</MishkaAccordion>
"""

def handle_info({:tap, {:toggled, id}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :faq, MishkaAccordion.toggle(socket.assigns.faq, id))}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

## Three ways to hear about a toggle — pick one

The web emits two events per click: `on_open_change` on the item (`{value, open}`) and
`on_value_change` on the root (`{value: [...]}`). **A device tap carries no payload, so the tag is
the payload** — and one tap can only send one message. These are therefore alternatives, not
additions. All three are optional; set the one you want.

| prop | message | use it when |
|---|---|---|
| `on_toggle` | `{:tap, {tag, :faq}}` | you already call `toggle/3` |
| `on_open_change` | `{:tap, {tag, :faq, true}}` | you need to know **which way** |
| `on_value_change` | `{:tap, {tag, [:faq, :billing]}}` | you just want the new set |

If you set more than one the richest wins — `on_value_change`, then `on_open_change`, then
`on_toggle` — and a warning is logged, because the others would silently never fire.

**`on_open_change` is the one `on_toggle` cannot replace.** "This trigger was hit" says nothing
about whether the panel is now opening or closing, so lazy-loading a panel body, or firing
analytics only on close, meant recomputing the direction from your own open set:

```elixir
def handle_info({:tap, {:changed, id, true}}, socket), do: {:noreply, load_body(socket, id)}
def handle_info({:tap, {:changed, _id, false}}, socket), do: {:noreply, socket}
```

**`on_value_change` is the least work.** The payload is the next open set, computed with the same
`toggle/3`, so the handler is a bare assign and cannot drift from the component's own `multiple` /
`collapsible` semantics:

```elixir
def handle_info({:tap, {:opened, next}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :open, next)}
end
```

Note it still reports the set the component *would* produce — you remain free to ignore or amend
it, because the open set is yours.

## Props

| Prop | Values | Default |
|---|---|---|
| `open` | list of item ids | `[]` — lives in the screen |
| `multiple` | boolean | `false` |
| `collapsible` | boolean | `true` — `false` keeps one panel always open |
| `disabled` | boolean | `false` — cascades to every item |
| `on_toggle` / `on_open_change` / `on_value_change` | event tags | see above |
| `chevron` | boolean | `true` |
| `background` | colour token / ARGB | `:surface_raised` |
| `corner_radius` | radius token / number | `:radius_md` |
| `padding` | spacing token / number | `:space_md` |
| `space` | number | `8` — `0` joins the items into one block |

Per item: `id` (any term; falls back to its 0-based index), `title`, `disabled`.

Helper: `toggle(open, id, multiple: false, collapsible: true)` → the next open set.

Not ported: `orientation` / `loop` (arrow-key focus), `heading_level` (`<h1>`–`<h6>`),
`hidden_until_found` (find-in-page) and every `*_class`. A phone has no DOM, no CSS cascade and no
roving tab focus.

## Three things to know

**An id is worth setting.** Without one an item is identified by its 0-based index, so inserting a
row above it silently moves the open panel.

**A disabled item wires no handler at all.** It cannot fire rather than firing and being ignored,
so there is nothing to guard on the receiving end. `disabled` on the accordion cascades to all of
them.

**No event prop means inert triggers.** Tapping does nothing, and the panels can then only change
by replacing `open` from the screen. The component logs a warning rather than failing quietly.

## Related
`collapsible` (a single disclosure), `spoiler` (a hidden-until-revealed block).
