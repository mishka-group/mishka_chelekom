# code (mob)

Inline code and code blocks. See [README](README.md) for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob code` → `lib/<app>/components/code.ex`, tag `<Code />`. With
`--module-prefix mishka_` it is `<MishkaCode />`.

## What it renders

Two different things wearing one name, which is what `block` picks between.

```
inline   box   fill_width: FALSE, padding 4        hugs its text
         └── text  font: "monospace"

block    box   fill_width: true, padding :space_md
         └── scroll axis="horizontal"              only when scroll: true
             └── text  font: "monospace"
```

## Example

```elixir
~MOB"""
<Row>
  <Text text="Run " />
  <MishkaCode text="mix mob.deploy" />
  <Text text=" to install it." />
</Row>
"""

~MOB"""
<MishkaCode text={@snippet} block={true} />
"""
```

No events — it is presentational. To make code copyable, put a `MishkaActionIcon` beside it and
handle the tap yourself.

## Props

| Prop | Values | Default |
|---|---|---|
| `text` | string | `nil` |
| `block` | boolean | `false` |
| `background` | colour token / ARGB | `:surface_raised` |
| `color` | colour token / ARGB | `:on_surface` |
| `text_size` | size token | `:sm` |
| `padding` | spacing token / number | `:space_md` block · `4` inline |
| `scroll` | boolean | `true` — blocks only |
| `id` | string | — a native testTag |

Not ported: the `*_class` attrs. `id` **is** ported, but as a test handle rather than a DOM id.

## Three things to know

**A block scrolls horizontally, and that is the point.** Code lines do not wrap, so without the
scroller a long line is quietly truncated with no way to reach the rest of it. `scroll={false}`
turns it off if you have already wrapped the text yourself.

**Inline hugs, block fills — both are set explicitly.** A Box given neither `width` nor
`fill_width` **fills its parent**, so inline code rendered as a full-width bar until
`fill_width={false}` was added, contradicting its own documentation. If you build your own inline
chip of any kind, this is the line to remember.

**There is no syntax highlighting, and it is not a gap.** The headless component has none either,
and colouring tokens needs per-token spans — `Text` takes one string and one colour. What you get
is the platform's real monospace face (Roboto Mono / SF Mono) via `font: "monospace"`, not an
approximation.

## Related
`mark` (a tinted run of ordinary prose), `highlight` (search matches inside a sentence),
`action_icon` (the copy button a block usually wants beside it).
