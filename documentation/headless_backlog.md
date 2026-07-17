# Headless (Mantine-port) backlog

Tracking which Mantine components still need a **headless** (unstyled + ARIA) port, and how.

Design rule (per Sha): **maximise `Phoenix.LiveView.JS` commands**. Only write a JS hook when the
behaviour is genuinely impossible with JS commands in the current LiveView (pointer-drag math,
`ResizeObserver` measurement, input masking, rAF animation). When a hook *is* needed, put it in its
**own separate JS file** under `priv/assets/js/<name>.js` and declare it in the component's `.exs`
`scripts` field. Installation and hook registration are handled by our **Igniter JS installer + CLI**
(`mix mishka.ui.gen.*`) — **not** manual `mishka_components.js` edits and **not** a colocated hook.

## ⏸ Deferred — revisit later (bigger subsystems, not single components)

- Dates — Calendar, DatePicker, DateInput, DateTimePicker, Month/Year pickers, TimeInput/TimePicker — https://mantine.dev/dates/getting-started/
- Charts — Area/Bar/Line/Pie/Donut/Radar/Sankey/etc. — https://mantine.dev/charts/getting-started/
- Spotlight — command palette — https://mantine.dev/x/spotlight/
- Rich text editor — Tiptap-based — https://mantine.dev/x/tiptap/

## 🔜 To build — needs interactivity (one at a time)

JS-commands-first; hook only where noted.

- TagsInput — free-entry tags + suggestions — server events (`phx-keydown`/`phx-change`) + `JS`; likely no custom hook — https://mantine.dev/core/tags-input/
- PillsInput — pills container + input — `JS.focus` on click; presentational; no hook — https://mantine.dev/core/pills-input/
- Affix — fixed-position content — CSS `position: fixed` (no JS); optional scroll-reveal hook — https://mantine.dev/core/affix/
- MaskInput — formatted input — hook (intercept input; JS commands can't mask) — https://mantine.dev/core/mask-input/
- AngleSlider — pick 0–360° — hook (pointer angle math) — https://mantine.dev/core/angle-slider/
- Splitter — resizable panes — hook (pointer drag) — https://mantine.dev/core/splitter/
- OverflowList — hide items that don't fit — hook (`ResizeObserver`) — https://mantine.dev/core/overflow-list/
- FloatingIndicator — indicator over active element — hook (measure + `ResizeObserver`) — https://mantine.dev/core/floating-indicator/
- FloatingWindow — draggable floating area — hook (pointer drag) — https://mantine.dev/core/floating-window/
- ColorPicker — saturation/hue/alpha — hook (pointer math; larger) — https://mantine.dev/core/color-picker/
- RollingNumber — animated digits — hook or CSS animation — https://mantine.dev/core/rolling-number/

## 🔜 To build — no JS (quick, same recipe as CloseButton/Burger/Chip/Pill)

Highlight, Mark, Code, ColorSwatch, ThemeIcon, ActionIcon, Anchor, NavLink, SemiCircleProgress,
NumberFormatter (render-time), Marquee (CSS animation).

## ✅ Done (headless)

EmptyState, CloseButton, Burger, Chip, Pill (+ the pre-existing 37).

## ❌ Dropped — already covered or not a headless component

- Scroller → covered by `scroll_area` — https://mantine.dev/core/scroller/
- TreeSelect → compose `tree` + `select` — https://mantine.dev/core/tree-select/
- Layout primitives (styling wrappers, not behaviour): Box, Flex, Grid, Group, Stack, Center,
  Container, SimpleGrid, Space, AspectRatio, Paper, BackgroundImage
