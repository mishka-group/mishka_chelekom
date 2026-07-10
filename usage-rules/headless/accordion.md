# accordion (headless)

A set of stacked disclosure items where each header toggles a content panel. Implements the WAI-ARIA APG [Accordion](https://www.w3.org/WAI/ARIA/apg/patterns/accordion/) pattern. Ships behavior and structure only — no colors or visual styling.

## Generate

```
mix mishka.ui.gen.headless accordion
```

Generates `lib/<app>_web/components/headless/accordion.ex` and the shared JS engine `disclosure.js` (hook `Disclosure`). Register the hook in your `app.js`:

```js
import Disclosure from "./disclosure.js";
// hooks: { Disclosure }
```

## Anatomy

Root `<div>` carries `phx-hook="Disclosure"`, `class="chelekom-accordion"`, plus `data-single` and `data-collapsible`.

| Part | Element | `data-part` | Class |
| --- | --- | --- | --- |
| item | `div` | `item` | `chelekom-accordion__item` |
| heading | `h3` | — | `chelekom-accordion__heading` |
| trigger | `button` | `trigger` | `chelekom-accordion__trigger` |
| panel | `div` | `panel` | `chelekom-accordion__panel` |

The engine pairs each `[data-part="trigger"]` to its `[data-part="panel"]` via the trigger's `aria-controls` (matched to the panel `id`).

## ARIA & keyboard

- **trigger** (`button`, wrapped in `<h3>`): `aria-expanded` (`"true"`/`"false"`), `aria-controls` → panel id.
- **panel** (`div`): `role="region"`, `aria-labelledby` → trigger id.
- **Keyboard:** Enter / Space on a focused trigger toggles its panel (native button activation; engine listens for `click`).

## State

The `Disclosure` engine toggles mutually-exclusive presence attributes on the **panel** (always exactly one present) and keeps the trigger's `aria-expanded` in sync:

- `data-open` — panel is open.
- `data-closed` — panel is closed.

Root flags read by the engine:

- `data-single` (from `single` attr, default `true`) — opening one item closes the others.
- `data-collapsible` (from `collapsible` attr, default `true`) — when `"false"`, the open item cannot be closed by clicking its own trigger.

Initial open state comes from the per-item `:open` attr, which seeds `aria-expanded`, `data-open`, and `data-closed` at render time.

## Example

```heex
<.accordion id="faq" single collapsible>
  <:item title="What is Mishka Chelekom?">
    A headless component library for Phoenix.
  </:item>
  <:item title="Is it styled?" open>
    No — you bring your own CSS via the chelekom-accordion* classes.
  </:item>
  <:item title="Can multiple be open?">
    Set <code>single={false}</code> to allow it.
  </:item>
</.accordion>
```

Attrs: `id` (required), `single` (boolean, default `true`), `collapsible` (boolean, default `true`), `class`, `rest` (global). Slot: `:item` (required) with `title` (required string), optional `open` (boolean); inner content is the panel body.

## Styling

No colors or theme are shipped. Style the structural classes — `chelekom-accordion`, `chelekom-accordion__item`, `chelekom-accordion__heading`, `chelekom-accordion__trigger`, `chelekom-accordion__panel` — and key panel visibility/animation off the state attributes:

```css
.chelekom-accordion__panel[data-closed] { display: none; }
.chelekom-accordion__panel[data-open]   { display: block; }
.chelekom-accordion__trigger[aria-expanded="true"] { /* expanded styles */ }
```
