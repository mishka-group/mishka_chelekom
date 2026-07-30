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
| `panel_color` | colour token / ARGB | `:surface` — the panel behind the indicator |
| `color` | colour token / ARGB | `:primary` — the indicator |
| `corner_radius` | radius token / number | `nil` |
| children | nodes | replace the indicator, panel and all |

## Five things to know

**It is not a spinner, and the difference is the point.** A spinner beside a button leaves the
form underneath live, so the user submits twice. This covers its region *and* absorbs the taps, so
a double submit is impossible while the work is in flight. If all you want is "something is
happening", use `progress` — it is one node instead of a stack.

**Match `corner_radius` to the region you cover — this one is iOS-only.** The scrim is a
rectangle. Android clips a child to its parent's shape (`nodeModifier` ends with
`m.clip(shape)`), so a rounded card hides the overhang for you and the omission is invisible
there. iOS does not, so the square corners of the scrim poke out past a rounded card. Set it and
both platforms agree.

**The indicator is a bar, and it sits on a panel.** Mob's only self-animating busy indicator is
linear — `LinearProgressIndicator` on Android, `.progressViewStyle(.linear)` on iOS, with no
circular option reachable from a Progress node. A lone 4dp rule centred on a large scrim reads as a
stray divider rather than a loader, which is exactly how it was reported, so the bar and its label
sit on a small fixed-width panel. Give the panel a dark `panel_color` when the scrim is dark, or
supply children and own the body entirely.

Do not swap the bar for a canvas ring. `Mob.Canvas.arc/6` would draw one, but nothing would turn
it — Mob has no animation primitive for ordinary nodes — and a still ring is a worse liveness
signal than a moving bar.

**Never centre with a Column.** A Column cannot align its children on either platform: Android maps
it to a bare Compose `Column` with no `horizontalAlignment`, iOS to `VStack(alignment: .leading)`
under an unconditional `.frame(maxWidth: .infinity, alignment: .topLeading)`. `fill_width={false}`
does not help — iOS never reads it for a Column. This component shipped with exactly that mistake:
the label left-aligned against the 140dp bar and sat visibly off centre on Android, and pinned to
the far left edge on iOS. Every part now gets its own centring Box.

**Cover the page, not the card, by mounting it at the screen root.** Inside a card it can only
ever cover that card. For a screen-wide busy state, make it the last child of `render/1`'s outermost
Box:

```elixir
def render(assigns) do
  ~MOB"""
  <Box fill_width={true} fill_height={true}>
    {page(assigns)}
    <MishkaLoadingOverlay visible={@syncing?} scrim_color={0x99FFFFFF}>
      {panel}
    </MishkaLoadingOverlay>
  </Box>
  """
end
```

A lower alpha on `scrim_color` (`0x99` ≈ 60%) leaves the page legible through the scrim, which is
what makes a full-page cover feel like glass rather than a blank wall. There is no blur primitive —
alpha is the whole effect.

**Children replace the indicator, panel and all — so bring your own `Progress`.** That is the hook
for a real busy panel: an icon, a headline, a line of detail, and a way out. Two things to know
about building one. Your panel is centred for you (the component wraps children in a centring Box),
but *inside* it a Column still cannot align its children — centre Texts with
`fill_width={true} text_align={:center}`, and let a `Progress` or a `fill_width` Button span the
panel. And a control inside the scrim **does** get its own taps: children are hit-tested before the
scrim beneath them, so a Cancel button works even though the scrim absorbs everything else. Without
that, a full-page overlay would be a trap with no way out.

**Invisible costs nothing.** `visible={false}` builds an empty `Column` — no scrim, no indicator,
no handler — so it is safe to leave in the tree permanently. There is no need to wrap it in an
`:if`.

## Watch the scrim colour against the theme

The default is a near-opaque **white**, which is right on a light surface and wrong on a dark one:
under the dark or Material themes it flashes white over dark content, and the `:muted` label lands
near the bottom of readable contrast. If your app ships dark themes, pass a `scrim_color` that
suits them — and a `panel_color` to match, or a light panel will sit on your dark scrim.

`label` is the web component's `aria-label`, which defaults to `"Loading"` there and is never
visible. Here it renders as real text, so the default is `nil`: porting the web default would put
a word on screen that the web never shows. Pass one when the surrounding screen does not already
say why.

## Related
`progress` (the animated indicator this uses), `skeleton` (a placeholder for content that has not
arrived, rather than a cover over content that has).
