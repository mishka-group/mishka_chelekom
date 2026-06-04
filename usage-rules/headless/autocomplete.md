# autocomplete (headless)

An unstyled, accessible free-text input with inline filtered suggestions: markup + WAI-ARIA wiring, with behavior delegated to the shared `HeadlessCombobox` JS engine. Implements the [WAI-ARIA APG Combobox pattern](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/). Structurally identical to the headless `combobox`.

## Generate

```bash
mix mishka.ui.gen.headless autocomplete
```

Generates `lib/<app>_web/components/headless/autocomplete.ex`. Wire up the JS engine in `app.js`:

```js
import HeadlessCombobox from "./headless_combobox.js";
const Hooks = { HeadlessCombobox };
```

## Anatomy

The root is a `<div>` carrying `phx-hook="HeadlessCombobox"` and `class="chelekom-autocomplete"`. Parts are marked with `data-part` hooks the engine queries:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-autocomplete` | always rendered |
| input | `input[type=text]` | `input` | `chelekom-autocomplete__input` | always rendered |
| value | `input[type=hidden]` | `value` | — | rendered when `@name` is set |
| popup | `ul` | `popup` | `chelekom-autocomplete__popup` | always rendered |
| item | `li` | `item` | `chelekom-autocomplete__item` | one per `<:option>` slot |

`HeadlessCombobox` queries `[data-part="input"]`, `[data-part="popup"]`, `[data-part="value"]`, and all `[data-part="item"]` inside the root.

## ARIA & keyboard

Roles and aria attributes (wired by the template + engine):

- **input** — the template renders `aria-controls="#{@id}-popup"` and `aria-expanded="false"`. On mount, when the popup has an id, the engine also sets `role="combobox"`, `aria-controls`, `aria-expanded`, and `aria-autocomplete="list"`. The engine toggles `aria-expanded` (`false`/`true`) on open/close and sets `aria-activedescendant` to the highlighted option's id (removed when nothing is highlighted).
- **popup** — `role="listbox"`, anchored at `#{@id}-popup`.
- **item** — `role="option"` with `id="#{@id}-opt-<index>"`, `data-value` from the slot's `value`, and `aria-selected` (template renders `value == @value`; the engine sets it to the chosen option on select).

Keyboard (handled by `HeadlessCombobox`):

- **Type** — filters options; non-matching items get `data-hidden` (case-insensitive `textContent` substring match against the trimmed input). Also opens the popup.
- **ArrowDown** — opens the popup and moves a roving highlight to the next visible option (clamped at the last).
- **ArrowUp** — moves the highlight to the previous visible option (clamped at the first).
- **Enter** — selects the highlighted option (only when one is highlighted).
- **Escape** — closes the popup and clears the highlight.

Focusing the input opens the popup. Selecting (Enter or click) fills the input with the option's `textContent`, writes the option's `data-value` (falling back to its text) into the hidden `[data-part="value"]` input, marks it `aria-selected`, and closes. Clicking outside the root closes the popup.

## State

Paired-presence (Base-UI style) attributes, toggled by the `HeadlessCombobox` engine:

- On the **popup**: `data-open` (present when open) / `data-closed` (present when closed) — always mutually exclusive. The template renders the initial `data-closed`.
- On each **item**: `data-highlighted` (present on the roving-focus option) and `data-hidden` (present when filtered out).

There is no `open` assign; open/closed state is driven entirely by the engine in response to focus, input, and keyboard.

## Example

```heex
<.autocomplete id="fruit" name="fruit" placeholder="Search fruit...">
  <:option value="apple">Apple</:option>
  <:option value="banana">Banana</:option>
  <:option value="cherry">Cherry</:option>
  <:option value="grape">Grape</:option>
</.autocomplete>
```

Attrs: `id` (required, anchors the popup and option ids), `name` (hidden form input name; the hidden `value` input only renders when set), `value` (currently selected value), `placeholder`, `class`, and `rest` (global). Slot: `option` (required, repeatable) — each takes a required `value` attr and renders its inner content as the visible label.

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-autocomplete*` classes (`chelekom-autocomplete`, `__input`, `__popup`, `__item`) and the `data-open` / `data-closed` / `data-highlighted` / `data-hidden` state attributes, e.g.:

```css
.chelekom-autocomplete__popup[data-closed]      { display: none; }
.chelekom-autocomplete__popup[data-open]        { /* visible styles */ }
.chelekom-autocomplete__item[data-hidden]       { display: none; }
.chelekom-autocomplete__item[data-highlighted]  { /* active option */ }
```

Add your own classes to the root via the `class` attr.