# alert_dialog (mob)

A confirmation modal that demands an explicit choice. See [README](README.md) for the rules every
Mob component shares.

## Generate
`mix mishka.ui.gen.mob alert_dialog` → `lib/<app>/components/alert_dialog.ex`, tag `<AlertDialog>`.
With `--module-prefix mishka_` it is `<MishkaAlertDialog>`. It renders through `dialog`, so
generate that alongside it.

## What it renders

Nothing at all when closed. When `open`, exactly what `dialog` renders — with the backdrop sealed:

```
box   fill_width fill_height          `<id>-open`  — exists ONLY while open
├── box   the backdrop                `<id>-backdrop-modal`, absorbs taps, never closes
└── box   the viewport, align :center  padding = `inset`
    └── box   the panel, width-locked  `<id>-panel`, absorbs taps
        └── column   padding = `padding`
            ├── column   the title         `<id>-title`
            ├── column   the description   `<id>-description`
            ├── column   your children     `<id>-content`
            └── column   the footer row    `<id>-footer`
```

The tags are `dialog`'s, on purpose — an alert dialog *is* a dialog, and a device test should not
have to know which of the two it is looking at.

## Example

```elixir
~MOB"""
<Column fill_width={true}>
  {MishkaDialog.trigger("discard", "Discard changes", on_tap: :open_discard)}
</Column>
"""

# The panel goes at the SCREEN ROOT so it covers the page, not the card it was
# triggered from. A :box stacks its children, last one on top.
~MOB"""
<Box fill_width={true} fill_height={true}>
  {page(assigns)}
  <MishkaAlertDialog
    id="discard"
    open={@discard?}
    title="Discard changes?"
    description="Your edits will be lost."
    on_close={:cancel_discard}
    actions={[
      MishkaAlertDialog.action("Cancel", id: "discard-cancel"),
      MishkaAlertDialog.action("Discard", id: "discard-go",
                               variant: :danger, on_tap: :really_discard)
    ]}
  />
</Box>
"""

def handle_info({:tap, :open_discard}, socket) do
  {:noreply, Mob.Socket.assign(socket, :discard?, true)}
end

# Cancel carries close: true and no handler of its own, so it lands here.
def handle_info({:tap, :cancel_discard}, socket) do
  {:noreply, Mob.Socket.assign(socket, :discard?, false)}
end

# Discard brought its own handler, so it closes the dialog itself.
def handle_info({:tap, :really_discard}, socket) do
  {:noreply, socket |> Mob.Socket.assign(:discard?, false) |> drop_edits()}
end

# REQUIRED — the backdrop and the panel both route stray taps to tags nobody
# handles, and an unmatched message crashes a screen with no catch-all.
def handle_info(_msg, socket), do: {:noreply, socket}
```

## Slots

| Builder | Web slot | Shorthand prop |
|---|---|---|
| `title/1` | `<:title>` | `title:` (a string) |
| `description/1` | `<:description>` | `description:` (a string) |
| `actions/1` | `<:actions>` | `actions:` (a list of nodes) |
| the tag's children | `<:inner_block>` | — |
| `MishkaDialog.trigger/3` | `<:trigger>` | — (a builder, see `dialog`) |

Each takes a string, one node, or a list of nodes, and each is placed among the dialog's children:

```elixir
alert_dialog(%{id: "quota", open: @full?, on_close: :dismiss_quota}, [
  MishkaAlertDialog.title([icon_heading("⚠", "Storage full")]),
  MishkaAlertDialog.description([usage_bar(0.98)]),
  MishkaAlertDialog.actions([MishkaAlertDialog.action("Got it", id: "quota-ok")])
])
```

`actions/1` and `MishkaDialog.footer/1` build the identical node — the two components' web slots
simply have different names.

## Props

| Prop | Values | Default |
|---|---|---|
| `id` | string | `nil` — the stem of every testTag; without it no part is tagged |
| `open` | boolean | `false` — the dialog draws nothing when closed |
| `title` / `description` | string | `nil` — shorthands for the slots above |
| `actions` | list of nodes | `[]` — footer buttons, trailing-aligned |
| `on_close` | event tag | — `{:tap, tag}`, fired by an action carrying `close: true` |
| `dismissible` | — | **always `false`** |
| `modal` | — | **always `true`** |

Everything else `dialog` accepts is forwarded: `width`, `background`, `corner_radius`, `padding`,
`inset`, `scrim_color`.

`action/2` takes `label` plus `:id` (testTag stem), `:on_tap`, `:close` (default `true`) and
`:variant` (`:neutral`, `:primary`, `:danger`).

Not ported beyond `dialog`'s own list: `on_open_change` (it fires on backdrop dismiss, which cannot
happen here), and `role="alertdialog"` / `aria-modal` — see the gap below.

## Six things to know

**The backdrop blocks but never closes, and blocking had to be built.** "Not dismissible" is not the
same as "not there". A Compose Box with a background but no pointer input paints over the page
without consuming a single touch, so a plain `dialog` with `dismissible: false` dims the page and
still lets every tap through to it — including the tap on the button that opened the dialog. This
component gives the backdrop a handler that goes nowhere, which is what makes it modal. Do not
reach for `dialog` with `dismissible: false` and expect the same thing.

**`close: true` is the web's `data-close`, and an explicit `on_tap` beats it.** An action with
`close: true` and no handler of its own fires the dialog's `on_close`. One that brings an `on_tap`
keeps it — a tap sends one message, so a Confirm button that both acts and closes has to close from
its own handler. `close: false` opts out entirely.

**The variant goes in the testTag, because a fill is not readable.** `action/2` tags itself
`<id>-neutral`, `<id>-primary` or `<id>-danger`. The only difference between a Delete and a Cancel
on screen is `:error` against `:surface_raised`, and a device test can read a tag and cannot read a
colour. Use `variant: :danger` rather than a red of your own — a literal ignores the theme.

**Always give it a way out.** There is no backdrop tap, no Escape and no back gesture (see below),
so the footer is the *only* exit. Opening one with no actions logs a warning naming exactly that;
so does opening one with neither a title nor a description, which is a modal demanding a choice
without saying what about. Both go quiet the moment a slot child is present, since `slot_types/0`
does not say which part a slot is and a false alarm is worse than none.

**`dismissible` and `modal` are not yours.** Both are overwritten. The web's alert dialog hardcodes
`data-close-on-outside="false"` and has no `modal` attribute at all, because it is never anything
else. If you want either knob, you want `dialog`.

**The trigger and the open state are yours.** As with `dialog`, the panel has to be stacked at the
screen root to cover the page while the trigger belongs in flow, so one node cannot be both.
`MishkaDialog.trigger/3` builds the button, you place it, and `id` ties the two together.

## Known platform gap

**There is no Escape, no back gesture, and no way to announce modality.** The web pattern gives the
user three exits — Escape, a focus trap that keeps Tab inside the popup, and a screen reader that
says "alert dialog" on open. None of them exist here. Mob registers no key event, and on Android
`Mob.Screen.handle_info/2` intercepts `{:mob, :back}` **before** the screen's own clauses
(`deps/mob/lib/mob/screen.ex:444`) and pops the nav stack — so the system back gesture, pressed
while an alert dialog is up, navigates away from the whole screen rather than closing the dialog,
and no component can intercept it. Neither renderer exposes accessibility semantics either, so
`role="alertdialog"` and `aria-modal="true"` have nowhere to go: the modality is behavioural (the
backdrop absorbs) rather than announced. Treat the footer as the only exit, keep it to two or three
plainly-labelled choices, and never put an alert dialog over a screen the user cannot afford to be
navigated away from.

## Related
`dialog` (this without the forced `dismissible: false`, and the module every part of this comes
from), `drawer` (the same overlay anchored to an edge), `loading_overlay` (a scrim that absorbs
taps and offers no choice at all), `popover`, `toast`.
