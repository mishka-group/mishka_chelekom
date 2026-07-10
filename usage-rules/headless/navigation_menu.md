# navigation_menu (headless)

An unstyled, accessible site navigation: a `<nav>` of items where each item is either a plain link or a `Popup`-driven dropdown panel. Open/close, outside-click and Escape dismissal, and `aria-expanded` wiring are delegated to the shared `Popup` JS engine. Implements the [WAI-ARIA APG Disclosure pattern](https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/).

## Generate

```bash
mix mishka.ui.gen.headless navigation_menu
```

Generates `lib/<app>_web/components/headless/navigation_menu.ex`. Wire up the JS engine in `app.js`:

```js
import Popup from "./popup.js";
const Hooks = { Popup };
```

## Anatomy

Each `<:item>` renders one of two shapes depending on whether it has inner content (a panel). Dropdown items each get their own `phx-hook="Popup"` root so the engine resolves the correct trigger/popup pair; parts are marked with `data-part` for the engine to query.

| Part | Element | `data-part` | Class | Rendered when |
|------|---------|-------------|-------|-------|
| root | `nav` | — | `chelekom-navigation_menu` | always |
| list | `ul` | — | `chelekom-navigation_menu__list` | always |
| item | `li` | — | `chelekom-navigation_menu__item` | per `<:item>` |
| link | `a` | `link` | `chelekom-navigation_menu__link` | `<:item>` with **no** inner content |
| popup-root | `div` | — | `chelekom-navigation_menu__popup-root` | `<:item>` **with** inner content (`phx-hook="Popup"`, `data-side`) |
| trigger | `button` | `trigger` | `chelekom-navigation_menu__trigger` | dropdown item |
| popup | `div` | `popup` | `chelekom-navigation_menu__panel` | dropdown item (the panel body) |

`Popup` queries `[data-part="trigger"]` and `[data-part="popup"]` within each popup-root. Popup id: `#{@id}-item-#{i}-popup`. Popup-root id: `#{@id}-item-#{i}`.

## ARIA & keyboard

- **trigger** — template sets `aria-haspopup="menu"` and `aria-controls` (pointing at the popup id); engine sets `aria-expanded` (`false`/`true`).
- **popup** — `role="menu"`, `aria-label={item.label}`, initial `data-closed`.
- **Enter/Space** on a focused trigger toggles its panel; **Escape** closes the open panel and returns focus to the trigger.
- Clicking a trigger toggles its panel; clicking outside the popup-root closes it. On open, the engine focuses the first `item`/`a`/`button` inside the panel.

## State

Paired-presence (Base-UI style) attributes, mutually exclusive, toggled by `Popup` on the **popup** element:

- `data-open` — panel is open.
- `data-closed` — panel is closed.

Template renders initial `data-closed`; on `show()` the engine flips to `data-open` (and sets `data-side` plus the `--chelekom-side` CSS var), on `hide()` flips back. Trigger's `aria-expanded` mirrors the open state.

## Example

```heex
<.navigation_menu id="main-nav" side="bottom">
  <:item label="Home" href="/" />

  <:item label="Products">
    <ul role="none">
      <li><a role="menuitem" href="/products/web">Web</a></li>
      <li><a role="menuitem" href="/products/mobile">Mobile</a></li>
    </ul>
  </:item>

  <:item label="Docs" href="/docs" />
</.navigation_menu>
```

**Attrs:** `id` (required, anchors aria relationships), `side` (`"top" | "right" | "bottom" | "left"`, default `"bottom"`), `class`, `rest` (global).
**Slot:** `item` (required, repeatable) — attrs `label` (required), `href`. No inner block → plain link (`href` or `"#"`); with inner content → dropdown whose panel is the slot body.

## Styling

Ships **no** colors or spacing — structural markup only. Style via the `chelekom-navigation_menu*` classes (`chelekom-navigation_menu`, `__list`, `__item`, `__link`, `__popup-root`, `__trigger`, `__panel`) and the `data-open`/`data-closed` state attributes:

```css
.chelekom-navigation_menu__panel[data-closed] { display: none; }
.chelekom-navigation_menu__panel[data-open]   { /* visible styles */ }
```

The engine sets `data-side` and the `--chelekom-side` CSS var on the open panel for side-aware positioning. Add custom classes to the root via `class`.
