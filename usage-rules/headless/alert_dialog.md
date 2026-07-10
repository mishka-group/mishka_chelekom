# alert_dialog (headless)

An unstyled, accessible confirmation dialog: markup + WAI-ARIA wiring + focus management, behavior delegated to the shared `FocusTrap` JS engine. Implements the [WAI-ARIA APG Alert Dialog pattern](https://www.w3.org/WAI/ARIA/apg/patterns/alertdialog/). Unlike a plain dialog, the root hardcodes `data-close-on-outside="false"` — a backdrop click does **not** dismiss it; the user must make an explicit choice.

## Generate

```bash
mix mishka.ui.gen.headless alert_dialog
```

Generates `lib/<app>_web/components/headless/alert_dialog.ex`. Wire up the JS engine in `app.js`:

```js
import FocusTrap from "./focus_trap.js";
const Hooks = { FocusTrap };
```

## Anatomy

Root is a `<div>` with `phx-hook="FocusTrap"`, `class="chelekom-alert-dialog"`, `data-close-on-outside="false"`. Parts carry `data-part` hooks the engine queries:

| Part | Element | `data-part` | Class | Rendered when |
|------|---------|-------------|-------|-------|
| root | `div` | — | `chelekom-alert-dialog` | always |
| trigger | `button` | `trigger` | `chelekom-alert-dialog__trigger` | `<:trigger>` non-empty |
| backdrop | `div` | `backdrop` | `chelekom-alert-dialog__backdrop` | always (auto) |
| popup | `div` | `popup` | `chelekom-alert-dialog__popup` | always |
| title | `h2` | `title` | `chelekom-alert-dialog__title` | `<:title>` slot (required) |
| description | `p` | `description` | `chelekom-alert-dialog__description` | `<:description>` slot (required) |
| content | `div` | `content` | `chelekom-alert-dialog__content` | `inner_block` non-empty |
| actions | `div` | `actions` | `chelekom-alert-dialog__actions` | `<:actions>` non-empty |

`FocusTrap` queries `[data-part="trigger"]`, `[data-part="popup"]`, `[data-part="backdrop"]`, and all `[data-close]` elements inside the root.

## ARIA & keyboard

- **trigger** — engine sets `aria-haspopup="dialog"`, `aria-expanded` (toggled `false`/`true`), `aria-controls` pointing at the popup id.
- **backdrop** — `aria-hidden="true"`.
- **popup** — `role="alertdialog"`, `aria-modal="true"`, `tabindex="-1"`, plus `aria-labelledby` (`@labelledby` attr or `#{@id}-title`) and `aria-describedby` (`@describedby` attr or `#{@id}-desc`). `<:title>` (`h2`, id `#{@id}-title`) and `<:description>` (`p`, id `#{@id}-desc`) anchor these and are both **required**.
- **Escape** — closes (unless `data-close-on-escape="false"` on root).
- **Tab / Shift+Tab** — cycle focus forward/backward through visible focusables, wrapping (trapped inside popup).
- Focus moves to the first focusable (or the popup) on open, restored to the opener on close.
- Backdrop click does **not** close it (`data-close-on-outside="false"`) — dismissal only via Escape or a `data-close` button in `<:actions>`.

## State

Paired-presence (Base-UI style) attrs, toggled by `FocusTrap` on both root and popup — always mutually exclusive:

- `data-open` — present when open.
- `data-closed` — present when closed.

`aria-expanded` on the trigger mirrors open state. Template renders initial `data-open`/`data-closed` from the `open` assign; `FocusTrap` re-syncs in `updated()`, so server-driven `open` toggling also works.

## Example

```heex
<.alert_dialog id="confirm-delete">
  <:trigger>Delete account</:trigger>
  <:title>Delete account</:title>
  <:description>This permanently removes your account and all data.</:description>

  <p>This action cannot be undone. Are you absolutely sure?</p>

  <:actions>
    <button type="button" data-close>Cancel</button>
    <button type="button" phx-click="delete_account" data-close>Delete</button>
  </:actions>
</.alert_dialog>
```

- **Attrs**: `id` (required, anchors aria relationships), `open` (boolean, default `false`), `labelledby`, `describedby`, `class`, `rest` (global).
- **Slots**: `trigger`, `title` (required), `description` (required), `inner_block` (body), `actions`.
- Put `data-close` on any button inside `<:actions>` to make the engine close it on click. Drive from the server by toggling the `open` assign.

## Styling

Ships **no** colors or spacing — structural markup only. Style via `chelekom-alert-dialog*` classes (`chelekom-alert-dialog`, `__trigger`, `__backdrop`, `__popup`, `__title`, `__description`, `__content`, `__actions`) and the `data-open`/`data-closed` state attrs:

```css
.chelekom-alert-dialog__backdrop[data-closed] { display: none; }
.chelekom-alert-dialog__popup[data-open]      { /* visible styles */ }
.chelekom-alert-dialog__popup[data-closed]    { display: none; }
```

Add custom classes to the root via `class`.
