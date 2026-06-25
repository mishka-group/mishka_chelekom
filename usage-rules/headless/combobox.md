# combobox (headless)

An unstyled, accessible autocomplete: a text input that filters a listbox of options, with behavior delegated to the shared `HeadlessCombobox` JS engine. Implements the [WAI-ARIA APG Combobox pattern](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/).

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

The root is a `<div>` carrying `phx-hook="HeadlessCombobox"` and `class="chelekom-combobox"`. Parts are marked with `data-part` hooks the engine queries:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-combobox` | always rendered |
| input | `input[type=text]` | `input` | `chelekom-combobox__input` | always rendered (auto) |
| value | `input[type=hidden]` | `value` | — | rendered when `name` is set |
| popup | `ul` | `popup` | `chelekom-combobox__popup` | always rendered |
| item | `li` | `item` | `chelekom-combobox__item` | one per `<:option>` slot entry |

`HeadlessCombobox` queries `[data-part="input"]`, `[data-part="popup"]`, `[data-part="value"]`, and all `[data-part="item"]` inside the root. The popup's id is `#{@id}-popup` and each item id is `#{@id}-opt-#{index}`.

## ARIA & keyboard

Roles and aria attributes (wired by the template + engine):

- **input** — template renders `aria-controls="#{@id}-popup"` and `aria-expanded="false"`. On mount the engine adds `role="combobox"`, `aria-autocomplete="list"`, re-confirms `aria-controls`/`aria-expanded`, and maintains `aria-expanded` (`true`/`false`) and `aria-activedescendant` (the highlighted item's id, or removed) at runtime.
- **popup** — `role="listbox"`.
- **item** — `role="option"`, `data-value` (the option's `value`), and `aria-selected` (template renders `to_string(value == @value)`; the engine sets `true`/`false` per item on selection).

Keyboard (handled by `HeadlessCombobox` on the input):

- **Type** — filters options; non-matching items get `data-hidden` (matching is case-insensitive substring on each item's text). Also opens the popup.
- **ArrowDown** — opens the popup and moves the highlight to the next visible option (clamped at the last; starts at the first).
- **ArrowUp** — moves the highlight to the previous visible option (clamped at the first).
- **Enter** — selects the highlighted option (only when one is highlighted).
- **Escape** — closes the popup and clears the highlight.

Selecting an option (Enter or click) fills the input with the item's text, writes the item's `data-value` into the hidden `[data-part="value"]` input, marks it `aria-selected="true"`, and closes. Focusing the input opens the popup; clicking outside the root closes it.

## State

Paired-presence (Base-UI style) attributes, toggled by the `HeadlessCombobox` engine:

- `data-open` / `data-closed` — on the **popup**; mutually exclusive, mirror the open state. The template renders the initial `data-closed`; the engine toggles them on open/close.
- `data-highlighted` — on the **item** currently under the roving highlight (at most one).
- `data-hidden` — on **items** filtered out by the current query.

## Example

```heex
<.combobox id="fruit" name="fruit" value="apple" placeholder="Search a fruit…">
  <:option value="apple">Apple</:option>
  <:option value="banana">Banana</:option>
  <:option value="cherry">Cherry</:option>
</.combobox>
```

Attrs: `id` (required), `name` (hidden form input name; the hidden `value` input only renders when set), `value` (currently selected value), `placeholder`, `class`, and `rest` (global). Slot: `option` (required, one or more), each with a required `value` attr; the slot's content is the visible label. The hidden input submits the selected option's `value` with the form.

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-combobox*` classes (`chelekom-combobox`, `__input`, `__popup`, `__item`) and the `data-*` state attributes, e.g.:

```css
.chelekom-combobox__popup[data-closed]      { display: none; }
.chelekom-combobox__popup[data-open]        { /* visible styles */ }
.chelekom-combobox__item[data-hidden]       { display: none; }
.chelekom-combobox__item[data-highlighted]  { /* active option styles */ }
.chelekom-combobox__item[aria-selected="true"] { /* selected styles */ }
```

Add your own classes to the root via the `class` attr.