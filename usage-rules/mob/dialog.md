# dialog (mob)

A centred modal over a dimmed backdrop. See [README](README.md) for the rules every Mob component
shares.

## Generate
`mix mishka.ui.gen.mob dialog` → `lib/<app>/components/dialog.ex`, tag `<Dialog>`.
With `--module-prefix mishka_` it is `<MishkaDialog>`.

## What it renders

Nothing at all when closed. When `open`:

```
box   fill_width fill_height          `<id>-open`  — exists ONLY while open
├── box   the backdrop                `<id>-backdrop-modal` / `<id>-backdrop-plain`
└── box   the viewport, align :center  padding = `inset`
    └── box   the panel, width-locked  `<id>-panel`, absorbs taps
        └── column   padding = `padding`
            ├── column   the title         `<id>-title`
            ├── column   the description   `<id>-description`
            ├── column   your children     `<id>-content`
            └── column   the footer row    `<id>-footer`
```

Every part the web marks with a `data-part` is here, named by a testTag instead — a device test can
read a tag and cannot read a colour.

## Example

```elixir
~MOB"""
<Column fill_width={true}>
  {MishkaDialog.trigger("confirm", "Delete", on_tap: :open_confirm)}
</Column>
"""

# The panel goes at the SCREEN ROOT so it covers the page, not the card it was
# triggered from. A :box stacks its children, last one on top.
~MOB"""
<Box fill_width={true} fill_height={true}>
  {page(assigns)}
  <MishkaDialog
    id="confirm"
    open={@confirm?}
    title="Delete file?"
    description="This cannot be undone."
    on_close={:close_confirm}
    actions={[cancel_button(), delete_button()]}
  >
    <Text text="report.pdf will be removed from every device." />
  </MishkaDialog>
</Box>
"""

def handle_info({:tap, :open_confirm}, socket) do
  {:noreply, Mob.Socket.assign(socket, :confirm?, true)}
end

def handle_info({:tap, :close_confirm}, socket) do
  {:noreply, Mob.Socket.assign(socket, :confirm?, false)}
end

# REQUIRED — the panel routes stray taps to an ignored tag.
def handle_info(_msg, socket), do: {:noreply, socket}
```

## Slots

| Builder | Web slot | Shorthand prop |
|---|---|---|
| `title/1` | `<:title>` | `title:` (a string) |
| `description/1` | `<:description>` | `description:` (a string) |
| `footer/1` | `<:close>` | `actions:` (a list of nodes) |
| the tag's children | `<:inner_block>` | — |
| `trigger/3` | `<:trigger>` | — (a builder, see below) |

Each builder takes a string, one node, or a list of nodes, and each is placed among the dialog's
children:

```elixir
dialog(%{id: "move", open: @move?, on_close: :close_move}, [
  MishkaDialog.title([icon_heading("🗂", "Move to trash")]),
  MishkaDialog.description("Items in the trash are deleted after 30 days."),
  body_nodes(),
  MishkaDialog.footer([close_button()])
])
```

## Props

| Prop | Values | Default |
|---|---|---|
| `id` | string | `nil` — the stem of every testTag; without it no part is tagged |
| `open` | boolean | `false` — the dialog draws nothing when closed |
| `modal` | `true` / `false` / `"trap-focus"` | `true` — whether the backdrop dims |
| `title` / `description` | string | `nil` |
| `actions` | list of nodes | `[]` — footer buttons, trailing-aligned |
| `dismissible` | boolean | `true` — whether a backdrop tap closes it |
| `on_close` | event tag | — `{:tap, tag}` |
| `on_open_change` | event tag | — `{:tap, {tag, false}}`; `on_close` wins over it |
| `width` | number | `320` |
| `background` | colour token / ARGB int | `:surface` |
| `corner_radius` | radius token / number | `:radius_lg` |
| `padding` | spacing token / number | `:space_lg` — inside the panel |
| `inset` | spacing token / number | `:space_lg` — between the panel and the screen edges |
| `scrim_color` | ARGB int / token | `0x99000000` when modal, `0x00000000` otherwise |

`trigger/3` takes `id, label` plus `:on_tap`, `:on_open_change`, `:disabled`, `:background`,
`:text_color`, `:padding`, `:fill_width`.

Not ported: `close_on_escape` (see the gap below), `initial_focus`, `final_focus`, `labelledby`,
`describedby`, `on_open_change_target` and the nine `*_class` attrs. Focus restoration and ARIA
anchoring are DOM concerns; the classes are the chrome props above.

## Seven things to know

**The trigger is a builder, not a slot.** On the web it lives inside the dialog's own markup. Here
the panel has to be stacked at the **screen root** to cover the page, while the trigger belongs in
flow where the user is reading — one node cannot be in both places. So `trigger/3` builds the
button, the caller places it, and `id` is what ties the two together. The open state is yours, the
same way it is for `menu` and `popover`.

**`id` is the only thing a device test can see.** A native screen has no DOM to query and a tag
query cannot read a colour or a glyph, so state that would otherwise be colour-only is folded into
the tag: the overlay root is `<id>-open` and exists only while open, the backdrop says whether it
dims (`-backdrop-modal` / `-backdrop-plain`), and a disabled trigger is `<id>-trigger-disabled`
rather than `<id>-trigger`. Give every dialog an `id` you intend to test.

**A slot child wins over its shorthand.** `title("…")` and `title: "…"` build the identical node, so
passing both is not an error — the slot simply wins. Use the prop for a line of text and the slot
when the title is a Row with an icon in it, which is the whole reason the web has a `<:title>` slot
and not a `title` attribute.

**`modal` survives as the backdrop; the focus trap does not.** The web's `modal` bundles a focus
trap, a scroll lock and a backdrop. Only the backdrop exists natively, so `false` and
`"trap-focus"` render identically — the one thing that separated them was the trap. `modal={false}`
leaves the backdrop fully transparent rather than removing it.

**A non-modal outside tap dismisses instead of passing through.** The web lets an outside click on a
non-modal dialog both close it *and* reach the content beneath; one native hit test cannot do both,
and dismissal is what the user is relying on. If you want the pass-through, set
`dismissible: false` — a Box with no fill and no handler has no hit shape at all, so taps land on
whatever is underneath.

**The panel absorbs its own taps, so the screen needs a catch-all `handle_info/2`.** Without it, a
tap on the panel's empty area would fall through to the backdrop and the dialog would dismiss
itself; the panel routes those to `:__mishka_dialog_ignore` instead, and an unmatched message
crashes a screen that has no catch-all.

**`on_close` wins over `on_open_change`.** `on_open_change` is the web's contract — it carries the
new state, so the backdrop sends `{:tap, {tag, false}}` and `trigger/3`'s `on_open_change` sends
`{:tap, {tag, true}}`, letting one clause serve both edges. `on_close` is the narrower shorthand and
takes precedence when both are set.

## Known platform gap

**There is no Escape, and the back gesture is not yours.** `close_on_escape` has no native
counterpart on either platform: iOS has no back gesture at all, and on Android
`Mob.Screen.handle_info/2` intercepts `{:mob, :back}` **before** the screen's own clauses
(`deps/mob/lib/mob/screen.ex:444`) and pops the nav stack — or exits the app when the stack is
empty. So the system back gesture, pressed while a dialog is up, navigates away from the screen
rather than closing the dialog, and no component can intercept it. Fixing that means a hook in Mob
itself; until then, always give a dismissible dialog a visible way out — a backdrop tap or a footer
button — and treat a non-dismissible one as a genuine forced choice.

## Related
`alert_dialog` (this with `dismissible` forced to `false`), `drawer` (the same overlay mechanics
anchored to an edge instead of centred), `popover`, `floating_window`, `loading_overlay`.
