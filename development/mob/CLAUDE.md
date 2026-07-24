# MishkaMob — agent guide

The native (BEAM-on-device) Mob showcase for Mishka Chelekom components. UI is
rendered natively (SwiftUI / Jetpack Compose) from Elixir node maps — there is
**no HTML, HEEx, CSS, JS, or Phoenix** here. See `MISHKA_MOB_INTEGRATION.md` for
the port design.

## Before finishing any task

Run `mix precommit`. Fix everything it reports. **Do not report work as done
while it fails.** It's the fixed definition of "good" that sits between generated
code and the branch — the tools catch what's mechanical; the judgment (reading
the code) is still yours.

`mix precommit` bundles: `compile --warnings-as-errors`, `format
--check-formatted`, `deps.unlock --check-unused`, `deps.audit`, `hex.audit`,
`credo --strict` (with ex_slop, which flags AI patterns — blanket rescue,
narrator docs, redundant Enum chains), `xref graph --label compile-connected
--fail-above 0` (so a runtime dependency doesn't quietly become a compile-time
one and balloon recompiles), and `test --warnings-as-errors`. Dialyzer is
separate (slow, PLT-cached): `mix dialyzer`.

**Sobelow is intentionally absent.** It scans Phoenix web surfaces (XSS / CSRF /
SQL injection in controllers and HEEx). This app has no web endpoint, so it does
not apply. The web showcase (`../web`) keeps it.

## Standards

- No `case` on a boolean — use `if`.
- Every public function has a `@spec` with named arguments.
- Tests must assert something meaningful — never `assert true`, no
  assertion-free or vacuous tests (the false confidence you don't want written
  into the suite).
- If a preference is missed repeatedly, update **this file**, not just the diff.

## Mob-specific

- **UI is native node maps** `%{type:, props:, children:}` (or the `~MOB`
  sigil). No HTML/HEEx, no `raw/1`, no Tailwind — don't reach for web idioms.
- Screens are GenServers (`use Mob.Screen`): `mount/3`, `render/1` returning a
  node tree, events via `handle_info({:tap, tag}, socket)` with a **mandatory
  catch-all** clause.
- Custom widgets are `Mob.Composite`s (pure-Elixir tags) registered in
  `MishkaMob.App.on_start/0` — don't ship native Swift/Kotlin unless a widget
  genuinely needs it.
- A new showcase component is **one module** implementing
  `MishkaMob.Showcase.Component` + **one `register/1` line** — never a new screen.
- `weight` shares the parent's MAIN axis (width in a Row, height in a Column);
  a standalone full-width button uses `fill_width`, not `weight`. A Compose
  `Box` wraps its content (an iOS Box fills width) — full-width sheets are a
  Column. Verify layout on a real device (`mix deploy`, then `Mob.Test`) before
  claiming a visual works; unit tests check tree shape, not rendering.

## Deps

Always the latest published versions — the repo root pins none of these quality
tools, so track hex latest. `mob.exs` and `android/local.properties` are
machine-specific and gitignored.
