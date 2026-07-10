# scroll_area (headless)

An unstyled, accessible scrollable viewport: a structural overflow container with a focusable inner viewport for keyboard scrolling. Implements the [WAI-ARIA APG](https://www.w3.org/WAI/ARIA/apg/) "Scroll area" pattern. Ships no scrollbar styling — style the `chelekom-scroll_area*` classes and select the axis via `data-orientation`.

## Generate

```bash
mix mishka.ui.gen.headless scroll_area
```

Generates `lib/<app>_web/components/headless/scroll_area.ex`. No JS engine is wired by default (`hooks: []`, no scripts) — pure structural markup. A custom-scrollbar `ScrollArea` hook ships in the asset library (`priv/assets/js/scrollArea.js`) but is **optional** and **not** attached by the generated template; to get a draggable custom scrollbar you must wire it and supply the markup it expects yourself.

## Anatomy

Root is a `<div class="chelekom-scroll_area" data-orientation="...">` wrapping one focusable viewport part:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-scroll_area` | always rendered |
| viewport | `div` | `viewport` | `chelekom-scroll_area__viewport` | always rendered; wraps `inner_block` (required) |

The viewport carries `tabindex="0"` so it is focusable and keyboard-scrollable.

## ARIA & keyboard

Lightweight pattern — no special roles/`aria-*` beyond the focusable viewport (`tabindex="0"`). Keyboard behavior is native browser scrolling of the focused viewport:

- **Arrow keys** — scroll the focused viewport.
- **PageUp / PageDown** — scroll by a page.

## State

No JS. Only state attribute is `data-orientation` on the root, rendered statically from the `orientation` assign (`vertical` | `horizontal` | `both`, default `vertical`). It's a value-bearing attribute (not a paired-presence toggle) and nothing toggles it at runtime — change it by re-rendering with a different `orientation` assign. Use it as a CSS selector to pick the scroll axis (e.g. `[data-orientation="horizontal"]`).

## Example

```heex
<.scroll_area id="changelog" orientation="vertical" class="h-64 w-80">
  <article>
    <h3>Release notes</h3>
    <p>… long content that overflows the viewport …</p>
  </article>
</.scroll_area>
```

Attrs: `id` (required), `orientation` (`"vertical"` | `"horizontal"` | `"both"`, default `"vertical"`), `class`, `rest` (global). Slot: `inner_block` (required) — the scrollable content, rendered inside the viewport.

## Styling

Ships **no** colors or sizing — not even an `overflow` rule. Give the root or viewport a fixed size and the overflow behavior you want via the `chelekom-scroll_area*` classes (`chelekom-scroll_area`, `__viewport`) plus `data-orientation`:

```css
.chelekom-scroll_area__viewport            { height: 100%; }
.chelekom-scroll_area[data-orientation="vertical"]   .chelekom-scroll_area__viewport { overflow-y: auto; }
.chelekom-scroll_area[data-orientation="horizontal"] .chelekom-scroll_area__viewport { overflow-x: auto; }
.chelekom-scroll_area[data-orientation="both"]       .chelekom-scroll_area__viewport { overflow: auto; }
```

Add your own classes to the root via `class`.
