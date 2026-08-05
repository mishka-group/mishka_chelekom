# avatar (mob)

An image with a text fallback — usually initials. See [README](README.md) for the rules every Mob
component shares.

## Generate
`mix mishka.ui.gen.mob avatar` → `lib/<app>/components/avatar.ex`, tag `<Avatar />`. With
`--module-prefix mishka_` it is `<MishkaAvatar />`.

## What it renders

```
box    size × size, corner_radius from shape, align: :center
├── box   the fallback — background + initials (or your children)
└── image the picture, drawn OVER it, only when src is set
```

## Example

```elixir
~MOB"""
<Row>
  <MishkaAvatar src={@user.avatar_url} initials={initials(@user)} size={40} />
  <MishkaAvatar initials="SH" shape={:rounded} background={0xFF7C3AED} color={0xFFFFFFFF} />
</Row>
"""
```

No events — an avatar is presentational. Wrap it in a tappable `Box` if you need one, and give
that Box the handler.

## Props

| Prop | Values | Default |
|---|---|---|
| `src` | string | `nil` — a URL or an on-device path |
| `initials` | string | `nil` — children override it |
| `size` | number | `44` — both axes; an avatar is square |
| `shape` | `:circle` · `:rounded` · `:square` | `:circle` |
| `background` | colour token / ARGB | `:surface_raised` — the fallback's fill |
| `color` | colour token / ARGB | `:on_surface` — the initials |
| `text_size` | size token | `:lg` |
| `id` | string | — a native testTag |

Helper: `radius(shape, size)` → `size / 2` for `:circle`, `0` for `:square`, `10` otherwise.

Not ported: `alt` (no screen-reader text on a Mob image), `width` / `height` (an avatar is square —
use `size`), `referrer_policy`, `crossorigin`, `delay`, `on_loading_status_change` and the
`*_class` attrs.

## Three things to know

**The fallback is stacked, not swapped.** The web always renders the fallback and lets CSS hide
it once the image paints. There is no CSS here — but a `Box` stacks its children with the last on
top, so the port renders `[fallback, image]`. The initials show immediately and the picture covers
them when it arrives. Same intent, no flash of empty space, and nothing to wire: that is why
`delay` and `on_loading_status_change` are absent rather than missing.

**`:circle` is `size / 2`, not a radius token.** A token is a fixed number of dp, so a circle
built from one stops being a circle as soon as the size changes. `radius/2` computes it, which is
why a 24 avatar and a 96 avatar are both round.

**Give it an `id` if a test must find it.** An avatar showing an image renders no text at all —
Mob turns `:id` into a native testTag, and it is the only handle there is.

## Related
`skeleton` with `shape: :circle` — the placeholder an avatar is usually swapped in for; match the
`size` on both or the row jumps when the data lands.
