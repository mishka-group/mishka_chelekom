defmodule DevelopmentWeb.Showcase.HeadlessDaisyUIExamples do
  @moduledoc """
  The same headless components as `HeadlessBaseUIExamples`, wearing the daisyUI skin.

  Each component's page mirrors its page on daisyui.com example for example, so you can put the two
  side by side. Two kinds of example live here:

    * the **hero**, which passes no styling classes at all — the skin installed by
      `mix mishka.ui.gen.headless <name> --skin daisyui` paints every part from the
      `chelekom-<name>__<part>` classes and `data-*` state the component already emits;
    * the **variants** (sizes, colors, styles), which add daisyUI's own modifier classes through the
      per-part class attributes. That is the documented escape hatch, and it is how a variant stays
      pixel-exact instead of being re-implemented.

  Behavior, ARIA and keyboard handling are identical to the Base UI gallery in every one of them —
  only the paint differs.
  """
  use Phoenix.Component

  alias DevelopmentWeb.Showcase.ExampleSource
  alias Phoenix.LiveView.JS

  import DevelopmentWeb.Components.Headless.Accordion
  import DevelopmentWeb.Components.Headless.Avatar
  import DevelopmentWeb.Components.Headless.SemiCircleProgress
  import DevelopmentWeb.Components.Headless.OtpField
  import DevelopmentWeb.Components.Headless.Fieldset
  import DevelopmentWeb.Components.Headless.Drawer
  import DevelopmentWeb.Components.Headless.Alert
  import DevelopmentWeb.Components.Headless.Anchor
  import DevelopmentWeb.Components.Headless.Button
  import DevelopmentWeb.Components.Headless.Toggle
  import DevelopmentWeb.Components.Headless.NavLink
  import DevelopmentWeb.Components.Headless.LoadingOverlay
  import DevelopmentWeb.Components.Headless.Field
  import DevelopmentWeb.Components.Headless.Code
  import DevelopmentWeb.Components.Headless.Checkbox
  import DevelopmentWeb.Components.Headless.Toast
  import DevelopmentWeb.Components.Headless.Collapsible
  import DevelopmentWeb.Components.Headless.Dialog
  import DevelopmentWeb.Components.Headless.Menu
  import DevelopmentWeb.Components.Headless.Pill
  import DevelopmentWeb.Components.Headless.Progress
  import DevelopmentWeb.Components.Headless.Slider
  import DevelopmentWeb.Components.Headless.Separator
  import DevelopmentWeb.Components.Headless.Radio
  import DevelopmentWeb.Components.Headless.RadioGroup
  import DevelopmentWeb.Components.Headless.ActionIcon
  import DevelopmentWeb.Components.Headless.CloseButton
  import DevelopmentWeb.Components.Headless.Chip
  import DevelopmentWeb.Components.Headless.Burger
  import DevelopmentWeb.Components.Headless.Spoiler
  import DevelopmentWeb.Components.Headless.SegmentedControl
  import DevelopmentWeb.Components.Headless.ToggleGroup
  import DevelopmentWeb.Components.Headless.AlphaSlider
  import DevelopmentWeb.Components.Headless.AngleSlider
  import DevelopmentWeb.Components.Headless.HueSlider
  import DevelopmentWeb.Components.Headless.AlertDialog
  import DevelopmentWeb.Components.Headless.Autocomplete
  import DevelopmentWeb.Components.Headless.Chart
  import DevelopmentWeb.Components.Headless.CheckboxGroup
  import DevelopmentWeb.Components.Headless.ColorInput
  import DevelopmentWeb.Components.Headless.ColorPicker
  import DevelopmentWeb.Components.Headless.ColorSwatch
  import DevelopmentWeb.Components.Headless.Combobox
  import DevelopmentWeb.Components.Headless.ContextMenu
  import DevelopmentWeb.Components.Headless.Editor
  import DevelopmentWeb.Components.Headless.EmptyState
  import DevelopmentWeb.Components.Headless.FloatingIndicator
  import DevelopmentWeb.Components.Headless.FloatingWindow
  import DevelopmentWeb.Components.Headless.Highlight
  import DevelopmentWeb.Components.Headless.JsonInput
  import DevelopmentWeb.Components.Headless.Mark
  import DevelopmentWeb.Components.Headless.Marquee
  import DevelopmentWeb.Components.Headless.MaskInput
  import DevelopmentWeb.Components.Headless.Menubar
  import DevelopmentWeb.Components.Headless.Meter
  import DevelopmentWeb.Components.Headless.NavigationMenu
  import DevelopmentWeb.Components.Headless.NumberField
  import DevelopmentWeb.Components.Headless.NumberFormatter
  import DevelopmentWeb.Components.Headless.OverflowList
  import DevelopmentWeb.Components.Headless.PillsInput
  import DevelopmentWeb.Components.Headless.Popover
  import DevelopmentWeb.Components.Headless.PreviewCard
  import DevelopmentWeb.Components.Headless.RollingNumber
  import DevelopmentWeb.Components.Headless.ScrollArea
  import DevelopmentWeb.Components.Headless.Scroller
  import DevelopmentWeb.Components.Headless.Sparkline
  import DevelopmentWeb.Components.Headless.Splitter
  import DevelopmentWeb.Components.Headless.TagsInput
  import DevelopmentWeb.Components.Headless.ThemeIcon
  import DevelopmentWeb.Components.Headless.Toolbar
  import DevelopmentWeb.Components.Headless.Tree
  import DevelopmentWeb.Components.Headless.TreeSelect
  import DevelopmentWeb.Components.Headless.VisuallyHidden
  import DevelopmentWeb.Components.Headless.Select
  import DevelopmentWeb.Components.Headless.Switch
  import DevelopmentWeb.Components.Headless.Tabs
  import DevelopmentWeb.Components.Headless.Tooltip
  import DevelopmentWeb.Components.Headless.TextInput
  import DevelopmentWeb.Components.Headless.Textarea
  import DevelopmentWeb.Components.Headless.FileInput
  import DevelopmentWeb.Components.Headless.Card
  import DevelopmentWeb.Components.Headless.Breadcrumb
  import DevelopmentWeb.Components.Headless.Stepper
  import DevelopmentWeb.Components.Headless.Dock
  import DevelopmentWeb.Components.Headless.Pagination
  import DevelopmentWeb.Components.Headless.Rating
  import DevelopmentWeb.Components.Headless.Countdown
  import DevelopmentWeb.Components.Headless.ThemeController
  import DevelopmentWeb.Components.Headless.Fab
  import DevelopmentWeb.Components.Headless.Table
  import DevelopmentWeb.Components.Headless.Carousel
  import DevelopmentWeb.Components.Headless.Calendar
  import DevelopmentWeb.Components.Headless.RadioGroup

  @faq [
    {"What is a skin?",
     "A stylesheet that paints the classes and data-attributes the headless component already emits. It never touches markup, ARIA or behavior."},
    {"Does it change the component?",
     "No. The same generated module renders both galleries — only the stylesheet differs, so keyboard navigation and screen-reader semantics are identical."},
    {"Can I still use utility classes?",
     "Yes. Every per-part class attribute still applies on top, so you can override any part the skin paints."}
  ]

  @face "https://images.unsplash.com/photo-1543610892-0b1f7e6d8ac1?w=128&h=128&fit=crop&crop=faces&dpr=2&q=80"

  @colors ~w(primary secondary accent neutral info success warning error)
  @sizes ~w(xs sm md lg xl)

  @sections %{
    "accordion" => [
      {"accordion-hero", "Accordion",
       "daisyUI's `collapse` with the arrow icon, joined into one bordered box. No styling classes in the markup — the skin draws the border, radii, padding and the rotating arrow."},
      {"accordion-multiple", "Multiple open",
       "daisyUI's `details` accordion lets several panels stay open; ours is the `multiple` attribute."},
      {"accordion-plus", "Plus / minus icon",
       "daisyUI's `collapse-plus`. Our accordion has a real `:trigger_icon` slot, so the skin steps aside and lets the icon rotate on `data-panel-open`."},
      {"accordion-separated", "Not joined",
       "daisyUI's plain `collapse` boxes, before `join` merges them — each item its own bordered card."}
    ],
    "select" => [
      {"select-hero", "Select",
       "daisyUI's `select` on the trigger and `menu` on the listbox, arrow and radii from the active theme."},
      {"select-ghost", "Ghost", "daisyUI's `select-ghost` — no background until focus."},
      {"select-colors", "Colors", "All eight `select-*` colors."},
      {"select-sizes", "Sizes", "`select-xs` through `select-xl`."},
      {"select-disabled", "Disabled", "The disabled trigger, plus a per-option disabled row."},
      {"select-grouped", "Grouped",
       "Options split into labelled groups, each label painted as a daisyUI menu title."},
      {"select-multiple", "Multiple",
       "A multi-select that stays open, with the daisyUI menu-active treatment on every chosen row."},
      {"select-form", "With fieldset and label",
       "Inside a real form next to a daisyUI button — submitting echoes the value the hidden input carried."}
    ],
    "switch" => [
      {"switch-hero", "Toggle",
       "daisyUI's `toggle`: the track is the box, the knob its ::before."},
      {"switch-sizes", "Sizes", "`toggle-xs` through `toggle-xl`."},
      {"switch-colors", "Colors", "All eight `toggle-*` colors."},
      {"switch-disabled", "Disabled", "On and off, both disabled."},
      {"switch-icons", "Toggle with icons inside",
       "daisyUI puts two icons on the knob and cross-fades them; our switch grew `:on_icon` / `:off_icon` slots so the skin can do the same."},
      {"switch-custom-colors", "Custom colors",
       "daisyUI's custom-color recipe, with `data-checked` standing in for `:checked`."},
      {"switch-form", "With fieldset and label",
       "Three toggles in a fieldset, submitted as real form fields."}
    ],
    "checkbox" => [
      {"checkbox-hero", "Checkbox",
       "daisyUI's `checkbox`: the indicator is the box and the tick is daisyUI's own clip-path."},
      {"checkbox-form", "With fieldset and label",
       "A checkbox group in a fieldset, submitted as real form fields."},
      {"checkbox-sizes", "Sizes", "`checkbox-xs` through `checkbox-xl`."},
      {"checkbox-colors", "Colors", "All eight `checkbox-*` colors."},
      {"checkbox-disabled", "Disabled", "Checked and unchecked, both disabled."},
      {"checkbox-indeterminate", "Indeterminate",
       "daisyUI needs JavaScript to set `.indeterminate`; ours is a server-rendered attribute."},
      {"checkbox-custom-colors", "Checkbox with custom colors",
       "daisyUI's custom-color recipe, with `data-checked` standing in for `:checked`."}
    ],
    "dialog" => [
      {"dialog-hero", "Dialog modal",
       "daisyUI's `modal-box` with a `modal-action` row. Dismissing on outside click is our default."},
      {"dialog-non-dismissible", "Does not close when clicked outside",
       "`dismissible={false}` — only the action buttons and Escape close it."},
      {"dialog-close-corner", "Close button at corner",
       "daisyUI's `btn btn-sm btn-circle btn-ghost` ✕, positioned by the footer part."},
      {"dialog-wide", "Custom width", "daisyUI's `w-11/12 max-w-5xl` on the popup part."},
      {"dialog-responsive", "Responsive",
       "daisyUI's `modal-bottom sm:modal-middle` — full-width sheet on mobile, centered card above `sm`."}
    ],
    "tabs" => [
      {"tabs-hero", "Tabs",
       "The skin's own row: daisyUI's `tabs-border` look, but the underline is our indicator part, so it slides and resizes."},
      {"tabs-plain", "tabs", "daisyUI's plain `tabs`, opted into with its real classes."},
      {"tabs-border", "tabs-border",
       "daisyUI's `tabs-border`, opted into with its real classes rather than drawn by the skin."},
      {"tabs-lift", "tabs-lift", "daisyUI's `tabs-lift`, including its notched corners."},
      {"tabs-box", "tabs-box", "daisyUI's `tabs-box`."},
      {"tabs-sizes", "Sizes", "`tabs-xs` through `tabs-xl` on the lift style."},
      {"tabs-bottom", "Tabs on the bottom",
       "daisyUI's `tabs-bottom` with the panel above the row."},
      {"tabs-scroll", "Horizontal scroll when there's no space",
       "daisyUI's recipe: the row keeps its natural width inside a narrow scroller."},
      {"tabs-custom-color", "Custom color",
       "daisyUI's `--tab-bg` / `--tab-border-color` recipe."},
      {"tabs-vertical", "Vertical",
       "Not a daisyUI variant — our `orientation` attribute, with the indicator on the inline edge."}
    ],
    "avatar" => [
      {"avatar-hero", "Avatar",
       "daisyUI's `avatar` box; the image only appears once it has loaded."},
      {"avatar-sizes", "Custom sizes",
       "daisyUI sizes the avatar with a width utility on the root."},
      {"avatar-rounded", "Rounded", "`rounded-xl` and `rounded-full` on the root."},
      {"avatar-mask", "With mask", "daisyUI's `mask` shapes — heart, squircle, hexagon."},
      {"avatar-group", "Avatar group", "daisyUI's `avatar-group` with a negative inline gap."},
      {"avatar-group-counter", "Group with counter",
       "The same group ending in a placeholder counting the rest."},
      {"avatar-ring", "With ring", "A `ring-primary` offset from the page background."},
      {"avatar-presence", "With presence indicator",
       "daisyUI's `avatar-online` / `avatar-offline` dot."},
      {"avatar-placeholder", "Placeholder",
       "Initials on a neutral chip — our fallback part, shown when there is no image."}
    ],
    "pill" => [
      {"pill-hero", "Badge", "daisyUI's `badge`, painted from the pill's root."},
      {"pill-sizes", "Sizes", "`badge-xs` through `badge-xl`."},
      {"pill-colors", "Colors", "All eight `badge-*` colors."},
      {"pill-soft", "Soft style", "daisyUI's `badge-soft` across the colors."},
      {"pill-outline", "Outline style", "daisyUI's `badge-outline` across the colors."},
      {"pill-dash", "Dash style", "daisyUI's `badge-dash` across the colors."},
      {"pill-neutral-variants", "Neutral, outline and dash", "The neutral badge in both styles."},
      {"pill-ghost", "Ghost", "daisyUI's `badge-ghost`."},
      {"pill-empty", "Empty", "Content-free badges at every size — a status dot."},
      {"pill-icon", "With icon", "An icon before the label inside the badge."},
      {"pill-in-text", "In a text", "Badges sized to sit inline with headings and body copy."},
      {"pill-in-button", "In a button", "A badge riding along inside a daisyUI button."},
      {"pill-removable", "Removable",
       "Not a daisyUI variant — our `with_remove` trailing button, painted to match."}
    ],
    "progress" => [
      {"progress-hero", "Progress", "daisyUI's `progress` bar at 40%."},
      {"progress-colors", "Colors",
       "All eight `progress-*` colors — each only sets `color`, and the bar is `currentColor`."},
      {"progress-values", "Values", "0, 10, 40, 70 and 100 percent."},
      {"progress-indeterminate", "Indeterminate",
       "No `value`, so the bar sweeps — daisyUI's 5s loop, driven by our `data-indeterminate`."},
      {"progress-labelled", "With a label and readout",
       "Not a daisyUI variant — our `label` and `show_value` parts, painted to match."}
    ],
    "tooltip" => [
      {"tooltip-hero", "Tooltip", "daisyUI's neutral bubble, opened on hover or focus."},
      {"tooltip-open", "Force open", "daisyUI's `tooltip-open` — our `open` attribute."},
      {"tooltip-sides", "Top, bottom, left and right",
       "daisyUI's four position classes; ours is the `side` attribute, and the engine flips it when there is no room."},
      {"tooltip-align", "Start, center and end",
       "daisyUI's `tooltip-start/center/end`; ours is the `align` attribute."},
      {"tooltip-colors", "Colors",
       "All seven `tooltip-*` colors, which set daisyUI's own `--tt-bg` so the arrow follows."},
      {"tooltip-rich", "With rich content",
       "daisyUI's `tooltip-content` for markup instead of a `data-tip` string."},
      {"tooltip-responsive", "Responsive",
       "daisyUI's `lg:tooltip` — hidden below the breakpoint, shown above it."}
    ],
    "radio" => [
      {"radio-hero", "Radio", "daisyUI's `radio`, painted from the indicator part."},
      {"radio-sizes", "Sizes", "`radio-xs` through `radio-xl`."},
      {"radio-colors", "Colors", "All eight `radio-*` colors."},
      {"radio-disabled", "Disabled", "Checked and unchecked, both disabled."},
      {"radio-custom-colors", "Custom colors",
       "daisyUI's custom-colour recipe, with `data-checked` standing in for `:checked`."},
      {"radio-group", "In a group",
       "Our `radio_group`, which owns the roving tabindex and arrow-key selection."}
    ],
    "slider" => [
      {"slider-hero", "Range", "daisyUI's `range` track, fill and thumb."},
      {"slider-steps", "With steps and measure",
       "daisyUI's stepped range, with the step marks underneath."},
      {"slider-colors", "Colors", "All eight `range-*` colors."},
      {"slider-sizes", "Sizes", "`range-xs` through `range-xl`."},
      {"slider-custom", "Custom color and no fill",
       "daisyUI's `--range-bg` / `--range-thumb` / `--range-fill` recipe. Note the `d-` — a prefixed plugin prefixes its variables too, so the recipe from the docs needs the prefix here."},
      {"slider-vertical", "Vertical",
       "daisyUI's `range-vertical`; ours is the `orientation` attribute."},
      {"slider-range", "Two thumbs",
       "Not a daisyUI variant — our multi-thumb range, painted the same."}
    ],
    "separator" => [
      {"separator-hero", "Divider", "daisyUI's `divider` with a label in the middle."},
      {"separator-plain", "Without a label", "The bare rule."},
      {"separator-vertical", "Vertical", "daisyUI's `divider-horizontal` orientation."},
      {"separator-colors", "Colors", "All eight `divider-*` colors."},
      {"separator-positions", "Positions",
       "daisyUI's `divider-start` and `divider-end` move the label off centre."},
      {"separator-responsive", "Responsive",
       "Vertical on a wide screen, horizontal on a narrow one — daisyUI's `lg:divider-horizontal`."}
    ],
    "collapsible" => [
      {"collapsible-hero", "Collapse", "daisyUI's `collapse` with the arrow icon."},
      {"collapsible-plain", "Without border or background",
       "The bare disclosure, before the card treatment."},
      {"collapsible-plus", "Plus / minus icon",
       "daisyUI's `collapse-plus`; ours is the trigger's own icon, rotated on `data-panel-open`."},
      {"collapsible-icon-start", "Icon at the start",
       "The icon before the title instead of after it."},
      {"collapsible-open", "Force open", "daisyUI's `collapse-open` — our `open` attribute."},
      {"collapsible-close", "Force close",
       "daisyUI's `collapse-close` — ours is `disabled`, which also takes the trigger out of play."},
      {"collapsible-custom-colors", "Custom colors",
       "A primary card, the way daisyUI's colour recipe does it."}
    ],
    "toast" => [
      {"toast-hero", "Toast with an alert inside",
       "daisyUI's `toast` corner stack with an `alert` card in it."},
      {"toast-colors", "Alert colors",
       "`alert-info`, `alert-success`, `alert-warning`, `alert-error`."},
      {"toast-placement", "Placement",
       "daisyUI's nine `toast-{top,middle,bottom}` × `toast-{start,center,end}` combinations, as classes on the viewport."},
      {"toast-live", "Pushed from a trigger",
       "The template toast our engine clones on click, with the close button and auto-dismiss."}
    ],
    "fieldset" => [
      {"fieldset-hero", "Fieldset with legend and label",
       "daisyUI's `fieldset` and `fieldset-legend`."},
      {"fieldset-box", "With background and border", "The boxed variant from the docs."},
      {"fieldset-multiple", "With multiple inputs", "Several labelled inputs in one group."},
      {"fieldset-join", "With join items", "daisyUI's `join` pairing an input with a button."},
      {"fieldset-login", "Login form", "The docs' login form, built from our fieldset."},
      {"fieldset-disabled", "Disabled",
       "Not a daisyUI variant — our `disabled` attribute, which disables every control natively."}
    ],
    "otp_field" => [
      {"otp_field-hero", "OTP input", "Six `input` boxes in a row, daisyUI's OTP recipe."},
      {"otp_field-joined", "OTP joined",
       "daisyUI's `otp-joined` — the boxes share their edges, so the row reads as one field."},
      {"otp_field-sizes", "OTP with different sizes",
       "`input-xs` through `input-xl` on each box."},
      {"otp_field-colors", "OTP with different colors", "The eight `input-*` colours."},
      {"otp_field-groups", "With a separator", "Two groups of three, split by a separator part."},
      {"otp_field-masked", "Masked", "The same field with the characters hidden."},
      {"otp_field-alphanumeric", "Alphanumeric", "Letters and digits, upper-cased as you type."},
      {"otp_field-disabled", "Disabled", "The whole field disabled."}
    ],
    "anchor" => [
      {"anchor-hero", "Link", "daisyUI's `link`."},
      {"anchor-hover", "Link on hover only", "daisyUI's `link-hover`."},
      {"anchor-colors", "Colors", "All eight `link-*` colors."},
      {"anchor-in-text", "In a paragraph", "The link inline in body copy, as the docs show it."}
    ],
    "semi_circle_progress" => [
      {"semi_circle_progress-hero", "Radial progress", "daisyUI's `radial-progress`, as an arc."},
      {"semi_circle_progress-values", "Values", "0, 25, 50, 75 and 100 percent."},
      {"semi_circle_progress-colors", "Colors",
       "The colour utilities, since both arcs are `currentColor`."},
      {"semi_circle_progress-sizes", "Sizes", "Sized by a width utility on the root."}
    ],
    "drawer" => [
      {"drawer-hero", "Drawer", "daisyUI's sidebar drawer with an overlay."},
      {"drawer-sides", "Sides", "Left, right, top and bottom."},
      {"drawer-handle", "Bottom sheet with a handle",
       "Our handle part, for the swipe-to-dismiss sheet daisyUI has no equivalent of."},
      {"drawer-non-dismissible", "Does not close on overlay click", "`dismissible={false}`."}
    ],
    "toggle" => [
      {"toggle-hero", "Swap",
       "daisyUI's `swap`, as a two-state button; ours keys off `data-pressed`."},
      {"toggle-states", "Pressed and disabled", "The three states side by side."},
      {"toggle-icons", "With icons", "An icon that changes with the pressed state."},
      {"toggle-form", "In a form", "The toggle submitting a value, via `name`."}
    ],
    "code" => [
      {"code-hero", "Mockup code", "daisyUI's `mockup-code` window."},
      {"code-multi", "Multi line", "Several lines, each with its own prefix."},
      {"code-highlight", "Highlighted line", "One line picked out with a background colour."},
      {"code-scroll", "Long line will scroll",
       "A line wider than the window scrolls horizontally."},
      {"code-no-prefix", "Without prefix", "Lines with no `data-prefix` at all."},
      {"code-color", "With color", "The whole window in a theme colour."},
      {"code-inline", "Inline", "The same component inline in a sentence."}
    ],
    "field" => [
      {"field-hero", "Label and input", "daisyUI's `label` and `input`, wired by the field."},
      {"field-description", "With help text", "A description under the control."},
      {"field-invalid", "Invalid",
       "daisyUI's `validator-hint`; ours is the error part off `data-invalid`."},
      {"field-valid", "Valid", "The success state."},
      {"field-disabled", "Disabled", "The whole field disabled."}
    ],
    "nav_link" => [
      {"nav_link-hero", "Nav link",
       "A menu row, the shape a nav link takes in daisyUI's `menu`."},
      {"nav_link-active", "Active", "daisyUI's `menu-active` treatment on the current page."},
      {"nav_link-nested", "With children", "A nested list, indented with daisyUI's guide line."},
      {"nav_link-icons", "With an icon and a badge",
       "The `:icon` and `:trailing` slots, laid out by the row grid."}
    ],
    "loading_overlay" => [
      {"loading_overlay-hero", "Loading",
       "daisyUI's `loading-spinner` on a scrim over a region."},
      {"loading_overlay-content", "With custom content",
       "Your own loader instead of the spinner."},
      {"loading_overlay-styles", "Loader styles",
       "daisyUI's six: `loading-spinner`, `-dots`, `-ring`, `-ball`, `-bars` and `-infinity`."},
      {"loading_overlay-colors", "Colors", "The loader takes any text color utility."}
    ],
    "button" => [
      {"button-hero", "Button", "daisyUI's `btn`."},
      {"button-sizes", "Sizes", "`btn-xs` through `btn-xl`."},
      {"button-responsive", "Responsive", "One button that grows with the breakpoint."},
      {"button-colors", "Colors", "All eight `btn-*` colors."},
      {"button-soft", "Soft", "daisyUI's `btn-soft` across the colors."},
      {"button-outline", "Outline", "daisyUI's `btn-outline` across the colors."},
      {"button-dash", "Dash", "daisyUI's `btn-dash` across the colors."},
      {"button-neutral-variants", "Neutral, outline and dash",
       "The neutral button in both styles."},
      {"button-active", "Active", "daisyUI's `btn-active`."},
      {"button-ghost-link", "Ghost and link", "`btn-ghost` and `btn-link`."},
      {"button-wide-block", "Wide and block", "`btn-wide` and `btn-block`."},
      {"button-shapes", "Square and circle", "`btn-square` and `btn-circle`."},
      {"button-icons", "With icons",
       "Our `:start_icon` and `:end_icon` parts, so a skin can space them without markup surgery."},
      {"button-disabled", "Disabled",
       "The native disabled button, and the link form — which has no `disabled`, so it gets `aria-disabled`."},
      {"button-loading", "Loading",
       "Our `loading` attribute: `aria-busy`, interaction off, and the `:loader` slot revealed while the label holds its width."},
      {"button-as-link", "As a link",
       "`href` / `navigate` render an anchor with `role=\"button\"` — a link navigates, a button acts."},
      {"button-login", "Login buttons",
       "daisyUI's brand palette, straight from their page — the point being that a `btn` takes any background, text and border colour without losing its shape."},
      {"button-submit", "In a form", "A submit button wired to a form."}
    ],
    "alert" => [
      {"alert-hero", "Alert",
       "daisyUI's `alert` — neutral surface, the icon carrying the colour."},
      {"alert-info", "Info color", "daisyUI's `alert-info`."},
      {"alert-success", "Success color", "daisyUI's `alert-success`."},
      {"alert-warning", "Warning color", "daisyUI's `alert-warning`."},
      {"alert-error", "Error color", "daisyUI's `alert-error`."},
      {"alert-soft", "Alert soft style", "daisyUI's `alert-soft`."},
      {"alert-outline", "Alert outline style", "daisyUI's `alert-outline`."},
      {"alert-dash", "Alert dash style", "daisyUI's `alert-dash`."},
      {"alert-actions", "Alert with buttons + responsive",
       "daisyUI's `alert-vertical sm:alert-horizontal`, with our `:actions` part."},
      {"alert-title", "Alert with title and description",
       "The `:title` part, wired to the root through `aria-labelledby` so it is announced first."},
      {"alert-urgency", "Urgency",
       "Not a daisyUI variant — daisyUI's alert is purely visual. Ours picks the semantics: polite renders `role=status`, assertive renders `role=alert` and interrupts a screen reader."},
      {"alert-dismissible", "Dismissible",
       "The `:close` part, which hides the alert with `Phoenix.LiveView.JS` — no hook, no round trip."}
    ],
    "menu" => [
      {"menu-hero", "Dropdown menu",
       "A daisyUI button opening a `menu` popup, with separators splitting the groups of actions."},
      {"menu-placement", "Placement",
       "daisyUI ships sixteen `dropdown-{top,bottom,left,right}` × `dropdown-{start,center,end}` classes; ours are the `side` and `align` attributes."},
      {"menu-hover", "On hover", "daisyUI's `dropdown-hover` — our `open_on_hover` attribute."},
      {"menu-sizes", "Sizes", "`menu-xs` through `menu-xl` on the popup part."},
      {"menu-icons", "With icons", "An icon before each label, laid out by the skin's row grid."},
      {"menu-icons-only", "Icon only",
       "Icons with no labels — daisyUI's compact rail, as a dropdown."},
      {"menu-icons-tooltip", "Icon only, with tooltip",
       "daisyUI's `tooltip` + `data-tip` on each row, since the label is gone."},
      {"menu-badges", "With icons and a badge",
       "daisyUI's `badge badge-xs` pushed to the end of the row."},
      {"menu-active", "Active item", "daisyUI's `menu-active` marking the current page."},
      {"menu-disabled", "Disabled items", "A disabled row alongside live ones."},
      {"menu-title", "With a title", "daisyUI's `menu-title` as a heading over a group of rows."},
      {"menu-title-parent", "Title as a parent",
       "The title heading a nested list rather than a flat group."},
      {"menu-submenu", "Submenu", "A nested list opened from a row."},
      {"menu-file-tree", "File tree",
       "daisyUI's `menu-xs` file tree, nested two levels deep inside the popup."},
      {"menu-horizontal-submenu", "Horizontal submenu",
       "daisyUI's horizontal menu with a nested list hanging off one item."},
      {"menu-horizontal", "Horizontal",
       "daisyUI's `menu-horizontal` — the popup lays its rows out in a row."},
      {"menu-responsive", "Responsive",
       "daisyUI's `menu-vertical lg:menu-horizontal`: stacked on small screens, a row above `lg`."},
      {"menu-flush", "Without padding or radius",
       "daisyUI's `p-0` + square rows, for a menu that meets its container's edges."},
      {"menu-rich", "Checkboxes, radios and a submenu",
       "The full menu surface — checkbox items, a radio group and a nested submenu — all painted by the skin."},
      {"menu-card", "Card as dropdown",
       "daisyUI's card-shaped dropdown: arbitrary content in the popup instead of rows."}
    ],
    "breadcrumb" => [
      {"breadcrumb-hero", "Breadcrumbs",
       "daisyUI's `breadcrumbs`. The trail is an `<ol>` inside a `<nav aria-label>`, and the last crumb is a `<span aria-current=\"page\">` — a link to the page you are already on is a dead end that still takes a tab stop."},
      {"breadcrumb-icons", "With icons",
       "An icon inside each crumb. daisyUI draws its separator with a `:before` on the crumb itself; ours is a real part, so the icons do not fight it."},
      {"breadcrumb-max-width", "With max-width",
       "daisyUI scrolls a trail that outgrows its container — `max-w-*` on the root and the overflow is horizontal."},
      {"breadcrumb-separator", "Custom separator",
       "Not on daisyUI's page. The `:separator` slot replaces the chevron; the skin only paints its own when the default is in place."},
      {"breadcrumb-collapsed", "Collapsed",
       "Not on daisyUI's page either. `max_items` keeps the ends and stands one ellipsis in for the middle — arithmetic on the server, so it works before the socket connects."},
      {"breadcrumb-expandable", "Expandable",
       "The same collapse with `on_expand`, which makes the ellipsis a real button that pushes to the server."}
    ],
    "calendar" => [
      {"calendar-hero", "Calendar",
       "daisyUI ships no calendar — it styles Cally, React Day Picker and Vanilla Calendar Pro, each with its own JavaScript and markup. This is the Phoenix answer: the grid is `Date` arithmetic in Elixir, so the month is right before the socket connects."},
      {"calendar-selected", "With a selected day",
       "`value` is a `Date`; the selection lives on the server, so it is always the truth."},
      {"calendar-range", "Range",
       "`mode=\"range\"` with a `{from, to}` tuple — the days between are `data-in-range`, a state the component derives rather than a class the caller works out per cell."},
      {"calendar-multiple", "Multiple days", "`mode=\"multiple\"` with a list."},
      {"calendar-bounds", "With a minimum and a maximum",
       "Out-of-range days are `aria-disabled`, and the paging control disables itself rather than moving to a month with nothing in it."},
      {"calendar-disabled-dates", "With specific days blocked", "Individual dates ruled out."},
      {"calendar-sunday", "Starting on Sunday",
       "`first_day_of_week={7}` rotates the columns and the weekday names together."},
      {"calendar-compact", "Without outside days, sized to the month",
       "`show_outside_days={false}` and `fixed_weeks={false}`. February 2027 starts on a Monday and has 28 days, so it needs exactly four rows — and gets four, instead of six with two of them empty."},
      {"calendar-live", "Live",
       "`on_select` and `on_month_change` push to the server; the arrow keys page the month by themselves and land on the day the keys were heading for."}
    ],
    "carousel" => [
      {"carousel-hero", "Snap to start",
       "daisyUI's default. The scrolling is native scroll-snap and works with the hook absent — what the hook adds is which slide is current, which CSS has no way to report."},
      {"carousel-center", "Snap to center",
       "`snap=\"center\"`, read from the root rather than a class."},
      {"carousel-end", "Snap to end", "`snap=\"end\"`."},
      {"carousel-full", "Full width items", "One slide per view."},
      {"carousel-vertical", "Vertical",
       "daisyUI's `carousel-vertical`; the arrow keys follow the axis."},
      {"carousel-half", "Half width items", "Two slides per view, from a width on the slide."},
      {"carousel-full-bleed", "Full-bleed",
       "daisyUI's centred carousel on a neutral field, with the slides spaced and inset."},
      {"carousel-indicators", "With indicator buttons",
       "daisyUI's indicators are anchors that jump by fragment; ours are buttons carrying `aria-current`, so the position is announced and the page does not gain a history entry per slide."},
      {"carousel-controls", "With next/prev buttons",
       "The controls disable themselves at the ends — unless the carousel loops."},
      {"carousel-autoplay", "Autoplay",
       "Not on daisyUI's page. It advances on its own, pauses on hover and on focus, and never starts at all under `prefers-reduced-motion`."},
      {"carousel-live", "Reporting the slide",
       "`on_change` pushes the observed index — the one the user actually landed on, not the one a counter guessed."}
    ],
    "table" => [
      {"table-hero", "Table",
       "daisyUI's `table` transfers almost intact, because its rules target `th`/`td`/`tr` rather than class names. What it cannot give you is the semantics — a caption, `scope` on the headers, and a row header that lets a reader say the person's name before their job."},
      {"table-bordered", "With border and background",
       "daisyUI's `rounded-box` wrapper and a border."},
      {"table-active", "With an active row",
       "daisyUI marks a row with a class; ours is a state, so the skin reads `data-selected`."},
      {"table-hover", "Rows that highlight on hover", "daisyUI's `table-row-hover`."},
      {"table-zebra", "Zebra", "daisyUI's `table-zebra`."},
      {"table-visual", "With visual elements",
       "Avatars and badges in the cells, from the column's `:let` row."},
      {"table-xs", "Table xs", "daisyUI's `table-xs`."},
      {"table-pinned", "With pinned rows", "daisyUI's `table-pin-rows` inside a scrolling box."},
      {"table-pinned-cols", "With pinned rows and columns",
       "daisyUI's `table-pin-cols` as well — the row header is the column that stays put."},
      {"table-sortable", "Sortable",
       "Not on daisyUI's page. The header is a button and the cell carries `aria-sort`, so the order is announced and not merely drawn; clicking the sorted column reverses it."},
      {"table-selectable", "Selectable",
       "Not on daisyUI's page either. The header checkbox is tri-state — select one row and it goes to the mixed state rather than pretending nothing is selected."},
      {"table-empty", "Empty", "The `:empty` slot spans every column."}
    ],
    "fab" => [
      {"fab-hero", "FAB and speed dial",
       "daisyUI opens its dial with `:focus-within` on a `div[role=button]`. This is a real button on the shared Popup engine, so it has `aria-expanded`, closes on Escape and on an outside click, and can be activated with Space."},
      {"fab-icons", "With SVG icons", "Icons rather than letters in each action."},
      {"fab-labels", "With labels",
       "`show_label` puts the name beside the glyph; the action is announced either way."},
      {"fab-rectangle", "Rectangular buttons",
       "An action with a visible label stops being a circle — the skin does that from `:has()`, not from a modifier the caller adds."},
      {"fab-close", "With a close button",
       "`:close_icon` swaps the trigger's glyph while the dial is open."},
      {"fab-main-action", "With a main action",
       "daisyUI's `fab-main-action`: while the dial is open the button underneath is free to mean something else."},
      {"fab-single", "A single FAB",
       "No actions at all — and then no popup is rendered either, rather than an empty menu."},
      {"fab-flower", "Flower", "daisyUI's quarter-circle arrangement, from `data-direction`."},
      {"fab-flower-main", "Flower with a main action",
       "daisyUI shows the quarter-circle both ways; this is the one where the trigger becomes an action of its own once the dial is open."},
      {"fab-directions", "Other directions",
       "Not on daisyUI's page. The dial can fan down, left or right as well as up."}
    ],
    "theme_controller" => [
      {"theme-controller-hero", "Theme controller",
       "Every example on this page targets its own preview box rather than the page, which is what `target` is for — a controller that repainted this whole gallery would make the rest of it unreadable."},
      {"theme-controller-toggle", "Using a toggle",
       "daisyUI's `toggle` on the input. `switch` renders one checkbox standing for two themes instead of a radio each."},
      {"theme-controller-checkbox", "Using a checkbox", "daisyUI's `checkbox`."},
      {"theme-controller-toggle-text", "Toggle with text", "The label beside the switch."},
      {"theme-controller-swap", "Theme Controller using a swap",
       "daisyUI's `swap swap-rotate`: the two glyphs sit in one grid cell and rotate past each other."},
      {"theme-controller-icons-inside", "Toggle with icons inside",
       "daisyUI's glyphs live inside the track itself, addressed by `:nth-child`, so they render with no label wrapper around them."},
      {"theme-controller-dropdown", "Using a dropdown",
       "daisyUI's theme dropdown — a radio per theme, each drawn as a ghost block button."},
      {"theme-controller-toggle-icons", "Toggle with icons",
       "An icon on each side; the `:option` slot body replaces the label's text."},
      {"theme-controller-colors", "Toggle with custom colors",
       "daisyUI's colour modifiers on the input."},
      {"theme-controller-radio", "Using radio inputs",
       "The default shape: one native radio per theme, so arrow keys move between them without a line of JS."},
      {"theme-controller-buttons", "Using radio buttons",
       "The same radios with the input visually hidden and the label painted as a button — `data-checked` marks the chosen one."},
      {"theme-controller-system", "With a system option",
       "Not on daisyUI's page. `system` follows `prefers-color-scheme` and keeps following it, so changing the OS setting changes the preview without a click."},
      {"theme-controller-persist", "Remembering the choice",
       "Not on daisyUI's page either, and the reason this component exists: daisyUI's controller forgets on the next navigation. This one stores the choice — pick a theme, reload, and it is still there."}
    ],
    "countdown" => [
      {"countdown-hero", "Countdown",
       "daisyUI's `countdown` ships no timer — it animates a number you change yourself. This one counts: the server renders the remaining time so the first paint is already right, and the hook ticks it from there."},
      {"countdown-large", "Large text", "daisyUI's `text-4xl` on the root."},
      {"countdown-clock", "Clock",
       "Hours, minutes and seconds — the largest unit shown absorbs the days above it."},
      {"countdown-colons", "Clock with colons", "The `separator` attribute between units."},
      {"countdown-labels", "With labels", "`show_labels` puts the unit beside each number."},
      {"countdown-labels-under", "With labels underneath",
       "The same labels, stacked — layout is the caller's, the parts are the component's."},
      {"countdown-boxes", "In boxes", "daisyUI's bordered boxes around each unit."},
      {"countdown-short", "Reaching zero",
       "Not on daisyUI's page. A ten-second countdown that pushes `on_complete` once when it lands — watch the message below appear."}
    ],
    "burger" => [
      {"burger-hero", "Burger",
       "daisyUI's hamburger lives on its `swap` page as a checkbox cross-fading two whole SVGs. Ours is three bars that animate into an ✕ — one fewer icon to draw — on a real button with `aria-expanded`, not a disguised checkbox."},
      {"burger-opened", "Opened", "The same button in its open state."},
      {"burger-sizes", "Sizes", "`btn-xs` through `btn-lg` on the root."},
      {"burger-colors", "Colors",
       "The bars take `currentColor`, so a text colour is all it needs."},
      {"burger-disabled", "Disabled", "Dimmed and inert."}
    ],
    "spoiler" => [
      {"spoiler-hero", "Spoiler",
       "daisyUI's nearest thing is `collapse`, but that hides everything behind a title bar. A spoiler shows the beginning and fades out the rest, so the box is ours and only the toggle borrows `btn btn-sm btn-ghost`."},
      {"spoiler-expanded", "Starting open", "`expanded` renders it already unfolded."},
      {"spoiler-labels", "Custom labels", "The show and hide labels are attributes."}
    ],
    "segmented_control" => [
      {"segmented-control-hero", "Segmented control",
       "daisyUI builds this from `join` + `btn` or from `tabs-boxed`; both are the same shape, and the skin draws it so the markup carries nothing."},
      {"segmented-control-form", "In a form",
       "The segments are real radios sharing a name, so the choice posts with the form and needs no JS."},
      {"segmented-control-disabled", "Disabled", "The whole control ruled out."}
    ],
    "toggle_group" => [
      {"toggle-group-hero", "Toggle group",
       "daisyUI's `join` around `btn`s: one strip, square inner corners, the pressed one filled. Ours is a real toolbar with roving focus."},
      {"toggle-group-multiple", "Multiple",
       "Any number pressed at once — the classic text-formatting bar."},
      {"toggle-group-vertical", "Vertical", "The join runs down instead of across."},
      {"toggle-group-disabled", "Disabled", "The whole group ruled out."},
      {"toggle-group-form", "In a form",
       "Hidden inputs carry the pressed values; `multiple` posts them as a list."}
    ],
    "alert_dialog" => [
      {"alert_dialog-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"alert_dialog-detached-triggers-controlled", "Detached triggers controlled",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"alert_dialog-detached-triggers-simple", "Detached triggers simple",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "autocomplete" => [
      {"autocomplete-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"autocomplete-async", "Async",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"autocomplete-auto-highlight", "Auto highlight",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"autocomplete-command-palette", "Command palette",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"autocomplete-fuzzy-matching", "Fuzzy matching",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"autocomplete-grid", "Grid",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"autocomplete-grouped", "Grouped",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"autocomplete-inline", "Inline",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"autocomplete-limit", "Limit",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "chart" => [
      {"chart-breakdown", "Breakdown",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"chart-dashboard", "Dashboard",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "checkbox_group" => [
      {"checkbox_group-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "color_input" => [
      {"color_input-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "color_picker" => [
      {"color_picker-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "color_swatch" => [
      {"color_swatch-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "combobox" => [
      {"combobox-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"combobox-async-multiple", "Async Multiple",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"combobox-async-single", "Async Single",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"combobox-creatable", "Creatable",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"combobox-grouped", "Grouped",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"combobox-input-inside-popup", "Input Inside Popup",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"combobox-multiple", "Multiple",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "context_menu" => [
      {"context_menu-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"context_menu-submenu", "Submenu",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "editor" => [
      {"editor-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "empty_state" => [
      {"empty_state-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"empty_state-actions", "With actions",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "floating_indicator" => [
      {"floating_indicator-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "floating_window" => [
      {"floating_window-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "highlight" => [
      {"highlight-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "json_input" => [
      {"json_input-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "mark" => [
      {"mark-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "marquee" => [
      {"marquee-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "mask_input" => [
      {"mask_input-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "menubar" => [
      {"menubar-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "meter" => [
      {"meter-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "navigation_menu" => [
      {"navigation_menu-hero", "Megamenu",
       "daisyUI's megamenu: a bar of triggers, each opening a wide panel of links. The panel here is one shared, morphing viewport rather than a popover per trigger, so moving between menus resizes the box instead of swapping it."},
      {"navigation_menu-nested", "Nested",
       "A menu inside a menu — the inner list opens its own panel from within the outer one."},
      {"navigation_menu-nested-inline", "Nested inline",
       "The nested list stays in the flow of the panel instead of opening a second one."},
      {"navigation_menu-no-arrows", "Without arrows",
       "daisyUI drops its arrow with `after:content-none`; ours hides the icon part, since the trigger falls back to a `▾` when the `:icon` slot is empty."},
      {"navigation_menu-sizes", "Sizes", "daisyUI's `megamenu-xs` through `-lg`, on the list."}
    ],
    "number_field" => [
      {"number_field-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "number_formatter" => [
      {"number_formatter-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "overflow_list" => [
      {"overflow_list-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "pills_input" => [
      {"pills_input-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "popover" => [
      {"popover-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"popover-detached-triggers-controlled", "Detached Triggers Controlled",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"popover-detached-triggers-full", "Detached Triggers Full",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"popover-detached-triggers-simple", "Detached Triggers Simple",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"popover-open-on-hover", "Open On Hover",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "preview_card" => [
      {"preview_card-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"preview_card-detached-triggers-controlled", "Detached Triggers Controlled",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"preview_card-detached-triggers-full", "Detached Triggers Full",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"preview_card-detached-triggers-simple", "Detached Triggers Simple",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "rolling_number" => [
      {"rolling_number-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "scroll_area" => [
      {"scroll_area-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"scroll_area-both", "Both",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"scroll_area-scroll-fade", "Scroll Fade",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "scroller" => [
      {"scroller-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "sparkline" => [
      {"sparkline-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."},
      {"sparkline-types", "Types",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "splitter" => [
      {"splitter-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "tags_input" => [
      {"tags_input-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "theme_icon" => [
      {"theme_icon-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "toolbar" => [
      {"toolbar-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "tree" => [
      {"tree-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "tree_select" => [
      {"tree_select-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "visually_hidden" => [
      {"visually_hidden-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "alpha_slider" => [
      {"alpha_slider-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "angle_slider" => [
      {"angle_slider-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "hue_slider" => [
      {"hue_slider-hero", "Hero",
       "The same markup as the Base UI page with every styling class removed — the skin does all of it."}
    ],
    "action_icon" => [
      {"action-icon-hero", "Action icon",
       "daisyUI has no icon-button component; its own are `btn btn-square` written by hand, so that is what the skin paints — and every other `btn-*` modifier still works on the root."},
      {"action-icon-colors", "Colors", "All eight `btn-*` colors."},
      {"action-icon-sizes", "Sizes", "`btn-xs` through `btn-xl`."},
      {"action-icon-variants", "Variants",
       "daisyUI's `btn-outline`, `btn-ghost`, `btn-soft` and `btn-dash`."},
      {"action-icon-circle", "Circle", "daisyUI's `btn-circle` in place of the default square."},
      {"action-icon-disabled", "Disabled", "`disabled` reaches the skin through `data-disabled`."}
    ],
    "close_button" => [
      {"close-button-hero", "Close button",
       "daisyUI's own dismiss buttons — in its modal, on its alert — are `btn btn-sm btn-circle btn-ghost`, and so is this. Ghost matters: a close button should not compete with what it closes."},
      {"close-button-sizes", "Sizes", "`btn-xs` through `btn-lg`."},
      {"close-button-custom", "Custom glyph", "The slot replaces the built-in ✕."},
      {"close-button-in-alert", "In an alert",
       "Where daisyUI actually uses one — pinned to the end of a message."},
      {"close-button-disabled", "Disabled", "Dimmed and inert."}
    ],
    "chip" => [
      {"chip-hero", "Chip",
       "A chip is a badge you can pick, so it paints daisyUI's `badge`. The selected treatment is ours — daisyUI's badges are decoration, not controls."},
      {"chip-colors", "Colors", "All eight `badge-*` colors."},
      {"chip-sizes", "Sizes", "`badge-xs` through `badge-xl`."},
      {"chip-multiple", "Choose several",
       "Checkbox chips: each carries its own name, so any number can be on."},
      {"chip-single", "Choose one",
       "Radio chips sharing a name — the browser enforces the single choice, no JS involved."},
      {"chip-disabled", "Disabled", "One chip ruled out of the set."}
    ],
    "radio_group" => [
      {"radio-group-hero", "Radio group",
       "daisyUI's `radio` on each item, but the group owns the behaviour: one tab stop, arrow keys move *and* select, and a hidden input carries the value into a form."},
      {"radio-group-horizontal", "Horizontal", "The same group laid out in a row."},
      {"radio-group-sizes", "Sizes",
       "`radio-xs` through `radio-xl` — the modifier goes on the items, which is where daisyUI's radio lives."},
      {"radio-group-colors", "Colors", "All eight `radio-*` colors, one group each."},
      {"radio-group-disabled", "Disabled",
       "A whole group ruled out, and a group with one option disabled — the arrow keys skip the disabled one rather than stopping on it."},
      {"radio-group-readonly", "Read-only",
       "Not on daisyUI's page. Focus still moves through a read-only group, so it can be read out; only the selection is frozen."},
      {"radio-group-form", "In a form",
       "The hidden input fires `input`, so a wrapping `<.form phx-change>` sees every change."}
    ],
    "rating" => [
      {"rating-hero", "Rating",
       "daisyUI's `rating`. No classes in the markup — the skin supplies the star shape, and it is a radio group underneath, so arrow keys move and select and the whole control is one tab stop."},
      {"rating-readonly", "Read-only",
       "`readonly` shows a rating without letting it change — and unlike `disabled`, focus still moves through it, so a screen reader can read it out."},
      {"rating-star2", "mask-star-2 with warning color", "daisyUI's second star shape."},
      {"rating-heart", "mask-heart with multiple colors",
       "daisyUI's per-item colours — the classes go on the items, so each one can differ."},
      {"rating-green", "mask-star-2 with a fixed color", "A colour outside the theme palette."},
      {"rating-sizes", "Sizes", "`rating-xs` through `rating-xl`."},
      {"rating-hidden", "With a clear option",
       "daisyUI's `rating-hidden`. `clearable` adds a zero-width control before the first star, which is the only way back to no rating once one has been given."},
      {"rating-half", "Half stars",
       "`precision={0.5}` renders two half-width controls per star, so a half is picked rather than approximated — `data-value` carries the float, so the server never reconstructs it from an index."},
      {"rating-form", "In a Phoenix form",
       "The hidden input carries the value and fires `input`, so a wrapping `<.form phx-change>` sees every change — including the halves."}
    ],
    "pagination" => [
      {"pagination-hero", "With an active page",
       "daisyUI writes its pagination out by hand; here `total` and `page` are the input and the window is computed. The current page is a disabled button with `aria-current`, not a link to where you already are."},
      {"pagination-sizes", "Sizes", "daisyUI's `btn-*` sizes on the controls."},
      {"pagination-disabled", "With a disabled page",
       "`disabled` greys the whole control — and previous/next disable themselves at the ends rather than wrapping round."},
      {"pagination-xs", "Extra small buttons", "daisyUI's `btn-xs`."},
      {"pagination-edges", "First / last as well as previous / next",
       "daisyUI's equal-width outline prev/next, plus `show_edges` for the ends."},
      {"pagination-radio", "Using radio inputs",
       "daisyUI's radio pagination. `name` renders radios instead of buttons, so the choice posts with a surrounding form and needs no JS at all."},
      {"pagination-window", "The window at work",
       "Not on daisyUI's page. The same control at four positions in a hundred pages — the width never changes, so the buttons do not move under the cursor."},
      {"pagination-links", "Real links",
       "Not on daisyUI's page either. `href` takes a function of the page number, so the pages are crawlable and work with JavaScript off."},
      {"pagination-interactive", "Live",
       "`on_select` pushes `%{page: n}`; the page below is the server's."}
    ],
    "dock" => [
      {"dock-hero", "Dock",
       "daisyUI's `dock`, shown inside a frame — `contained` swaps the fixed positioning for absolute so it belongs to the box instead of the viewport, which is the only way to put one on a page that already has one."},
      {"dock-sizes", "Sizes", "`dock-xs` through `dock-xl`."},
      {"dock-colors", "Custom colors",
       "daisyUI colours the active item with a text class; the active state is `data-active`, so no `dock-active` is added by hand."},
      {"dock-top", "Pinned to the top",
       "Not on daisyUI's page. `position=\"top\"` flips the border and the active pill to the other edge."},
      {"dock-icon-only", "Labels for screen readers only",
       "Not on daisyUI's page either. `show_labels={false}` keeps the names in the DOM and hides them visually, rather than dropping the text an icon cannot replace."},
      {"dock-interactive", "Switching a panel",
       "`on_select` renders buttons instead of links, for a dock that changes a view rather than a route."}
    ],
    "stepper" => [
      {"stepper-hero", "Horizontal",
       "daisyUI's `steps`. Give the root an `active` index and the state of every step is derived — the skin colours the trail, so no step carries a `step-primary` by hand."},
      {"stepper-vertical", "Vertical", "daisyUI's `steps-vertical`."},
      {"stepper-responsive", "Responsive",
       "Vertical on a small screen, horizontal from `lg` up."},
      {"stepper-icons", "With custom content in the indicator",
       "daisyUI's `step-icon`. Content in the step's body replaces the number the skin would otherwise draw."},
      {"stepper-content", "With data-content",
       "daisyUI's `data-content` — the `content` attribute swaps the number for a character without giving up the numbering for the other steps."},
      {"stepper-colors", "Custom colors",
       "daisyUI's manual `step-*` classes, still supported for a flow whose colours do not follow its progress."},
      {"stepper-scrollable", "With a scrollable wrapper",
       "A long flow inside `overflow-x-auto`, exactly as daisyUI does it."},
      {"stepper-descriptions", "With descriptions",
       "Not on daisyUI's page. A second line per step, in its own part."},
      {"stepper-interactive", "Selectable steps",
       "Not on daisyUI's page either. `on_select` gives each reachable step an `action` covering the whole step; steps you have not reached yet stay plain text rather than becoming disabled buttons that still take a tab stop."}
    ],
    "text_input" => [
      {"text-input-hero", "Text input",
       "daisyUI's `input` on the control root. No styling classes in the markup — the border, radius, height and focus ring all come from the skin."},
      {"text-input-label-inside", "With text label inside",
       "daisyUI puts a label inside the input's border; ours is the `:start_section` slot, which the skin gives the divider and negative margin."},
      {"text-input-label-end", "With the label at the end",
       "The same, on the `:end_section` slot — the divider flips to the other edge."},
      {"text-input-ghost", "Ghost style", "daisyUI's `input-ghost` — no border until focus."},
      {"text-input-fieldset", "With fieldset and fieldset-legend",
       "Our `fieldset` around the input, with the legend painted as daisyUI's."},
      {"text-input-field", "With fieldset and label",
       "Our `field` wrapper supplies the label, the description and the `aria-describedby` wiring; the input only has to spread the `:let` map."},
      {"text-input-colors", "Input colors", "All eight `input-*` colors."},
      {"text-input-sizes", "Sizes", "`input-xs` through `input-xl`."},
      {"text-input-disabled", "Disabled",
       "`disabled` dims the box through `data-disabled`, so a server-disabled input looks disabled even before the browser agrees."},
      {"text-input-datalist", "With a datalist suggestion",
       "The native `list` attribute — `:global` carries it straight through."},
      {"text-input-date", "Date input", "`type=\"date\"`, with the picker indicator inset."},
      {"text-input-time", "Time input", "`type=\"time\"`."},
      {"text-input-datetime", "datetime-local input", "`type=\"datetime-local\"`."},
      {"text-input-username", "Username with icon and validator",
       "daisyUI's `validator` on the root: `:has(:user-invalid)` reaches our nested input, so the border turns red on a bad pattern with no JS."},
      {"text-input-search", "Search with icon", "`type=\"search\"` and an icon section."},
      {"text-input-email", "Email with icon and validator",
       "Native email validation, with the hint revealed only once the field is user-invalid."},
      {"text-input-join", "Email, button, joined",
       "daisyUI's `join` around the input and a button — the shared radii come from `--join-*`, which our root already reads."},
      {"text-input-password", "Password with icon and validator",
       "A pattern requiring a number, a lowercase and an uppercase letter."},
      {"text-input-number", "Number with validator", "`type=\"number\"` with min/max."},
      {"text-input-tel", "Telephone with icon and validator",
       "`type=\"tel\"` with a length pattern."},
      {"text-input-url", "URL with icon and validator", "`type=\"url\"`."},
      {"text-input-form", "In a Phoenix form",
       "The real integration: `field={@form[:email]}` takes the id, name, value and errors from the form. Errors wait for `used_input?/1` — the pristine form on the left has an error in its changeset and does not show it; the touched one on the right does."}
    ],
    "textarea" => [
      {"textarea-hero", "Textarea", "daisyUI's `textarea` on the control root."},
      {"textarea-ghost", "Ghost (no background)", "daisyUI's `textarea-ghost`."},
      {"textarea-field", "With form control and labels",
       "Our `field` wrapper around the textarea, label and description wired for screen readers."},
      {"textarea-colors", "Textarea colors", "All eight `textarea-*` colors."},
      {"textarea-sizes", "Sizes", "`textarea-xs` through `textarea-xl`."},
      {"textarea-disabled", "Disabled", "Disabled also removes the resize handle."},
      {"textarea-autosize", "Autosize",
       "Not on daisyUI's page — the one behaviour worth a hook. Type and the box grows between `min_rows` and `max_rows`, then starts scrolling."},
      {"textarea-form", "In a Phoenix form",
       "`field={@form[:bio]}` with a live character count from `phx-change`."}
    ],
    "file_input" => [
      {"file-input-hero", "File input",
       "daisyUI's `file-input`. The input *is* the root here, because `::file-selector-button` — the browser's own button — only exists on the input."},
      {"file-input-ghost", "File input ghost", "daisyUI's `file-input-ghost`."},
      {"file-input-field", "With fieldset and label",
       "Our `field` wrapper, with the accepted types as the description."},
      {"file-input-sizes", "Sizes", "`file-input-xs` through `file-input-xl`."},
      {"file-input-colors", "Colors",
       "The color modifiers paint the border and the button together."},
      {"file-input-disabled", "Disabled", "Both the box and the file-selector button dim."},
      {"file-input-form", "In a Phoenix form",
       "`field={@form[:attachment]}` plus a multiple-file input, whose name gets the `[]` suffix so Plug builds a list."}
    ],
    "card" => [
      {"card-hero", "Card",
       "daisyUI's `card` with a figure, a title and an action. The title is a real `h3` wired to the card through `aria-labelledby`."},
      {"card-pricing", "Pricing card", "A card with a list of features and a full-width action."},
      {"card-sizes", "Card sizes",
       "`card-xs` through `card-xl` — the padding and both font sizes come from the modifier."},
      {"card-border", "With a border", "daisyUI's `card-border`."},
      {"card-dash", "With a dashed border", "daisyUI's `card-dash`."},
      {"card-badge", "With a badge",
       "A daisyUI badge in the title row and another in the actions."},
      {"card-bottom-image", "Image at the bottom",
       "`figure_position=\"end\"` moves the figure after the body, which is what daisyUI's corner rounding keys off."},
      {"card-centered", "Centered content and padding",
       "Centered text with the image inset by padding."},
      {"card-image-overlay", "Image overlay",
       "daisyUI's `image-full` — figure and body share one grid cell and the image is dimmed behind the text."},
      {"card-no-image", "No image", "Just a body — the card collapses to a padded box."},
      {"card-custom-color", "Custom color",
       "Theme colors on the root, inherited by everything inside."},
      {"card-neutral", "Centered, neutral", "daisyUI's neutral card with centered actions."},
      {"card-actions-top", "Action on top",
       "The actions row moved above the title by ordering it first in the body."},
      {"card-side", "Image on the side",
       "daisyUI's `card-side`; the figure becomes a full-height column and its corners follow the edge."},
      {"card-responsive", "Responsive",
       "Vertical on a small screen, horizontal from `sm` up — one class, no JS."},
      {"card-selectable", "Selectable cards",
       "daisyUI outlines a card containing a checked control. `@rest` carries `aria-checked`, and the skin also matches `:has(:checked)` so the radio can live in the body."},
      {"card-link", "The whole card as a link",
       "`navigate` renders the root as an anchor, which is the honest markup for a card that is one big click target — a nested `<a>` inside a clickable `<div>` is not."}
    ]
  }

  attr :n, :integer, required: true

  # A flat SVG rather than a remote image: the gallery must render identically offline and in a
  # test, and ten carousels of network images would make the page useless to review.
  defp carousel_slide(assigns) do
    ~H"""
    <svg viewBox="0 0 200 120" class="h-32 w-full rounded-box object-cover" aria-hidden="true">
      <rect width="200" height="120" fill={"oklch(#{60 + rem(@n * 7, 20)}% 0.17 #{@n * 47})"} />
      <text
        x="100"
        y="68"
        text-anchor="middle"
        font-size="36"
        font-weight="700"
        fill="oklch(100% 0 0 / 0.85)"
      >
        {@n}
      </text>
    </svg>
    """
  end

  @crew [
    %{
      id: 1,
      name: "Cy Ganderton",
      job: "Quality Control Specialist",
      color: "Blue",
      company: "Littel, Schaden and Vandervort",
      location: "Canada"
    },
    %{
      id: 2,
      name: "Hart Hagerty",
      job: "Desktop Support Technician",
      color: "Purple",
      company: "Zemlak, Daniel and Leannon",
      location: "United States"
    },
    %{
      id: 3,
      name: "Brice Swyre",
      job: "Tax Accountant",
      color: "Red",
      company: "Carroll Group",
      location: "China"
    }
  ]

  @nav [
    {"Dashboard", "M3 12h18M3 6h18M3 18h18"},
    {"Projects", "M4 7h6l2 3h8v9H4z"},
    {"Settings", "M12 8a4 4 0 100 8 4 4 0 000-8z"}
  ]

  @spec has?(String.t()) :: boolean()
  def has?(component), do: Map.has_key?(@sections, component)

  @spec sections(String.t()) :: [{String.t(), String.t(), String.t()}]
  def sections(component), do: Map.get(@sections, component, [])

  @spec components() :: [String.t()]
  def components, do: @sections |> Map.keys() |> Enum.sort()

  @doc "The first section of a component — the one that must stay free of styling classes."
  @spec hero(String.t()) :: String.t() | nil
  def hero(component) do
    case sections(component) do
      [{id, _, _} | _] -> id
      [] -> nil
    end
  end

  @spec source(String.t()) :: String.t() | nil
  def source(id), do: ExampleSource.code(__MODULE__, id)

  attr :section, :string, required: true

  # ── accordion ─────────────────────────────────────────────────────────────
  @spec example(map()) :: Phoenix.LiveView.Rendered.t()
  def example(%{section: "accordion-hero"} = assigns) do
    assigns = assign(assigns, :faq, @faq)

    ~H"""
    <.accordion id="daisyui-accordion-hero" collapsible heading_level={3} class="max-w-80">
      <:item :for={{question, answer} <- @faq} title={question}>{answer}</:item>
    </.accordion>
    """
  end

  def example(%{section: "accordion-multiple"} = assigns) do
    assigns = assign(assigns, :faq, @faq)

    ~H"""
    <.accordion id="daisyui-accordion-multiple" multiple collapsible class="max-w-80">
      <:item :for={{question, answer} <- @faq} title={question}>{answer}</:item>
    </.accordion>
    """
  end

  def example(%{section: "accordion-plus"} = assigns) do
    assigns = assign(assigns, :faq, @faq)

    ~H"""
    <.accordion id="daisyui-accordion-plus" collapsible class="max-w-80">
      <:trigger_icon>
        <svg
          width="14"
          height="14"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          class="shrink-0 transition-transform duration-200 group-data-[panel-open]:rotate-45"
        >
          <path d="M2 8h12M8 2v12" />
        </svg>
      </:trigger_icon>
      <:item :for={{question, answer} <- @faq} title={question} trigger_class="group">
        {answer}
      </:item>
    </.accordion>
    """
  end

  def example(%{section: "accordion-separated"} = assigns) do
    assigns = assign(assigns, :faq, @faq)

    ~H"""
    <.accordion
      id="daisyui-accordion-separated"
      collapsible
      class="max-w-80 gap-2 overflow-visible border-0 bg-transparent"
    >
      <:item
        :for={{question, answer} <- @faq}
        title={question}
        class="rounded-box border border-base-300 bg-base-100"
      >
        {answer}
      </:item>
    </.accordion>
    """
  end

  # ── avatar ────────────────────────────────────────────────────────────────
  def example(%{section: "avatar-hero"} = assigns) do
    assigns = assign(assigns, :face, @face)

    ~H"""
    <.avatar id="daisyui-avatar-1" src={@face} alt="Lisa Turner" class="rounded-full" />
    """
  end

  def example(%{section: "avatar-sizes"} = assigns) do
    assigns = assign(assigns, :face, @face)

    ~H"""
    <div class="flex items-end gap-3">
      <.avatar
        :for={w <- ~w(w-8 w-16 w-20 w-32)}
        id={"daisyui-avatar-size-#{w}"}
        src={@face}
        alt=""
        class={["rounded-full", w]}
      />
    </div>
    """
  end

  def example(%{section: "avatar-rounded"} = assigns) do
    assigns = assign(assigns, :face, @face)

    ~H"""
    <div class="flex gap-3">
      <.avatar id="daisyui-avatar-3" src={@face} alt="" class="w-20 rounded-xl" />
      <.avatar id="daisyui-avatar-4" src={@face} alt="" class="w-20 rounded-full" />
    </div>
    """
  end

  def example(%{section: "avatar-mask"} = assigns) do
    assigns = assign(assigns, :face, @face)

    ~H"""
    <div class="flex gap-3">
      <.avatar
        :for={mask <- ~w(d-mask-heart d-mask-squircle d-mask-hexagon-2)}
        id={"daisyui-avatar-#{mask}"}
        src={@face}
        alt=""
        class={["w-20 d-mask", mask]}
      />
    </div>
    """
  end

  def example(%{section: "avatar-group"} = assigns) do
    assigns = assign(assigns, :face, @face)

    ~H"""
    <div class="d-avatar-group -space-x-6">
      <.avatar
        :for={i <- 1..3}
        id={"daisyui-avatar-group-#{i}"}
        src={@face}
        alt=""
        class="w-12 rounded-full"
      />
    </div>
    """
  end

  def example(%{section: "avatar-group-counter"} = assigns) do
    assigns = assign(assigns, :face, @face)

    ~H"""
    <div class="d-avatar-group -space-x-6">
      <.avatar
        :for={i <- 1..3}
        id={"daisyui-avatar-counter-#{i}"}
        src={@face}
        alt=""
        class="w-12 rounded-full"
      />
      <.avatar id="daisyui-avatar-8" class="w-12 rounded-full">+99</.avatar>
    </div>
    """
  end

  def example(%{section: "avatar-ring"} = assigns) do
    assigns = assign(assigns, :face, @face)

    ~H"""
    <.avatar
      id="daisyui-avatar-9"
      src={@face}
      alt=""
      class="w-20 rounded-full ring-2 ring-primary ring-offset-2 ring-offset-base-100"
    />
    """
  end

  def example(%{section: "avatar-presence"} = assigns) do
    assigns = assign(assigns, :face, @face)

    ~H"""
    <div class="flex gap-3">
      <.avatar id="daisyui-avatar-10" src={@face} alt="" class="d-avatar-online w-16 rounded-full" />
      <.avatar id="daisyui-avatar-11" src={@face} alt="" class="d-avatar-offline w-16 rounded-full" />
    </div>
    """
  end

  def example(%{section: "avatar-placeholder"} = assigns) do
    assigns = assign(assigns, :face, @face)

    ~H"""
    <div class="flex gap-3">
      <.avatar id="daisyui-avatar-12" class="w-16 rounded-full">LT</.avatar>
      <.avatar id="daisyui-avatar-13" class="d-avatar-online w-16 rounded-full">SH</.avatar>
    </div>
    """
  end

  # ── pill ──────────────────────────────────────────────────────────────────
  def example(%{section: "pill-hero"} = assigns) do
    ~H"""
    <.pill>Badge</.pill>
    """
  end

  def example(%{section: "pill-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.pill :for={size <- @sizes} class={"d-badge-#{size}"}>{size_label(size)}</.pill>
    </div>
    """
  end

  def example(%{section: "pill-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-2">
      <.pill :for={color <- @colors} class={"d-badge-#{color}"}>{color_label(color)}</.pill>
    </div>
    """
  end

  def example(%{section: "pill-soft"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-2">
      <.pill :for={color <- @colors} class={"d-badge-soft d-badge-#{color}"}>
        {color_label(color)}
      </.pill>
    </div>
    """
  end

  def example(%{section: "pill-outline"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-2">
      <.pill :for={color <- @colors} class={"d-badge-outline d-badge-#{color}"}>
        {color_label(color)}
      </.pill>
    </div>
    """
  end

  def example(%{section: "pill-dash"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-2">
      <.pill :for={color <- @colors} class={"d-badge-dash d-badge-#{color}"}>
        {color_label(color)}
      </.pill>
    </div>
    """
  end

  def example(%{section: "pill-neutral-variants"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      <.pill class="d-badge-neutral d-badge-outline">Outline</.pill>
      <.pill class="d-badge-neutral d-badge-dash">Dash</.pill>
    </div>
    """
  end

  def example(%{section: "pill-ghost"} = assigns) do
    ~H"""
    <.pill class="d-badge-ghost">Ghost</.pill>
    """
  end

  def example(%{section: "pill-empty"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.pill :for={size <- @sizes} class={"d-badge-primary d-badge-#{size}"}><span /></.pill>
    </div>
    """
  end

  def example(%{section: "pill-icon"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      <.pill class="d-badge-info">
        <.nav_icon path="M12 8h.01M11 12h1v4h1" /> Info
      </.pill>
      <.pill class="d-badge-success">
        <.nav_icon path="M20 6 9 17l-5-5" /> Done
      </.pill>
      <.pill class="d-badge-warning">
        <.nav_icon path="M12 9v4m0 4h.01" /> Careful
      </.pill>
      <.pill class="d-badge-error">
        <.nav_icon path="M18 6 6 18M6 6l12 12" /> Failed
      </.pill>
    </div>
    """
  end

  def example(%{section: "pill-in-text"} = assigns) do
    ~H"""
    <div class="space-y-2">
      <h2 class="text-xl font-bold">
        Headline
        <.pill class="d-badge-lg">new</.pill>
      </h2>
      <p class="text-sm">
        Body copy with a
        <.pill class="d-badge-sm">small</.pill>
        badge inline.
      </p>
    </div>
    """
  end

  def example(%{section: "pill-in-button"} = assigns) do
    ~H"""
    <button type="button" class="d-btn">
      Inbox
      <.pill class="d-badge-sm d-badge-secondary">12</.pill>
    </button>
    """
  end

  def example(%{section: "pill-removable"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      <.pill class="d-badge-primary" with_remove>elixir</.pill>
      <.pill class="d-badge-secondary" with_remove>phoenix</.pill>
    </div>
    """
  end

  # ── progress ──────────────────────────────────────────────────────────────
  def example(%{section: "progress-hero"} = assigns) do
    ~H"""
    <.progress
      id="daisyui-progress-hero"
      value={40}
      class="block w-56"
      track_class="relative h-2 w-full overflow-hidden rounded-[var(--radius-box)] bg-base-content/20"
      indicator_class="h-full rounded-[inherit] bg-current transition-[width] duration-200 ease-[ease-out]"
    />
    """
  end

  def example(%{section: "progress-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-col gap-2">
      <.progress
        :for={color <- @colors}
        id={"daisyui-progress-#{color}"}
        value={60}
        class={["block w-56", "text-#{color}"]}
        track_class="relative h-2 w-full overflow-hidden rounded-[var(--radius-box)] bg-base-content/20"
        indicator_class="h-full rounded-[inherit] bg-current transition-[width] duration-200 ease-[ease-out]"
      />
    </div>
    """
  end

  def example(%{section: "progress-values"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.progress
        :for={v <- [0, 10, 40, 70, 100]}
        id={"daisyui-progress-v#{v}"}
        value={v}
        class="block w-56"
        track_class="relative h-2 w-full overflow-hidden rounded-[var(--radius-box)] bg-base-content/20"
        indicator_class="h-full rounded-[inherit] bg-current transition-[width] duration-200 ease-[ease-out]"
      />
    </div>
    """
  end

  def example(%{section: "progress-indeterminate"} = assigns) do
    ~H"""
    <.progress
      id="daisyui-progress-indeterminate"
      class="block w-56"
      track_class="relative h-2 w-full overflow-hidden rounded-[var(--radius-box)] bg-base-content/20"
      indicator_class={[
        "h-full rounded-[inherit] bg-current transition-[width] duration-200 ease-[ease-out]",
        "data-indeterminate:w-full data-indeterminate:bg-transparent",
        "data-indeterminate:bg-[repeating-linear-gradient(90deg,currentColor_-1%,currentColor_10%,#0000_10%,#0000_90%)]",
        "data-indeterminate:bg-size-[200%] data-indeterminate:bg-position-[15%]",
        "motion-safe:data-indeterminate:animate-chelekom-progress-loading"
      ]}
    />
    """
  end

  def example(%{section: "progress-labelled"} = assigns) do
    ~H"""
    <.progress
      id="daisyui-progress-labelled"
      value={64}
      label="Uploading"
      show_value
      class="block w-56 text-primary"
      label_class="mb-1 block text-[0.875rem] text-base-content"
      value_class="text-[0.875rem] text-base-content/70"
      track_class="relative h-2 w-full overflow-hidden rounded-[var(--radius-box)] bg-base-content/20"
      indicator_class="h-full rounded-[inherit] bg-current transition-[width] duration-200 ease-[ease-out]"
    />
    """
  end

  # ── tooltip ───────────────────────────────────────────────────────────────
  def example(%{section: "tooltip-hero"} = assigns) do
    ~H"""
    <.tooltip id="daisyui-tooltip-hero">
      <:trigger><span class="d-btn">Hover me</span></:trigger>
      hello
    </.tooltip>
    """
  end

  def example(%{section: "tooltip-open"} = assigns) do
    ~H"""
    <div class="pt-10">
      <.tooltip id="daisyui-tooltip-open" open>
        <:trigger><span class="d-btn">Always open</span></:trigger>
        hello
      </.tooltip>
    </div>
    """
  end

  def example(%{section: "tooltip-sides"} = assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-10 p-10">
      <.tooltip
        :for={side <- ~w(top bottom left right)}
        id={"daisyui-tooltip-#{side}"}
        side={side}
        open
      >
        <:trigger><span class="d-btn">{side}</span></:trigger>
        {side}
      </.tooltip>
    </div>
    """
  end

  def example(%{section: "tooltip-align"} = assigns) do
    ~H"""
    <div class="flex gap-10 p-10">
      <.tooltip
        :for={align <- ~w(start center end)}
        id={"daisyui-tooltip-align-#{align}"}
        align={align}
        open
      >
        <:trigger><span class="d-btn">{align}</span></:trigger>
        {align}
      </.tooltip>
    </div>
    """
  end

  def example(%{section: "tooltip-colors"} = assigns) do
    assigns = assign(assigns, :colors, ~w(primary secondary accent info success warning error))

    ~H"""
    <div class="flex flex-wrap gap-6 p-10">
      <.tooltip
        :for={color <- @colors}
        id={"daisyui-tooltip-#{color}"}
        open
        popup_class={"d-tooltip-#{color}"}
      >
        <:trigger><span class="d-btn">{color}</span></:trigger>
        {color}
      </.tooltip>
    </div>
    """
  end

  def example(%{section: "tooltip-rich"} = assigns) do
    ~H"""
    <div class="pt-16">
      <.tooltip id="daisyui-tooltip-rich" open popup_class="max-w-56">
        <:trigger><span class="d-btn">Rich content</span></:trigger>
        <div class="space-y-1 text-left">
          <div class="text-base font-bold">You are doing well</div>
          <div class="text-xs opacity-80">Keep it up and finish the tutorial.</div>
        </div>
      </.tooltip>
    </div>
    """
  end

  def example(%{section: "tooltip-responsive"} = assigns) do
    ~H"""
    <.tooltip id="daisyui-tooltip-responsive" class="hidden lg:inline-block">
      <:trigger><span class="d-btn">Large screens only</span></:trigger>
      only above lg
    </.tooltip>
    """
  end

  # ── radio ─────────────────────────────────────────────────────────────────
  def example(%{section: "radio-hero"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.radio id="daisyui-radio-a" name="radio-hero" value="a" checked>Option A</.radio>
      <.radio id="daisyui-radio-b" name="radio-hero" value="b">Option B</.radio>
    </div>
    """
  end

  def example(%{section: "radio-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-col gap-2">
      <.radio
        :for={size <- @sizes}
        id={"daisyui-radio-size-#{size}"}
        name={"radio-size-#{size}"}
        value={size}
        checked
        indicator_class={"d-radio-#{size}"}
      >
        radio-{size}
      </.radio>
    </div>
    """
  end

  def example(%{section: "radio-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-4">
      <.radio
        :for={color <- @colors}
        id={"daisyui-radio-#{color}"}
        name={"radio-#{color}"}
        value={color}
        checked
        indicator_class={"d-radio-#{color}"}
      >
        {color}
      </.radio>
    </div>
    """
  end

  def example(%{section: "radio-disabled"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.radio id="daisyui-radio-dis-on" name="radio-dis" value="on" checked disabled>
        Disabled, selected
      </.radio>
      <.radio id="daisyui-radio-dis-off" name="radio-dis2" value="off" disabled>
        Disabled
      </.radio>
    </div>
    """
  end

  def example(%{section: "radio-custom-colors"} = assigns) do
    ~H"""
    <.radio
      id="daisyui-radio-custom"
      name="radio-custom"
      value="custom"
      checked
      indicator_class="border-red-300 bg-red-100 text-red-600 data-[checked]:border-red-600 data-[checked]:bg-red-200"
    >
      Custom colors
    </.radio>
    """
  end

  def example(%{section: "radio-group"} = assigns) do
    ~H"""
    <div>
      <div id="daisyui-radio-group-label" class="mb-2 text-sm font-bold">Plan</div>
      <.radio_group
        id="daisyui-radio-group"
        name="plan"
        value="pro"
        aria-labelledby="daisyui-radio-group-label"
      >
        <:option value="free">Free</:option>
        <:option value="pro">Pro</:option>
        <:option value="team" disabled>Team (invite only)</:option>
      </.radio_group>
    </div>
    """
  end

  # ── slider ────────────────────────────────────────────────────────────────
  def example(%{section: "slider-hero"} = assigns) do
    ~H"""
    <.slider id="daisyui-slider-hero" value={40} label="Volume" class="max-w-xs" />
    """
  end

  def example(%{section: "slider-steps"} = assigns) do
    ~H"""
    <div class="w-full max-w-xs">
      <.slider id="daisyui-slider-steps" value={50} step={25} />
      <div class="mt-2 flex justify-between px-1 text-xs opacity-60">
        <span :for={n <- ~w(0 25 50 75 100)}>{n}</span>
      </div>
    </div>
    """
  end

  def example(%{section: "slider-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex w-full max-w-xs flex-col gap-3">
      <.slider
        :for={color <- @colors}
        id={"daisyui-slider-#{color}"}
        value={60}
        class={"d-range-#{color}"}
      />
    </div>
    """
  end

  def example(%{section: "slider-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex w-full max-w-xs flex-col gap-3">
      <.slider
        :for={size <- @sizes}
        id={"daisyui-slider-size-#{size}"}
        value={60}
        class={"d-range-#{size}"}
      />
    </div>
    """
  end

  def example(%{section: "slider-custom"} = assigns) do
    ~H"""
    <.slider
      id="daisyui-slider-custom"
      value={40}
      class="max-w-xs text-blue-300 [--d-range-bg:orange] [--d-range-fill:0] [--d-range-thumb:blue]"
    />
    """
  end

  def example(%{section: "slider-vertical"} = assigns) do
    ~H"""
    <.slider id="daisyui-slider-vertical" value={40} orientation="vertical" />
    """
  end

  def example(%{section: "slider-range"} = assigns) do
    ~H"""
    <.slider id="daisyui-slider-two" values={[25, 75]} class="max-w-xs d-range-primary" />
    """
  end

  # ── separator ─────────────────────────────────────────────────────────────
  def example(%{section: "separator-hero"} = assigns) do
    ~H"""
    <div class="w-full max-w-xs">
      <div>Above</div>
      <.separator>OR</.separator>
      <div>Below</div>
    </div>
    """
  end

  def example(%{section: "separator-plain"} = assigns) do
    ~H"""
    <div class="w-full max-w-xs">
      <div>Above</div>
      <.separator />
      <div>Below</div>
    </div>
    """
  end

  def example(%{section: "separator-vertical"} = assigns) do
    ~H"""
    <div class="flex w-full max-w-xs items-center">
      <div class="grid grow place-items-center">Left</div>
      <.separator orientation="vertical">OR</.separator>
      <div class="grid grow place-items-center">Right</div>
    </div>
    """
  end

  def example(%{section: "separator-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="w-full max-w-xs">
      <.separator :for={color <- @colors} class={"d-divider-#{color}"}>{color}</.separator>
    </div>
    """
  end

  # ── collapsible ───────────────────────────────────────────────────────────
  def example(%{section: "separator-positions"} = assigns) do
    ~H"""
    <div class="w-72 space-y-2">
      <.separator class="d-divider-start">Start</.separator>
      <.separator>Center</.separator>
      <.separator class="d-divider-end">End</.separator>
    </div>
    """
  end

  def example(%{section: "separator-responsive"} = assigns) do
    ~H"""
    <div class="flex w-full flex-col lg:flex-row">
      <div class="grid h-20 flex-grow place-items-center rounded-box bg-base-300">content</div>
      <.separator class="lg:d-divider-horizontal">OR</.separator>
      <div class="grid h-20 flex-grow place-items-center rounded-box bg-base-300">content</div>
    </div>
    """
  end

  def example(%{section: "collapsible-hero"} = assigns) do
    ~H"""
    <.collapsible id="daisyui-collapsible-hero" class="w-80">
      <:trigger>How do I create an account?</:trigger>
      Click the "Sign up" button in the top right corner and follow the prompts.
    </.collapsible>
    """
  end

  def example(%{section: "collapsible-plain"} = assigns) do
    ~H"""
    <.collapsible id="daisyui-collapsible-plain" class="w-80" item_class="!border-0 !bg-transparent">
      <:trigger>Without border or background</:trigger>
      The same disclosure with the card treatment removed.
    </.collapsible>
    """
  end

  def example(%{section: "collapsible-plus"} = assigns) do
    ~H"""
    <.collapsible id="daisyui-collapsible-plus" class="w-80" trigger_class="group">
      <:trigger>
        Plus / minus
        <svg
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          class="size-3.5 shrink-0 transition-transform duration-200 group-data-[panel-open]:rotate-45"
        >
          <path d="M2 8h12M8 2v12" />
        </svg>
      </:trigger>
      daisyUI swaps the arrow for a plus; ours is the trigger's own icon.
    </.collapsible>
    """
  end

  def example(%{section: "collapsible-icon-start"} = assigns) do
    ~H"""
    <.collapsible
      id="daisyui-collapsible-icon-start"
      class="w-80"
      trigger_class="group flex-row-reverse justify-end"
    >
      <:trigger>
        Icon at the start
        <svg
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          class="size-3.5 shrink-0 transition-transform duration-200 group-data-[panel-open]:rotate-90"
        >
          <path d="M6 3l5 5-5 5" />
        </svg>
      </:trigger>
      The trigger is a flex row, so reversing it moves the icon.
    </.collapsible>
    """
  end

  def example(%{section: "collapsible-open"} = assigns) do
    ~H"""
    <.collapsible id="daisyui-collapsible-open" class="w-80" open>
      <:trigger>Open from the start</:trigger>
      daisyUI's `collapse-open`; ours is the `open` attribute.
    </.collapsible>
    """
  end

  def example(%{section: "collapsible-close"} = assigns) do
    ~H"""
    <.collapsible id="daisyui-collapsible-close" class="w-80" disabled>
      <:trigger>Closed, and it stays closed</:trigger>
      daisyUI's `collapse-close`; ours is the `disabled` attribute.
    </.collapsible>
    """
  end

  def example(%{section: "collapsible-custom-colors"} = assigns) do
    ~H"""
    <.collapsible
      id="daisyui-collapsible-custom"
      class="w-80"
      item_class="!border-primary !bg-primary text-primary-content"
    >
      <:trigger>Custom colors</:trigger>
      A primary card, painted with utilities on the item part.
    </.collapsible>
    """
  end

  # ── toast ─────────────────────────────────────────────────────────────────
  def example(%{section: "toast-hero"} = assigns) do
    ~H"""
    <div class="relative h-28 w-full [transform:translate(0)]">
      <.toast id="daisyui-toast-hero">
        <:toast duration={0}>New message arrived.</:toast>
      </.toast>
    </div>
    """
  end

  def example(%{section: "toast-colors"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.toast
        :for={color <- ~w(info success warning error)}
        id={"daisyui-toast-#{color}"}
        viewport_class="!static"
        toast_class={"d-alert-#{color}"}
      >
        <:toast duration={0}>alert-{color}</:toast>
      </.toast>
    </div>
    """
  end

  def example(%{section: "toast-placement"} = assigns) do
    assigns =
      assign(
        assigns,
        :spots,
        for(v <- ~w(top middle bottom), h <- ~w(start center end), do: {v, h})
      )

    ~H"""
    <div class="grid grid-cols-3 gap-2">
      <.toast
        :for={{v, h} <- @spots}
        id={"daisyui-toast-#{v}-#{h}"}
        class="relative h-20 [transform:translate(0)]"
        viewport_class={["d-toast-#{v}", "d-toast-#{h}"]}
        toast_class="d-alert-info"
      >
        <:toast duration={0}>{v}/{h}</:toast>
      </.toast>
    </div>
    """
  end

  def example(%{section: "toast-live"} = assigns) do
    ~H"""
    <.toast id="daisyui-toast-live" duration={4000} toast_class="d-alert-success">
      <:trigger>Show a toast</:trigger>
      <:template>Saved. This one dismisses itself.</:template>
    </.toast>
    """
  end

  # ── fieldset ──────────────────────────────────────────────────────────────
  def example(%{section: "fieldset-hero"} = assigns) do
    ~H"""
    <.fieldset id="daisyui-fieldset-hero" class="w-xs">
      <:legend>Page title</:legend>
      <input type="text" class="d-input" placeholder="My awesome page" />
      <p class="d-label">You can edit page title later on from settings</p>
    </.fieldset>
    """
  end

  def example(%{section: "fieldset-box"} = assigns) do
    ~H"""
    <.fieldset
      id="daisyui-fieldset-box"
      class="w-xs rounded-box border border-base-300 bg-base-200 p-4"
    >
      <:legend>Page title</:legend>
      <input type="text" class="d-input" placeholder="My awesome page" />
      <p class="d-label">You can edit page title later on from settings</p>
    </.fieldset>
    """
  end

  def example(%{section: "fieldset-multiple"} = assigns) do
    ~H"""
    <.fieldset
      id="daisyui-fieldset-multiple"
      class="w-xs rounded-box border border-base-300 bg-base-200 p-4"
    >
      <:legend>Page details</:legend>
      <label class="d-label">Title</label>
      <input type="text" class="d-input" placeholder="My awesome page" />
      <label class="d-label">Slug</label>
      <input type="text" class="d-input" placeholder="my-awesome-page" />
      <label class="d-label">Author</label>
      <input type="text" class="d-input" placeholder="Name" />
    </.fieldset>
    """
  end

  def example(%{section: "fieldset-join"} = assigns) do
    ~H"""
    <.fieldset
      id="daisyui-fieldset-join"
      class="w-xs rounded-box border border-base-300 bg-base-200 p-4"
    >
      <:legend>Newsletter</:legend>
      <div class="d-join">
        <input type="email" class="d-input d-join-item" placeholder="you@example.com" />
        <button type="button" class="d-btn d-join-item">Subscribe</button>
      </div>
    </.fieldset>
    """
  end

  def example(%{section: "fieldset-login"} = assigns) do
    ~H"""
    <.fieldset
      id="daisyui-fieldset-login"
      class="w-xs rounded-box border border-base-300 bg-base-200 p-4"
    >
      <:legend>Login</:legend>
      <label class="d-label">Email</label>
      <input type="email" class="d-input" placeholder="Email" />
      <label class="d-label">Password</label>
      <input type="password" class="d-input" placeholder="Password" />
      <button type="button" class="d-btn d-btn-neutral mt-4">Login</button>
    </.fieldset>
    """
  end

  def example(%{section: "fieldset-disabled"} = assigns) do
    ~H"""
    <.fieldset
      id="daisyui-fieldset-disabled"
      disabled
      class="w-xs rounded-box border border-base-300 bg-base-200 p-4"
    >
      <:legend>Disabled group</:legend>
      <input type="text" class="d-input" placeholder="Cannot type here" />
      <button type="button" class="d-btn">Cannot click either</button>
    </.fieldset>
    """
  end

  # ── otp_field ─────────────────────────────────────────────────────────────
  def example(%{section: "otp_field-hero"} = assigns) do
    ~H"""
    <.otp_field id="daisyui-otp-hero" />
    """
  end

  def example(%{section: "otp_field-joined"} = assigns) do
    ~H"""
    <.otp_field
      id="daisyui-otp-joined"
      length={4}
      class="gap-0!"
      input_class="-ms-px rounded-none first:ms-0 first:rounded-s-field last:rounded-e-field"
    />
    """
  end

  def example(%{section: "otp_field-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-col items-start gap-3">
      <.otp_field
        :for={size <- @sizes}
        id={"daisyui-otp-#{size}"}
        length={4}
        input_class={"d-input-#{size}"}
      />
    </div>
    """
  end

  def example(%{section: "otp_field-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <.otp_field
        :for={color <- @colors}
        id={"daisyui-otp-#{color}"}
        length={4}
        input_class={"d-input-#{color}"}
      />
    </div>
    """
  end

  def example(%{section: "otp_field-groups"} = assigns) do
    ~H"""
    <.otp_field id="daisyui-otp-groups" group={3} separator="–" />
    """
  end

  def example(%{section: "otp_field-masked"} = assigns) do
    ~H"""
    <.otp_field id="daisyui-otp-masked" mask value="1234" />
    """
  end

  def example(%{section: "otp_field-alphanumeric"} = assigns) do
    ~H"""
    <.otp_field
      id="daisyui-otp-alnum"
      length={5}
      validation_type="alphanumeric"
      transform="uppercase"
    />
    """
  end

  def example(%{section: "otp_field-disabled"} = assigns) do
    ~H"""
    <.otp_field id="daisyui-otp-disabled" value="123456" disabled />
    """
  end

  # ── anchor ────────────────────────────────────────────────────────────────
  def example(%{section: "anchor-hero"} = assigns) do
    ~H"""
    <.anchor href="#">Click me</.anchor>
    """
  end

  def example(%{section: "anchor-hover"} = assigns) do
    ~H"""
    <.anchor href="#" class="d-link-hover">Underlined on hover only</.anchor>
    """
  end

  def example(%{section: "anchor-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-4">
      <.anchor :for={color <- @colors} href="#" class={"d-link-#{color}"}>{color}</.anchor>
    </div>
    """
  end

  def example(%{section: "anchor-in-text"} = assigns) do
    ~H"""
    <p class="max-w-sm text-sm">
      Read the
      <.anchor href="#">quick start guide</.anchor>
      before you install anything, then come back here.
    </p>
    """
  end

  # ── semi_circle_progress ──────────────────────────────────────────────────
  def example(%{section: "semi_circle_progress-hero"} = assigns) do
    ~H"""
    <.semi_circle_progress id="daisyui-semi-hero" value={70} label="Progress">
      70%
    </.semi_circle_progress>
    """
  end

  def example(%{section: "semi_circle_progress-values"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-end gap-4">
      <.semi_circle_progress :for={v <- [0, 25, 50, 75, 100]} id={"daisyui-semi-#{v}"} value={v}>
        {v}%
      </.semi_circle_progress>
    </div>
    """
  end

  def example(%{section: "semi_circle_progress-colors"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-end gap-4">
      <.semi_circle_progress
        :for={color <- ~w(primary secondary accent success warning error)}
        id={"daisyui-semi-#{color}"}
        value={70}
        class={"text-#{color}"}
      >
        70%
      </.semi_circle_progress>
    </div>
    """
  end

  def example(%{section: "semi_circle_progress-sizes"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-end gap-4">
      <.semi_circle_progress
        :for={w <- ~w(w-20 w-28 w-40)}
        id={"daisyui-semi-size-#{w}"}
        value={70}
        class={w}
      >
        70%
      </.semi_circle_progress>
    </div>
    """
  end

  # ── drawer ────────────────────────────────────────────────────────────────
  def example(%{section: "drawer-hero"} = assigns) do
    ~H"""
    <.drawer id="daisyui-drawer-hero">
      <:trigger>Open drawer</:trigger>
      <:title>Navigation</:title>
      <:description>The overlay closes it, and so does Escape.</:description>
      <p>Drawer body content.</p>
      <:close>
        <button type="button" data-close class="d-btn">Close</button>
      </:close>
    </.drawer>
    """
  end

  def example(%{section: "drawer-sides"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-3">
      <.drawer :for={side <- ~w(left right top bottom)} id={"daisyui-drawer-#{side}"} side={side}>
        <:trigger>{side}</:trigger>
        <:title>{side} drawer</:title>
        <p>Opened from the {side}.</p>
        <:close>
          <button type="button" data-close class="d-btn">Close</button>
        </:close>
      </.drawer>
    </div>
    """
  end

  def example(%{section: "drawer-handle"} = assigns) do
    ~H"""
    <.drawer id="daisyui-drawer-handle" side="bottom">
      <:trigger>Open bottom sheet</:trigger>
      <:handle></:handle>
      <:title>Bottom sheet</:title>
      <:description>Drag the handle down to dismiss.</:description>
      <p>Swipe-to-dismiss is the component's, not daisyUI's.</p>
    </.drawer>
    """
  end

  def example(%{section: "drawer-non-dismissible"} = assigns) do
    ~H"""
    <.drawer id="daisyui-drawer-sticky" dismissible={false}>
      <:trigger>Open sticky drawer</:trigger>
      <:title>Finish this first</:title>
      <:description>Clicking the overlay will not close this one.</:description>
      <:close>
        <button type="button" data-close class="d-btn d-btn-primary">Done</button>
      </:close>
    </.drawer>
    """
  end

  # ── toggle ────────────────────────────────────────────────────────────────
  def example(%{section: "toggle-hero"} = assigns) do
    ~H"""
    <.toggle id="daisyui-toggle-hero" pressed>Bold</.toggle>
    """
  end

  def example(%{section: "toggle-states"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-3">
      <.toggle id="daisyui-toggle-off">Off</.toggle>
      <.toggle id="daisyui-toggle-on" pressed>On</.toggle>
      <.toggle id="daisyui-toggle-dis" disabled>Disabled</.toggle>
    </div>
    """
  end

  def example(%{section: "toggle-icons"} = assigns) do
    ~H"""
    <.toggle id="daisyui-toggle-icons" pressed class="group d-btn-square">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="size-5">
        <path class="hidden group-data-[pressed]:block" d="M20 6 9 17l-5-5" />
        <path class="group-data-[pressed]:hidden" d="M12 5v14M5 12h14" />
      </svg>
    </.toggle>
    """
  end

  def example(%{section: "toggle-form"} = assigns) do
    ~H"""
    <form phx-submit="daisyui_switch_submit" class="flex items-center gap-3">
      <.toggle id="daisyui-toggle-form" name="pinned" pressed>Pinned</.toggle>
      <button type="submit" class="d-btn d-btn-primary d-btn-sm">Save</button>
    </form>
    """
  end

  # ── code ──────────────────────────────────────────────────────────────────
  def example(%{section: "code-hero"} = assigns) do
    ~H"""
    <.code id="daisyui-code-hero" block>
      <pre data-prefix="$"><code>mix mishka.ui.gen.headless select --skin daisyui</code></pre>
      <pre data-prefix=">" class="text-warning"><code>installing…</code></pre>
      <pre data-prefix=">" class="text-success"><code>Done</code></pre>
    </.code>
    """
  end

  def example(%{section: "code-inline"} = assigns) do
    ~H"""
    <p class="text-sm">
      Run
      <.code id="daisyui-code-inline">mix mishka.ui.gen.headless</.code>
      to generate a component.
    </p>
    """
  end

  def example(%{section: "code-multi"} = assigns) do
    ~H"""
    <.code id="daisyui-code-multi" block>
      <pre data-prefix="1"><code>defmodule MyApp.Page do</code></pre>
      <pre data-prefix="2"><code>  use MyAppWeb, :live_view</code></pre>
      <pre data-prefix="3"><code>end</code></pre>
    </.code>
    """
  end

  def example(%{section: "code-highlight"} = assigns) do
    ~H"""
    <.code id="daisyui-code-highlight" block>
      <pre data-prefix="1"><code>mix deps.get</code></pre>
      <pre data-prefix="2" class="bg-warning text-warning-content"><code>mix deps.compile</code></pre>
      <pre data-prefix="3"><code>mix phx.server</code></pre>
    </.code>
    """
  end

  def example(%{section: "code-scroll"} = assigns) do
    ~H"""
    <.code id="daisyui-code-scroll" block>
      <pre data-prefix="$"><code>mix mishka.ui.gen.headless select --skin daisyui --skin-scope "[data-skin=daisyui]" --skin-prefix d- --yes</code></pre>
    </.code>
    """
  end

  def example(%{section: "code-no-prefix"} = assigns) do
    ~H"""
    <.code id="daisyui-code-no-prefix" block>
      <pre><code>{"%{status: :ok}"}</code></pre>
      <pre><code>{"%{status: :error}"}</code></pre>
    </.code>
    """
  end

  def example(%{section: "code-color"} = assigns) do
    ~H"""
    <.code id="daisyui-code-color" block class="bg-primary text-primary-content">
      <pre data-prefix="$"><code>mix phx.server</code></pre>
      <pre data-prefix=">"><code>Running DevelopmentWeb.Endpoint</code></pre>
    </.code>
    """
  end

  # ── field ─────────────────────────────────────────────────────────────────
  def example(%{section: "field-hero"} = assigns) do
    ~H"""
    <.field :let={f} id="daisyui-field-hero" label="Email" class="w-xs">
      <input type="email" id={f.id} name={f.name} placeholder="you@example.com" />
    </.field>
    """
  end

  def example(%{section: "field-description"} = assigns) do
    ~H"""
    <.field :let={f} id="daisyui-field-desc" label="Page title" class="w-xs">
      <:description>You can edit the title later from settings.</:description>
      <input type="text" id={f.id} name={f.name} placeholder="My awesome page" />
    </.field>
    """
  end

  def example(%{section: "field-invalid"} = assigns) do
    ~H"""
    <.field
      :let={f}
      id="daisyui-field-invalid"
      label="Email"
      errors={["is not a valid address"]}
      class="w-xs"
    >
      <input type="email" id={f.id} name={f.name} value="not-an-email" />
    </.field>
    """
  end

  def example(%{section: "field-valid"} = assigns) do
    ~H"""
    <.field :let={f} id="daisyui-field-valid" label="Email" valid class="w-xs">
      <input type="email" id={f.id} name={f.name} value="you@example.com" />
    </.field>
    """
  end

  def example(%{section: "field-disabled"} = assigns) do
    ~H"""
    <.field :let={f} id="daisyui-field-disabled" label="Email" disabled class="w-xs">
      <input type="email" id={f.id} name={f.name} disabled placeholder="Not editable" />
    </.field>
    """
  end

  # ── nav_link ──────────────────────────────────────────────────────────────
  def example(%{section: "nav_link-hero"} = assigns) do
    ~H"""
    <div class="w-56">
      <.nav_link id="daisyui-nav-hero" href="#" label="Dashboard" />
      <.nav_link id="daisyui-nav-hero-2" href="#" label="Projects" />
    </div>
    """
  end

  def example(%{section: "nav_link-active"} = assigns) do
    ~H"""
    <div class="w-56">
      <.nav_link id="daisyui-nav-active-1" href="#" label="Overview" />
      <.nav_link id="daisyui-nav-active-2" href="#" label="Projects" active />
      <.nav_link id="daisyui-nav-active-3" href="#" label="Settings" />
    </div>
    """
  end

  def example(%{section: "nav_link-nested"} = assigns) do
    ~H"""
    <div class="w-56">
      <.nav_link id="daisyui-nav-nested" label="Components" default_opened>
        <:children>
          <.nav_link id="daisyui-nav-nested-a" href="#" label="Accordion" />
          <.nav_link id="daisyui-nav-nested-b" href="#" label="Select" active />
        </:children>
      </.nav_link>
    </div>
    """
  end

  def example(%{section: "nav_link-icons"} = assigns) do
    assigns = assign(assigns, :nav, @nav)

    ~H"""
    <div class="w-56">
      <.nav_link :for={{label, path} <- @nav} id={"daisyui-nav-icon-#{label}"} href="#" label={label}>
        <:icon><.nav_icon path={path} /></:icon>
        <:trailing><span class="d-badge d-badge-xs">3</span></:trailing>
      </.nav_link>
    </div>
    """
  end

  # ── loading_overlay ───────────────────────────────────────────────────────
  def example(%{section: "loading_overlay-hero"} = assigns) do
    ~H"""
    <div class="relative h-32 w-64 rounded-box border border-base-300 p-4 text-sm">
      Content behind the overlay.
      <.loading_overlay id="daisyui-loading-hero" visible class="absolute inset-0 rounded-box" />
    </div>
    """
  end

  def example(%{section: "loading_overlay-content"} = assigns) do
    ~H"""
    <div class="relative h-32 w-64 rounded-box border border-base-300 p-4 text-sm">
      Content behind the overlay.
      <.loading_overlay id="daisyui-loading-content" visible class="absolute inset-0 rounded-box">
        <span class="d-loading d-loading-dots d-loading-lg"></span>
      </.loading_overlay>
    </div>
    """
  end

  def example(%{section: "loading_overlay-styles"} = assigns) do
    assigns = assign(assigns, :styles, ~w(spinner dots ring ball bars infinity))

    ~H"""
    <div class="flex flex-wrap items-center gap-6">
      <div :for={style <- @styles} class="flex flex-col items-center gap-2">
        <div class="relative size-20 rounded-box border border-base-300">
          <.loading_overlay
            id={"daisyui-loading-#{style}"}
            visible
            class="absolute inset-0 rounded-box"
          >
            <span class={"d-loading d-loading-#{style} d-loading-lg"}></span>
          </.loading_overlay>
        </div>
        <span class="text-xs opacity-60">{style}</span>
      </div>
    </div>
    """
  end

  def example(%{section: "loading_overlay-colors"} = assigns) do
    assigns =
      assign(assigns, :colors, ~w(primary secondary accent neutral info success warning error))

    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <div :for={color <- @colors} class="relative size-16 rounded-box border border-base-300">
        <.loading_overlay
          id={"daisyui-loading-color-#{color}"}
          visible
          class="absolute inset-0 rounded-box"
        >
          <span class={"d-loading d-loading-spinner d-loading-md text-#{color}"}></span>
        </.loading_overlay>
      </div>
    </div>
    """
  end

  # ── button ────────────────────────────────────────────────────────────────
  def example(%{section: "button-hero"} = assigns) do
    ~H"""
    <.button>Button</.button>
    """
  end

  def example(%{section: "button-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.button :for={size <- @sizes} class={"d-btn-#{size}"}>btn-{size}</.button>
    </div>
    """
  end

  def example(%{section: "button-responsive"} = assigns) do
    ~H"""
    <.button class="d-btn-xs sm:d-btn-sm md:d-btn-md lg:d-btn-lg xl:d-btn-xl">Responsive</.button>
    """
  end

  def example(%{section: "button-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-2">
      <.button :for={color <- @colors} class={"d-btn-#{color}"}>{color}</.button>
    </div>
    """
  end

  def example(%{section: "button-soft"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-2">
      <.button :for={color <- @colors} class={"d-btn-soft d-btn-#{color}"}>{color}</.button>
    </div>
    """
  end

  def example(%{section: "button-outline"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-2">
      <.button :for={color <- @colors} class={"d-btn-outline d-btn-#{color}"}>{color}</.button>
    </div>
    """
  end

  def example(%{section: "button-dash"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-2">
      <.button :for={color <- @colors} class={"d-btn-dash d-btn-#{color}"}>{color}</.button>
    </div>
    """
  end

  def example(%{section: "button-neutral-variants"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      <.button class="d-btn-neutral d-btn-outline">outline</.button>
      <.button class="d-btn-neutral d-btn-dash">dash</.button>
    </div>
    """
  end

  def example(%{section: "button-active"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      <.button class="d-btn-active">Active</.button>
      <.button class="d-btn-primary d-btn-active">Primary</.button>
      <.button class="d-btn-ghost d-btn-active">Ghost</.button>
    </div>
    """
  end

  def example(%{section: "button-ghost-link"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      <.button class="d-btn-ghost">Ghost</.button>
      <.button class="d-btn-link">Link</.button>
    </div>
    """
  end

  def example(%{section: "button-wide-block"} = assigns) do
    ~H"""
    <div class="flex w-full max-w-sm flex-col items-center gap-2">
      <.button class="d-btn-wide">Wide</.button>
      <.button class="d-btn-block">Block</.button>
    </div>
    """
  end

  def example(%{section: "button-shapes"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      <.button class="d-btn-square" label="✕" />
      <.button class="d-btn-circle" label="✕" />
    </div>
    """
  end

  def example(%{section: "button-icons"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      <.button class="d-btn-primary">
        <:start_icon><.nav_icon path="M12 5v14M5 12h14" /></:start_icon>
        New project
      </.button>
      <.button>
        Continue
        <:end_icon><.nav_icon path="M6 3l5 5-5 5" /></:end_icon>
      </.button>
    </div>
    """
  end

  def example(%{section: "button-disabled"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      <.button disabled>Disabled button</.button>
      <.button href="#" disabled>Disabled link</.button>
    </div>
    """
  end

  def example(%{section: "button-loading"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      <.button class="d-btn-primary" loading>
        <:loader><span class="d-loading d-loading-spinner d-loading-xs"></span></:loader>
        Saving
      </.button>
      <.button class="d-btn-square" loading label="">
        <:loader><span class="d-loading d-loading-spinner"></span></:loader>
      </.button>
    </div>
    """
  end

  def example(%{section: "button-as-link"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      <.button href="https://daisyui.com" class="d-btn-primary">Open daisyUI</.button>
      <.button navigate="/showcase/headless-daisyui" class="d-btn-ghost">Back to the gallery</.button>
    </div>
    """
  end

  def example(%{section: "button-login"} = assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-2">
      <.button class="border-[#e5e5e5] bg-white text-black">
        <:start_icon>
          <svg aria-label="Email icon" width="16" height="16" viewBox="0 0 24 24">
            <g
              stroke-linejoin="round"
              stroke-linecap="round"
              stroke-width="2"
              fill="none"
              stroke="black"
            >
              <rect width="20" height="16" x="2" y="4" rx="2" />
              <path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7" />
            </g>
          </svg>
        </:start_icon>
        Login with Email
      </.button>

      <.button class="border-black bg-black text-white">
        <:start_icon>
          <svg aria-label="GitHub logo" width="16" height="16" viewBox="0 0 24 24">
            <path
              fill="white"
              d="M12,2A10,10 0 0,0 2,12C2,16.42 4.87,20.17 8.84,21.5C9.34,21.58 9.5,21.27 9.5,21C9.5,20.77 9.5,20.14 9.5,19.31C6.73,19.91 6.14,17.97 6.14,17.97C5.68,16.81 5.03,16.5 5.03,16.5C4.12,15.88 5.1,15.9 5.1,15.9C6.1,15.97 6.63,16.93 6.63,16.93C7.5,18.45 8.97,18 9.54,17.76C9.63,17.11 9.89,16.67 10.17,16.42C7.95,16.17 5.62,15.31 5.62,11.5C5.62,10.39 6,9.5 6.65,8.79C6.55,8.54 6.2,7.5 6.75,6.15C6.75,6.15 7.59,5.88 9.5,7.17C10.29,6.95 11.15,6.84 12,6.84C12.85,6.84 13.71,6.95 14.5,7.17C16.41,5.88 17.25,6.15 17.25,6.15C17.8,7.5 17.45,8.54 17.35,8.79C18,9.5 18.38,10.39 18.38,11.5C18.38,15.32 16.04,16.16 13.81,16.41C14.17,16.72 14.5,17.33 14.5,18.26C14.5,19.6 14.5,20.68 14.5,21C14.5,21.27 14.66,21.59 15.17,21.5C19.14,20.16 22,16.42 22,12A10,10 0 0,0 12,2Z"
            />
          </svg>
        </:start_icon>
        Login with GitHub
      </.button>

      <.button class="border-[#e5e5e5] bg-white text-black">
        <:start_icon>
          <svg aria-label="Google logo" width="16" height="16" viewBox="0 0 512 512">
            <g>
              <path d="m0 0H512V512H0" fill="#fff" />
              <path fill="#34a853" d="M153 292c30 82 118 95 171 60h62v48A192 192 0 0190 341" />
              <path fill="#4285f4" d="m386 400a140 175 0 0053-179H260v74h102q-7 37-38 57" />
              <path fill="#fbbc02" d="m90 341a208 200 0 010-171l63 49q-12 37 0 73" />
              <path fill="#ea4335" d="m153 219c22-69 116-109 179-50l55-54c-78-75-230-72-297 55" />
            </g>
          </svg>
        </:start_icon>
        Login with Google
      </.button>

      <.button class="border-black bg-black text-white">
        <:start_icon>
          <svg aria-label="Apple logo" width="16" height="16" viewBox="0 0 1195 1195">
            <path
              fill="white"
              d="M1006.933 812.8c-32 153.6-115.2 211.2-147.2 249.6-32 25.6-121.6 25.6-153.6 6.4-38.4-25.6-134.4-25.6-166.4 0-44.8 32-115.2 19.2-128 12.8-256-179.2-352-716.8 12.8-774.4 64-12.8 134.4 32 134.4 32 51.2 25.6 70.4 12.8 115.2-6.4 96-44.8 243.2-44.8 313.6 76.8-147.2 96-153.6 294.4 19.2 403.2zM802.133 64c12.8 70.4-64 224-204.8 230.4-12.8-38.4 32-217.6 204.8-230.4z"
            />
          </svg>
        </:start_icon>
        Login with Apple
      </.button>

      <.button class="border-[#005fd8] bg-[#1A77F2] text-white">
        <:start_icon>
          <svg aria-label="Facebook logo" width="16" height="16" viewBox="0 0 32 32">
            <path
              fill="white"
              d="M8 12h5V8c0-2.96.92-5 5.03-5H21v5h-3c-1 0-1 1-1 1v3h4l-.5 5H17v12h-4V17H8z"
            />
          </svg>
        </:start_icon>
        Login with Facebook
      </.button>
    </div>
    """
  end

  def example(%{section: "button-submit"} = assigns) do
    ~H"""
    <form phx-submit="daisyui_switch_submit" class="flex items-center gap-3">
      <input type="hidden" name="saved" value="yes" />
      <.button type="submit" class="d-btn-primary">Save</.button>
      <.button type="reset" class="d-btn-ghost">Reset</.button>
    </form>
    """
  end

  # ── alert ─────────────────────────────────────────────────────────────────
  def example(%{section: "alert-hero"} = assigns) do
    ~H"""
    <.alert id="daisyui-alert-hero" class="w-full">
      <:icon><.alert_icon kind="info" class="text-info" /></:icon>
      12 unread messages. Tap to see.
    </.alert>
    """
  end

  def example(%{section: "alert-info"} = assigns) do
    ~H"""
    <.alert id="daisyui-alert-info" class="w-full d-alert-info">
      <:icon><.alert_icon kind="info" /></:icon>
      New software update available.
    </.alert>
    """
  end

  def example(%{section: "alert-success"} = assigns) do
    ~H"""
    <.alert id="daisyui-alert-success" class="w-full d-alert-success">
      <:icon><.alert_icon kind="success" /></:icon>
      Your purchase has been confirmed!
    </.alert>
    """
  end

  def example(%{section: "alert-warning"} = assigns) do
    ~H"""
    <.alert id="daisyui-alert-warning" class="w-full d-alert-warning">
      <:icon><.alert_icon kind="warning" /></:icon>
      Warning: Invalid email address!
    </.alert>
    """
  end

  def example(%{section: "alert-error"} = assigns) do
    ~H"""
    <.alert id="daisyui-alert-error" class="w-full d-alert-error">
      <:icon><.alert_icon kind="error" /></:icon>
      Error! Task failed successfully.
    </.alert>
    """
  end

  def example(%{section: "alert-soft"} = assigns) do
    assigns = assign(assigns, :alerts, alert_messages())

    ~H"""
    <div class="flex w-full flex-col gap-2">
      <.alert
        :for={{color, message} <- @alerts}
        id={"daisyui-alert-soft-#{color}"}
        class={"d-alert-soft d-alert-#{color}"}
      >
        {message}
      </.alert>
    </div>
    """
  end

  def example(%{section: "alert-outline"} = assigns) do
    assigns = assign(assigns, :alerts, alert_messages())

    ~H"""
    <div class="flex w-full flex-col gap-2">
      <.alert
        :for={{color, message} <- @alerts}
        id={"daisyui-alert-outline-#{color}"}
        class={"d-alert-outline d-alert-#{color}"}
      >
        {message}
      </.alert>
    </div>
    """
  end

  def example(%{section: "alert-dash"} = assigns) do
    assigns = assign(assigns, :alerts, alert_messages())

    ~H"""
    <div class="flex w-full flex-col gap-2">
      <.alert
        :for={{color, message} <- @alerts}
        id={"daisyui-alert-dash-#{color}"}
        class={"d-alert-dash d-alert-#{color}"}
      >
        {message}
      </.alert>
    </div>
    """
  end

  def example(%{section: "alert-actions"} = assigns) do
    ~H"""
    <.alert id="daisyui-alert-actions" class="w-full d-alert-vertical sm:d-alert-horizontal">
      <:icon><.alert_icon kind="info" class="text-info" /></:icon>
      we use cookies for no reason.
      <:actions>
        <.button class="d-btn-sm">Deny</.button>
        <.button class="d-btn-sm d-btn-primary">Accept</.button>
      </:actions>
    </.alert>
    """
  end

  def example(%{section: "alert-title"} = assigns) do
    ~H"""
    <.alert id="daisyui-alert-title" class="w-full d-alert-vertical sm:d-alert-horizontal">
      <:icon><.alert_icon kind="info" class="text-info" /></:icon>
      <:title>New message!</:title>
      You have 1 unread message
      <:actions>
        <.button class="d-btn-sm">See</.button>
      </:actions>
    </.alert>
    """
  end

  def example(%{section: "alert-urgency"} = assigns) do
    ~H"""
    <div class="flex w-full flex-col gap-2">
      <.alert id="daisyui-alert-polite" urgency="polite" class="d-alert-info">
        polite — role="status", waits its turn
      </.alert>
      <.alert id="daisyui-alert-assertive" urgency="assertive" class="d-alert-error">
        assertive — role="alert", interrupts
      </.alert>
      <.alert id="daisyui-alert-off" urgency="off">
        off — a plain region, for a message already on the page
      </.alert>
    </div>
    """
  end

  def example(%{section: "alert-dismissible"} = assigns) do
    ~H"""
    <.alert id="daisyui-alert-dismiss" class="w-full d-alert-success" dismissible>
      <:icon><.nav_icon path="M20 6 9 17l-5-5" /></:icon>
      Saved. Dismiss me — no round trip.
    </.alert>
    """
  end

  # ── select ────────────────────────────────────────────────────────────────
  def example(%{section: "select-hero"} = assigns) do
    ~H"""
    <.select id="daisyui-select-hero" label="Apple" placeholder="Select apple" value="fuji">
      <:option value="gala">Gala</:option>
      <:option value="fuji">Fuji</:option>
      <:option value="honeycrisp">Honeycrisp</:option>
      <:option value="granny-smith">Granny Smith</:option>
      <:option value="pink-lady">Pink Lady</:option>
    </.select>
    """
  end

  def example(%{section: "select-ghost"} = assigns) do
    ~H"""
    <.select
      id="daisyui-select-ghost"
      placeholder="Pick a font"
      trigger_class="d-select-ghost"
    >
      <:option value="inter">Inter</:option>
      <:option value="mono">JetBrains Mono</:option>
      <:option value="serif">Source Serif</:option>
    </.select>
    """
  end

  def example(%{section: "select-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-3">
      <.select
        :for={color <- @colors}
        id={"daisyui-select-#{color}"}
        placeholder={color}
        class="w-44"
        trigger_class={"d-select-#{color}"}
      >
        <:option value="one">One</:option>
        <:option value="two">Two</:option>
      </.select>
    </div>
    """
  end

  def example(%{section: "select-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-col items-start gap-3">
      <.select
        :for={size <- @sizes}
        id={"daisyui-select-size-#{size}"}
        placeholder={size_label(size)}
        class="w-56"
        trigger_class={"d-select-#{size}"}
      >
        <:option value="apple">{size_label(size)} Apple</:option>
        <:option value="orange">{size_label(size)} Orange</:option>
        <:option value="tomato">{size_label(size)} Tomato</:option>
      </.select>
    </div>
    """
  end

  def example(%{section: "select-disabled"} = assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-3">
      <.select id="daisyui-select-disabled" placeholder="You can't touch this" disabled>
        <:option value="one">One</:option>
      </.select>
      <.select id="daisyui-select-option-disabled" placeholder="One option is out">
        <:option value="one">Available</:option>
        <:option value="two" disabled>Sold out</:option>
      </.select>
    </div>
    """
  end

  def example(%{section: "select-grouped"} = assigns) do
    ~H"""
    <.select id="daisyui-select-grouped" label="Produce" placeholder="Select produce">
      <:option value="gala" group="Apples">Gala</:option>
      <:option value="fuji" group="Apples">Fuji</:option>
      <:option value="honeycrisp" group="Apples">Honeycrisp</:option>
      <:option value="bartlett" group="Pears">Bartlett</:option>
      <:option value="bosc" group="Pears">Bosc</:option>
      <:option value="comice" group="Pears" disabled>Comice (out of stock)</:option>
    </.select>
    """
  end

  def example(%{section: "select-multiple"} = assigns) do
    ~H"""
    <.select
      id="daisyui-select-multiple"
      label="Languages"
      placeholder="Select languages"
      multiple
      value={["javascript", "typescript"]}
    >
      <:option value="javascript">JavaScript</:option>
      <:option value="typescript">TypeScript</:option>
      <:option value="elixir">Elixir</:option>
      <:option value="rust">Rust</:option>
      <:option value="go">Go</:option>
    </.select>
    """
  end

  def example(%{section: "select-form"} = assigns) do
    ~H"""
    <form phx-submit="daisyui_select_submit" class="flex items-end gap-3">
      <.select
        id="daisyui-select-form"
        name="apple"
        label="Apple"
        placeholder="Select apple"
        value="gala"
        required
      >
        <:option value="gala">Gala</:option>
        <:option value="fuji">Fuji</:option>
        <:option value="honeycrisp">Honeycrisp</:option>
      </.select>
      <button type="submit" class="d-btn d-btn-primary">Save</button>
    </form>
    """
  end

  # ── switch ────────────────────────────────────────────────────────────────
  def example(%{section: "switch-hero"} = assigns) do
    ~H"""
    <.switch id="daisyui-switch-hero" checked>Notifications</.switch>
    """
  end

  def example(%{section: "switch-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-col gap-3">
      <.switch
        :for={size <- @sizes}
        id={"daisyui-switch-size-#{size}"}
        checked
        class={"d-toggle-#{size}"}
      >
        toggle-{size}
      </.switch>
    </div>
    """
  end

  def example(%{section: "switch-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-4">
      <.switch
        :for={color <- @colors}
        id={"daisyui-switch-#{color}"}
        checked
        class={"d-toggle-#{color}"}
      >
        {color}
      </.switch>
    </div>
    """
  end

  def example(%{section: "switch-disabled"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <.switch id="daisyui-switch-disabled-on" checked disabled>Disabled, on</.switch>
      <.switch id="daisyui-switch-disabled-off" disabled>Disabled, off</.switch>
    </div>
    """
  end

  def example(%{section: "switch-icons"} = assigns) do
    ~H"""
    <.switch id="daisyui-switch-icons" checked class="d-toggle-lg">
      <:on_icon>
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="4" class="size-full">
          <path d="M20 6 9 17l-5-5" />
        </svg>
      </:on_icon>
      <:off_icon>
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="4" class="size-full">
          <path d="M18 6 6 18M6 6l12 12" />
        </svg>
      </:off_icon>
    </.switch>
    """
  end

  def example(%{section: "switch-custom-colors"} = assigns) do
    ~H"""
    <.switch
      id="daisyui-switch-custom"
      checked
      track_class="border-indigo-600 bg-indigo-500 text-indigo-800 data-[checked]:border-orange-500 data-[checked]:bg-orange-400 data-[checked]:text-orange-800"
    >
      Custom colors
    </.switch>
    """
  end

  def example(%{section: "switch-form"} = assigns) do
    ~H"""
    <form phx-submit="daisyui_switch_submit" class="flex flex-col items-start gap-3">
      <fieldset class="d-fieldset">
        <legend class="d-fieldset-legend">Notify me about</legend>
        <.switch id="daisyui-switch-form-email" name="email" checked>Email</.switch>
        <.switch id="daisyui-switch-form-push" name="push">Push</.switch>
        <.switch id="daisyui-switch-form-sms" name="sms">SMS</.switch>
      </fieldset>
      <button type="submit" class="d-btn d-btn-primary d-btn-sm">Save</button>
    </form>
    """
  end

  # ── checkbox ──────────────────────────────────────────────────────────────
  def example(%{section: "checkbox-hero"} = assigns) do
    ~H"""
    <.checkbox id="daisyui-checkbox-hero" checked>Enable notifications</.checkbox>
    """
  end

  def example(%{section: "checkbox-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-col gap-3">
      <.checkbox
        :for={size <- @sizes}
        id={"daisyui-checkbox-size-#{size}"}
        checked
        indicator_class={"d-checkbox-#{size}"}
      >
        checkbox-{size}
      </.checkbox>
    </div>
    """
  end

  def example(%{section: "checkbox-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-4">
      <.checkbox
        :for={color <- @colors}
        id={"daisyui-checkbox-#{color}"}
        checked
        indicator_class={"d-checkbox-#{color}"}
      >
        {color}
      </.checkbox>
    </div>
    """
  end

  def example(%{section: "checkbox-disabled"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <.checkbox id="daisyui-checkbox-disabled-on" checked disabled>Disabled, checked</.checkbox>
      <.checkbox id="daisyui-checkbox-disabled-off" disabled>Disabled, unchecked</.checkbox>
    </div>
    """
  end

  def example(%{section: "checkbox-indeterminate"} = assigns) do
    ~H"""
    <.checkbox id="daisyui-checkbox-mixed" indeterminate>Some selected</.checkbox>
    """
  end

  def example(%{section: "checkbox-custom-colors"} = assigns) do
    ~H"""
    <.checkbox
      id="daisyui-checkbox-custom"
      checked
      indicator_class="border-indigo-600 bg-indigo-500 text-indigo-800 data-[checked]:border-orange-500 data-[checked]:bg-orange-400 data-[checked]:text-orange-800"
    >
      Custom colors
    </.checkbox>
    """
  end

  def example(%{section: "checkbox-form"} = assigns) do
    ~H"""
    <form phx-submit="daisyui_checkbox_submit" class="flex flex-col items-start gap-3">
      <fieldset class="d-fieldset">
        <legend class="d-fieldset-legend">Include in export</legend>
        <.checkbox id="daisyui-checkbox-form-posts" name="posts" value="posts" checked>
          Posts
        </.checkbox>
        <.checkbox id="daisyui-checkbox-form-media" name="media" value="media">Media</.checkbox>
        <.checkbox id="daisyui-checkbox-form-users" name="users" value="users">Users</.checkbox>
      </fieldset>
      <button type="submit" class="d-btn d-btn-primary d-btn-sm">Export</button>
    </form>
    """
  end

  # ── dialog ────────────────────────────────────────────────────────────────
  def example(%{section: "dialog-hero"} = assigns) do
    ~H"""
    <.dialog id="daisyui-dialog-hero">
      <:trigger>View notifications</:trigger>
      <:title>Notifications</:title>
      <:description>You are all caught up. Good job!</:description>
      <:close>
        <button type="button" data-close class="d-btn">Close</button>
      </:close>
    </.dialog>
    """
  end

  def example(%{section: "dialog-non-dismissible"} = assigns) do
    ~H"""
    <.dialog id="daisyui-dialog-sticky" dismissible={false}>
      <:trigger>Delete workspace</:trigger>
      <:title>Delete this workspace?</:title>
      <:description>
        Every project, deployment and API key in it goes with it. This cannot be undone.
      </:description>
      <:close>
        <button type="button" data-close class="d-btn d-btn-ghost">Cancel</button>
        <button type="button" data-close class="d-btn d-btn-error">Delete</button>
      </:close>
    </.dialog>
    """
  end

  def example(%{section: "dialog-close-corner"} = assigns) do
    ~H"""
    <.dialog id="daisyui-dialog-corner" footer_class="!mt-0 absolute right-2 top-2">
      <:trigger>Open</:trigger>
      <:title>Press ESC or click ✕ to close</:title>
      <:description>The close button is the footer part, pinned to the corner.</:description>
      <:close>
        <button type="button" data-close class="d-btn d-btn-sm d-btn-circle d-btn-ghost">✕</button>
      </:close>
    </.dialog>
    """
  end

  def example(%{section: "dialog-wide"} = assigns) do
    ~H"""
    <.dialog id="daisyui-dialog-wide" popup_class="w-11/12 max-w-5xl">
      <:trigger>Open wide dialog</:trigger>
      <:title>Release notes</:title>
      <:description>
        This popup uses daisyUI's own width recipe on the popup part, so it stays a modal-box.
      </:description>
      <:close>
        <button type="button" data-close class="d-btn">Close</button>
      </:close>
    </.dialog>
    """
  end

  def example(%{section: "dialog-responsive"} = assigns) do
    ~H"""
    <.dialog
      id="daisyui-dialog-responsive"
      viewport_class="items-end sm:items-center"
      popup_class="w-full max-w-none rounded-b-none sm:w-11/12 sm:max-w-lg sm:rounded-box"
    >
      <:trigger>Open responsive dialog</:trigger>
      <:title>Bottom sheet on mobile</:title>
      <:description>Resize the window — above `sm` it becomes a centered card.</:description>
      <:close>
        <button type="button" data-close class="d-btn">Close</button>
      </:close>
    </.dialog>
    """
  end

  # ── tabs ──────────────────────────────────────────────────────────────────
  def example(%{section: "tabs-hero"} = assigns) do
    ~H"""
    <.tabs id="daisyui-tabs-hero" default_value="overview">
      <:tab value="overview">Overview</:tab>
      <:tab value="projects">Projects</:tab>
      <:tab value="account">Account</:tab>
      <:panel value="overview">Workspace stats and activity.</:panel>
      <:panel value="projects">Milestones and deadlines.</:panel>
      <:panel value="account">Billing, members and API keys.</:panel>
    </.tabs>
    """
  end

  def example(%{section: "tabs-plain"} = assigns) do
    ~H"""
    <.tabs id="daisyui-tabs-plain" default_value="overview" list_class="d-tabs">
      <:tab value="overview" class="d-tab">Overview</:tab>
      <:tab value="projects" class="d-tab">Projects</:tab>
      <:tab value="account" class="d-tab">Account</:tab>
      <:panel value="overview">Workspace stats and activity.</:panel>
      <:panel value="projects">Milestones and deadlines.</:panel>
      <:panel value="account">Billing, members and API keys.</:panel>
    </.tabs>
    """
  end

  def example(%{section: "tabs-border"} = assigns) do
    ~H"""
    <.tabs id="daisyui-tabs-border" default_value="overview" list_class="d-tabs d-tabs-border">
      <:tab value="overview" class="d-tab">Overview</:tab>
      <:tab value="projects" class="d-tab">Projects</:tab>
      <:tab value="account" class="d-tab">Account</:tab>
      <:panel value="overview">Workspace stats and activity.</:panel>
      <:panel value="projects">Milestones and deadlines.</:panel>
      <:panel value="account">Billing, members and API keys.</:panel>
    </.tabs>
    """
  end

  def example(%{section: "tabs-lift"} = assigns) do
    ~H"""
    <.tabs id="daisyui-tabs-lift" default_value="overview" list_class="d-tabs d-tabs-lift">
      <:tab value="overview" class="d-tab">Overview</:tab>
      <:tab value="projects" class="d-tab">Projects</:tab>
      <:tab value="account" class="d-tab">Account</:tab>
      <:panel value="overview">Workspace stats and activity.</:panel>
      <:panel value="projects">Milestones and deadlines.</:panel>
      <:panel value="account">Billing, members and API keys.</:panel>
    </.tabs>
    """
  end

  def example(%{section: "tabs-box"} = assigns) do
    ~H"""
    <.tabs id="daisyui-tabs-box" default_value="overview" list_class="d-tabs d-tabs-box">
      <:tab value="overview" class="d-tab">Overview</:tab>
      <:tab value="projects" class="d-tab">Projects</:tab>
      <:tab value="account" class="d-tab">Account</:tab>
      <:panel value="overview">Workspace stats and activity.</:panel>
      <:panel value="projects">Milestones and deadlines.</:panel>
      <:panel value="account">Billing, members and API keys.</:panel>
    </.tabs>
    """
  end

  def example(%{section: "tabs-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-col gap-6">
      <.tabs
        :for={size <- @sizes}
        id={"daisyui-tabs-size-#{size}"}
        default_value="one"
        list_class={"d-tabs d-tabs-lift d-tabs-#{size}"}
      >
        <:tab value="one" class="d-tab">tabs-{size}</:tab>
        <:tab value="two" class="d-tab">Two</:tab>
        <:panel value="one">First panel.</:panel>
        <:panel value="two">Second panel.</:panel>
      </.tabs>
    </div>
    """
  end

  def example(%{section: "tabs-bottom"} = assigns) do
    ~H"""
    <.tabs
      id="daisyui-tabs-bottom"
      default_value="overview"
      class="flex-col-reverse"
      list_class="d-tabs d-tabs-lift d-tabs-bottom"
      panels_class="!pt-0 pb-4"
    >
      <:tab value="overview" class="d-tab">Overview</:tab>
      <:tab value="projects" class="d-tab">Projects</:tab>
      <:panel value="overview">Workspace stats and activity.</:panel>
      <:panel value="projects">Milestones and deadlines.</:panel>
    </.tabs>
    """
  end

  def example(%{section: "tabs-scroll"} = assigns) do
    ~H"""
    <div class="max-w-60 overflow-x-auto">
      <.tabs
        id="daisyui-tabs-scroll"
        default_value="one"
        list_class="d-tabs d-tabs-lift min-w-max"
      >
        <:tab value="one" class="d-tab">Tab title 1</:tab>
        <:tab value="two" class="d-tab">Tab title 2</:tab>
        <:tab value="three" class="d-tab">Tab title 3</:tab>
        <:tab value="four" class="d-tab">Tab title 4</:tab>
        <:panel value="one" class="max-w-60">Tab content 1</:panel>
        <:panel value="two" class="max-w-60">Tab content 2</:panel>
        <:panel value="three" class="max-w-60">Tab content 3</:panel>
        <:panel value="four" class="max-w-60">Tab content 4</:panel>
      </.tabs>
    </div>
    """
  end

  def example(%{section: "tabs-custom-color"} = assigns) do
    ~H"""
    <.tabs id="daisyui-tabs-custom" default_value="overview" list_class="d-tabs d-tabs-lift">
      <:tab value="overview" class="d-tab text-primary [--tab-bg:orange] [--tab-border-color:red]">
        Overview
      </:tab>
      <:tab value="projects" class="d-tab">Projects</:tab>
      <:panel value="overview">Workspace stats and activity.</:panel>
      <:panel value="projects">Milestones and deadlines.</:panel>
    </.tabs>
    """
  end

  def example(%{section: "tabs-vertical"} = assigns) do
    ~H"""
    <.tabs id="daisyui-tabs-vertical" default_value="general" orientation="vertical">
      <:tab value="general">General</:tab>
      <:tab value="members">Members</:tab>
      <:tab value="billing" disabled>Billing</:tab>
      <:panel value="general">Workspace name, region and defaults.</:panel>
      <:panel value="members">Invite people and manage their roles.</:panel>
      <:panel value="billing">Plan and invoices.</:panel>
    </.tabs>
    """
  end

  # ── menu ──────────────────────────────────────────────────────────────────
  def example(%{section: "menu-hero"} = assigns) do
    ~H"""
    <.menu id="daisyui-menu-hero" side_offset={8}>
      <:trigger>Song</:trigger>
      <:item>Add to Library</:item>
      <:item>Add to Playlist</:item>
      <:item type="separator" />
      <:item>Play Next</:item>
      <:item>Play Last</:item>
      <:item type="separator" />
      <:item>Favorite</:item>
      <:item disabled>Share</:item>
    </.menu>
    """
  end

  def example(%{section: "menu-placement"} = assigns) do
    assigns =
      assign(assigns, :placements, [
        {"bottom", "start"},
        {"bottom", "center"},
        {"bottom", "end"},
        {"top", "center"},
        {"left", "center"},
        {"right", "center"}
      ])

    ~H"""
    <div class="flex flex-wrap gap-3">
      <.menu
        :for={{side, align} <- @placements}
        id={"daisyui-menu-#{side}-#{align}"}
        side={side}
        align={align}
        side_offset={8}
      >
        <:trigger>{side}/{align}</:trigger>
        <:item>Item one</:item>
        <:item>Item two</:item>
      </.menu>
    </div>
    """
  end

  def example(%{section: "menu-hover"} = assigns) do
    ~H"""
    <.menu id="daisyui-menu-hover" open_on_hover side_offset={8}>
      <:trigger>Hover me</:trigger>
      <:item>Item one</:item>
      <:item>Item two</:item>
    </.menu>
    """
  end

  def example(%{section: "menu-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-wrap gap-3">
      <.menu
        :for={size <- @sizes}
        id={"daisyui-menu-size-#{size}"}
        side_offset={8}
        popup_class={"d-menu-#{size}"}
      >
        <:trigger>menu-{size}</:trigger>
        <:item>Item one</:item>
        <:item>Item two</:item>
      </.menu>
    </div>
    """
  end

  def example(%{section: "menu-icons"} = assigns) do
    assigns = assign(assigns, :nav, @nav)

    ~H"""
    <.menu id="daisyui-menu-icons" side_offset={8}>
      <:trigger>Workspace</:trigger>
      <:item :for={{label, path} <- @nav}>
        <.nav_icon path={path} />
        {label}
      </:item>
    </.menu>
    """
  end

  def example(%{section: "menu-icons-only"} = assigns) do
    assigns = assign(assigns, :nav, @nav)

    ~H"""
    <.menu id="daisyui-menu-icons-only" side_offset={8} popup_class="!min-w-0 w-fit">
      <:trigger>Rail</:trigger>
      <:item :for={{label, path} <- @nav} label={label}>
        <.nav_icon path={path} />
      </:item>
    </.menu>
    """
  end

  def example(%{section: "menu-icons-tooltip"} = assigns) do
    assigns = assign(assigns, :nav, @nav)

    ~H"""
    <.menu id="daisyui-menu-tooltip" side_offset={8} popup_class="!min-w-0 w-fit">
      <:trigger>Rail</:trigger>
      <.menu_item
        :for={{label, path} <- @nav}
        label={label}
        class="d-tooltip d-tooltip-right"
        data-tip={label}
      >
        <.nav_icon path={path} />
      </.menu_item>
    </.menu>
    """
  end

  def example(%{section: "menu-badges"} = assigns) do
    ~H"""
    <.menu id="daisyui-menu-badges" side_offset={8}>
      <:trigger>Inbox</:trigger>
      <:item>
        <.nav_icon path="M3 8l9 6 9-6M3 8v8h18V8" /> Messages
        <span class="d-badge d-badge-xs d-badge-info">12</span>
      </:item>
      <:item>
        <.nav_icon path="M12 3v18M3 12h18" /> Drafts
        <span class="d-badge d-badge-xs d-badge-warning">2</span>
      </:item>
      <:item><.nav_icon path="M4 7h16v12H4z" /> Archive</:item>
    </.menu>
    """
  end

  def example(%{section: "menu-active"} = assigns) do
    ~H"""
    <.menu id="daisyui-menu-active" side_offset={8}>
      <:trigger>Section</:trigger>
      <:item>Overview</:item>
      <:item class="d-menu-active">Projects</:item>
      <:item>Settings</:item>
    </.menu>
    """
  end

  def example(%{section: "menu-disabled"} = assigns) do
    ~H"""
    <.menu id="daisyui-menu-disabled" side_offset={8}>
      <:trigger>Actions</:trigger>
      <:item>Rename</:item>
      <:item>Duplicate</:item>
      <:item disabled>Transfer (owner only)</:item>
      <:item>Delete</:item>
    </.menu>
    """
  end

  def example(%{section: "menu-title"} = assigns) do
    ~H"""
    <.menu id="daisyui-menu-title" side_offset={8}>
      <:trigger>Account</:trigger>
      <.menu_group id="daisyui-menu-title-group" label="Signed in as shahryar">
        <.menu_item>Profile</.menu_item>
        <.menu_item>Billing</.menu_item>
        <.menu_item>Sign out</.menu_item>
      </.menu_group>
    </.menu>
    """
  end

  def example(%{section: "menu-title-parent"} = assigns) do
    ~H"""
    <.menu id="daisyui-menu-title-parent" side_offset={8}>
      <:trigger>Docs</:trigger>
      <.menu_group id="daisyui-menu-parent-a" label="Getting started">
        <.menu_item>Install</.menu_item>
        <.menu_item>Configure</.menu_item>
      </.menu_group>
      <.menu_group id="daisyui-menu-parent-b" label="Components">
        <.menu_item>Accordion</.menu_item>
        <.menu_item>Select</.menu_item>
      </.menu_group>
    </.menu>
    """
  end

  def example(%{section: "menu-submenu"} = assigns) do
    ~H"""
    <.menu id="daisyui-menu-submenu" side_offset={8}>
      <:trigger>File</:trigger>
      <.menu_item>New</.menu_item>
      <.menu_submenu id="daisyui-menu-submenu-open" label="Open recent">
        <.menu_item>chelekom.ex</.menu_item>
        <.menu_item>app.css</.menu_item>
      </.menu_submenu>
      <.menu_item>Save</.menu_item>
    </.menu>
    """
  end

  def example(%{section: "menu-file-tree"} = assigns) do
    ~H"""
    <.menu id="daisyui-menu-tree" side_offset={8} popup_class="d-menu-xs w-60">
      <:trigger>Files</:trigger>
      <.menu_submenu id="daisyui-menu-tree-lib" label="lib">
        <.menu_submenu id="daisyui-menu-tree-web" label="my_app_web">
          <.menu_item>router.ex</.menu_item>
          <.menu_item>endpoint.ex</.menu_item>
        </.menu_submenu>
        <.menu_item>application.ex</.menu_item>
      </.menu_submenu>
      <.menu_submenu id="daisyui-menu-tree-assets" label="assets">
        <.menu_item>app.css</.menu_item>
        <.menu_item>app.js</.menu_item>
      </.menu_submenu>
      <.menu_item>mix.exs</.menu_item>
    </.menu>
    """
  end

  def example(%{section: "menu-horizontal-submenu"} = assigns) do
    ~H"""
    <.menu
      id="daisyui-menu-horizontal-submenu"
      side_offset={8}
      popup_class="d-menu-horizontal !min-w-0"
    >
      <:trigger>Toolbar</:trigger>
      <.menu_item>Cut</.menu_item>
      <.menu_submenu id="daisyui-menu-horizontal-submenu-paste" label="Paste as">
        <.menu_item>Plain text</.menu_item>
        <.menu_item>Markdown</.menu_item>
      </.menu_submenu>
      <.menu_item>Copy</.menu_item>
    </.menu>
    """
  end

  def example(%{section: "menu-horizontal"} = assigns) do
    ~H"""
    <.menu id="daisyui-menu-horizontal" side_offset={8} popup_class="d-menu-horizontal !min-w-0">
      <:trigger>Toolbar</:trigger>
      <:item>Cut</:item>
      <:item>Copy</:item>
      <:item>Paste</:item>
    </.menu>
    """
  end

  def example(%{section: "menu-responsive"} = assigns) do
    ~H"""
    <.menu
      id="daisyui-menu-responsive"
      side_offset={8}
      popup_class="d-menu-vertical lg:d-menu-horizontal lg:!min-w-0"
    >
      <:trigger>Responsive</:trigger>
      <:item>Overview</:item>
      <:item>Projects</:item>
      <:item>Settings</:item>
    </.menu>
    """
  end

  def example(%{section: "menu-flush"} = assigns) do
    ~H"""
    <.menu
      id="daisyui-menu-flush"
      side_offset={8}
      popup_class="!p-0 overflow-hidden [&_[data-part=item]]:rounded-none"
    >
      <:trigger>Flush</:trigger>
      <:item>Overview</:item>
      <:item>Projects</:item>
      <:item>Settings</:item>
    </.menu>
    """
  end

  def example(%{section: "menu-rich"} = assigns) do
    ~H"""
    <.menu id="daisyui-menu-rich" side_offset={8}>
      <:trigger>View options</:trigger>
      <.menu_group id="daisyui-menu-panels" label="Panels">
        <.menu_checkbox checked>Sidebar</.menu_checkbox>
        <.menu_checkbox>Terminal</.menu_checkbox>
      </.menu_group>
      <.menu_separator />
      <.menu_radio_group id="daisyui-menu-sort" label="Sort by">
        <.menu_radio name="sort" value="name" checked>Name</.menu_radio>
        <.menu_radio name="sort" value="date">Date modified</.menu_radio>
      </.menu_radio_group>
      <.menu_separator />
      <.menu_submenu id="daisyui-menu-share" label="Share">
        <.menu_link href="#">Copy link</.menu_link>
        <.menu_item>Email</.menu_item>
      </.menu_submenu>
    </.menu>
    """
  end

  def example(%{section: "menu-card"} = assigns) do
    ~H"""
    <.menu id="daisyui-menu-card" side_offset={8} popup_class="w-64 !p-0">
      <:trigger>Account</:trigger>
      <div class="d-card d-card-sm">
        <div class="d-card-body">
          <h3 class="d-card-title text-sm">Signed in as</h3>
          <p class="text-xs opacity-60">shahryar@mishka.tools</p>
          <div class="d-card-actions justify-end pt-2">
            <button type="button" class="d-btn d-btn-xs d-btn-primary">Manage</button>
          </div>
        </div>
      </div>
    </.menu>
    """
  end

  # ── breadcrumb ────────────────────────────────────────────────────────────
  def example(%{section: "breadcrumb-hero"} = assigns) do
    ~H"""
    <.breadcrumb id="daisyui-breadcrumb-hero">
      <:item href="#">Home</:item>
      <:item href="#">Documents</:item>
      <:item>Add document</:item>
    </.breadcrumb>
    """
  end

  def example(%{section: "breadcrumb-icons"} = assigns) do
    ~H"""
    <.breadcrumb id="daisyui-breadcrumb-icons">
      <:item href="#">
        <.field_icon path="M3 11l9-8 9 8M5 10v10h14V10" /> Home
      </:item>
      <:item href="#">
        <.field_icon path="M3 7h6l2 2h10v10H3z" /> Documents
      </:item>
      <:item>
        <.field_icon path="M7 3h7l5 5v13H7zM14 3v5h5" /> Add document
      </:item>
    </.breadcrumb>
    """
  end

  def example(%{section: "breadcrumb-max-width"} = assigns) do
    ~H"""
    <.breadcrumb id="daisyui-breadcrumb-max-width" class="max-w-xs">
      <:item href="#">Long text 1</:item>
      <:item href="#">Long text 2</:item>
      <:item href="#">Long text 3</:item>
      <:item href="#">Long text 4</:item>
      <:item>Long text 5</:item>
    </.breadcrumb>
    """
  end

  def example(%{section: "breadcrumb-separator"} = assigns) do
    ~H"""
    <.breadcrumb id="daisyui-breadcrumb-separator">
      <:separator><span class="px-2 opacity-40">›</span></:separator>
      <:item href="#">Home</:item>
      <:item href="#">Library</:item>
      <:item>Data</:item>
    </.breadcrumb>
    """
  end

  def example(%{section: "breadcrumb-collapsed"} = assigns) do
    ~H"""
    <.breadcrumb id="daisyui-breadcrumb-collapsed" max_items={4}>
      <:item href="#">Home</:item>
      <:item href="#">Projects</:item>
      <:item href="#">Chelekom</:item>
      <:item href="#">Headless</:item>
      <:item href="#">Components</:item>
      <:item>Breadcrumb</:item>
    </.breadcrumb>
    """
  end

  def example(%{section: "breadcrumb-expandable"} = assigns) do
    ~H"""
    <.breadcrumb
      id="daisyui-breadcrumb-expandable"
      max_items={3}
      boundary={1}
      on_expand="daisyui_breadcrumb_expand"
    >
      <:item href="#">Home</:item>
      <:item href="#">Projects</:item>
      <:item href="#">Chelekom</:item>
      <:item href="#">Headless</:item>
      <:item>Breadcrumb</:item>
    </.breadcrumb>
    """
  end

  # ── calendar ──────────────────────────────────────────────────────────────
  def example(%{section: "calendar-hero"} = assigns) do
    ~H"""
    <.calendar id="daisyui-calendar-hero" month={~D[2026-03-01]} today={~D[2026-03-17]} />
    """
  end

  def example(%{section: "calendar-selected"} = assigns) do
    ~H"""
    <.calendar
      id="daisyui-calendar-selected"
      month={~D[2026-03-01]}
      today={~D[2026-03-17]}
      value={~D[2026-03-12]}
    />
    """
  end

  def example(%{section: "calendar-range"} = assigns) do
    ~H"""
    <.calendar
      id="daisyui-calendar-range"
      mode="range"
      month={~D[2026-03-01]}
      today={~D[2026-03-17]}
      value={{~D[2026-03-09], ~D[2026-03-18]}}
    />
    """
  end

  def example(%{section: "calendar-multiple"} = assigns) do
    ~H"""
    <.calendar
      id="daisyui-calendar-multiple"
      mode="multiple"
      month={~D[2026-03-01]}
      today={~D[2026-03-17]}
      value={[~D[2026-03-03], ~D[2026-03-11], ~D[2026-03-24]]}
    />
    """
  end

  def example(%{section: "calendar-bounds"} = assigns) do
    ~H"""
    <.calendar
      id="daisyui-calendar-bounds"
      month={~D[2026-03-01]}
      today={~D[2026-03-17]}
      min={~D[2026-03-05]}
      max={~D[2026-03-25]}
    />
    """
  end

  def example(%{section: "calendar-disabled-dates"} = assigns) do
    ~H"""
    <.calendar
      id="daisyui-calendar-disabled-dates"
      month={~D[2026-03-01]}
      today={~D[2026-03-17]}
      disabled_dates={[~D[2026-03-14], ~D[2026-03-15], ~D[2026-03-21], ~D[2026-03-22]]}
    />
    """
  end

  def example(%{section: "calendar-sunday"} = assigns) do
    ~H"""
    <.calendar
      id="daisyui-calendar-sunday"
      month={~D[2026-03-01]}
      today={~D[2026-03-17]}
      first_day_of_week={7}
    />
    """
  end

  def example(%{section: "calendar-compact"} = assigns) do
    ~H"""
    <.calendar
      id="daisyui-calendar-compact"
      month={~D[2027-02-01]}
      today={~D[2027-02-17]}
      show_outside_days={false}
      fixed_weeks={false}
    />
    """
  end

  def example(%{section: "calendar-live"} = assigns) do
    ~H"""
    <.calendar
      id="daisyui-calendar-live"
      month={~D[2026-03-01]}
      today={~D[2026-03-17]}
      on_select="daisyui_calendar_select"
      on_month_change="daisyui_calendar_month"
    />
    """
  end

  # ── carousel ──────────────────────────────────────────────────────────────
  def example(%{section: "carousel-hero"} = assigns) do
    ~H"""
    <.carousel id="daisyui-carousel-hero" label="Photos" class="w-80">
      <:slide :for={n <- 1..5} class="w-48"><.carousel_slide n={n} /></:slide>
    </.carousel>
    """
  end

  def example(%{section: "carousel-center"} = assigns) do
    ~H"""
    <.carousel id="daisyui-carousel-center" label="Photos" snap="center" class="w-80">
      <:slide :for={n <- 1..5} class="w-48"><.carousel_slide n={n} /></:slide>
    </.carousel>
    """
  end

  def example(%{section: "carousel-end"} = assigns) do
    ~H"""
    <.carousel id="daisyui-carousel-end" label="Photos" snap="end" class="w-80">
      <:slide :for={n <- 1..5} class="w-48"><.carousel_slide n={n} /></:slide>
    </.carousel>
    """
  end

  def example(%{section: "carousel-full"} = assigns) do
    ~H"""
    <.carousel id="daisyui-carousel-full" label="Photos" class="w-80">
      <:slide :for={n <- 1..4} class="w-full"><.carousel_slide n={n} /></:slide>
    </.carousel>
    """
  end

  def example(%{section: "carousel-vertical"} = assigns) do
    ~H"""
    <.carousel
      id="daisyui-carousel-vertical"
      label="Photos"
      orientation="vertical"
      class="w-64"
      viewport_class="h-64"
    >
      <:slide :for={n <- 1..4} class="h-64"><.carousel_slide n={n} /></:slide>
    </.carousel>
    """
  end

  def example(%{section: "carousel-half"} = assigns) do
    ~H"""
    <.carousel id="daisyui-carousel-half" label="Photos" class="w-80">
      <:slide :for={n <- 1..6} class="w-1/2"><.carousel_slide n={n} /></:slide>
    </.carousel>
    """
  end

  def example(%{section: "carousel-full-bleed"} = assigns) do
    ~H"""
    <.carousel
      id="daisyui-carousel-full-bleed"
      label="Photos"
      snap="center"
      class="max-w-md space-x-4 rounded-box bg-neutral p-4"
    >
      <:slide :for={n <- 1..5} class="w-48"><.carousel_slide n={n} /></:slide>
    </.carousel>
    """
  end

  def example(%{section: "carousel-indicators"} = assigns) do
    ~H"""
    <.carousel id="daisyui-carousel-indicators" label="Photos" class="w-80" show_indicators>
      <:slide :for={n <- 1..4} class="w-full"><.carousel_slide n={n} /></:slide>
    </.carousel>
    """
  end

  def example(%{section: "carousel-controls"} = assigns) do
    ~H"""
    <.carousel
      id="daisyui-carousel-controls"
      label="Photos"
      class="w-80"
      show_controls
      show_indicators
    >
      <:slide :for={n <- 1..4} class="w-full"><.carousel_slide n={n} /></:slide>
    </.carousel>
    """
  end

  def example(%{section: "carousel-autoplay"} = assigns) do
    ~H"""
    <.carousel
      id="daisyui-carousel-autoplay"
      label="Photos"
      class="w-80"
      autoplay={2500}
      loop
      show_indicators
    >
      <:slide :for={n <- 1..4} class="w-full"><.carousel_slide n={n} /></:slide>
    </.carousel>
    """
  end

  def example(%{section: "carousel-live"} = assigns) do
    ~H"""
    <.carousel
      id="daisyui-carousel-live"
      label="Photos"
      class="w-80"
      show_controls
      on_change="daisyui_carousel_change"
    >
      <:slide :for={n <- 1..4} class="w-full"><.carousel_slide n={n} /></:slide>
    </.carousel>
    """
  end

  # ── table ─────────────────────────────────────────────────────────────────
  def example(%{section: "table-hero"} = assigns) do
    assigns = assign(assigns, :rows, @crew)

    ~H"""
    <.table id="daisyui-table-hero" rows={@rows} caption="Crew" row_id={&"hero-#{&1.id}"}>
      <:col :let={row} label="#" align="end">{row.id}</:col>
      <:col :let={row} label="Name" row_header>{row.name}</:col>
      <:col :let={row} label="Job">{row.job}</:col>
      <:col :let={row} label="Favorite color">{row.color}</:col>
    </.table>
    """
  end

  def example(%{section: "table-bordered"} = assigns) do
    assigns = assign(assigns, :rows, @crew)

    ~H"""
    <div class="rounded-box border border-base-content/5 bg-base-100 overflow-hidden">
      <.table id="daisyui-table-bordered" rows={@rows} caption="Crew" row_id={&"bordered-#{&1.id}"}>
        <:col :let={row} label="Name" row_header>{row.name}</:col>
        <:col :let={row} label="Job">{row.job}</:col>
      </.table>
    </div>
    """
  end

  def example(%{section: "table-active"} = assigns) do
    assigns = assign(assigns, :rows, @crew)

    ~H"""
    <.table
      id="daisyui-table-active"
      rows={@rows}
      caption="Crew"
      row_id={&"active-#{&1.id}"}
      selected={["active-2"]}
    >
      <:col :let={row} label="Name" row_header>{row.name}</:col>
      <:col :let={row} label="Job">{row.job}</:col>
    </.table>
    """
  end

  def example(%{section: "table-hover"} = assigns) do
    assigns = assign(assigns, :rows, @crew)

    ~H"""
    <.table
      id="daisyui-table-hover"
      rows={@rows}
      caption="Crew"
      row_id={&"hover-#{&1.id}"}
      row_class="d-table-row-hover"
    >
      <:col :let={row} label="Name" row_header>{row.name}</:col>
      <:col :let={row} label="Job">{row.job}</:col>
    </.table>
    """
  end

  def example(%{section: "table-zebra"} = assigns) do
    assigns = assign(assigns, :rows, @crew)

    ~H"""
    <.table
      id="daisyui-table-zebra"
      rows={@rows}
      caption="Crew"
      row_id={&"zebra-#{&1.id}"}
      class="d-table-zebra"
    >
      <:col :let={row} label="Name" row_header>{row.name}</:col>
      <:col :let={row} label="Job">{row.job}</:col>
    </.table>
    """
  end

  def example(%{section: "table-visual"} = assigns) do
    assigns = assign(assigns, :rows, @crew)

    ~H"""
    <.table id="daisyui-table-visual" rows={@rows} caption="Crew" row_id={&"visual-#{&1.id}"}>
      <:col :let={row} label="Name" row_header>
        <span class="flex items-center gap-3">
          <span class="d-badge d-badge-neutral size-8 rounded-full">{String.first(row.name)}</span>
          <span class="flex flex-col">
            <span class="font-medium">{row.name}</span>
            <span class="text-xs opacity-50">{row.job}</span>
          </span>
        </span>
      </:col>
      <:col :let={row} label="Color">
        <span class="d-badge d-badge-ghost d-badge-sm">{row.color}</span>
      </:col>
    </.table>
    """
  end

  def example(%{section: "table-xs"} = assigns) do
    assigns = assign(assigns, :rows, @crew)

    ~H"""
    <.table
      id="daisyui-table-xs"
      rows={@rows}
      caption="Crew"
      row_id={&"xs-#{&1.id}"}
      class="d-table-xs"
    >
      <:col :let={row} label="Name" row_header>{row.name}</:col>
      <:col :let={row} label="Job">{row.job}</:col>
      <:col :let={row} label="Color">{row.color}</:col>
    </.table>
    """
  end

  def example(%{section: "table-pinned"} = assigns) do
    assigns = assign(assigns, :rows, @crew ++ @crew)

    ~H"""
    <div class="h-48 overflow-x-auto">
      <.table
        id="daisyui-table-pinned"
        rows={Enum.with_index(@rows) |> Enum.map(fn {r, i} -> %{r | id: i} end)}
        caption="Crew"
        row_id={&"pinned-#{&1.id}"}
        class="d-table-pin-rows"
      >
        <:col :let={row} label="Name" row_header>{row.name}</:col>
        <:col :let={row} label="Job">{row.job}</:col>
      </.table>
    </div>
    """
  end

  def example(%{section: "table-pinned-cols"} = assigns) do
    assigns = assign(assigns, :rows, @crew)

    ~H"""
    <div class="h-48 w-full overflow-x-auto">
      <.table
        id="daisyui-table-pinned-cols"
        rows={@rows}
        caption="Crew"
        row_id={&"pincols-#{&1.id}"}
        class="d-table-pin-rows d-table-pin-cols"
      >
        <:col :let={row} label="Name" row_header>{row.name}</:col>
        <:col :let={row} label="Job">{row.job}</:col>
        <:col :let={row} label="Color">{row.color}</:col>
        <:col :let={row} label="Company">{row.company}</:col>
        <:col :let={row} label="Location">{row.location}</:col>
      </.table>
    </div>
    """
  end

  def example(%{section: "table-sortable"} = assigns) do
    assigns = assign(assigns, :rows, @crew)

    ~H"""
    <.table
      id="daisyui-table-sortable"
      rows={@rows}
      caption="Crew, sortable"
      row_id={&"sortable-#{&1.id}"}
      sort_by="name"
      sort_dir="asc"
      on_sort="daisyui_table_sort"
    >
      <:col :let={row} label="Name" key="name" row_header>{row.name}</:col>
      <:col :let={row} label="Job" key="job">{row.job}</:col>
      <:col :let={row} label="Color">{row.color}</:col>
    </.table>
    """
  end

  def example(%{section: "table-selectable"} = assigns) do
    assigns = assign(assigns, :rows, @crew)

    ~H"""
    <.table
      id="daisyui-table-selectable"
      rows={@rows}
      caption="Crew, selectable"
      row_id={&"selectable-#{&1.id}"}
      selected={["selectable-1"]}
      on_select="daisyui_table_select"
      on_select_all="daisyui_table_select_all"
    >
      <:col :let={row} label="Name" row_header>{row.name}</:col>
      <:col :let={row} label="Job">{row.job}</:col>
    </.table>
    """
  end

  def example(%{section: "table-empty"} = assigns) do
    ~H"""
    <.table id="daisyui-table-empty" rows={[]} caption="No crew" show_caption>
      <:col label="Name" />
      <:col label="Job" />
      <:empty>Nobody has signed on yet.</:empty>
    </.table>
    """
  end

  # ── fab ───────────────────────────────────────────────────────────────────
  def example(%{section: "fab-hero"} = assigns) do
    ~H"""
    <.fab_frame>
      <.fab id="daisyui-fab-hero" label="Actions" contained>
        <:icon>+</:icon>
        <:action label="Share">A</:action>
        <:action label="Copy">B</:action>
        <:action label="Edit">C</:action>
      </.fab>
    </.fab_frame>
    """
  end

  def example(%{section: "fab-icons"} = assigns) do
    ~H"""
    <.fab_frame>
      <.fab id="daisyui-fab-icons" label="Actions" contained>
        <:icon><.dock_icon path="M12 5v14M5 12h14" /></:icon>
        <:action label="Share"><.dock_icon path="M4 12v8h16v-8M12 3v13M8 7l4-4 4 4" /></:action>
        <:action label="Copy"><.dock_icon path="M9 9h10v10H9zM5 15V5h10" /></:action>
        <:action label="Edit"><.dock_icon path="M4 20h4L20 8l-4-4L4 16z" /></:action>
      </.fab>
    </.fab_frame>
    """
  end

  def example(%{section: "fab-labels"} = assigns) do
    ~H"""
    <.fab_frame>
      <.fab id="daisyui-fab-labels" label="Actions" contained>
        <:icon><.dock_icon path="M12 5v14M5 12h14" /></:icon>
        <:action label="Share" show_label>
          <.dock_icon path="M4 12v8h16v-8M12 3v13M8 7l4-4 4 4" />
        </:action>
        <:action label="Copy" show_label><.dock_icon path="M9 9h10v10H9zM5 15V5h10" /></:action>
      </.fab>
    </.fab_frame>
    """
  end

  def example(%{section: "fab-rectangle"} = assigns) do
    ~H"""
    <.fab_frame>
      <.fab id="daisyui-fab-rectangle" label="Actions" contained>
        <:icon>+</:icon>
        <:action label="Add a page" show_label>+</:action>
        <:action label="Add a folder" show_label>▸</:action>
      </.fab>
    </.fab_frame>
    """
  end

  def example(%{section: "fab-close"} = assigns) do
    ~H"""
    <.fab_frame>
      <.fab id="daisyui-fab-close" label="Actions" contained>
        <:icon><.dock_icon path="M12 5v14M5 12h14" /></:icon>
        <:close_icon><.dock_icon path="M6 6l12 12M18 6L6 18" /></:close_icon>
        <:action label="Share" show_label>A</:action>
        <:action label="Copy" show_label>B</:action>
      </.fab>
    </.fab_frame>
    """
  end

  def example(%{section: "fab-main-action"} = assigns) do
    ~H"""
    <.fab_frame>
      <.fab id="daisyui-fab-main" label="Actions" contained>
        <:icon><.dock_icon path="M12 5v14M5 12h14" /></:icon>
        <:action label="Share" show_label>A</:action>
        <:action label="Copy" show_label>B</:action>
        <:main_action label="Compose"><.dock_icon path="M4 20h4L20 8l-4-4L4 16z" /></:main_action>
      </.fab>
    </.fab_frame>
    """
  end

  def example(%{section: "fab-single"} = assigns) do
    ~H"""
    <.fab_frame>
      <.fab id="daisyui-fab-single" label="Compose" contained>
        <:icon><.dock_icon path="M4 20h4L20 8l-4-4L4 16z" /></:icon>
      </.fab>
    </.fab_frame>
    """
  end

  def example(%{section: "fab-flower"} = assigns) do
    ~H"""
    <.fab_frame>
      <.fab id="daisyui-fab-flower" label="Actions" contained direction="flower">
        <:icon><.dock_icon path="M12 5v14M5 12h14" /></:icon>
        <:action label="Share">A</:action>
        <:action label="Copy">B</:action>
        <:action label="Edit">C</:action>
      </.fab>
    </.fab_frame>
    """
  end

  def example(%{section: "fab-flower-main"} = assigns) do
    ~H"""
    <.fab_frame>
      <.fab id="daisyui-fab-flower-main" label="Actions" contained direction="flower">
        <:icon><.dock_icon path="M12 5v14M5 12h14" /></:icon>
        <:action label="Share">A</:action>
        <:action label="Copy">B</:action>
        <:action label="Edit">C</:action>
        <:main_action label="Compose"><.dock_icon path="M4 20h4L20 8l-4-4L4 16z" /></:main_action>
      </.fab>
    </.fab_frame>
    """
  end

  def example(%{section: "fab-directions"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-4">
      <.fab_frame :for={{dir, place} <- [{"down", "top-start"}, {"right", "bottom-start"}]}>
        <.fab
          id={"daisyui-fab-#{dir}"}
          label={"Actions #{dir}"}
          contained
          direction={dir}
          placement={place}
        >
          <:icon>+</:icon>
          <:action label="Share">A</:action>
          <:action label="Copy">B</:action>
        </.fab>
      </.fab_frame>
    </div>
    """
  end

  # ── theme_controller ──────────────────────────────────────────────────────
  def example(%{section: "theme-controller-hero"} = assigns) do
    ~H"""
    <.theme_preview id="daisyui-theme-hero-box">
      <.theme_controller
        id="daisyui-theme-hero"
        target="#daisyui-theme-hero-box"
        value="light"
        input_class="d-radio"
      >
        <:option value="light">Light</:option>
        <:option value="dark">Dark</:option>
        <:option value="cupcake">Cupcake</:option>
      </.theme_controller>
    </.theme_preview>
    """
  end

  def example(%{section: "theme-controller-toggle"} = assigns) do
    ~H"""
    <.theme_preview id="daisyui-theme-toggle-box">
      <.theme_controller
        id="daisyui-theme-toggle"
        target="#daisyui-theme-toggle-box"
        value="light"
        switch
        input_class="d-toggle"
      >
        <:option value="light" />
        <:option value="dark" />
      </.theme_controller>
    </.theme_preview>
    """
  end

  def example(%{section: "theme-controller-checkbox"} = assigns) do
    ~H"""
    <.theme_preview id="daisyui-theme-checkbox-box">
      <.theme_controller
        id="daisyui-theme-checkbox"
        target="#daisyui-theme-checkbox-box"
        value="light"
        switch
        input_class="d-checkbox"
      >
        <:option value="light" />
        <:option value="dark" />
      </.theme_controller>
    </.theme_preview>
    """
  end

  def example(%{section: "theme-controller-toggle-text"} = assigns) do
    ~H"""
    <.theme_preview id="daisyui-theme-text-box">
      <.theme_controller
        id="daisyui-theme-text"
        target="#daisyui-theme-text-box"
        value="light"
        switch
        input_class="d-toggle"
      >
        <:option value="light" />
        <:option value="dark">Dark mode</:option>
      </.theme_controller>
    </.theme_preview>
    """
  end

  def example(%{section: "theme-controller-swap"} = assigns) do
    ~H"""
    <.theme_preview id="daisyui-theme-swap-box">
      <.theme_controller
        id="daisyui-theme-swap"
        target="#daisyui-theme-swap-box"
        value="light"
        switch
        wrap_label={false}
        option_class="d-swap d-swap-rotate"
      >
        <:option value="light" />
        <:option value="dark">
          <.theme_glyph kind="sun" class="d-swap-off size-10 fill-current" />
          <.theme_glyph kind="moon" class="d-swap-on size-10 fill-current" />
        </:option>
      </.theme_controller>
    </.theme_preview>
    """
  end

  def example(%{section: "theme-controller-icons-inside"} = assigns) do
    ~H"""
    <.theme_preview id="daisyui-theme-inside-box">
      <.theme_controller
        id="daisyui-theme-inside"
        target="#daisyui-theme-inside-box"
        value="light"
        switch
        wrap_label={false}
        option_class="d-toggle text-base-content"
      >
        <:option value="light" />
        <:option value="dark">
          <.theme_glyph kind="sun" stroked />
          <.theme_glyph kind="moon" stroked />
        </:option>
      </.theme_controller>
    </.theme_preview>
    """
  end

  def example(%{section: "theme-controller-dropdown"} = assigns) do
    ~H"""
    <.theme_preview id="daisyui-theme-dropdown-box">
      <details class="d-dropdown">
        <summary class="d-btn m-1">Theme</summary>
        <.theme_controller
          id="daisyui-theme-dropdown"
          target="#daisyui-theme-dropdown-box"
          value="light"
          class="d-dropdown-content z-1 w-52 rounded-box bg-base-300 p-2 shadow-2xl"
          input_class="sr-only"
          option_class="d-btn d-btn-sm d-btn-block d-btn-ghost justify-start"
        >
          <:option value="light" label="Light" />
          <:option value="dark" label="Dark" />
          <:option value="cupcake" label="Cupcake" />
        </.theme_controller>
      </details>
    </.theme_preview>
    """
  end

  def example(%{section: "theme-controller-toggle-icons"} = assigns) do
    ~H"""
    <.theme_preview id="daisyui-theme-icons-box">
      <.theme_controller
        id="daisyui-theme-icons"
        target="#daisyui-theme-icons-box"
        value="light"
        switch
        input_class="d-toggle"
      >
        <:option value="light" />
        <:option value="dark">
          <.field_icon path="M21 12.8A9 9 0 1111.2 3a7 7 0 009.8 9.8z" />
        </:option>
      </.theme_controller>
    </.theme_preview>
    """
  end

  def example(%{section: "theme-controller-colors"} = assigns) do
    ~H"""
    <.theme_preview id="daisyui-theme-colors-box">
      <.theme_controller
        id="daisyui-theme-colors"
        target="#daisyui-theme-colors-box"
        value="light"
        switch
        input_class="d-toggle d-toggle-primary"
      >
        <:option value="light" />
        <:option value="dark" />
      </.theme_controller>
    </.theme_preview>
    """
  end

  def example(%{section: "theme-controller-radio"} = assigns) do
    ~H"""
    <.theme_preview id="daisyui-theme-radio-box">
      <.theme_controller
        id="daisyui-theme-radio"
        target="#daisyui-theme-radio-box"
        value="light"
        input_class="d-radio"
      >
        <:option value="light">Light</:option>
        <:option value="dark">Dark</:option>
        <:option value="retro">Retro</:option>
        <:option value="cyberpunk">Cyberpunk</:option>
      </.theme_controller>
    </.theme_preview>
    """
  end

  def example(%{section: "theme-controller-buttons"} = assigns) do
    ~H"""
    <.theme_preview id="daisyui-theme-buttons-box">
      <.theme_controller
        id="daisyui-theme-buttons"
        target="#daisyui-theme-buttons-box"
        value="light"
        input_class="sr-only"
        label_class="d-btn d-btn-sm"
      >
        <:option value="light">Light</:option>
        <:option value="dark">Dark</:option>
        <:option value="valentine">Valentine</:option>
      </.theme_controller>
    </.theme_preview>
    """
  end

  def example(%{section: "theme-controller-system"} = assigns) do
    ~H"""
    <.theme_preview id="daisyui-theme-system-box">
      <.theme_controller
        id="daisyui-theme-system"
        target="#daisyui-theme-system-box"
        value="system"
        system
        input_class="d-radio"
      >
        <:option value="light">Light</:option>
        <:option value="dark">Dark</:option>
      </.theme_controller>
    </.theme_preview>
    """
  end

  def example(%{section: "theme-controller-persist"} = assigns) do
    ~H"""
    <.theme_preview id="daisyui-theme-persist-box">
      <.theme_controller
        id="daisyui-theme-persist"
        target="#daisyui-theme-persist-box"
        storage_key="chelekom-demo-theme"
        value="light"
        input_class="d-radio"
        on_change="daisyui_theme_change"
      >
        <:option value="light">Light</:option>
        <:option value="dark">Dark</:option>
        <:option value="dracula">Dracula</:option>
      </.theme_controller>
    </.theme_preview>
    """
  end

  # ── countdown ─────────────────────────────────────────────────────────────
  def example(%{section: "countdown-hero"} = assigns) do
    ~H"""
    <.countdown id="daisyui-countdown-hero" target={countdown_target(:launch)} />
    """
  end

  def example(%{section: "countdown-large"} = assigns) do
    ~H"""
    <.countdown
      id="daisyui-countdown-large"
      target={countdown_target(:launch)}
      class="font-mono text-4xl"
    />
    """
  end

  def example(%{section: "countdown-clock"} = assigns) do
    ~H"""
    <.countdown
      id="daisyui-countdown-clock"
      target={countdown_target(:launch)}
      units={~w(hours minutes seconds)}
      class="font-mono text-2xl"
    />
    """
  end

  def example(%{section: "countdown-colons"} = assigns) do
    ~H"""
    <.countdown
      id="daisyui-countdown-colons"
      target={countdown_target(:launch)}
      units={~w(hours minutes seconds)}
      separator=":"
      class="font-mono text-2xl"
    />
    """
  end

  def example(%{section: "countdown-labels"} = assigns) do
    ~H"""
    <.countdown
      id="daisyui-countdown-labels"
      target={countdown_target(:launch)}
      show_labels
      labels={%{"days" => "days", "hours" => "hours", "minutes" => "min", "seconds" => "sec"}}
      class="font-mono text-2xl"
    />
    """
  end

  def example(%{section: "countdown-labels-under"} = assigns) do
    ~H"""
    <.countdown
      id="daisyui-countdown-labels-under"
      target={countdown_target(:launch)}
      show_labels
      class="font-mono text-3xl [&_[data-part=unit]]:flex-col [&_[data-part=unit]]:items-center gap-5"
    />
    """
  end

  def example(%{section: "countdown-boxes"} = assigns) do
    ~H"""
    <.countdown
      id="daisyui-countdown-boxes"
      target={countdown_target(:launch)}
      show_labels
      class={[
        "font-mono text-3xl gap-3",
        "[&_[data-part=unit]]:flex-col [&_[data-part=unit]]:items-center",
        "[&_[data-part=unit]]:rounded-box [&_[data-part=unit]]:bg-neutral",
        "[&_[data-part=unit]]:text-neutral-content [&_[data-part=unit]]:p-3"
      ]}
    />
    """
  end

  def example(%{section: "countdown-short"} = assigns) do
    ~H"""
    <.countdown
      id="daisyui-countdown-short"
      seconds={10}
      units={~w(seconds)}
      show_labels
      on_complete="daisyui_countdown_complete"
      class="font-mono text-3xl"
    />
    """
  end

  # ── alert_dialog ────────────────────────────────────────────────────────
  def example(%{section: "alert_dialog-hero"} = assigns) do
    ~H"""
    <.alert_dialog id="daisyui-alert_dialog-hero">
      <:trigger>Discard draft</:trigger>
      <:title>Discard draft?</:title>
      <:description>You can’t undo this action.</:description>
      <:actions>
        <button
          type="button"
          data-close
        >
          Cancel
        </button>
        <button
          type="button"
          data-close
        >
          Discard
        </button>
      </:actions>
    </.alert_dialog>
    """
  end

  def example(%{section: "alert_dialog-detached-triggers-controlled"} = assigns) do
    ~H"""
    <.alert_dialog id="daisyui-alert_dialog-detached-triggers-controlled">
      <:trigger>Discard</:trigger>
      <:title>Discard draft?</:title>
      <:description>This action cannot be undone.</:description>
      <:actions>
        <button
          type="button"
          data-close
        >
          Cancel
        </button>
        <button
          type="button"
          data-close
        >
          Confirm
        </button>
      </:actions>
    </.alert_dialog>
    """
  end

  def example(%{section: "alert_dialog-detached-triggers-simple"} = assigns) do
    ~H"""
    <.alert_dialog id="daisyui-alert_dialog-detached-triggers-simple">
      <:trigger>Discard draft</:trigger>
      <:title>Discard draft?</:title>
      <:description>This action cannot be undone.</:description>
      <:actions>
        <button
          type="button"
          data-close
        >
          Cancel
        </button>
        <button
          type="button"
          data-close
        >
          Discard
        </button>
      </:actions>
    </.alert_dialog>
    """
  end

  # ── autocomplete ────────────────────────────────────────────────────────
  def example(%{section: "autocomplete-hero"} = assigns) do
    ~H"""
    <label>
      Search tags
      <.autocomplete
        id="daisyui-autocomplete-hero"
        placeholder="e.g. feature"
      >
        <:option
          :for={tag <- daisyui_autocomplete_tags()}
          value={tag.value}
        >
          {tag.value}
        </:option>
        <:empty>
          <div>
            No tags found.
          </div>
        </:empty>
      </.autocomplete>
    </label>
    """
  end

  def example(%{section: "autocomplete-async"} = assigns) do
    ~H"""
    <label>
      Search movies by name or year
      <.autocomplete
        id="daisyui-autocomplete-async"
        placeholder="e.g. Pulp Fiction or 1994"
      >
        <:option
          :for={movie <- daisyui_autocomplete_movies()}
          value={movie.title}
        >
          <span>
            <span>{movie.title}</span>
            <span>
              {movie.year}
            </span>
          </span>
        </:option>
        <:empty>
          <div>
            No movies found in the Top 100 IMDb movies.
          </div>
        </:empty>
      </.autocomplete>
    </label>
    """
  end

  def example(%{section: "autocomplete-auto-highlight"} = assigns) do
    ~H"""
    <label>
      Auto highlight on type
      <.autocomplete
        id="daisyui-autocomplete-auto-highlight"
        placeholder="e.g. feature"
        auto_highlight
      >
        <:option
          :for={tag <- daisyui_autocomplete_tags()}
          value={tag.value}
        >
          {tag.value}
        </:option>
        <:empty>
          <div>
            No tags found.
          </div>
        </:empty>
      </.autocomplete>
    </label>
    """
  end

  def example(%{section: "autocomplete-command-palette"} = assigns) do
    ~H"""
    <div>
      <.autocomplete
        id="daisyui-autocomplete-command-palette"
        placeholder="Search for apps and commands…"
        auto_highlight
        inline
      >
        <:option
          :for={item <- daisyui_autocomplete_palette_suggestions()}
          value={item.label}
          group="Suggestions"
        >
          <span>{item.label}</span>
          <span>
            Application
          </span>
        </:option>
        <:option
          :for={item <- daisyui_autocomplete_palette_commands()}
          value={item.label}
          group="Commands"
        >
          <span>{item.label}</span>
          <span>
            Command
          </span>
        </:option>
        <:empty>
          <div>
            No results found.
          </div>
        </:empty>
      </.autocomplete>
      <div>
        <div>
          <span>Activate</span>
          <kbd>
            Enter
          </kbd>
        </div>
        <div>
          <span>Actions</span>
          <kbd>
            Cmd
          </kbd>
          <kbd>
            K
          </kbd>
        </div>
      </div>
    </div>
    """
  end

  # ── chart ───────────────────────────────────────────────────────────────
  def example(%{section: "chart-breakdown"} = assigns) do
    ~H"""
    <.chart
      id="daisyui-chart-breakdown"
      height="20rem"
      aria_label="Traffic by source"
      option={
        %{
          tooltip: %{trigger: "item"},
          legend: %{bottom: 0},
          series: [
            %{
              name: "Source",
              type: "pie",
              radius: ["48%", "72%"],
              data: [
                %{value: 1048, name: "Search"},
                %{value: 735, name: "Direct"},
                %{value: 580, name: "Referral"},
                %{value: 484, name: "Social"},
                %{value: 300, name: "Email"}
              ]
            }
          ]
        }
      }
    />
    """
  end

  def example(%{section: "chart-dashboard"} = assigns) do
    ~H"""
    <.chart
      id="daisyui-chart-dashboard"
      height="20rem"
      aria_label="Monthly revenue over a year"
      option={
        %{
          grid: %{left: 8, right: 16, top: 24, bottom: 28, containLabel: true},
          tooltip: %{trigger: "axis"},
          xAxis: %{
            type: "category",
            boundaryGap: false,
            data: ~w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
          },
          yAxis: %{type: "value", axisLabel: %{formatter: "chelekom:currency:USD"}},
          series: [
            %{
              name: "Revenue",
              type: "line",
              smooth: true,
              areaStyle: %{color: "chelekom:fade"},
              data: [
                8200,
                9320,
                9010,
                12_340,
                12_900,
                13_300,
                14_100,
                15_600,
                14_800,
                16_200,
                17_400,
                19_100
              ]
            }
          ]
        }
      }
    />
    """
  end

  # ── checkbox_group ──────────────────────────────────────────────────────
  def example(%{section: "checkbox_group-hero"} = assigns) do
    ~H"""
    <.checkbox_group id="daisyui-checkbox_group-hero">
      <:indicator_icon>
        <svg
          class="block"
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
        >
          <path d="m2.5 8.5 4 4 7-9" />
        </svg>
      </:indicator_icon>

      <:label>Apples</:label>

      <:item
        value="fuji-apple"
        checked
      >
        Fuji
      </:item>

      <:item value="gala-apple">
        Gala
      </:item>

      <:item value="granny-smith-apple">
        Granny Smith
      </:item>
    </.checkbox_group>
    """
  end

  # ── color_input ─────────────────────────────────────────────────────────
  def example(%{section: "color_input-hero"} = assigns) do
    ~H"""
    <.color_input
      id="daisyui-color-input"
      value="#0ea5e9"
      label="Color"
    />
    """
  end

  # ── color_picker ────────────────────────────────────────────────────────
  def example(%{section: "color_picker-hero"} = assigns) do
    ~H"""
    <.color_picker
      id="daisyui-color-picker"
      value="#e8590c"
    />
    """
  end

  # ── color_swatch ────────────────────────────────────────────────────────
  def example(%{section: "color_swatch-hero"} = assigns) do
    ~H"""
    <div>
      <.color_swatch color="#fa5252" />
      <.color_swatch color="#7048e8" />
      <.color_swatch color="#12b886" />
      <.color_swatch
        color="#1c7ed6"
        label="Selected"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
          <path
            fill-rule="evenodd"
            d="M16.704 4.153a.75.75 0 0 1 .143 1.052l-8 10.5a.75.75 0 0 1-1.127.075l-4.5-4.5a.75.75 0 0 1 1.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 0 1 1.05-.143Z"
            clip-rule="evenodd"
          />
        </svg>
      </.color_swatch>
    </div>
    """
  end

  # ── combobox ────────────────────────────────────────────────────────────
  def example(%{section: "combobox-hero"} = assigns) do
    ~H"""
    <div>
      <label for="daisyui-combobox-hero">Choose a fruit</label>
      <.combobox
        id="daisyui-combobox-hero"
        clear
        trigger
        placeholder="e.g. Apple"
      >
        <:trigger_icon>
          <svg class="block" width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
            <path d="M12 6H4l4 4.5z" />
          </svg>
        </:trigger_icon>
        <:clear_icon>
          <svg
            class="block"
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-linecap="square"
            stroke-linejoin="round"
          >
            <path d="m4.5 4.5 7 7m-7 0 7-7" />
          </svg>
        </:clear_icon>
        <:item_indicator>
          <svg
            class="block"
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
          >
            <path d="m2.5 8.5 4 4 7-9" />
          </svg>
        </:item_indicator>
        <:option
          :for={
            f <-
              ~w(Apple Banana Orange Pineapple Grape Mango Strawberry Blueberry Raspberry Blackberry Cherry Peach Pear Plum Kiwi Watermelon Cantaloupe Honeydew Papaya Guava Lychee Pomegranate Apricot Grapefruit Passionfruit)
          }
          value={String.downcase(f)}
        >
          <span>{f}</span>
        </:option>
        <:empty>No fruits found.</:empty>
      </.combobox>
    </div>
    """
  end

  def example(%{section: "combobox-async-multiple"} = assigns) do
    assigns =
      assign(assigns,
        users: [
          %{
            id: "leslie-alexander",
            name: "Leslie Alexander",
            username: "leslie",
            email: "leslie.alexander@example.com",
            title: "Product Manager"
          },
          %{
            id: "kathryn-murphy",
            name: "Kathryn Murphy",
            username: "kathryn",
            email: "kathryn.murphy@example.com",
            title: "Marketing Lead"
          },
          %{
            id: "courtney-henry",
            name: "Courtney Henry",
            username: "courtney",
            email: "courtney.henry@example.com",
            title: "Design Systems"
          },
          %{
            id: "michael-foster",
            name: "Michael Foster",
            username: "michael",
            email: "michael.foster@example.com",
            title: "Engineering Manager"
          },
          %{
            id: "lindsay-walton",
            name: "Lindsay Walton",
            username: "lindsay",
            email: "lindsay.walton@example.com",
            title: "Product Designer"
          },
          %{
            id: "tom-cook",
            name: "Tom Cook",
            username: "tom",
            email: "tom.cook@example.com",
            title: "Frontend Engineer"
          },
          %{
            id: "whitney-francis",
            name: "Whitney Francis",
            username: "whitney",
            email: "whitney.francis@example.com",
            title: "Customer Success"
          },
          %{
            id: "jacob-jones",
            name: "Jacob Jones",
            username: "jacob",
            email: "jacob.jones@example.com",
            title: "Security Engineer"
          },
          %{
            id: "arlene-mccoy",
            name: "Arlene McCoy",
            username: "arlene",
            email: "arlene.mccoy@example.com",
            title: "Data Analyst"
          },
          %{
            id: "marvin-mckinney",
            name: "Marvin McKinney",
            username: "marvin",
            email: "marvin.mckinney@example.com",
            title: "QA Specialist"
          },
          %{
            id: "eleanor-pena",
            name: "Eleanor Pena",
            username: "eleanor",
            email: "eleanor.pena@example.com",
            title: "Operations"
          },
          %{
            id: "jerome-bell",
            name: "Jerome Bell",
            username: "jerome",
            email: "jerome.bell@example.com",
            title: "DevOps Engineer"
          }
        ]
      )

    ~H"""
    <div>
      <label for="daisyui-combobox-async-multiple">
        Assign reviewers
      </label>
      <.combobox
        id="daisyui-combobox-async-multiple"
        multiple
        placeholder="e.g. Michael"
      >
        <:chip_remove_icon>
          <svg
            class="block"
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-linecap="square"
            stroke-linejoin="round"
          >
            <path d="m4.5 4.5 7 7m-7 0 7-7" />
          </svg>
        </:chip_remove_icon>
        <:item_indicator>
          <svg
            class="block"
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
          >
            <path d="m2.5 8.5 4 4 7-9" />
          </svg>
        </:item_indicator>
        <:option :for={u <- @users} value={u.id}>
          <span>
            <span>{u.name}</span>
            <span>{u.email}</span>
            <span>
              <span>@{u.username}</span>
              <span>{u.title}</span>
            </span>
          </span>
        </:option>
        <:empty>Try a different search term.</:empty>
      </.combobox>
    </div>
    """
  end

  def example(%{section: "combobox-async-single"} = assigns) do
    assigns =
      assign(assigns,
        users: [
          %{
            id: "leslie-alexander",
            name: "Leslie Alexander",
            username: "leslie",
            email: "leslie.alexander@example.com",
            title: "Product Manager"
          },
          %{
            id: "kathryn-murphy",
            name: "Kathryn Murphy",
            username: "kathryn",
            email: "kathryn.murphy@example.com",
            title: "Marketing Lead"
          },
          %{
            id: "courtney-henry",
            name: "Courtney Henry",
            username: "courtney",
            email: "courtney.henry@example.com",
            title: "Design Systems"
          },
          %{
            id: "michael-foster",
            name: "Michael Foster",
            username: "michael",
            email: "michael.foster@example.com",
            title: "Engineering Manager"
          },
          %{
            id: "lindsay-walton",
            name: "Lindsay Walton",
            username: "lindsay",
            email: "lindsay.walton@example.com",
            title: "Product Designer"
          },
          %{
            id: "tom-cook",
            name: "Tom Cook",
            username: "tom",
            email: "tom.cook@example.com",
            title: "Frontend Engineer"
          },
          %{
            id: "whitney-francis",
            name: "Whitney Francis",
            username: "whitney",
            email: "whitney.francis@example.com",
            title: "Customer Success"
          },
          %{
            id: "jacob-jones",
            name: "Jacob Jones",
            username: "jacob",
            email: "jacob.jones@example.com",
            title: "Security Engineer"
          },
          %{
            id: "arlene-mccoy",
            name: "Arlene McCoy",
            username: "arlene",
            email: "arlene.mccoy@example.com",
            title: "Data Analyst"
          },
          %{
            id: "marvin-mckinney",
            name: "Marvin McKinney",
            username: "marvin",
            email: "marvin.mckinney@example.com",
            title: "QA Specialist"
          },
          %{
            id: "eleanor-pena",
            name: "Eleanor Pena",
            username: "eleanor",
            email: "eleanor.pena@example.com",
            title: "Operations"
          },
          %{
            id: "jerome-bell",
            name: "Jerome Bell",
            username: "jerome",
            email: "jerome.bell@example.com",
            title: "DevOps Engineer"
          }
        ]
      )

    ~H"""
    <div>
      <label for="daisyui-combobox-async-single">Assign reviewer</label>
      <.combobox
        id="daisyui-combobox-async-single"
        clear
        trigger
        placeholder="e.g. Michael"
      >
        <:trigger_icon>
          <svg class="block" width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
            <path d="M12 6H4l4 4.5z" />
          </svg>
        </:trigger_icon>
        <:clear_icon>
          <svg
            class="block"
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-linecap="square"
            stroke-linejoin="round"
          >
            <path d="m4.5 4.5 7 7m-7 0 7-7" />
          </svg>
        </:clear_icon>
        <:item_indicator>
          <svg
            class="block"
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
          >
            <path d="m2.5 8.5 4 4 7-9" />
          </svg>
        </:item_indicator>
        <:option :for={u <- @users} value={u.id}>
          <span>
            <span>{u.name}</span>
            <span>{u.email}</span>
            <span>
              <span>@{u.username}</span>
              <span>{u.title}</span>
            </span>
          </span>
        </:option>
        <:empty>Try a different search term.</:empty>
      </.combobox>
    </div>
    """
  end

  def example(%{section: "combobox-creatable"} = assigns) do
    assigns =
      assign(assigns,
        labels: ["bug", "documentation", "enhancement", "help wanted", "good first issue"]
      )

    ~H"""
    <div>
      <label for="daisyui-combobox-creatable">
        Labels
      </label>
      <.combobox
        id="daisyui-combobox-creatable"
        multiple
        creatable
        placeholder="e.g. bug"
      >
        <:chip_remove_icon>
          <svg
            class="block"
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-linecap="square"
            stroke-linejoin="round"
          >
            <path d="m4.5 4.5 7 7m-7 0 7-7" />
          </svg>
        </:chip_remove_icon>
        <:item_indicator>
          <svg
            class="block"
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
          >
            <path d="m2.5 8.5 4 4 7-9" />
          </svg>
        </:item_indicator>
        <:create_icon>
          <span>
            <svg
              class="block"
              width="16"
              height="16"
              viewBox="0 0 16 16"
              fill="none"
              stroke="currentColor"
              stroke-linecap="square"
              stroke-linejoin="round"
            >
              <path d="M1.5 8h13M8 14.5v-13" />
            </svg>
          </span>
        </:create_icon>
        <:option :for={lbl <- @labels} value={lbl}>
          <span>{lbl}</span>
        </:option>
        <:empty>No labels found.</:empty>
      </.combobox>
    </div>
    """
  end

  # ── context_menu ────────────────────────────────────────────────────────
  def example(%{section: "context_menu-hero"} = assigns) do
    ~H"""
    <.context_menu id="daisyui-context_menu-hero">
      <:trigger>Right click here</:trigger>
      <:item>
        Add to Library
      </:item>
      <:item>
        Add to Playlist
      </:item>
      <:item type="separator" />
      <:item>
        Play Next
      </:item>
      <:item>
        Play Last
      </:item>
      <:item type="separator" />
      <:item>
        Favorite
      </:item>
      <:item>
        Share
      </:item>
    </.context_menu>
    """
  end

  def example(%{section: "context_menu-submenu"} = assigns) do
    ~H"""
    <.context_menu id="daisyui-context_menu-submenu">
      <:trigger>Right click here</:trigger>
      <.context_menu_item>
        Add to Library
      </.context_menu_item>
      <.context_menu_submenu
        id="daisyui-context_menu-submenu-playlist"
        label="Add to Playlist"
      >
        <:chevron>
          <svg class="block" width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
            <path d="M6 12V4l4.5 4z" />
          </svg>
        </:chevron>
        <.context_menu_item>
          Get Up!
        </.context_menu_item>
        <.context_menu_item>
          Inside Out
        </.context_menu_item>
        <.context_menu_item>
          Night Beats
        </.context_menu_item>
        <.context_menu_separator />
        <.context_menu_item>
          New playlist…
        </.context_menu_item>
      </.context_menu_submenu>
      <.context_menu_separator />
      <.context_menu_item>
        Play Next
      </.context_menu_item>
      <.context_menu_item>
        Play Last
      </.context_menu_item>
      <.context_menu_separator />
      <.context_menu_item>
        Favorite
      </.context_menu_item>
      <.context_menu_item>
        Share
      </.context_menu_item>
    </.context_menu>
    """
  end

  # ── editor ──────────────────────────────────────────────────────────────
  def example(%{section: "editor-hero"} = assigns) do
    ~H"""
    <.editor
      id="daisyui-editor-hero"
      value="<p>A rich-text surface. Select a word and use the toolbar.</p>"
    >
      <:toolbar>
        <button
          :for={{command, label} <- [{"bold", "B"}, {"italic", "I"}, {"underline", "U"}]}
          type="button"
          data-editor-command={command}
        >{label}</button>
      </:toolbar>
    </.editor>
    """
  end

  # ── empty_state ─────────────────────────────────────────────────────────
  def example(%{section: "empty_state-hero"} = assigns) do
    ~H"""
    <.empty_state
      id="daisyui-empty-state-hero"
      title="No results found"
      description="We couldn't find anything matching your search. Try a different keyword."
    >
      <:indicator>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"
          />
        </svg>
      </:indicator>
    </.empty_state>
    """
  end

  def example(%{section: "empty_state-actions"} = assigns) do
    ~H"""
    <.empty_state
      id="daisyui-empty-state-actions"
      align="left"
      title="No projects yet"
      description="Create your first project to get started — it only takes a minute."
    >
      <:indicator>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M12 10.5v6m3-3H9m4.06-7.19-2.12-2.12a1.5 1.5 0 0 0-1.061-.44H4.5A2.25 2.25 0 0 0 2.25 6v12a2.25 2.25 0 0 0 2.25 2.25h15A2.25 2.25 0 0 0 21.75 18V9a2.25 2.25 0 0 0-2.25-2.25h-5.379a1.5 1.5 0 0 1-1.06-.44Z"
          />
        </svg>
      </:indicator>
      <:actions>
        <button type="button">
          New project
        </button>
        <button type="button">
          Import
        </button>
      </:actions>
    </.empty_state>
    """
  end

  # ── floating_indicator ──────────────────────────────────────────────────
  def example(%{section: "floating_indicator-hero"} = assigns) do
    ~H"""
    <.floating_indicator
      id="daisyui-floating-indicator"
      active="day"
      label="Range"
    >
      <:target value="day">Day</:target>
      <:target value="week">Week</:target>
      <:target value="month">Month</:target>
    </.floating_indicator>
    """
  end

  # ── floating_window ─────────────────────────────────────────────────────
  def example(%{section: "floating_window-hero"} = assigns) do
    ~H"""
    <div class="relative h-56 w-full overflow-hidden bg-[radial-gradient(rgba(120,120,120,0.25)_1px,transparent_0)] bg-[size:16px_16px]">
      <.floating_window
        id="daisyui-floating-window"
        x={24}
        y={24}
        label="Window"
      >
        <:handle>Drag me</:handle>
        Grab the title bar to move this panel within the box.
      </.floating_window>
    </div>
    """
  end

  # ── highlight ───────────────────────────────────────────────────────────
  def example(%{section: "highlight-hero"} = assigns) do
    ~H"""
    <p>
      <.highlight
        text="Search results for phoenix — the Phoenix framework is fast."
        highlight="phoenix"
      />
    </p>
    """
  end

  # ── json_input ──────────────────────────────────────────────────────────
  def example(%{section: "json_input-hero"} = assigns) do
    ~H"""
    <.json_input
      id="daisyui-json-input"
      value={~s({\n  "name": "Mantine",\n  "ok": true\n})}
      rows={4}
    />
    """
  end

  # ── mark ────────────────────────────────────────────────────────────────
  def example(%{section: "mark-hero"} = assigns) do
    ~H"""
    <p>
      The quick brown
      <.mark>fox</.mark>
      jumps over the lazy <.mark>dog</.mark>.
    </p>
    """
  end

  # ── marquee ─────────────────────────────────────────────────────────────
  def example(%{section: "marquee-hero"} = assigns) do
    ~H"""
    <div>
      <style>
        @keyframes chelekom-marquee-x { from { transform: translateX(0) } to { transform: translateX(-50%) } }
      </style>
      <.marquee>
        <span>React</span>
        <span>Vue</span>
        <span>Svelte</span>
        <span>Solid</span>
        <span>Angular</span>
      </.marquee>
    </div>
    """
  end

  # ── mask_input ──────────────────────────────────────────────────────────
  def example(%{section: "mask_input-hero"} = assigns) do
    ~H"""
    <.mask_input
      id="daisyui-mask-input"
      mask="(999) 999-9999"
      placeholder="(___) ___-____"
      inputmode="numeric"
    />
    """
  end

  # ── menubar ─────────────────────────────────────────────────────────────
  def example(%{section: "menubar-hero"} = assigns) do
    ~H"""
    <.menubar id="daisyui-menubar-hero">
      <:menu label="File">
        <button
          type="button"
          role="menuitem"
        >
          New
        </button>
        <button
          type="button"
          role="menuitem"
        >
          Open
        </button>
        <button
          type="button"
          role="menuitem"
        >
          Save
        </button>
        <button
          type="button"
          role="menuitem"
        >
          Export
          <svg class="block" width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
            <path d="M6 12V4l4.5 4z" />
          </svg>
        </button>
        <div
          data-part="separator"
          role="separator"
        >
        </div>
        <button
          type="button"
          role="menuitem"
        >
          Print
        </button>
      </:menu>

      <:menu label="Edit">
        <button
          type="button"
          role="menuitem"
        >
          Cut
        </button>
        <button
          type="button"
          role="menuitem"
        >
          Copy
        </button>
        <button
          type="button"
          role="menuitem"
        >
          Paste
        </button>
      </:menu>

      <:menu label="View">
        <button
          type="button"
          role="menuitem"
        >
          Zoom In
        </button>
        <button
          type="button"
          role="menuitem"
        >
          Zoom Out
        </button>
        <button
          type="button"
          role="menuitem"
        >
          Layout
          <svg class="block" width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
            <path d="M6 12V4l4.5 4z" />
          </svg>
        </button>
        <div
          data-part="separator"
          role="separator"
        >
        </div>
        <button
          type="button"
          role="menuitem"
        >
          Full Screen
        </button>
      </:menu>

      <:menu label="Help" disabled></:menu>
    </.menubar>
    """
  end

  # ── meter ───────────────────────────────────────────────────────────────
  def example(%{section: "meter-hero"} = assigns) do
    ~H"""
    <.meter
      id="daisyui-meter-hero"
      value={24}
      label="Storage Used"
      show_value
    />
    """
  end

  # ── navigation_menu ─────────────────────────────────────────────────────
  def example(%{section: "navigation_menu-hero"} = assigns) do
    ~H"""
    <.navigation_menu
      id="daisyui-navigation_menu-hero"
      class="[--duration:0.35s] [--easing:cubic-bezier(0.22,1,0.36,1)]"
    >
      <:icon>
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
          <path d="M12 6H4l4 4.5z" />
        </svg>
      </:icon>

      <:item label="Overview">
        <ul>
          <li>
            <a href="#">
              <h3>Quick Start</h3>
              <p>
                Install and assemble your first component.
              </p>
            </a>
          </li>
          <li>
            <a href="#">
              <h3>Accessibility</h3>
              <p>
                Learn how we build accessible components.
              </p>
            </a>
          </li>
          <li>
            <a href="#">
              <h3>Releases</h3>
              <p>
                See what's new in the latest Base UI versions.
              </p>
            </a>
          </li>
          <li>
            <a href="#">
              <h3>About</h3>
              <p>
                Learn more about Base UI and our mission.
              </p>
            </a>
          </li>
        </ul>
      </:item>

      <:item label="Handbook">
        <ul>
          <li>
            <a href="#">
              <h3>Styling</h3>
              <p>
                Base UI components can be styled with plain CSS, Tailwind CSS, CSS-in-JS, or CSS Modules.
              </p>
            </a>
          </li>
          <li>
            <a href="#">
              <h3>Animation</h3>
              <p>
                Base UI components can be animated with CSS transitions, CSS animations, or JavaScript libraries.
              </p>
            </a>
          </li>
          <li>
            <a href="#">
              <h3>Composition</h3>
              <p>
                Base UI components can be replaced and composed with your own existing components.
              </p>
            </a>
          </li>
        </ul>
      </:item>

      <:item label="GitHub" href="#" />
    </.navigation_menu>
    """
  end

  def example(%{section: "navigation_menu-no-arrows"} = assigns) do
    ~H"""
    <.navigation_menu id="daisyui-navigation_menu-no-arrows" icon_class="hidden">
      <:item label="One">
        <div class="p-4">Content for the first item</div>
      </:item>
      <:item label="Two">
        <div class="p-4">Content for the second item</div>
      </:item>
      <:item label="Three">
        <div class="p-4">Content for the third item</div>
      </:item>
    </.navigation_menu>
    """
  end

  def example(%{section: "navigation_menu-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, ~w(xs sm md lg))

    ~H"""
    <div class="flex flex-col items-start gap-4">
      <.navigation_menu
        :for={size <- @sizes}
        id={"daisyui-navigation_menu-#{size}"}
        list_class={"d-menu-#{size}"}
      >
        <:icon>
          <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" class="block">
            <path d="M12 6H4l4 4.5z" />
          </svg>
        </:icon>
        <:item label="One">
          <div class="p-4">menu-{size}</div>
        </:item>
        <:item label="Two">
          <div class="p-4">Content for the second item</div>
        </:item>
      </.navigation_menu>
    </div>
    """
  end

  def example(%{section: "navigation_menu-nested"} = assigns) do
    ~H"""
    <.navigation_menu
      id="daisyui-navigation_menu-nested"
      class="[--duration:0.35s] [--easing:cubic-bezier(0.22,1,0.36,1)]"
    >
      <:icon>
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
          <path d="M12 6H4l4 4.5z" />
        </svg>
      </:icon>

      <:item label="Overview">
        <ul>
          <li>
            <a href="#">
              <h3>Quick Start</h3>
              <p>
                Install and assemble your first component.
              </p>
            </a>
          </li>
          <li>
            <a href="#">
              <h3>Accessibility</h3>
              <p>
                Learn how we build accessible components.
              </p>
            </a>
          </li>
          <li>
            <a href="#">
              <h3>Releases</h3>
              <p>
                See what's new in the latest Base UI versions.
              </p>
            </a>
          </li>
          <li>
            <div>
              <span>Handbook</span>
              <p>
                How to use Base UI effectively.
              </p>
            </div>
            <ul>
              <li>
                <a href="#">
                  <h3>Styling</h3>
                  <p>
                    Base UI components can be styled with plain CSS, Tailwind CSS, CSS-in-JS, or CSS Modules.
                  </p>
                </a>
              </li>
              <li>
                <a href="#">
                  <h3>Animation</h3>
                  <p>
                    Base UI components can be animated with CSS transitions, CSS animations, or JavaScript libraries.
                  </p>
                </a>
              </li>
              <li>
                <a href="#">
                  <h3>Composition</h3>
                  <p>
                    Base UI components can be replaced and composed with your own existing components.
                  </p>
                </a>
              </li>
            </ul>
          </li>
        </ul>
      </:item>
    </.navigation_menu>
    """
  end

  def example(%{section: "navigation_menu-nested-inline"} = assigns) do
    ~H"""
    <.navigation_menu
      id="daisyui-navigation_menu-nested-inline"
      class="[--duration:0.35s] [--easing:cubic-bezier(0.22,1,0.36,1)]"
    >
      <:icon>
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
          <path d="M12 6H4l4 4.5z" />
        </svg>
      </:icon>

      <:item label="Product">
        <div>
          <ul>
            <li>
              <div>
                <span>
                  Developers
                </span>
                <span>
                  Go from idea to UI faster.
                </span>
              </div>
            </li>
            <li>
              <div>
                <span>
                  Design Systems
                </span>
                <span>
                  Keep patterns aligned across teams.
                </span>
              </div>
            </li>
            <li>
              <div>
                <span>
                  Engineering Leads
                </span>
                <span>
                  Roll out shared UI without drag.
                </span>
              </div>
            </li>
            <li>
              <div>
                <span>
                  Startups
                </span>
                <span>
                  Ship polished basics while things change.
                </span>
              </div>
            </li>
          </ul>
          <div>
            <div>
              <div>
                <h4>
                  Build product UI without giving up control
                </h4>
                <p>
                  Start with accessible parts and shape them to your app instead of working around a preset design system.
                </p>
              </div>
              <ul>
                <li>
                  <a href="#">
                    <h5>Quick start</h5>
                    <p>
                      Install Base UI and get your first interactive primitive on screen fast.
                    </p>
                  </a>
                </li>
                <li>
                  <a href="#">
                    <h5>Composition</h5>
                    <p>
                      Wrap and combine parts to match your product structure without hacks.
                    </p>
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </:item>

      <:item label="Learn">
        <div>
          <div>
            <h4>Where teams usually start</h4>
            <p>
              These are the docs people reach for first when they are turning a prototype into shared UI.
            </p>
          </div>
          <ul>
            <li>
              <a href="#">
                <h5>Accessibility handbook</h5>
                <p>
                  Take a practical pass over focus order, semantics, and keyboard support.
                </p>
              </a>
            </li>
            <li>
              <a href="#">
                <h5>Composition handbook</h5>
                <p>
                  Learn when to wrap parts, share behavior, and expose flexible APIs.
                </p>
              </a>
            </li>
            <li>
              <a href="#">
                <h5>Styling handbook</h5>
                <p>
                  Apply tokens and state styles without fighting the underlying markup.
                </p>
              </a>
            </li>
          </ul>
        </div>
      </:item>

      <:item label="Releases" href="#" />
      <:item label="GitHub" href="#" />
    </.navigation_menu>
    """
  end

  # ── number_field ────────────────────────────────────────────────────────
  def example(%{section: "number_field-hero"} = assigns) do
    ~H"""
    <.number_field
      id="daisyui-number_field-hero"
      value={100}
      scrub_cursor
    >
      <:scrub_area>Amount</:scrub_area>
      <:scrub_cursor_icon>
        <svg
          class="block"
          width="26"
          height="14"
          viewBox="0 0 24 14"
          fill="black"
          stroke="white"
        >
          <path d="M19.5 5.5L6.49737 5.51844V2L1 6.9999L6.5 12L6.49737 8.5L19.5 8.5V12L25 6.9999L19.5 2V5.5Z" />
        </svg>
      </:scrub_cursor_icon>
      <:decrement_icon>
        <svg
          class="block"
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          stroke-linecap="square"
          stroke-linejoin="round"
        >
          <path d="M1.5 8h13" />
        </svg>
      </:decrement_icon>
      <:increment_icon>
        <svg
          class="block"
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          stroke-linecap="square"
          stroke-linejoin="round"
        >
          <path d="M1.5 8h13M8 14.5v-13" />
        </svg>
      </:increment_icon>
    </.number_field>
    """
  end

  # ── number_formatter ────────────────────────────────────────────────────
  def example(%{section: "number_formatter-hero"} = assigns) do
    ~H"""
    <div>
      <p>
        Revenue:
        <.number_formatter
          value={1_234_567.89}
          prefix="$"
          decimal_scale={2}
        />
      </p>
      <p>
        Downloads:
        <.number_formatter
          value={9_876_543}
          thousand_separator=" "
        />
      </p>
    </div>
    """
  end

  # ── overflow_list ───────────────────────────────────────────────────────
  def example(%{section: "overflow_list-hero"} = assigns) do
    ~H"""
    <div>
      <.overflow_list
        id="daisyui-overflow-list"
        min_visible={1}
      >
        <:item>Design</:item>
        <:item>Phoenix</:item>
        <:item>Elixir</:item>
        <:item>LiveView</:item>
        <:item>Tailwind</:item>
        <:item>Headless</:item>
      </.overflow_list>
    </div>
    """
  end

  # ── pills_input ─────────────────────────────────────────────────────────
  def example(%{section: "pills_input-hero"} = assigns) do
    ~H"""
    <.pills_input
      id="daisyui-pills-input"
      placeholder="Add a tag…"
    >
      <:pills>
        <.pill
          with_remove
          remove_label="Remove ui"
          on_remove={JS.hide(to: {:closest, "[data-part=root]"})}
        >
          ui
        </.pill>
        <.pill
          with_remove
          remove_label="Remove phoenix"
          on_remove={JS.hide(to: {:closest, "[data-part=root]"})}
        >
          phoenix
        </.pill>
      </:pills>
    </.pills_input>
    """
  end

  # ── popover ─────────────────────────────────────────────────────────────
  def example(%{section: "popover-hero"} = assigns) do
    ~H"""
    <.popover
      id="daisyui-popover-hero"
      side_offset={8}
    >
      <:trigger>Notifications</:trigger>
      <:arrow></:arrow>
      <:title>Notifications</:title>
      <:description>You are all caught up. Good job!</:description>
    </.popover>
    """
  end

  def example(%{section: "popover-detached-triggers-controlled"} = assigns) do
    ~H"""
    <.popover
      id="daisyui-popover-detached-triggers-controlled"
      side_offset={8}
    >
      <:trigger>Trigger 1</:trigger>
      <:arrow></:arrow>
      <:title>Notifications</:title>
      <:description>You are all caught up. Good job!</:description>
    </.popover>
    """
  end

  def example(%{section: "popover-detached-triggers-full"} = assigns) do
    ~H"""
    <.popover
      id="daisyui-popover-detached-triggers-full"
      side_offset={8}
    >
      <:trigger>Profile</:trigger>
      <:arrow></:arrow>
      <div>
        <h2>
          Jason Eventon
        </h2>
        <span>
          <img
            src="https://images.unsplash.com/photo-1543610892-0b1f7e6d8ac1?w=128&h=128&dpr=2&q=80"
            width="48"
            height="48"
          />
        </span>
        <span>
          Pro plan
        </span>
        <div>
          <a href="#">
            Profile settings
          </a>
          <a href="#">
            Log out
          </a>
        </div>
      </div>
    </.popover>
    """
  end

  def example(%{section: "popover-detached-triggers-simple"} = assigns) do
    ~H"""
    <.popover
      id="daisyui-popover-detached-triggers-simple"
      side_offset={8}
    >
      <:trigger>Notifications</:trigger>
      <:arrow></:arrow>
      <:title>Notifications</:title>
      <:description>You are all caught up. Good job!</:description>
    </.popover>
    """
  end

  # ── preview_card ────────────────────────────────────────────────────────
  def example(%{section: "preview_card-hero"} = assigns) do
    ~H"""
    <p>
      The principles of good
      <.preview_card
        id="daisyui-preview_card-hero"
        side_offset={8}
      >
        <:trigger>typography</:trigger>
        <:arrow></:arrow>
        <div>
          <img
            width="224"
            height="150"
            src="https://images.unsplash.com/photo-1619615391095-dfa29e1672ef?q=80&w=448&h=300"
            alt="Station Hofplein signage in Rotterdam, Netherlands"
          />
          <p>
            <strong>Typography</strong> is the art and science of arranging type to make written
            language clear, visually appealing, and effective in communication.
          </p>
        </div>
      </.preview_card>
      remain in the digital age.
    </p>
    """
  end

  def example(%{section: "preview_card-detached-triggers-controlled"} = assigns) do
    ~H"""
    <div>
      <p>
        Discover
        <.preview_card
          id="daisyui-preview_card-detached-triggers-controlled-typography"
          side_offset={8}
        >
          <:trigger>typography</:trigger>
          <:arrow></:arrow>
          <div>
            <img
              width="224"
              height="150"
              src="https://images.unsplash.com/photo-1619615391095-dfa29e1672ef?q=80&w=448&h=300"
              alt="Station Hofplein signage in Rotterdam, Netherlands"
            />
            <p>
              <strong>Typography</strong> is the art and science of arranging type.
            </p>
          </div>
        </.preview_card>
        ,
        <.preview_card
          id="daisyui-preview_card-detached-triggers-controlled-design"
          side_offset={8}
        >
          <:trigger>design</:trigger>
          <:arrow></:arrow>
          <div>
            <img
              width="241"
              height="240"
              src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Braun_ABW30_%28schwarz%29.jpg/250px-Braun_ABW30_%28schwarz%29.jpg"
              alt="Braun ABW30"
            />
            <p>
              A <strong>design</strong> is the concept or proposal for an object, process, or system.
            </p>
          </div>
        </.preview_card>
        , or
        <.preview_card
          id="daisyui-preview_card-detached-triggers-controlled-art"
          side_offset={8}
        >
          <:trigger>art</:trigger>
          <:arrow></:arrow>
          <div>
            <img
              width="206"
              height="240"
              src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/MonaLisa_sfumato.jpeg/250px-MonaLisa_sfumato.jpeg"
              alt="Mona Lisa"
            />
            <p>
              <strong>Art</strong>
              is a diverse range of cultural activity centered around works utilizing
              creative or imaginative talents, which are expected to evoke a worthwhile experience,
              generally through an expression of emotional power, conceptual ideas, technical proficiency,
              or beauty.
            </p>
          </div>
        </.preview_card>
        .
      </p>
      <button
        type="button"
        phx-click={
          Phoenix.LiveView.JS.focus(
            to: "#baseui-preview_card-detached-triggers-controlled-design [data-part=trigger]"
          )
        }
      >
        Open programmatically
      </button>
    </div>
    """
  end

  def example(%{section: "preview_card-detached-triggers-full"} = assigns) do
    ~H"""
    <p>
      Discover
      <.preview_card
        id="daisyui-preview_card-detached-triggers-full-typography"
        side_offset={8}
      >
        <:trigger>typography</:trigger>
        <:arrow></:arrow>
        <div>
          <img
            width="224"
            height="150"
            src="https://images.unsplash.com/photo-1619615391095-dfa29e1672ef?q=80&w=448&h=300"
            alt="Station Hofplein signage in Rotterdam, Netherlands"
          />
          <p>
            <strong>Typography</strong> is the art and science of arranging type.
          </p>
        </div>
      </.preview_card>
      ,
      <.preview_card
        id="daisyui-preview_card-detached-triggers-full-design"
        side_offset={8}
      >
        <:trigger>design</:trigger>
        <:arrow></:arrow>
        <div>
          <img
            width="250"
            height="249"
            src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Braun_ABW30_%28schwarz%29.jpg/250px-Braun_ABW30_%28schwarz%29.jpg"
            alt="Braun ABW30"
          />
          <p>
            A <strong>design</strong> is the concept or proposal for an object, process, or system.
          </p>
        </div>
      </.preview_card>
      , or
      <.preview_card
        id="daisyui-preview_card-detached-triggers-full-art"
        side_offset={8}
      >
        <:trigger>art</:trigger>
        <:arrow></:arrow>
        <div>
          <img
            width="250"
            height="290"
            src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/MonaLisa_sfumato.jpeg/250px-MonaLisa_sfumato.jpeg"
            alt="Mona Lisa"
          />
          <p>
            <strong>Art</strong>
            is a diverse range of cultural activity centered around works utilizing
            creative or imaginative talents, which are expected to evoke a worthwhile experience,
            generally through an expression of emotional power, conceptual ideas, technical proficiency,
            or beauty.
          </p>
        </div>
      </.preview_card>
      .
    </p>
    """
  end

  def example(%{section: "preview_card-detached-triggers-simple"} = assigns) do
    ~H"""
    <p>
      The principles of good
      <.preview_card
        id="daisyui-preview_card-detached-triggers-simple"
        side_offset={8}
      >
        <:trigger>typography</:trigger>
        <:arrow></:arrow>
        <div>
          <img
            width="224"
            height="150"
            src="https://images.unsplash.com/photo-1619615391095-dfa29e1672ef?q=80&w=448&h=300"
            alt="Station Hofplein signage in Rotterdam, Netherlands"
          />
          <p>
            <strong>Typography</strong> is the art and science of arranging type to make
            written language clear, visually appealing, and effective in communication.
          </p>
        </div>
      </.preview_card>
      remain in the digital age.
    </p>
    """
  end

  # ── rolling_number ──────────────────────────────────────────────────────
  def example(%{section: "rolling_number-hero"} = assigns) do
    ~H"""
    <div>
      <.rolling_number
        id="daisyui-rolling-number-1"
        value={2048}
      />
      <.rolling_number
        id="daisyui-rolling-number-2"
        value={1_000_000}
        duration={1400}
      />
    </div>
    """
  end

  # ── scroll_area ─────────────────────────────────────────────────────────
  def example(%{section: "scroll_area-hero"} = assigns) do
    ~H"""
    <.scroll_area
      id="daisyui-scroll_area-hero"
      orientation="vertical"
    >
      <p>
        Vernacular architecture is building done outside any academic tradition, and without
        professional guidance. It is not a particular architectural movement or style, but
        rather a broad category, encompassing a wide range and variety of building types, with
        differing methods of construction, from around the world, both historical and extant and
        classical and modern. Vernacular architecture constitutes 95% of the world's built
        environment, as estimated in 1995 by Amos Rapoport, as measured against the small
        percentage of new buildings every year designed by architects and built by engineers.
      </p>
      <p>
        This type of architecture usually serves immediate, local needs, is constrained by the
        materials available in its particular region and reflects local traditions and cultural
        practices. The study of vernacular architecture does not examine formally schooled
        architects, but instead that of the design skills and tradition of local builders, who
        were rarely given any attribution for the work. More recently, vernacular architecture
        has been examined by designers and the building industry in an effort to be more energy
        conscious with contemporary design and construction—part of a broader interest in
        sustainable design.
      </p>
    </.scroll_area>
    """
  end

  def example(%{section: "scroll_area-both"} = assigns) do
    ~H"""
    <.scroll_area
      id="daisyui-scroll_area-both"
      orientation="both"
    >
      <ul>
        <li :for={i <- 1..100}>
          {i}
        </li>
      </ul>
    </.scroll_area>
    """
  end

  def example(%{section: "scroll_area-scroll-fade"} = assigns) do
    ~H"""
    <.scroll_area
      id="daisyui-scroll_area-scroll-fade"
      orientation="vertical"
    >
      <p>
        Vernacular architecture is building done outside any academic tradition, and without
        professional guidance. It is not a particular architectural movement or style, but
        rather a broad category, encompassing a wide range and variety of building types, with
        differing methods of construction, from around the world, both historical and extant and
        classical and modern. Vernacular architecture constitutes 95% of the world's built
        environment, as estimated in 1995 by Amos Rapoport, as measured against the small
        percentage of new buildings every year designed by architects and built by engineers.
      </p>
      <p>
        This type of architecture usually serves immediate, local needs, is constrained by the
        materials available in its particular region and reflects local traditions and cultural
        practices. The study of vernacular architecture does not examine formally schooled
        architects, but instead that of the design skills and tradition of local builders, who
        were rarely given any attribution for the work. More recently, vernacular architecture
        has been examined by designers and the building industry in an effort to be more energy
        conscious with contemporary design and construction—part of a broader interest in
        sustainable design.
      </p>
    </.scroll_area>
    """
  end

  # ── scroller ────────────────────────────────────────────────────────────
  def example(%{section: "scroller-hero"} = assigns) do
    ~H"""
    <.scroller id="daisyui-scroller">
      <div :for={n <- 1..10}>
        {n}
      </div>
    </.scroller>
    """
  end

  # ── sparkline ───────────────────────────────────────────────────────────
  def example(%{section: "sparkline-hero"} = assigns) do
    ~H"""
    <.sparkline
      values={[4, 7, 5, 9, 8, 12, 10, 14]}
      last_point
      color="currentColor"
      aria_label="Weekly signups, trending up"
    />
    """
  end

  def example(%{section: "sparkline-types"} = assigns) do
    ~H"""
    <div>
      <.sparkline
        :for={type <- ~w(line area bar)}
        values={[4, 7, 5, 9, 8, 12, 10, 14]}
        type={type}
        color="currentColor"
        aria_label={"Weekly signups as a #{type}"}
      />
    </div>
    """
  end

  # ── splitter ────────────────────────────────────────────────────────────
  def example(%{section: "splitter-hero"} = assigns) do
    ~H"""
    <.splitter
      id="daisyui-splitter"
      default_size={45}
    >
      <:first>
        <div>Files</div>
      </:first>
      <:second>
        <div>
          Editor — drag the divider or focus it and use arrow keys.
        </div>
      </:second>
    </.splitter>
    """
  end

  # ── tags_input ──────────────────────────────────────────────────────────
  def example(%{section: "tags_input-hero"} = assigns) do
    ~H"""
    <.tags_input
      id="daisyui-tags-input"
      tags={["Design", "Engineering", "Product"]}
      placeholder="Add a tag…"
      on_remove={JS.hide(to: {:closest, "[data-part=tag]"})}
    />
    """
  end

  # ── theme_icon ──────────────────────────────────────────────────────────
  def example(%{section: "theme_icon-hero"} = assigns) do
    ~H"""
    <div>
      <.theme_icon label="Success">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="2"
          stroke="currentColor"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
        </svg>
      </.theme_icon>
      <.theme_icon>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
          <path d="M11.983 1.907a.75.75 0 0 0-1.292-.657l-8.5 9.5A.75.75 0 0 0 2.75 12h6.572l-1.305 6.093a.75.75 0 0 0 1.292.657l8.5-9.5A.75.75 0 0 0 18.25 8h-6.572l1.305-6.093Z" />
        </svg>
      </.theme_icon>
    </div>
    """
  end

  # ── toolbar ─────────────────────────────────────────────────────────────
  def example(%{section: "toolbar-hero"} = assigns) do
    ~H"""
    <.toolbar id="daisyui-toolbar-hero">
      <:item
        group="Alignment"
        label="Align left"
      >
        Align Left
      </:item>
      <:item
        group="Alignment"
        label="Align right"
      >
        Align Right
      </:item>
      <:item type="separator" />
      <:item
        group="Numerical format"
        label="Format as currency"
      >
        $
      </:item>
      <:item
        group="Numerical format"
        label="Format as percent"
      >
        %
      </:item>
      <:item type="separator" />
      <:item label="Font family">
        Helvetica
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
          <path d="M11 10H5l3 3.5zm0-4H5l3-3.5z" />
        </svg>
      </:item>
      <:item type="separator" />
      <:item
        type="link"
        href="#"
      >
        Edited 51m ago
      </:item>
    </.toolbar>
    """
  end

  # ── tree ────────────────────────────────────────────────────────────────
  def example(%{section: "tree-hero"} = assigns) do
    ~H"""
    <.tree
      id="daisyui-tree-hero"
      aria_label="Project files"
      select_on_click
      expanded={["app", "app/components"]}
      selected={["app/components/Menu.tsx"]}
      nodes={[
        %{
          label: "app",
          value: "app",
          children: [
            %{
              label: "components",
              value: "app/components",
              children: [
                %{label: "Accordion.tsx", value: "app/components/Accordion.tsx"},
                %{label: "Menu.tsx", value: "app/components/Menu.tsx"}
              ]
            },
            %{label: "page.tsx", value: "app/page.tsx"}
          ]
        },
        %{label: "package.json", value: "package.json"},
        %{label: "tsconfig.json", value: "tsconfig.json"}
      ]}
    >
      <:expand_icon>
        <svg class="block" width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
          <path d="M6 12V4l4.5 4z" />
        </svg>
      </:expand_icon>
      <:node :let={n}>
        <svg
          :if={n.has_children}
          width="14"
          height="14"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          stroke-linecap="square"
          stroke-linejoin="round"
        >
          <path d="M1.5 12.5v-9h4l1.5 2h7.5v7z" />
        </svg>
        <svg
          :if={!n.has_children}
          width="14"
          height="14"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          stroke-linecap="square"
          stroke-linejoin="round"
        >
          <path d="M3.5 1.5h6l3 3v11h-9z" />
          <path d="M9.5 1.5v3.5h3" />
        </svg>
        {n.node.label}
      </:node>
    </.tree>
    """
  end

  # ── tree_select ─────────────────────────────────────────────────────────
  def example(%{section: "tree_select-hero"} = assigns) do
    ~H"""
    <.tree_select
      id="daisyui-tree-select"
      placeholder="Choose a category…"
    >
      <.tree
        id="daisyui-tree-select-tree"
        nodes={[
          %{
            label: "Design",
            value: "design",
            children: [
              %{label: "Wireframes", value: "wireframes"},
              %{label: "Mockups", value: "mockups"}
            ]
          },
          %{
            label: "Engineering",
            value: "engineering",
            children: [%{label: "Frontend", value: "frontend"}, %{label: "Backend", value: "backend"}]
          }
        ]}
        expanded={:all}
        select_on_click
        multiple={false}
        aria_label="Categories"
      >
        <:expand_icon>▸</:expand_icon>
      </.tree>
    </.tree_select>
    """
  end

  # ── visually_hidden ─────────────────────────────────────────────────────
  def example(%{section: "visually_hidden-hero"} = assigns) do
    ~H"""
    <button type="button">
      ★
      <.visually_hidden>Add to favorites</.visually_hidden>
    </button>
    """
  end

  # ── alpha_slider ────────────────────────────────────────────────────────
  def example(%{section: "alpha_slider-hero"} = assigns) do
    ~H"""
    <div>
      <.alpha_slider
        id="daisyui-alpha-slider"
        value={50}
        color="#e8590c"
      />
    </div>
    """
  end

  # ── angle_slider ────────────────────────────────────────────────────────
  def example(%{section: "angle_slider-hero"} = assigns) do
    ~H"""
    <.angle_slider
      id="daisyui-angle-slider"
      value={135}
      step={5}
      label="Angle"
    />
    """
  end

  # ── hue_slider ──────────────────────────────────────────────────────────
  def example(%{section: "hue_slider-hero"} = assigns) do
    ~H"""
    <div>
      <.hue_slider
        id="daisyui-hue-slider"
        value={140}
      />
    </div>
    """
  end

  def example(%{section: "autocomplete-fuzzy-matching"} = assigns) do
    ~H"""
    <label>
      Fuzzy search documentation
      <.autocomplete
        id="daisyui-autocomplete-fuzzy-matching"
        placeholder="e.g. React"
      >
        <:option
          :for={doc <- daisyui_autocomplete_docs()}
          value={doc.title}
        >
          <span>
            <span>
              <span>{doc.title}</span>
            </span>
            <span>{doc.description}</span>
          </span>
        </:option>
        <:empty>
          <div>
            No results found.
          </div>
        </:empty>
      </.autocomplete>
    </label>
    """
  end

  def example(%{section: "autocomplete-grid"} = assigns) do
    ~H"""
    <div>
      <label>
        Choose emoji
        <.autocomplete
          id="daisyui-autocomplete-grid"
          placeholder="Search emojis…"
        >
          <:option
            :for={emoji <- daisyui_autocomplete_emojis()}
            value={emoji.name}
            group={emoji.group}
          >
            {emoji.emoji}
          </:option>
          <:empty>
            <div>
              No emojis found
            </div>
          </:empty>
        </.autocomplete>
      </label>
    </div>
    """
  end

  def example(%{section: "autocomplete-grouped"} = assigns) do
    ~H"""
    <label>
      Select a tag
      <.autocomplete
        id="daisyui-autocomplete-grouped"
        placeholder="e.g. feature"
      >
        <:option
          :for={tag <- daisyui_autocomplete_tags()}
          value={tag.value}
          group={tag.group}
        >
          {tag.value}
        </:option>
        <:empty>
          <div>
            No tags found.
          </div>
        </:empty>
      </.autocomplete>
    </label>
    """
  end

  def example(%{section: "autocomplete-inline"} = assigns) do
    ~H"""
    <label>
      Search tags
      <.autocomplete
        id="daisyui-autocomplete-inline"
        placeholder="e.g. feature"
        auto_highlight
      >
        <:option
          :for={tag <- daisyui_autocomplete_tags()}
          value={tag.value}
        >
          {tag.value}
        </:option>
      </.autocomplete>
    </label>
    """
  end

  def example(%{section: "autocomplete-limit"} = assigns) do
    ~H"""
    <label>
      Limit results to 8
      <.autocomplete
        id="daisyui-autocomplete-limit"
        placeholder="e.g. component"
      >
        <:option
          :for={tag <- daisyui_autocomplete_limit_tags()}
          value={tag.value}
        >
          {tag.value}
        </:option>
        <:empty>
          <div>
            No results found.
          </div>
        </:empty>
      </.autocomplete>
    </label>
    """
  end

  def example(%{section: "combobox-grouped"} = assigns) do
    assigns =
      assign(assigns,
        fruits: ~w(Apple Banana Mango Kiwi Grape Orange Strawberry Watermelon),
        vegetables: [
          "Broccoli",
          "Carrot",
          "Cauliflower",
          "Cucumber",
          "Kale",
          "Bell pepper",
          "Spinach",
          "Zucchini"
        ]
      )

    ~H"""
    <div>
      <label for="daisyui-combobox-grouped">Select produce</label>
      <.combobox
        id="daisyui-combobox-grouped"
        clear
        trigger
        placeholder="e.g. Mango"
      >
        <:trigger_icon>
          <svg class="block" width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
            <path d="M12 6H4l4 4.5z" />
          </svg>
        </:trigger_icon>
        <:clear_icon>
          <svg
            class="block"
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-linecap="square"
            stroke-linejoin="round"
          >
            <path d="m4.5 4.5 7 7m-7 0 7-7" />
          </svg>
        </:clear_icon>
        <:item_indicator>
          <svg
            class="block"
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
          >
            <path d="m2.5 8.5 4 4 7-9" />
          </svg>
        </:item_indicator>
        <:option :for={f <- @fruits} value={"fruit-" <> String.downcase(f)} group="Fruits">
          <span>{f}</span>
        </:option>
        <:option :for={v <- @vegetables} value={"veg-" <> String.downcase(v)} group="Vegetables">
          <span>{v}</span>
        </:option>
        <:empty>No produce found.</:empty>
      </.combobox>
    </div>
    """
  end

  def example(%{section: "combobox-input-inside-popup"} = assigns) do
    assigns =
      assign(assigns,
        countries: [
          {"af", "Afghanistan"},
          {"al", "Albania"},
          {"dz", "Algeria"},
          {"ad", "Andorra"},
          {"ao", "Angola"},
          {"ar", "Argentina"},
          {"am", "Armenia"},
          {"au", "Australia"},
          {"at", "Austria"},
          {"az", "Azerbaijan"},
          {"bs", "Bahamas"},
          {"bh", "Bahrain"},
          {"bd", "Bangladesh"},
          {"be", "Belgium"},
          {"br", "Brazil"},
          {"ca", "Canada"},
          {"cn", "China"},
          {"fr", "France"},
          {"de", "Germany"},
          {"in", "India"},
          {"it", "Italy"},
          {"jp", "Japan"},
          {"mx", "Mexico"},
          {"nl", "Netherlands"},
          {"nz", "New Zealand"},
          {"no", "Norway"},
          {"pl", "Poland"},
          {"pt", "Portugal"},
          {"es", "Spain"},
          {"se", "Sweden"},
          {"ch", "Switzerland"},
          {"tr", "Turkey"},
          {"ua", "Ukraine"},
          {"gb", "United Kingdom"},
          {"us", "United States"},
          {"vn", "Vietnam"}
        ]
      )

    ~H"""
    <div>
      <label for="daisyui-combobox-input-inside-popup">
        Country
      </label>
      <.combobox
        id="daisyui-combobox-input-inside-popup"
        placeholder="e.g. United Kingdom"
      >
        <:item_indicator>
          <svg
            class="block"
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
          >
            <path d="m2.5 8.5 4 4 7-9" />
          </svg>
        </:item_indicator>
        <:option :for={{code, label} <- @countries} value={code}>
          <span>{label}</span>
        </:option>
        <:empty>No countries found.</:empty>
      </.combobox>
    </div>
    """
  end

  def example(%{section: "combobox-multiple"} = assigns) do
    assigns =
      assign(assigns,
        langs: [
          "JavaScript",
          "TypeScript",
          "Python",
          "Java",
          "C++",
          "C#",
          "PHP",
          "Ruby",
          "Go",
          "Rust",
          "Swift"
        ]
      )

    ~H"""
    <div>
      <label for="daisyui-combobox-multiple">
        Programming languages
      </label>
      <.combobox
        id="daisyui-combobox-multiple"
        multiple
        placeholder="e.g. TypeScript"
      >
        <:chip_remove_icon>
          <svg
            class="block"
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-linecap="square"
            stroke-linejoin="round"
          >
            <path d="m4.5 4.5 7 7m-7 0 7-7" />
          </svg>
        </:chip_remove_icon>
        <:item_indicator>
          <svg
            class="block"
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
          >
            <path d="m2.5 8.5 4 4 7-9" />
          </svg>
        </:item_indicator>
        <:option :for={lang <- @langs} value={lang}>
          <span>{lang}</span>
        </:option>
        <:empty>No languages found.</:empty>
      </.combobox>
    </div>
    """
  end

  def example(%{section: "popover-open-on-hover"} = assigns) do
    ~H"""
    <.popover
      id="daisyui-popover-open-on-hover"
      open_on_hover
      side_offset={8}
    >
      <:trigger>Notifications</:trigger>
      <:arrow></:arrow>
      <:title>Notifications</:title>
      <:description>You are all caught up. Good job!</:description>
    </.popover>
    """
  end

  # ── burger ────────────────────────────────────────────────────────────────
  def example(%{section: "burger-hero"} = assigns) do
    ~H"""
    <.burger id="daisyui-burger-hero" label="Open menu" controls="daisyui-burger-region" />
    """
  end

  def example(%{section: "burger-opened"} = assigns) do
    ~H"""
    <.burger id="daisyui-burger-opened" label="Close menu" opened />
    """
  end

  def example(%{section: "burger-sizes"} = assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <.burger
        :for={size <- ~w(xs sm md lg)}
        id={"daisyui-burger-#{size}"}
        label={"Menu #{size}"}
        class={"d-btn-#{size}"}
      />
    </div>
    """
  end

  def example(%{section: "burger-colors"} = assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <.burger
        :for={color <- ~w(primary secondary accent error)}
        id={"daisyui-burger-#{color}"}
        label={"Menu #{color}"}
        class={"text-#{color}"}
      />
    </div>
    """
  end

  def example(%{section: "burger-disabled"} = assigns) do
    ~H"""
    <.burger id="daisyui-burger-disabled" label="Menu" disabled />
    """
  end

  # ── spoiler ───────────────────────────────────────────────────────────────
  def example(%{section: "spoiler-hero"} = assigns) do
    ~H"""
    <.spoiler id="daisyui-spoiler-hero" class="w-96">
      <p>
        Chelekom's headless line ships behaviour and semantics, and no styling at all. Each component
        names its parts with <code>data-part</code>
        and reports its state with <code>data-*</code>
        attributes, which is what lets one stylesheet paint the whole set without the markup knowing
        anything about it. That is the same contract this spoiler follows.
      </p>
    </.spoiler>
    """
  end

  def example(%{section: "spoiler-expanded"} = assigns) do
    ~H"""
    <.spoiler id="daisyui-spoiler-expanded" expanded class="w-96">
      <p>
        Already unfolded, because the server said so — no flash of collapsed content while the
        socket connects.
      </p>
    </.spoiler>
    """
  end

  def example(%{section: "spoiler-labels"} = assigns) do
    ~H"""
    <.spoiler
      id="daisyui-spoiler-labels"
      show_label="Read the rest"
      hide_label="That's enough"
      class="w-96"
    >
      <p>
        The labels are attributes rather than slots, because a spoiler's control is a word or two —
        anything longer belongs in an accordion.
      </p>
    </.spoiler>
    """
  end

  # ── segmented_control ─────────────────────────────────────────────────────
  def example(%{section: "segmented-control-hero"} = assigns) do
    ~H"""
    <.segmented_control
      id="daisyui-segmented-hero"
      name="view"
      value="list"
      label="View"
      options={[{"List", "list"}, {"Grid", "grid"}, {"Table", "table"}]}
    />
    """
  end

  def example(%{section: "segmented-control-form"} = assigns) do
    ~H"""
    <form
      id="daisyui-segmented-form-el"
      phx-change="daisyui_segmented_change"
      class="flex flex-col items-start gap-3"
    >
      <.segmented_control
        id="daisyui-segmented-form"
        name="density"
        value="cosy"
        label="Density"
        options={[{"Compact", "compact"}, {"Cosy", "cosy"}, {"Roomy", "roomy"}]}
      />
    </form>
    """
  end

  def example(%{section: "segmented-control-disabled"} = assigns) do
    ~H"""
    <.segmented_control
      id="daisyui-segmented-disabled"
      name="view_off"
      value="grid"
      label="View"
      disabled
      options={[{"List", "list"}, {"Grid", "grid"}]}
    />
    """
  end

  # ── toggle_group ──────────────────────────────────────────────────────────
  def example(%{section: "toggle-group-hero"} = assigns) do
    ~H"""
    <.toggle_group id="daisyui-toggle-group-hero" value="center">
      <:item value="left">Left</:item>
      <:item value="center">Center</:item>
      <:item value="right">Right</:item>
    </.toggle_group>
    """
  end

  def example(%{section: "toggle-group-multiple"} = assigns) do
    ~H"""
    <.toggle_group id="daisyui-toggle-group-multiple" multiple value={["bold", "italic"]}>
      <:item value="bold"><span class="font-bold">B</span></:item>
      <:item value="italic"><span class="italic">I</span></:item>
      <:item value="underline"><span class="underline">U</span></:item>
    </.toggle_group>
    """
  end

  def example(%{section: "toggle-group-vertical"} = assigns) do
    ~H"""
    <.toggle_group id="daisyui-toggle-group-vertical" orientation="vertical" value="center">
      <:item value="left">Left</:item>
      <:item value="center">Center</:item>
      <:item value="right">Right</:item>
    </.toggle_group>
    """
  end

  def example(%{section: "toggle-group-disabled"} = assigns) do
    ~H"""
    <.toggle_group id="daisyui-toggle-group-disabled" value="center" disabled>
      <:item value="left">Left</:item>
      <:item value="center">Center</:item>
    </.toggle_group>
    """
  end

  def example(%{section: "toggle-group-form"} = assigns) do
    ~H"""
    <form
      id="daisyui-toggle-group-form-el"
      phx-change="daisyui_toggle_group_change"
      class="flex flex-col items-start gap-3"
    >
      <.toggle_group id="daisyui-toggle-group-form" name="format" multiple value={["bold"]}>
        <:item value="bold"><span class="font-bold">B</span></:item>
        <:item value="italic"><span class="italic">I</span></:item>
      </.toggle_group>
    </form>
    """
  end

  # ── action_icon ───────────────────────────────────────────────────────────
  def example(%{section: "action-icon-hero"} = assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <.action_icon label="Edit"><.dock_icon path="M4 20h4L20 8l-4-4L4 16z" /></.action_icon>
      <.action_icon label="Delete">
        <.dock_icon path="M5 7h14M9 7V5h6v2M7 7l1 13h8l1-13" />
      </.action_icon>
    </div>
    """
  end

  def example(%{section: "action-icon-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.action_icon :for={color <- @colors} label={color} class={"d-btn-#{color}"}>
        <.dock_icon path="M4 20h4L20 8l-4-4L4 16z" />
      </.action_icon>
    </div>
    """
  end

  def example(%{section: "action-icon-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex items-center gap-2">
      <.action_icon :for={size <- @sizes} label={size} class={"d-btn-#{size}"}>
        <.dock_icon path="M4 20h4L20 8l-4-4L4 16z" />
      </.action_icon>
    </div>
    """
  end

  def example(%{section: "action-icon-variants"} = assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <.action_icon
        :for={variant <- ~w(outline ghost soft dash)}
        label={variant}
        class={"d-btn-#{variant}"}
      >
        <.dock_icon path="M4 20h4L20 8l-4-4L4 16z" />
      </.action_icon>
    </div>
    """
  end

  def example(%{section: "action-icon-circle"} = assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <.action_icon label="Edit" class="d-btn-circle">
        <.dock_icon path="M4 20h4L20 8l-4-4L4 16z" />
      </.action_icon>
      <.action_icon label="Add" class="d-btn-circle d-btn-primary">
        <.dock_icon path="M12 5v14M5 12h14" />
      </.action_icon>
    </div>
    """
  end

  def example(%{section: "action-icon-disabled"} = assigns) do
    ~H"""
    <.action_icon label="Edit" disabled><.dock_icon path="M4 20h4L20 8l-4-4L4 16z" /></.action_icon>
    """
  end

  # ── close_button ──────────────────────────────────────────────────────────
  def example(%{section: "close-button-hero"} = assigns) do
    ~H"""
    <.close_button label="Dismiss" />
    """
  end

  def example(%{section: "close-button-sizes"} = assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <.close_button :for={size <- ~w(xs sm md lg)} label={size} class={"d-btn-#{size}"} />
    </div>
    """
  end

  def example(%{section: "close-button-custom"} = assigns) do
    ~H"""
    <.close_button label="Dismiss">
      <.dock_icon path="M6 6l12 12M18 6L6 18" />
    </.close_button>
    """
  end

  def example(%{section: "close-button-in-alert"} = assigns) do
    ~H"""
    <.alert id="daisyui-close-button-alert" class="d-alert d-alert-info w-96">
      A new version is available.
      <:actions><.close_button label="Dismiss" /></:actions>
    </.alert>
    """
  end

  def example(%{section: "close-button-disabled"} = assigns) do
    ~H"""
    <.close_button label="Dismiss" disabled />
    """
  end

  # ── chip ──────────────────────────────────────────────────────────────────
  def example(%{section: "chip-hero"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.chip id="daisyui-chip-a" name="tag_a" value="elixir" checked>Elixir</.chip>
      <.chip id="daisyui-chip-b" name="tag_b" value="phoenix">Phoenix</.chip>
    </div>
    """
  end

  def example(%{section: "chip-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.chip
        :for={color <- @colors}
        id={"daisyui-chip-#{color}"}
        name={"tag_#{color}"}
        value={color}
        checked={color == "primary"}
        class={"d-badge-#{color}"}
      >
        {color}
      </.chip>
    </div>
    """
  end

  def example(%{section: "chip-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.chip
        :for={size <- @sizes}
        id={"daisyui-chip-size-#{size}"}
        name={"tag_size_#{size}"}
        value={size}
        class={"d-badge-#{size}"}
      >
        {size}
      </.chip>
    </div>
    """
  end

  def example(%{section: "chip-multiple"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.chip
        :for={tag <- ~w(Elixir Phoenix LiveView Ecto)}
        id={"daisyui-chip-multi-#{tag}"}
        name={"tags[#{tag}]"}
        value={tag}
        checked={tag in ~w(Elixir LiveView)}
      >
        {tag}
      </.chip>
    </div>
    """
  end

  def example(%{section: "chip-single"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.chip
        :for={size <- ~w(Small Medium Large)}
        id={"daisyui-chip-one-#{size}"}
        type="radio"
        name="chip_size"
        value={size}
        checked={size == "Medium"}
      >
        {size}
      </.chip>
    </div>
    """
  end

  def example(%{section: "chip-disabled"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.chip id="daisyui-chip-on" name="chip_on" value="on" checked>Available</.chip>
      <.chip id="daisyui-chip-off" name="chip_off" value="off" disabled>Sold out</.chip>
    </div>
    """
  end

  # ── radio_group ───────────────────────────────────────────────────────────
  def example(%{section: "radio-group-hero"} = assigns) do
    ~H"""
    <.radio_group id="daisyui-radio-group-hero" name="plan" value="team">
      <:option value="solo">Solo</:option>
      <:option value="team">Team</:option>
      <:option value="enterprise">Enterprise</:option>
    </.radio_group>
    """
  end

  def example(%{section: "radio-group-horizontal"} = assigns) do
    ~H"""
    <.radio_group
      id="daisyui-radio-group-horizontal"
      name="plan_row"
      value="team"
      orientation="horizontal"
    >
      <:option value="solo">Solo</:option>
      <:option value="team">Team</:option>
      <:option value="enterprise">Enterprise</:option>
    </.radio_group>
    """
  end

  def example(%{section: "radio-group-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-col gap-3">
      <.radio_group
        :for={size <- @sizes}
        id={"daisyui-radio-group-#{size}"}
        name={"plan_#{size}"}
        value="team"
        orientation="horizontal"
        class={"d-radio-#{size}"}
      >
        <:option value="solo">Solo</:option>
        <:option value="team">{size}</:option>
      </.radio_group>
    </div>
    """
  end

  def example(%{section: "radio-group-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-col gap-2">
      <.radio_group
        :for={color <- @colors}
        id={"daisyui-radio-group-#{color}"}
        name={"plan_#{color}"}
        value="on"
        orientation="horizontal"
        class={"text-#{color}"}
      >
        <:option value="on">{color}</:option>
        <:option value="off">off</:option>
      </.radio_group>
    </div>
    """
  end

  def example(%{section: "radio-group-disabled"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.radio_group id="daisyui-radio-group-disabled" name="plan_off" value="team" disabled>
        <:option value="solo">Solo</:option>
        <:option value="team">Team</:option>
      </.radio_group>

      <.radio_group id="daisyui-radio-group-one-off" name="plan_one" value="solo">
        <:option value="solo">Solo</:option>
        <:option value="team" disabled>Team (sold out)</:option>
        <:option value="enterprise">Enterprise</:option>
      </.radio_group>
    </div>
    """
  end

  def example(%{section: "radio-group-readonly"} = assigns) do
    ~H"""
    <.radio_group id="daisyui-radio-group-readonly" name="plan_ro" value="team" readonly>
      <:option value="solo">Solo</:option>
      <:option value="team">Team</:option>
      <:option value="enterprise">Enterprise</:option>
    </.radio_group>
    """
  end

  def example(%{section: "radio-group-form"} = assigns) do
    ~H"""
    <form
      id="daisyui-radio-group-form-el"
      phx-change="daisyui_radio_group_change"
      phx-submit="daisyui_radio_group_submit"
      class="flex flex-col items-start gap-3"
    >
      <.radio_group id="daisyui-radio-group-form" name="plan_form" value="team">
        <:option value="solo">Solo</:option>
        <:option value="team">Team</:option>
        <:option value="enterprise">Enterprise</:option>
      </.radio_group>
      <button type="submit" class="d-btn d-btn-primary d-btn-sm">Save</button>
    </form>
    """
  end

  # ── rating ────────────────────────────────────────────────────────────────
  def example(%{section: "rating-hero"} = assigns) do
    ~H"""
    <.rating id="daisyui-rating-hero" value={3} />
    """
  end

  def example(%{section: "rating-readonly"} = assigns) do
    ~H"""
    <.rating
      id="daisyui-rating-readonly"
      value={4}
      readonly
      label="Average rating"
      item_class="bg-orange-400"
    />
    """
  end

  def example(%{section: "rating-star2"} = assigns) do
    ~H"""
    <.rating id="daisyui-rating-star2" value={2} item_class="d-mask-star-2 bg-warning" />
    """
  end

  def example(%{section: "rating-heart"} = assigns) do
    ~H"""
    <.rating id="daisyui-rating-heart" value={3} item_class="d-mask-heart bg-red-400" />
    """
  end

  def example(%{section: "rating-green"} = assigns) do
    ~H"""
    <.rating id="daisyui-rating-green" value={4} item_class="d-mask-star-2 bg-green-500" />
    """
  end

  def example(%{section: "rating-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-col items-center gap-2">
      <.rating
        :for={size <- @sizes}
        id={"daisyui-rating-#{size}"}
        value={3}
        class={"d-rating-#{size}"}
        item_class="d-mask-star-2 bg-orange-400"
      />
    </div>
    """
  end

  def example(%{section: "rating-hidden"} = assigns) do
    ~H"""
    <.rating
      id="daisyui-rating-hidden"
      value={2}
      clearable
      item_class="d-mask-star-2 bg-green-500"
    />
    """
  end

  def example(%{section: "rating-half"} = assigns) do
    ~H"""
    <.rating
      id="daisyui-rating-half"
      value={2.5}
      precision={0.5}
      clearable
      item_class="d-mask-star-2 bg-green-500"
    />
    """
  end

  def example(%{section: "rating-form"} = assigns) do
    ~H"""
    <form
      id="daisyui-rating-form-el"
      phx-change="daisyui_rating_change"
      phx-submit="daisyui_rating_submit"
      class="flex flex-col items-center gap-3"
    >
      <.rating
        id="daisyui-rating-form"
        name="score"
        value={3.5}
        precision={0.5}
        label="Your score"
        item_class="bg-orange-400"
      />
      <button type="submit" class="d-btn d-btn-primary d-btn-sm">Save</button>
    </form>
    """
  end

  # ── pagination ────────────────────────────────────────────────────────────
  def example(%{section: "pagination-hero"} = assigns) do
    ~H"""
    <.pagination id="daisyui-pagination-hero" total={4} page={2} show_controls={false} />
    """
  end

  def example(%{section: "pagination-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-col items-center gap-3">
      <.pagination
        :for={size <- @sizes}
        id={"daisyui-pagination-#{size}"}
        total={4}
        page={2}
        show_controls={false}
        control_class={"d-btn-#{size}"}
      />
    </div>
    """
  end

  def example(%{section: "pagination-disabled"} = assigns) do
    ~H"""
    <div class="flex flex-col items-center gap-3">
      <.pagination id="daisyui-pagination-disabled" total={4} page={2} disabled />
      <.pagination id="daisyui-pagination-at-first" total={4} page={1} />
      <.pagination id="daisyui-pagination-at-last" total={4} page={4} />
    </div>
    """
  end

  def example(%{section: "pagination-xs"} = assigns) do
    ~H"""
    <.pagination
      id="daisyui-pagination-extra-small"
      total={4}
      page={2}
      show_controls={false}
      control_class="d-btn-xs"
    />
    """
  end

  def example(%{section: "pagination-edges"} = assigns) do
    ~H"""
    <.pagination
      id="daisyui-pagination-edges"
      total={10}
      page={5}
      show_edges
      previous_label="Prev"
      next_label="Next"
      first_label="First"
      last_label="Last"
      control_class="d-btn-outline"
    />
    """
  end

  def example(%{section: "pagination-radio"} = assigns) do
    ~H"""
    <form id="daisyui-pagination-radio-form" phx-change="daisyui_pagination_change">
      <.pagination
        id="daisyui-pagination-radio"
        total={4}
        page={2}
        name="page"
        show_controls={false}
      />
    </form>
    """
  end

  def example(%{section: "pagination-window"} = assigns) do
    ~H"""
    <div class="flex flex-col items-center gap-3">
      <.pagination
        :for={page <- [1, 7, 50, 100]}
        id={"daisyui-pagination-w#{page}"}
        total={100}
        page={page}
      />
    </div>
    """
  end

  def example(%{section: "pagination-links"} = assigns) do
    ~H"""
    <.pagination
      id="daisyui-pagination-links"
      total={7}
      page={3}
      href={&"/showcase/headless-daisyui/pagination?page=#{&1}"}
    />
    """
  end

  def example(%{section: "pagination-interactive"} = assigns) do
    ~H"""
    <.pagination
      id="daisyui-pagination-interactive"
      total={12}
      page={4}
      show_edges
      on_select="daisyui_pagination_select"
    />
    """
  end

  # ── dock ──────────────────────────────────────────────────────────────────
  def example(%{section: "dock-hero"} = assigns) do
    ~H"""
    <.dock_frame>
      <.dock id="daisyui-dock-hero" label="Sections" contained>
        <:item label="Home" href="#"><.dock_icon path="M3 11l9-8 9 8M5 10v10h14V10" /></:item>
        <:item label="Inbox" href="#" active><.dock_icon path="M3 7h18v10H3zM3 7l9 6 9-6" /></:item>
        <:item label="Settings" href="#"><.dock_icon path="M12 8a4 4 0 100 8 4 4 0 000-8z" /></:item>
      </.dock>
    </.dock_frame>
    """
  end

  def example(%{section: "dock-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-col gap-4">
      <.dock_frame :for={size <- @sizes} height="h-28">
        <.dock
          id={"daisyui-dock-#{size}"}
          label={"Sections #{size}"}
          contained
          class={"d-dock-#{size}"}
        >
          <:item label="Home" href="#"><.dock_icon path="M3 11l9-8 9 8M5 10v10h14V10" /></:item>
          <:item label="Inbox" href="#" active><.dock_icon path="M3 7h18v10H3zM3 7l9 6 9-6" /></:item>
          <:item label="Settings" href="#">
            <.dock_icon path="M12 8a4 4 0 100 8 4 4 0 000-8z" />
          </:item>
        </.dock>
      </.dock_frame>
    </div>
    """
  end

  def example(%{section: "dock-colors"} = assigns) do
    ~H"""
    <.dock_frame>
      <.dock
        id="daisyui-dock-colors"
        label="Sections"
        contained
        class="bg-primary text-primary-content"
      >
        <:item label="Home" href="#"><.dock_icon path="M3 11l9-8 9 8M5 10v10h14V10" /></:item>
        <:item label="Inbox" href="#" active><.dock_icon path="M3 7h18v10H3zM3 7l9 6 9-6" /></:item>
        <:item label="Settings" href="#"><.dock_icon path="M12 8a4 4 0 100 8 4 4 0 000-8z" /></:item>
      </.dock>
    </.dock_frame>
    """
  end

  def example(%{section: "dock-top"} = assigns) do
    ~H"""
    <.dock_frame align="items-start">
      <.dock id="daisyui-dock-top" label="Sections" position="top" contained>
        <:item label="Home" href="#"><.dock_icon path="M3 11l9-8 9 8M5 10v10h14V10" /></:item>
        <:item label="Inbox" href="#" active><.dock_icon path="M3 7h18v10H3zM3 7l9 6 9-6" /></:item>
        <:item label="Settings" href="#"><.dock_icon path="M12 8a4 4 0 100 8 4 4 0 000-8z" /></:item>
      </.dock>
    </.dock_frame>
    """
  end

  def example(%{section: "dock-icon-only"} = assigns) do
    ~H"""
    <.dock_frame>
      <.dock id="daisyui-dock-icon-only" label="Sections" contained show_labels={false}>
        <:item label="Home" href="#"><.dock_icon path="M3 11l9-8 9 8M5 10v10h14V10" /></:item>
        <:item label="Inbox" href="#" active><.dock_icon path="M3 7h18v10H3zM3 7l9 6 9-6" /></:item>
        <:item label="Settings" href="#" disabled>
          <.dock_icon path="M12 8a4 4 0 100 8 4 4 0 000-8z" />
        </:item>
      </.dock>
    </.dock_frame>
    """
  end

  def example(%{section: "dock-interactive"} = assigns) do
    ~H"""
    <.dock_frame>
      <.dock id="daisyui-dock-interactive" label="Panels" contained>
        <:item label="Home" on_select="daisyui_dock_select">
          <.dock_icon path="M3 11l9-8 9 8M5 10v10h14V10" />
        </:item>
        <:item label="Inbox" on_select="daisyui_dock_select" active>
          <.dock_icon path="M3 7h18v10H3zM3 7l9 6 9-6" />
        </:item>
        <:item label="Settings" on_select="daisyui_dock_select">
          <.dock_icon path="M12 8a4 4 0 100 8 4 4 0 000-8z" />
        </:item>
      </.dock>
    </.dock_frame>
    """
  end

  # ── stepper ───────────────────────────────────────────────────────────────
  def example(%{section: "stepper-hero"} = assigns) do
    ~H"""
    <.stepper id="daisyui-stepper-hero" label="Checkout" active={2}>
      <:step label="Register" />
      <:step label="Choose plan" />
      <:step label="Purchase" />
      <:step label="Receive product" />
    </.stepper>
    """
  end

  def example(%{section: "stepper-vertical"} = assigns) do
    ~H"""
    <.stepper
      id="daisyui-stepper-vertical"
      label="Checkout"
      orientation="vertical"
      active={2}
    >
      <:step label="Register" />
      <:step label="Choose plan" />
      <:step label="Purchase" />
      <:step label="Receive product" />
    </.stepper>
    """
  end

  def example(%{section: "stepper-responsive"} = assigns) do
    ~H"""
    <.stepper
      id="daisyui-stepper-responsive"
      label="Checkout"
      active={2}
      orientation="vertical"
      horizontal_from="lg"
    >
      <:step label="Register" />
      <:step label="Choose plan" />
      <:step label="Purchase" />
      <:step label="Receive product" />
    </.stepper>
    """
  end

  def example(%{section: "stepper-icons"} = assigns) do
    ~H"""
    <.stepper id="daisyui-stepper-icons" label="Delivery" active={4}>
      <:step label="Step 1">😕</:step>
      <:step label="Step 2">😃</:step>
      <:step label="Step 3">😍</:step>
      <:step label="Step 4">
        <.field_icon path="M5 13l4 4L19 7" />
      </:step>
    </.stepper>
    """
  end

  def example(%{section: "stepper-content"} = assigns) do
    ~H"""
    <.stepper id="daisyui-stepper-content" label="Progress" active={4}>
      <:step label="Step 1" content="?" />
      <:step label="Step 2" content="!" />
      <:step label="Step 3" content="✓" />
      <:step label="Step 4" content="✕" />
      <:step label="Step 5" />
    </.stepper>
    """
  end

  def example(%{section: "stepper-colors"} = assigns) do
    ~H"""
    <.stepper id="daisyui-stepper-colors" label="Colors" active={0}>
      <:step label="Fund wallet" class="d-step-info" />
      <:step label="Choose plan" class="d-step-info" />
      <:step label="Purchase" class="d-step-error" />
      <:step label="Receive product" class="d-step-error" />
    </.stepper>
    """
  end

  def example(%{section: "stepper-scrollable"} = assigns) do
    ~H"""
    <div class="w-full overflow-x-auto">
      <.stepper id="daisyui-stepper-scrollable" label="Long flow" active={3}>
        <:step :for={n <- 1..10} label={"Step #{n}"} />
      </.stepper>
    </div>
    """
  end

  def example(%{section: "stepper-descriptions"} = assigns) do
    ~H"""
    <.stepper id="daisyui-stepper-descriptions" label="Onboarding" active={1}>
      <:step label="Account" description="Email and password" />
      <:step label="Profile" description="Name and avatar" />
      <:step label="Team" description="Invite your colleagues" />
    </.stepper>
    """
  end

  def example(%{section: "stepper-interactive"} = assigns) do
    ~H"""
    <.stepper
      id="daisyui-stepper-interactive"
      label="Editable flow"
      active={2}
      on_select="daisyui_stepper_select"
    >
      <:step label="Register" />
      <:step label="Choose plan" />
      <:step label="Purchase" />
      <:step label="Receive product" />
    </.stepper>
    """
  end

  # ── text_input ────────────────────────────────────────────────────────────
  def example(%{section: "text-input-hero"} = assigns) do
    ~H"""
    <.text_input id="daisyui-input-hero" name="username" placeholder="Type here" />
    """
  end

  def example(%{section: "text-input-label-inside"} = assigns) do
    ~H"""
    <.text_input id="daisyui-input-label-inside" name="path" placeholder="daisyui.com">
      <:start_section>https://</:start_section>
    </.text_input>
    """
  end

  def example(%{section: "text-input-label-end"} = assigns) do
    ~H"""
    <.text_input id="daisyui-input-label-end" name="domain" placeholder="mysite">
      <:end_section>.com</:end_section>
    </.text_input>
    """
  end

  def example(%{section: "text-input-ghost"} = assigns) do
    ~H"""
    <.text_input
      id="daisyui-input-ghost"
      name="ghost"
      class="d-input-ghost"
      placeholder="Type here"
    />
    """
  end

  def example(%{section: "text-input-fieldset"} = assigns) do
    ~H"""
    <.fieldset id="daisyui-input-fieldset" class="d-fieldset w-xs">
      <:legend>What is your name?</:legend>
      <.text_input id="daisyui-input-fieldset-control" name="name" placeholder="Your name" />
      <p class="d-label">Optional</p>
    </.fieldset>
    """
  end

  def example(%{section: "text-input-field"} = assigns) do
    ~H"""
    <.field
      :let={f}
      id="daisyui-input-field"
      name="email"
      label="Email"
      class="d-fieldset w-xs"
      label_class="d-fieldset-legend"
    >
      <.text_input
        id={f.id}
        name={f.name}
        type="email"
        placeholder="you@example.com"
        describedby={f.describedby}
      />
      <:description>We'll never share it.</:description>
    </.field>
    """
  end

  def example(%{section: "text-input-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-col gap-2">
      <.text_input
        :for={color <- @colors}
        id={"daisyui-input-#{color}"}
        name={color}
        class={"d-input-#{color}"}
        placeholder={String.capitalize(color)}
      />
    </div>
    """
  end

  def example(%{section: "text-input-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-col gap-2">
      <.text_input
        :for={size <- @sizes}
        id={"daisyui-input-size-#{size}"}
        name={size}
        class={"d-input-#{size}"}
        placeholder={"Size #{size}"}
      />
    </div>
    """
  end

  def example(%{section: "text-input-disabled"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.text_input id="daisyui-input-disabled" name="disabled" placeholder="You can't type" disabled />
      <.text_input id="daisyui-input-disabled-value" name="disabled_value" value="Locked" disabled />
    </div>
    """
  end

  def example(%{section: "text-input-datalist"} = assigns) do
    ~H"""
    <div>
      <.text_input
        id="daisyui-input-datalist"
        name="browser"
        placeholder="Pick a browser"
        list="daisyui-browsers"
      />
      <datalist id="daisyui-browsers">
        <option value="Chrome"></option>
        <option value="Firefox"></option>
        <option value="Safari"></option>
      </datalist>
    </div>
    """
  end

  def example(%{section: "text-input-date"} = assigns) do
    ~H"""
    <.text_input id="daisyui-input-date" name="date" type="date" />
    """
  end

  def example(%{section: "text-input-time"} = assigns) do
    ~H"""
    <.text_input id="daisyui-input-time" name="time" type="time" />
    """
  end

  def example(%{section: "text-input-datetime"} = assigns) do
    ~H"""
    <.text_input id="daisyui-input-datetime" name="at" type="datetime-local" />
    """
  end

  def example(%{section: "text-input-username"} = assigns) do
    ~H"""
    <div class="w-xs">
      <.text_input
        id="daisyui-input-username"
        name="username"
        class="d-validator"
        placeholder="Username"
        required
        pattern="[A-Za-z][A-Za-z0-9\-]*"
        minlength="3"
        maxlength="30"
        title="Only letters, numbers or dash"
      >
        <:start_section>
          <.field_icon path="M12 12a4 4 0 100-8 4 4 0 000 8zM4 20a8 8 0 0116 0" />
        </:start_section>
      </.text_input>
      <p class="d-validator-hint">
        Must be 3 to 30 characters, containing only letters, numbers or dash
      </p>
    </div>
    """
  end

  def example(%{section: "text-input-search"} = assigns) do
    ~H"""
    <.text_input id="daisyui-input-search" name="q" type="search" placeholder="Search" required>
      <:start_section>
        <.field_icon path="M11 19a8 8 0 100-16 8 8 0 000 16zM21 21l-4.35-4.35" />
      </:start_section>
    </.text_input>
    """
  end

  def example(%{section: "text-input-email"} = assigns) do
    ~H"""
    <div class="w-xs">
      <.text_input
        id="daisyui-input-email"
        name="email"
        type="email"
        class="d-validator"
        placeholder="mail@site.com"
        required
      >
        <:start_section>
          <.field_icon path="M3 7l9 6 9-6M3 7v10h18V7H3z" />
        </:start_section>
      </.text_input>
      <div class="d-validator-hint">Enter valid email address</div>
    </div>
    """
  end

  def example(%{section: "text-input-join"} = assigns) do
    ~H"""
    <form id="daisyui-input-join-form" phx-submit="daisyui_text_input_submit" class="d-join">
      <.text_input
        id="daisyui-input-join"
        name="email"
        type="email"
        class="d-join-item"
        placeholder="Enter your email"
        required
      />
      <button type="submit" class="d-btn d-btn-primary d-join-item">Subscribe</button>
    </form>
    """
  end

  def example(%{section: "text-input-password"} = assigns) do
    ~H"""
    <div class="w-xs">
      <.text_input
        id="daisyui-input-password"
        name="password"
        type="password"
        class="d-validator"
        placeholder="Password"
        required
        minlength="8"
        pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).*"
        title="Must be more than 8 characters, including a number, a lowercase and an uppercase letter"
      >
        <:start_section>
          <.field_icon path="M7 11V8a5 5 0 0110 0v3M5 11h14v10H5V11z" />
        </:start_section>
      </.text_input>
      <p class="d-validator-hint">
        Must be more than 8 characters, including a number, a lowercase and an uppercase letter
      </p>
    </div>
    """
  end

  def example(%{section: "text-input-number"} = assigns) do
    ~H"""
    <div class="w-xs">
      <.text_input
        id="daisyui-input-number"
        name="quantity"
        type="number"
        class="d-validator"
        placeholder="Between 1 and 10"
        required
        min="1"
        max="10"
        title="Must be between 1 and 10"
      />
      <p class="d-validator-hint">Must be between 1 and 10</p>
    </div>
    """
  end

  def example(%{section: "text-input-tel"} = assigns) do
    ~H"""
    <div class="w-xs">
      <.text_input
        id="daisyui-input-tel"
        name="phone"
        type="tel"
        class="d-validator tabular-nums"
        placeholder="Phone"
        required
        pattern="[0-9]*"
        minlength="10"
        maxlength="10"
        title="Must be 10 digits"
      >
        <:start_section>
          <.field_icon path="M5 4h4l2 5-2.5 1.5a11 11 0 005 5L15 13l5 2v4a1 1 0 01-1 1A16 16 0 014 5a1 1 0 011-1z" />
        </:start_section>
      </.text_input>
      <p class="d-validator-hint">Must be 10 digits</p>
    </div>
    """
  end

  def example(%{section: "text-input-url"} = assigns) do
    ~H"""
    <div class="w-xs">
      <.text_input
        id="daisyui-input-url"
        name="url"
        type="url"
        class="d-validator"
        placeholder="https://"
        required
      >
        <:start_section>
          <.field_icon path="M10 13a5 5 0 007 0l3-3a5 5 0 00-7-7l-1 1M14 11a5 5 0 00-7 0l-3 3a5 5 0 007 7l1-1" />
        </:start_section>
      </.text_input>
      <p class="d-validator-hint">Must be valid URL</p>
    </div>
    """
  end

  def example(%{section: "text-input-form"} = assigns) do
    # Same errors on both forms; only the right one has params, so only the right one has been
    # "used". That difference is the whole point — `used_input?/1` is what keeps a freshly rendered
    # form from being red before anyone has typed in it.
    errors = [email: {"must have the @ sign", []}]

    assigns =
      assigns
      |> assign(:pristine, to_form(%{}, as: :pristine, errors: errors))
      |> assign(:touched, to_form(%{"email" => "nope"}, as: :touched, errors: errors))

    ~H"""
    <form
      id="daisyui-input-form"
      phx-submit="daisyui_text_input_submit"
      class="flex flex-wrap items-start gap-6"
    >
      <.field :let={f} id="daisyui-input-pristine" label="Pristine" class="d-fieldset">
        <.text_input
          field={@pristine[:email]}
          type="email"
          placeholder="you@example.com"
          describedby={f.describedby}
        />
        <:description>Has an error; not shown yet.</:description>
      </.field>

      <.field
        :let={f}
        id="daisyui-input-touched"
        label="Touched"
        errors={Enum.map(@touched[:email].errors, &elem(&1, 0))}
        class="d-fieldset"
      >
        <.text_input field={@touched[:email]} type="email" describedby={f.describedby} />
      </.field>

      <button type="submit" class="d-btn d-btn-primary self-center">Save</button>
    </form>
    """
  end

  # ── textarea ──────────────────────────────────────────────────────────────
  def example(%{section: "textarea-hero"} = assigns) do
    ~H"""
    <.textarea id="daisyui-textarea-hero" name="bio" placeholder="Bio" />
    """
  end

  def example(%{section: "textarea-ghost"} = assigns) do
    ~H"""
    <.textarea id="daisyui-textarea-ghost" name="ghost" class="d-textarea-ghost" placeholder="Bio" />
    """
  end

  def example(%{section: "textarea-field"} = assigns) do
    ~H"""
    <.field
      :let={f}
      id="daisyui-textarea-field"
      name="bio"
      label="Your bio"
      class="d-fieldset w-xs"
      label_class="d-fieldset-legend"
    >
      <.textarea id={f.id} name={f.name} placeholder="Bio" describedby={f.describedby} />
      <:description>Optional</:description>
    </.field>
    """
  end

  def example(%{section: "textarea-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-col gap-2">
      <.textarea
        :for={color <- @colors}
        id={"daisyui-textarea-#{color}"}
        name={color}
        rows={2}
        class={"d-textarea-#{color}"}
        placeholder={String.capitalize(color)}
      />
    </div>
    """
  end

  def example(%{section: "textarea-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-col gap-2">
      <.textarea
        :for={size <- @sizes}
        id={"daisyui-textarea-size-#{size}"}
        name={size}
        rows={2}
        class={"d-textarea-#{size}"}
        placeholder={"Size #{size}"}
      />
    </div>
    """
  end

  def example(%{section: "textarea-disabled"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.textarea id="daisyui-textarea-disabled" name="disabled" placeholder="You can't type" disabled />
      <.textarea id="daisyui-textarea-disabled-value" name="locked" value="Locked" disabled />
    </div>
    """
  end

  def example(%{section: "textarea-autosize"} = assigns) do
    ~H"""
    <.textarea
      id="daisyui-textarea-autosize"
      name="notes"
      placeholder="Keep typing — this grows to six rows, then scrolls"
      autosize
      min_rows={2}
      max_rows={6}
    />
    """
  end

  def example(%{section: "textarea-form"} = assigns) do
    assigns = assign(assigns, :form, to_form(%{"bio" => "Elixir developer."}, as: :profile))

    ~H"""
    <form
      id="daisyui-textarea-form-el"
      phx-change="daisyui_textarea_change"
      phx-submit="daisyui_textarea_submit"
      class="flex w-xs flex-col gap-2"
    >
      <.field :let={f} id="daisyui-textarea-form" label="Bio" class="d-fieldset">
        <.textarea
          field={@form[:bio]}
          rows={3}
          placeholder="Tell us about yourself"
          describedby={f.describedby}
        />
        <:description>Changes push on every keystroke.</:description>
      </.field>
      <button type="submit" class="d-btn d-btn-primary self-start">Save</button>
    </form>
    """
  end

  # ── file_input ────────────────────────────────────────────────────────────
  def example(%{section: "file-input-hero"} = assigns) do
    ~H"""
    <.file_input id="daisyui-file-hero" name="attachment" />
    """
  end

  def example(%{section: "file-input-ghost"} = assigns) do
    ~H"""
    <.file_input id="daisyui-file-ghost" name="ghost" class="d-file-input-ghost" />
    """
  end

  def example(%{section: "file-input-field"} = assigns) do
    ~H"""
    <.field
      :let={f}
      id="daisyui-file-field"
      name="avatar"
      label="Pick a file"
      class="d-fieldset w-xs"
      label_class="d-fieldset-legend"
    >
      <.file_input id={f.id} name={f.name} accept="image/*" describedby={f.describedby} />
      <:description>Max size 2MB</:description>
    </.field>
    """
  end

  def example(%{section: "file-input-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-col gap-2">
      <.file_input
        :for={size <- @sizes}
        id={"daisyui-file-size-#{size}"}
        name={size}
        class={"d-file-input-#{size}"}
      />
    </div>
    """
  end

  def example(%{section: "file-input-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-col gap-2">
      <.file_input
        :for={color <- @colors}
        id={"daisyui-file-#{color}"}
        name={color}
        class={"d-file-input-#{color}"}
      />
    </div>
    """
  end

  def example(%{section: "file-input-disabled"} = assigns) do
    ~H"""
    <.file_input id="daisyui-file-disabled" name="disabled" disabled />
    """
  end

  def example(%{section: "file-input-form"} = assigns) do
    assigns = assign(assigns, :form, to_form(%{}, as: :upload))

    ~H"""
    <form
      id="daisyui-file-form"
      phx-submit="daisyui_file_input_submit"
      class="flex w-xs flex-col gap-3"
    >
      <.field :let={f} id="daisyui-file-form-single" label="Attachment" class="d-fieldset">
        <.file_input field={@form[:attachment]} describedby={f.describedby} />
        <:description>One file, posted as <code>upload[attachment]</code>.</:description>
      </.field>

      <.field :let={f} id="daisyui-file-form-many" label="Gallery" class="d-fieldset">
        <.file_input field={@form[:gallery]} multiple accept="image/*" describedby={f.describedby} />
        <:description>
          Several files — the name gains <code>[]</code> so Plug builds a list.
        </:description>
      </.field>

      <button type="submit" class="d-btn d-btn-primary self-start">Upload</button>
    </form>
    """
  end

  # ── card ──────────────────────────────────────────────────────────────────
  def example(%{section: "card-hero"} = assigns) do
    ~H"""
    <.card id="daisyui-card-hero" class="d-card bg-base-100 w-80 shadow-sm">
      <:figure><.card_image /></:figure>
      <:title>Shoes!</:title>
      If a dog chews shoes whose shoes does he choose?
      <:actions>
        <div class="ml-auto">
          <button type="button" class="d-btn d-btn-primary">Buy now</button>
        </div>
      </:actions>
    </.card>
    """
  end

  def example(%{section: "card-pricing"} = assigns) do
    ~H"""
    <.card id="daisyui-card-pricing" class="bg-base-100 w-80 shadow-sm">
      <:title>Pro plan</:title>
      <div class="flex flex-col gap-2">
        <span class="text-2xl font-semibold">$29<span class="text-sm font-normal">/mo</span></span>
        <ul class="flex flex-col gap-1 text-sm">
          <li :for={feature <- ["Unlimited projects", "Priority support", "Custom domain"]}>
            ✓ {feature}
          </li>
        </ul>
      </div>
      <:actions>
        <button type="button" class="d-btn d-btn-primary d-btn-block">Subscribe</button>
      </:actions>
    </.card>
    """
  end

  def example(%{section: "card-sizes"} = assigns) do
    assigns = assign(assigns, :sizes, @sizes)

    ~H"""
    <div class="flex flex-wrap items-start gap-3">
      <.card
        :for={size <- @sizes}
        id={"daisyui-card-#{size}"}
        class={"d-card-#{size} bg-base-100 w-52 shadow-sm"}
      >
        <:title>card-{size}</:title>
        A card with the {size} padding scale.
      </.card>
    </div>
    """
  end

  def example(%{section: "card-border"} = assigns) do
    ~H"""
    <.card id="daisyui-card-border" class="d-card-border bg-base-100 w-80">
      <:title>Bordered</:title>
      A card with a solid border instead of a shadow.
    </.card>
    """
  end

  def example(%{section: "card-dash"} = assigns) do
    ~H"""
    <.card id="daisyui-card-dash" class="d-card-dash bg-base-100 w-80">
      <:title>Dashed</:title>
      A card with a dashed border — reads as a placeholder or a drop target.
    </.card>
    """
  end

  def example(%{section: "card-badge"} = assigns) do
    ~H"""
    <.card id="daisyui-card-badge" class="bg-base-100 w-80 shadow-sm">
      <:title>
        Shoes!
        <div class="d-badge d-badge-secondary">NEW</div>
      </:title>
      If a dog chews shoes whose shoes does he choose?
      <:actions>
        <div class="d-badge d-badge-outline">Fashion</div>
        <div class="d-badge d-badge-outline">Products</div>
      </:actions>
    </.card>
    """
  end

  def example(%{section: "card-bottom-image"} = assigns) do
    ~H"""
    <.card id="daisyui-card-bottom" figure_position="end" class="bg-base-100 w-80 shadow-sm">
      <:title>Shoes!</:title>
      If a dog chews shoes whose shoes does he choose?
      <:figure><.card_image /></:figure>
    </.card>
    """
  end

  def example(%{section: "card-centered"} = assigns) do
    ~H"""
    <.card id="daisyui-card-centered" class="bg-base-100 w-80 shadow-sm">
      <:figure><.card_image class="rounded-xl" /></:figure>
      <div class="flex flex-col items-center gap-2 pt-2 text-center">
        <h3 class="d-card-title">Shoes!</h3>
        <p>A card with centered content and a padded, rounded image.</p>
        <button type="button" class="d-btn d-btn-primary">Buy now</button>
      </div>
    </.card>
    """
  end

  def example(%{section: "card-image-overlay"} = assigns) do
    ~H"""
    <.card id="daisyui-card-overlay" class="d-image-full w-80 shadow-sm">
      <:figure><.card_image /></:figure>
      <:title>Shoes!</:title>
      If a dog chews shoes whose shoes does he choose?
      <:actions>
        <div class="ml-auto">
          <button type="button" class="d-btn d-btn-primary">Buy now</button>
        </div>
      </:actions>
    </.card>
    """
  end

  def example(%{section: "card-no-image"} = assigns) do
    ~H"""
    <.card id="daisyui-card-no-image" class="bg-base-100 w-80 shadow-sm">
      <:title>Card title</:title>
      A card with no image at all — just a padded box with a heading.
      <:actions>
        <div class="ml-auto">
          <button type="button" class="d-btn d-btn-primary">Buy now</button>
        </div>
      </:actions>
    </.card>
    """
  end

  def example(%{section: "card-custom-color"} = assigns) do
    ~H"""
    <.card id="daisyui-card-custom" class="bg-primary text-primary-content w-80">
      <:title>Card title</:title>
      Theme colors on the root; everything inside inherits them.
      <:actions>
        <div class="ml-auto">
          <button type="button" class="d-btn">Buy now</button>
        </div>
      </:actions>
    </.card>
    """
  end

  def example(%{section: "card-neutral"} = assigns) do
    ~H"""
    <.card id="daisyui-card-neutral" class="bg-neutral text-neutral-content w-80">
      <div class="flex flex-col items-center gap-2 text-center">
        <h3 class="d-card-title">Cookies!</h3>
        <p>We are using cookies for no reason.</p>
        <div class="flex gap-2">
          <button type="button" class="d-btn d-btn-primary">Accept</button>
          <button type="button" class="d-btn d-btn-ghost">Deny</button>
        </div>
      </div>
    </.card>
    """
  end

  def example(%{section: "card-actions-top"} = assigns) do
    ~H"""
    <.card id="daisyui-card-actions-top" class="bg-base-100 w-80 shadow-sm">
      <:actions>
        <div class="ml-auto flex gap-1">
          <button type="button" class="d-btn d-btn-square d-btn-sm" aria-label="Archive">
            <.field_icon path="M4 7h16v3H4zM6 10h12v10H6zM10 14h4" />
          </button>
          <button type="button" class="d-btn d-btn-square d-btn-sm" aria-label="Close">
            <.field_icon path="M6 6l12 12M18 6L6 18" />
          </button>
        </div>
      </:actions>
      <:title>Card title</:title>
      The actions row is rendered first in the body, so it sits above the heading.
    </.card>
    """
  end

  def example(%{section: "card-side"} = assigns) do
    ~H"""
    <.card id="daisyui-card-side" class="d-card-side bg-base-100 w-96 shadow-sm">
      <:figure><.card_image class="w-32" /></:figure>
      <:title>New movie is released!</:title>
      Click the button to watch on Jetflix app.
      <:actions>
        <div class="ml-auto">
          <button type="button" class="d-btn d-btn-primary">Watch</button>
        </div>
      </:actions>
    </.card>
    """
  end

  def example(%{section: "card-responsive"} = assigns) do
    ~H"""
    <.card id="daisyui-card-responsive" class="bg-base-100 w-96 shadow-sm sm:d-card-side">
      <:figure><.card_image class="sm:w-32" /></:figure>
      <:title>Responsive</:title>
      Vertical below <code>sm</code>, horizontal from <code>sm</code>
      up. Resize the window.
    </.card>
    """
  end

  def example(%{section: "card-selectable"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-3">
      <.card
        :for={{plan, price, checked} <- [{"Starter", "$0", true}, {"Team", "$29", false}]}
        id={"daisyui-card-select-#{String.downcase(plan)}"}
        class="d-card-border bg-base-100 w-48 cursor-pointer"
      >
        <:title>{plan}</:title>
        <label class="flex items-center gap-2">
          <input type="radio" name="daisyui_card_plan" value={plan} checked={checked} class="d-radio" />
          <span>{price} / month</span>
        </label>
      </.card>
    </div>
    """
  end

  def example(%{section: "card-link"} = assigns) do
    ~H"""
    <.card
      id="daisyui-card-link"
      navigate="/showcase/headless-daisyui/card"
      class="d-card-border bg-base-100 w-80 transition hover:shadow-md"
    >
      <:title>The whole card is the link</:title>
      The root renders as an anchor, so there is one focus stop and one click target — not a link
      nested inside a clickable box.
    </.card>
    """
  end

  attr :paint, :string, default: "tailwind", values: ~w(tailwind css theme)
  slot :inner_block, required: true

  # A daisyUI fab is `position: fixed`; a contained one is `absolute`, so it needs a positioned
  # ancestor — and nine fabs all pinned to the viewport corner would land on top of each other.
  defp fab_frame(assigns) do
    ~H"""
    <.preview_frame paint={@paint} class="relative h-48 w-64 overflow-hidden">
      {render_slot(@inner_block)}
    </.preview_frame>
    """
  end

  attr :id, :string, required: true
  slot :inner_block, required: true

  # Each controller repaints this box rather than the page: a gallery of ten theme controllers that
  # all targeted `:root` would fight each other, and the last one clicked would win the whole page.
  # `paint="theme"` is not a preference here, it is the demo: the box has to repaint when the
  # controller changes the theme, and only daisyUI's own tokens follow `data-theme`. Painting it in
  # fixed Tailwind colours would leave it stubbornly the same shade whichever theme was picked.
  defp theme_preview(assigns) do
    ~H"""
    <.preview_frame id={@id} paint="theme" class="flex w-72 flex-col items-center gap-3 p-6">
      {render_slot(@inner_block)}
      <p class="text-xs opacity-60">This box follows the choice above.</p>
    </.preview_frame>
    """
  end

  # A fixed offset rather than a wall-clock date: the examples have to read the same every time the
  # page is rendered, including in a test, and a hard-coded date would eventually go negative.
  defp countdown_target(:launch) do
    DateTime.utc_now() |> DateTime.add(2 * 86_400 + 5 * 3_600 + 42 * 60 + 17)
  end

  attr :height, :string, default: "h-40"
  attr :align, :string, default: "items-end"
  attr :paint, :string, default: "tailwind", values: ~w(tailwind css theme)
  slot :inner_block, required: true

  # A daisyUI dock is `position: fixed`; a contained one is `absolute`, which needs a positioned
  # ancestor. This frame is that ancestor — and it is also what keeps three docks on one page from
  # stacking on top of each other at the bottom of the viewport.
  defp dock_frame(assigns) do
    ~H"""
    <.preview_frame paint={@paint} class={["relative w-72 overflow-hidden", @height, @align]}>
      {render_slot(@inner_block)}
    </.preview_frame>
    """
  end

  attr :id, :string, default: nil
  attr :class, :any, default: nil

  attr :paint, :string,
    default: "tailwind",
    values: ~w(tailwind css theme),
    doc: "Which palette draws the box; see the note above the function"

  slot :inner_block, required: true

  # The box these demos sit in, in three palettes, because they are not interchangeable:
  #
  #   * `tailwind` — Tailwind 4 utilities, written out. The default, and the one to copy: it needs
  #     nothing from this harness and drops into any Tailwind project unchanged.
  #   * `css` — the showcase chrome's own `--c-*` variables, so a frame can match the page around
  #     it rather than sitting in it as a lighter or darker rectangle.
  #   * `theme` — daisyUI's `base-*` tokens, which follow `data-theme`. The only one that repaints
  #     when a theme controller changes the theme.
  #
  # Keeping all three is the point: Tailwind is the readable default, and the other two exist
  # because there are things they can do that it cannot.
  defp preview_frame(assigns) do
    ~H"""
    <div id={@id} data-paint={@paint} class={[frame_paint(@paint), "rounded-xl border", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp frame_paint("tailwind"),
    do: "border-neutral-200 bg-white dark:border-neutral-800 dark:bg-neutral-950"

  defp frame_paint("css"), do: "border-[var(--c-base-300)] bg-[var(--c-base-100)]"
  defp frame_paint("theme"), do: "border-base-300 bg-base-100 text-base-content"

  defp daisyui_autocomplete_movies do
    [
      %{title: "Sample Film One", year: 2021},
      %{title: "Sample Film Two", year: 2019},
      %{title: "Another Picture", year: 2023},
      %{title: "A Short Story", year: 2018}
    ]
  end

  defp daisyui_autocomplete_palette_commands do
    [
      %{label: "Toggle theme", name: "toggle-theme"},
      %{label: "Format document", name: "format"},
      %{label: "Go to line", name: "goto-line"},
      %{label: "Find in files", name: "find"}
    ]
  end

  defp daisyui_autocomplete_palette_suggestions do
    [
      %{label: "New file", name: "new-file"},
      %{label: "New window", name: "new-window"},
      %{label: "Open recent", name: "open-recent"}
    ]
  end

  defp daisyui_autocomplete_tags do
    [
      %{value: "feature", group: "Type"},
      %{value: "bug", group: "Type"},
      %{value: "docs", group: "Area"},
      %{value: "design", group: "Area"},
      %{value: "urgent", group: "Priority"}
    ]
  end

  defp daisyui_autocomplete_docs do
    [
      %{title: "Quick start", description: "Install and render your first component."},
      %{title: "Styling", description: "Bring your own CSS or Tailwind utilities."},
      %{title: "Accessibility", description: "Built-in ARIA roles and keyboard support."},
      %{title: "Theming", description: "Tokens, dark mode, and variants."}
    ]
  end

  defp daisyui_autocomplete_emojis do
    [
      %{emoji: "😀", name: "grinning", group: "Smileys"},
      %{emoji: "🎉", name: "party", group: "Objects"},
      %{emoji: "🚀", name: "rocket", group: "Travel"},
      %{emoji: "❤️", name: "heart", group: "Symbols"},
      %{emoji: "👍", name: "thumbs up", group: "People"}
    ]
  end

  defp daisyui_autocomplete_limit_tags do
    Enum.map(~w(react vue svelte angular solid qwik ember preact lit alpine), &%{value: &1})
  end

  attr :path, :string, required: true

  defp dock_icon(assigns) do
    ~H"""
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.6"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="size-5"
      aria-hidden="true"
    >
      <path d={@path} />
    </svg>
    """
  end

  attr :class, :any, default: nil

  # No gradient `<defs>`: a def needs an id, and this placeholder is rendered once per card on a
  # page full of them. Stacked flat fills give the same look with nothing to collide.
  defp card_image(assigns) do
    ~H"""
    <svg viewBox="0 0 320 160" class={["h-40 w-full object-cover", @class]} aria-hidden="true">
      <rect width="320" height="160" fill="oklch(66% 0.17 285)" />
      <rect width="320" height="160" fill="oklch(60% 0.19 320)" opacity="0.45" />
      <circle cx="70" cy="52" r="24" fill="oklch(100% 0 0 / 0.35)" />
      <path d="M0 160L110 74l70 52 50-34 90 68z" fill="oklch(0% 0 0 / 0.22)" />
    </svg>
    """
  end

  attr :path, :string, required: true

  defp field_icon(assigns) do
    ~H"""
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.6"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="size-4 shrink-0 opacity-60"
      aria-hidden="true"
    >
      <path d={@path} />
    </svg>
    """
  end

  # daisyUI labels their size and colour examples with names, not class names — "Xsmall", "Primary".
  # Reading "badge-xs" tells you what is already in the code block above it; reading "Xsmall" shows
  # you the thing the example is about.
  defp size_label("xs"), do: "Xsmall"
  defp size_label("sm"), do: "Small"
  defp size_label("md"), do: "Medium"
  defp size_label("lg"), do: "Large"
  defp size_label("xl"), do: "Xlarge"

  defp color_label(color), do: String.capitalize(color)

  # daisyUI's own alert copy, so the soft / outline / dash rows read the same as their page.
  defp alert_messages do
    [
      {"info", "12 unread messages. Tap to see."},
      {"success", "Your purchase has been confirmed!"},
      {"warning", "Warning: Invalid email address!"},
      {"error", "Error! Task failed successfully."}
    ]
  end

  # Their alert glyphs verbatim — 24px at stroke 2 with round caps, where `nav_icon` is 16px at
  # 1.6. Same paths, so the shapes are theirs rather than something similar.
  attr :kind, :string, required: true, values: ~w(info success warning error)
  attr :class, :string, default: nil

  defp alert_icon(assigns) do
    ~H"""
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class={["h-6 w-6 shrink-0", @class]}
    >
      <path d={alert_icon_path(@kind)} />
    </svg>
    """
  end

  defp alert_icon_path("info"), do: "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
  defp alert_icon_path("success"), do: "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"

  defp alert_icon_path("warning"),
    do:
      "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"

  defp alert_icon_path("error"),
    do: "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"

  # daisyUI's sun and moon, in the two shapes their theme-controller examples use them: filled for
  # the swap, stroked for the toggle's inside glyphs.
  attr :kind, :string, required: true, values: ~w(sun moon)
  attr :stroked, :boolean, default: false
  attr :class, :string, default: nil

  defp theme_glyph(%{stroked: true} = assigns) do
    ~H"""
    <svg
      aria-label={@kind}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class={@class}
    >
      <g :if={@kind == "sun"}>
        <circle cx="12" cy="12" r="4" />
        <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41" />
      </g>
      <path :if={@kind == "moon"} d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z" />
    </svg>
    """
  end

  defp theme_glyph(assigns) do
    ~H"""
    <svg aria-label={@kind} viewBox="0 0 24 24" class={@class}>
      <path
        :if={@kind == "sun"}
        d="M12 6a6 6 0 106 6 6 6 0 00-6-6zm0-4a1 1 0 011 1v1a1 1 0 01-2 0V3a1 1 0 011-1zm0 18a1 1 0 011 1v1a1 1 0 01-2 0v-1a1 1 0 011-1zM3 11h1a1 1 0 010 2H3a1 1 0 010-2zm17 0h1a1 1 0 010 2h-1a1 1 0 010-2zM5.64 4.22l.71.71a1 1 0 01-1.42 1.42l-.7-.71a1 1 0 011.41-1.42zm12.02 12.02l.71.71a1 1 0 01-1.42 1.41l-.7-.7a1 1 0 011.41-1.42zm.71-10.6l-.71.71a1 1 0 01-1.41-1.42l.7-.7a1 1 0 011.42 1.41zM6.35 17.66l-.71.71a1 1 0 01-1.41-1.42l.7-.7a1 1 0 011.42 1.41z"
      />
      <path
        :if={@kind == "moon"}
        d="M21.64 13a1 1 0 00-1.05-.14 8 8 0 01-9.45-9.45A1 1 0 0010 2.36 10 10 0 1022 14.05a1 1 0 00-.36-1.05z"
      />
    </svg>
    """
  end

  attr :path, :string, required: true

  defp nav_icon(assigns) do
    ~H"""
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.6"
      class="size-4 shrink-0"
    >
      <path d={@path} />
    </svg>
    """
  end
end
