# avatar (headless)

An unstyled image with a text fallback (e.g. initials): renders an `<img>` when `src` is set and always renders a fallback region underneath, leaving show/hide to CSS. No formal WAI-ARIA APG pattern — decorative/representational images use an empty `alt` by default; pass a meaningful `alt` when the avatar conveys information.

## Generate

```bash
mix mishka.ui.gen.headless avatar
```

Generates `lib/<app>_web/components/headless/avatar.ex`. No JS engine to wire up — this component is pure markup.

## Anatomy

The root is a `<span>` carrying `class="chelekom-avatar"`. Parts are marked with `data-part` hooks:

| Part | Element | `data-part` | Class | Source |
|------|---------|-------------|-------|--------|
| root | `span` | — | `chelekom-avatar` | always rendered |
| image | `img` | `image` | `chelekom-avatar__image` | rendered only when `src` is set |
| fallback | `span` | `fallback` | `chelekom-avatar__fallback` | always rendered (`inner_block`) |

## ARIA & keyboard

No formal APG pattern; no keyboard interactions. ARIA wiring is static (no engine):

- **image** — `alt` is the `@alt` attr, which defaults to `""` (decorative). Pass a meaningful `alt` when the avatar conveys information.
- **fallback** — `aria-hidden="true"` when `src` is set (image present), otherwise no `aria-hidden` (so screen readers announce the fallback text when the image is absent).

## State

No JS. There are no `data-*` paired-presence state attributes and no engine — the catalog lists empty `state_attributes`, `hooks`, and `scripts`. Whether the fallback shows is a pure CSS concern: it renders only when `src` is `nil` from the server, and you can layer image-load CSS (e.g. hiding the fallback once the image paints) using the structural classes and `data-part` hooks.

## Example

```heex
<.avatar src={@user.avatar_url} alt={@user.name}>
  {initials(@user.name)}
</.avatar>

<%!-- No src: only the fallback renders, and it is not aria-hidden --%>
<.avatar id="anon-avatar" class="size-10">
  AB
</.avatar>
```

Attrs: `id` (optional), `src` (optional; when `nil` only the fallback renders), `alt` (string, default `""`), `class` (extra classes for the root), and `rest` (global). Slot: `inner_block` — the fallback content (e.g. initials) shown when the image is absent.

## Styling

This component ships **no** colors, sizing, or spacing — only structural markup. Style it via the `chelekom-avatar*` classes (`chelekom-avatar`, `__image`, `__fallback`) and the `data-part` hooks, e.g.:

```css
.chelekom-avatar__image    { /* size, border-radius, object-fit */ }
.chelekom-avatar__fallback { /* sizing, centered initials */ }

/* hide the fallback once the image is present */
.chelekom-avatar:has([data-part="image"]) [data-part="fallback"] { display: none; }
```

Add your own classes to the root via the `class` attr.
