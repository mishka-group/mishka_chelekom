# scroll_area (headless)

An unstyled, accessible scrollable viewport: a structural overflow container with a focusable inner viewport for keyboard scrolling. Implements the [WAI-ARIA APG](https://www.w3.org/WAI/ARIA/apg/) "Scroll area" pattern. It ships no scrollbar styling — style the `chelekom-scroll_area*` classes and select the axis via `data-orientation`.

## Generate

```bash
mix mishka.ui.gen.headless scroll_area
```

Generates `lib/<app>_web/components/headless/scroll_area.ex`. No JS engine is wired by default (`hooks: []`, no scripts) — the component is pure structural markup. A custom-scrollbar `ScrollArea` hook ships in the asset library (`priv/assets/js/scrollArea.js`) but is **optional** and is **not** attached by the generated template; if you want a draggable custom scrollbar you must wire it and supply the markup it expects yourself.

## Anatomy

The root is a `<div>` carrying `class="chelekom-scroll_area"` and `data-orientation`. It wraps a single focusable viewport part, marked with `data-part`:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-scroll_area` | always rendered |
| viewport | `div` | `viewport` | `chelekom-scroll_area__viewport` | always rendered; wraps `inner_block` (required) |

The viewport carries `tabindex="0"` so it is focusable and can be scrolled with the keyboard.

## ARIA & keyboard

The "Scroll area" pattern is lightweight — there are no special roles or `aria-*` attributes wired by the template beyond making the viewport focusable. Keyboard behavior is the browser's native scrolling of the focused viewport (`tabindex="0"`):

- **Arrow keys** — scroll the focused viewport.
- **PageUp / PageDown** — scroll the focused viewport by a page.

## State

No JS. The only state attribute is `data-orientation` on the root, rendered statically from the `orientation` assign (`vertical` | `horizontal` | `both`, default `vertical`). It is a value-bearing attribute, not a paired-presence toggle, and nothing toggles it at runtime — change it by re-rendering with a different `orientation` assign. Use it as a CSS selector to pick the scroll axis (e.g. `[data-orientation="horizontal"]`).

## Example

```heex
<.scroll_area id="changelog" orientation="vertical" class="h-64 w-80">
  <article>
    <h3>Release notes</h3>
    <p>… long content that overflows the viewport …</p>
  </article>
</.scroll_area>
```

Attrs: `id` (required), `orientation` (`"vertical"` | `"horizontal"` | `"both"`, default `"vertical"`), `class`, and `rest` (global). Slot: `inner_block` (required) — the scrollable content, rendered inside the viewport.

## Styling

This component ships **no** colors or sizing — only structural markup, and not even an `overflow` rule. Give the root or viewport a fixed size and the overflow behavior you want via the `chelekom-scroll_area*` classes (`chelekom-scroll_area`, `__viewport`) plus the `data-orientation` state, e.g.:

```css
.chelekom-scroll_area__viewport            { height: 100%; }
.chelekom-scroll_area[data-orientation="vertical"]   .chelekom-scroll_area__viewport { overflow-y: auto; }
.chelekom-scroll_area[data-orientation="horizontal"] .chelekom-scroll_area__viewport { overflow-x: auto; }
.chelekom-scroll_area[data-orientation="both"]       .chelekom-scroll_area__viewport { overflow: auto; }
```

Add your own classes to the root via the `class` attr.
