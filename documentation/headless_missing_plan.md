# Missing-components build plan (headless)

Build order for the Mantine components still missing from Mishka Chelekom (styled **and** headless).
One per commit, each with the full treatment. Excludes pure-Tailwind primitives (Box/Flex/Grid/…) and
whole subsystems (Dates/Charts/Schedule/Dropzone/Spotlight/RTE) which are tracked separately.

Per-component checklist (every item):
- `priv/headless/<name>.exs` (catalog + ARIA + `scripts` if it needs a JS engine)
- `priv/headless/<name>.eex` + `development/.../components/headless/<name>.ex`
- JS engine (if any): `priv/assets/js/<name>.js` + copy in `development/assets/vendor/` + register in `mishka_components.js`
- `meta.ex` one-line description
- `headless_preview.ex`: import + `show/1` + style helper
- `headless_baseui_examples.ex`: import + `sections/1` + `example/1`
- **bottom Examples section** (`has_examples?/1` + `examples/1`); if it's a form control → a Phoenix `<.form>` demo (live_component) with `handle_event`
- `CHANGELOG.md` one line
- commit (not pushed)

## Order

1. **Highlight** — no JS (render-time substring split → `<mark>`) — https://mantine.dev/core/highlight/
2. **SemiCircleProgress** — no JS (SVG arc + `role="progressbar"`) — https://mantine.dev/core/semi-circle-progress/
3. **NavLink** — no JS (link + optional nested disclosure via `<details>`/`JS.toggle`) — https://mantine.dev/core/nav-link/
4. **JsonInput** — no JS (textarea; optional server-side validate demo) — https://mantine.dev/core/json-input/
5. **SegmentedControl** — no JS (native radios + `:has(:checked)`); **form demo** — https://mantine.dev/core/segmented-control/
6. **LoadingOverlay** — no JS (compose `overlay` + a spinner slot; `visible` toggle) — https://mantine.dev/core/loading-overlay/
7. **PillsInput** — JS commands (`JS.focus` on click); **form demo** — https://mantine.dev/core/pills-input/
8. **MaskInput** — JS engine `mask_input.js` (format-as-you-type); **form demo** — https://mantine.dev/core/mask-input/
9. **AngleSlider** — JS engine `angle_slider.js` (pointer angle); **form demo** — https://mantine.dev/core/angle-slider/
10. **OverflowList** — JS engine `overflow_list.js` (`ResizeObserver`) — https://mantine.dev/core/overflow-list/
11. **FloatingIndicator** — JS engine `floating_indicator.js` (measure active target) — https://mantine.dev/core/floating-indicator/
12. **FloatingWindow** — JS engine `floating_window.js` (pointer drag) — https://mantine.dev/core/floating-window/
13. **ColorInput** — compose `color_picker` in a popover (`<details>` or Popover) + hex text input; **form demo** — https://mantine.dev/core/color-input/
14. **TreeSelect** — compose `tree` in a popover with a trigger label; **form demo** — https://mantine.dev/core/tree-select/

## Status

- [x] 1 Highlight
- [ ] 2 SemiCircleProgress
- [ ] 3 NavLink
- [ ] 4 JsonInput
- [ ] 5 SegmentedControl
- [ ] 6 LoadingOverlay
- [ ] 7 PillsInput
- [ ] 8 MaskInput
- [ ] 9 AngleSlider
- [ ] 10 OverflowList
- [ ] 11 FloatingIndicator
- [ ] 12 FloatingWindow
- [ ] 13 ColorInput
- [ ] 14 TreeSelect
