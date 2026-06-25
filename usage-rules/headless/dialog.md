# dialog (headless)

An unstyled, accessible modal dialog: markup + WAI-ARIA wiring + focus management, with behavior delegated to the shared `FocusTrap` JS engine. Implements the [WAI-ARIA APG Dialog (Modal) pattern](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/).

## Generate

```bash
mix mishka.ui.gen.headless dialog
```

Generates `lib/<app>_web/components/headless/dialog.ex`. Wire up the JS engine in `app.js`:

```js
import FocusTrap from "./focus_trap.js";
const Hooks = { FocusTrap };
```

## Anatomy

The root is a `<div>` carrying `phx-hook="FocusTrap"` and `class="chelekom-dialog"`. Parts are marked with `data-part` hooks the engine queries:

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

Roles and aria attributes (wired by the template + engine):

- **trigger** — engine sets `aria-haspopup="dialog"`, `aria-expanded` (toggled `false`/`true`), and `aria-controls` pointing at the popup id.
- **backdrop** — `aria-hidden="true"`.
- **popup** — `role="dialog"`, `aria-modal="true"`, `tabindex="-1"`, plus `aria-labelledby` (the `@labelledby` attr or `#{@id}-title` when a `<:title>` is present) and `aria-describedby` (the `@describedby` attr or `#{@id}-desc` when a `<:description>` is present).

Keyboard (handled by `FocusTrap`):

- **Escape** — closes (unless `data-close-on-escape="false"` on the root).
- **Tab** — cycles forward through visible focusables, wrapping from last to first (focus trapped inside the popup).
- **Shift+Tab** — cycles backward, wrapping from first to last.

Focus is moved to the first focusable (or the popup) on open and restored to the opener on close. Clicking the backdrop closes the dialog (unless `data-close-on-outside="false"`).

## State

Paired-presence (Base-UI style) attributes, toggled by the `FocusTrap` engine on both the root and the popup:

- `data-open` — present when the dialog is open.
- `data-closed` — present when the dialog is closed.

The two are always mutually exclusive. On the trigger, `aria-expanded` mirrors the open state. The template renders the initial `data-open`/`data-closed` from the `open` assign; thereafter `FocusTrap` re-syncs in `updated()` (so server-driven `open` toggling also works).

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

Attrs: `id` (required), `open` (boolean, default `false`), `labelledby`, `describedby`, `class`, and `rest` (global). Slots: `trigger`, `title`, `description`, `inner_block` (required, the body), `close`. Put `data-close` on any button inside the dialog to make the engine close on click. To drive it from the server, toggle the `open` assign.

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-dialog*` classes (`chelekom-dialog`, `__trigger`, `__backdrop`, `__popup`, `__title`, `__description`, `__content`, `__footer`) and the `data-open` / `data-closed` state attributes, e.g.:

```css
.chelekom-dialog__backdrop[data-closed] { display: none; }
.chelekom-dialog__popup[data-open]      { /* visible styles */ }
.chelekom-dialog__popup[data-closed]    { display: none; }
```

Add your own classes to the root via the `class` attr.
