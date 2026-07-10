# dialog (headless)

Unstyled, accessible modal dialog: markup + WAI-ARIA wiring + focus management, delegated to the shared `FocusTrap` JS engine. Implements the [WAI-ARIA APG Dialog (Modal) pattern](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/).

## Generate

```bash
mix mishka.ui.gen.headless dialog
```

Generates `lib/<app>_web/components/headless/dialog.ex`. Wire the JS engine in `app.js`:

```js
import FocusTrap from "./focus_trap.js";
const Hooks = { FocusTrap };
```

## Anatomy

Root is a `<div>` carrying `phx-hook="FocusTrap"` and `class="chelekom-dialog"`. Parts are marked with `data-part` hooks the engine queries:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-dialog` | always rendered |
| trigger | `button` | `trigger` | `chelekom-dialog__trigger` | `<:trigger>` slot |
| backdrop | `div` | `backdrop` | `chelekom-dialog__backdrop` | always rendered (auto) |
| popup | `div` | `popup` | `chelekom-dialog__popup` | always rendered |
| title | `h2` | `title` | `chelekom-dialog__title` | `<:title>` slot |
| description | `p` | `description` | `chelekom-dialog__description` | `<:description>` slot |
| content | `div` | `content` | `chelekom-dialog__content` | `inner_block` (required) |
| footer | `div` | `footer` | `chelekom-dialog__footer` | `<:close>` slot |

`FocusTrap` queries `[data-part="trigger"]`, `[data-part="popup"]`, `[data-part="backdrop"]`, and all `[data-close]` elements inside the root.

## ARIA & keyboard

- **trigger** — engine sets `aria-haspopup="dialog"`, `aria-expanded` (toggled `false`/`true`), `aria-controls` (popup id).
- **backdrop** — `aria-hidden="true"`.
- **popup** — `role="dialog"`, `aria-modal="true"`, `tabindex="-1"`, `aria-labelledby` (`@labelledby` attr, else `#{@id}-title` when `<:title>` present), `aria-describedby` (`@describedby` attr, else `#{@id}-desc` when `<:description>` present).

Keyboard (via `FocusTrap`):

- **Escape** — closes (unless `data-close-on-escape="false"` on the root).
- **Tab** — cycles forward through visible focusables, wrapping last→first (trapped inside popup).
- **Shift+Tab** — cycles backward, wrapping first→last.

Focus moves to the first focusable (or the popup) on open and restores to the opener on close. Clicking the backdrop closes the dialog (unless `data-close-on-outside="false"`).

## State

Paired-presence (Base-UI style) attrs, toggled by `FocusTrap` on both root and popup, always mutually exclusive:

- `data-open` — present when open.
- `data-closed` — present when closed.

`aria-expanded` on the trigger mirrors open state. Template renders initial `data-open`/`data-closed` from the `open` assign; `FocusTrap` re-syncs in `updated()`, so server-driven `open` toggling also works.

## Example

```heex
<.dialog id="confirm" labelledby={nil} describedby={nil}>
  <:trigger>Open dialog</:trigger>
  <:title>Delete project</:title>
  <:description>This action cannot be undone.</:description>

  <p>Are you sure you want to permanently delete this project?</p>

  <:close>
    <button type="button" data-close>Cancel</button>
    <button type="button" phx-click="delete" data-close>Delete</button>
  </:close>
</.dialog>
```

Attrs: `id` (required), `open` (boolean, default `false`), `labelledby`, `describedby`, `class`, `rest` (global). Slots: `trigger`, `title`, `description`, `inner_block` (required, the body), `close`. Put `data-close` on any button inside the dialog to close on click. Toggle the `open` assign to drive it from the server.

## Styling

Ships **no** colors or spacing — structural markup only. Style via `chelekom-dialog*` classes (`chelekom-dialog`, `__trigger`, `__backdrop`, `__popup`, `__title`, `__description`, `__content`, `__footer`) and the `data-open`/`data-closed` state attrs, e.g.:

```css
.chelekom-dialog__backdrop[data-closed] { display: none; }
.chelekom-dialog__popup[data-open]      { /* visible styles */ }
.chelekom-dialog__popup[data-closed]    { display: none; }
```

Add custom classes to the root via the `class` attr.
