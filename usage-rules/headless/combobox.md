# combobox (headless)

An unstyled, accessible autocomplete: a text input that filters a listbox of options, behavior delegated to the shared `HeadlessCombobox` JS engine. Implements the [WAI-ARIA APG Combobox pattern](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/).

## Generate

```bash
mix mishka.ui.gen.headless combobox
```

Generates `lib/<app>_web/components/headless/combobox.ex`. Wire up the JS engine in `app.js`:

```js
import HeadlessCombobox from "./headless_combobox.js";
const Hooks = { HeadlessCombobox };
```

## Anatomy

Root is a `<div phx-hook="HeadlessCombobox" class="chelekom-combobox">`. `HeadlessCombobox` queries `[data-part="input"]`, `[data-part="popup"]`, `[data-part="value"]`, and all `[data-part="item"]` inside the root. Popup id is `#{@id}-popup`; each item id is `#{@id}-opt-#{index}`.

| Part | Element | `data-part` | Class | Rendered |
|------|---------|-------------|-------|----------|
| root | `div` | — | `chelekom-combobox` | always |
| input | `input[type=text]` | `input` | `chelekom-combobox__input` | always (auto) |
| value | `input[type=hidden]` | `value` | — | when `name` is set |
| popup | `ul` | `popup` | `chelekom-combobox__popup` | always |
| item | `li` | `item` | `chelekom-combobox__item` | one per `<:option>` slot entry |

## ARIA & keyboard

- **input** — template renders `aria-controls="#{@id}-popup"`, `aria-expanded="false"`. On mount the engine adds `role="combobox"`, `aria-autocomplete="list"`, re-confirms `aria-controls`/`aria-expanded`, and maintains `aria-expanded` (`true`/`false`) and `aria-activedescendant` (highlighted item's id, or removed) at runtime.
- **popup** — `role="listbox"`.
- **item** — `role="option"`, `data-value` (the option's `value`), `aria-selected` (template renders `to_string(value == @value)`; engine sets `true`/`false` per item on selection).

Keyboard (on the input):

| Key | Behavior |
|-----|----------|
| Type | Filters options (case-insensitive substring per item's text); non-matches get `data-hidden`; opens popup |
| ArrowDown | Opens popup; highlight → next visible option (clamped at last; starts at first) |
| ArrowUp | Highlight → previous visible option (clamped at first) |
| Enter | Selects the highlighted option (only if one is highlighted) |
| Escape | Closes popup, clears highlight |

Selecting (Enter or click) fills the input with the item's text, writes `data-value` into the hidden `[data-part="value"]` input, marks the item `aria-selected="true"`, and closes the popup. Focusing the input opens the popup; clicking outside the root closes it.

## State

Paired-presence (Base-UI style) attributes, toggled by the engine:

- `data-open` / `data-closed` — on the **popup**; mutually exclusive. Template renders initial `data-closed`; engine toggles on open/close.
- `data-highlighted` — on the **item** under the roving highlight (at most one).
- `data-hidden` — on **items** filtered out by the current query.

## Example

```heex
<.combobox id="fruit" name="fruit" value="apple" placeholder="Search a fruit…">
  <:option value="apple">Apple</:option>
  <:option value="banana">Banana</:option>
  <:option value="cherry">Cherry</:option>
</.combobox>
```

Attrs: `id` (required), `name` (hidden form input name; hidden `value` input only renders when set), `value` (currently selected value), `placeholder`, `class`, `rest` (global). Slot: `option` (required, one or more), each with a required `value` attr; slot content is the visible label. The hidden input submits the selected option's `value` with the form.

## Styling

Ships **no** colors or spacing — structural markup only. Style via `chelekom-combobox*` classes (`chelekom-combobox`, `__input`, `__popup`, `__item`) and `data-*` state attributes:

```css
.chelekom-combobox__popup[data-closed]      { display: none; }
.chelekom-combobox__popup[data-open]        { /* visible styles */ }
.chelekom-combobox__item[data-hidden]       { display: none; }
.chelekom-combobox__item[data-highlighted]  { /* active option styles */ }
.chelekom-combobox__item[aria-selected="true"] { /* selected styles */ }
```

Add custom classes to the root via `class`.
