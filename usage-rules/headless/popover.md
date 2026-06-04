# popover (headless)

A trigger button that toggles an anchored, dismissable popup dialog. Follows the WAI-ARIA APG **Disclosure** pattern (combined with lightweight anchored positioning).

## Generate

```
mix mishka.ui.gen.headless popover
```

Generates `lib/<app>_web/components/headless/popover.ex` and copies the `popup.js` hook into your JS assets. Register the hook in your `app.js`:

```js
import Popup from "./popup.js";
const Hooks = { Popup };
```

## Anatomy

| Part | Element | `data-part` hook | Notes |
|------|---------|------------------|-------|
| trigger | `<button>` | `data-part="trigger"` | Toggles the popup on click |
| popup | `<div>` | `data-part="popup"` | `role="dialog"`, anchored content |

The root `<div>` carries `id`, `phx-hook="Popup"`, `data-side`, `data-align`, and the `chelekom-popover` class. The `Popup` engine resolves parts by querying for `[data-part="trigger"]` and `[data-part="popup"]`.

## ARIA & keyboard

- **trigger**: `aria-expanded` (toggled `"false"`/`"true"` by the engine) and `aria-controls` (set to the popup's `id`).
- **popup**: `role="dialog"`.
- **Keyboard / dismissal**:
  - `Escape` — closes the popup and returns focus to the trigger.
  - Click outside — closes the popup.
  - On open, focus moves to the first focusable element inside the popup (`[data-part="item"]`, `[role="menuitem"]`, `[role="option"]`, `a`, or `button`).

## State

Paired-presence attributes on the popup, toggled by the `Popup` JS engine (`popup.js`):

- `data-open` — present while the popup is open.
- `data-closed` — present while the popup is closed (initial render state).
- `data-side` — the resolved side (`top`/`right`/`bottom`/`left`); also exposed as the `--chelekom-side` CSS variable.

The engine flips `data-open`/`data-closed` on `show()`/`hide()` and keeps `aria-expanded` in sync.

## Example

```heex
<.popover id="profile-popover" side="bottom" align="end">
  <:trigger>Account</:trigger>

  <div class="chelekom-popover__panel">
    <p>Signed in as <strong>alex@example.com</strong></p>
    <a href="/settings">Settings</a>
    <button type="button">Sign out</button>
  </div>
</.popover>
```

Attributes (from the template):

- `id` (required) — root id; the popup gets `"#{id}-popup"`.
- `side` — `top` | `right` | `bottom` | `left` (default `bottom`).
- `align` — `start` | `center` | `end` (default `center`).
- `class` — extra classes appended to `chelekom-popover` on the root.
- `rest` — global attributes spread onto the root `<div>`.

Slots: `:trigger` (required, button content) and the default `inner_block` (required, popup content).

## Styling

Ships **no colors or visual styling** — it is fully headless. Style via the BEM-style classes the template emits:

- `chelekom-popover` (root)
- `chelekom-popover__trigger`
- `chelekom-popover__popup`

Drive open/closed transitions off the state attributes, e.g.:

```css
.chelekom-popover__popup[data-closed] { opacity: 0; pointer-events: none; }
.chelekom-popover__popup[data-open]   { opacity: 1; }
```

Use `data-side` (or the `--chelekom-side` CSS variable) for side-aware offsets/animations. The engine applies only minimal inline anchoring positioning, which you can override with your own CSS.
