# nav_link (mob)

A navigation row: a leaf that reports where it goes, or a group that holds nested links. See
[README](README.md) for the event shapes every Mob component shares.

## Generate
`mix mishka.ui.gen.mob nav_link` → `lib/<app>/components/nav_link.ex`, tag `<NavLink>`. With
`--module-prefix mishka_` it is `<MishkaNavLink>`.

## What it renders

One tappable row — leading glyph, label, optional second line, trailing glyph — and, when you
give it children, a chevron plus the nested links indented underneath. The current row is
`:primary` on a `:surface_raised` background; everything else is flat.

## Example

```elixir
~MOB"""
<Column fill_width={true}>
  <MishkaNavLink
    id="nav-dash"
    label="Dashboard"
    icon="◱"
    href="/dashboard"
    active={@current == "/dashboard"}
    on_tap={:pick}
  />

  <MishkaNavLink
    id="nav-mail"
    label="Mail"
    icon="✉"
    opened={@mail_open?}
    on_toggle={:toggle_mail}
  >{[
    nav_link([id: "nav-inbox", label: "Inbox", description: "12 unread",
              href: "/mail/inbox", active: @current == "/mail/inbox", on_tap: :pick], []),
    nav_link([id: "nav-drafts", label: "Drafts",
              href: "/mail/drafts", active: @current == "/mail/drafts", on_tap: :pick], [])
  ]}</MishkaNavLink>
</Column>
"""

# One clause for the whole sidebar: the href the link was given rides back with
# the tag, so the handler never has to know which row was tapped.
def handle_info({:tap, {:pick, href}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :current, href)}
end

def handle_info({:tap, :toggle_mail}, socket) do
  {:noreply, Mob.Socket.assign(socket, :mail_open?, not socket.assigns.mail_open?)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

Write the rows out as tags, and call `nav_link/2` for the ones that come from data — both build
the identical node. Nesting works either way: a `<MishkaNavLink>` may hold `<MishkaNavLink>`
children directly, because a composite's children reach it unexpanded and it expands them itself.

## Props

| Prop | Values | Default |
|---|---|---|
| `id` | string | `nil` — the base of every test tag below |
| `label` | string | `nil` |
| `description` | string | `nil` — a second, muted line |
| `icon` / `trailing` | glyph string, **node, or list of nodes** | `nil` — `[]` is no slot at all |
| `active` | boolean | `false` — the web's `data-active` |
| `opened` | boolean | `nil` — the group's open state, owned by your screen |
| `default_opened` | boolean | `false` — used only while `opened` is `nil` |
| `disabled` | boolean | `false` — mutes and unwires |
| `href` | string | `nil` — rides back with the tap |
| `indent` | number | `16` — how far the nested links sit in |
| `on_tap` | event tag | `{:tap, tag}`, or `{:tap, {tag, href}}` with an href |
| `on_toggle` | event tag | a group's row — falls back to `on_tap` |

Not ported: `navigate` / `patch` (a LiveView routing distinction — the destination rides back and
your screen decides), the `inner_block` label slot (children are the nested links here), and
`class` / `label_class` / `children_class` / `rest`.

## Test tags

| Tag | Node |
|---|---|
| `<id>` | the tappable row — stable in every state, so it is what a test taps |
| `<id>-active` / `-inactive` / `-disabled` | the label, one per ink it can take |
| `<id>-open` / `-closed` | the chevron — a group only |
| `<id>-icon` / `<id>-trailing` | the leading and trailing glyphs |

## Six things to know

**`opened` is a prop; `default_opened` is only its fallback.** The web renders a native
`<details>`, then warns that `[open]` is uncontrolled DOM state which LiveView resets on every
patch. Nothing resets it here — but nothing remembers it either, a node tree having nowhere to
keep state of its own. `default_opened` reproduces the web's precedence exactly (it applies only
while `opened` is `nil`), which makes it the right prop for a fixed section and the wrong one for
a group that has to toggle. Pass `opened` and flip it from `on_toggle` for that.

**One handler serves the sidebar, and the component never navigates.** `href` rides back as
`{:tap, {tag, href}}`, so a dozen links share one clause and the row is identified by where it
goes. A node tree only *describes* navigation: the screen performs it, with
`Mob.Socket.push_screen/3` for another screen or `MishkaAnchor.open/1` for an external URL. That
is the same rule `anchor` and `scroller` follow.

**A leaf taps and a group toggles — one gesture each.** A row carries a single `on_tap`, so
children make it a disclosure: `on_toggle` wins on a group, falls back to `on_tap` if you gave
only that, and the chevron replaces any `trailing` you set, because the chevron is the one thing
saying this row expands rather than navigates. Tapping a nested link is a separate event on that
link, and it does not close the group — collapsing a section is not what choosing a destination
means.

**A disabled row is wired to nothing.** Not a handler that returns early: no `on_tap` prop at all,
so the tap never leaves the device. It reads `<id>-disabled`, and `disabled` outranks `active` in
the ink — a muted current row is still a row you cannot reach.

**`id` is a family of tags, and the state is in them.** Mob turns `:id` into a native testTag on
both bridges. The row keeps the bare name, because a tap target renamed by the act of using it can
only be used once; the state goes on the parts inside it. A glyph is the reason: `▸` and `▾` are
the same to a device test, and `active` is a tint. Rows are clickable Boxes, and a clickable node
merges its children's semantics — reach the inner tags with `useUnmergedTree = true`. Give the id
as a string: both bridges read the tag as one, so an atom would tag nothing and never say so.

**A node in `icon` or `trailing` must state its own width.** Both slots take a node — or a list of
them, which is what `render_slot` returns — as readily as a glyph: an unread-count badge is a
perfectly ordinary trailing, and a string could never be one. But a `Box` with neither `width` nor
a fixed frame **fills its parent** on both bridges, and a badge that fills shoves the label off
the row. A list arrives wrapped in a hugging `Row`; `[]` means no slot, as `:if={@icon != []}`
does on the web. The node keeps its own `:id` if it has one and is tagged `<id>-trailing` if not.

## Known platform gap

**No hover, no focus, no keys.** The web styles `:hover` and `:focus-visible` and answers Enter on
a leaf, Enter or Space on a group's `<summary>`. A touch screen has one gesture and no keyboard, so
a tap is the whole activation model. Nothing is lost that a phone could have used — long press is
free here, and `context_menu` is where it belongs.

**`aria-current="page"` has nowhere to go.** No node type in the bridge carries accessibility
semantics, so "this is the page you are on" reaches the eye and no further; `visually_hidden`
reports the same limit through `announce?/0`. The state tags are for tests, not for a screen
reader.

**A long label elides on Android and wraps on iOS.** The label is capped with `max_lines: 1`,
which Compose honours with an ellipsis; Mob's SwiftUI renderer never reads that prop, so the same
label runs onto a second line there. Keep nav labels short and the difference never shows.

## Related
`anchor` (a link with no row around it), `menu` / `context_menu` (actions rather than
destinations), `navigation_menu` (a bar with panels), `tree` (the same disclosure over data),
`accordion`.
