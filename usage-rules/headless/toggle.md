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

There is a single part: the root **is** the `<button>` (no nested parts, no `data-part` hooks). It carries `phx-hook="Toggle"` and `class="chelekom-toggle"`:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `button` | — | `chelekom-toggle` | always rendered; `inner_block` (required) is the label/content |

The `Toggle` engine operates directly on `this.el` (the button) — it does not query any sub-parts (it only looks for an optional `[data-part="input"]`, which this toggle component does not render).

## ARIA & keyboard

Roles and aria attributes (wired by the template + engine):

- **root** (`button`) — `type="button"`, `aria-pressed` reflects the current state. The template renders the initial `aria-pressed` (`"true"`/`"false"`) from the `pressed` assign; thereafter `Toggle` flips it on each activation. (The engine picks `aria-pressed` because the root has no `role="switch"`/`"checkbox"`.)

Keyboard (handled by `Toggle`):

- **Enter** — toggles the pressed state.
- **Space** — toggles the pressed state (the engine calls `preventDefault()`).
- Clicking the button also toggles. Activation is ignored while `data-disabled` is present on the root.

## State

Paired-presence (Base-UI style) attributes, toggled by the `Toggle` engine on the root button:

- `data-on` — present when pressed.
- `data-off` — present when not pressed.

The two are always mutually exclusive, and `aria-pressed` mirrors the same state. The template renders the initial `data-on`/`data-off` from the `pressed` assign (`data-on={@pressed}`, `data-off={!@pressed}`); thereafter `Toggle` re-syncs them on each click / Enter / Space.

## Example

```heex
<.toggle id="bold" pressed={false}>
  Bold
</.toggle>
```

Attrs: `id` (string, default `nil`), `pressed` (boolean, default `false` — initial/controlled pressed state), `class` (extra classes for the root button), and `rest` (global). Slot: `inner_block` (required — the toggle label / content). The state is flipped client-side by the engine; set `pressed` to seed the initial value.

## Styling

This component ships **no** colors, spacing, or typography — only structural markup. Style it via the `chelekom-toggle` class and the `data-on` / `data-off` state attributes, e.g.:

```css
.chelekom-toggle            { /* base button styles */ }
.chelekom-toggle[data-off]  { /* unpressed styles */ }
.chelekom-toggle[data-on]   { /* pressed styles */ }
```

Add your own classes to the root via the `class` attr.
