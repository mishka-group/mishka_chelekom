# tooltip (headless)

A hover/focus popup that describes its trigger, built on the shared `Popup` engine in hover mode. Implements the [WAI-ARIA APG Tooltip pattern](https://www.w3.org/WAI/ARIA/apg/patterns/tooltip/).

## Generate

```bash
mix mishka.ui.gen.headless tooltip
```

Generates `lib/<app>_web/components/headless/tooltip.ex`.

## Anatomy

The component renders a root `div` (`phx-hook="Popup"`, `data-trigger="hover"`) wrapping two parts, each marked with a `data-part` hook the JS engine queries:

| Part | Element | `data-part` | Notes |
| --- | --- | --- | --- |
| trigger | `span` | `trigger` | `aria-describedby`, `tabindex="0"`, class `chelekom-tooltip__trigger` |
| popup | `div` | `popup` | `role="tooltip"`, `id="#{id}-popup"`, class `chelekom-tooltip__popup` |

Slots: `:trigger` (required) and `:inner_block` (required, the tooltip content). Attrs: `:id` (required), `:side` (`"top"` default; `top|right|bottom|left`), `:class`, and `:rest` global.

## ARIA & keyboard

- Trigger carries `aria-describedby="#{id}-popup"` pointing at the popup; the `Popup` engine also sets `aria-controls` and toggles `aria-expanded` (`false`/`true`).
- Popup carries `role="tooltip"`.
- Keyboard: `Escape` dismisses the tooltip (engine returns focus to the trigger).
- Focus: the tooltip never receives or traps focus. It opens on `mouseenter`/`focusin` and hides on `mouseleave`/`focusout`.

## State

The popup uses paired-presence `data-*` attributes toggled by the `Popup` JS engine (`priv/assets/js/popup.js`):

- `data-open` / `data-closed` — exactly one is present; `show()` sets `data-open` (clears `data-closed`), `hide()` reverses it. The popup renders with `data-closed` initially.
- `data-side` — set to the resolved side on open; the engine also exposes it as the `--chelekom-side` CSS variable.

Outside-click and `Escape` (via document listeners added on open) both trigger `hide()`.

## Example

```heex
<.tooltip id="save-tip" side="top">
  <:trigger>
    <button type="button">Save</button>
  </:trigger>
  Saves your changes to the server.
</.tooltip>
```

## Styling

Ships no colors or visual styling. Style the `chelekom-tooltip`, `chelekom-tooltip__trigger`, and `chelekom-tooltip__popup` classes, and drive open/closed visibility off the `data-*` state, e.g.:

```css
.chelekom-tooltip__popup[data-closed] { display: none; }
.chelekom-tooltip__popup[data-open]   { display: block; }
```

Use `data-side` (or the `--chelekom-side` CSS var) for side-specific offsets/arrows.
