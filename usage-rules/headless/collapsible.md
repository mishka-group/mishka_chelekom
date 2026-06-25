# collapsible (headless)

An unstyled, accessible disclosure: a trigger button that shows/hides one region, with behavior delegated to the shared `Disclosure` JS engine. Implements the [WAI-ARIA APG Disclosure pattern](https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/).

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

The root is a `<div>` carrying `phx-hook="Disclosure"` and `class="chelekom-collapsible"`. Parts are marked with `data-part` hooks the engine queries:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-collapsible` | always rendered |
| trigger | `button` | `trigger` | `chelekom-collapsible__trigger` | `<:trigger>` slot (required) |
| panel | `div` | `panel` | `chelekom-collapsible__panel` | `inner_block` (required) |

The trigger id is `#{@id}-trigger`; the panel id is `#{@id}-panel`. `Disclosure` queries `[data-part="trigger"]` and follows each trigger's `aria-controls` to its panel.

## ARIA & keyboard

Roles and aria attributes (wired by the template + engine):

- **trigger** — `aria-controls` points at the panel id (`#{@id}-panel`); `aria-expanded` is rendered from the `open` assign and re-synced by the engine on toggle.
- **panel** — `role="region"`, `aria-labelledby` pointing at the trigger id (`#{@id}-trigger`).

Keyboard (native button behavior, handled via the engine's click listener):

- **Enter / Space** — toggles the panel open/closed.

The engine reads each panel's initial `data-open` on mount and sets the trigger's `aria-expanded` to match.

## State

Paired-presence (Base-UI style) attributes on the panel, toggled by the `Disclosure` engine:

- `data-open` — present when the panel is open.
- `data-closed` — present when the panel is closed.

The two are always mutually exclusive. On the trigger, `aria-expanded` mirrors the open state. The template renders the initial `data-open`/`data-closed` from the `open` assign; thereafter the `Disclosure` engine toggles them on click.

## Example

```heex
<.collapsible id="details" open={false}>
  <:trigger>Show details</:trigger>

  <p>This content is revealed when the trigger is clicked.</p>
</.collapsible>
```

Attrs: `id` (required), `open` (boolean, default `false`), `class`, and `rest` (global). Slots: `trigger` (required, the toggle button label), `inner_block` (required, the collapsible content). Add your own classes to the root via the `class` attr.

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-collapsible*` classes (`chelekom-collapsible`, `__trigger`, `__panel`) and the `data-open` / `data-closed` state attributes, e.g.:

```css
.chelekom-collapsible__panel[data-closed] { display: none; }
.chelekom-collapsible__panel[data-open]   { /* visible styles */ }
```
