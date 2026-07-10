# toggle (headless)

An unstyled, accessible two-state pressed button (on / off): the root element **is** a `<button>` wired to the shared `Toggle` JS engine. Implements the [WAI-ARIA APG Button (Toggle) pattern](https://www.w3.org/WAI/ARIA/apg/patterns/button/).

## Generate

```bash
mix mishka.ui.gen.headless toggle
```

Generates `lib/<app>_web/components/headless/toggle.ex`. Wire up the JS engine in `app.js`:

```js
import Toggle from "./toggle.js";
const Hooks = { Toggle };
```

## Anatomy

Single part: the root **is** the `<button>` (no nested parts, no `data-part` hooks). It carries `phx-hook="Toggle"` and `class="chelekom-toggle"`. `inner_block` (required) is the label/content.

The `Toggle` engine operates directly on `this.el` (the button) — it does not query any sub-parts (it only looks for an optional `[data-part="input"]`, which this component does not render).

## ARIA & keyboard

- **root** (`button`) — `type="button"`, `aria-pressed` reflects current state. Template renders initial `aria-pressed` (`"true"`/`"false"`) from `pressed`; thereafter `Toggle` flips it on each activation (chosen since root has no `role="switch"`/`"checkbox"`).
- **Enter** / **Space** — toggle the pressed state (`Space` calls `preventDefault()`).
- Click also toggles. Activation is ignored while `data-disabled` is present on the root.

## State

Paired-presence (Base-UI style) attributes, toggled by `Toggle` on the root button:

- `data-on` — present when pressed.
- `data-off` — present when not pressed.

Mutually exclusive; `aria-pressed` mirrors the same state. Template renders initial `data-on`/`data-off` from `pressed` (`data-on={@pressed}`, `data-off={!@pressed}`); `Toggle` re-syncs them on each click / Enter / Space.

## Example

```heex
<.toggle id="bold" pressed={false}>
  Bold
</.toggle>
```

Attrs: `id` (string, default `nil`), `pressed` (boolean, default `false` — initial/controlled pressed state), `class` (extra classes for root button), `rest` (global). Slot: `inner_block` (required). State flips client-side; `pressed` only seeds the initial value.

## Styling

Ships **no** colors, spacing, or typography — structural markup only. Style via `chelekom-toggle` and the `data-on` / `data-off` state attributes:

```css
.chelekom-toggle            { /* base button styles */ }
.chelekom-toggle[data-off]  { /* unpressed styles */ }
.chelekom-toggle[data-on]   { /* pressed styles */ }
```

Add custom classes to the root via `class`.
