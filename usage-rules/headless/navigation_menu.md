# navigation_menu (headless)

An unstyled, accessible site navigation: a `<nav>` of items where each item is either a plain link or a `Popup`-driven dropdown panel. Behavior (open/close, outside-click and Escape dismissal, `aria-expanded` wiring) is delegated to the shared `Popup` JS engine. Implements the [WAI-ARIA APG Disclosure pattern](https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/).

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

The root is a `<nav>` with `class="chelekom-navigation_menu"`, holding a `<ul>` (`__list`) of `<li>` items (`__item`). Each `<:item>` renders one of two shapes depending on whether it has inner content (a panel). Dropdown items each get their own `phx-hook="Popup"` root so the engine resolves the correct trigger/popup pair; parts are marked with `data-part` hooks the engine queries:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `nav` | — | `chelekom-navigation_menu` | always rendered |
| list | `ul` | — | `chelekom-navigation_menu__list` | always rendered |
| item | `li` | — | `chelekom-navigation_menu__item` | per `<:item>` |
| link | `a` | `link` | `chelekom-navigation_menu__link` | `<:item>` with **no** inner content |
| popup-root | `div` | — | `chelekom-navigation_menu__popup-root` | `<:item>` **with** inner content (`phx-hook="Popup"`, `data-side`) |
| trigger | `button` | `trigger` | `chelekom-navigation_menu__trigger` | dropdown item |
| popup | `div` | `popup` | `chelekom-navigation_menu__panel` | dropdown item (the panel body) |

`Popup` queries `[data-part="trigger"]` and `[data-part="popup"]` within each popup-root. The popup id is `#{@id}-item-#{i}-popup` and the popup-root id is `#{@id}-item-#{i}`.

## ARIA & keyboard

Roles and aria attributes (wired by the template + engine):

- **trigger** — template sets `aria-haspopup="menu"` and `aria-controls` (pointing at the popup id); the engine sets `aria-expanded` (toggled `false`/`true`).
- **popup** — `role="menu"`, `aria-label={item.label}`, and initial `data-closed`.

Keyboard (handled by `Popup`):

- **Enter/Space** — activates the focused trigger button, toggling its panel.
- **Escape** — closes the open panel and returns focus to the trigger.

Clicking a trigger toggles its panel; clicking outside the popup-root closes it. On open, the engine focuses the first item, `a`, or `button` inside the panel.

## State

Paired-presence (Base-UI style) attributes, toggled by the `Popup` engine on the **popup** element:

- `data-open` — present when the panel is open.
- `data-closed` — present when the panel is closed.

The two are mutually exclusive. The template renders the initial `data-closed`; on `show()` the engine flips to `data-open` (and sets `data-side` plus the `--chelekom-side` CSS var), on `hide()` it flips back. The trigger's `aria-expanded` mirrors the open state.

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

Attrs: `id` (required, anchors aria relationships), `side` (`"top" | "right" | "bottom" | "left"`, default `"bottom"`), `class`, and `rest` (global). Slot: `item` (required, repeatable) with attrs `label` (required) and `href`. An `<:item>` with no inner block renders a plain link (`href` or `"#"`); an `<:item>` with inner content renders a dropdown whose panel is the slot body.

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-navigation_menu*` classes (`chelekom-navigation_menu`, `__list`, `__item`, `__link`, `__popup-root`, `__trigger`, `__panel`) and the `data-open` / `data-closed` state attributes, e.g.:

```css
.chelekom-navigation_menu__panel[data-closed] { display: none; }
.chelekom-navigation_menu__panel[data-open]   { /* visible styles */ }
```

The engine sets `data-side` and the `--chelekom-side` CSS var on the open panel for side-aware positioning. Add your own classes to the root via the `class` attr.
