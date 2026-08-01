# json_input (mob)

A multi-line field for JSON with a validated error state. See [README](README.md) for the rules
every Mob component shares.

## Generate
`mix mishka.ui.gen.mob json_input` → `lib/<app>/components/json_input.ex`, tag `<JsonInput />`.
With `--module-prefix mishka_` it is `<MishkaJsonInput />`.

## What it renders

```
column  fill_width
├── text_field  lines: 6, the raw text — border reddens when invalid
└── column      the parser's own message, when there is one
```

Parsing is the **server's** job and there is no JS involved — the web component is explicit about
that, which makes this one of the most faithful ports here: the same division of labour, with
`Jason` on the same side of the wire.

## Example

```elixir
~MOB"""
<MishkaJsonInput value={@json} lines={5} on_change={:json} id="config" />
"""

# The field never reformats as you type — that would move the cursor out from
# under the user — so the screen just holds the raw text.
def handle_info({:change, :json, text}, socket) do
  {:noreply, Mob.Socket.assign(socket, :json, text)}
end

# Format on a deliberate action instead: a button, a blur.
def handle_info({:tap, :tidy}, socket) do
  {:noreply, Mob.Socket.assign(socket, :json, MishkaJsonInput.format(socket.assigns.json))}
end
```

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | string | `""` — the raw text, never reformatted as you type |
| `lines` | integer | `6` — height in rows. **Android only**, see below |
| `placeholder` | string | `"{ }"` |
| `on_change` | event tag (atom) | — `{:change, tag, text}` per keystroke |
| `disabled` | boolean | `false` |
| `invalid` | boolean | derived — force the error state |
| `error_text` | string | the parser's message |
| `show_error` | boolean | `true` |
| `error_color` | colour token / ARGB int | `:error` |
| `background` / `border_color` / `border_width` / `padding` | | the field |
| `id` | string | `nil` — test tag on the field |

Helpers: `validate/1`, `format/1`, `invalid?/2`.

Not ported: `name` / `form` (form plumbing). `id` **is** ported, as a test handle.

## Five things to know

**Blank is not an error.** `validate/1` returns `:empty` for blank or whitespace, not `{:error, _}`.
An untouched field is not a mistake, and the web version does not paint one red either.

**A bare scalar is valid JSON.** `42`, `"a string"`, `true` and `null` all parse — treating them as
errors would be wrong, and there is a doctest pinning it.

**Never reformat on a keystroke.** `format/1` exists, and it is for a deliberate action: a button, a
blur. Pretty-printing as someone types moves the cursor out from under them mid-word. The component
never calls it for you.

**Use the `:error` token, not a hardcoded red — and never an invented one.** This component shipped
with `:danger`, which exists in no theme and no fallback palette. An unresolved token serialises as a
bare string, and the consequences were worse than "wrong colour": as a `border_color` it made the
border vanish entirely (a border needs both a colour and a width), so invalid JSON *deleted the
field's outline* instead of reddening it; as a `text_color` it left the message unstyled on Android
and fully transparent — invisible — on iOS. `error_color` overrides it if your design system
disagrees.

**Forcing `invalid` on text that parses does not claim bad syntax.** `invalid: true` means the caller
knows something the parser does not — a schema rejected it, the server said no. Without an
`error_text` the field tints but says nothing, because "Invalid JSON" would be a lie about the one
thing this component actually checked.

## Known platform gap

`lines` is **Android only**. iOS's `MobTextField` renders a single-line field whatever it says, and
styles itself with the system's rounded-border style rather than reading `background`,
`border_color` or `border_width` — so on iOS this is a one-line box with system chrome, and the
invalid state shows only in the message underneath. Both live in the `mob` dependency; see
`development/mob/IOS_TODO.md` item 10.

## Related
`field` (label, hint and errors around any control), `mask_input`, `number_field`, `code` (read-only
syntax display rather than an editor).
