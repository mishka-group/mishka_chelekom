# highlight (mob)

Text with matching substrings marked, as in search results. Built on
[mark](mark.md) — read that one for why a highlight is a `Box` and not a text attribute.

## Generate
`mix mishka.ui.gen.mob highlight` → `lib/<app>/components/highlight.ex`, tag `<Highlight />`.
Pulls in `mark` as a sibling.

## What it renders

```
row                          one line — the default
├── text   plain run
├── box    matched run       a Mark
└── text   plain run

column                       with wrap_at: N
├── row  · spacer · row …
```

## Example

```elixir
~MOB"""
<MishkaHighlight
  text="Highlight This, definitely THIS and also this!"
  highlight="this"
  wrap_at={34}
/>
"""
```

All three are marked, and **each renders with the casing it has in the text**, not the casing you
searched for. Pass a list to match several queries; blank and `nil` queries are ignored, and an
unmatched query leaves the text plain rather than erroring.

No events — it is presentational.

## Props

| Prop | Values | Default |
|---|---|---|
| `text` | string | `""` |
| `highlight` | string or list | `[]` |
| `case_sensitive` | boolean | `false` |
| `wrap_at` | integer or `nil` | `nil` — one Row |
| `line_space` | number | `4` |
| `background` / `color` | colour token / ARGB | the mark's amber / ink |
| `text_color` | colour token / ARGB | `:on_surface` |
| `text_size` | size token | `:base` |

Helpers: `split(text, queries, opts)` → `[{:mark | :text, run}]`, `wrap(parts, budget)` → lines.

## Three things to know

**A sentence is many nodes, and a `Row` does not wrap.** `Text` takes one string and exposes no
span API, so a partially highlighted sentence has to be several nodes side by side. Without
`wrap_at` the line runs straight off the edge — silently, since nothing clips or complains.

**`wrap_at` is a character budget, not a measurement.** No geometry is reported back to
`render/1`, so nothing can ask how much fits; the count has to be declared, the same trade
`overflow_list` makes with `visible`. Breaks land after whitespace so a wrapped line never begins
with a space, and a mark is never split — it is one `Box`, and one longer than the budget takes a
line to itself.

**One fill covers every match.** For a line where each match means something different — `Error`
in red beside `Success` in green — compose `mark` and `Text` yourself. The web component draws the
same line: it has a single `mark_class`.

```elixir
~MOB"""
<Row>
  <MishkaMark text="Error" background={0xFFFECACA} />
  <Text text=": Invalid input." />
</Row>
"""
```

## Case sensitivity

Matching is case-insensitive by default; `case_sensitive={true}` marks only the exact casing.
(Mantine spells the same switch `caseInsensitive={false}`.) **The web component has no equivalent
attr yet** — it is hardcoded insensitive — so this is the one place the Mob port is ahead of it.

## Related
`mark` (one highlighted run, and what this is built from).
