# combobox (mob)

A text field that filters a list of options, single or multiple. See [README](README.md) for the
rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob combobox` → `lib/<app>/components/combobox.ex`, tag `<Combobox />`. With
`--module-prefix mishka_` it is `<MishkaCombobox />`.

## What it renders

```
column  fill_width
├── box  the control — border, radius, padding
│   └── column
│       ├── row(s)  the chips, when multiple and something is chosen
│       └── row     the query field · ✕ clear · ▾ trigger
└── <MishkaMenu />  the filtered options, only while `open`
    ├── label  a group heading
    ├── item   an option, ticked with ✓ when chosen
    └── item   Create "…"        ← when `creatable` and nothing matches exactly
```

## Example

```elixir
~MOB"""
<MishkaCombobox
  query={@query}
  value={@picked}
  open={@open?}
  multiple={true}
  clear={true}
  trigger={true}
  creatable={true}
  placeholder="Add items…"
  on_query={:query}
  on_select={:pick}
  on_remove={:remove}
  on_clear={:clear}
  on_toggle={:toggle}
  id="food"
>
  {[
    option(:apple, "Apple", group: "FRUIT"),
    option(:durian, "Durian (out of stock)", group: "FRUIT", disabled: true),
    option(:carrot, "Carrot", group: "VEGETABLE")
  ]}
</MishkaCombobox>
"""

def handle_info({:change, :query, text}, socket) do
  {:noreply, Mob.Socket.assign(socket, :query, text)}
end

# The create row reports the same tag as any option, with the id :__create__ —
# so one clause picks, and one branch inside it creates.
def handle_info({:tap, {:pick, :__create__}}, socket), do: create(socket)

def handle_info({:tap, {:pick, id}}, socket) do
  {value, _close?} = MishkaSelect.toggle(socket.assigns.picked, id, true)
  {:noreply, Mob.Socket.assign(socket, :picked, value)}
end
```

## Props

| Prop | Values | Default |
|---|---|---|
| `query` | string | `""` — the field's contents |
| `value` | option id, list, or `nil` | `nil` |
| `open` | boolean | `false` |
| `multiple` | boolean | `false` — renders chips |
| `placeholder` | string | `"Search…"` |
| `filter` | `:contains` / `:starts_with` | `:contains` |
| `clear` | boolean | `false` — a ✕ that clears the query |
| `trigger` | boolean | `false` — a ▾ that opens and closes |
| `creatable` | boolean | `false` |
| `create_label` | string | `"Create"` |
| `empty_text` | string | `"No matches"` |
| `disabled` | boolean | `false` |
| `on_query` / `on_select` / `on_clear` / `on_toggle` / `on_create` / `on_remove` | event tags | — |
| `background` / `border_color` / `border_width` / `corner_radius` / `padding` | | the control |
| `wrap_chars` | number | `28` — characters per chip row |
| `id` | string | `nil` |

Options are built with `option/3`, which takes `:disabled` and `:group`.

Helpers: `filter/3`, `fold/1`.

Not ported: `name` / `form` (form plumbing), `auto_highlight` (there is no focus ring to highlight)
and the `*_class` attrs.

## Five things to know

**Filtering is a pure function the screen calls.** The web filters in JS as you type; here `filter/3`
does it and your `handle_change/3` calls it. That keeps the component a pure function of its props
and makes the awkward cases testable. It is **case- and accent-insensitive** — typing `"turkiye"`
finds `"Türkiye"` — which matters far more on a phone than on a desktop, where a physical keyboard
makes accents easy. It is the difference between a working search and a dead one.

**In `multiple` mode the selection is chips, inside the control.** Otherwise what you have chosen is
invisible until you reopen the list, which is a guessing game. Each chip's ✕ reports
`{:tap, {tag, id}}` through `on_remove`. They wrap by the same estimate the tags input uses —
nothing on this side of the bridge can measure text.

**`creatable` only OFFERS.** The row appears when the query matches no option **exactly** — the web
offers to create "Ban" while "Banana" is listed, and so does this; only an exact match (folded, so
case and accents do not matter) suppresses it. Adding to the option list is your job, which is why
the row reports `:__create__` through the ordinary `on_select` tag rather than inventing a second
event: you already hold the query.

**Groups are runs.** Consecutive options sharing `group:` get one heading, via
`MishkaSelect.group_runs/1` — so a grouped combobox, select and menu are the same list. Filtering
runs first, and a run whose options all fail the filter loses its heading with them.

**A disabled option stays in the list and stays inert.** Options carry their `disabled` and `group`
all the way through the filter. They used to be flattened to `{id, label}` pairs first, which threw
both away and made a disabled option indistinguishable from any other.

## Related
`select` (the same list without a query), `tags_input` (free text rather than a known list),
`autocomplete`, `menu` (the surface all three are built on).
