# disclosure (headless)

A button that shows or hides a single content region. Implements the [WAI-ARIA APG Disclosure pattern](https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/).

## Generate

```bash
mix mishka.ui.gen.headless disclosure
```

Generates `lib/<app>_web/components/headless/disclosure.ex` and copies the `Disclosure` JS hook (`disclosure.js`). Register the hook with your LiveSocket so `phx-hook="Disclosure"` resolves.

## Anatomy

Root `<div id={@id} phx-hook="Disclosure" class="chelekom-disclosure">` wrapping two parts:

| Part | Element | `data-part` | Hooks / IDs |
| --- | --- | --- | --- |
| trigger | `button` (`.chelekom-disclosure__trigger`) | `data-part="trigger"` | `id="#{@id}-trigger"`, `aria-controls="#{@id}-panel"` |
| panel | `div` (`.chelekom-disclosure__panel`) | `data-part="panel"` | `id="#{@id}-panel"`, `role="region"`, `aria-labelledby="#{@id}-trigger"` |

The JS engine discovers each `[data-part="trigger"]`, resolves its paired `[data-part="panel"]` via `aria-controls`, and wires the click handler.

## ARIA & keyboard

- **trigger**: `aria-expanded` (`"true"`/`"false"`, synced by the engine) and `aria-controls` pointing at the panel id.
- **panel**: `role="region"` and `aria-labelledby` pointing back at the trigger id.
- **Keyboard**: Enter / Space on the focused trigger toggles the panel (native `<button>` activation; the engine listens on `click`).

## State

Paired-presence attributes on the **panel**, toggled by the `Disclosure` JS engine:

- `data-open` — present when open.
- `data-closed` — present when closed.

These are always mutually exclusive. The initial values come from the `@open` attr in the template; thereafter `set/3` in `disclosure.js` flips both attributes and updates the trigger's `aria-expanded`. The `Disclosure` hook is the only engine that toggles them.

Optional root attributes the same engine honors (set via `@rest`):
- `data-single` — accordion-style exclusive open; opening one panel closes the others.
- `data-collapsible="false"` — prevents closing the currently open panel by clicking its trigger.

## Example

```heex
<.disclosure id="shipping" open={false} class="border rounded">
  <:trigger>Shipping details</:trigger>
  <p>Orders ship within 2 business days. Tracking is emailed on dispatch.</p>
</.disclosure>
```

Attributes: `id` (required), `open` (boolean, default `false`), `class` (any), plus `:rest` global. Slots: `:trigger` (required, the toggle button label) and the default `inner_block` (required, the disclosed content).

## Styling

Ships **no colors or visual styling** — only structural classes and state hooks. Style these:

- `.chelekom-disclosure` — root wrapper
- `.chelekom-disclosure__trigger` — toggle button
- `.chelekom-disclosure__panel` — disclosed region

Drive show/hide off the panel's state attributes, e.g.:

```css
.chelekom-disclosure__panel[data-closed] { display: none; }
.chelekom-disclosure__panel[data-open]   { display: block; }
```

You can also key off `aria-expanded` on the trigger (e.g. rotating a chevron).
