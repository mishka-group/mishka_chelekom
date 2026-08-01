# separator (mob)

A thematic rule between groups of content, optionally carrying a centred label. See
[README](README.md) for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob separator` → `lib/<app>/components/separator.ex`, tag `<Separator />`.
With `--module-prefix mishka_` it is `<MishkaSeparator />`.

## What it renders

Three different node trees, not one with switches:

```
plain      divider
vertical   box      width: thickness, fill_height
labelled   row      divider(weight 1) — gap — text — gap — divider(weight 1)
```

## Example

```elixir
~MOB"""
<Column fill_width={true}>
  <Text text="Section one" />
  <MishkaSeparator id="sep" />
  <Text text="Section two" />

  <MishkaSeparator label="or continue with" id="or" />
</Column>
"""
```

There is no state and no event — a rule is the one component here with nothing to handle.

## Props

| Prop | Values | Default |
|---|---|---|
| `orientation` | `:horizontal` / `:vertical` | `:horizontal` — a vertical rule needs a parent that gives it height |
| `label` | string | `nil` — renders line — label — line. Horizontal only |
| `color` | colour token / ARGB int | `:border` |
| `thickness` | number | `1` (dp/pt) |
| `space` | number | `12` — gap between the label and the lines |
| `id` | string | `nil` — test tag; a labelled rule also tags each line |

Helpers: `line_ids/1`.

Not ported: `decorative` (it only flips `role="separator"` to `role="none"` in the DOM, and Mob
exposes no such role) and the `*_class` attrs.

## Four things to know

**A rule is invisible to a test without an `id`.** It draws a line: no text, no state, nothing in
the semantics tree at all. `id` is not decoration here — it is the only way to say *which* rule you
mean, and the only way to check the one thing a rule can get wrong, which is its geometry.

**A labelled rule tags its two lines separately**, `<id>-line-start` and `<id>-line-end` via
`line_ids/1`. "The label sits centred between two equal lines" is a claim about their widths, so
they need to be measurable independently. Note the `Row` merges its children's semantics, so a tag
query for either line needs `useUnmergedTree = true`.

**A vertical rule needs a parent with height.** It is a Box with a width and `fill_height` — there
is nothing inside it to give it a height of its own, so in a parent that hugs its content it
measures zero and draws nothing. Put it in a `Row` inside a `Box` with an explicit `height`.

**Set `thickness`, not `height`.** A rule's cross-axis size is `thickness` on both orientations.
There is no `height` prop, and a `Divider` ignores one.

## Known platform gaps

**Only the plain rule works on iOS.** All three gaps are in the `mob` dependency
(`development/mob/IOS_TODO.md` items 11-13):

- the **vertical** rule renders 1pt wide and **0pt tall** — invisible. iOS's `MobBox` consults
  `fill_height` only in the branch it takes when there is no `width`, and a vertical rule sets one.
- the **labelled** variant's flanking lines become 1×1pt ticks. SwiftUI's `Divider()` draws along
  its container's axis, so inside the `Row` that centres the label it is a *vertical* hairline, then
  clamped to `thickness` tall.
- `weight` is read nowhere in the iOS renderer, so even once the axis is fixed the two lines cannot
  share the leftover width.

Android is correct for all three.

## Related
`divider` (the raw native node this wraps), `spacer`, `card`.
