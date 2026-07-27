# Mishka Chelekom — Mob components

Native components for [Mob](https://hexdocs.pm/mob), BEAM-on-device. They build a tree of
**platform widgets** that Compose and SwiftUI draw — no HTML, no CSS, no JS. A Mob app is a
plain OTP app: no `_web` namespace.

## Generate

```bash
mix mishka.ui.gen.mob otp_field        # one (pulls in siblings it calls)
mix mishka.ui.gen.mob.components       # all of them
mix mishka.ui.uninstall otp_field --mob
```

Output: `lib/<app>/components/otp_field.ex`, module `<App>.Components.OtpField`, tag
`<OtpField />`. Each run also maintains `lib/<app>/components.ex`, calls `register_all/0` from
your `on_start/0`, and adds the tags to Mob's `~MOB` whitelist.

`--module-prefix mishka_` renames all three at once: `mishka_otp_field.ex`,
`MishkaOtpField`, `<MishkaOtpField />`. Worth doing — `Mob.Composite`'s tag table is global, so
an unprefixed `:otp_field` can collide with a composite the app already registered.

## Write them as tags

Components are `Mob.Composite`s, so they are tags inside `~MOB`:

```elixir
~MOB"<OtpField value={@code} length={6} on_change={:code} />"
```

The function form (`{otp_field(value: @code)}`) is equivalent and used only for what a tag
cannot express.

## Three rules that are easy to get wrong

**1. Event props must be handler-wrapped.** The renderer only registers a handler when the prop
is `{screen_pid, tag}`. A bare atom serialises as an ordinary prop, and the control then renders
perfectly and does nothing. Inside a component use `Event.handler/1`; from a screen, passing the
atom to a composite is enough — `expand/3` injects the target.

**2. Event shapes.**

| Event | Message |
|---|---|
| tap | `{:tap, tag}` |
| value change | `{:change, tag, value}` |
| submit | `{:submit, tag}` — no payload |
| focus / blur | `{:focus, tag}` / `{:blur, tag}` — **not** taps |

**3. A screen needs a catch-all `handle_info/2`.** Components route stray events to ignored tags;
without it the screen crashes.

## Screens

```elixir
defmodule MyApp.CodeScreen do
  use Mob.Screen
  import Mob.Sigil

  # The tag needs no alias — it resolves through Mob.Composite at runtime. The
  # alias is for the module's helper functions.
  alias MyApp.Components.OtpField

  def mount(_params, _session, socket), do: {:ok, Mob.Socket.assign(socket, :code, "")}

  def render(assigns) do
    ~MOB"<Column fill_width={true}><OtpField value={@code} on_change={:code} /></Column>"
  end

  def handle_info({:change, :code, raw}, socket) do
    {:noreply, Mob.Socket.assign(socket, :code, OtpField.sanitize(raw, length: 6))}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}
end
```
