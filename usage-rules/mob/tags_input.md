# tags_input (mob)

Removable tokens plus a text field for entering a list of values. See [README](README.md) for the
rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob tags_input` → `lib/<app>/components/tags_input.ex`, tag `<TagsInput />`.
With `--module-prefix mishka_` it is `<MishkaTagsInput />`.

## What it renders

```
box  the control — background, border, corner_radius, padding
└── column
    ├── row(s)  the tokens, packed by `wrap_chars`   ← a <MishkaPill /> each, with its ✕
    └── text_field  the draft — transparent, underline: false
```

## Example

```elixir
~MOB"""
<MishkaTagsInput
  tags={@tags}
  draft={@draft}
  placeholder="Add a tag…"
  on_draft={:draft}
  on_add={:add}
  on_remove={:remove}
  id="tags"
/>
"""

def handle_info({:change, :draft, text}, socket) do
  {:noreply, Mob.Socket.assign(socket, :draft, text)}
end

# A submit carries NO text — commit the draft you are already holding.
def handle_info({:submit, :add}, socket) do
  {:noreply,
   socket
   |> Mob.Socket.assign(:tags, MishkaTagsInput.add(socket.assigns.tags, socket.assigns.draft))
   |> Mob.Socket.assign(:draft, "")}
end

def handle_info({:tap, {:remove, tag}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :tags, MishkaTagsInput.remove(socket.assigns.tags, tag))}
end
```

## Props

| Prop | Values | Default |
|---|---|---|
| `tags` | list of strings | `[]` |
| `draft` | string | `""` |
| `placeholder` | string | `"Add a tag…"` |
| `disabled` | boolean | `false` |
| `on_draft` | event tag | — `{:change, tag, text}` while typing |
| `on_add` | event tag | — `{:submit, tag}` on return, **no payload** |
| `on_remove` | event tag | — `{:tap, {tag, string}}` from a ✕ |
| `background` / `corner_radius` / `padding` | | `:surface` / `:radius_md` / `:space_sm` |
| `border_color` / `border_width` | | `:border` / `1` — `0` removes the box |
| `space` | number | `6` — gap between tokens |
| `wrap_chars` | number | `40` — characters per token row |
| `id` | string | `nil` — `<id>-draft` and `<id>-tag-<tag>` |

Helpers: `add/3`, `remove/2`, `wrap/2`.

Not ported: `name` / `input_name` (form plumbing) and the `*_class` attrs.

## Five things to know

**Return commits the draft, and the event carries no text.** There is no keydown on a phone, so the
draft is committed by the field's return key (`return_key: "done"`). Verified against the bridge:
`nativeSendSubmit(handle)` takes **only the handle**, unlike `nativeSendChangeStr(handle, value)`.
So `{:submit, tag}` is a bare notification — commit the draft you already hold from `on_change`, and
do not try to read text off the event. A screen that forgets `on_draft` gets a return key that
appears to do nothing.

**`add/3` is stricter than it looks.** Blank input is ignored, surrounding whitespace is trimmed,
and a duplicate is refused rather than appended — a tags input that lets you add "elixir" twice is a
bug every caller then has to fix. `allow_duplicates: true` opts back in. Use the helper rather than
`tags ++ [draft]`.

**It ships no look worth keeping.** Like the headless original, the container's decoration is
entirely props with legible defaults. `border_width: 0` (with `padding: 0`) leaves a bare control
you can drop into your own box.

**The draft field draws no box of its own.** `underline: false` and a transparent background,
because a Material text field with no border draws its **indicator line** — which lands inside the
container as a stray rule across the middle. Keep it that way if you restyle.

**Tokens wrap by estimate.** Neither renderer has a flow layout and nothing on this side of the
bridge can measure text, so tags are packed greedily into rows using `wrap_chars` as a character
budget (each tag costs its length plus a fixed allowance for its padding and ✕). The default is
calibrated rather than guessed: a card's usable width is about 349dp, a character at `:base` about
8.5dp, and a token's padding plus its ✕ about 36dp — roughly 40 characters a row. It was 28, which
broke "United Kingdom" onto a line of its own with half the row empty beside it. Raise it for a wide
control, lower it for a narrow one; a tag longer than the whole budget gets a row to itself rather
than being dropped.

## Related
`pill` (the token itself), `chip` (a selectable label rather than a removable one), `field` (label,
hint and errors around this), `combobox` (pick from a known list instead of free text).
