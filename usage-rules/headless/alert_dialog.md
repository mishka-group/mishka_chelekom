# alert_dialog (headless)

An unstyled, accessible confirmation dialog: markup + WAI-ARIA wiring + focus management, with behavior delegated to the shared `FocusTrap` JS engine. Implements the [WAI-ARIA APG Alert Dialog pattern](https://www.w3.org/WAI/ARIA/apg/patterns/alertdialog/). Unlike a plain dialog, the root hardcodes `data-close-on-outside="false"` — a backdrop click does **not** dismiss it, so the user must make an explicit choice.

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

The root is a `<div>` carrying `phx-hook="FocusTrap"`, `class="chelekom-alert-dialog"`, and `data-close-on-outside="false"`. Parts are marked with `data-part` hooks the engine queries:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-alert-dialog` | always rendered |
| trigger | `button` | `trigger` | `chelekom-alert-dialog__trigger` | rendered when `<:trigger>` is non-empty |
| backdrop | `div` | `backdrop` | `chelekom-alert-dialog__backdrop` | always rendered (auto) |
| popup | `div` | `popup` | `chelekom-alert-dialog__popup` | always rendered |
| title | `h2` | `title` | `chelekom-alert-dialog__title` | `<:title>` slot (required) |
| description | `p` | `description` | `chelekom-alert-dialog__description` | `<:description>` slot (required) |
| content | `div` | `content` | `chelekom-alert-dialog__content` | rendered when `inner_block` is non-empty |
| actions | `div` | `actions` | `chelekom-alert-dialog__actions` | rendered when `<:actions>` is non-empty |

`FocusTrap` queries `[data-part="trigger"]`, `[data-part="popup"]`, `[data-part="backdrop"]`, and all `[data-close]` elements inside the root.

## ARIA & keyboard

Roles and aria attributes (wired by the template + engine):

- **trigger** — engine sets `aria-haspopup="dialog"`, `aria-expanded` (toggled `false`/`true`), and `aria-controls` pointing at the popup id.
- **backdrop** — `aria-hidden="true"`.
- **popup** — `role="alertdialog"`, `aria-modal="true"`, `tabindex="-1"`, plus `aria-labelledby` (the `@labelledby` attr or `#{@id}-title`) and `aria-describedby` (the `@describedby` attr or `#{@id}-desc`). The `<:title>` (`h2`, id `#{@id}-title`) and `<:description>` (`p`, id `#{@id}-desc`) anchor these relationships and are both required.

Keyboard (handled by `FocusTrap`):

- **Escape** — closes (unless `data-close-on-escape="false"` on the root).
- **Tab** — cycles forward through visible focusables, wrapping from last to first (focus trapped inside the popup).
- **Shift+Tab** — cycles backward, wrapping from first to last.

Focus is moved to the first focusable (or the popup) on open and restored to the opener on close. Clicking the backdrop does **not** close the alert dialog — the root sets `data-close-on-outside="false"`, so dismissal must come from Escape or a `data-close` button in `<:actions>`.

## State

Paired-presence (Base-UI style) attributes, toggled by the `FocusTrap` engine on both the root and the popup:

- `data-open` — present when the dialog is open.
- `data-closed` — present when the dialog is closed.

The two are always mutually exclusive. On the trigger, `aria-expanded` mirrors the open state. The template renders the initial `data-open`/`data-closed` from the `open` assign; thereafter `FocusTrap` re-syncs in `updated()` (so server-driven `open` toggling also works).

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

Attrs: `id` (required, anchors the aria relationships), `open` (boolean, default `false`), `labelledby`, `describedby`, `class`, and `rest` (global). Slots: `trigger`, `title` (required), `description` (required), `inner_block` (the body), `actions`. Put `data-close` on any button inside `<:actions>` to make the engine close on click. To drive it from the server, toggle the `open` assign.

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-alert-dialog*` classes (`chelekom-alert-dialog`, `__trigger`, `__backdrop`, `__popup`, `__title`, `__description`, `__content`, `__actions`) and the `data-open` / `data-closed` state attributes, e.g.:

```css
.chelekom-alert-dialog__backdrop[data-closed] { display: none; }
.chelekom-alert-dialog__popup[data-open]      { /* visible styles */ }
.chelekom-alert-dialog__popup[data-closed]    { display: none; }
```

Add your own classes to the root via the `class` attr.