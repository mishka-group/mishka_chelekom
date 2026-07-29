# loading_overlay (mob)

A scrim over a region while it is busy — and, more usefully, a lid on the taps aimed at what it
covers. See [README](README.md) for the rules every Mob component shares.

## Generate
`mix mishka.ui.gen.mob loading_overlay` → `lib/<app>/components/loading_overlay.ex`, tag
`<LoadingOverlay />`. With `--module-prefix mishka_` it is `<MishkaLoadingOverlay />`.

## What it renders

```
column                                    when visible is false — nothing at all

box     the scrim, fill_width + fill_height, carries a no-op on_tap
└── column
    ├── box(140)  an indeterminate Progress
    └── text      the label, when given
```

## Example

```elixir
~MOB"""
<Box>
  {content}
  <MishkaLoadingOverlay visible={@saving?} label="Saving…" corner_radius={:radius_md} />
</Box>
"""
```

**Put it last inside the Box it covers.** A Box stacks its children, so whatever comes after is
drawn on top — and being on top is the entire mechanism.

No event props. The scrim sends a no-op tag of its own while visible; the catch-all `handle_info/2`
every screen already needs swallows it, and that is what stops taps reaching the content below.

## Props

| Prop | Values | Default |
|---|---|---|
| `visible` | boolean | `false` |
| `label` | string | `nil` — omitted entirely, not rendered empty |
| `scrim_color` | ARGB int / token | `0xCCFFFFFF` |
| `color` | colour token / ARGB | `:primary` — the indicator |
| `corner_radius` | radius token / number | `nil` |
| children | nodes | replace the indicator and label |

## Three things to know

**It is not a spinner, and the difference is the point.** A spinner beside a button leaves the
form underneath live, so the user submits twice. This covers its region *and* absorbs the taps, so
a double submit is impossible while the work is in flight. If all you want is "something is
happening", use `progress` — it is one node instead of a stack.

**Match `corner_radius` to the region you cover.** The scrim is a rectangle; over a rounded card
without it, the corners visibly overhang.

**Invisible costs nothing.** `visible={false}` builds an empty `Column` — no scrim, no indicator,
no handler — so it is safe to leave in the tree permanently. There is no need to wrap it in an
`:if`.

## Watch the scrim colour against the theme

The default is a near-opaque **white**, which is right on a light surface and wrong on a dark one:
under the dark or Material themes it flashes white over dark content, and the `:muted` label lands
near the bottom of readable contrast. If your app ships dark themes, pass a `scrim_color` that
suits them rather than taking the default.

## Related
`progress` (the animated indicator this uses), `skeleton` (a placeholder for content that has not
arrived, rather than a cover over content that has).
