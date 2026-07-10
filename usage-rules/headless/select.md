# select (headless)

A button that opens a single-select option list (listbox), wiring open/close, keyboard navigation, ARIA and a hidden form input. Follows the WAI-ARIA APG **Combobox / Listbox** pattern: https://www.w3.org/WAI/ARIA/apg/patterns/combobox/

## Generate

```bash
mix mishka.ui.gen.headless select
```

Generates `lib/<app>_web/components/headless/select.ex` defining `<.select>` (prefixed per your config). Requires two JS hooks registered in `app.js`:

```js
import Popup from "./popup.js";
import RovingTabindex from "./roving_tabindex.js";
// hooks: { Popup, RovingTabindex }
```

## Anatomy

| Part | Element | `data-part` | Notes |
|------|---------|-------------|-------|
| trigger | `button` | `trigger` | `role="combobox"`, opens/closes the popup |
| popup | `ul` | `popup` | `role="listbox"`, holds the options |
| option | `li` | `item` | `role="option"`, one per `:option` slot entry; carries `data-value` |
| hidden input | `input` | — | `type="hidden"`, rendered only when `name` is set; carries the value for form submission |

Root `<div>` carries `phx-hook="Popup"`; the `<ul>` popup carries `phx-hook="RovingTabindex"` with `data-orientation="vertical"`.

## ARIA & keyboard

- Trigger: `role="combobox"`, `aria-haspopup="listbox"`, `aria-controls="<id>-popup"`. `Popup` engine sets `aria-expanded` (`false` → `true`).
- Popup: `role="listbox"`.
- Option: `role="option"`, `aria-selected` (`"true"`/`"false"` from template; `RovingTabindex` updates it on activation), `tabindex="-1"`.

Keyboard: **Down/Up** move focus among options (vertical, rolling tabindex) · **Home/End** focus first/last option · **Enter/Space** activate focused option · **Escape** close popup and return focus to trigger · outside click closes the popup.

## State

Paired-presence `data-*` attributes (the absent half of each pair is never both present):

- `data-open` / `data-closed` — on the popup `<ul>`. Toggled by the **Popup** engine on show/hide (template renders `data-closed` initially). Popup also sets `data-side` and the `--chelekom-side` CSS var.
- `data-highlighted` — on the active option `<li>`. Toggled by the **RovingTabindex** engine when an option is activated (also flips `aria-selected`).

## Example

```heex
<.select id="fruit" name="order[fruit]" value={@fruit} placeholder="Pick a fruit…">
  <:option value="apple">Apple</:option>
  <:option value="banana">Banana</:option>
  <:option value="cherry">Cherry</:option>
</.select>
```

Attributes/slots (exactly as defined in the template):

- `id` (required) — root id; the popup id is `"<id>-popup"`.
- `name` — name for the hidden form input; the hidden `<input>` only renders when set.
- `value` — currently selected value; shown in the trigger when present, and matched against each option to set `aria-selected`.
- `placeholder` — trigger label when no `value` (default `"Select…"`).
- `class` — extra classes merged onto the root.
- `rest` — global attributes passed to the root `<div>`.
- `:option` slot (required), each with a required `value` attribute; the slot's inner content is the option label.

## Styling

Ships **no colors** and minimal layout. Style against stable class names and state hooks:

- `.chelekom-select` (root), `.chelekom-select__trigger`, `.chelekom-select__popup`, `.chelekom-select__option`.
- `.chelekom-sr-only` on the hidden input.
- Drive visibility/appearance from state: `[data-part="popup"][data-open]` / `[data-closed]`, `[data-part="item"][data-highlighted]`, and `[role="option"][aria-selected="true"]`. Positioning can read `[data-side]` / the `--chelekom-side` CSS var set by the Popup engine.
