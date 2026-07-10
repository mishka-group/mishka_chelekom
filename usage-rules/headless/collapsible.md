# collapsible (headless)

An unstyled, accessible disclosure: a trigger button that shows/hides one region, behavior delegated to the shared `Disclosure` JS engine. Implements the [WAI-ARIA APG Disclosure pattern](https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/).

## Generate

```bash
mix mishka.ui.gen.headless collapsible
```

Generates `lib/<app>_web/components/headless/collapsible.ex`. Wire up the JS engine in `app.js`:

```js
import Disclosure from "./disclosure.js";
const Hooks = { Disclosure };
```

## Anatomy

Root is a `<div>` with `phx-hook="Disclosure"` and `class="chelekom-collapsible"`. `Disclosure` queries `[data-part="trigger"]` and follows each trigger's `aria-controls` to its panel.

| Part | Element | `data-part` | Class | Source | id |
|------|---------|-------------|-------|--------|----|
| root | `div` | — | `chelekom-collapsible` | always rendered | — |
| trigger | `button` | `trigger` | `chelekom-collapsible__trigger` | `<:trigger>` slot (required) | `#{@id}-trigger` |
| panel | `div` | `panel` | `chelekom-collapsible__panel` | `inner_block` (required) | `#{@id}-panel` |

## ARIA & keyboard

- **trigger** — `aria-controls` points at the panel id; `aria-expanded` renders from the `open` assign and is re-synced by the engine on toggle.
- **panel** — `role="region"`, `aria-labelledby` pointing at the trigger id.
- **Enter / Space** — toggles open/closed (native button behavior via the engine's click listener).
- On mount, the engine reads each panel's initial `data-open` and sets the trigger's `aria-expanded` to match.

## State

Paired-presence (Base-UI style) attributes on the panel, mutually exclusive, toggled by the `Disclosure` engine on click:

- `data-open` — present when open.
- `data-closed` — present when closed.

`aria-expanded` on the trigger mirrors the open state. The template renders the initial `data-open`/`data-closed` from the `open` assign.

## Example

```heex
<.collapsible id="details" open={false}>
  <:trigger>Show details</:trigger>

  <p>This content is revealed when the trigger is clicked.</p>
</.collapsible>
```

Attrs: `id` (required), `open` (boolean, default `false`), `class`, `rest` (global). Slots: `trigger` (required, toggle button label), `inner_block` (required, collapsible content).

## Styling

Ships **no** colors or spacing — structural markup only. Style via the `chelekom-collapsible*` classes (`chelekom-collapsible`, `__trigger`, `__panel`) and the `data-open` / `data-closed` state attributes:

```css
.chelekom-collapsible__panel[data-closed] { display: none; }
.chelekom-collapsible__panel[data-open]   { /* visible styles */ }
```
