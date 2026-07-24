# Mishka Chelekom — web showcase (development harness)

The Phoenix LiveView app that renders and dogfoods the Chelekom component
library, consumed as a path dep at `../../` (this app lives under
`development/web/`). Deeper repo/agent guidance is in `AGENTS.md`.

## Before finishing any task

Run `mix precommit`. Fix everything it reports. **Do not report work as done
while it fails.** It's the fixed definition of "good" between generated code and
the branch — the tools catch what's mechanical; the judgment is still yours.

`mix precommit`: `compile --warnings-as-errors`, `format --check-formatted`,
`deps.unlock --check-unused`, `deps.audit`, `hex.audit`, `credo --strict`,
`sobelow --config` (Phoenix web security — XSS / CSRF / SQL injection in
controllers and HEEx), and `test --warnings-as-errors`. Dialyzer is separate
(slow, PLT-cached): `mix dialyzer`.

## Standards

- No `case` on a boolean — use `if`.
- Every public function has a `@spec` with named arguments.
- **Never use `raw/1` in HEEx** — it's an XSS hole; sanitize server-side.
- Tests must assert something meaningful — never `assert true`, no vacuous or
  assertion-free tests.
- If a preference is missed repeatedly, update **this file**, not just the diff.

## Deps

Always the latest published versions. The Chelekom library is the path dep
`{:mishka_chelekom, path: "../../"}`; the quality tools (credo, sobelow,
mix_audit, dialyxir) track hex latest.
