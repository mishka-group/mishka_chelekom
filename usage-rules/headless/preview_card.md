# preview_card (headless)

An unstyled, accessible hover card (preview card): a trigger that reveals a floating, non-modal preview on hover/focus, with behavior delegated to the shared `Popup` JS engine in hover mode. Follows the **Hover Card** convention (no formal WAI-ARIA APG pattern); the trigger exposes `aria-expanded` + `aria-controls` and the popup uses `role="dialog"`.

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

The root is a `<div>` carrying `phx-hook="Popup"`, `data-trigger="hover"`, `data-side={@side}`, and `class="chelekom-preview-card"`. Parts are marked with `data-part` hooks the engine queries:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-preview-card` | always rendered |
| trigger | `span` | `trigger` | `chelekom-preview-card__trigger` | `<:trigger>` slot (required) |
| popup | `div` | `popup` | `chelekom-preview-card__popup` | `inner_block` (required) |

`Popup` queries `[data-part="trigger"]` and `[data-part="popup"]` inside the root. The popup id is `#{@id}-popup`.

## ARIA & keyboard

Roles and aria attributes (wired by the template + engine):

- **trigger** — `aria-controls` points at the popup id (`#{@id}-popup`); `aria-expanded` is rendered `"false"` and toggled `"true"`/`"false"` by the engine as the preview opens/closes.
- **popup** — `role="dialog"`. It is **non-modal**: focus is never trapped and there is no `aria-modal`.

Interactions (handled by `Popup` in hover mode):

- **Pointer enter / focus in** (`mouseenter`, `focusin` on the root) — opens the preview.
- **Pointer leave / focus out** (`mouseleave`, `focusout` on the root) — closes the preview.
- **Escape** — closes the preview and returns focus to the trigger.

In hover mode the engine does **not** autofocus content on open and does not trap Tab focus. Outside-click also closes while open (engine listens on `document` only while open). Placement follows `data-side` (default `top`).

## State

Paired-presence (Base-UI style) attributes on the popup, toggled by the `Popup` engine:

- `data-open` — present when the preview is open.
- `data-closed` — present when the preview is closed (the template renders the initial `data-closed`).

The two are mutually exclusive. On open the engine also sets `data-side` on the popup and the `--chelekom-side` CSS custom property to the resolved side. On the trigger, `aria-expanded` mirrors the open state.

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

Attrs: `id` (required), `side` (one of `top` | `right` | `bottom` | `left`, default `top`), `class`, and `rest` (global). Slots: `trigger` (required, the hovered/focused element) and `inner_block` (required, the preview content).

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-preview-card*` classes (`chelekom-preview-card`, `__trigger`, `__popup`) and the `data-open` / `data-closed` / `data-side` state attributes, e.g.:

```css
.chelekom-preview-card__popup            { position: absolute; }
.chelekom-preview-card__popup[data-closed] { display: none; }
.chelekom-preview-card__popup[data-open]   { /* visible styles */ }
.chelekom-preview-card__popup[data-side="top"]    { /* per-side offset */ }
```

The engine exposes the resolved side via the `--chelekom-side` CSS variable for transitions/arrows. Add your own classes to the root via the `class` attr.
