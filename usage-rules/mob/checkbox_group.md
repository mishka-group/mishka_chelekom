# checkbox_group (mob)

A labelled set of checkboxes with an optional tristate "select all" parent. See
[README](README.md) for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob checkbox_group` → `lib/<app>/components/checkbox_group.ex`, tag
`<CheckboxGroup />`. With `--module-prefix mishka_` it is `<MishkaCheckboxGroup />`.

## What it renders

```
column  fill_width
├── text  the group label              ← omitted when absent
├── column  the parent block           ← only when select_all is set AND there are items
│   ├── <MishkaCheckbox />  the tristate parent
│   └── box  fill_width, height 1      ← a hairline rule under it
└── column  the items, spaced by `space`
    └── <MishkaCheckbox /> per item
```

It **composes `checkbox`** for both the items and the parent, so the parent is not a special
widget — it is an ordinary checkbox whose `indeterminate` state is *derived* from the selection.

## Example

```elixir
~MOB"""
<MishkaCheckboxGroup
  label="LIBRARIES"
  value={@value}
  select_all={true}
  on_change={:item}
  on_select_all={:all}
  id="langs"
>
  <MishkaCheckboxGroupItem id={:beam} label="BEAM" />
  <MishkaCheckboxGroupItem id={:otp} label="OTP" />
  <MishkaCheckboxGroupItem id={:ecto} label="Ecto" disabled={true} />
</MishkaCheckboxGroup>
"""

@ids [:beam, :otp, :ecto]

# An item tap carries its id. The parent's does not — there is only one parent.
def handle_info({:tap, {:item, id}}, socket) do
  next = MishkaCheckboxGroup.toggle(socket.assigns.value, id)
  {:noreply, Mob.Socket.assign(socket, :value, next)}
end

def handle_info({:tap, :all}, socket) do
  next = MishkaCheckboxGroup.select_all(socket.assigns.value, @ids)
  {:noreply, Mob.Socket.assign(socket, :value, next)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

## Slots

| Slot | Builder | Takes |
|---|---|---|
| `<MishkaCheckboxGroupItem>` | `item/3` | `id`, `label`, `disabled` |

A slot tag has no module and no expander — it is matched on `:type` among the group's children and
consumed by `expand/3`, which routes it back through `item/3`. Tag and builder therefore produce the
**identical** node, so pick by where the rows come from. Write the tags out when you are writing the
rows out; call `item/3` when the rows come from data, where a comprehension is less work than
generated markup and cannot drift from the list:

```elixir
~MOB"""
<MishkaCheckboxGroup value={@value} on_change={:item}>
  {Enum.map(@channels, fn {id, label} -> MishkaCheckboxGroup.item(id, label) end)}
</MishkaCheckboxGroup>
"""
```

No item tag carries its own `on_*`: the group's single `on_change` serves every row, because each
row reports its own id.

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | list of ids | `[]` — the selected ids |
| `label` | string | `nil` — group heading |
| `select_all` | boolean | `false` — render the tristate parent |
| `select_all_label` | string | `"Select all"` |
| `on_change` | event tag (atom) | — sent as `{:tap, {tag, item_id}}` |
| `on_select_all` | event tag (atom) | — sent as `{:tap, tag}`, no id |
| `disabled` | boolean | `false` — disables every row, parent included |
| `space` | number | `12` — gap between rows |
| `color` / `size` | see `checkbox` | passed to every row |
| `id` | string | `nil` — prefix for each row's test tag |

Helpers: `toggle/2`, `select_all/2`, `parent_state/2`.

Not ported: `name` (form plumbing), the `*_class` attrs, and the `indicator_icon` slot — the tick
and dash are drawn by the Checkbox.

## Five things to know

**The two events have different shapes, and that is deliberate.** An item tap arrives as
`{:tap, {tag, item_id}}` because one handler serves every item; the parent arrives as a bare
`{:tap, tag}` because there is only one parent and nothing to disambiguate. Writing a
`{:tap, {:all, _}}` clause for the parent is the mistake to avoid — it never matches, and the
control renders perfectly and does nothing.

**The reducers are the component; use them.** A checkbox group is mostly bookkeeping and the
bookkeeping is where the bugs live, so it is exposed and tested rather than left in each caller's
handler:

- `toggle/2` — add or remove one id, preserving order.
- `select_all/2` — **all**, unless everything is already selected, in which case **none**. A
  partially selected group fills up rather than clearing: the mixed state is asking to be
  completed, not emptied.
- `parent_state/2` — the `{checked?, indeterminate?}` the parent should render.

**You own the id list, so the parent can be scoped.** `select_all/2` and `parent_state/2` both take
the ids as their second argument rather than reading them from the group, so "all" means whatever
you pass. Pass every id for the ordinary case; pass only the enabled ones if you do not want a tap
on the parent to sweep in a disabled row. Whatever you choose, pass the **same** list to both, or
the parent will paint a state its own tap cannot produce.

**`disabled` cascades to the parent too.** A group-wide `disabled` disables every row *and* the
parent; `item(:ecto, "Ecto", disabled: true)` disables just that one. Disabling means no handler is
wired, so the row is inert rather than merely grey — the parent is the row most likely to escape a
cascade, because it is built separately from the items.

**`id` makes rows addressable, because the mark is drawn.** Given `id="langs"`, the `:otp` row is
tagged `"langs-otp-checked"` / `"langs-otp-empty"` and the parent is `"langs-all-mixed"`. A tick
drawn on a canvas has no text and no semantics, so those tags are the only thing a device test can
read; pass `useUnmergedTree = true`, since a tappable Row merges its children's semantics. Without a
group `id` the rows stay untagged.

## Known platform gap

On **iOS** a `fill_width` Row centres its content (the renderer omits `alignment: .leading`), so
each row centres independently and the boxes land at different x positions instead of a straight
left column. Android is correct. The hairline rule under the parent is also invisible on iOS, which
drops a Box's `height` unless a width is set. Both live in the `mob` dependency — see
`development/mob/IOS_TODO.md` items 8 and 1.

## Related
`checkbox` (one box, and the three states), `radio_group` (pick exactly one, never none),
`chip` (the same choice as compact labels), `switch` (a setting rather than a selection).
