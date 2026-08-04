# select (mob)

A trigger showing the current choice, and a list to pick from. See [README](README.md) for the rules
every Mob component shares.

## Generate
`mix mishka.ui.gen.mob select` → `lib/<app>/components/select.ex`, tag `<Select />`. With
`--module-prefix mishka_` it is `<MishkaSelect />`.

## What it renders

```
column  fill_width
├── text  the caption               ← omitted when absent
├── box  the trigger — chosen text (or placeholder) + a ▾ / ▴, on_tap
└── <MishkaMenu />  the options, only while `open`
    ├── label  a group heading      ← one per run, when options carry :group
    └── item   an option, ticked with ✓ when chosen
```

The list renders **in flow beneath the trigger**, not floating beside it: the web version anchors
its listbox, and Mob has no anchored positioning (see `popover`). For a long list on a phone, put
the same options in a bottom `drawer` — which is where a native picker belongs anyway.

## Example

```elixir
~MOB"""
<MishkaSelect
  label="TOPPINGS"
  value={@toppings}
  open={@open?}
  multiple={true}
  placeholder="Choose your toppings…"
  on_toggle={:toggle}
  on_select={:pick}
  id="toppings"
>
  <MishkaSelectOption id={:cheese} label="Cheese" group="CLASSIC" />
  <MishkaSelectOption id={:pepperoni} label="Pepperoni" group="CLASSIC" />
  <MishkaSelectOption id={:mushroom} label="Mushroom" group="VEGGIE" />
  <MishkaSelectOption id={:onion} label="Onion" group="VEGGIE" />
</MishkaSelect>
"""

def handle_info({:tap, :toggle}, socket) do
  {:noreply, Mob.Socket.assign(socket, :open?, not socket.assigns.open?)}
end

# toggle/3 returns {value, close?} — BOTH halves matter.
def handle_info({:tap, {:pick, id}}, socket) do
  {value, close?} = MishkaSelect.toggle(socket.assigns.toppings, id, true)

  {:noreply,
   socket
   |> Mob.Socket.assign(:toppings, value)
   |> Mob.Socket.assign(:open?, not close?)}
end
```

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | option id, list, or `nil` | `nil` |
| `open` | boolean | `false` — lives in the screen |
| `multiple` | boolean | `false` |
| `placeholder` | string | `"Select…"` |
| `label` | string | `nil` — caption above the trigger |
| `disabled` | boolean | `false` |
| `on_toggle` | event tag | — `{:tap, tag}` from the trigger |
| `on_select` | event tag | — `{:tap, {tag, option_id}}` from an option |
| `id` | string | `nil` — tags the trigger and every option |

## Options

An option is a slot child: `<MishkaSelectOption id={:uk} label="United Kingdom" />`, taking `id`
(required — what `on_select` reports and the stem of the testTag), `label`, `disabled` and `group`.

`option/3` builds the identical node — `option(id, label, disabled: false, group: nil)` — so the two
forms mix freely inside one select. Write the tags out when you are writing the options out, and
reach for the function when they come from data:

```elixir
~MOB"""
<MishkaSelect value={@country} open={@open?} on_select={:pick}>
  {Enum.map(@countries, fn {id, label} -> MishkaSelect.option(id, label) end)}
</MishkaSelect>
"""
```

Helpers: `toggle/3`, `display/3`, `group_runs/1`.

Not ported: `name`, `form`, `required`, `readonly` (form plumbing), `side` and `highlight_on_hover`
(no anchoring, no hover) and the `*_class` attrs.

## Five things to know

**`toggle/3` returns `{value, close?}`, and you must use both.** Single mode replaces the value and
**closes**; multiple accumulates and **stays open**, because a multi-select that shut after every
pick would be exhausting. A screen that keeps only the value gets a list that either slams shut on
every tap or hangs open over the rest of the page. That is the single most likely mistake here.

**Groups are runs, not buckets.** `option(:pepperoni, "Pepperoni", group: "CLASSIC")` puts a heading
above the run it starts, and **consecutive** options sharing a group belong to it — the same rule
the web uses. Your order *is* the grouping: two runs of "CLASSIC" separated by a "VEGGIE" render as
three headings, not two merged ones. Nothing is sorted underneath you. `group_runs/1` is the pure
function, and the headings are `MishkaMenu.label/1`, so a grouped select and a grouped menu look the
same.

**`open` lives in the screen, like every other Mob overlay.** The component draws the list when told
to; it has no state of its own. Closed means the options are not rendered at all, not merely hidden.

**A stale value shows itself.** `display/3` falls back to the id's own name when no option matches,
so a value left over from a list that has since changed appears as `:some_id` rather than silently
blanking the trigger.

**`id` carries the state, because a tick is a glyph.** The trigger becomes `"<id>-trigger-open"` /
`"-closed"` and each option `"<id>-option-<option>-selected"` / `"-idle"`. A ✓ cannot be attributed
to one row among several by a device test. Menu items take `test_id` for the same reason.

## Related
`menu` (the surface this is built on — actions rather than a value), `combobox` (type to filter a
long list), `radio_group` (a handful of choices, all visible), `drawer` (where a long picker belongs
on a phone).
