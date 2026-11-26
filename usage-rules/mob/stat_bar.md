# stat_bar (mob)

**Documentation:** https://mishka.tools/chelekom/docs/mob/stat-bar

A labelled measurement: a name, a reading, and a bar under them showing the reading against
its scale. See [README](README.md) for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob stat_bar` → `lib/<app>/components/stat_bar.ex`, tag `<StatBar />`. With
`--module-prefix mishka_` it is `<MishkaStatBar />`.

## The reading is the caller's

`value` is a `0.0..1.0` fraction, clamped; `value_text` is the string a person reads (`6h`,
`72%`, `3 of 5`). The component never formats a number, because the unit is a property of the
data rather than of a bar.

## Headless

No background, palette token or type scale beyond plain numbers. Pass `color`, `track_color`,
`height`, `corner_radius`, `label_size`, `label_color`, `label_font_weight`, `value_size`,
`value_color`, `value_weight` and `font_family` from the app's own design system.

## A ranked row is the same row

A "watched most" list is this component with `leading`: the rank before the name, the name as
the label, the count as the reading. `leading` takes a string, a node or a list of nodes, so a
rank, a glyph or a dot all fit. Pair it with `label_flex` when the list must stay aligned: the
label then takes the free width and truncates, while the reading is pinned to the right edge by
`label_gap`. Without `label_flex` the label hugs its text and the reading floats right behind a
flexible spacer.

## Examples

```elixir
<MishkaStatBar label="Action" value={0.6} value_text="6h" color={0xFF4E9A73} />
```

```elixir
<MishkaStatBar
  leading="1" leading_gap={10} leading_weight="bold"
  label="Apocalypse Z: New World" label_flex={1.0} label_gap={0}
  value={1.0} value_text="7" value_weight="bold" value_size={12.5}
  gap={6} height={5}
/>
```
