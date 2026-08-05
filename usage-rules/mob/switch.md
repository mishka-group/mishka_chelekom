# switch (mob)

An on/off control, mapped onto Mob's native `Toggle`. See [README](README.md) for the rules every
Mob component shares.

## Generate
`mix mishka.ui.gen.mob switch` → `lib/<app>/components/switch.ex`, tag `<Switch />`. With
`--module-prefix mishka_` it is `<MishkaSwitch />`.

## What it renders

One `Toggle` node — a Compose `Switch` on Android, a SwiftUI `Toggle` on iOS. It is a thin wrapper
by design: the platform control animates, reports accessibility state and follows the system's own
switch metrics, none of which a track-and-thumb built from Boxes would.

```elixir
~MOB"""
<MishkaSwitch label="Wi-Fi" checked={@wifi?} on_change={:wifi_changed} />
"""

# Controlled: nothing moves until the screen writes the value back.
def handle_info({:change, :wifi_changed, on?}, socket) do
  {:noreply, Mob.Socket.assign(socket, :wifi?, on?)}
end
```

## Props

| Prop | Values | Default |
|---|---|---|
| `checked` | boolean | `false` |
| `label` | string | `nil` — leads; the switch trails |
| `on_change` | event tag (atom) | — omit for a read-only switch |
| `color` | colour token / ARGB int | platform — the **thumb** when on |
| `track_color` | **ARGB int only** | platform — the **track** when on |
| `disabled` | boolean | `false` |

Not ported: `name`, `value`, `unchecked_value`, `form`, `required` (they exist only to make an
`<input>` submit inside an HTML form) and `id`.

## Five things to know

**`color` is the thumb, `track_color` is the track.** Set only `color` and you recolour half the
control while the track keeps the theme default — which reads as a two-tone switch nobody asked
for. That is not a bug to route around; it is why both props exist. Set both, or neither.

**`track_color` takes no colour tokens.** Mob's renderer resolves tokens only for the props in its
`@color_props` whitelist — `background`, `text_color`, `border_color`, `color`, `placeholder_color`
— and `track_color` is not among them. Pass `:primary` and it arrives as an unparseable string and
is **silently ignored**; pass `0xFF7C3AED` and it works. `color` is whitelisted and takes either.

**`disabled` means "no handler", not "greyed out".** Both `disabled` and the web's `readonly`
collapse into omitting the handler: `Toggle` is controlled, so with nothing listening the thumb
cannot move. The platform still paints an *enabled-looking* switch — the bridge does not forward
Compose's `enabled` flag — so pair it with a muted label when the distinction matters.

**Omitting `label` is a layout decision, not a cosmetic one.** The built-in label always leads and
the switch always trails. That is the only arrangement `label=` can produce. Drop it and the switch
is just a node you can place: leading, trailing, inside a card row, wherever. If your "no label"
version rebuilds text-spacer-switch by hand, you have written the labelled version the long way.

**Give each switch its own assign.** Two switches bound to the same assign move together, and on a
page of examples that looks like a rendering bug rather than the state bug it is.

## iOS gaps, all in the dependency

None of these is the component's doing and none can be fixed from the Chelekom layer. They are
listed so you do not spend an afternoon on them:

| | On iOS |
|---|---|
| `color` / `track_color` | ignored — `MobToggle` has no `.tint(...)`, so the control paints the system accent |
| controlled state | it is **not** — `MobToggle` seeds a `@State` once in its initialiser and binds the control to that local copy, so the thumb moves on touch whatever the screen decides |
| `disabled` | does not disable — it works by omitting the handler, which only stops an uncontrolled control from *reporting*, not from moving |

Do not rely on the screen being able to refuse a change on iOS.

The label used to be a fourth row here — the bridge decodes text from `props["text"]`, so a `label`
prop never arrived and the Toggle rendered blank. The component now builds that row itself, out of
an ordinary `Text` and a flexible `Spacer`, so the label works on both platforms and is styleable.

## Related
`checkbox` (a choice in a set, rather than a setting that takes effect at once), `toggle` (a pressed
button), `chip` (a filter), `radio_group` (one of many).
