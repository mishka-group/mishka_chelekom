# tabs (headless)

Headless tablist with roving focus and positionally-matched panels, implementing the [WAI-ARIA APG Tabs pattern](https://www.w3.org/WAI/ARIA/apg/patterns/tabs/) (auto-activation on focus).

## Generate

```bash
mix mishka.ui.gen.headless tabs
```

Generates `lib/<app>_web/components/headless/tabs.ex` exposing `tabs/1` (or `<prefix>tabs/1`). Requires the `RovingTabindex` JS hook registered (`import RovingTabindex from "./roving_tabindex.js";`).

## Anatomy

Root `<div>` carries `phx-hook="RovingTabindex"`, `data-orientation`, `data-activate-on-focus`.

| Part | `data-part` | Element | Role |
| --- | --- | --- | --- |
| tablist | `tablist` | `div` | `tablist` |
| tab | `item` | `button` | `tab` |
| panel | `panel` | `div` | `tabpanel` |

Note: the tab button uses `data-part="item"` (generic name the `RovingTabindex` engine queries via `[data-part="item"]`), not `data-part="tab"`.

Slots: `:tab` (required, repeatable) and `:panel` (required, repeatable — matched to its tab by index). The first tab/panel pair is selected/open by default.

## ARIA & keyboard

Generated automatically:

- `role="tablist"` with `aria-orientation` bound to `@orientation`.
- Each `role="tab"` button: `id="{id}-tab-{i}"`, `aria-controls="{id}-panel-{i}"`, `aria-selected` (`"true"` on index 0 initially), `tabindex` (`0` on selected tab, `-1` on rest).
- Each `role="tabpanel"`: `id="{id}-panel-{i}"`, `aria-labelledby="{id}-tab-{i}"`, `tabindex="0"`.

Keyboard (`RovingTabindex`, horizontal default / vertical when `data-orientation="vertical"`):

- Arrow Right/Down → next tab (wraps); Arrow Left/Up → previous tab (wraps); focusing a tab auto-activates it (move + activate).
- Home → first tab, End → last tab.
- Enter / Space → activate the focused tab.
- Items marked `data-disabled` are skipped.

## State

Paired-presence attributes toggled by `RovingTabindex` on activation:

- Panel: `data-open` (selected) / `data-closed` (not selected) — mutually exclusive, set via `toggleAttribute` keyed off the tab's `aria-controls`.
- Tab: `aria-selected` updated `"true"`/`"false"`; `data-highlighted` toggled on the active item.

Template seeds initial state (`data-open={i == 0}` / `data-closed={i != 0}`, `aria-selected={to_string(i == 0)}`); the JS hook maintains it thereafter.

## Example

```heex
<.tabs id="account-tabs" orientation="horizontal">
  <:tab>Profile</:tab>
  <:tab>Billing</:tab>
  <:tab>Notifications</:tab>

  <:panel>
    <h3>Profile</h3>
    <p>Manage your public profile.</p>
  </:panel>
  <:panel>
    <h3>Billing</h3>
    <p>Update your payment method.</p>
  </:panel>
  <:panel>
    <h3>Notifications</h3>
    <p>Choose what you get notified about.</p>
  </:panel>
</.tabs>
```

Attributes: `id` (required), `orientation` (`"horizontal"` default | `"vertical"`), `class` (merged onto root), `rest` (global passthrough). The Nth `:tab` pairs with the Nth `:panel` by position.

## Styling

Ships no colors or visual styling. Hook CSS onto `chelekom-tabs*` classes and `data-*` state:

- `.chelekom-tabs` — root container.
- `.chelekom-tabs__list` — the tablist.
- `.chelekom-tabs__tab` — each tab button (style selected state via `[aria-selected="true"]` and/or `[data-highlighted]`).
- `.chelekom-tabs__panel` — each panel (style `[data-open]` vs `[data-closed]`, e.g. hide closed panels).
