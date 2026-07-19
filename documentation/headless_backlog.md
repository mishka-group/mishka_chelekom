# Headless (Mantine-port) backlog

Tracking which Mantine components still need a **headless** (unstyled + ARIA) port, and how.

Design rule (per Sha): **maximise `Phoenix.LiveView.JS` commands**. Only write a JS hook when the
behaviour is genuinely impossible with JS commands in the current LiveView (pointer-drag math,
`ResizeObserver` measurement, input masking, rAF animation). When a hook *is* needed, put it in its
**own separate JS file** under `priv/assets/js/<name>.js` and declare it in the component's `.exs`
`scripts` field. Installation and hook registration are handled by our **Igniter JS installer + CLI**
(`mix mishka.ui.gen.*`) — **not** manual `mishka_components.js` edits and **not** a colocated hook.

Per-component requirements (per Sha):
1. A **bottom-of-page Examples section** (`has_examples?/1` + `examples/1`) like Tree/EmptyState —
   required for every component with **behaviour** (state, events, form participation) **and for
   any component whose purpose is not obvious from the hero alone**: if a reader can look at the
   preview and ask "what is this for?", it needs an example that answers it (ColorSwatch and Pill
   both did). Only genuinely self-evident inline primitives (Mark, Code, ThemeIcon,
   VisuallyHidden, Anchor, ActionIcon, CloseButton, Marquee) are exempt.
2. If it is a **form control**, a **Phoenix `<.form>` example** in that Examples section.
3. **Manually test every feature/state** in the browser at http://localhost:4002 before committing.

## ⏸ Deferred — revisit later (bigger subsystems, not single components)

- Dates — Calendar, DatePicker, DateInput, DateTimePicker, Month/Year pickers, TimeInput/TimePicker — https://mantine.dev/dates/getting-started/
- Charts — Area/Bar/Line/Pie/Donut/Radar/Sankey/etc. — https://mantine.dev/charts/getting-started/
- Spotlight — command palette — https://mantine.dev/x/spotlight/
- Rich text editor — Tiptap-based — https://mantine.dev/x/tiptap/

## 🔜 To build — JS commands only (no hook)

- PillsInput — pills + input container; `JS.focus` on click — https://mantine.dev/core/pills-input/
- Affix — fixed-position content; CSS `position: fixed` (+ optional scroll-reveal hook) — https://mantine.dev/core/affix/

## 🔜 To build — needs a separate JS-file engine (hook)

- MaskInput — format-as-you-type — https://mantine.dev/core/mask-input/
- AngleSlider — pick 0–360° (pointer math) — https://mantine.dev/core/angle-slider/
- Splitter — resizable panes (pointer drag) — https://mantine.dev/core/splitter/
- OverflowList — hide items that don't fit (`ResizeObserver`) — https://mantine.dev/core/overflow-list/
- FloatingIndicator — indicator over active element (measure) — https://mantine.dev/core/floating-indicator/
- FloatingWindow — draggable floating area — https://mantine.dev/core/floating-window/
- Scroller — horizontal scroll + nav controls (scroll position) — https://mantine.dev/core/scroller/
- RollingNumber — animated digits — https://mantine.dev/core/rolling-number/
- ColorPicker — saturation/hue/alpha — https://mantine.dev/core/color-picker/
- HueSlider — hue channel slider (0–360°) — https://mantine.dev/core/hue-slider/
- AlphaSlider — alpha channel slider (0–1) — https://mantine.dev/core/alpha-slider/
- ColorInput — input + color-picker popover — https://mantine.dev/core/color-input/
- TreeSelect — tree inside a select/popover (compose `tree` + `select`/`popover`; may need a thin hook) — https://mantine.dev/core/tree-select/

## 🔜 To build — no JS (quick, same recipe as CloseButton/Burger/Chip/Pill)

Highlight, NavLink, SemiCircleProgress,
NumberFormatter (render-time, https://mantine.dev/core/number-formatter/).

## ✅ Done (headless)

EmptyState, CloseButton, Burger, Chip, Pill, TagsInput, Spoiler, ColorSwatch, Code, Mark,
VisuallyHidden, ThemeIcon, Anchor, ActionIcon, Marquee (+ the pre-existing 37).

## ❌ Dropped — not a headless component

Layout primitives (styling wrappers, not behaviour): Box, Flex, Grid, Group, Stack, Center,
Container, SimpleGrid, Space, AspectRatio, Paper, BackgroundImage.
