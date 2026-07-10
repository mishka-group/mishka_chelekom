# autocomplete (headless)

Unstyled, accessible free-text input with inline filtered suggestions: markup + WAI-ARIA wiring, behavior delegated to the shared `HeadlessCombobox` JS engine. Implements the [WAI-ARIA APG Combobox pattern](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/). Structurally identical to the headless `combobox`.

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

Root is a `<div>` with `phx-hook="HeadlessCombobox"` and `class="chelekom-autocomplete"`. `HeadlessCombobox` queries `[data-part="input"]`, `[data-part="popup"]`, `[data-part="value"]`, and all `[data-part="item"]` inside the root.

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-autocomplete` | always rendered |
| input | `input[type=text]` | `input` | `chelekom-autocomplete__input` | always rendered |
| value | `input[type=hidden]` | `value` | — | rendered when `@name` is set |
| popup | `ul` | `popup` | `chelekom-autocomplete__popup` | always rendered |
| item | `li` | `item` | `chelekom-autocomplete__item` | one per `<:option>` slot |

## ARIA & keyboard

- **input** — template renders `aria-controls="#{@id}-popup"` and `aria-expanded="false"`. On mount (when popup has an id), engine also sets `role="combobox"`, `aria-controls`, `aria-expanded`, `aria-autocomplete="list"`. Engine toggles `aria-expanded` (`false`/`true`) on open/close and sets `aria-activedescendant` to the highlighted option's id (removed when nothing is highlighted).
- **popup** — `role="listbox"`, anchored at `#{@id}-popup`.
- **item** — `role="option"`, `id="#{@id}-opt-<index>"`, `data-value` from the slot's `value`, and `aria-selected` (template renders `value == @value`; engine sets it to the chosen option on select).

Keyboard (handled by `HeadlessCombobox`):

| Key | Behavior |
|-----|----------|
| Type | Filters options (case-insensitive `textContent` substring match against trimmed input); non-matching items get `data-hidden`. Also opens the popup. |
| ArrowDown | Opens the popup and moves the roving highlight to the next visible option (clamped at the last). |
| ArrowUp | Moves the highlight to the previous visible option (clamped at the first). |
| Enter | Selects the highlighted option (only when one is highlighted). |
| Escape | Closes the popup and clears the highlight. |

Focusing the input opens the popup. Selecting (Enter or click) fills the input with the option's `textContent`, writes the option's `data-value` (falling back to its text) into the hidden `[data-part="value"]` input, marks it `aria-selected`, and closes. Clicking outside the root closes the popup.

## State

Paired-presence (Base-UI style) attributes, toggled by the `HeadlessCombobox` engine:

- **popup**: `data-open` (present when open) / `data-closed` (present when closed) — mutually exclusive; template renders initial `data-closed`.
- **item**: `data-highlighted` (present on the roving-focus option), `data-hidden` (present when filtered out).

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

Attrs: `id` (required, anchors popup/option ids), `name` (hidden form input name; hidden `value` input only renders when set), `value` (currently selected value), `placeholder`, `class`, `rest` (global). Slot: `option` (required, repeatable) — each takes a required `value` attr and renders its inner content as the visible label.

## Styling

Ships **no** colors or spacing — only structural markup. Style via the `chelekom-autocomplete*` classes (`chelekom-autocomplete`, `__input`, `__popup`, `__item`) and the `data-open` / `data-closed` / `data-highlighted` / `data-hidden` state attributes:

```css
.chelekom-autocomplete__popup[data-closed]      { display: none; }
.chelekom-autocomplete__popup[data-open]        { /* visible styles */ }
.chelekom-autocomplete__item[data-hidden]       { display: none; }
.chelekom-autocomplete__item[data-highlighted]  { /* active option */ }
```

Add your own classes to the root via the `class` attr.
