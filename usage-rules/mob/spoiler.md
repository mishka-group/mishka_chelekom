# spoiler (mob)

Long content that starts collapsed behind a "Show more" control. See [README](README.md) for the
event shapes every Mob component shares.

## Generate
`mix mishka.ui.gen.mob spoiler` → `lib/<app>/components/spoiler.ex`, tag `<Spoiler />`. With
`--module-prefix mishka_` it is `<MishkaSpoiler />`.

## Spoiler, collapsible or accordion?

All three hide content behind a tap. They differ in what the reader is looking at.

| | what it hides | the control |
|---|---|---|
| **spoiler** | content that is *already the point*, merely too long | **under** it, a text link whose label changes |
| [collapsible](collapsible.md) | content behind a **titled header** you read first | above it, a panel header |
| [accordion](accordion.md) | many such regions, one open set | a header per item |

So the markup differs, not just the words: a spoiler renders its control **last**.

## What it renders

```
column
├── column   the body — content when expanded, `preview` when not
│   └── spacer(10)
└── box      the control, padded → on_tap
    └── text  "Show more" / "Show less"
```

## Example

```elixir
~MOB"""
<MishkaSpoiler expanded={@open?} preview={preview()} on_toggle={:more}>
  {full_text()}
</MishkaSpoiler>
"""

# A bare tag: one region, so nothing needs identifying. The label follows the
# boolean, so the screen only ever flips it.
def handle_info({:tap, :more}, socket) do
  {:noreply, Mob.Socket.assign(socket, :open?, not socket.assigns.open?)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

## Props

| Prop | Values | Default |
|---|---|---|
| `expanded` | boolean | `false` — lives in the screen |
| `preview` | list of nodes | `[]` — shown while collapsed |
| `show_label` | string | `"Show more"` |
| `hide_label` | string | `"Show less"` |
| `on_toggle` | event tag | `{:tap, tag}` |
| `color` | colour token / ARGB | `:primary` |
| `padding` | number | `10` — vertical, around the control |

Helper: `label(props, expanded?)` → the control's text for a state.

Not ported: `id` and the `*_class` attrs.

## Three things to know

**`preview` replaces the web's `max-height`.** On the web the content is always in the DOM and CSS
clips it to a height, so the first few lines show through. Mob reports no geometry back to
`render/1`, so nothing here can clip to a measurement — you supply the collapsed form yourself.
Give it a truncated line or a summary; leave it out and the collapsed state is the control alone.

**The control is the tap target, and `padding` sizes it.** A line of `:base` text is about 20 dp
tall, less than half the ~44 dp both platforms ask for — the same problem `action_icon`'s `size`
default exists to prevent. The padding is **vertical only**, so the label stays flush with the
content above it, and the target hugs the words rather than spanning the row, where a stray tap
anywhere on the line would toggle it.

**The label is derived, not stored.** `show_label` and `hide_label` are picked by `expanded`, so
your handler only ever flips a boolean — there is no second piece of state to keep in step, and
`label/2` is public if you want the same text elsewhere.

## Related
`collapsible` (a titled header above the content), `accordion` (many regions), `highlight` with
`wrap_at` (long text that needs wrapping rather than hiding).
