# Changelog for MishkaChelekom 0.0.2

### Features:
- Support community cli version (beta) [#92](https://github.com/mishka-group/mishka_chelekom/pull/92)
- Supports cli helpers import [#93](https://github.com/mishka-group/mishka_chelekom/pull/93)

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


### Bugs:
- Fix un-CSP progress mounted [#72](https://github.com/mishka-group/mishka_chelekom/pull/72)
- Fix modal title `default: nil` value [#76](https://github.com/mishka-group/mishka_chelekom/pull/76)
- Correct typo separated across the project [#81](https://github.com/mishka-group/mishka_chelekom/pull/81)
- Revision and fix some missing part of some fields (version 0.0.1) [#84](https://github.com/mishka-group/mishka_chelekom/pull/84)
- Fix without `--import` option error of components task CLI [b0b7492](https://github.com/mishka-group/mishka_chelekom/commit/b0b7492e636663d2c55d4b56a04c89b2376f422a)


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
