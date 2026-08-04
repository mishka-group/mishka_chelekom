# theme_icon (mob)

A themed container around exactly one icon. See [README](README.md) for the rules every Mob
component shares.

## Generate
`mix mishka.ui.gen.mob theme_icon` → `lib/<app>/components/theme_icon.ex`, tag `<ThemeIcon>`.
With `--module-prefix mishka_` it is `<MishkaThemeIcon>`.

## What it renders

One fixed square `Box` that centres its icon, painted by `variant` out of `color`, with a corner
radius. The icon is whatever you put inside it. Nothing else — it is a frame, not a button.

## Example

```elixir
~MOB"""
<Row>
  <MishkaThemeIcon
    id="ti-deploy"
    icon="🚀"
    label="Deploy"
    variant={:light}
    color={:error}
    size={:lg}
    on_tap={:deploy}
    on_long_press={:explain}
  />
  <Spacer size={12} />
  <MishkaThemeIcon id="ti-logo" variant={:gradient} size={:lg} radius={:full}>
    {[logo()]}
  </MishkaThemeIcon>
</Row>
"""

def handle_info({:tap, :deploy}, socket), do: {:noreply, start_deploy(socket)}

# A long press is the touch equivalent of hover, and the label rides the
# payload — so one clause explains every icon on the screen.
def handle_info({:tap, {:explain, label}}, socket) do
  {:noreply, Mob.Socket.assign(socket, :hint, label)}
end
```

## Props

| Prop | Values | Default |
|---|---|---|
| `id` | string | `nil` — testTag for the container; markers derive from it |
| `icon` | string | `nil` — glyph shorthand, used when there are no children |
| `label` | string | `nil` — what the icon means; rides the long press, tags the marker |
| `variant` | `:filled :light :outline :subtle :white :default :gradient` | `:filled` |
| `color` | colour token / ARGB int | `:primary` |
| `size` | `:xs :sm :md :lg :xl` or dp | `:md` — 20, 26, 32, 40, 48 |
| `radius` | `:none :sm :md :lg :full` or dp | `:md` |
| `gradient` | `{from, to}` / `%{from:, to:}` | `{:primary, :secondary}` |
| `icon_color` | colour token / ARGB int | the variant's choice |
| `on_tap` | event tag | — `{:tap, tag}` |
| `on_long_press` | event tag | — `{:tap, {tag, label}}` |

## Seven things to know

**The container only tints the icon it built itself.** `text_color` does not inherit in Mob the
way CSS `color` does, so an icon passed as children keeps whatever colour you gave it. The `icon`
shorthand is the one the container sizes (55% of `size`) and tints from the variant; anything
richer than a glyph is yours to colour. `icon_color` overrides the shorthand's colour and nothing
else.

**`label` is not announced anywhere.** The web flips the span to `role="img"` with an
`aria-label`; neither renderer has an accessibility-label prop on `Box`, so there is nothing to
announce into. Instead the label rides the `on_long_press` payload — a long press being the touch
equivalent of the hover that reveals a `title` — and lands in the testTag as `<id>-labelled` or
`<id>-decorative`. If the icon carries meaning, wire `on_long_press` and show the label
somewhere, or put a `Text` beside it.

**`id` is the only handle a test has.** Everything this component does is paint, and
`onNodeWithTag` cannot read a fill. So the container is tagged `<id>` and two markers spell out
the rest: `<id>-<variant>` (`ti-save-filled`, `ti-save-gradient`) and
`<id>-labelled` / `<id>-decorative`. A tappable `Box` merges its children's semantics, so read
those markers with `useUnmergedTree = true`.

**`:white` is `:surface`, not white.** Once an app has a theme, "the white variant" means the
surface colour — which is dark in a dark theme. Use `color={:white}` on a `:filled` icon if you
genuinely want the paint white.

**Two things resolve on the BEAM rather than on the device.** `:light` mixes the colour with
transparency and the gradient interpolates between its endpoints; both need numbers, so those
colours are resolved through `Mob.Theme.resolved_palette/0` when the tree is built rather than
being passed to the native side as tokens. The tree is rebuilt on every render, so they still
follow a theme change — but a colour you hand either of them must be a token the theme knows, a
base palette name, an ARGB int or `"#rrggbb"`. Anything else paints black instead of failing.

**The gradient draws its own corners.** No `Box` has a gradient background, so `variant:
:gradient` paints one into a `Mob.UI.canvas/1` as bands whose edges follow the rounded silhouette.
It does that rather than leaning on the parent's corner radius because only one of the two
platforms clips (see the gap below). The cost is one canvas per icon — fine for a header, wrong
for a hundred list rows, where `:light` reads nearly as well.

**It is not a button, and it is not a switcher.** A tappable icon with a pressed state is
[action_icon](action_icon.md); this is a decorative frame that happens to accept `on_tap`. And
below `:md` it is under the 44dp touch minimum, so wrap a small one in a padded tappable `Box`
rather than tapping the icon itself. This component used to *be* a light/dark switcher — a
switcher is three of these in a row with the active one `:filled` and the rest `:subtle`, plus
`Mob.Theme.set/1` in your handler.

## Known platform gaps

**No accessibility label, either platform.** `Box` exposes none in `MobBridge.kt` or
`MobRootView.swift` — only `Image` carries a `description` (→ `contentDescription` /
`accessibilityLabel`). So `role="img"` + `aria-label` genuinely does not port, and `label` does
what is described above instead. Passing your icon as an `<Image>` with a `description` is the one
way to get a real announcement today.

**iOS does not clip a `Box`'s children to its corner radius.** Compose applies `Modifier.clip` for
any node with a radius; SwiftUI's `MobBox` shapes only the *background*. A child that overflows the
container is therefore clipped on Android and not on iOS — which is why the gradient rounds itself
rather than trusting the parent, and why an oversized caller-supplied icon looks different on the
two platforms. Keep the icon inside the square.

**No hover, no focus ring, no pressed state.** There is no cursor to hover and no focus to ring,
and a plain `Box` does not ripple. If an icon needs to acknowledge a press, use
[action_icon](action_icon.md) or wrap it in a `Button`.

## Related
`action_icon` (the tappable, pressable version), `avatar` (the same square around a person),
`color_swatch` (the same square around nothing but a colour), `marquee`.
