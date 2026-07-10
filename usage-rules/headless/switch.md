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

Root is a `<button type="button">` with `phx-hook="Toggle"` and `class="chelekom-switch"`. Parts (queried via `data-part`):

| Part | Element | `data-part` | Class | Rendered when |
|------|---------|-------------|-------|----------------|
| root | `button` | — | `chelekom-switch` | always |
| input | `input` (checkbox) | `input` | `chelekom-switch__input chelekom-sr-only` | `name` is set |
| thumb | `span` | `thumb` | `chelekom-switch__thumb` | always |
| label | `span` | `label` | `chelekom-switch__label` | `inner_block` present |

`Toggle` queries `[data-part="input"]` to keep the hidden checkbox in sync for form submission.

## ARIA & keyboard

- **root** — `role="switch"`, `aria-checked` (`"true"`/`"false"`, mirrors on state), `aria-labelledby="#{@id}-label"` when a label (`inner_block`) is present.
- **input** — `aria-hidden="true"`, `tabindex="-1"` (visually hidden, present only for form posting).
- **thumb** — `aria-hidden="true"` (decorative).
- **Enter** / **Space** — toggle the switch (handled by `Toggle`).

On toggle, `Toggle` flips `aria-checked` and (since role is `switch`) the `data-checked`/`data-unchecked` attributes, and syncs the hidden input's `checked`. Toggling is skipped if the root carries `data-disabled`.

## State

`Toggle` maintains mutually-exclusive, paired-presence attributes on the root, mirrored by `aria-checked`:

- `data-checked` — present when on.
- `data-unchecked` — present when off.

The template renders the initial state from the `checked` assign; `Toggle` re-syncs on each Enter/Space/click.

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

**Attrs**: `id` (required), `name` (string, default `nil` — when set, renders the hidden checkbox `<input>` for form submission), `checked` (boolean, default `false`), `class`, `rest` (global).
**Slot**: `inner_block` (optional label content — when present, `aria-labelledby` is wired and the label `<span>` is rendered).

## Styling

Ships **no** colors or spacing — structural markup only. Style via the `chelekom-switch*` classes (`chelekom-switch`, `__input`, `__thumb`, `__label`) and the `data-checked`/`data-unchecked` state attributes:

```css
.chelekom-switch                     { /* track styles */ }
.chelekom-switch[data-checked]       { /* on track */ }
.chelekom-switch[data-unchecked]     { /* off track */ }
.chelekom-switch__thumb              { /* knob */ }
.chelekom-switch[data-checked] .chelekom-switch__thumb { /* knob, on position */ }
```

Add your own classes to the root via `class`. The hidden `__input` uses `chelekom-sr-only` to stay visually hidden while remaining form-submittable.
