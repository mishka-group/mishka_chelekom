# separator (headless)

An unstyled, accessible thematic divider between groups of content: a `<div role="separator">` (or `role="none"` when decorative) carrying `aria-orientation`, with **no JavaScript**. No formal WAI-ARIA APG pattern — it follows the [`separator` role](https://www.w3.org/WAI/ARIA/apg/) semantics.

## Generate

```bash
mix mishka.ui.gen.headless separator
```

Generates `lib/<app>_web/components/headless/separator.ex`. No JS engine to wire up.

## Anatomy

The root is a `<div>` with `class="chelekom-separator"`. An optional label part is rendered only when the `inner_block` slot is non-empty:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `div` | — | `chelekom-separator` | always rendered |
| label | `span` | `label` | `chelekom-separator__label` | `inner_block` (rendered only when present) |

## ARIA & keyboard

Roles and aria attributes (set directly by the template):

- **root** — `role="separator"` by default, or `role="none"` when `decorative` is `true`.
- **aria-orientation** — set to the `orientation` value (`"horizontal"` or `"vertical"`) on a non-decorative separator; omitted (`nil`) when `decorative`.

No keyboard interactions — the separator is a static, non-interactive divider (the `.exs` `aria_pattern` lists an empty `keyboard`).

## State

There is **no JS** (`hooks: []`, no scripts). The only state attribute is `data-orientation`, rendered statically by the template from the `orientation` assign (`"horizontal"` or `"vertical"`); it is not toggled at runtime. Use it as a styling hook.

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

Attrs: `id` (default `nil`), `orientation` (`"horizontal"` | `"vertical"`, default `"horizontal"`), `decorative` (boolean, default `false`), `class`, and `rest` (global). Slot: `inner_block` (optional — its presence renders the labelled `<span data-part="label">`).

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-separator*` classes (`chelekom-separator`, `chelekom-separator__label`) and the `data-orientation` state attribute, e.g.:

```css
.chelekom-separator[data-orientation="horizontal"] { /* full-width line */ }
.chelekom-separator[data-orientation="vertical"]   { /* full-height line */ }
.chelekom-separator__label                         { /* center the label structurally */ }
```

Add your own classes to the root via the `class` attr.