# Headless JS Behavior Engines

Mishka Chelekom's headless components are styled in markup but delegate all interactive behavior to a small set of shared, framework-agnostic JS engines. Each engine is a Phoenix LiveView hook (`mounted`/`updated`/`destroyed`) registered under a `phx-hook` name and attached to a component root via `phx-hook="..."`.

All engines follow a **paired-presence state contract** (Base-UI style): open elements carry `data-open`, closed elements carry `data-closed`, kept mutually exclusive via `toggleAttribute`. Engines read config from `data-*` attributes on the hook root and address markup through `[data-part="..."]` selectors. They ship **no** styling — consumers react to the state attributes via CSS.

Source files:
- `priv/assets/js/focus_trap.js`
- `priv/assets/js/disclosure.js`
- `priv/assets/js/roving_tabindex.js`
- `priv/assets/js/popup.js`

## Overview

| Engine | `phx-hook` | Responsibility | Reads (config `data-*`) | Writes (state) | Expected `[data-part]` | Consumed by |
| --- | --- | --- | --- | --- | --- | --- |
| FocusTrap | `FocusTrap` | Modal dialog: open/close, focus trap inside popup, focus restore | `data-open` (also a state attr; used to control), `data-close-on-escape`, `data-close-on-outside` | root + popup: `data-open`/`data-closed`; trigger: `aria-expanded`, `aria-haspopup`, `aria-controls` | `trigger`, `backdrop`, `popup` + any `[data-close]` elements | `dialog` |
| Disclosure | `Disclosure` | Expand/collapse trigger→panel pairs; optional accordion (single-open) | `data-multiple`, `data-collapsible` | panel: `data-open`/`data-closed`; trigger: `aria-expanded` | `trigger` (panel resolved via `aria-controls`) | `collapsible`, `accordion` |
| RovingTabindex | `RovingTabindex` | One-tab-stop composite keyboard nav (arrows/Home/End); optional activate-on-focus selection | `data-orientation`, `data-activate-on-focus` | item: `tabindex`, `data-highlighted`, `aria-selected` (only if already present); panel: `data-open`/`data-closed` | `item` (panel resolved via item `aria-controls`) | `tabs`, `menu`, `select` |
| Popup | `Popup` | Floating layer: open/close, outside-click + Escape dismissal, lightweight side/align placement | `data-trigger`, `data-side`, `data-align` | popup: `data-open`/`data-closed`, `data-side`, `--chelekom-side` CSS var; trigger: `aria-expanded`, `aria-controls` | `trigger`, `popup` | `popover`, `menu`, `tooltip`, `select` |

---

## FocusTrap

**`phx-hook="FocusTrap"`** — headless dialog / alert-dialog engine.

Trigger opens the dialog; Tab/Shift+Tab cycle focus among visible focusables inside the popup; Escape / backdrop click / `[data-close]` buttons close it and restore focus to the opener. Client-driven by default, but server-controllable by toggling `data-open` on the root — `updated()` re-syncs `active` state against the attribute.

- **Reads:** `data-open` (presence activates trap on mount; re-read in `updated()` to drive open/close from the server) · `data-close-on-escape` (Escape closes unless `"false"`) · `data-close-on-outside` (backdrop click closes unless `"false"`)
- **Writes:** root **and** popup toggle `data-open`/`data-closed`; trigger gets `aria-expanded="true"/"false"`, and on mount `aria-haspopup="dialog"` + `aria-controls` (→ `popup.id`)
- **Parts:** `trigger` (click opens) · `backdrop` (click closes, only when `closeOnOutside`) · `popup` (focus-trapped container; focusables queried inside it, fallback focus target if none) · any `[data-close]` element (not a `data-part`; click closes)
- **Notes:** focusable set = `a[href]`, non-disabled `button`/`textarea`/`input`/`select`, `[tabindex]:not([tabindex="-1"])`, filtered to visible (`offsetParent !== null`). Global `keydown` listener added in capture phase on `document` while active, removed on `destroyed`. First focusable (or the popup) is focused on the next animation frame.
- **Consumed by:** `priv/headless/dialog.eex` (root `phx-hook="FocusTrap"`; parts `trigger`, `backdrop`, `popup`, plus `title`/`description`/`content`/`footer` for layout; close buttons use `data-close`).

---

## Disclosure

**`phx-hook="Disclosure"`** — headless disclosure / accordion engine.

Each `[data-part="trigger"]` button pairs with a panel resolved through its `aria-controls` id (via `CSS.escape`). Click toggles the panel. Add `data-single` to the root for accordion-style exclusive open (opening one item closes the others). Initial `aria-expanded` is seeded from whether the panel already has `data-open`.

- **Reads:** `data-single` (presence enables single-open/accordion mode) · `data-collapsible` (set `"false"` to prevent closing an already-open item by clicking its trigger; default collapsible)
- **Writes:** panel toggles `data-open`/`data-closed`; trigger gets `aria-expanded="true"/"false"`
- **Parts:** `trigger` — the toggling button; must carry `aria-controls` pointing at its panel's id (panel is located by id, not by a `data-part`)
- **Notes:** purely client-driven, no `updated()`/`destroyed()` resync. Keyboard activation relies on the native button (Enter/Space) — the engine binds only `click`.
- **Consumed by:** `priv/headless/collapsible.eex` (root `phx-hook="Disclosure"`) and `priv/headless/accordion.eex` (root `phx-hook="Disclosure"`, typically with `data-multiple`).

---

## RovingTabindex

**`phx-hook="RovingTabindex"`** — headless composite navigation engine (tabs / menu / listbox / toolbar).

Maintains exactly one `[data-part="item"]` with `tabindex="0"` while all others are `-1`. Arrow keys (plus Home/End) move focus among items and roll the tabindex; Enter/Space activates the focused item. With `data-activate-on-focus` (tabs pattern), merely focusing an item activates it. Activation toggles `aria-selected` (only on items that already have the attribute), sets `data-highlighted`, and shows the matching panel found via the item's `aria-controls` id.

- **Reads:** `data-orientation` (`"vertical"` enables Up/Down arrows; default Left/Right) · `data-activate-on-focus` (presence makes focusing an item activate it — tabs)
- **Writes:** items get `tabindex` (`0` for active, `-1` for rest), `data-highlighted` toggled on the active item, `aria-selected` updated **only if already present**; panels toggle `data-open`/`data-closed` on the element whose id matches the active item's `aria-controls`
- **Parts:** `item` — the navigable elements; items with `data-disabled` are filtered out/skipped. Panels are not `data-part`s — resolved via `getElementById(item.getAttribute("aria-controls"))`.
- **Notes:** initial active index = first item with `aria-selected="true"` or `data-active`, else `0`. `refresh()` runs on `mounted` and `updated`, guarding per-item listener binding with an `item._rtBound` flag so re-renders don't double-bind. Arrow navigation wraps around (modulo). `keydown` listener is on the hook root, removed on `destroyed`.
- **Consumed by:** `priv/headless/tabs.eex` (root `phx-hook="RovingTabindex"`, with `data-activate-on-focus`), `priv/headless/menu.eex` (inner list `phx-hook="RovingTabindex"`, menu root is `Popup`), `priv/headless/select.eex` (listbox `<ul>` uses `phx-hook="RovingTabindex"` with `data-orientation="vertical"`, select root is `Popup`).

---

## Popup

**`phx-hook="Popup"`** — headless floating + dismissal engine (popover / menu / tooltip / select).

A `[data-part="trigger"]` opens a `[data-part="popup"]`; outside-click (capture-phase document listener) and Escape close it (Escape also returns focus to the trigger). With `data-trigger="hover"` (tooltip), opens on `mouseenter`/`focusin` and closes on `mouseleave`/`focusout` instead of click, and never moves focus into the popup. For click triggers, opening focuses the first menu-item/option/link/button on the next animation frame. Positioning is lightweight: inline styles place the popup on the configured side, and the resolved side is exposed for CSS.

- **Reads:** `data-trigger` (`"hover"` switches to hover/focus open mode; otherwise click toggles) · `data-side` — `top`\|`right`\|`bottom`\|`left` (default `bottom`); drives both `position()` inline styles and the published side state · `data-align` — `start`\|`center`\|`end` (default `center`); read into `this.align` (reserved for alignment; not applied in the minimal `position()`)
- **Writes:** popup toggles `data-open`/`data-closed`, sets `data-side` to the resolved side, sets `--chelekom-side` CSS custom property, sets inline positioning styles (`top`/`bottom`/`left`/`right`) per side; trigger gets `aria-expanded="true"/"false"`, and on mount `aria-controls` (→ `popup.id`)
- **Parts:** `trigger` — opens/toggles the popup · `popup` — the floating layer; `isOpen()` determined by its `data-open` attribute; on open (non-hover) the first focusable inside is found via `[data-part="item"],[role="menuitem"],[role="option"],a,button`
- **Notes:** outside-click and Escape `keydown` listeners added in capture phase on `document` only while open, removed on `hide()` and `destroyed()`. The trigger's click handler calls `stopPropagation()` so the same click doesn't immediately trigger the outside-close. Engine never traps focus — pair it with `RovingTabindex` inside the popup for keyboard navigation (menu/select).
- **Consumed by:** `priv/headless/popover.eex` (root `phx-hook="Popup"`), `priv/headless/tooltip.eex` (root `phx-hook="Popup"`, `data-trigger="hover"`), `priv/headless/menu.eex` (root `phx-hook="Popup"` with `data-side`; inner list is `RovingTabindex`), `priv/headless/select.eex` (root `phx-hook="Popup"`; listbox is `RovingTabindex`).
