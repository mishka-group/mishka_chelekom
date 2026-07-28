# mark (mob)

Highlighted text — the native `<mark>`. See [README](README.md) for the rules every Mob component
shares, and [highlight](highlight.md) for marking matches inside a sentence automatically.

## Generate
`mix mishka.ui.gen.mob mark` → `lib/<app>/components/mark.ex`, tag `<Mark />`. With
`--module-prefix mishka_` it is `<MishkaMark />`.

## What it renders

```
box    the tint — corner_radius: :radius_sm, padding: 2, fill_width: false
└── text
```

That is the whole component. **A `Text` node carries no background of its own**, so a mark has to
be a `Text` inside a tinted `Box` — there is no attributed-string or span API to reach for.

## Example

```elixir
~MOB"""
<Row>
  <MishkaMark text="Error" background={0xFFFECACA} />
  <Text text=": Invalid input. " />
  <MishkaMark text="Warning" background={0xFFFDE68A} />
  <Text text=": Check this field." />
</Row>
"""
```

No events — a mark is presentational. Wrap it in a tappable `Box` if you need one.

## Props

| Prop | Values | Default |
|---|---|---|
| `text` | string | `nil` |
| `background` | colour token / ARGB | `0xFFFDE68A` (amber) |
| `color` | colour token / ARGB | `0xFF111827` |
| `text_size` | size token | `:base` |

Helpers: `default_fill/0`, `default_ink/0` — so other components can match the tint.

## Two things to know

**It hugs its text, and that is a prop.** The Box passes `fill_width={false}`. A Box given neither
`width` nor `fill_width` **fills its parent**, which turns a mark into a full-width bar — the
opposite of what `<mark>` means. If you build your own tinted Box, this is the line you will
forget.

**The defaults are ARGB, not theme tokens, on purpose.** A highlight has to stay readable against
*itself*, so a light fill paired with dark ink beats a `:surface` / `:on_surface` pair that flips
with the theme and can land light-on-light. Override both together or neither.

## Related
`highlight` (splits text on a query and marks the matches for you — it is built on this).
