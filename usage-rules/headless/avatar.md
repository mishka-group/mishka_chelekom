# avatar (headless)

An unstyled image with a text fallback (e.g. initials): renders an `<img>` when `src` is set and always renders a fallback region underneath, leaving show/hide to CSS. No formal WAI-ARIA APG pattern.

## Generate

```bash
mix mishka.ui.gen.headless avatar
```

Generates `lib/<app>_web/components/headless/avatar.ex`. Pure markup — no JS engine to wire up.

## Anatomy

Root is a `<span class="chelekom-avatar">`. Parts use `data-part` hooks:

| Part | Element | `data-part` | Class | Rendered |
|------|---------|-------------|-------|----------|
| root | `span` | — | `chelekom-avatar` | always |
| image | `img` | `image` | `chelekom-avatar__image` | only when `src` is set |
| fallback | `span` | `fallback` | `chelekom-avatar__fallback` | always (`inner_block`) |

## ARIA & keyboard

No formal APG pattern, no keyboard interactions, no engine — ARIA wiring is static:

- **image** — `alt` is the `@alt` attr, default `""` (decorative). Pass a meaningful `alt` when the avatar conveys information.
- **fallback** — `aria-hidden="true"` when `src` is set (image present); otherwise no `aria-hidden`, so screen readers announce the fallback text when the image is absent.

## State

No JS engine: empty `state_attributes`, `hooks`, and `scripts` in the catalog — no paired-presence `data-*` state attrs. Fallback visibility is a pure CSS concern: the fallback markup renders only when `src` is `nil` from the server; you can layer image-load CSS (e.g. hide the fallback once the image paints) using the structural classes / `data-part` hooks.

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

Attrs: `id` (optional), `src` (optional; `nil` renders only the fallback), `alt` (string, default `""`), `class` (extra classes for the root), `rest` (global).
Slot: `inner_block` — fallback content (e.g. initials) shown when the image is absent.

## Styling

Ships **no** colors, sizing, or spacing — structural markup only. Style via the `chelekom-avatar*` classes and `data-part` hooks:

```css
.chelekom-avatar__image    { /* size, border-radius, object-fit */ }
.chelekom-avatar__fallback { /* sizing, centered initials */ }

/* hide the fallback once the image is present */
.chelekom-avatar:has([data-part="image"]) [data-part="fallback"] { display: none; }
```

Add your own classes to the root via the `class` attr.
