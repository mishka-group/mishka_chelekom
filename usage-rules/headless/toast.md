# toast (headless)

An unstyled, accessible `aria-live` region that announces transient messages: markup + WAI-ARIA wiring + auto-dismiss, with behavior delegated to the shared `ToastRegion` JS engine. Implements the [WAI-ARIA APG Alert pattern](https://www.w3.org/WAI/ARIA/apg/patterns/alert/).

## Generate

```bash
mix mishka.ui.gen.headless toast
```

Generates `lib/<app>_web/components/headless/toast.ex`. Wire up the JS engine in `app.js`:

```js
import ToastRegion from "./toast_region.js";
const Hooks = { ToastRegion };
```

## Anatomy

Root `<div>` carries `phx-hook="ToastRegion"` and `class="chelekom-toast"`. Each toast comes from a `<:toast>` slot entry; parts are marked with `data-part` hooks the engine queries:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-toast` | always rendered (live region) |
| toast | `div` | `toast` | `chelekom-toast__toast` | one per `<:toast>` slot entry |
| dismiss | `button` | `dismiss` | `chelekom-toast__dismiss` | always rendered inside each toast |

`ToastRegion` queries `[data-part="toast"]` within the root and binds each `[data-part="dismiss"]` inside it.

## ARIA & keyboard

- **root** — `aria-live="polite"`, `aria-atomic="false"` (new toasts announced without re-reading the whole region).
- **toast** — `role="status"` (engine also sets it as a fallback if missing).
- **dismiss** — `aria-label="Dismiss"`.
- **Keyboard** — none required; the live region announces automatically. Dismiss is a native `<button>` (focusable, Enter/Space activates).

## State

Paired-presence (Base-UI style) attrs on each `[data-part="toast"]`, toggled by `ToastRegion`:

- `data-open` — present while showing (rendered initially by the template).
- `data-closed` — present after dismissal.

On dismissal (manual click, or auto after `data-duration` ms — default `5000`; `0` disables), the engine removes `data-open`, sets `data-closed`, then removes the node ~200ms later so CSS can animate the exit. Toasts streamed in by LiveView are re-scanned in `updated()`.

## Example

```heex
<.toast id="notifications">
  <:toast>
    Profile saved.
  </:toast>

  <:toast duration={0}>
    Upload failed — this toast won't auto-dismiss.
  </:toast>
</.toast>
```

Attrs: `id` (required, anchors the live region), `class`, `rest` (global). Slot `toast` (repeatable), each accepting an optional `duration` integer (auto-dismiss delay in ms; default `5000`, `0` disables). Each toast renders its slot content followed by a `×` dismiss button. To drive toasts from the server, render `<:toast>` entries conditionally (e.g. from a stream or assign) and let `ToastRegion` pick them up.

## Styling

Ships **no** colors or spacing — structural markup only. Style via the `chelekom-toast*` classes (`chelekom-toast`, `__toast`, `__dismiss`) and the `data-open` / `data-closed` state attrs:

```css
.chelekom-toast__toast[data-open]   { /* enter / visible styles */ }
.chelekom-toast__toast[data-closed] { opacity: 0; /* exit animation */ }
```

Add your own classes to the root via the `class` attr.
