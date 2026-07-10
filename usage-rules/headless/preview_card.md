# preview_card (headless)

An unstyled, accessible hover card (preview card): a trigger that reveals a floating, non-modal preview on hover/focus, delegated to the shared `Popup` JS engine in hover mode. Follows the **Hover Card** convention (no formal WAI-ARIA APG pattern); trigger exposes `aria-expanded` + `aria-controls`, popup uses `role="dialog"`.

## Generate

```bash
mix mishka.ui.gen.headless preview_card
```

Generates `lib/<app>_web/components/headless/preview_card.ex`. Wire up the JS engine in `app.js`:

```js
import Popup from "./popup.js";
const Hooks = { Popup };
```

## Anatomy

Root `<div>` carries `phx-hook="Popup"`, `data-trigger="hover"`, `data-side={@side}`, `class="chelekom-preview-card"`. `Popup` queries `[data-part="trigger"]`/`[data-part="popup"]` inside the root. Popup id is `#{@id}-popup`.

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-preview-card` | always rendered |
| trigger | `span` | `trigger` | `chelekom-preview-card__trigger` | `<:trigger>` slot (required) |
| popup | `div` | `popup` | `chelekom-preview-card__popup` | `inner_block` (required) |

## ARIA & keyboard

- **trigger** — `aria-controls` points at `#{@id}-popup`; `aria-expanded` rendered `"false"`, toggled `"true"`/`"false"` by the engine as the preview opens/closes.
- **popup** — `role="dialog"`, **non-modal**: focus is never trapped, no `aria-modal`.
- **Pointer enter / focus in** (`mouseenter`/`focusin` on root) — opens.
- **Pointer leave / focus out** (`mouseleave`/`focusout` on root) — closes.
- **Escape** — closes and returns focus to trigger.
- Hover mode does **not** autofocus content on open and does not trap Tab focus. Outside-click also closes while open (engine listens on `document` only while open). Placement follows `data-side` (default `top`).

## State

Paired-presence (Base-UI style) attrs on the popup, toggled by the `Popup` engine, mutually exclusive:

- `data-open` — preview is open.
- `data-closed` — preview is closed (template renders this initially).

On open the engine also sets `data-side` on the popup and the `--chelekom-side` CSS custom property to the resolved side. `aria-expanded` on the trigger mirrors the open state.

## Example

```heex
<.preview_card id="user-card" side="top">
  <:trigger>
    <a href="/users/ada">@ada</a>
  </:trigger>

  <div class="card">
    <img src="/avatars/ada.png" alt="" />
    <h3>Ada Lovelace</h3>
    <p>First programmer. Hover to preview.</p>
  </div>
</.preview_card>
```

Attrs: `id` (required), `side` (`top` | `right` | `bottom` | `left`, default `top`), `class`, `rest` (global). Slots: `trigger` (required, hovered/focused element), `inner_block` (required, preview content).

## Styling

Ships **no** colors or spacing — structural markup only. Style via `chelekom-preview-card*` classes (`chelekom-preview-card`, `__trigger`, `__popup`) and `data-open`/`data-closed`/`data-side` state attrs:

```css
.chelekom-preview-card__popup            { position: absolute; }
.chelekom-preview-card__popup[data-closed] { display: none; }
.chelekom-preview-card__popup[data-open]   { /* visible styles */ }
.chelekom-preview-card__popup[data-side="top"]    { /* per-side offset */ }
```

`--chelekom-side` CSS variable exposes the resolved side for transitions/arrows. Add custom classes to the root via `class`.
