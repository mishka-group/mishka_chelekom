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
`height`, `corner_radius`, `label_size`, `label_color`, `value_size`, `value_color` and
`font_family` from the app's own design system.

## Example

```elixir
<MishkaStatBar label="Action" value={0.6} value_text="6h" color={0xFF4E9A73} />
```
