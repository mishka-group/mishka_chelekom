# Changelog for MishkaChelekom 0.0.10

### Features:

- Add headless `Tree` component — Mantine's Tree converted to a Phoenix headless component, with expand/collapse, single/multiple and shift-range selection, cascading checkboxes (with indeterminate) or `check_strictly`, WAI-ARIA treeview keyboard navigation, drag & drop, and server-driven async child loading
- Add Base UI gallery example and live server-driven examples (controller, form, single event, async, drag & drop, search) for the `Tree` component
- Add headless `EmptyState` component — Mantine's EmptyState converted to a Phoenix headless component: an optional indicator, `title`/`description` shorthands, extra body content and an actions row, aligned via `data-align` (left/center/right); ships no colors, spacing or role (presentational — add `role="status"` for dynamically shown states)
- Add headless `CloseButton` component (Mantine parity) — an icon-only button with a required `aria-label`, custom-icon slot and `data-disabled`
- Add headless `Burger` component (Mantine parity) — a hamburger navigation toggle with `aria-expanded`/`aria-controls` and `data-opened`
- Add headless `Chip` component (Mantine parity) — a selectable pill backed by a native checkbox/radio input, checked styling via `:has(:checked)`
- Add headless `Pill` component (Mantine parity) — a compact tag/token with an optional accessible remove button and `data-disabled`
- Add headless `TagsInput` component (Mantine parity) — removable tokens plus a draft input; add via a form `phx-submit` or `on_add`, remove via `on_remove`, click-to-focus via `JS.focus`, no JS hook
- Add headless `Spoiler` component (Mantine parity) — clamp long content behind a Show more / Show less toggle via `JS.toggle_attribute`, no JS hook
- Add headless `ColorSwatch` component (Mantine parity) — display a single color as a labelled `role="img"` swatch with optional overlay
- Add headless `Code` component (Mantine parity) — inline `<code>` or a `<pre><code>` block
- Add headless `Mark` component (Mantine parity) — highlight an inline run of text with `<mark>`
- Add headless `VisuallyHidden` component (Mantine parity) — hide content visually while keeping it available to screen readers
- Add headless `ThemeIcon` component (Mantine parity) — a container that wraps an icon, decorative or labelled
- Add headless `ActionIcon` component (Mantine parity) — an icon-only action button with a required accessible label
- Add headless `Anchor` component (Mantine parity) — a plain, themeable link
- Add headless `Marquee` component (Mantine parity) — seamless CSS-only scrolling row (content duplicated, second copy `aria-hidden`), no JS hook
- Add headless `NumberFormatter` component (Mantine parity) — render-time number formatting with thousands/decimal separators and prefix/suffix, no JS
- Add headless `HueSlider` component (Mantine parity) — a 0–360° hue picker reusing the shared `Slider` engine, no new JS
- Add headless `AlphaSlider` component (Mantine parity) — a 0–100 opacity picker reusing the shared `Slider` engine, no new JS
- Add headless `Splitter` component (Mantine parity) — two resizable panes via a `Splitter` JS engine (pointer drag + keyboard, `role="separator"`)
- Add headless `Scroller` component (Mantine parity) — horizontal scroll row with prev/next controls via a `Scroller` JS engine (ResizeObserver end-detection)
- Add headless `RollingNumber` component (Mantine parity) — animate a number to its value via a `RollingNumber` JS engine (rAF, reduced-motion aware)
- Add headless `ColorPicker` component (Mantine parity) — saturation/value drag area + hue slider via a `ColorPicker` JS engine (HSV↔hex, hidden input for forms)
- Add headless `Highlight` component (Mantine parity) — wrap case-insensitive matches of one or more query terms in `<mark>` at render time, no JS
- Add headless `SemiCircleProgress` component (Mantine parity) — a half-circle SVG gauge (`role="progressbar"`) computed at render time, no JS
- Add headless `NavLink` component (Mantine parity) — a nav item that's a `<.link>` leaf or a native `<details>` disclosure with nested children (`data-active`/`aria-current`), no JS
- Add headless `JsonInput` component (Mantine parity) — a JSON textarea with a server-validated `data-invalid` state (parse/format via `Jason` in LiveView), no JS
- Add headless `SegmentedControl` component (Mantine parity) — a row of native radios with `:has(:checked)` selection and Arrow-key navigation, no JS
- Add headless `LoadingOverlay` component (Mantine parity) — an absolute `role="status"` loader overlay toggled by `visible` (CSS fade), no JS
- Add `Mishka Tools` documentation button to headless component pages, and point `ARIA pattern` at the component's `spec_url` instead of its docs URL
- Add per-option tagged, base-first `examples` to `mix mishka.ui.export --cms`: every component now ships at least one example, ordered base-first, with `extra.examples[]` carrying `label`/`section`/`base`/`requires` so a consumer can hide an example whose variant was not installed [Commit](https://github.com/mishka-group/mishka_chelekom/commit/65764c5e)
- Add `## Examples` docs to `label/1`, `error/1`, `header/1` and `simple_form/1`, so every public component function documents its usage

### Refactors:

- Refactor the `--cms` export example pipeline into `CmsBundle.{DocExamples, DocsPage, Examples, Sanitize}`, harvesting from each function's `@doc` fences and the docs pages' `code_string/1` snippets rather than the demo markup
- Update `phoenix_live_view` to 1.2.7 [Commit](https://github.com/mishka-group/mishka_chelekom/commit/85d3bf5f)
- Point `doc_url` at mishka.tools and preserve the specification URLs under `spec_url` [Commit](https://github.com/mishka-group/mishka_chelekom/commit/6e4db073)
- Add the Headless section to the README [Commit](https://github.com/mishka-group/mishka_chelekom/commit/c23668dc)
- Tighten all 116 usage rules, fix the Kit doc, bump versions and add the v0.0.9 roadmap [Commit](https://github.com/mishka-group/mishka_chelekom/commit/080e90fd)
- Shorten every usage rule [Commit](https://github.com/mishka-group/mishka_chelekom/commit/f6f8594f)

### Bugs:

- Fix missing `component_prefix` in components [Commit](https://github.com/mishka-group/mishka_chelekom/commit/fc2e7edc)
- Fix Tabs not showing a pointer cursor on hover over tab triggers [#491](https://github.com/mishka-group/mishka_chelekom/pull/491)
- Fix avatar not forwarding standard `img` attributes (`alt`, `srcset`, `loading`, `width`…) via `:global` include [Commit](https://github.com/mishka-group/mishka_chelekom/commit/e08098c1)
- Fix Elixir 1.20 type-checker warnings in stepper and table_content [Commit](https://github.com/mishka-group/mishka_chelekom/commit/bb94d8f8)
- Fix dev harness headless CSS copy drifting from the `priv` source [Commit](https://github.com/mishka-group/mishka_chelekom/commit/9ccaf8d1)
- Fix `--cms` export shipping no examples for 53 of 136 components: the form components' docs pages were never vendored, nested-only components (`card_title`, `td`, `progress_section`…) were skipped by the extractor, and the literal-only filter discarded every snippet that referenced a demo assign (`pagination` harvested 111 examples and shipped 0)
- Fix `DemoHarness` not passing `extra.clauses`, `extra.prelude` and `extra.module_attributes` to the component compiler, so every multi-clause component was compiled from its first clause only and guarded clauses were never exercised
- Fix component compiler dropping multi-clause guards, which made all nine form-field components raise `FunctionClauseError` on render with their default `floating` value

# Changelog for MishkaChelekom 0.0.9

### Features:

- Add Components prefix name in CLI and config file [#454](https://github.com/mishka-group/mishka_chelekom/pull/454)
- Add Module prefix name in CLI and config file [#459](https://github.com/mishka-group/mishka_chelekom/pull/459)
- Add `--no-save` flag to control prefix config saving [#459](https://github.com/mishka-group/mishka_chelekom/pull/459)
- Add Usage rules for all components and JS Hooks [#461](https://github.com/mishka-group/mishka_chelekom/pull/461)
- Add uninstall Mix task and its tests [#464](https://github.com/mishka-group/mishka_chelekom/pull/464)
- Add Entry-level MCP for Mishka Chelekom components, docs and CLIs [#466](https://github.com/mishka-group/mishka_chelekom/pull/466)
- Add server push event for `Combobox` component [Issue with help](https://github.com/mishka-group/mishka_chelekom/issues/440)
- Add `Disabled State`, `Half-Star Precision`, `Form integration` into rating component [Issue with help](https://github.com/mishka-group/mishka_chelekom/issues/474)
- Add dock (bottom-navigation) component [Issue with help](https://github.com/mishka-group/mishka_chelekom/issues/470 )
- Add Shape component
- Add Stat component
- Add harness demo driven kit test for dynamic CMS generator (Private APIs) [#479](https://github.com/mishka-group/mishka_chelekom/pull/479)
- Add stdio transport + mix mishka.mcp.setup --stdio [Issue with help](https://github.com/mishka-group/mishka_chelekom/issues/#480)
- Add entry-level headless components ported from Base UI for Phoenix [#489](https://github.com/mishka-group/mishka_chelekom/pull/489)
- Add creatable option support to Combobox component [Commit](https://github.com/mishka-group/mishka_chelekom/commit/f3fd81fd08b3f577a15d8085dafb0cbd708df5ee)
- Add scrollable trigger list (`scroll_area`) for Tabs in vertical orientation [Issue with help](https://github.com/mishka-group/mishka_chelekom/issues/471)
- Add `--headless` flag to `mix mishka.ui.uninstall` and make `--all` remove both styled and headless components
- Add `MishkaChelekom.Kit` — a Spark DSL (`customize`/`from`) to reuse and restyle existing styled and headless components without editing their files
- Add `mix mishka.ui.gen.kit` to vendor the Kit engine into your app (self-contained catalog + `spark` dep), so the Kit works in production with no `mishka_chelekom` runtime dependency


### Refactors:

- Refactor accordion to auto-generate item IDs (Explicit and open dynamic identifiers) [Commit](https://github.com/mishka-group/mishka_chelekom/commit/41a9f87d896c3524ce60826d5436ee14efacfb83) and [Issue with help](https://github.com/mishka-group/mishka_chelekom/issues/443#issuecomment-3529762821)
- Change `:class` attr type from `:string` to `:any` in components [Commit](https://github.com/mishka-group/mishka_chelekom/commit/dc4d66b52ad7703524a4057346b574fbf72992f0)
- Refactor server-render active state so it works on static mount and reacts to assign changes [Issue with help](https://github.com/mishka-group/mishka_chelekom/issues/476) - [Issue with help](https://github.com/mishka-group/mishka_chelekom/issues/472)
- Refactor generators and asset handling for the headless CLI, with unified per-command banners and improved headless CSS import [Commit](https://github.com/mishka-group/mishka_chelekom/commit/3f873a5bff4de148d0f4305cd3857c4e72c6a06a)
- Bump minimum Elixir to 1.18 and add compile-time `JSON`/`Jason` fallback [Commit](https://github.com/mishka-group/mishka_chelekom/commit/2c771d52e3abbf2c9af72f079143ad16e6c0b777)
- Refactor uninstall to restore `CoreComponents` import [#465](https://github.com/mishka-group/mishka_chelekom/pull/465)
- Center the banner subtitle and give every mix task its own title
- Add a consistent Owl loading spinner to every Igniter mix task (`export`, `gen.component`, `gen.headless`, `gen.kit`, `css.config`, `assets.deps`, `mcp.setup`)

### Bugs:

- Remove stopPropagation from Floating hook to allow phx-click event bubbling [Commit](https://github.com/mishka-group/mishka_chelekom/commit/4a62be5142767c3b2977619614a5fa40e835b1bb) and [Issue with help](https://github.com/mishka-group/mishka_chelekom/issues/448#issuecomment-3529933709)
- Fix menu `sub_items` and sidebar `hide_position` crashes [Issue with help](https://github.com/mishka-group/mishka_chelekom/issues/467)
- Use native browser date picker icons and remove custom calendar icon [Issue with help](https://github.com/mishka-group/mishka_chelekom/issues/442)
- Fix Misplaced dropdown when content has min-width [Issue with help](https://github.com/mishka-group/mishka_chelekom/issues/447)
- Fix some missing lables conditions [#469](https://github.com/mishka-group/mishka_chelekom/pull/469)
- Fix CSS typos, wrong border classes, swapped docs, and Gettext template bug [#468](https://github.com/mishka-group/mishka_chelekom/pull/468)
- Delete dead label code from fieldset component
- Fix readd floating content back to original parent before update[#475](https://github.com/mishka-group/mishka_chelekom/pull/475)
- Fix MCP runtime error [Commit](https://github.com/mishka-group/mishka_chelekom/commit/c30039e753a6581a5d910120040bf9cc95837d0b)
- Update and fix version conflict with other Mishka Project [Commit](https://github.com/mishka-group/mishka_chelekom/commit/c30039e753a6581a5d910120040bf9cc95837d0b)
- Fix Only use `Owl.Spinner` when TTY available [#477](https://github.com/mishka-group/mishka_chelekom/issues/477)
- Fix dropdown content slot class attribute concatenation [Commit](https://github.com/mishka-group/mishka_chelekom/commit/be96e764b24d0e854c303480f6afeee086ccba51)
- Fix Combobox field attribute not sending values to form params [Commit](https://github.com/mishka-group/mishka_chelekom/commit/903f2204ff51ca1a43d8b89b06146ddf93166c78)
- Fix Elixir 1.19 and `not ... in ...` deprecation warnings [Commit](https://github.com/mishka-group/mishka_chelekom/commit/b545a40b8f663355e172b048886b28e5bcd4813b)
- Fix false cross-kind dependency warning when uninstalling a headless component that shares a name with a styled one
- Fix uninstall `--all` component discovery for path and umbrella dependencies
- Fix `:owl` application not started before the spinner in `mix mishka.ui.gen.headless.components`
- Fix active mode of Outline Radio Card and Checkbox Card [#488](https://github.com/mishka-group/mishka_chelekom/issues/488) [#481](https://github.com/mishka-group/mishka_chelekom/issues/481)
- Fix `show_checkbox` prop not applying in Checkbox Card and Radio Card [#487](https://github.com/mishka-group/mishka_chelekom/issues/487)
- Fix component colors and gradients across form and menu components, including `form_wrapper` default variant/color/border and `mega_menu` gradient rendering [#485](https://github.com/mishka-group/mishka_chelekom/issues/485)
- Align component catalog (`.exs`) variant and color lists with their implementations (`unbordered`→`bordered`, `gradeint`→`gradient`, corrupted color token, missing `table`/`tabs` variants) [Commit](https://github.com/mishka-group/mishka_chelekom/commit/723800d122953268fd360aaca5fd1d30f2c5470c)
- Fix Combobox dropdown color not matching the selected variant/color and theme the option highlight to follow the chosen color [Commit](https://github.com/mishka-group/mishka_chelekom/commit/1a5a27ada84caec3643ab96c4034569c86d332ef)
- Migrate remaining Tailwind v3 utilities to v4 (video track captions, opacity, flex-shrink) [#486](https://github.com/mishka-group/mishka_chelekom/issues/486)
- Fix `color_field` `circle` option having no effect and migrate it to Tailwind v4 [#483](https://github.com/mishka-group/mishka_chelekom/issues/483)

### Tests:

- Add retire-js and semgrep security scanning [#460](https://github.com/mishka-group/mishka_chelekom/pull/460)
- Add Elixir 1.20.2 (OTP 29) to the CI test matrix [Commit](https://github.com/mishka-group/mishka_chelekom/commit/6197ccf8aa6668be213074e08846ed88922cd2f7)
- Add direct end-to-end tests for every mix command in the development harness

---


# Changelog for MishkaChelekom 0.0.8

### Refactors:

- Update to Tailwind 4 phoenix 1.8 and new cli options for 0.0.8 [#439](https://github.com/mishka-group/mishka_chelekom/pull/439)
- Update dependencies
- Update IgniterJS source [#40](https://github.com/ash-project/igniter_js/pull/40)
- Update IgniterCss (but not using in this version, still we have some problems) [#14](https://github.com/ash-project/igniter_css/pull/14)
- Improve `floating.js` to accept update request and better UX
- Refactor Tooltip and Popover components
- Refactor Combobox component

### Features:

- Add `mix mishka.ui.css.config`
- Add CSS file to have all components colors and another configs
- Add Config file to override default configs (for example custom css)
- Add simple CSS utilities helper and delete IgniterCss for this version
- Add exclude components option for `mix mishka.ui.gen.components`
- Add Collapse component
- Add Collapsible JS Hook
- Add Github action for testing

### Tests:

- Add unit tests for `mix mishka.assets.deps`
- Add unit tests for `mix mishka.assets.install`
- Add unit tests for `mix mishka.ui.add`
- Add unit tests for `mix mishka.ui.css.config`
- Add unit tests for `mix mishka.ui.export`
- Add unit tests for `mix mishka.ui.gen.component/components`

### Bugs:

- Fix some bugs of `mix mishka.ui.add` and `mix mishka.ui.export`
- Fix some problems of new changes of Phoenix and LiveView
- Fix typos
- Fix Owl error conflict version with Ash generator [Discord](https://discord.com/channels/711271361523351632/1414489258667802674)
- Fix duplicated IDs in `dropdown` component
- Fix installation issues of Ash Igniter

---

# Changelog for MishkaChelekom 0.0.7

### Refactors:

- Flash group restriction for Phoenix version 1.8 [#424](https://github.com/mishka-group/mishka_chelekom/pull/424)


---

# Changelog for MishkaChelekom 0.0.6

### Features:

- Add install version of `mishka.assets.deps` mix command [#413](https://github.com/mishka-group/mishka_chelekom/pull/413)
- Add remove JS package for `mix mishka.assets.deps` cli [#414](https://github.com/mishka-group/mishka_chelekom/pull/414)

### Bugs:

- Add temporary patch for fixing Phoenix 1.8 Flash group

---

# Changelog for MishkaChelekom 0.0.5

### Features:

- Add layouts flex and grid components [#330](https://github.com/mishka-group/mishka_chelekom/pull/330)
- Add filterable gallery to the Gallery component [#332](https://github.com/mishka-group/mishka_chelekom/pull/332)
- Add Circular and Semicircle Progress bar to progress component [#333](https://github.com/mishka-group/mishka_chelekom/pull/333)
- Add support for fractional values to the rating component [#334](https://github.com/mishka-group/mishka_chelekom/pull/334)
- Add tooltip to progress section [#335](https://github.com/mishka-group/mishka_chelekom/pull/335)
- Add Clipboard component and hook integration [#337](https://github.com/mishka-group/mishka_chelekom/pull/337)
- Add ability to to Minimize and Maximize Sidebar [#339](https://github.com/mishka-group/mishka_chelekom/pull/339)
- Adding basic accessibility support to all components

### Refactors:

- Fix Dropdown Bugs and Enhance Dynamic Behavior [#328](https://github.com/mishka-group/mishka_chelekom/pull/328)
- Add conditional styling to divider and buttons [#329](https://github.com/mishka-group/mishka_chelekom/pull/329)
- Add Custom Hook, Loading State, and Bug Fixes of Carousel Component [#336](https://github.com/mishka-group/mishka_chelekom/pull/336)
- Replace custom icon functions with shared icon component [#338](https://github.com/mishka-group/mishka_chelekom/pull/338)
- Implement Toast and Alert components to support z-index prop [#399](https://github.com/mishka-group/mishka_chelekom/pull/399)
- Update Igniter to last version


---

# Changelog for MishkaChelekom 0.0.4

### Bugs:

- Fix Stepper icon display issue [#338](https://github.com/mishka-group/mishka_chelekom/pull/338)

### Features:

- Add on_select attribute on tab slot
- Add scroll area component [#296](https://github.com/mishka-group/mishka_chelekom/pull/296) [#300](https://github.com/mishka-group/mishka_chelekom/pull/300)
- Add missing features of Phoenix core components [#296](https://github.com/mishka-group/mishka_chelekom/pull/296)
- Add global components installing support and JS formatter [#304](https://github.com/mishka-group/mishka_chelekom/pull/304)
- Add radio card component [#305](https://github.com/mishka-group/mishka_chelekom/pull/305)
- Add checkbox card component [#306](https://github.com/mishka-group/mishka_chelekom/pull/306)
- Add combobox component [#321](https://github.com/mishka-group/mishka_chelekom/pull/321)

### Bugs:

- Add missing slot to gallery component [#294](https://github.com/mishka-group/mishka_chelekom/pull/294)
- fix typo in tab, checkbox field, radio field components [#295](https://github.com/mishka-group/mishka_chelekom/pull/295)
- Fix missing ids in table and Flash assign_new to create new id from pattern [#313](https://github.com/mishka-group/mishka_chelekom/pull/313)
- Fix color and variants functions of stepper component [#338](https://github.com/mishka-group/mishka_chelekom/pull/338)

### Refactors:

- Refactor some Phoenix CoreComponent backward compatibility issues for Ash [#312](https://github.com/mishka-group/mishka_chelekom/pull/312)
- Refactor and Use more generous dependency on igniter [#317](https://github.com/mishka-group/mishka_chelekom/pull/317)
- Reset line height of alert [#320](https://github.com/mishka-group/mishka_chelekom/pull/320)
- Skipping Color in the Base Variant [#322](https://github.com/mishka-group/mishka_chelekom/pull/322)
- Fix color of radio and checkbox fields [#324](https://github.com/mishka-group/mishka_chelekom/pull/324)

---

# Changelog for MishkaChelekom 0.0.3

### Features:

- Support JS community cli version (beta) [#254](https://github.com/mishka-group/mishka_chelekom/pull/254)
- Support Export community cli version (beta) [#256](https://github.com/mishka-group/mishka_chelekom/pull/256)
- Add paddings and width fit to alert [#287](https://github.com/mishka-group/mishka_chelekom/pull/287)
- Add badge to tab component [#290](https://github.com/mishka-group/mishka_chelekom/pull/290)
- Add Igniter installer mix task

### Bugs:

- Fix alert title type [#288](https://github.com/mishka-group/mishka_chelekom/pull/288)
- Fix some issues about windows PowerShell

---

# Changelog for MishkaChelekom 0.0.2

### Features:

- Support community cli version (beta) [#92](https://github.com/mishka-group/mishka_chelekom/pull/92)
- Supports cli helpers import [#93](https://github.com/mishka-group/mishka_chelekom/pull/93)
- Update all templates for new syntax `{}` (Phoenix LiveView 1.0.0)

### Refactors:

- Fix Adjust spacing for checkbox and radio fields [#73](https://github.com/mishka-group/mishka_chelekom/pull/73)
- Add dark mode and fix issues of gradient variants of Button component [#91](https://github.com/mishka-group/mishka_chelekom/pull/91)
- Add dark mode and fix issues of gradient variants of Badge component [#94](https://github.com/mishka-group/mishka_chelekom/pull/94)
- Add dark mode and fix issues of Overlay of Drawer component [#96](https://github.com/mishka-group/mishka_chelekom/pull/96)
- Add dark mode of Divider component [#97](https://github.com/mishka-group/mishka_chelekom/pull/97)
- Add dark mode of Avatar component [#98](https://github.com/mishka-group/mishka_chelekom/pull/98)
- Add dark mode of Alert component [#99](https://github.com/mishka-group/mishka_chelekom/pull/99)
- Add dark mode of Spinner component [#100](https://github.com/mishka-group/mishka_chelekom/pull/100)
- Add dark mode of Banner component [#101](https://github.com/mishka-group/mishka_chelekom/pull/101)
- Add dark mode of Breadcrumb component [#102](https://github.com/mishka-group/mishka_chelekom/pull/102)
- Add dark mode of Blockquote component [#103](https://github.com/mishka-group/mishka_chelekom/pull/103)
- Add dark mode of Dropdown component [#104](https://github.com/mishka-group/mishka_chelekom/pull/104)
- Add dark mode of Overlay component [#106](https://github.com/mishka-group/mishka_chelekom/pull/106)
- Add dark mode of Card component [#107](https://github.com/mishka-group/mishka_chelekom/pull/107)
- Add dark mode and add `show_arrow` prop of Popover component [#121](https://github.com/mishka-group/mishka_chelekom/pull/121)
- Add dark mode of Rating component [#123](https://github.com/mishka-group/mishka_chelekom/pull/123)
- Add dark mode of Chat component [#125](https://github.com/mishka-group/mishka_chelekom/pull/125)
- Add dark mode of Modal component [#126](https://github.com/mishka-group/mishka_chelekom/pull/126)
- Add dark mode of Keyboard component [#127](https://github.com/mishka-group/mishka_chelekom/pull/127)
- Add dark mode of Jumbotron component [#128](https://github.com/mishka-group/mishka_chelekom/pull/128)
- Add dark mode of Indicator component [#129](https://github.com/mishka-group/mishka_chelekom/pull/129)
- Add dark mode of Carousel component [#130](https://github.com/mishka-group/mishka_chelekom/pull/130)
- Add dark mode of Footer component [#132](https://github.com/mishka-group/mishka_chelekom/pull/132)
- Add dark mode of MegaMenu component [#133](https://github.com/mishka-group/mishka_chelekom/pull/133)
- Add dark mode of Navbar component [#134](https://github.com/mishka-group/mishka_chelekom/pull/134)
- Add dark mode of Progress component [#136](https://github.com/mishka-group/mishka_chelekom/pull/136)
- Add dark mode of email, url, search, number, password, textarea, tel, text fields components [#138](https://github.com/mishka-group/mishka_chelekom/pull/138)
- Add dark mode of FormWrapper component [#140](https://github.com/mishka-group/mishka_chelekom/pull/140)
- Add dark mode of RadioField component [#143](https://github.com/mishka-group/mishka_chelekom/pull/143)
- Add dark mode of CheckboxField component [#144](https://github.com/mishka-group/mishka_chelekom/pull/144)
- Add dark mode of Sidebar component [#145](https://github.com/mishka-group/mishka_chelekom/pull/145)
- Add dark mode of DateTimeField component [#146](https://github.com/mishka-group/mishka_chelekom/pull/146)
- Add dark mode of Tooltip component [#147](https://github.com/mishka-group/mishka_chelekom/pull/147)
- Add dark mode of Video component [#148](https://github.com/mishka-group/mishka_chelekom/pull/148)
- Add dark mode of Typography component [#149](https://github.com/mishka-group/mishka_chelekom/pull/149)
- Add dark mode of ToggleField component [#150](https://github.com/mishka-group/mishka_chelekom/pull/150)
- Add dark mode of SpeedDial component [#151](https://github.com/mishka-group/mishka_chelekom/pull/151)
- Add dark mode of Skeleton component [#152](https://github.com/mishka-group/mishka_chelekom/pull/152)
- Add dark mode of TableOfContent component [#153](https://github.com/mishka-group/mishka_chelekom/pull/153)
- Add dark mode of Timeline component [#154](https://github.com/mishka-group/mishka_chelekom/pull/154)
- Add dark mode of Table component [#155](https://github.com/mishka-group/mishka_chelekom/pull/155)
- Add dark mode of Tabs component [#156](https://github.com/mishka-group/mishka_chelekom/pull/156)
- Add dark mode of NativeSelect component [#158](https://github.com/mishka-group/mishka_chelekom/pull/158)
- Add dark mode of RangeField component [#159](https://github.com/mishka-group/mishka_chelekom/pull/159)
- Add dark mode of Toast component [#160](https://github.com/mishka-group/mishka_chelekom/pull/160)
- Add dark mode of List component [#161](https://github.com/mishka-group/mishka_chelekom/pull/161)
- Add dark mode of Fieldset component [#162](https://github.com/mishka-group/mishka_chelekom/pull/162)
- Add dark mode of FileField component [#163](https://github.com/mishka-group/mishka_chelekom/pull/163)
- Add dark mode of Stepper component [#165](https://github.com/mishka-group/mishka_chelekom/pull/165)
- Add dark mode of Accordion component [#166](https://github.com/mishka-group/mishka_chelekom/pull/166)
- Add dark mode of DeviceMockup component [#167](https://github.com/mishka-group/mishka_chelekom/pull/167)
- Add dark mode of pagination component [#168](https://github.com/mishka-group/mishka_chelekom/pull/168)
- Add full width to button [#170](https://github.com/mishka-group/mishka_chelekom/pull/170)
- Add filter props to image component [#171](https://github.com/mishka-group/mishka_chelekom/pull/171)
- Add other line styles to timeline [#172](https://github.com/mishka-group/mishka_chelekom/pull/172)
- Add loader to slot to button component [#173](https://github.com/mishka-group/mishka_chelekom/pull/173)
- Add radius to toggle component [#174](https://github.com/mishka-group/mishka_chelekom/pull/174)
- Add space based on sizes to pagination component [#175](https://github.com/mishka-group/mishka_chelekom/pull/175)
- Add label slot to each chunk of progress [#176](https://github.com/mishka-group/mishka_chelekom/pull/176)
- Add separated variant to table [#178](https://github.com/mishka-group/mishka_chelekom/pull/178)
- Refactor: Fix issue of zooming inputs [#185](https://github.com/mishka-group/mishka_chelekom/pull/185)
- Modify structure of popover and dropdown components [#189](https://github.com/mishka-group/mishka_chelekom/pull/189)
- Add animations to gallery [#190](https://github.com/mishka-group/mishka_chelekom/pull/190)
- Stop spinner when an image is in done [#194](https://github.com/mishka-group/mishka_chelekom/pull/194)
- Modify styles of form fields, add new prop to badge [#192](https://github.com/mishka-group/mishka_chelekom/pull/192)
- Modify card and overlay components styles [#193](https://github.com/mishka-group/mishka_chelekom/pull/193)
- Modify table content component [#195](https://github.com/mishka-group/mishka_chelekom/pull/195)
- Add variant to stepper, add loading state to stepper [#196](https://github.com/mishka-group/mishka_chelekom/pull/196)
- add hoverable prop to listdd [#197](https://github.com/mishka-group/mishka_chelekom/pull/197)
- Add classes to badge [#257](https://github.com/mishka-group/mishka_chelekom/pull/257)
- Add new styles to tabs [#273](https://github.com/mishka-group/mishka_chelekom/pull/273)
- change structure of tooltip [#277](https://github.com/mishka-group/mishka_chelekom/pull/277)
- Add and remove unnecessary classes textarea field [#276](https://github.com/mishka-group/mishka_chelekom/pull/276)
- Add and remove unnecessary classes text field [#275](https://github.com/mishka-group/mishka_chelekom/pull/275)
- Add and remove unnecessary classes tel field [#274](https://github.com/mishka-group/mishka_chelekom/pull/274)
- Add new variants to table [#272](https://github.com/mishka-group/mishka_chelekom/pull/272)
- Change styles in stepper [#271](https://github.com/mishka-group/mishka_chelekom/pull/271)
- Add and remove unnecessary classes of search [#270](https://github.com/mishka-group/mishka_chelekom/pull/270)
- Add line height class to rating button [#269](https://github.com/mishka-group/mishka_chelekom/pull/269)
- Change styles of progress [#268](https://github.com/mishka-group/mishka_chelekom/pull/268)
- Change structure of popover [#267](https://github.com/mishka-group/mishka_chelekom/pull/267)
- Add and remove unnecessary classes number field [#265](https://github.com/mishka-group/mishka_chelekom/pull/265)
- Add new props and fix color issues, remove extra functions from list [#263](https://github.com/mishka-group/mishka_chelekom/pull/263)
- Add and remove unnecessary classes from email field [#261](https://github.com/mishka-group/mishka_chelekom/pull/261)
- Add and remove unnecessary classes from date field [#260](https://github.com/mishka-group/mishka_chelekom/pull/260)
- change chat section styles [#259](https://github.com/mishka-group/mishka_chelekom/pull/259)
- Add new prop to card media [#258](https://github.com/mishka-group/mishka_chelekom/pull/258)

### Bugs:

- Fix un-CSP progress mounted [#72](https://github.com/mishka-group/mishka_chelekom/pull/72)
- Fix modal title `default: nil` value [#76](https://github.com/mishka-group/mishka_chelekom/pull/76)
- Correct typo separated across the project [#81](https://github.com/mishka-group/mishka_chelekom/pull/81)
- Revision and fix some missing part of some fields (version 0.0.1) [#84](https://github.com/mishka-group/mishka_chelekom/pull/84)
- Fix without `--import` option error of components task CLI [b0b7492](https://github.com/mishka-group/mishka_chelekom/commit/b0b7492e636663d2c55d4b56a04c89b2376f422a)
- Fix issue of breadcrumb RTL mode [#170](https://github.com/mishka-group/mishka_chelekom/pull/170)
- Remove space-y-0 classes from Menu, Footer, Navbar, Tooltip components [#183](https://github.com/mishka-group/mishka_chelekom/pull/183)
- Delete none pattern functions from all components [#246](https://github.com/mishka-group/mishka_chelekom/pull/246)
- Fix issues of password field [#266](https://github.com/mishka-group/mishka_chelekom/pull/266)
- Fix issues of shadow in native select [#264](https://github.com/mishka-group/mishka_chelekom/pull/264)
- Fix style issues of fieldset [#262](https://github.com/mishka-group/mishka_chelekom/pull/262)
- Fix some global issues

---

# Changelog for MishkaChelekom 0.0.1

> We are delighted to introduce our new version of MishkaChelekom fully featured components and UI kit library for Phoenix & Phoenix LiveView.
> Kindly ensure that the MishkaChelekom Library is updated as quickly as feasible.

**For more information please see**: https://mishka.tools/chelekom

### Features:

- Add generator mix CLI task for creating component
- Add generator mix CLI task for creating components
- Add basic components (light mode version)

  <details>

    <summary>Components list</summary>

  - [x] accordion
  - [x] alert
  - [x] avatar
  - [x] badge
  - [x] banner
  - [x] blockquote
  - [x] breadcrumb
  - [x] button
  - [x] card
  - [x] carousel
  - [x] chat
  - [x] chekbox_field
  - [x] color_field
  - [x] date_time_field
  - [x] device_mockup
  - [x] divider
  - [x] drawer
  - [x] dropdown
  - [x] email_field
  - [x] fieldset
  - [x] file_field
  - [x] footer
  - [x] form_wrapper
  - [x] gallery
  - [x] image
  - [x] indicator
  - [x] input_field
  - [x] jumbotron
  - [x] keyboard
  - [x] list
  - [x] mega_menu
  - [x] menu
  - [x] modal
  - [x] native_select
  - [x] navbar
  - [x] number_field
  - [x] overlay
  - [x] pagination
  - [x] password_field
  - [x] popover
  - [x] progress
  - [x] radio_field
  - [x] range_field
  - [x] rating
  - [x] search_field
  - [x] sidebar
  - [x] skeleton
  - [x] speed_dial
  - [x] spinner
  - [x] stepper
  - [x] table
  - [x] table_content
  - [x] tabs
  - [x] tel_field
  - [x] text_field
  - [x] textarea_field
  - [x] timeline
  - [x] toast
  - [x] toggle_field
  - [x] tooltip
  - [x] typography
  - [x] url_field
  - [x] video

  </details>

- Add white primary secondary dark success warning danger info light misc dawn colors
- Add common sizes
- Add common variants
- Add common positions

### Docs

- Add generator docs
- Add basic components docs
