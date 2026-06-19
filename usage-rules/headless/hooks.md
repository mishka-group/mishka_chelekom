# Headless JS Behavior Engines

Mishka Chelekom's headless components are styled in markup but delegate all interactive behavior to a small set of shared, framework-agnostic JS engines. Each engine is a Phoenix LiveView hook object (`mounted` / `updated` / `destroyed` lifecycle) registered under a `phx-hook` name and attached to a component root via `phx-hook="..."`.

These engines follow a **paired-presence state contract** (Base-UI style): open elements carry `data-open`, closed elements carry `data-closed`, and the two are kept mutually exclusive via `toggleAttribute`. Engines read configuration from `data-*` attributes on the hook root and communicate with the markup through `[data-part="..."]` selectors. They ship **no** styling — consumers react to the state attributes via CSS.

Source files:
- `/Users/shahryar/Documents/Programming/Elixir/mishka_chelekom/priv/assets/js/focus_trap.js`
- `/Users/shahryar/Documents/Programming/Elixir/mishka_chelekom/priv/assets/js/disclosure.js`
- `/Users/shahryar/Documents/Programming/Elixir/mishka_chelekom/priv/assets/js/roving_tabindex.js`
- `/Users/shahryar/Documents/Programming/Elixir/mishka_chelekom/priv/assets/js/popup.js`

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

**Responsibility.** Self-contained modal behavior: a trigger opens the dialog, keyboard focus is trapped inside the popup (Tab/Shift+Tab cycle through visible focusables), and Escape / backdrop click / `[data-close]` buttons close it, restoring focus to the element that opened it. It is client-driven by default but can be server-controlled by toggling `data-open` on the root — `updated()` re-syncs `active` state against the attribute.

**Config attributes read (root):**
- `data-open` — presence on mount activates the trap immediately; also re-read in `updated()` to drive open/close from the server.
- `data-close-on-escape` — Escape closes unless set to the literal string `"false"`.
- `data-close-on-outside` — backdrop click closes unless set to `"false"`.

**State written:**
- Root **and** popup: toggles `data-open` / `data-closed` (mutually exclusive).
- Trigger: `aria-expanded` set to `"true"`/`"false"`; on mount also sets `aria-haspopup="dialog"` and `aria-controls` (to `popup.id` when present).

**Markup parts expected (`data-part`):**
- `trigger` — click opens; gets the aria wiring above.
- `backdrop` — click closes (only wired when `closeOnOutside`).
- `popup` — the focus-trapped container; focusables are queried inside it, and it is the fallback focus target if it has no focusables.
- Any element with `[data-close]` (not a `data-part`) — click closes.

**Notes.** Focusable set = `a[href]`, non-disabled `button`/`textarea`/`input`/`select`, and `[tabindex]:not([tabindex="-1"])`, filtered to visible (`offsetParent !== null`). The global `keydown` listener is added in capture phase on `document` while active and removed on `destroyed`. First focusable (or the popup) is focused on the next animation frame.

**Consumed by:** `priv/headless/dialog.eex` (root `phx-hook="FocusTrap"`; parts `trigger`, `backdrop`, `popup`, plus `title`/`description`/`content`/`footer` for layout; close buttons use `data-close`).

---

## Disclosure

**`phx-hook="Disclosure"`** — headless disclosure / accordion engine.

**Responsibility.** Each `[data-part="trigger"]` button is paired with a panel resolved through its `aria-controls` id (looked up with `CSS.escape`). Click toggles the panel's open state. Add `data-single` to the root for accordion-style exclusive open (opening one item closes the others). Initial `aria-expanded` is seeded from whether the panel already has `data-open`.

**Config attributes read (root):**
- `data-single` — presence enables single-open (accordion) mode.
- `data-collapsible` — when set to `"false"`, an already-open item cannot be closed by clicking its trigger (only relevant with the toggle-to-close path). Defaults to collapsible.

**State written:**
- Panel: toggles `data-open` / `data-closed`.
- Trigger: `aria-expanded` set to `"true"`/`"false"`.

**Markup parts expected (`data-part`):**
- `trigger` — the toggling button; must carry `aria-controls` pointing at its panel's id. The panel itself is located by id, not by a `data-part`.

**Notes.** Purely client-driven; no `updated()`/`destroyed()` resync. Keyboard activation relies on the native button (Enter/Space) — the engine binds only `click`.

**Consumed by:** `priv/headless/collapsible.eex` (root `phx-hook="Disclosure"`) and `priv/headless/accordion.eex` (root `phx-hook="Disclosure"`, typically with `data-multiple`).

---

## RovingTabindex

**`phx-hook="RovingTabindex"`** — headless composite navigation engine (tabs / menu / listbox / toolbar).

**Responsibility.** Maintains exactly one `[data-part="item"]` with `tabindex="0"` while all others are `-1`. Arrow keys (plus Home/End) move focus among items and roll the tabindex; Enter/Space activates the focused item. With `data-activate-on-focus` (tabs pattern), merely focusing an item activates it. Activation toggles `aria-selected` (only on items that already have the attribute), sets `data-highlighted`, and shows the matching panel found via the item's `aria-controls` id.

**Config attributes read (root):**
- `data-orientation` — `"vertical"` enables Up/Down arrows; otherwise (default) Left/Right.
- `data-activate-on-focus` — presence makes focusing an item activate it (tabs).

**State written:**
- Items: `tabindex` (`0` for the active one, `-1` for the rest), `data-highlighted` toggled on the active item, and `aria-selected` updated **only if the item already has that attribute**.
- Panels: toggles `data-open` / `data-closed` on the element whose id matches an item's `aria-controls`.

**Markup parts expected (`data-part`):**
- `item` — the navigable elements. Items carrying `data-disabled` are filtered out and skipped. Panels are not `data-part`s; they are resolved by `getElementById(item.getAttribute("aria-controls"))`.

**Notes.** Initial active index = first item with `aria-selected="true"` or `data-active`, else `0`. `refresh()` runs on `mounted` and `updated`, and guards per-item listener binding with an `item._rtBound` flag so re-renders don't double-bind. Arrow navigation wraps around (modulo). The `keydown` listener is on the hook root and removed on `destroyed`.

**Consumed by:** `priv/headless/tabs.eex` (root `phx-hook="RovingTabindex"`, with `data-activate-on-focus`), `priv/headless/menu.eex` (inner list `phx-hook="RovingTabindex"`, the menu root being `Popup`), and `priv/headless/select.eex` (the listbox `<ul>` uses `phx-hook="RovingTabindex"` with `data-orientation="vertical"`, the select root being `Popup`).

---

## Popup

**`phx-hook="Popup"`** — headless floating + dismissal engine (popover / menu / tooltip / select).

**Responsibility.** A `[data-part="trigger"]` opens a `[data-part="popup"]`; outside-click (capture-phase document listener) and Escape close it (Escape also returns focus to the trigger). With `data-trigger="hover"` (tooltip), it opens on `mouseenter`/`focusin` and closes on `mouseleave`/`focusout` instead of click, and never moves focus into the popup. For click triggers, opening focuses the first menu-item/option/link/button on the next animation frame. Positioning is lightweight: inline styles place the popup on the configured side, and the resolved side is exposed for CSS.

**Config attributes read (root):**
- `data-trigger` — `"hover"` switches to hover/focus open mode; otherwise click toggles.
- `data-side` — `top` | `right` | `bottom` | `left` (default `bottom`); drives both the `position()` inline styles and the published side state.
- `data-align` — `start` | `center` | `end` (default `center`); read into `this.align` (reserved for alignment; not applied in the minimal `position()`).

**State written:**
- Popup: toggles `data-open` / `data-closed`; sets `data-side` to the resolved side; sets the `--chelekom-side` CSS custom property; sets inline positioning styles (`top`/`bottom`/`left`/`right`) per side.
- Trigger: `aria-expanded` `"true"`/`"false"`; on mount sets `aria-controls` to `popup.id` when present.

**Markup parts expected (`data-part`):**
- `trigger` — opens/toggles the popup.
- `popup` — the floating layer; `isOpen()` is determined by its `data-open` attribute. On open (non-hover), the first focusable inside is found via `[data-part="item"],[role="menuitem"],[role="option"],a,button`.

**Notes.** Outside-click and Escape `keydown` listeners are added in capture phase on `document` only while open, removed on `hide()` and `destroyed()`. The trigger's click handler calls `stopPropagation()` so the same click doesn't immediately trigger the outside-close. Engine never traps focus; pair it with `RovingTabindex` inside the popup for keyboard navigation (menu/select).

**Consumed by:** `priv/headless/popover.eex` (root `phx-hook="Popup"`), `priv/headless/tooltip.eex` (root `phx-hook="Popup"`, `data-trigger="hover"`), `priv/headless/menu.eex` (root `phx-hook="Popup"` with `data-side`; inner list is `RovingTabindex`), and `priv/headless/select.eex` (root `phx-hook="Popup"`; listbox is `RovingTabindex`).
