# rolling_number (mob)

A number that counts up to its value. See [README](README.md) for the rules every Mob component
shares.

## Generate
`mix mishka.ui.gen.mob rolling_number` → `lib/<app>/components/rolling_number.ex`, tag
`<RollingNumber />`. With `--module-prefix mishka_` it is `<MishkaRollingNumber />`.

## What it renders

One `Text` node holding the formatted number. That is the whole tree — the interesting part is who
owns the animation.

## The roll is the screen's, not the component's

The web version runs a JS hook that tweens from the old value to the new one over `duration`. A Mob
component is a pure function of its props and **cannot animate itself** — one that started a timer
would start a fresh one on every render. So the component renders whatever number it is handed, and
`steps/3` gives you the sequence to walk:

```elixir
# kick it off
def handle_info({:tap, :roll}, socket) do
  [next | rest] = RollingNumber.steps(socket.assigns.count, 1_284, 18)
  if rest != [], do: Process.send_after(self(), {:roll, rest}, 24)
  {:noreply, Mob.Socket.assign(socket, :count, next)}
end

# and walk it
def handle_info({:roll, [next | rest]}, socket) do
  if rest != [], do: Process.send_after(self(), {:roll, rest}, 24)
  {:noreply, Mob.Socket.assign(socket, :count, next)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

`steps/3` eases out (early steps move further than late ones), always **lands exactly on the
target**, counts down as happily as up, and degenerates safely: a flat range repeats the value, and
zero or fewer steps jumps straight to the target.

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | integer | `0` |
| `separator` | string | `","` — `""` disables grouping |
| `text_size` | size token | `:"2xl"` |
| `color` | color token / ARGB int | `:on_surface` |

Not ported: `duration` and `locale` (see below), `id` and the `*_class` attrs.

## Three things to know

**Grouping is a character, not a locale.** `locale`-aware grouping is not ported — Elixir has no
`Intl.NumberFormat`, and guessing a locale's separators would be worse than not trying. Pass the
character you want: `","` (default), `" "` for the European style, `"."`, or `""` for none. The sign
stays outside the grouping, so `-1234` formats as `-1,234`.

**Nothing here is animated by the component, so a still screenshot is the honest test.** If you want
to assert the roll, assert `steps/3` — it is a pure function. Asserting the rendered text mid-roll
is a race.

**Don't drive it from a render.** The value must come from assigns, updated by a message. Calling
`steps/3` inside `render/1` produces a new sequence every frame and the number never settles.

## Related
`number_formatter` (formats without counting), `progress` (a bar rather than a number),
`number_field` (input rather than display), `semi_circle_progress` (a gauge with a readout).
