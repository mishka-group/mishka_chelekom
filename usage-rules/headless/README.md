# Mishka Chelekom — Headless components

Headless components are **unstyled markup + full WAI-ARIA wiring + a shared JS behavior core**.
They ship no colors, spacing or typography — you style the `chelekom-<comp>__<part>` classes and
the `data-*` state. This is the Base-UI-style layer that coexists with the styled generator.

## Generate

```bash
mix mishka.ui.gen.headless <name>          # one component
mix mishka.ui.gen.headless.components       # all of them
```

Output goes to `lib/<app>_web/components/headless/<name>.ex`, module
`<App>Web.Components.Headless.<Name>` — so **styled and headless coexist** without collisions.
There are no `--color/--variant/--size/--padding` options (meaningless for headless).

## Catalog (37 components, Base-UI parity)

| Component | WAI-ARIA pattern | JS hooks |
|---|---|---|
| dialog | Dialog (Modal) | FocusTrap |
| alert_dialog | Alert Dialog | FocusTrap |
| drawer | Dialog (Modal) + side | FocusTrap |
| popover | Disclosure + positioning | Popup |
| preview_card | Hover card | Popup |
| tooltip | Tooltip | Popup |
| menu | Menu Button | Popup + RovingTabindex |
| menubar | Menubar | RovingTabindex + Popup |
| context_menu | Menu (context) | Popup + RovingTabindex |
| navigation_menu | Disclosure nav | Popup |
| collapsible | Disclosure | Disclosure |
| accordion | Accordion | Disclosure |
| tabs | Tabs | RovingTabindex |
| toolbar | Toolbar | RovingTabindex |
| select | Listbox / Combobox | Popup + RovingTabindex |
| combobox | Combobox | HeadlessCombobox |
| autocomplete | Combobox (inline) | HeadlessCombobox |
| radio_group | Radio Group | RovingTabindex |
| radio | Radio | — (native) |
| otp_field | OTP / segmented input | Otp |
| checkbox | Checkbox | Toggle |
| checkbox_group | Checkbox | — |
| switch | Switch | Toggle |
| toggle | Button (pressed) | Toggle |
| toggle_group | Toolbar | RovingTabindex + Toggle |
| slider | Slider | Slider |
| number_field | Spinbutton | NumberScrub |
| field / fieldset | (form grouping) | — |
| avatar | (img + fallback) | — |
| separator | Separator | — |
| progress | Progressbar | — |
| meter | Meter | — |
| scroll_area | (scroll viewport) | — |
| toast | Alert / live region | ToastRegion |

> The headless `form` is intentionally omitted — Phoenix already ships `<.form>`. Use `field`
> and `fieldset` for grouping.

See the per-component docs in this folder, and `hooks.md` for the JS engines.

## Conventions (read once)

- **Base classes**: `chelekom-<component>` for the root, `chelekom-<component>__<part>` for parts
  (BEM-ish, framework-agnostic, stable).
- **State**: Base-UI **paired-presence** `data-*` — `data-open`/`data-closed`, `data-highlighted`,
  `data-selected`, `data-disabled`, `data-side`. The attribute's *presence* is the state; CSS
  targets `[data-open]`. Never `data-state="open"`.
- **Anatomy**: each part is reachable via `data-part="trigger|popup|item|panel|backdrop|…"`, which
  is also how the JS engines find their targets.
- **Behavior**: delegated to the shared engines in `priv/assets/js/` — FocusTrap, Disclosure,
  RovingTabindex, Popup, Toggle, Slider, NumberScrub, ToastRegion, HeadlessCombobox;
  no inline JS in templates. See `hooks.md`.

## Coexistence & migration

- Styled and headless live in different module namespaces (`Components.<Name>` vs
  `Components.Headless.<Name>`), so importing both is fine — call `<.button>` (styled) and
  `<.dialog>` (headless) side by side. If you import both modules into the same scope and a name
  collides (e.g. a future styled `tabs`), alias one import or use the fully-qualified call.
- Headless components install a tiny functional stylesheet (`assets/vendor/chelekom_headless.css`,
  imported into `app.css`) that only handles visibility/positioning — no opinionated styling.
- Both layers reuse the **same JS assembly**: a component's `scripts:` entries are copied into
  `assets/vendor/` and spliced into `mishka_components.js`, then `app.js`.
- Generated components have **zero runtime dependency** on `mishka_chelekom`; the Layer-3
  overrides/theming/DSL modules are opt-in and never forced on generated output.

## Theming (Layer 3, opt-in)

Style centrally without editing generated files via `MishkaChelekom.Overrides`
(Pyro-style first-wins), compose classes with `MishkaChelekom.CSS` (swappable
`tailwind_merge` seam), and declare variants/tokens with the `MishkaChelekom.Theme` Spark DSL
(compile-time validated). See the library moduledocs.
