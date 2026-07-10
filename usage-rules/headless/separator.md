# separator (headless)

An unstyled, accessible thematic divider between groups of content: a `<div role="separator">` (or `role="none"` when decorative) carrying `aria-orientation`, with **no JavaScript**. No formal WAI-ARIA APG pattern — follows the [`separator` role](https://www.w3.org/WAI/ARIA/apg/) semantics.

## Generate

```bash
mix mishka.ui.gen.headless separator
```

Generates `lib/<app>_web/components/headless/separator.ex`. No JS engine to wire up.

## Anatomy

Root is a `<div>` with `class="chelekom-separator"`. The label part renders only when `inner_block` is non-empty.

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-separator` | always rendered |
| label | `span` | `label` | `chelekom-separator__label` | `inner_block` (rendered only when present) |

## ARIA & state

Set directly by the template (no JS, `hooks: []`, no runtime toggling):

- **role** — `"separator"` by default, or `"none"` when `decorative` is `true`.
- **aria-orientation** — the `orientation` value (`"horizontal"` or `"vertical"`) when not decorative; `nil` (omitted) when `decorative`.
- **data-orientation** — always rendered from `orientation` (`"horizontal"` or `"vertical"`); use as a styling hook.
- **keyboard** — none; static, non-interactive divider (`.exs` `aria_pattern` lists an empty `keyboard`).

## Example

```heex
<%!-- Plain horizontal rule --%>
<.separator />

<%!-- Labelled separator --%>
<.separator>or continue with</.separator>

<%!-- Vertical separator with extra classes --%>
<.separator id="sidebar-divider" orientation="vertical" class="my-divider" />

<%!-- Purely decorative (role="none", no aria-orientation) --%>
<.separator decorative />
```

**Attrs**: `id` (default `nil`) · `orientation` (`"horizontal"` | `"vertical"`, default `"horizontal"`) · `decorative` (boolean, default `false`) · `class` · `rest` (global).
**Slot**: `inner_block` (optional — presence renders the labelled `<span data-part="label">`).

## Styling

Ships **no** colors or spacing — structural markup only. Style via the `chelekom-separator*` classes and `data-orientation`:

```css
.chelekom-separator[data-orientation="horizontal"] { /* full-width line */ }
.chelekom-separator[data-orientation="vertical"]   { /* full-height line */ }
.chelekom-separator__label                         { /* center the label structurally */ }
```

Add your own classes to the root via the `class` attr.
