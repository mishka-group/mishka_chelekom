# switch (headless)

An unstyled, accessible on/off toggle rendered as a `role="switch"` button, with behavior delegated to the shared `Toggle` JS engine. Implements the [WAI-ARIA APG Switch pattern](https://www.w3.org/WAI/ARIA/apg/patterns/switch/).

## Generate

```bash
mix mishka.ui.gen.headless switch
```

Generates `lib/<app>_web/components/headless/switch.ex`. Wire up the JS engine in `app.js`:

```js
import Toggle from "./toggle.js";
const Hooks = { Toggle };
```

## Anatomy

The root is a `<button type="button">` carrying `phx-hook="Toggle"` and `class="chelekom-switch"`. Parts are marked with `data-part` hooks the engine queries:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `button` | — | `chelekom-switch` | always rendered |
| input | `input` (checkbox) | `input` | `chelekom-switch__input chelekom-sr-only` | rendered only when `name` is set |
| thumb | `span` | `thumb` | `chelekom-switch__thumb` | always rendered |
| label | `span` | `label` | `chelekom-switch__label` | rendered only when `inner_block` is present |

`Toggle` queries `[data-part="input"]` to keep the hidden checkbox in sync for form submission.

## ARIA & keyboard

Roles and aria attributes (wired by the template + engine):

- **root** — `role="switch"`, `aria-checked` (`"true"`/`"false"`, mirrors the on state), and `aria-labelledby` pointing at `#{@id}-label` when a label (`inner_block`) is present.
- **input** — `aria-hidden="true"`, `tabindex="-1"` (visually hidden, present only for form posting).
- **thumb** — `aria-hidden="true"` (decorative).

Keyboard (handled by `Toggle`):

- **Enter** — toggles the switch.
- **Space** — toggles the switch.

On toggle the engine reads the element's role (`switch`), flips `aria-checked`, and (because it is a switch) toggles the `data-checked`/`data-unchecked` attributes; it also sets the hidden input's `checked` to match. Toggling is skipped if the root carries `data-disabled`.

## State

Paired-presence (Base-UI style) attributes, toggled by the `Toggle` engine on the root:

- `data-checked` — present when the switch is on.
- `data-unchecked` — present when the switch is off.

The two are always mutually exclusive, and `aria-checked` mirrors the same state. The template renders the initial `data-checked`/`data-unchecked` (and `aria-checked`) from the `checked` assign; thereafter `Toggle` re-syncs them on each Enter/Space/click.

## Example

```heex
<.switch id="notifications" name="notifications" checked={false}>
  Enable notifications
</.switch>
```

Without a form input or label:

```heex
<.switch id="dark-mode" />
```

Attrs: `id` (required), `name` (string, default `nil` — when set, renders the hidden checkbox `<input>` for form submission), `checked` (boolean, default `false`), `class`, and `rest` (global). Slot: `inner_block` (optional label content — when present, the engine-friendly `aria-labelledby` is wired and the label `<span>` is rendered).

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-switch*` classes (`chelekom-switch`, `__input`, `__thumb`, `__label`) and the `data-checked` / `data-unchecked` state attributes, e.g.:

```css
.chelekom-switch                     { /* track styles */ }
.chelekom-switch[data-checked]       { /* on track */ }
.chelekom-switch[data-unchecked]     { /* off track */ }
.chelekom-switch__thumb              { /* knob */ }
.chelekom-switch[data-checked] .chelekom-switch__thumb { /* knob, on position */ }
```

Add your own classes to the root via the `class` attr. The hidden `__input` uses `chelekom-sr-only` to stay visually hidden while remaining form-submittable.
