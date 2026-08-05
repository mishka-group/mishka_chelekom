# otp_field (mob)

Segmented one-time-code input: a row of slots the user types into directly. Native widgets, no
HTML. See [README](README.md) for the event shapes every Mob component shares.

## Generate
`mix mishka.ui.gen.mob otp_field` → `lib/<app>/components/otp_field.ex`, tag `<OtpField />`
(+ the `Event` kit, the tag registration, and the `~MOB` whitelist entry). With
`--module-prefix mishka_` it is `<MishkaOtpField />`.

## Example

```elixir
def render(assigns) do
  ~MOB"""
  <OtpField id="code" value={@code} length={6} on_change={:code} />
  """
end

def handle_info({:change, :code, raw}, socket) do
  code = OtpField.sanitize(raw, length: 6)
  if OtpField.complete?(code, length: 6), do: submit(code)
  {:noreply, Mob.Socket.assign(socket, :code, code)}
end

def handle_info(_msg, socket), do: {:noreply, socket}
```

**`sanitize/2` is required, not optional.** It is what enforces `length` and
`validation_type` — the field deliberately does not cap input natively, because a native cap
would refuse a pasted `123-456` whole instead of stripping the separator. Assign the sanitized
value back and the correction shows up on screen.

## Props

| Prop | Values | Default |
|---|---|---|
| `value` | string | `""` |
| `length` | integer | `6` |
| `validation_type` | `:numeric` `:alpha` `:alphanumeric` `:none` | `:numeric` |
| `mask` | boolean | `false` — render `•` |
| `disabled` | boolean | `false` |
| `on_change` | event tag | `{:change, tag, text}` |
| `group` + `separator` | int or list, string | `3` → `123-456`; `[3, 4]` → `Abs-5563`. Both required. |
| `focused` + `on_focus`/`on_blur` | boolean, event tags | draws the caret; see below |
| `id` | string | sets a native testTag, for e2e tests |
| `color`, `slot_width` | color token / number | `:primary`, `44` |

Helpers: `sanitize/2`, `complete?/2`, `boundaries/1`.

## Two things that surprise people

**The slots ARE the input.** An invisible full-width `TextField` is stacked over them, so paste,
backspace and the system keyboard all behave normally. There is no second visible field. Its
`id` is the only handle a test has, since it draws nothing.

**Focus and blur are not taps.** They arrive as `{:focus, tag}` / `{:blur, tag}`, even though the
renderer registers them with `register_tap/1`. A screen matching on `{:tap, tag}` sees nothing,
the caret never appears, and everything else keeps working — which makes it slow to spot.

```elixir
def handle_info({:focus, :code}, socket), do: {:noreply, assign(socket, :focused, true)}
def handle_info({:blur, :code}, socket), do: {:noreply, assign(socket, :focused, false)}
```

Pass `focused={@focused}` to draw the caret in the active slot.

## Not ported
`name`, `auto_complete`, `input_mode`, `transform`, `auto_submit` (the screen decides, using
`complete?/2`), and the `*_class` attrs — there is no CSS.
