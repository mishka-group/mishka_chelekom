# menu (mob)

A list of actions revealed from a trigger. See [README](README.md) for the rules every Mob component
shares.

## Generate
`mix mishka.ui.gen.mob menu` → `lib/<app>/components/menu.ex`, tag `<Menu>` plus its row tags.
With `--module-prefix mishka_` they are `<MishkaMenu>`, `<MishkaMenuItem>`, and so on.

## What it renders

A `popover` panel when `open`, and **nothing at all** when closed. Each row is a tappable Box.

## Example

```elixir
~MOB"""
<MishkaMenu open={@open?} on_select={:pick}>
  <MishkaMenuItem id={:edit} label="Edit" icon="✎" />
  <MishkaMenuItem id={:dup} label="Duplicate" icon="⧉" />
  <MishkaMenuSeparator />
  <MishkaMenuCheckbox id={:grid} label="Show grid" checked={@grid?} />
  <MishkaMenuSeparator />
  <MishkaMenuLabel text="SORT BY" />
  <MishkaMenuRadio id={:name} label="Name" name="sort" checked={@sort == :name} />
  <MishkaMenuRadio id={:date} label="Date" name="sort" checked={@sort == :date} />
  <MishkaMenuSeparator />
  <MishkaMenuItem id={:archive} label="Archive" disabled={true} />
  <MishkaMenuSubmenu id={:share} label="Share" open={@submenu == :share}>
    <MishkaMenuItem id={:copy} label="Copy link" />
    <MishkaMenuItem id={:email} label="Email" />
  </MishkaMenuSubmenu>
</MishkaMenu>
"""

# One handler for every row — the message carries the row's own id.
def handle_info({:tap, {:pick, :grid}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :grid?, not socket.assigns.grid?)}
end
```

## Rows

| Tag | Function | What it is |
|---|---|---|
| `<MishkaMenuItem>` | `item/3` | A command. `id`, `label`, `icon`, `disabled`, `danger`, `test_id` |
| `<MishkaMenuSeparator>` | `separator/0` | A divider |
| `<MishkaMenuLabel>` | `label/1` | A section heading. `text` |
| `<MishkaMenuCheckbox>` | `checkbox/3` | A tick. `checked` |
| `<MishkaMenuRadio>` | `radio/4` | One of a named group. `name`, `checked` |
| `<MishkaMenuSubmenu>` | `submenu/3` | Nested rows. `open`, and its children are the rows |

Tag and function forms build the identical node, so use the tag when writing rows out and the
function when they come from data.

## Props

| Prop | Values | Default |
|---|---|---|
| `open` | boolean | `false` — the menu draws nothing when closed |
| `on_select` | event tag | — `{:tap, {tag, row_id}}` |
| `width` | number | `nil` — panel width |
| `danger_color` | colour token / ARGB int | `:error` |

Everything `popover` accepts is forwarded (`background`, `corner_radius`, `padding`, `border_*`,
`offset_x`, `offset_y`).

## Six things to know

**The trigger and the open state are yours.** Unlike the web original there is no `<:trigger>` slot:
the caller places the menu and owns `open`. This used to say Mob has no anchored-popup positioning —
it has some now, and `popover` draws its panel in a window of its own, over the page; the menu has
not been moved onto it and keeps the full-width shell it always had. Caller placement is also what
lets the same row list serve as a dropdown or as the contents of a bottom `drawer`.

**One handler serves every row.** `on_select` sends `{:tap, {tag, row_id}}`, so you match the menu
once and read the id. A row with no `on_select` renders identically and does nothing.

**A checkbox should not close the menu.** Nothing closes the menu but you — so ticking a checkbox or
opening a submenu can leave it open, while a command closes it. The web component gets this wrong
(it dismisses on every activation unless `keep_open` is set); here the decision is simply yours.

**A submenu opens inline, not sideways.** On the web it flies out on hover. There is no hover on a
touch screen and no room beside a phone-width panel, so its rows appear underneath the trigger,
indented 16dp. The trigger reports its own id like any row and the screen decides what opens — so
you can have one submenu open at a time, or several, as you prefer.

**`id` is the event tag; `test_id` is the testTag.** They are separate on purpose: the id is what
`on_select` reports, while `test_id` becomes the row's native tag because a device test otherwise
has nothing to address a row by but its label, and labels repeat. A checkbox or radio appends its
state — `<test_id>-checked` / `-unchecked` — and a submenu appends `-open` / `-closed`, because a
glyph is not something a device test can attribute to a row.

**Use the `:error` token for destructive rows, not a red.** `danger: true` tints with `:error`. It
shipped with a hardcoded `0xFFDC2626`, which ignores the theme and cannot be restyled — and the unit
test asserting that literal is what kept it there.

## Related
`context_menu` (the same rows from a long-press), `select` / `combobox` / `autocomplete` (all build
their option lists from `item/3`), `drawer`, `popover`.
