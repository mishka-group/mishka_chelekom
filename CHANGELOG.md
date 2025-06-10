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
