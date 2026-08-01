# overflow_list (mob)

Items on one row, with the ones that do not fit collapsed into a `+N` counter. See
[README](README.md) for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob overflow_list` → `lib/<app>/components/overflow_list.ex`, tag
`<OverflowList>`. With `--module-prefix mishka_` it is `<MishkaOverflowList>`.

## What it renders

```
row  fill_width, align: center, carries `id`
├── item · spacer · item · spacer · …    the shown children, in priority order
└── box   the "+N" counter — fill_width: false, tappable when on_counter is set
```

## Example

```elixir
~MOB"""
<MishkaOverflowList visible={4} on_counter={:more} id="langs">
  {tag_pills()}
</MishkaOverflowList>
"""

def handle_info({:tap, :more}, socket) do
  {:noreply, Mob.Socket.assign(socket, :visible, socket.assigns.visible + 1)}
end
```

Children are the items, in priority order — the first ones survive.

## Props

| Prop | Values | Default |
|---|---|---|
| `visible` | integer | `3` — how many to show. **Declared, not measured** |
| `min_visible` | integer | `1` — never show fewer, even if `visible` is lower |
| `space` | number | `6` — gap between items, and before the counter |
| `counter_text` | fun/1 or string | `"+N"` — takes the hidden count |
| `on_counter` | event tag | — `{:tap, tag}`; without it the `+N` is inert |
| `id` | string | `nil` — items get `<id>-item-<n>`, the counter `<id>-counter` |

Helpers: `split/2`, `counter_id/1`, `item_id/2`.

Not ported: `on_change` (the web pushes the hidden count on every resize; there is no resize here to
push, and `split/2` already hands you the hidden list) and the `*_class` attrs.

## Four things to know

**The count is declared, not measured — and that is the whole difference from the web.** The web
version watches its container with a `ResizeObserver` and hides items until they fit. Elixir cannot
learn a rendered node's width in Mob: `render/1` is a pure function producing a JSON tree, and there
is no `on_layout`/`on_size` event on either platform. Rather than fake it, this takes `visible`.
The useful cases are usually the ones where you already know the number — "three tags and a +N",
"the last four avatars".

**`split/2` is the whole policy, and it is public.** `{shown, hidden}` — pure, testable, and exactly
where a measured count would plug in unchanged if Mob ever reports geometry. Use it when you want to
know what *would* be hidden without rendering.

**`min_visible` is a floor, not a target.** `visible: 0` still shows one. The web makes the same
guarantee, so a caller cannot accidentally collapse the entire list into a counter.

**The counter hugs because it says so.** It sets `fill_width={false}`. A Box given neither a `width`
nor `fill_width` **fills its parent** — which turned the `+N` pill into a bar stretching across the
rest of the row. This is the single most recurring bug in this library.

## Known platform gap

iOS's `MobBox` never reads `fill_width` at all (`development/mob/IOS_TODO.md` item 6), so the
counter-hugging fix above is Android-only until that lands. On iOS the `+N` still stretches.

## Related
`pill` (what the items usually are), `tags_input`, `chip`, `splitter` (this used to live on its
page).
