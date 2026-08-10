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
      {"checkbox-sizes", "Sizes", "`checkbox-xs` through `checkbox-xl`."},
      {"checkbox-colors", "Colors", "All eight `checkbox-*` colors."},
      {"checkbox-disabled", "Disabled", "Checked and unchecked, both disabled."},
      {"checkbox-indeterminate", "Indeterminate",
       "daisyUI needs JavaScript to set `.indeterminate`; ours is a server-rendered attribute."},
      {"checkbox-custom-colors", "Custom colors",
       "daisyUI's custom-color recipe, with `data-checked` standing in for `:checked`."},
      {"checkbox-form", "With fieldset and label",
       "A checkbox group in a fieldset, submitted as real form fields."}
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
      {"tabs-lift", "tabs-lift", "daisyUI's `tabs-lift`, including its notched corners."},
      {"tabs-box", "tabs-box", "daisyUI's `tabs-box`."},
      {"tabs-sizes", "Sizes", "`tabs-xs` through `tabs-xl` on the lift style."},
      {"tabs-bottom", "Tabs on the bottom",
       "daisyUI's `tabs-bottom` with the panel above the row."},
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
      {"separator-colors", "Colors", "All eight `divider-*` colors."}
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
       "Your own loader instead of the spinner."}
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
      {"button-submit", "In a form", "A submit button wired to a form."}
    ],
    "alert" => [
      {"alert-hero", "Alert", "daisyUI's `alert`."},
      {"alert-colors", "Colors",
       "`alert-info`, `alert-success`, `alert-warning`, `alert-error`."},
      {"alert-soft", "Soft", "daisyUI's `alert-soft`."},
      {"alert-outline", "Outline", "daisyUI's `alert-outline`."},
      {"alert-dash", "Dash", "daisyUI's `alert-dash`."},
      {"alert-actions", "With buttons",
       "daisyUI's `alert-vertical sm:alert-horizontal`, with our `:actions` part."},
      {"alert-title", "With title and description",
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
      <.pill :for={size <- @sizes} class={"d-badge-#{size}"}>badge-{size}</.pill>
    </div>
    """
  end

  def example(%{section: "pill-colors"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-2">
      <.pill :for={color <- @colors} class={"d-badge-#{color}"}>{color}</.pill>
    </div>
    """
  end

  def example(%{section: "pill-soft"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-2">
      <.pill :for={color <- @colors} class={"d-badge-soft d-badge-#{color}"}>{color}</.pill>
    </div>
    """
  end

  def example(%{section: "pill-outline"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-2">
      <.pill :for={color <- @colors} class={"d-badge-outline d-badge-#{color}"}>{color}</.pill>
    </div>
    """
  end

  def example(%{section: "pill-dash"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-wrap gap-2">
      <.pill :for={color <- @colors} class={"d-badge-dash d-badge-#{color}"}>{color}</.pill>
    </div>
    """
  end

  def example(%{section: "pill-neutral-variants"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      <.pill class="d-badge-neutral d-badge-outline">outline</.pill>
      <.pill class="d-badge-neutral d-badge-dash">dash</.pill>
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
    <.progress id="daisyui-progress-hero" value={40} class="w-56" />
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
        class={["w-56", "d-progress-#{color}"]}
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
        class="w-56"
      />
    </div>
    """
  end

  def example(%{section: "progress-indeterminate"} = assigns) do
    ~H"""
    <.progress id="daisyui-progress-indeterminate" class="w-56" />
    """
  end

  def example(%{section: "progress-labelled"} = assigns) do
    ~H"""
    <.progress
      id="daisyui-progress-labelled"
      value={64}
      label="Uploading"
      show_value
      class="w-56 d-progress-primary"
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
    <.alert id="daisyui-alert-hero" class="w-xs">
      <:icon><.nav_icon path="M12 8h.01M11 12h1v4h1" /></:icon>
      12 unread messages. Tap to see.
    </.alert>
    """
  end

  def example(%{section: "alert-colors"} = assigns) do
    ~H"""
    <div class="flex w-xs flex-col gap-2">
      <.alert
        :for={color <- ~w(info success warning error)}
        id={"daisyui-alert-#{color}"}
        class={"d-alert-#{color}"}
      >
        alert-{color}
      </.alert>
    </div>
    """
  end

  def example(%{section: "alert-soft"} = assigns) do
    ~H"""
    <div class="flex w-xs flex-col gap-2">
      <.alert
        :for={color <- ~w(info success warning error)}
        id={"daisyui-alert-soft-#{color}"}
        class={"d-alert-soft d-alert-#{color}"}
      >
        alert-{color}
      </.alert>
    </div>
    """
  end

  def example(%{section: "alert-outline"} = assigns) do
    ~H"""
    <div class="flex w-xs flex-col gap-2">
      <.alert
        :for={color <- ~w(info success warning error)}
        id={"daisyui-alert-outline-#{color}"}
        class={"d-alert-outline d-alert-#{color}"}
      >
        alert-{color}
      </.alert>
    </div>
    """
  end

  def example(%{section: "alert-dash"} = assigns) do
    ~H"""
    <div class="flex w-xs flex-col gap-2">
      <.alert
        :for={color <- ~w(info success warning error)}
        id={"daisyui-alert-dash-#{color}"}
        class={"d-alert-dash d-alert-#{color}"}
      >
        alert-{color}
      </.alert>
    </div>
    """
  end

  def example(%{section: "alert-actions"} = assigns) do
    ~H"""
    <.alert id="daisyui-alert-actions" class="w-xs d-alert-vertical sm:d-alert-horizontal">
      We use cookies for no reason.
      <:actions>
        <.button class="d-btn-sm">Deny</.button>
        <.button class="d-btn-sm d-btn-primary">Accept</.button>
      </:actions>
    </.alert>
    """
  end

  def example(%{section: "alert-title"} = assigns) do
    ~H"""
    <.alert id="daisyui-alert-title" class="w-xs d-alert-vertical sm:d-alert-horizontal">
      <:icon><.nav_icon path="M12 9v4m0 4h.01" /></:icon>
      <:title>New software update available</:title>
      A new release is ready to install.
      <:actions>
        <.button class="d-btn-sm">Later</.button>
      </:actions>
    </.alert>
    """
  end

  def example(%{section: "alert-urgency"} = assigns) do
    ~H"""
    <div class="flex w-xs flex-col gap-2">
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
    <.alert id="daisyui-alert-dismiss" class="w-xs d-alert-success" dismissible>
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
        placeholder={"select-#{size}"}
        class="w-56"
        trigger_class={"d-select-#{size}"}
      >
        <:option value="one">One</:option>
        <:option value="two">Two</:option>
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
    <form phx-change="daisyui_pagination_change">
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

  attr :height, :string, default: "h-40"
  attr :align, :string, default: "items-end"
  slot :inner_block, required: true

  # A daisyUI dock is `position: fixed`; a contained one is `absolute`, which needs a positioned
  # ancestor. This frame is that ancestor — and it is also what keeps three docks on one page from
  # stacking on top of each other at the bottom of the viewport.
  defp dock_frame(assigns) do
    ~H"""
    <div class={[
      "relative w-72 overflow-hidden rounded-xl border border-[var(--c-base-300)] bg-[var(--c-base-100)]",
      @height,
      @align
    ]}>
      {render_slot(@inner_block)}
    </div>
    """
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
