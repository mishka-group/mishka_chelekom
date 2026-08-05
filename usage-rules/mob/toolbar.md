# toolbar (mob)

A strip of related controls, in groups, with separators between them. See [README](README.md) for
the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob toolbar` → `lib/<app>/components/toolbar.ex`, tag `<Toolbar>` plus its four
item tags. With `--module-prefix mishka_` they are `<MishkaToolbar>`, `<MishkaToolbarButton>`, and so
on.

## What it renders

```
box   the strip — background, corner_radius, padding; carries `id`
└── row (or column when vertical)   the items, `space` apart
    ├── box    a button  — tappable, tagged <id>-<item_id>
    ├── box    a link    — tinted, with a rule under the text
    ├── box    a group   — fill_width: false, holding its own row of items
    ├── box    a separator — a 1dp hairline across the OTHER axis
    └── box    an input  — weight: 1, holding a TextField that carries the tag
└── text  the hint caption, when `hint` names an item
```

Under `overflow: :scroll` the row is wrapped in a `Scroll`; under `:collapse` the tail becomes a `⋯`.

## Example

```elixir
~MOB"""
<MishkaToolbar
  id="fmt"
  on_select={:act}
  on_hold={:hint}
  on_input={:typed}
  hint={@hint}
>
  <MishkaToolbarButton id={:bold} label="Bold" icon="B" />
  <MishkaToolbarButton id={:italic} label="Italic" icon="I" />
  <MishkaToolbarSeparator />
  <MishkaToolbarButton id={:left} label="Left" icon="◀" group="Align" />
  <MishkaToolbarButton id={:right} label="Right" icon="▶" group="Align" />
  <MishkaToolbarLink id={:docs} label="Docs" href="https://mishka.tools/chelekom" />
  <MishkaToolbarInput id={:find} placeholder="Find…" value={@query} />
</MishkaToolbar>
"""

# One clause for every button and link — each reports its own id.
def handle_info({:tap, {:act, :docs}}, socket) do
  Mob.Device.open_url("https://mishka.tools/chelekom")
  {:noreply, socket}
end

def handle_info({:tap, {:act, id}}, socket), do: {:noreply, apply_format(socket, id)}

# A long press is the touch equivalent of a hover, so this is where the web's
# aria-label ends up: hold an icon and the toolbar prints its label.
def handle_info({:tap, {:hint, id}}, socket), do: {:noreply, assign(socket, :hint, id)}

def handle_info({:change, {:typed, :find}, value}, socket) do
  {:noreply, Mob.Socket.assign(socket, :query, value)}
end
```

## Items

| Tag | Builder | What it is |
|---|---|---|
| `<MishkaToolbarButton>` | `button/3` | A command. `id`, `label`, and `icon`, `disabled`, `group` |
| `<MishkaToolbarLink>` | `link/3` | A destination. Same, plus `href` — tinted, with a rule under it |
| `<MishkaToolbarInput>` | `input/2` | A text field. `placeholder`, `value`, `width`, `disabled`, `group` |
| `<MishkaToolbarSeparator>` | `separator/1` | A divider, oriented across the toolbar's axis. Takes `group` |

No item tag carries its own `on_*` — the bar's `on_select`, `on_hold` and `on_input` serve every item,
because each reports its own `id`.

Tag and builder produce the identical node (`expand/3` routes every tag back through its builder), so
pick by where the items come from. Write the tags when you are writing the bar out; call the builders
when the items come from data, where a comprehension beats generated markup:

```elixir
~MOB"""
<MishkaToolbar id="fmt" overflow={:scroll} on_select={:act}>
  {Enum.map(@tools, fn {id, label, icon} -> MishkaToolbar.button(id, label, icon: icon) end)}
</MishkaToolbar>
"""
```

Anything that is *not* one of these passes through untouched, so a `toggle`, an `action_icon` or a
`toggle_group` sits in the bar unchanged — as a tag or as an expression child, either way.

## Props

| Prop | Values | Default |
|---|---|---|
| `id` | string | `nil` — items get `<id>-<item_id>` |
| `orientation` | `:horizontal` `:vertical` | `:horizontal` — separators follow it |
| `disabled` | boolean | `false` — reaches every item |
| `focusable_when_disabled` | boolean | `true` — a disabled item still answers a hold |
| `on_select` | event tag | — `{:tap, {tag, item_id}}` from a button or link |
| `on_hold` | event tag | — `{:tap, {tag, item_id}}` from a long press |
| `on_input` | event tag | — `{:change, {tag, item_id}, value}` from an input |
| `on_overflow` | event tag | — `{:tap, tag}` from the `⋯` |
| `hint` | item id | `nil` — prints that item's `label` under the strip |
| `overflow` | `:none` `:scroll` `:collapse` | `:none` |
| `visible` | integer | `3` — controls kept under `:collapse` |
| `space` | number | `8` |
| `height` | number | `nil` — a vertical `:scroll` needs it |
| `background` · `corner_radius` · `padding` | tokens | `:surface_raised` · `:radius_md` · `:space_sm` |
| `group_background` | colour token / ARGB int | `:surface` |
| `item_color` · `link_color` | colour token / ARGB int | `:on_surface` · `:primary` |

Helpers: `href/2`, `split/2`, `item_tag/3`, `group_tag/2`, `overflow_tag/1`, `hint_tag/1`,
`scroll_tag/1`.

Not ported: `loop` (roving arrow-key focus), and `class` / `group_class` — there is no stylesheet, so
every visual decision is a prop instead.

## Six things to know

**A long press is the hover, and that is where `label` goes.** On the web an item's `label` is its
`aria-label`: an icon-only button announces "Undo", and a desktop browser shows the same string as a
tooltip. Mob exposes no accessible name and a touch screen has no hover — but it has a long press,
which is what a phone uses for exactly this. Give the item an `:icon` and the glyph is drawn; hold it
and `on_hold` reports the id; pass that id back as `hint` and the bar prints the label underneath.
The invisible name becomes a visible one, on demand. An input is the exception: a text field consumes
its own long press to place a selection, so it carries no hold.

**`focusable_when_disabled` really did port.** On the web it keeps a disabled item in the roving
order so it stays *discoverable*. Here it means a disabled item still answers a long press — you
cannot activate it, but you can still find out what it is. Set it to `false` to take that away.

**Everything reports an id, including links.** There is no second event shape for a link, because one
`on_select` clause should serve the whole bar. Opening the destination is the screen's job
(`Mob.Device.open_url/1`, or `push_screen/3` for an internal one) — a node tree is a description, not
an effect. Written as tags the `href` sits in the markup beside the id; when the items come from a
list, `href/2` turns the reported id back into it.

**Nothing wraps, so overflow is a decision you make.** A `Row` runs off the edge rather than flowing
onto a second line, and nothing measures itself, so eight controls on a phone are simply clipped by
the strip's Box. `overflow: :scroll` makes the strip scroll along its own axis; `overflow: :collapse`
keeps `visible` controls and adds a `⋯` that reports `on_overflow`. `split/2` is the collapse policy,
pure and public: it counts **controls**, so a separator does not spend a slot, it never lets the
strip end on a divider, and it always keeps at least one control.

**The input is weighted, and only where a weight means something.** Compose measures a Row's
unweighted children first, in order, each against what is left — so an unweighted `TextField` with
`fill_width` eats the row and every button after it gets the scraps. The input therefore sits in a
`weight: 1` box. Under `overflow: :scroll` there is no bounded width to divide, so it falls back to a
fixed `:width` (160) instead, as it does in a vertical bar where the main axis is height.

**A group's label survives only as its test tag.** Consecutive items sharing a `:group` are chunked
into one cluster, exactly as the web wraps them in a `role="group"` div — and the chunking is by
*run*, not by name, so the same label used twice with something between makes two clusters. The
label itself is an `aria-label` on the web: invisible to sighted users, and unavailable here, so it
becomes `<id>-group-<slug>` and nothing else. The cluster sets `fill_width={false}`, without which
the first group swallows the strip and every item after it goes off the edge.

## Test tags

`id` is the only thing that makes this bar addressable on a device, and state that is carried by
colour alone is folded into the tag, because a device test can read neither a colour nor a glyph.

| Tag | On |
|---|---|
| `<id>` | the strip |
| `<id>-<item_id>` | a live button or link; on an input it is on the **text field**, so a test can type |
| `<id>-<item_id>-disabled` | the same item when it is disabled |
| `<id>-group-<slug>` | a labelled group |
| `<id>-overflow` | the `⋯` |
| `<id>-hint` | the hint caption — on the `Text` itself, so it can be read from its own node |
| `<id>-scroll` | the scroller under `overflow: :scroll`, also registered for `Mob.Test.scroll_to/3` |

A clickable Box merges its children's semantics, so query these with `useUnmergedTree = true`. And
`performScrollTo` drives the **nearest** scrollable ancestor: inside a `:scroll` toolbar that is the
strip, not the page, so scroll the page to the example first and the item second.

## Known platform gap

**No accessible name, on either platform.** `label` on an item and the label on a group are both
`aria-label` on the web. Mob exposes no accessible-name API, so neither is announced by TalkBack or
VoiceOver. The hint is a visual substitute, not an accessibility one.

**`height` is a no-op on iOS.** It becomes a Box carrying `height` and `fill_width` but no `width`,
and iOS's `MobBox` applies `fixedHeight` only in the branch it takes when a width *is* set
(`development/mob/IOS_TODO.md` item 1). So a vertical `overflow: :scroll` toolbar cannot be bounded
on iOS and will not scroll. Android honours it.

**`weight` is ignored on iOS.** `MobRootView.swift` reads it nowhere (`IOS_TODO.md` item 13). An
`HStack` serves fixed-size children first, so the input still behaves — but the ordering guarantee
above is an Android one.

**A group cluster cannot hug on iOS.** `MobBox` never reads `fill_width` (`IOS_TODO.md` item 6), so
`fill_width={false}` does not stop the cluster filling the strip. This is the same bug that makes
`chip` and `pill` full-width there, and it is fixed in one line of Swift with no Elixir change.

**`max_lines` is Android-only.** Every label in the bar carries `max_lines: 1`, because a `Text`
squeezed narrower than its content wraps character by character rather than clipping. iOS applies no
`.lineLimit` (`IOS_TODO.md` item 9), so an over-packed strip stacks letters vertically there instead
of ellipsising — one more reason to reach for `overflow: :scroll`.

## Related
`burger` (shares this page — the three-bar nav button), `toggle` / `toggle_group` /
`segmented_control` (what usually goes *in* a toolbar), `menubar`, `overflow_list` (the same `+N`
idea for a row of tags), `separator`.
