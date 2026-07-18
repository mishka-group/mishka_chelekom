defmodule DevelopmentWeb.Showcase.HeadlessBaseUIExamples do
  @moduledoc """
  Faithful ports of Base UI's own component demos (the `tailwind` variants), rebuilt with our
  Phoenix headless components. ExampleSource lifts each ~H for the copy-paste code block.
  """
  use Phoenix.Component

  import DevelopmentWeb.Components.Headless.Accordion
  import DevelopmentWeb.Components.Headless.ActionIcon
  import DevelopmentWeb.Components.Headless.AlertDialog
  import DevelopmentWeb.Components.Headless.AlphaSlider
  import DevelopmentWeb.Components.Headless.Anchor
  import DevelopmentWeb.Components.Headless.Autocomplete
  import DevelopmentWeb.Components.Headless.Avatar
  import DevelopmentWeb.Components.Headless.Burger
  import DevelopmentWeb.Components.Headless.Checkbox
  import DevelopmentWeb.Components.Headless.CheckboxGroup
  import DevelopmentWeb.Components.Headless.Chip
  import DevelopmentWeb.Components.Headless.CloseButton
  import DevelopmentWeb.Components.Headless.Code
  import DevelopmentWeb.Components.Headless.Collapsible
  import DevelopmentWeb.Components.Headless.ColorPicker
  import DevelopmentWeb.Components.Headless.ColorSwatch
  import DevelopmentWeb.Components.Headless.Combobox
  import DevelopmentWeb.Components.Headless.ContextMenu
  import DevelopmentWeb.Components.Headless.Dialog
  import DevelopmentWeb.Components.Headless.Drawer
  import DevelopmentWeb.Components.Headless.EmptyState
  import DevelopmentWeb.Components.Headless.Field
  import DevelopmentWeb.Components.Headless.Fieldset
  import DevelopmentWeb.Components.Headless.Highlight
  import DevelopmentWeb.Components.Headless.HueSlider
  import DevelopmentWeb.Components.Headless.Mark
  import DevelopmentWeb.Components.Headless.Marquee
  import DevelopmentWeb.Components.Headless.Menu
  import DevelopmentWeb.Components.Headless.Menubar
  import DevelopmentWeb.Components.Headless.Meter
  import DevelopmentWeb.Components.Headless.NavigationMenu
  import DevelopmentWeb.Components.Headless.NumberField
  import DevelopmentWeb.Components.Headless.NumberFormatter
  import DevelopmentWeb.Components.Headless.OtpField
  import DevelopmentWeb.Components.Headless.Pill
  import DevelopmentWeb.Components.Headless.Popover
  import DevelopmentWeb.Components.Headless.PreviewCard
  import DevelopmentWeb.Components.Headless.Progress
  import DevelopmentWeb.Components.Headless.Radio
  import DevelopmentWeb.Components.Headless.RollingNumber
  import DevelopmentWeb.Components.Headless.ScrollArea
  import DevelopmentWeb.Components.Headless.Scroller
  import DevelopmentWeb.Components.Headless.Select
  import DevelopmentWeb.Components.Headless.SemiCircleProgress
  import DevelopmentWeb.Components.Headless.Separator
  import DevelopmentWeb.Components.Headless.Slider
  import DevelopmentWeb.Components.Headless.Splitter
  import DevelopmentWeb.Components.Headless.Spoiler
  import DevelopmentWeb.Components.Headless.Switch
  import DevelopmentWeb.Components.Headless.Tabs
  import DevelopmentWeb.Components.Headless.TagsInput
  import DevelopmentWeb.Components.Headless.ThemeIcon
  import DevelopmentWeb.Components.Headless.Toast
  import DevelopmentWeb.Components.Headless.Toggle
  import DevelopmentWeb.Components.Headless.ToggleGroup
  import DevelopmentWeb.Components.Headless.Toolbar
  import DevelopmentWeb.Components.Headless.Tooltip
  import DevelopmentWeb.Components.Headless.Tree
  import DevelopmentWeb.Components.Headless.VisuallyHidden

  alias DevelopmentWeb.Showcase.ExampleSource
  alias Phoenix.LiveView.JS

  def sections("collapsible"),
    do: [{"collapsible-hero", "Hero", "A panel controlled by a button."}]

  def sections("accordion"),
    do: [
      {"accordion-hero", "Hero",
       "A single-open FAQ accordion (one panel at a time) with three items, a height-transitioned panel, and a plus icon that rotates 45deg when the panel is open."},
      {"accordion-multiple", "Multiple",
       "Same FAQ accordion but with multiple panels allowed open at once (multiple), each panel animating its height open/closed and the trigger icon rotating when open."}
    ]

  def sections("action_icon"),
    do: [{"action_icon-hero", "Hero", "Icon-only edit and delete buttons, one disabled."}]

  def sections("alert_dialog"),
    do: [
      {"alert_dialog-hero", "Hero",
       "A destructive-action confirmation: a 'Discard draft' trigger opens a centered alert dialog with title, description, and Cancel / Discard buttons."},
      {"alert_dialog-detached-triggers-simple", "Detached Triggers Simple",
       "The same discard-draft confirmation; Base UI wires it via a detached trigger handle, ported here with our built-in trigger slot."},
      {"alert_dialog-detached-triggers-controlled", "Detached Triggers Controlled",
       "Base UI drives multiple detached triggers with per-trigger payloads and programmatic open; ported as a single controlled-style confirmation since our component renders one trigger/message."}
    ]

  def sections("anchor"),
    do: [{"anchor-hero", "Hero", "A themed inline link inside a sentence."}]

  def sections("autocomplete"),
    do: [
      {"autocomplete-hero", "Hero",
       "Basic free-text autocomplete: typing filters a tag list and shows a styled empty state when nothing matches."},
      {"autocomplete-grouped", "Grouped",
       "Options split into Type and Component groups, each with a sticky group label."},
      {"autocomplete-auto-highlight", "Auto Highlight",
       "Highlights the first match as you type so Enter selects it without arrowing down."},
      {"autocomplete-inline", "Inline",
       "Inline-completion style list with no empty state; the popup hides when there are no matches."},
      {"autocomplete-fuzzy-matching", "Fuzzy Matching",
       "Documentation search rendering a two-line title/description per item with a query-aware empty message."},
      {"autocomplete-limit", "Limit",
       "Caps visible results and uses the live status region to announce how many matches are hidden."},
      {"autocomplete-async", "Async",
       "Movie search whose status region shows a spinner/messages while results stream in; items show title and year."},
      {"autocomplete-command-palette", "Command Palette",
       "Spotlight-style palette with grouped suggestions and commands plus an Enter / Cmd+K footer."},
      {"autocomplete-grid", "Grid",
       "Emoji picker laying options out in a 5-column grid grouped by category."}
    ]

  def sections("avatar"),
    do: [
      {"avatar-hero", "Hero",
       "Two rounded avatars side by side: one loads a remote image with an \"LT\" fallback (600ms delay) and the other is a fallback-only avatar showing just the \"LT\" initials."}
    ]

  def sections("burger"),
    do: [
      {"burger-hero", "Hero",
       "A closed and an opened burger toggle; the three bars animate into an ✕ under data-opened."}
    ]

  def sections("checkbox"),
    do: [
      {"checkbox-hero", "Hero",
       "A single labeled checkbox, checked by default, showing a check icon in a square box and the label \"Enable notifications\"."}
    ]

  def sections("checkbox_group"),
    do: [
      {"checkbox_group-hero", "Hero",
       "A labelled \"Apples\" checkbox group (Fuji/Gala/Granny Smith) with Fuji checked by default; each item is a small square box that fills in and shows a check icon when checked."}
    ]

  def sections("chip"),
    do: [
      {"chip-hero", "Hero",
       "Multi-select filter chips (checkbox) and a single-select size row (radio); the checked look is pure CSS on :has(:checked)."}
    ]

  def sections("close_button"),
    do: [
      {"close_button-hero", "Hero",
       "A default close button (built-in ✕) and one with a custom icon, both with an accessible label."}
    ]

  def sections("code"),
    do: [
      {"code-hero", "Hero", "Inline code inside a sentence and a preformatted code block."}
    ]

  def sections("color_swatch"),
    do: [
      {"color_swatch-hero", "Hero",
       "Round and square swatches of different colors, one with a check overlay."}
    ]

  def sections("combobox"),
    do: [
      {"combobox-hero", "Hero",
       "A single-select fruit combobox with a clear button, a caret trigger to open the popup, an empty state, and a checkmark indicator on the selected option."},
      {"combobox-grouped", "Grouped",
       "A single-select produce combobox whose options are split into Fruits and Vegetables groups, each with a group label, plus clear/trigger buttons and an empty state."},
      {"combobox-multiple", "Multiple",
       "A multi-select programming-languages combobox rendering removable chips for each selection, with a checkmark indicator and empty state."},
      {"combobox-input-inside-popup", "Input Inside Popup",
       "A country picker styled like a select trigger where the filtering text input lives inside the opened popup above the list."},
      {"combobox-creatable", "Creatable",
       "A multi-select labels combobox that offers to create the typed query as a new label (creatable item) alongside existing matches, rendered as chips."},
      {"combobox-async-single", "Async Single",
       "A single-select people picker styled for async search results (rich two-line items with name, email, username and title), with clear/trigger buttons and an empty state."},
      {"combobox-async-multiple", "Async Multiple",
       "A multi-select reviewer picker styled for async search results with removable chips and rich two-line options showing name, email, username and title."}
    ]

  def sections("context_menu"),
    do: [
      {"context_menu-hero", "Hero",
       "Right-click a bordered box to open a context menu of flat items (Add to Library, Play Next, Favorite, ...) split by separators, with a scale/opacity open animation."},
      {"context_menu-submenu", "Submenu",
       "A context menu whose 'Add to Playlist' row opens a nested submenu of playlists with a caret icon, alongside the regular items and separators."}
    ]

  def sections("dialog"),
    do: [
      {"dialog-hero", "Hero",
       "Basic modal dialog with a trigger, backdrop, title, description and a Close button, including starting/ending enter-exit transitions."},
      {"dialog-nested", "Nested",
       "A dialog whose body contains a second dialog trigger, demonstrating the stacked nested-dialog offset/scale driven by the --nested-dialogs CSS var and data-nested-dialog-open dimming overlay."},
      {"dialog-uncontained", "Uncontained",
       "A full-width dialog using the viewport to grid-center an empty content panel with a detached top-right close (X) button outside the panel."},
      {"dialog-outside-scroll", "Outside Scroll",
       "A tall dialog whose long content overflows and scrolls the page/viewport container, with a corner close (X) button and a list of documentation sections plus related links."},
      {"dialog-inside-scroll", "Inside Scroll",
       "A dialog kept fully on screen with a fixed header/footer and an internally scrolling content region listing many documentation sections."},
      {"dialog-close-confirmation", "Close Confirmation",
       "A tweet-compose dialog containing a form/textarea; closing with unsaved text is intended to surface a discard confirmation alert dialog."},
      {"dialog-detached-triggers-simple", "Detached Triggers Simple",
       "The notifications dialog (Base UI's detached-trigger handle API has no equivalent here, so it is ported as a standard inline-trigger dialog)."},
      {"dialog-detached-triggers-controlled", "Detached Triggers Controlled",
       "A controlled dialog opened from a trigger (Base UI's multi-trigger handle/payload API has no equivalent here, so it is ported as a single standard dialog)."}
    ]

  def sections("drawer"),
    do: [
      {"drawer-hero", "Hero",
       "A right-side drawer that slides in from the edge and can be swiped to dismiss, with a backdrop and a Close button."},
      {"drawer-mobile-nav", "Mobile Nav",
       "A bottom mobile-menu drawer with a drag handle, a close (X) icon and a long scrollable list of navigation links you flick down to dismiss."},
      {"drawer-nested", "Nested",
       "A stack of independently focus-managed bottom drawers (Account, Security, Advanced) that nest and stack on top of one another."},
      {"drawer-non-modal", "Non-modal",
       "A right-side non-modal drawer that does not trap focus and ignores outside clicks; dismiss via the Close button or swipe."},
      {"drawer-position", "Position",
       "A bottom-positioned notifications drawer (bottom sheet) with a drag handle, demonstrating side placement."},
      {"drawer-snap-points", "Snap Points",
       "A bottom sheet with snap points you can drag between a compact peek and a near full-height view, scrolling a long list."},
      {"drawer-swipe-area", "Swipe Area",
       "A non-modal right drawer opened by swiping from a dashed edge swipe-area (\"Swipe here\") rather than a button."},
      {"drawer-uncontained", "Uncontained",
       "An iOS-style action sheet: an uncontained bottom drawer of separate action cards (Unfollow, Mute, etc.) plus a Block User card."}
    ]

  def sections("empty_state"),
    do: [
      {"empty_state-hero", "Hero",
       "A centered 'no results' empty state: a search icon in a soft circular indicator, a title and a muted description."},
      {"empty_state-actions", "With actions",
       "A left-aligned empty state for a fresh project — indicator, title, description and an actions row with a primary and a subtle button."}
    ]

  def sections("field"),
    do: [
      {"field-hero", "Hero",
       "A required text field with a bold label, a value-missing error message, and a description line, wired for accessibility."}
    ]

  def sections("fieldset"),
    do: [
      {"fieldset-hero", "Hero",
       "A 'Billing details' fieldset with a bold underlined legend grouping two labeled text inputs (Company and Tax ID), each built from our field component."}
    ]

  def sections("highlight"),
    do: [
      {"highlight-hero", "Hero",
       "Highlight one or more query terms inside a sentence (case-insensitive)."}
    ]

  def sections("mark"),
    do: [{"mark-hero", "Hero", "A highlighted run of text inside a sentence."}]

  def sections("alpha_slider"),
    do: [
      {"alpha_slider-hero", "Hero",
       "Pick opacity over a checkerboard + color gradient (reuses Slider)."}
    ]

  def sections("hue_slider"),
    do: [{"hue_slider-hero", "Hero", "Pick a hue on a rainbow track (reuses the Slider engine)."}]

  def sections("number_formatter"),
    do: [
      {"number_formatter-hero", "Hero", "Currency, plain, percentage and space-grouped numbers."}
    ]

  def sections("marquee"),
    do: [
      {"marquee-hero", "Hero",
       "A row of words scrolling continuously; pure CSS, pauses on hover."}
    ]

  def sections("menu"),
    do: [
      {"menu-hero", "Hero",
       "Basic Song menu with items and separators (Add to Library, Play Next, Favorite, Share)."},
      {"menu-arrow", "Arrow",
       "Same Song menu; Base UI Arrow part has no equivalent in our component so it is omitted, side_offset kept."},
      {"menu-checkbox-items", "Checkbox Items",
       "Workspace menu with three toggleable checkbox items (Minimap, Search, Sidebar) and check-icon indicators."},
      {"menu-radio-items", "Radio Items",
       "Sort menu with a single-select radio group (Date, Name, Type) and check-icon indicators."},
      {"menu-group-labels", "Group Labels",
       "View menu combining a labeled radio group (Sort) and a labeled checkbox group (Workspace) separated by a divider."},
      {"menu-open-on-hover", "Open On Hover",
       "Add to playlist menu that opens on trigger hover via open_on_hover."},
      {"menu-submenu", "Submenu",
       "Song menu containing a nested Add to Playlist submenu, with popup-open highlight styling."},
      {"menu-detached-triggers-simple", "Detached Triggers Simple",
       "Ellipsis icon trigger opening a project-actions menu (Rename, Duplicate, Archive, Delete); Base UI detached handle collapsed to a normal trigger."},
      {"menu-detached-triggers-full", "Detached Triggers Full",
       "Library menu with two labeled groups separated by a divider; the Base UI multi-trigger handle/Viewport morphing is collapsed to a single menu."},
      {"menu-detached-triggers-controlled", "Detached Triggers Controlled",
       "Playback menu (Play, Add to queue); the Base UI controlled multi-trigger handle is collapsed to a single menu."}
    ]

  def sections("menubar"),
    do: [
      {"menubar-hero", "Hero",
       "A desktop-style menubar (File / Edit / View / Help) with neutral-950 hard-shadow popups, highlighted items, an Export/Layout submenu trigger with caret, separators, and a disabled Help menu."}
    ]

  def sections("meter"),
    do: [
      {"meter-hero", "Hero",
       "A storage-used meter at 24% with a label, a right-aligned percentage value readout, and a filled track indicator that animates its width."}
    ]

  def sections("navigation_menu"),
    do: [
      {"navigation_menu-hero", "Hero",
       "A site navbar with Overview and Handbook dropdown triggers (rich link cards in a shared morphing popup) plus a plain GitHub link."},
      {"navigation_menu-nested", "Nested",
       "An Overview dropdown whose panel embeds a grid of link cards alongside a Handbook section, demonstrating richer nested content inside one panel."},
      {"navigation_menu-nested-inline", "Nested Inline",
       "A Product mega-menu with an audience sidebar (Developers/Design Systems/Engineering Leads/Startups) and detail links, plus a Learn dropdown and Releases/GitHub links."}
    ]

  def sections("number_field"),
    do: [
      {"number_field-hero", "Hero",
       "A number field with an Amount scrub-area label (ew-resize, drag-to-change with a custom grow cursor) and a minus/plus stepper group around a tabular-nums input, with hover/active/disabled stepper states."}
    ]

  def sections("otp_field"),
    do: [
      {"otp_field-hero", "Hero",
       "A basic 6-character verification code field with a label and helper text."},
      {"otp_field-alphanumeric", "Alphanumeric",
       "A 6-slot recovery code field that accepts both letters and numbers (validation_type alphanumeric)."},
      {"otp_field-password", "Password",
       "A masked access code field using mask to obscure entered characters on shared screens."},
      {"otp_field-focused-placeholder", "Focused Placeholder",
       "Per-slot placeholder dots that stay visible until the active slot is focused."},
      {"otp_field-grouped", "Grouped",
       "Two groups of three slots split by a horizontal separator line (group + separator)."}
    ]

  def sections("pill"),
    do: [
      {"pill-hero", "Hero",
       "A read-only pill and removable tags, each with an accessible remove button."}
    ]

  def sections("popover"),
    do: [
      {"popover-hero", "Hero",
       "A Notifications trigger button opening an anchored popup with a title and description, with a subtle scale/opacity enter animation."},
      {"popover-open-on-hover", "Open On Hover",
       "Same Notifications popover but opened on trigger hover instead of click."},
      {"popover-detached-triggers-simple", "Detached Triggers Simple",
       "Base UI uses a detached handle so a trigger outside the Root opens it; ported as a standard single-trigger Notifications popover."},
      {"popover-detached-triggers-full", "Detached Triggers Full",
       "Base UI shares one morphing popup across Notifications/Activity/Profile triggers via a handle+payload; ported as a rich Profile popover (avatar, plan, links) since our component positions and renders one popup internally."},
      {"popover-detached-triggers-controlled", "Detached Triggers Controlled",
       "Base UI controls a shared handle's open state and active trigger programmatically; ported as a standard controlled-style Notifications popover trigger."}
    ]

  def sections("preview_card"),
    do: [
      {"preview_card-hero", "Hero",
       "A link in a paragraph reveals a preview card with an image and a short description of typography on hover/focus."},
      {"preview_card-detached-triggers-simple", "Detached Triggers Simple",
       "The detached-trigger pattern (single shared popup), ported as one preview card whose typography link reveals an image + caption preview."},
      {"preview_card-detached-triggers-controlled", "Detached Triggers Controlled",
       "Multiple linked terms (typography, design, art) each open their own preview card; the programmatic open button is shown disabled since our component has no shared controlled handle."},
      {"preview_card-detached-triggers-full", "Detached Triggers Full",
       "Multiple linked terms each reveal their own preview card; the morphing shared Viewport is omitted since our component renders one popup per trigger."}
    ]

  def sections("progress"),
    do: [
      {"progress-hero", "Hero",
       "A labeled determinate progress bar with a right-aligned percentage readout and an animated fill track."}
    ]

  def sections("radio"),
    do: [
      {"radio-hero", "Hero",
       "A radio group (Best apple) with three options — Fuji, Gala, Granny Smith — sharing a name; the checked option fills its circle with a center dot via the indicator."}
    ]

  def sections("scroll_area"),
    do: [
      {"scroll_area-hero", "Hero",
       "A vertical scroll area with two paragraphs of text and a custom fading scrollbar that appears on hover or while scrolling."},
      {"scroll_area-both", "Both",
       "A scroll area that scrolls in both axes over a 10x10 grid of numbered cells, with vertical and horizontal scrollbars and a corner."},
      {"scroll_area-scroll-fade", "Scroll Fade",
       "A vertical scroll area whose top and bottom edges fade out via a mask driven by the --scroll-area-overflow-y-start/end CSS vars."}
    ]

  def sections("select"),
    do: [
      {"select-hero", "Hero",
       "A basic single-select of apple varieties with a label, caret-up-down trigger icon, and a check ItemIndicator on the selected option."},
      {"select-grouped", "Grouped",
       "A produce select whose options are split into Fruits and Vegetables groups, each with a muted group label."},
      {"select-multiple", "Multiple",
       "A multi-select of programming languages (pre-selected JavaScript + TypeScript) that stays open and shows a check next to each chosen item."},
      {"select-object-values", "Object Values",
       "A shipping-method select where each option renders a two-line label (name plus duration and price), pre-selecting Standard."}
    ]

  def sections("separator"),
    do: [
      {"separator-hero", "Hero",
       "A horizontal navigation bar whose primary links are divided from the auth links (Log in / Sign up) by a thin vertical separator."}
    ]

  def sections("slider"),
    do: [
      {"slider-hero", "Hero",
       "A basic single-thumb volume slider with a thin track, filled indicator and a square draggable thumb."},
      {"slider-range-slider", "Range Slider",
       "A two-thumb range slider (minimum and maximum values) sharing one filled interval indicator."},
      {"slider-edge-alignment", "Edge Alignment",
       "A single-thumb slider whose thumb is edge-aligned so it stays within the track bounds at the extremes."},
      {"slider-vertical", "Vertical",
       "A single-thumb slider laid out vertically, with the track running top-to-bottom."}
    ]

  def sections("color_picker"),
    do: [
      {"color_picker-hero", "Hero", "A saturation/value area with a hue slider and live preview."}
    ]

  def sections("rolling_number"),
    do: [{"rolling_number-hero", "Hero", "Numbers that roll up from zero on mount (ease-out)."}]

  def sections("scroller"),
    do: [
      {"scroller-hero", "Hero", "A row of cards with prev/next buttons that disable at the ends."}
    ]

  def sections("semi_circle_progress"),
    do: [{"semi_circle_progress-hero", "Hero", "A half-circle gauge with a centered readout."}]

  def sections("splitter"),
    do: [{"splitter-hero", "Hero", "Two panes with a draggable divider; keyboard-resizable too."}]

  def sections("spoiler"),
    do: [
      {"spoiler-hero", "Hero",
       "A paragraph clamped to a few lines with a Show more / Show less toggle (client-side)."}
    ]

  def sections("switch"),
    do: [
      {"switch-hero", "Hero",
       "A bordered on/off switch (default checked) with a sliding thumb that inverts colors on toggle, plus a 'Notifications' label."}
    ]

  def sections("tabs"),
    do: [
      {"tabs-hero", "Hero",
       "A three-tab workspace switcher (Overview / Projects / Account) with an animated bordered indicator that slides under the active tab and a bordered panel area below."}
    ]

  def sections("tags_input"),
    do: [
      {"tags_input-hero", "Hero",
       "A tags/keywords control: removable tokens and a growing input; click anywhere to focus it."}
    ]

  def sections("theme_icon"),
    do: [{"theme_icon-hero", "Hero", "Icons inside colored, rounded containers."}]

  def sections("toast"),
    do: [
      {"toast-hero", "Hero",
       "A Create toast button spawns stacking notifications anchored bottom-right; the stack collapses with newest in front and expands into a full list on hover/focus, each with a title, description and dismiss button."},
      {"toast-position", "Position",
       "Same stacking toast pattern but anchored top-center with an upward swipe direction, showing the viewport position can be relocated while keeping the collapse/expand stacking behaviour."},
      {"toast-anchored", "Anchored",
       "Two managers side by side: a Stacked toast button feeds the bottom-right collapsing stack, demonstrating the stacked viewport (the anchored-to-trigger Positioner/Arrow + tooltip copy variant is omitted since our component positions internally and has no Arrow/Positioner part)."}
    ]

  def sections("toggle"),
    do: [
      {"toggle-hero", "Hero",
       "A single icon toggle button (a favorite/like heart) that swaps an outline heart for a filled heart when pressed, with hover/active/focus-visible styling."}
    ]

  def sections("toggle_group"),
    do: [
      {"toggle_group-hero", "Hero",
       "A single-select toggle group of three text-alignment buttons (left/center/right) with left pressed by default."},
      {"toggle_group-multiple", "Multiple",
       "A multi-select toggle group of text-formatting buttons (bold/italic/underline) with bold and italic pressed by default."}
    ]

  def sections("toolbar"),
    do: [
      {"toolbar-hero", "Hero",
       "A horizontal editing toolbar: an alignment toggle group, a numerical-format group ($ / %), a font-family select trigger, and a right-aligned 'Edited 51m ago' link, separated by vertical dividers."}
    ]

  def sections("tooltip"),
    do: [
      {"tooltip-hero", "Hero",
       "A toolbar of three icon buttons (Bold, Italic, Underline), each revealing its own labeled tooltip on hover or focus."},
      {"tooltip-detached-triggers-simple", "Detached Triggers Simple",
       "A single Delete icon button whose tooltip popup is defined separately from the trigger."},
      {"tooltip-detached-triggers-controlled", "Detached Triggers Controlled",
       "A group of icon-button triggers (headphones, stopwatch, trash) plus a button, each showing a Controlled tooltip; the shared-handle/programmatic-open behavior is approximated with per-trigger tooltips."},
      {"tooltip-detached-triggers-full", "Detached Triggers Full",
       "A group of icon-button triggers each carrying its own descriptive payload text as the tooltip content (audio preview, set a timer, delete warning)."}
    ]

  def sections("tree"),
    do: [
      {"tree-hero", "Hero",
       "Base UI ships no Tree, so this is the one it would: a bordered file explorer whose folders carry a caret that rotates a quarter turn when open, rows that highlight on hover and invert to solid on select, and files/folders drawn with outline icons."}
    ]

  def sections("visually_hidden"),
    do: [{"visually_hidden-hero", "Hero", "A button whose text label is screen-reader-only."}]

  def sections(_), do: []

  def has?(component), do: sections(component) != []

  def source(id), do: ExampleSource.code(__MODULE__, id)

  def example(%{section: "collapsible-hero"} = assigns) do
    ~H"""
    <.collapsible
      id="recovery-keys"
      class="w-48 text-neutral-950 dark:text-white"
      item_class="flex min-h-36 flex-col justify-center"
      trigger_class="group flex h-8 items-center justify-between gap-2 rounded-none border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 pl-3 pr-2 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400"
      panel_class="flex h-[var(--accordion-panel-height)] flex-col justify-end overflow-hidden text-sm transition-[height] duration-150 ease-[ease-out] [&[hidden]:not([hidden='until-found'])]:hidden data-[ending-style]:h-0 data-[starting-style]:h-0"
    >
      <:trigger>
        Recovery keys
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="currentColor"
          class="block transition-transform duration-100 ease-[ease-out] group-data-[panel-open]:rotate-90"
        >
          <path d="M6 12V4l4.5 4z" />
        </svg>
      </:trigger>
      <div class="flex flex-col gap-2 px-3.5 py-2">
        <div>alien-bean-pasta</div>
        <div>wild-irish-burrito</div>
        <div>horse-battery-staple</div>
      </div>
    </.collapsible>
    """
  end

  def example(%{section: "accordion-hero"} = assigns) do
    ~H"""
    <.accordion
      id="baseui-accordion-hero"
      collapsible
      heading_level={3}
      class="flex w-full max-w-80 flex-col border border-neutral-950 text-neutral-950 dark:border-white dark:text-white"
    >
      <:trigger_icon>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          stroke-linecap="square"
          stroke-linejoin="round"
          class="block shrink-0 transition-transform duration-100 ease-[ease-out] group-data-[panel-open]:rotate-45"
        >
          <path d="M1.5 8h13M8 14.5v-13" />
        </svg>
      </:trigger_icon>
      <:item
        title="What is Base UI?"
        trigger_class="group flex w-full items-center justify-between gap-4 bg-transparent px-3 py-2 text-left text-sm font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 focus-visible:relative focus-visible:z-1 focus-visible:outline-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800"
        content_class="h-[var(--accordion-panel-height)] overflow-hidden text-sm transition-[height] duration-150 ease-[ease-out] data-[ending-style]:h-0 data-[starting-style]:h-0"
      >
        <div class="px-3 py-2">
          Base UI is a library of high-quality unstyled React components for design systems and web apps.
        </div>
      </:item>
      <:item
        title="How do I get started?"
        class="border-t border-neutral-950 dark:border-white"
        trigger_class="group flex w-full items-center justify-between gap-4 bg-transparent px-3 py-2 text-left text-sm font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 focus-visible:relative focus-visible:z-1 focus-visible:outline-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800"
        content_class="h-[var(--accordion-panel-height)] overflow-hidden text-sm transition-[height] duration-150 ease-[ease-out] data-[ending-style]:h-0 data-[starting-style]:h-0"
      >
        <div class="px-3 py-2">
          Head to the “Quick start” guide in the docs. If you’ve used unstyled libraries before, you’ll feel at home.
        </div>
      </:item>
      <:item
        title="Can I use it for my project?"
        class="border-t border-neutral-950 dark:border-white"
        trigger_class="group flex w-full items-center justify-between gap-4 bg-transparent px-3 py-2 text-left text-sm font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 focus-visible:relative focus-visible:z-1 focus-visible:outline-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800"
        content_class="h-[var(--accordion-panel-height)] overflow-hidden text-sm transition-[height] duration-150 ease-[ease-out] data-[ending-style]:h-0 data-[starting-style]:h-0"
      >
        <div class="px-3 py-2">Of course! Base UI is free and open source.</div>
      </:item>
    </.accordion>
    """
  end

  def example(%{section: "accordion-multiple"} = assigns) do
    ~H"""
    <.accordion
      id="baseui-accordion-multiple"
      multiple
      collapsible
      heading_level={3}
      class="flex w-full max-w-80 flex-col border border-neutral-950 text-neutral-950 dark:border-white dark:text-white"
    >
      <:trigger_icon>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          stroke-linecap="square"
          stroke-linejoin="round"
          class="block shrink-0 transition-transform duration-100 ease-[ease-out] group-data-[panel-open]:rotate-45"
        >
          <path d="M1.5 8h13M8 14.5v-13" />
        </svg>
      </:trigger_icon>
      <:item
        title="What is Base UI?"
        trigger_class="group flex w-full items-center justify-between gap-4 bg-transparent px-3 py-2 text-left text-sm font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 focus-visible:relative focus-visible:z-1 focus-visible:outline-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800"
        content_class="h-[var(--accordion-panel-height)] overflow-hidden text-sm transition-[height] duration-150 ease-[ease-out] data-[ending-style]:h-0 data-[starting-style]:h-0"
      >
        <div class="px-3 py-2">
          Base UI is a library of high-quality unstyled React components for design systems and web apps.
        </div>
      </:item>
      <:item
        title="How do I get started?"
        class="border-t border-neutral-950 dark:border-white"
        trigger_class="group flex w-full items-center justify-between gap-4 bg-transparent px-3 py-2 text-left text-sm font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 focus-visible:relative focus-visible:z-1 focus-visible:outline-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800"
        content_class="h-[var(--accordion-panel-height)] overflow-hidden text-sm transition-[height] duration-150 ease-[ease-out] data-[ending-style]:h-0 data-[starting-style]:h-0"
      >
        <div class="px-3 py-2">
          Head to the “Quick start” guide in the docs. If you’ve used unstyled libraries before, you’ll feel at home.
        </div>
      </:item>
      <:item
        title="Can I use it for my project?"
        class="border-t border-neutral-950 dark:border-white"
        trigger_class="group flex w-full items-center justify-between gap-4 bg-transparent px-3 py-2 text-left text-sm font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 focus-visible:relative focus-visible:z-1 focus-visible:outline-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800"
        content_class="h-[var(--accordion-panel-height)] overflow-hidden text-sm transition-[height] duration-150 ease-[ease-out] data-[ending-style]:h-0 data-[starting-style]:h-0"
      >
        <div class="px-3 py-2">Of course! Base UI is free and open source.</div>
      </:item>
    </.accordion>
    """
  end

  def example(%{section: "alert_dialog-hero"} = assigns) do
    ~H"""
    <.alert_dialog
      id="baseui-alert_dialog-hero"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-red-700 dark:text-red-400 select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400"
      backdrop_class="fixed inset-0 min-h-dvh bg-black opacity-20 transition-opacity duration-150 data-[closed]:opacity-0 data-[starting-style]:opacity-0 dark:opacity-50 supports-[-webkit-touch-callout:none]:absolute"
      popup_class="fixed top-1/2 left-1/2 -mt-8 flex w-96 max-w-[calc(100vw-3rem)] -translate-x-1/2 -translate-y-1/2 flex-col gap-4 bg-white dark:bg-neutral-950 p-4 text-neutral-950 dark:text-white border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[scale,opacity] duration-100 ease-out data-[closed]:scale-[0.98] data-[closed]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
      title_class="text-base font-bold"
      description_class="text-sm text-neutral-600 dark:text-neutral-400"
      actions_class="flex justify-end gap-3"
    >
      <:trigger>Discard draft</:trigger>
      <:title>Discard draft?</:title>
      <:description>You can’t undo this action.</:description>
      <:actions>
        <button
          type="button"
          data-close
          class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400"
        >
          Cancel
        </button>
        <button
          type="button"
          data-close
          class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-red-700 dark:text-red-400 select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400"
        >
          Discard
        </button>
      </:actions>
    </.alert_dialog>
    """
  end

  def example(%{section: "alert_dialog-detached-triggers-simple"} = assigns) do
    ~H"""
    <.alert_dialog
      id="baseui-alert_dialog-detached-triggers-simple"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-red-700 dark:text-red-400 select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400"
      backdrop_class="fixed inset-0 min-h-dvh bg-black opacity-20 transition-opacity duration-150 data-[closed]:opacity-0 data-[starting-style]:opacity-0 dark:opacity-50 supports-[-webkit-touch-callout:none]:absolute"
      popup_class="fixed top-1/2 left-1/2 -mt-8 flex w-96 max-w-[calc(100vw-3rem)] -translate-x-1/2 -translate-y-1/2 flex-col gap-4 bg-white dark:bg-neutral-950 p-4 text-neutral-950 dark:text-white border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[scale,opacity] duration-100 ease-out data-[closed]:scale-[0.98] data-[closed]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
      title_class="text-base font-bold"
      description_class="text-sm text-neutral-600 dark:text-neutral-400"
      actions_class="flex justify-end gap-3"
    >
      <:trigger>Discard draft</:trigger>
      <:title>Discard draft?</:title>
      <:description>This action cannot be undone.</:description>
      <:actions>
        <button
          type="button"
          data-close
          class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400"
        >
          Cancel
        </button>
        <button
          type="button"
          data-close
          class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-red-700 dark:text-red-400 select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400"
        >
          Discard
        </button>
      </:actions>
    </.alert_dialog>
    """
  end

  def example(%{section: "alert_dialog-detached-triggers-controlled"} = assigns) do
    ~H"""
    <.alert_dialog
      id="baseui-alert_dialog-detached-triggers-controlled"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-red-700 dark:text-red-400 select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400"
      backdrop_class="fixed inset-0 min-h-dvh bg-black opacity-20 transition-opacity duration-150 data-[closed]:opacity-0 data-[starting-style]:opacity-0 dark:opacity-50 supports-[-webkit-touch-callout:none]:absolute"
      popup_class="fixed top-1/2 left-1/2 -mt-8 flex w-96 max-w-[calc(100vw-3rem)] -translate-x-1/2 -translate-y-1/2 flex-col gap-4 bg-white dark:bg-neutral-950 p-4 text-neutral-950 dark:text-white border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[scale,opacity] duration-100 ease-out data-[closed]:scale-[0.98] data-[closed]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
      title_class="text-base font-bold"
      description_class="text-sm text-neutral-600 dark:text-neutral-400"
      actions_class="flex justify-end gap-3"
    >
      <:trigger>Discard</:trigger>
      <:title>Discard draft?</:title>
      <:description>This action cannot be undone.</:description>
      <:actions>
        <button
          type="button"
          data-close
          class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400"
        >
          Cancel
        </button>
        <button
          type="button"
          data-close
          class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-red-700 dark:text-red-400 select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400"
        >
          Confirm
        </button>
      </:actions>
    </.alert_dialog>
    """
  end

  def example(%{section: "autocomplete-hero"} = assigns) do
    ~H"""
    <label class="flex flex-col gap-1 text-sm font-bold text-neutral-950 dark:text-white">
      Search tags
      <.autocomplete
        id="baseui-autocomplete-hero"
        placeholder="e.g. feature"
        input_class="h-8 w-[16rem] border border-neutral-950 bg-white dark:bg-neutral-950 px-2 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 placeholder:opacity-100 placeholder:text-neutral-500 placeholder:[-webkit-text-fill-color:var(--color-neutral-500)] dark:placeholder:text-neutral-400 dark:placeholder:[-webkit-text-fill-color:var(--color-neutral-400)] focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:text-white"
        popup_class="top-full mt-1 w-[16rem] max-w-[16rem] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none outline-0 overflow-y-auto scroll-py-[0.25rem] py-1 overscroll-contain max-h-[22.5rem]"
      >
        <:option
          :for={tag <- baseui_autocomplete_tags()}
          value={tag.value}
          class="flex cursor-default items-center gap-2 py-2 pr-2 pl-2 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-0 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          {tag.value}
        </:option>
        <:empty>
          <div class="py-4 pr-4 pl-2 text-sm leading-4 text-neutral-500 dark:text-neutral-400">
            No tags found.
          </div>
        </:empty>
      </.autocomplete>
    </label>
    """
  end

  def example(%{section: "autocomplete-grouped"} = assigns) do
    ~H"""
    <label class="flex flex-col gap-1 text-sm font-bold text-neutral-950 dark:text-white">
      Select a tag
      <.autocomplete
        id="baseui-autocomplete-grouped"
        placeholder="e.g. feature"
        input_class="h-8 w-[16rem] border border-neutral-950 bg-white dark:bg-neutral-950 px-2 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 placeholder:text-neutral-500 dark:placeholder:text-neutral-400 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:text-white"
        popup_class="top-full mt-1 w-[16rem] max-w-[16rem] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none outline-0 overflow-y-auto py-1 scroll-py-1 overscroll-contain max-h-[22.5rem]"
      >
        <:option
          :for={tag <- baseui_autocomplete_tags()}
          value={tag.value}
          group={tag.group}
          group_class="block pb-2 last:pb-0"
          group_label_class="p-2 text-sm leading-4 text-neutral-500 select-none dark:text-neutral-400"
          class="flex cursor-default items-center gap-2 py-2 pr-2 pl-2 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-0 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          {tag.value}
        </:option>
        <:empty>
          <div class="py-4 pr-4 pl-2 text-sm leading-4 text-neutral-500 dark:text-neutral-400">
            No tags found.
          </div>
        </:empty>
      </.autocomplete>
    </label>
    """
  end

  def example(%{section: "autocomplete-auto-highlight"} = assigns) do
    ~H"""
    <label class="flex flex-col gap-1 text-sm font-bold text-neutral-950 dark:text-white">
      Auto highlight on type
      <.autocomplete
        id="baseui-autocomplete-auto-highlight"
        placeholder="e.g. feature"
        auto_highlight
        input_class="h-8 w-[16rem] border border-neutral-950 bg-white dark:bg-neutral-950 px-2 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 placeholder:text-neutral-500 dark:placeholder:text-neutral-400 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:text-white"
        popup_class="top-full mt-1 w-[16rem] max-w-[16rem] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none outline-0 overflow-y-auto scroll-py-[0.25rem] py-1 overscroll-contain max-h-[22.5rem]"
      >
        <:option
          :for={tag <- baseui_autocomplete_tags()}
          value={tag.value}
          class="flex cursor-default items-center gap-2 py-2 pr-2 pl-2 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-0 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          {tag.value}
        </:option>
        <:empty>
          <div class="py-4 pr-4 pl-2 text-sm leading-4 text-neutral-500 dark:text-neutral-400">
            No tags found.
          </div>
        </:empty>
      </.autocomplete>
    </label>
    """
  end

  def example(%{section: "autocomplete-inline"} = assigns) do
    ~H"""
    <label class="flex flex-col gap-1 text-sm font-bold text-neutral-950 dark:text-white">
      Search tags
      <.autocomplete
        id="baseui-autocomplete-inline"
        placeholder="e.g. feature"
        auto_highlight
        input_class="h-8 w-[16rem] border border-neutral-950 bg-white dark:bg-neutral-950 px-2 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 placeholder:text-neutral-500 dark:placeholder:text-neutral-400 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:text-white"
        popup_class="top-full mt-1 w-[16rem] max-w-[16rem] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none outline-0 overflow-y-auto scroll-py-[0.25rem] py-1 overscroll-contain max-h-[22.5rem]"
      >
        <:option
          :for={tag <- baseui_autocomplete_tags()}
          value={tag.value}
          class="flex cursor-default items-center gap-2 py-2 pr-2 pl-2 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-0 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          {tag.value}
        </:option>
      </.autocomplete>
    </label>
    """
  end

  def example(%{section: "autocomplete-fuzzy-matching"} = assigns) do
    ~H"""
    <label class="flex flex-col gap-1 text-sm font-bold text-neutral-950 dark:text-white">
      Fuzzy search documentation
      <.autocomplete
        id="baseui-autocomplete-fuzzy-matching"
        placeholder="e.g. React"
        input_class="h-8 w-[16rem] border border-neutral-950 bg-white dark:bg-neutral-950 px-2 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 placeholder:text-neutral-500 dark:placeholder:text-neutral-400 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:text-white"
        popup_class="top-full mt-1 w-[16rem] max-w-[16rem] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none flex max-h-[28rem] flex-col overflow-y-auto overscroll-contain py-1 scroll-pt-1 scroll-pb-1"
      >
        <:option
          :for={doc <- baseui_autocomplete_docs()}
          value={doc.title}
          class="flex cursor-default py-3 pr-2 pl-2 text-sm leading-6 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-0 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-100 dark:data-[highlighted]:before:bg-neutral-800"
        >
          <span class="flex w-full flex-col gap-1">
            <span class="flex items-center justify-between gap-3">
              <span class="flex-1 font-bold leading-5">{doc.title}</span>
            </span>
            <span class="text-sm text-neutral-500 dark:text-neutral-400">{doc.description}</span>
          </span>
        </:option>
        <:empty>
          <div class="py-3 pr-4 pl-2 text-sm leading-4 text-neutral-500 dark:text-neutral-400">
            No results found.
          </div>
        </:empty>
      </.autocomplete>
    </label>
    """
  end

  def example(%{section: "autocomplete-limit"} = assigns) do
    ~H"""
    <label class="flex flex-col gap-1 text-sm font-bold text-neutral-950 dark:text-white">
      Limit results to 8
      <.autocomplete
        id="baseui-autocomplete-limit"
        placeholder="e.g. component"
        input_class="h-8 w-[16rem] border border-neutral-950 bg-white dark:bg-neutral-950 px-2 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 placeholder:text-neutral-500 dark:placeholder:text-neutral-400 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:text-white"
        popup_class="top-full mt-1 w-[16rem] max-h-[22.5rem] max-w-[16rem] overflow-y-auto scroll-pt-1 scroll-pb-1 overscroll-contain border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
        status_class="py-2 pr-4 pl-2 text-sm text-neutral-500 dark:text-neutral-400"
      >
        <:option
          :for={tag <- baseui_autocomplete_limit_tags()}
          value={tag.value}
          class="flex cursor-default py-2 pr-2 pl-2 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-0 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          {tag.value}
        </:option>
        <:empty>
          <div class="py-2 pr-4 pl-2 text-sm leading-4 text-neutral-500 dark:text-neutral-400">
            No results found.
          </div>
        </:empty>
      </.autocomplete>
    </label>
    """
  end

  def example(%{section: "autocomplete-async"} = assigns) do
    ~H"""
    <label class="flex flex-col gap-1 text-sm font-bold text-neutral-950 dark:text-white">
      Search movies by name or year
      <.autocomplete
        id="baseui-autocomplete-async"
        placeholder="e.g. Pulp Fiction or 1994"
        input_class="h-8 w-[16rem] border border-neutral-950 bg-white dark:bg-neutral-950 px-2 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 placeholder:text-neutral-500 dark:placeholder:text-neutral-400 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:text-white"
        popup_class="top-full mt-1 w-[16rem] max-w-[16rem] max-h-[22.5rem] overflow-y-auto overscroll-contain py-1 scroll-pt-1 scroll-pb-1 border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
        status_class="flex items-center gap-2 py-1 pr-8 pl-2 text-sm text-neutral-500 dark:text-neutral-400"
      >
        <:option
          :for={movie <- baseui_autocomplete_movies()}
          value={movie.title}
          class="group flex cursor-default py-2 pr-2 pl-2 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-0 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          <span class="flex w-full flex-col gap-1">
            <span class="font-bold leading-5">{movie.title}</span>
            <span class="text-sm leading-4 text-neutral-500 dark:text-neutral-400 group-data-[highlighted]:text-neutral-300 dark:group-data-[highlighted]:text-neutral-500">
              {movie.year}
            </span>
          </span>
        </:option>
        <:empty>
          <div class="flex items-center gap-2 py-1 pr-8 pl-2 text-sm text-neutral-500 dark:text-neutral-400">
            No movies found in the Top 100 IMDb movies.
          </div>
        </:empty>
      </.autocomplete>
    </label>
    """
  end

  def example(%{section: "autocomplete-command-palette"} = assigns) do
    ~H"""
    <div class="relative flex max-h-[36rem] w-full max-w-md flex-col border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none">
      <.autocomplete
        id="baseui-autocomplete-command-palette"
        placeholder="Search for apps and commands…"
        auto_highlight
        inline
        class="block"
        input_class="relative z-1 h-10 w-full border-0 bg-white px-3 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 placeholder:text-neutral-500 focus:outline-2 focus:outline-solid focus:outline-neutral-950 dark:focus:outline-white dark:bg-neutral-950 dark:text-white dark:placeholder:text-neutral-400"
        popup_class="static mt-0 w-full max-h-[24rem] overflow-y-auto overscroll-contain border-0 border-t border-neutral-950 bg-transparent shadow-none py-1 dark:border-t-white"
      >
        <:option
          :for={item <- baseui_autocomplete_palette_suggestions()}
          value={item.label}
          group="Suggestions"
          group_class="not-last:mb-1"
          group_label_class="flex min-h-8 items-center pr-6 pl-3 text-sm leading-none font-normal text-neutral-500 select-none outline-none dark:text-neutral-400"
          class="group grid min-h-8 cursor-default grid-cols-[minmax(0,1fr)_auto] items-center gap-2 px-6 text-sm font-normal leading-[1.25] outline-none select-none data-[highlighted]:bg-neutral-200 dark:data-[highlighted]:bg-neutral-700"
        >
          <span class="min-w-0 truncate font-normal">{item.label}</span>
          <span class="shrink-0 whitespace-nowrap text-sm text-neutral-500 group-data-[highlighted]:text-neutral-700 dark:text-neutral-400 dark:group-data-[highlighted]:text-neutral-300">
            Application
          </span>
        </:option>
        <:option
          :for={item <- baseui_autocomplete_palette_commands()}
          value={item.label}
          group="Commands"
          group_class="not-last:mb-1"
          group_label_class="flex min-h-8 items-center pr-6 pl-3 text-sm leading-none font-normal text-neutral-500 select-none outline-none dark:text-neutral-400"
          class="group grid min-h-8 cursor-default grid-cols-[minmax(0,1fr)_auto] items-center gap-2 px-6 text-sm font-normal leading-[1.25] outline-none select-none data-[highlighted]:bg-neutral-200 dark:data-[highlighted]:bg-neutral-700"
        >
          <span class="min-w-0 truncate font-normal">{item.label}</span>
          <span class="shrink-0 whitespace-nowrap text-sm text-neutral-500 group-data-[highlighted]:text-neutral-700 dark:text-neutral-400 dark:group-data-[highlighted]:text-neutral-300">
            Command
          </span>
        </:option>
        <:empty>
          <div class="flex min-h-32 items-center justify-start py-4 pr-4 pl-2 text-sm leading-4 text-neutral-500 dark:text-neutral-400">
            No results found.
          </div>
        </:empty>
      </.autocomplete>
      <div class="flex items-center justify-between border-t border-neutral-950 bg-white px-3 py-2.5 text-xs text-neutral-600 dark:border-white dark:bg-neutral-950 dark:text-neutral-400">
        <div class="flex items-center gap-1">
          <span>Activate</span>
          <kbd class="inline-flex h-5 min-w-5 items-center justify-center border border-neutral-400 bg-neutral-100 px-1 font-mono text-[0.625rem] leading-none font-normal text-neutral-600 dark:border-neutral-600 dark:bg-neutral-900 dark:text-neutral-400">
            Enter
          </kbd>
        </div>
        <div class="flex items-center gap-1">
          <span>Actions</span>
          <kbd class="inline-flex h-5 min-w-5 items-center justify-center border border-neutral-400 bg-neutral-100 px-1 font-mono text-[0.625rem] leading-none font-normal text-neutral-600 dark:border-neutral-600 dark:bg-neutral-900 dark:text-neutral-400">
            Cmd
          </kbd>
          <kbd class="inline-flex h-5 min-w-5 items-center justify-center border border-neutral-400 bg-neutral-100 px-1 font-mono text-[0.625rem] leading-none font-normal text-neutral-600 dark:border-neutral-600 dark:bg-neutral-900 dark:text-neutral-400">
            K
          </kbd>
        </div>
      </div>
    </div>
    """
  end

  def example(%{section: "autocomplete-grid"} = assigns) do
    ~H"""
    <div class="mx-auto w-[16rem]">
      <label class="flex flex-col gap-1 text-sm font-bold text-neutral-950 dark:text-white">
        Choose emoji
        <.autocomplete
          id="baseui-autocomplete-grid"
          placeholder="Search emojis…"
          input_class="h-8 w-64 max-w-full border border-neutral-950 bg-white px-2 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 placeholder:text-neutral-500 dark:placeholder:text-neutral-400 focus:outline-2 focus:-outline-offset-2 focus:outline-solid focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:bg-neutral-950 dark:text-white"
          popup_class="top-full mt-1 w-64 max-w-full max-h-[18.5rem] overflow-auto overscroll-contain border border-t-0 border-neutral-950 bg-white py-2 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
        >
          <:option
            :for={emoji <- baseui_autocomplete_emojis()}
            value={emoji.name}
            group={emoji.group}
            group_label_class="p-2 text-sm leading-4 text-neutral-500 select-none dark:text-neutral-400"
            group_list_class="grid grid-cols-5 px-2 pb-1"
            class="group flex h-10 cursor-default flex-col items-center justify-center bg-transparent px-0.5 py-2 text-2xl leading-none text-neutral-950 outline-0 select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:before:absolute data-[highlighted]:before:inset-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-100 dark:text-white dark:data-[highlighted]:before:bg-neutral-800"
          >
            {emoji.emoji}
          </:option>
          <:empty>
            <div class="px-2 py-3 text-sm leading-4 text-neutral-500 dark:text-neutral-400">
              No emojis found
            </div>
          </:empty>
        </.autocomplete>
      </label>
    </div>
    """
  end

  def example(%{section: "avatar-hero"} = assigns) do
    ~H"""
    <div class="flex gap-4">
      <.avatar
        id="baseui-avatar-hero-1"
        src="https://images.unsplash.com/photo-1543610892-0b1f7e6d8ac1?w=128&h=128&dpr=2&q=80"
        width="48"
        height="48"
        delay={600}
        class="inline-flex size-8 items-center justify-center overflow-hidden rounded-full bg-neutral-200 align-middle text-sm leading-none font-normal text-neutral-950 select-none dark:bg-neutral-800 dark:text-white"
        image_class="size-full object-cover"
        fallback_class="flex size-full items-center justify-center text-sm"
      >
        LT
      </.avatar>
      <.avatar
        id="baseui-avatar-hero-2"
        class="inline-flex size-8 items-center justify-center overflow-hidden rounded-full bg-neutral-200 align-middle text-sm leading-none font-normal text-neutral-950 select-none dark:bg-neutral-800 dark:text-white"
        fallback_class="flex size-full items-center justify-center"
      >
        LT
      </.avatar>
    </div>
    """
  end

  def example(%{section: "empty_state-hero"} = assigns) do
    ~H"""
    <.empty_state
      id="baseui-empty-state-hero"
      title="No results found"
      description="We couldn't find anything matching your search. Try a different keyword."
      class="flex w-72 flex-col items-center gap-3 text-center"
      indicator_class="flex size-12 items-center justify-center rounded-full bg-neutral-100 text-neutral-500 dark:bg-neutral-800 dark:text-neutral-400"
      body_class="flex flex-col gap-1"
      title_class="text-base font-semibold text-neutral-950 dark:text-white"
      description_class="text-sm text-neutral-600 dark:text-neutral-400"
    >
      <:indicator>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-6"
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
      id="baseui-empty-state-actions"
      align="left"
      title="No projects yet"
      description="Create your first project to get started — it only takes a minute."
      class="flex w-80 flex-col items-start gap-3 text-left"
      indicator_class="flex size-12 items-center justify-center rounded-full bg-neutral-100 text-neutral-500 dark:bg-neutral-800 dark:text-neutral-400"
      body_class="flex flex-col gap-1"
      title_class="text-base font-semibold text-neutral-950 dark:text-white"
      description_class="text-sm text-neutral-600 dark:text-neutral-400"
      actions_class="mt-2 flex gap-2"
    >
      <:indicator>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-6"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M12 10.5v6m3-3H9m4.06-7.19-2.12-2.12a1.5 1.5 0 0 0-1.061-.44H4.5A2.25 2.25 0 0 0 2.25 6v12a2.25 2.25 0 0 0 2.25 2.25h15A2.25 2.25 0 0 0 21.75 18V9a2.25 2.25 0 0 0-2.25-2.25h-5.379a1.5 1.5 0 0 1-1.06-.44Z"
          />
        </svg>
      </:indicator>
      <:actions>
        <button
          type="button"
          class="rounded-md bg-neutral-950 px-3 py-1.5 text-sm font-medium text-white hover:bg-neutral-800 dark:bg-white dark:text-neutral-950 dark:hover:bg-neutral-200"
        >
          New project
        </button>
        <button
          type="button"
          class="rounded-md px-3 py-1.5 text-sm font-medium text-neutral-700 hover:bg-neutral-100 dark:text-neutral-300 dark:hover:bg-neutral-800"
        >
          Import
        </button>
      </:actions>
    </.empty_state>
    """
  end

  def example(%{section: "burger-hero"} = assigns) do
    ~H"""
    <div class="flex items-center gap-6">
      <.burger
        id="baseui-burger-closed"
        label="Open navigation"
        class="relative inline-flex size-9 items-center justify-center rounded-md text-neutral-900 hover:bg-neutral-100 dark:text-white dark:hover:bg-neutral-800 [&_[data-part=line]]:absolute [&_[data-part=line]]:h-0.5 [&_[data-part=line]]:w-5 [&_[data-part=line]]:rounded-full [&_[data-part=line]]:bg-current [&_[data-part=line]]:transition-all [&_[data-part=line]]:duration-200 [&_[data-part=line]:nth-child(1)]:-translate-y-1.5 [&_[data-part=line]:nth-child(3)]:translate-y-1.5 [&[data-opened]_[data-part=line]:nth-child(1)]:translate-y-0 [&[data-opened]_[data-part=line]:nth-child(1)]:rotate-45 [&[data-opened]_[data-part=line]:nth-child(2)]:opacity-0 [&[data-opened]_[data-part=line]:nth-child(3)]:translate-y-0 [&[data-opened]_[data-part=line]:nth-child(3)]:-rotate-45"
      />
      <.burger
        id="baseui-burger-opened"
        opened
        label="Close navigation"
        class="relative inline-flex size-9 items-center justify-center rounded-md text-neutral-900 hover:bg-neutral-100 dark:text-white dark:hover:bg-neutral-800 [&_[data-part=line]]:absolute [&_[data-part=line]]:h-0.5 [&_[data-part=line]]:w-5 [&_[data-part=line]]:rounded-full [&_[data-part=line]]:bg-current [&_[data-part=line]]:transition-all [&_[data-part=line]]:duration-200 [&_[data-part=line]:nth-child(1)]:-translate-y-1.5 [&_[data-part=line]:nth-child(3)]:translate-y-1.5 [&[data-opened]_[data-part=line]:nth-child(1)]:translate-y-0 [&[data-opened]_[data-part=line]:nth-child(1)]:rotate-45 [&[data-opened]_[data-part=line]:nth-child(2)]:opacity-0 [&[data-opened]_[data-part=line]:nth-child(3)]:translate-y-0 [&[data-opened]_[data-part=line]:nth-child(3)]:-rotate-45"
      />
    </div>
    """
  end

  def example(%{section: "color_picker-hero"} = assigns) do
    ~H"""
    <.color_picker
      id="baseui-color-picker"
      value="#e8590c"
      class="w-56 space-y-3 [&_[data-part=area]]:relative [&_[data-part=area]]:h-36 [&_[data-part=area]]:w-full [&_[data-part=area]]:cursor-crosshair [&_[data-part=area]]:rounded-lg [&_[data-part=area]]:ring-1 [&_[data-part=area]]:ring-black/10 [&_[data-part=area-thumb]]:size-3.5 [&_[data-part=area-thumb]]:rounded-full [&_[data-part=area-thumb]]:border-2 [&_[data-part=area-thumb]]:border-white [&_[data-part=area-thumb]]:shadow [&_[data-part=area-thumb]]:ring-1 [&_[data-part=area-thumb]]:ring-black/30 [&_[data-part=controls]]:flex [&_[data-part=controls]]:items-center [&_[data-part=controls]]:gap-3 [&_[data-part=preview]]:size-8 [&_[data-part=preview]]:shrink-0 [&_[data-part=preview]]:rounded-full [&_[data-part=preview]]:ring-1 [&_[data-part=preview]]:ring-black/10 [&_[data-part=hue]]:h-3 [&_[data-part=hue]]:w-full [&_[data-part=hue]]:cursor-pointer [&_[data-part=hue]]:appearance-none [&_[data-part=hue]]:rounded-full [&_[data-part=hue]]:[background:linear-gradient(to_right,#f00,#ff0,#0f0,#0ff,#00f,#f0f,#f00)]"
    />
    """
  end

  def example(%{section: "rolling_number-hero"} = assigns) do
    ~H"""
    <div class="flex gap-8 text-neutral-900 dark:text-white">
      <.rolling_number
        id="baseui-rolling-number-1"
        value={2048}
        class="text-3xl font-bold tabular-nums"
      />
      <.rolling_number
        id="baseui-rolling-number-2"
        value={1_000_000}
        duration={1400}
        class="text-3xl font-bold tabular-nums"
      />
    </div>
    """
  end

  def example(%{section: "scroller-hero"} = assigns) do
    ~H"""
    <.scroller
      id="baseui-scroller"
      class="flex w-80 items-center gap-2 [&_[data-part=control]]:grid [&_[data-part=control]]:size-8 [&_[data-part=control]]:shrink-0 [&_[data-part=control]]:place-items-center [&_[data-part=control]]:rounded-full [&_[data-part=control]]:border [&_[data-part=control]]:border-neutral-300 [&_[data-part=control]]:bg-white [&_[data-part=control]]:text-lg [&_[data-part=control][data-disabled]]:opacity-30 dark:[&_[data-part=control]]:border-neutral-700 dark:[&_[data-part=control]]:bg-neutral-900 [&_[data-part=viewport]]:flex [&_[data-part=viewport]]:gap-3 [&_[data-part=viewport]]:overflow-x-auto [&_[data-part=viewport]]:scroll-smooth [&_[data-part=viewport]]:pb-1"
    >
      <div
        :for={n <- 1..10}
        class="grid size-16 shrink-0 place-items-center rounded-lg bg-neutral-100 text-sm font-medium text-neutral-800 dark:bg-neutral-800 dark:text-neutral-200"
      >
        {n}
      </div>
    </.scroller>
    """
  end

  def example(%{section: "semi_circle_progress-hero"} = assigns) do
    ~H"""
    <.semi_circle_progress
      value={72}
      label="Score"
      class="relative inline-block w-48 [&_[data-part=track]]:[stroke:#e5e5e5] [&_[data-part=track]]:[stroke-width:12] [&_[data-part=indicator]]:[stroke:#f97316] [&_[data-part=indicator]]:[stroke-width:12] dark:[&_[data-part=track]]:[stroke:#404040] [&_[data-part=label]]:absolute [&_[data-part=label]]:inset-x-0 [&_[data-part=label]]:bottom-1 [&_[data-part=label]]:flex [&_[data-part=label]]:flex-col [&_[data-part=label]]:items-center [&_[data-part=label]]:text-neutral-900 dark:[&_[data-part=label]]:text-white"
    >
      <span class="text-2xl font-bold">72</span>
      <span class="text-xs text-neutral-500">score</span>
    </.semi_circle_progress>
    """
  end

  def example(%{section: "splitter-hero"} = assigns) do
    ~H"""
    <.splitter
      id="baseui-splitter"
      default_size={45}
      class="flex h-40 w-80 overflow-hidden rounded-lg border border-neutral-300 dark:border-neutral-700 [&_[data-part=panel][data-index=0]]:w-[var(--chelekom-splitter-pos)] [&_[data-part=panel][data-index=0]]:shrink-0 [&_[data-part=panel][data-index=0]]:overflow-auto [&_[data-part=panel][data-index=1]]:flex-1 [&_[data-part=panel][data-index=1]]:overflow-auto [&_[data-part=panel][data-index=1]]:bg-neutral-50 dark:[&_[data-part=panel][data-index=1]]:bg-neutral-800 [&_[data-part=resizer]]:w-1.5 [&_[data-part=resizer]]:shrink-0 [&_[data-part=resizer]]:cursor-col-resize [&_[data-part=resizer]]:bg-neutral-200 dark:[&_[data-part=resizer]]:bg-neutral-700 [&_[data-part=resizer]:hover]:bg-neutral-400 [&_[data-part=resizer]]:outline-none"
    >
      <:first>
        <div class="p-3 text-sm text-neutral-700 dark:text-neutral-300">Files</div>
      </:first>
      <:second>
        <div class="p-3 text-sm text-neutral-700 dark:text-neutral-300">
          Editor — drag the divider or focus it and use arrow keys.
        </div>
      </:second>
    </.splitter>
    """
  end

  def example(%{section: "spoiler-hero"} = assigns) do
    ~H"""
    <.spoiler
      id="baseui-spoiler"
      class="max-w-sm text-sm text-neutral-700 dark:text-neutral-300 [&_[data-part=content]]:overflow-hidden [&_[data-part=content]]:transition-all [&:not([data-expanded])_[data-part=content]]:max-h-12 [&[data-expanded]_[data-part=content]]:max-h-40 [&_[data-part=control]]:mt-1 [&_[data-part=control]]:text-sm [&_[data-part=control]]:font-medium [&_[data-part=control]]:text-neutral-900 [&_[data-part=control]]:underline dark:[&_[data-part=control]]:text-white [&[data-expanded]_[data-part=show-label]]:hidden [&:not([data-expanded])_[data-part=hide-label]]:hidden"
    >
      Mantine's Spoiler hides long content behind a toggle. This copy is long enough to be clipped
      when collapsed; press the control to reveal the rest, and press it again to hide it away.
    </.spoiler>
    """
  end

  def example(%{section: "tags_input-hero"} = assigns) do
    ~H"""
    <.tags_input
      id="baseui-tags-input"
      tags={["Design", "Engineering", "Product"]}
      placeholder="Add a tag…"
      on_remove={JS.hide(to: {:closest, "[data-part=tag]"})}
      class="flex w-80 flex-wrap items-center gap-1.5 rounded-lg border border-neutral-300 bg-white px-2 py-1.5 text-sm cursor-text focus-within:ring-2 focus-within:ring-neutral-400 dark:border-neutral-700 dark:bg-neutral-900 [&_[data-part=tag]]:inline-flex [&_[data-part=tag]]:items-center [&_[data-part=tag]]:gap-1 [&_[data-part=tag]]:rounded [&_[data-part=tag]]:bg-neutral-100 [&_[data-part=tag]]:py-0.5 [&_[data-part=tag]]:pr-1 [&_[data-part=tag]]:pl-2 dark:[&_[data-part=tag]]:bg-neutral-800 [&_[data-part=remove]]:inline-flex [&_[data-part=remove]]:size-4 [&_[data-part=remove]]:items-center [&_[data-part=remove]]:justify-center [&_[data-part=remove]]:rounded-full [&_[data-part=remove]]:text-neutral-500 [&_[data-part=remove]]:hover:bg-neutral-200 dark:[&_[data-part=remove]]:hover:bg-neutral-700 [&_[data-part=input]]:min-w-24 [&_[data-part=input]]:flex-1 [&_[data-part=input]]:border-0 [&_[data-part=input]]:bg-transparent [&_[data-part=input]]:p-0.5 [&_[data-part=input]]:outline-none"
    />
    """
  end

  def example(%{section: "pill-hero"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.pill
        id="baseui-pill-design"
        class="inline-flex items-center gap-1 rounded-full bg-neutral-100 px-2.5 py-0.5 text-sm text-neutral-800 dark:bg-neutral-800 dark:text-neutral-200"
      >
        Design
      </.pill>
      <.pill
        id="baseui-pill-eng"
        with_remove
        remove_label="Remove Engineering"
        class="inline-flex items-center gap-1 rounded-full bg-neutral-100 py-0.5 pr-1 pl-2.5 text-sm text-neutral-800 dark:bg-neutral-800 dark:text-neutral-200 [&_[data-part=remove]]:inline-flex [&_[data-part=remove]]:size-4 [&_[data-part=remove]]:items-center [&_[data-part=remove]]:justify-center [&_[data-part=remove]]:rounded-full [&_[data-part=remove]]:text-neutral-500 [&_[data-part=remove]]:hover:bg-neutral-200 dark:[&_[data-part=remove]]:hover:bg-neutral-700"
      >
        Engineering
      </.pill>
      <.pill
        id="baseui-pill-product"
        with_remove
        remove_label="Remove Product"
        class="inline-flex items-center gap-1 rounded-full bg-neutral-100 py-0.5 pr-1 pl-2.5 text-sm text-neutral-800 dark:bg-neutral-800 dark:text-neutral-200 [&_[data-part=remove]]:inline-flex [&_[data-part=remove]]:size-4 [&_[data-part=remove]]:items-center [&_[data-part=remove]]:justify-center [&_[data-part=remove]]:rounded-full [&_[data-part=remove]]:text-neutral-500 [&_[data-part=remove]]:hover:bg-neutral-200 dark:[&_[data-part=remove]]:hover:bg-neutral-700"
      >
        Product
      </.pill>
    </div>
    """
  end

  def example(%{section: "chip-hero"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      <.chip
        id="baseui-chip-react"
        name="baseui-chip[]"
        value="react"
        checked
        class="inline-flex cursor-pointer items-center gap-1.5 rounded-full border border-neutral-300 px-3 py-1 text-sm text-neutral-800 select-none has-[:checked]:border-neutral-900 has-[:checked]:bg-neutral-900 has-[:checked]:text-white has-[:focus-visible]:ring-2 has-[:focus-visible]:ring-neutral-400 dark:border-neutral-700 dark:text-neutral-200 dark:has-[:checked]:border-white dark:has-[:checked]:bg-white dark:has-[:checked]:text-neutral-900 [&_[data-part=input]]:sr-only"
      >
        React
      </.chip>
      <.chip
        id="baseui-chip-vue"
        name="baseui-chip[]"
        value="vue"
        class="inline-flex cursor-pointer items-center gap-1.5 rounded-full border border-neutral-300 px-3 py-1 text-sm text-neutral-800 select-none has-[:checked]:border-neutral-900 has-[:checked]:bg-neutral-900 has-[:checked]:text-white has-[:focus-visible]:ring-2 has-[:focus-visible]:ring-neutral-400 dark:border-neutral-700 dark:text-neutral-200 dark:has-[:checked]:border-white dark:has-[:checked]:bg-white dark:has-[:checked]:text-neutral-900 [&_[data-part=input]]:sr-only"
      >
        Vue
      </.chip>
      <.chip
        id="baseui-chip-svelte"
        name="baseui-chip[]"
        value="svelte"
        class="inline-flex cursor-pointer items-center gap-1.5 rounded-full border border-neutral-300 px-3 py-1 text-sm text-neutral-800 select-none has-[:checked]:border-neutral-900 has-[:checked]:bg-neutral-900 has-[:checked]:text-white has-[:focus-visible]:ring-2 has-[:focus-visible]:ring-neutral-400 dark:border-neutral-700 dark:text-neutral-200 dark:has-[:checked]:border-white dark:has-[:checked]:bg-white dark:has-[:checked]:text-neutral-900 [&_[data-part=input]]:sr-only"
      >
        Svelte
      </.chip>
    </div>
    """
  end

  def example(%{section: "close_button-hero"} = assigns) do
    ~H"""
    <div class="flex items-center gap-4">
      <.close_button
        id="baseui-close-button-hero"
        label="Close"
        class="inline-flex size-8 items-center justify-center rounded-md text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 dark:text-neutral-400 dark:hover:bg-neutral-800 dark:hover:text-white"
      />
      <.close_button
        id="baseui-close-button-custom"
        label="Remove"
        class="inline-flex size-8 items-center justify-center rounded-md text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 dark:text-neutral-400 dark:hover:bg-neutral-800 dark:hover:text-white"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-4"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
        </svg>
      </.close_button>
    </div>
    """
  end

  def example(%{section: "checkbox-hero"} = assigns) do
    ~H"""
    <.checkbox
      id="baseui-checkbox-hero"
      checked
      class="flex items-center gap-2 text-sm font-normal text-neutral-950 dark:text-white focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      indicator_class="group flex size-4 shrink-0 items-center justify-center border rounded-none p-0 border-neutral-950 bg-white text-white dark:border-white dark:bg-neutral-950 dark:text-neutral-950 data-[checked]:bg-neutral-950 data-[checked]:text-white dark:data-[checked]:bg-white dark:data-[checked]:text-neutral-950"
    >
      <:indicator>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          class="block group-data-[unchecked]:hidden"
        >
          <path d="m2.5 8.5 4 4 7-9" />
        </svg>
      </:indicator>
      Enable notifications
    </.checkbox>
    """
  end

  def example(%{section: "checkbox_group-hero"} = assigns) do
    ~H"""
    <.checkbox_group
      id="baseui-checkbox_group-hero"
      class="flex flex-col items-start gap-1 text-neutral-950 dark:text-white"
      label_class="text-sm font-bold"
    >
      <:indicator_icon>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          class="block group-data-[unchecked]/box:hidden"
          style="display: block"
        >
          <path d="m2.5 8.5 4 4 7-9" />
        </svg>
      </:indicator_icon>

      <:label>Apples</:label>

      <:item
        value="fuji-apple"
        checked
        item_class="group flex items-center gap-2 text-sm font-normal text-neutral-950 dark:text-white"
        indicator_class="group/box flex size-4 shrink-0 items-center justify-center border rounded-none p-0 border-neutral-950 bg-white text-white dark:border-white dark:bg-neutral-950 dark:text-neutral-950 data-[checked]:bg-neutral-950 data-[checked]:text-white dark:data-[checked]:bg-white dark:data-[checked]:text-neutral-950 group-focus-visible:outline-2 group-focus-visible:outline-offset-2 group-focus-visible:outline-neutral-950 dark:group-focus-visible:outline-white"
      >
        Fuji
      </:item>

      <:item
        value="gala-apple"
        item_class="group flex items-center gap-2 text-sm font-normal text-neutral-950 dark:text-white"
        indicator_class="group/box flex size-4 shrink-0 items-center justify-center border rounded-none p-0 border-neutral-950 bg-white text-white dark:border-white dark:bg-neutral-950 dark:text-neutral-950 data-[checked]:bg-neutral-950 data-[checked]:text-white dark:data-[checked]:bg-white dark:data-[checked]:text-neutral-950 group-focus-visible:outline-2 group-focus-visible:outline-offset-2 group-focus-visible:outline-neutral-950 dark:group-focus-visible:outline-white"
      >
        Gala
      </:item>

      <:item
        value="granny-smith-apple"
        item_class="group flex items-center gap-2 text-sm font-normal text-neutral-950 dark:text-white"
        indicator_class="group/box flex size-4 shrink-0 items-center justify-center border rounded-none p-0 border-neutral-950 bg-white text-white dark:border-white dark:bg-neutral-950 dark:text-neutral-950 data-[checked]:bg-neutral-950 data-[checked]:text-white dark:data-[checked]:bg-white dark:data-[checked]:text-neutral-950 group-focus-visible:outline-2 group-focus-visible:outline-offset-2 group-focus-visible:outline-neutral-950 dark:group-focus-visible:outline-white"
      >
        Granny Smith
      </:item>
    </.checkbox_group>
    """
  end

  def example(%{section: "alpha_slider-hero"} = assigns) do
    ~H"""
    <div class="w-64">
      <.alpha_slider
        id="baseui-alpha-slider"
        value={50}
        color="#e8590c"
        class="block w-full [&_[data-part=control]]:relative [&_[data-part=control]]:flex [&_[data-part=control]]:h-4 [&_[data-part=control]]:cursor-pointer [&_[data-part=control]]:items-center [&_[data-part=track]]:relative [&_[data-part=track]]:h-3 [&_[data-part=track]]:w-full [&_[data-part=track]]:overflow-hidden [&_[data-part=track]]:rounded-full [&_[data-part=track]]:[background-image:linear-gradient(to_right,transparent,var(--chelekom-alpha-color)),conic-gradient(#ccc_25%,#fff_0_50%,#ccc_0_75%,#fff_0)] [&_[data-part=track]]:[background-size:100%_100%,10px_10px] [&_[data-part=indicator]]:hidden [&_[data-part=thumb]]:size-4 [&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:border-2 [&_[data-part=thumb]]:border-white [&_[data-part=thumb]]:shadow [&_[data-part=thumb]]:ring-1 [&_[data-part=thumb]]:ring-black/30 [&_[data-part=thumb]]:outline-none"
      />
    </div>
    """
  end

  def example(%{section: "hue_slider-hero"} = assigns) do
    ~H"""
    <div class="w-64">
      <.hue_slider
        id="baseui-hue-slider"
        value={140}
        class="block w-full [&_[data-part=control]]:relative [&_[data-part=control]]:flex [&_[data-part=control]]:h-4 [&_[data-part=control]]:cursor-pointer [&_[data-part=control]]:items-center [&_[data-part=track]]:relative [&_[data-part=track]]:h-3 [&_[data-part=track]]:w-full [&_[data-part=track]]:rounded-full [&_[data-part=track]]:[background:linear-gradient(to_right,#f00,#ff0,#0f0,#0ff,#00f,#f0f,#f00)] [&_[data-part=indicator]]:hidden [&_[data-part=thumb]]:size-4 [&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:border-2 [&_[data-part=thumb]]:border-white [&_[data-part=thumb]]:shadow [&_[data-part=thumb]]:ring-1 [&_[data-part=thumb]]:ring-black/30 [&_[data-part=thumb]]:outline-none"
      />
    </div>
    """
  end

  def example(%{section: "number_formatter-hero"} = assigns) do
    ~H"""
    <div class="space-y-1 text-sm text-neutral-700 dark:text-neutral-300">
      <p>
        Revenue:
        <.number_formatter
          value={1_234_567.89}
          prefix="$"
          decimal_scale={2}
          class="font-semibold tabular-nums text-neutral-900 dark:text-white"
        />
      </p>
      <p>
        Downloads:
        <.number_formatter
          value={9_876_543}
          thousand_separator=" "
          class="font-semibold tabular-nums text-neutral-900 dark:text-white"
        />
      </p>
    </div>
    """
  end

  def example(%{section: "marquee-hero"} = assigns) do
    ~H"""
    <div class="w-80 overflow-hidden">
      <style>
        @keyframes chelekom-marquee-x { from { transform: translateX(0) } to { transform: translateX(-50%) } }
      </style>
      <.marquee
        class="overflow-hidden"
        track_class="flex w-max motion-safe:animate-[chelekom-marquee-x_14s_linear_infinite] hover:[animation-play-state:paused]"
        group_class="flex shrink-0 items-center gap-6 pr-6 text-sm font-medium text-neutral-700 dark:text-neutral-300"
      >
        <span>React</span>
        <span>Vue</span>
        <span>Svelte</span>
        <span>Solid</span>
        <span>Angular</span>
      </.marquee>
    </div>
    """
  end

  def example(%{section: "action_icon-hero"} = assigns) do
    ~H"""
    <div class="flex items-center gap-3">
      <.action_icon
        label="Edit"
        class="inline-flex size-9 items-center justify-center rounded-md text-neutral-700 hover:bg-neutral-100 dark:text-neutral-300 dark:hover:bg-neutral-800"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-5"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Z"
          />
        </svg>
      </.action_icon>
      <.action_icon
        label="Delete"
        disabled
        class="inline-flex size-9 items-center justify-center rounded-md text-neutral-700 data-[disabled]:opacity-40 dark:text-neutral-300"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-5"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397"
          />
        </svg>
      </.action_icon>
    </div>
    """
  end

  def example(%{section: "anchor-hero"} = assigns) do
    ~H"""
    <p class="text-sm text-neutral-700 dark:text-neutral-300">
      Built with <.anchor
        href="https://phoenixframework.org"
        target="_blank"
        class="font-medium text-blue-600 underline underline-offset-2 hover:no-underline dark:text-blue-400"
      >Phoenix</.anchor>.
    </p>
    """
  end

  def example(%{section: "theme_icon-hero"} = assigns) do
    ~H"""
    <div class="flex items-center gap-3">
      <.theme_icon
        label="Success"
        class="inline-flex size-9 items-center justify-center rounded-lg bg-emerald-100 text-emerald-700 dark:bg-emerald-500/20 dark:text-emerald-300"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="2"
          stroke="currentColor"
          class="size-5"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
        </svg>
      </.theme_icon>
      <.theme_icon class="inline-flex size-9 items-center justify-center rounded-full bg-violet-100 text-violet-700 dark:bg-violet-500/20 dark:text-violet-300">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="size-5">
          <path d="M11.983 1.907a.75.75 0 0 0-1.292-.657l-8.5 9.5A.75.75 0 0 0 2.75 12h6.572l-1.305 6.093a.75.75 0 0 0 1.292.657l8.5-9.5A.75.75 0 0 0 18.25 8h-6.572l1.305-6.093Z" />
        </svg>
      </.theme_icon>
    </div>
    """
  end

  def example(%{section: "visually_hidden-hero"} = assigns) do
    ~H"""
    <button
      type="button"
      class="rounded-md border border-neutral-300 px-3 py-1.5 text-sm text-neutral-800 hover:bg-neutral-100 dark:border-neutral-700 dark:text-neutral-200 dark:hover:bg-neutral-800"
    >
      ★
      <.visually_hidden>Add to favorites</.visually_hidden>
    </button>
    """
  end

  def example(%{section: "highlight-hero"} = assigns) do
    ~H"""
    <p class="max-w-sm text-sm text-neutral-700 dark:text-neutral-300">
      <.highlight
        text="Search results for phoenix — the Phoenix framework is fast."
        highlight="phoenix"
        mark_class="rounded bg-lime-200 px-0.5 text-neutral-900"
      />
    </p>
    """
  end

  def example(%{section: "mark-hero"} = assigns) do
    ~H"""
    <p class="max-w-sm text-sm text-neutral-700 dark:text-neutral-300">
      The quick brown
      <.mark class="rounded bg-yellow-200 px-0.5 text-neutral-900">fox</.mark>
      jumps over the lazy <.mark class="rounded bg-lime-200 px-0.5 text-neutral-900">dog</.mark>.
    </p>
    """
  end

  def example(%{section: "code-hero"} = assigns) do
    ~H"""
    <div class="w-80 space-y-3">
      <p class="text-sm text-neutral-700 dark:text-neutral-300">
        Run
        <.code class="rounded bg-neutral-100 px-1.5 py-0.5 font-mono text-[0.85em] text-neutral-900 dark:bg-neutral-800 dark:text-neutral-100">
          npm install
        </.code>
        first.
      </p>
      <.code
        block
        class="overflow-x-auto rounded-lg bg-neutral-100 p-3 font-mono text-sm text-neutral-900 dark:bg-neutral-800 dark:text-neutral-100"
        phx-no-format
      >export const sum = (a, b) => a + b;</.code>
    </div>
    """
  end

  def example(%{section: "color_swatch-hero"} = assigns) do
    ~H"""
    <div class="flex items-center gap-3">
      <.color_swatch color="#fa5252" class="inline-block size-9 rounded-full ring-1 ring-black/10" />
      <.color_swatch color="#7048e8" class="inline-block size-9 rounded-full ring-1 ring-black/10" />
      <.color_swatch color="#12b886" class="inline-block size-9 rounded-lg ring-1 ring-black/10" />
      <.color_swatch
        color="#1c7ed6"
        label="Selected"
        class="inline-flex size-9 items-center justify-center rounded-full text-white ring-1 ring-black/10"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="size-4">
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

  def example(%{section: "combobox-hero"} = assigns) do
    ~H"""
    <div class="relative flex flex-col gap-1 text-sm leading-5 font-bold text-neutral-950 dark:text-white">
      <label for="baseui-combobox-hero">Choose a fruit</label>
      <.combobox
        id="baseui-combobox-hero"
        clear
        trigger
        placeholder="e.g. Apple"
        class="relative"
        control_class="relative h-8 w-56 border border-neutral-950 bg-white dark:bg-neutral-950 focus-within:outline-2 focus-within:-outline-offset-1 focus-within:outline-neutral-950 dark:focus-within:outline-white dark:border-white"
        input_class="h-full w-full border-0 bg-white pl-2 pr-[calc(0.5rem+2rem*2)] dark:bg-neutral-950 text-sm font-normal text-neutral-950 outline-none placeholder:text-neutral-500 dark:placeholder:text-neutral-400 dark:text-white"
        clear_class="absolute right-6 bottom-0 flex h-full w-6 items-center justify-center border-0 bg-transparent p-0 text-neutral-950 dark:text-white data-[hidden]:hidden"
        trigger_class="absolute right-0 bottom-0 flex h-full w-6 items-center justify-center border-0 bg-transparent p-0 text-neutral-950 dark:text-white"
        popup_class="mt-1 w-56 max-w-[var(--available-width)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0_rgb(0_0_0_/_12%)] max-h-[22.5rem] overflow-y-auto overscroll-contain py-1 scroll-py-1 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none data-[closed]:hidden"
        item_class="group/item grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 p-2 text-sm leading-4 outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white data-[hidden]:hidden"
        indicator_class="col-start-1 invisible group-data-[selected]/item:visible"
        empty_class="py-4 pr-4 pl-2 text-sm leading-4 text-neutral-500 dark:text-neutral-400 data-[hidden]:hidden"
      >
        <:trigger_icon>
          <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display:block">
            <path d="M12 6H4l4 4.5z" />
          </svg>
        </:trigger_icon>
        <:clear_icon>
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-linecap="square"
            stroke-linejoin="round"
            style="display:block"
          >
            <path d="m4.5 4.5 7 7m-7 0 7-7" />
          </svg>
        </:clear_icon>
        <:item_indicator>
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            style="display:block"
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
          <span class="col-start-2">{f}</span>
        </:option>
        <:empty>No fruits found.</:empty>
      </.combobox>
    </div>
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
    <div class="relative flex flex-col gap-1 text-sm leading-5 font-bold text-neutral-950 dark:text-white">
      <label for="baseui-combobox-grouped">Select produce</label>
      <.combobox
        id="baseui-combobox-grouped"
        clear
        trigger
        placeholder="e.g. Mango"
        class="relative"
        control_class="relative h-8 w-64 border border-neutral-950 bg-white dark:bg-neutral-950 focus-within:outline-2 focus-within:-outline-offset-1 focus-within:outline-neutral-950 dark:focus-within:outline-white dark:border-white"
        input_class="h-full w-full border-0 bg-white pl-2 pr-[calc(0.5rem+2rem*2)] dark:bg-neutral-950 text-sm font-normal text-neutral-950 outline-none placeholder:text-neutral-500 dark:placeholder:text-neutral-400 dark:text-white"
        clear_class="absolute right-6 bottom-0 flex h-full w-6 items-center justify-center border-0 bg-transparent p-0 text-neutral-950 dark:text-white data-[hidden]:hidden"
        trigger_class="absolute right-0 bottom-0 flex h-full w-6 items-center justify-center border-0 bg-transparent p-0 text-neutral-950 dark:text-white"
        popup_class="mt-1 w-64 max-w-[var(--available-width)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0_rgb(0_0_0_/_12%)] max-h-[22.5rem] overflow-auto overscroll-contain py-1 scroll-py-1 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none data-[closed]:hidden"
        group_class="block pb-2 last:pb-0"
        group_label_class="block py-2 pr-2 pl-8 text-sm leading-4 text-neutral-500 select-none dark:text-neutral-400"
        item_class="group/item grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 p-2 text-sm leading-4 outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white data-[hidden]:hidden"
        indicator_class="col-start-1 flex items-center justify-center invisible group-data-[selected]/item:visible"
        empty_class="py-4 pr-4 pl-2 text-sm leading-4 text-neutral-500 dark:text-neutral-400 data-[hidden]:hidden"
      >
        <:trigger_icon>
          <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display:block">
            <path d="M12 6H4l4 4.5z" />
          </svg>
        </:trigger_icon>
        <:clear_icon>
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-linecap="square"
            stroke-linejoin="round"
            style="display:block"
          >
            <path d="m4.5 4.5 7 7m-7 0 7-7" />
          </svg>
        </:clear_icon>
        <:item_indicator>
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            style="display:block"
          >
            <path d="m2.5 8.5 4 4 7-9" />
          </svg>
        </:item_indicator>
        <:option :for={f <- @fruits} value={"fruit-" <> String.downcase(f)} group="Fruits">
          <span class="col-start-2">{f}</span>
        </:option>
        <:option :for={v <- @vegetables} value={"veg-" <> String.downcase(v)} group="Vegetables">
          <span class="col-start-2">{v}</span>
        </:option>
        <:empty>No produce found.</:empty>
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
    <div class="max-w-md flex flex-col gap-1">
      <label
        class="flex flex-col gap-1 text-sm leading-5 font-bold text-neutral-950 dark:text-white"
        for="baseui-combobox-multiple"
      >
        Programming languages
      </label>
      <.combobox
        id="baseui-combobox-multiple"
        multiple
        placeholder="e.g. TypeScript"
        control_class="flex min-h-8 w-64 cursor-text flex-wrap items-center gap-0.5 border border-neutral-950 bg-white dark:bg-neutral-950 px-2 py-1 focus-within:outline-2 focus-within:-outline-offset-1 focus-within:outline-neutral-950 dark:focus-within:outline-white has-[button]:px-1 dark:border-white min-[32rem]:w-[22rem]"
        chips_class="flex w-full flex-wrap items-center gap-1"
        chip_class="group flex min-h-[calc(1.5rem-2px)] cursor-default items-center gap-1 overflow-hidden bg-neutral-100 py-0 pr-[0.2rem] pl-[0.4rem] text-sm leading-none text-neutral-950 outline-none focus-within:bg-neutral-950 focus-within:text-white dark:bg-neutral-800 dark:text-white dark:focus-within:bg-white dark:focus-within:text-neutral-950"
        chip_remove_class="flex size-4 items-center justify-center border-0 bg-transparent p-0 text-inherit hover:bg-neutral-200 group-focus-within:hover:bg-neutral-700 dark:hover:bg-neutral-700 dark:group-focus-within:hover:bg-neutral-200"
        input_class="h-[calc(1.5rem-2px)] min-w-12 flex-1 border-0 bg-white p-0 text-sm dark:bg-neutral-950 font-normal text-neutral-950 outline-none placeholder:text-neutral-500 dark:placeholder:text-neutral-400 dark:text-white"
        popup_class="mt-1 w-64 max-h-[24.5rem] max-w-[var(--available-width)] origin-[var(--transform-origin)] overflow-y-auto overscroll-contain border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0_rgb(0_0_0_/_12%)] dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none data-[closed]:hidden"
        item_class="group/item grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 p-2 text-sm leading-4 outline-none select-none data-[selected]:relative data-[selected]:z-0 data-[selected]:text-neutral-950 data-[selected]:before:absolute data-[selected]:before:inset-0 data-[selected]:before:z-[-1] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 dark:data-[selected]:text-white dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white data-[hidden]:hidden"
        indicator_class="col-start-1 invisible group-data-[selected]/item:visible"
        empty_class="py-2 pr-4 pl-2 text-sm leading-4 text-neutral-500 dark:text-neutral-400 data-[hidden]:hidden"
      >
        <:chip_remove_icon>
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-linecap="square"
            stroke-linejoin="round"
            style="display:block"
          >
            <path d="m4.5 4.5 7 7m-7 0 7-7" />
          </svg>
        </:chip_remove_icon>
        <:item_indicator>
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            style="display:block"
          >
            <path d="m2.5 8.5 4 4 7-9" />
          </svg>
        </:item_indicator>
        <:option :for={lang <- @langs} value={lang}>
          <span class="col-start-2">{lang}</span>
        </:option>
        <:empty>No languages found.</:empty>
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
    <div class="flex flex-col items-start gap-1">
      <label
        class="cursor-default text-sm leading-5 font-bold text-neutral-950 dark:text-white"
        for="baseui-combobox-input-inside-popup"
      >
        Country
      </label>
      <.combobox
        id="baseui-combobox-input-inside-popup"
        placeholder="e.g. United Kingdom"
        control_class="relative flex h-8 min-w-40 items-center border border-neutral-950 bg-white px-2 text-sm dark:bg-neutral-950 dark:border-white focus-within:outline-2 focus-within:-outline-offset-1 focus-within:outline-neutral-950 dark:focus-within:outline-white"
        input_class="h-full w-full border-0 bg-white text-sm font-normal text-neutral-950 outline-none placeholder:text-neutral-500 dark:bg-neutral-950 dark:placeholder:text-neutral-400 dark:text-white"
        popup_class="mt-1 max-h-[24.5rem] max-w-[var(--available-width)] origin-[var(--transform-origin)] overflow-auto overscroll-contain border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0_rgb(0_0_0_/_12%)] dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none data-[closed]:hidden"
        item_class="group/item grid min-w-80 cursor-default grid-cols-[1rem_1fr] items-center gap-2 p-2 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white data-[hidden]:hidden"
        indicator_class="col-start-1 invisible group-data-[selected]/item:visible"
        empty_class="py-4 pr-4 pl-2 text-sm leading-4 text-neutral-500 dark:text-neutral-400 data-[hidden]:hidden"
      >
        <:item_indicator>
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            style="display:block"
          >
            <path d="m2.5 8.5 4 4 7-9" />
          </svg>
        </:item_indicator>
        <:option :for={{code, label} <- @countries} value={code}>
          <span class="col-start-2">{label}</span>
        </:option>
        <:empty>No countries found.</:empty>
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
    <div class="max-w-md flex flex-col gap-1">
      <label
        class="flex flex-col gap-1 text-sm leading-5 font-bold text-neutral-950 dark:text-white"
        for="baseui-combobox-creatable"
      >
        Labels
      </label>
      <.combobox
        id="baseui-combobox-creatable"
        multiple
        creatable
        placeholder="e.g. bug"
        control_class="flex min-h-8 w-64 cursor-text flex-wrap items-center gap-0.5 border border-neutral-950 bg-white dark:bg-neutral-950 px-2 py-1 focus-within:outline-2 focus-within:-outline-offset-1 focus-within:outline-neutral-950 dark:focus-within:outline-white has-[button]:px-1 dark:border-white min-[32rem]:w-[22rem]"
        chips_class="flex w-full flex-wrap items-center gap-1"
        chip_class="group flex min-h-[calc(1.5rem-2px)] cursor-default items-center gap-1 overflow-hidden bg-neutral-100 py-0 pr-[0.2rem] pl-[0.4rem] text-sm leading-none text-neutral-950 outline-none focus-within:bg-neutral-950 focus-within:text-white dark:bg-neutral-800 dark:text-white dark:focus-within:bg-white dark:focus-within:text-neutral-950"
        chip_remove_class="flex size-4 items-center justify-center border-0 bg-transparent p-0 text-inherit hover:bg-neutral-200 group-focus-within:hover:bg-neutral-700 dark:hover:bg-neutral-700 dark:group-focus-within:hover:bg-neutral-200"
        input_class="h-[calc(1.5rem-2px)] min-w-12 flex-1 border-0 bg-white p-0 text-sm dark:bg-neutral-950 font-normal text-neutral-950 outline-none placeholder:text-neutral-500 dark:placeholder:text-neutral-400 dark:text-white"
        popup_class="mt-1 w-64 max-h-[24.5rem] max-w-[var(--available-width)] origin-[var(--transform-origin)] overflow-y-auto overscroll-contain border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0_rgb(0_0_0_/_12%)] dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none data-[closed]:hidden"
        item_class="group/item grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 p-2 text-sm leading-4 outline-none select-none data-[selected]:relative data-[selected]:z-0 data-[selected]:text-neutral-950 data-[selected]:before:absolute data-[selected]:before:inset-0 data-[selected]:before:z-[-1] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 dark:data-[selected]:text-white dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white data-[hidden]:hidden"
        indicator_class="col-start-1 invisible group-data-[selected]/item:visible"
        create_class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 p-2 text-sm leading-4 outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white data-[hidden]:hidden"
        create_label_class="col-start-2"
        empty_class="py-2 pr-4 pl-2 text-sm leading-4 text-neutral-500 dark:text-neutral-400 data-[hidden]:hidden"
      >
        <:chip_remove_icon>
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-linecap="square"
            stroke-linejoin="round"
            style="display:block"
          >
            <path d="m4.5 4.5 7 7m-7 0 7-7" />
          </svg>
        </:chip_remove_icon>
        <:item_indicator>
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            style="display:block"
          >
            <path d="m2.5 8.5 4 4 7-9" />
          </svg>
        </:item_indicator>
        <:create_icon>
          <span class="col-start-1">
            <svg
              width="16"
              height="16"
              viewBox="0 0 16 16"
              fill="none"
              stroke="currentColor"
              stroke-linecap="square"
              stroke-linejoin="round"
              style="display:block"
            >
              <path d="M1.5 8h13M8 14.5v-13" />
            </svg>
          </span>
        </:create_icon>
        <:option :for={lbl <- @labels} value={lbl}>
          <span class="col-start-2">{lbl}</span>
        </:option>
        <:empty>No labels found.</:empty>
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
    <div class="relative flex flex-col gap-1 text-sm leading-5 font-bold text-neutral-950 dark:text-white">
      <label for="baseui-combobox-async-single">Assign reviewer</label>
      <.combobox
        id="baseui-combobox-async-single"
        clear
        trigger
        placeholder="e.g. Michael"
        class="relative"
        control_class="relative h-8 w-64 border border-neutral-950 bg-white dark:bg-neutral-950 focus-within:outline-2 focus-within:-outline-offset-1 focus-within:outline-neutral-950 dark:focus-within:outline-white dark:border-white md:w-80"
        input_class="h-full w-full border-0 bg-white pl-2 pr-[calc(0.5rem+2rem*2)] dark:bg-neutral-950 text-sm font-normal text-neutral-950 outline-none placeholder:text-neutral-500 dark:placeholder:text-neutral-400 dark:text-white"
        clear_class="absolute right-6 bottom-0 flex h-full w-6 items-center justify-center border-0 bg-transparent p-0 text-neutral-950 dark:text-white data-[hidden]:hidden"
        trigger_class="absolute right-0 bottom-0 flex h-full w-6 items-center justify-center border-0 bg-transparent p-0 text-neutral-950 dark:text-white"
        popup_class="mt-1 w-64 md:w-80 max-w-[var(--available-width)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0_rgb(0_0_0_/_12%)] max-h-[22.5rem] overflow-y-auto overscroll-contain py-1 scroll-pt-1 scroll-pb-1 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none data-[closed]:hidden"
        item_class="group/item grid cursor-default grid-cols-[1rem_1fr] items-start gap-2 px-2 py-2 text-sm leading-[1.2rem] outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-neutral-950 data-[highlighted]:before:absolute data-[highlighted]:before:inset-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-100 dark:data-[highlighted]:text-white dark:data-[highlighted]:before:bg-neutral-800 data-[hidden]:hidden"
        indicator_class="col-start-1 mt-1 invisible group-data-[selected]/item:visible"
      >
        <:trigger_icon>
          <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display:block">
            <path d="M12 6H4l4 4.5z" />
          </svg>
        </:trigger_icon>
        <:clear_icon>
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-linecap="square"
            stroke-linejoin="round"
            style="display:block"
          >
            <path d="m4.5 4.5 7 7m-7 0 7-7" />
          </svg>
        </:clear_icon>
        <:item_indicator>
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            style="display:block"
          >
            <path d="m2.5 8.5 4 4 7-9" />
          </svg>
        </:item_indicator>
        <:option :for={u <- @users} value={u.id}>
          <span class="col-start-2 flex flex-col gap-1">
            <span class="text-sm leading-5 font-bold">{u.name}</span>
            <span class="text-xs">{u.email}</span>
            <span class="flex flex-wrap gap-2 text-xs text-neutral-500 dark:text-neutral-400">
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
    <div class="max-w-md flex flex-col gap-1">
      <label
        class="flex flex-col gap-1 text-sm leading-5 font-bold text-neutral-950 dark:text-white"
        for="baseui-combobox-async-multiple"
      >
        Assign reviewers
      </label>
      <.combobox
        id="baseui-combobox-async-multiple"
        multiple
        placeholder="e.g. Michael"
        control_class="flex min-h-8 w-64 cursor-text flex-wrap items-center gap-0.5 border border-neutral-950 bg-white dark:bg-neutral-950 px-2 py-1 focus-within:outline-2 focus-within:-outline-offset-1 focus-within:outline-neutral-950 dark:focus-within:outline-white has-[button]:px-1 dark:border-white min-[32rem]:w-[22rem]"
        chips_class="flex w-full flex-wrap items-center gap-1"
        chip_class="group flex min-h-[calc(1.5rem-2px)] cursor-default items-center gap-1 overflow-hidden bg-neutral-100 py-0 pr-[0.2rem] pl-[0.4rem] text-sm leading-none text-neutral-950 outline-none focus-within:bg-neutral-950 focus-within:text-white dark:bg-neutral-800 dark:text-white dark:focus-within:bg-white dark:focus-within:text-neutral-950"
        chip_remove_class="flex size-4 items-center justify-center border-0 bg-transparent p-0 text-inherit hover:bg-neutral-200 group-focus-within:hover:bg-neutral-700 dark:hover:bg-neutral-700 dark:group-focus-within:hover:bg-neutral-200"
        input_class="h-[calc(1.5rem-2px)] min-w-12 flex-1 border-0 bg-white p-0 text-sm dark:bg-neutral-950 font-normal text-neutral-950 outline-none placeholder:text-neutral-500 dark:placeholder:text-neutral-400 dark:text-white"
        popup_class="mt-1 w-64 max-w-[var(--available-width)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0_rgb(0_0_0_/_12%)] max-h-[24.5rem] overflow-y-auto overscroll-contain py-1 scroll-pt-1 scroll-pb-1 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none data-[closed]:hidden"
        item_class="group/item grid cursor-default grid-cols-[1rem_1fr] items-start gap-2 px-2 py-2 text-sm leading-[1.2rem] outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-neutral-950 data-[highlighted]:before:absolute data-[highlighted]:before:inset-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-100 dark:data-[highlighted]:text-white dark:data-[highlighted]:before:bg-neutral-800 data-[hidden]:hidden"
        indicator_class="col-start-1 mt-1 invisible group-data-[selected]/item:visible"
      >
        <:chip_remove_icon>
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-linecap="square"
            stroke-linejoin="round"
            style="display:block"
          >
            <path d="m4.5 4.5 7 7m-7 0 7-7" />
          </svg>
        </:chip_remove_icon>
        <:item_indicator>
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            style="display:block"
          >
            <path d="m2.5 8.5 4 4 7-9" />
          </svg>
        </:item_indicator>
        <:option :for={u <- @users} value={u.id}>
          <span class="col-start-2 flex flex-col gap-1">
            <span class="text-sm leading-5 font-bold">{u.name}</span>
            <span class="text-xs">{u.email}</span>
            <span class="flex flex-wrap gap-2 text-xs text-neutral-500 dark:text-neutral-400">
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

  def example(%{section: "context_menu-hero"} = assigns) do
    ~H"""
    <.context_menu
      id="baseui-context_menu-hero"
      trigger_class="flex h-[12rem] w-[15rem] items-center justify-center rounded-none border border-neutral-950 bg-white text-neutral-950 select-none font-normal dark:border-white dark:bg-neutral-950 dark:text-white"
      popup_class="origin-[var(--transform-origin)] border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
    >
      <:trigger>Right click here</:trigger>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Add to Library
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Add to Playlist
      </:item>
      <:item type="separator" class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Play Next
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Play Last
      </:item>
      <:item type="separator" class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Favorite
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Share
      </:item>
    </.context_menu>
    """
  end

  def example(%{section: "context_menu-submenu"} = assigns) do
    ~H"""
    <.context_menu
      id="baseui-context_menu-submenu"
      trigger_class="flex h-[12rem] w-[15rem] items-center justify-center rounded-none border border-neutral-950 bg-white text-neutral-950 select-none font-normal dark:border-white dark:bg-neutral-950 dark:text-white"
      popup_class="origin-[var(--transform-origin)] border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
    >
      <:trigger>Right click here</:trigger>
      <.context_menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Add to Library
      </.context_menu_item>
      <.context_menu_submenu
        id="baseui-context_menu-submenu-playlist"
        label="Add to Playlist"
        trigger_class="flex cursor-default items-center justify-between gap-4 py-2 pr-2 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400"
        popup_class="origin-[var(--transform-origin)] border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
      >
        <:chevron>
          <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block">
            <path d="M6 12V4l4.5 4z" />
          </svg>
        </:chevron>
        <.context_menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
          Get Up!
        </.context_menu_item>
        <.context_menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
          Inside Out
        </.context_menu_item>
        <.context_menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
          Night Beats
        </.context_menu_item>
        <.context_menu_separator class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
        <.context_menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
          New playlist…
        </.context_menu_item>
      </.context_menu_submenu>
      <.context_menu_separator class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
      <.context_menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Play Next
      </.context_menu_item>
      <.context_menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Play Last
      </.context_menu_item>
      <.context_menu_separator class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
      <.context_menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Favorite
      </.context_menu_item>
      <.context_menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Share
      </.context_menu_item>
    </.context_menu>
    """
  end

  def example(%{section: "dialog-hero"} = assigns) do
    ~H"""
    <.dialog
      id="baseui-dialog-hero"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      backdrop_class="fixed inset-0 min-h-dvh bg-black opacity-20 transition-opacity duration-150 data-[ending-style]:opacity-0 data-[starting-style]:opacity-0 dark:opacity-50 supports-[-webkit-touch-callout:none]:absolute"
      popup_class="fixed top-1/2 left-1/2 -mt-8 flex w-96 max-w-[calc(100vw-3rem)] -translate-x-1/2 -translate-y-1/2 flex-col gap-4 bg-white dark:bg-neutral-950 p-4 text-neutral-950 dark:text-white border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
      content_class="contents"
      title_class="text-base font-bold"
      description_class="text-sm text-neutral-600 dark:text-neutral-400"
      footer_class="flex justify-end gap-3"
    >
      <:trigger>View notifications</:trigger>
      <:title>Notifications</:title>
      <:description>You are all caught up. Good job!</:description>
      <:close>
        <button
          type="button"
          data-close
          class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
        >
          Close
        </button>
      </:close>
    </.dialog>
    """
  end

  def example(%{section: "dialog-nested"} = assigns) do
    ~H"""
    <.dialog
      id="baseui-dialog-nested-outer"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      backdrop_class="fixed inset-0 min-h-dvh bg-black opacity-20 transition-opacity duration-150 data-[ending-style]:opacity-0 data-[starting-style]:opacity-0 dark:opacity-50 supports-[-webkit-touch-callout:none]:absolute"
      popup_class="fixed top-[calc(50%+1.25rem*var(--nested-dialogs))] left-1/2 -mt-8 flex w-96 max-w-[calc(100vw-3rem)] -translate-x-1/2 -translate-y-1/2 flex-col gap-4 scale-[calc(1-0.1*var(--nested-dialogs))] bg-white dark:bg-neutral-950 p-4 text-neutral-950 dark:text-white border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[top,scale,opacity] duration-100 ease-out after:absolute after:inset-0 after:bg-black/5 after:opacity-0 after:transition-opacity after:duration-100 after:ease-out after:pointer-events-none data-[ending-style]:top-[calc(50%+0.25rem+1.25rem*var(--nested-dialogs))] data-[ending-style]:scale-[0.96] data-[ending-style]:opacity-0 data-[nested-dialog-open]:after:opacity-100 data-[starting-style]:top-[calc(50%+0.25rem+1.25rem*var(--nested-dialogs))] data-[starting-style]:scale-[0.96] data-[starting-style]:opacity-0"
      content_class="flex items-center gap-3"
      title_class="text-base font-bold"
      description_class="text-sm text-neutral-600 dark:text-neutral-400"
    >
      <:trigger>View notifications</:trigger>
      <:title>Notifications</:title>
      <:description>You are all caught up. Good job!</:description>
      <.dialog
        id="baseui-dialog-nested-inner"
        trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
        popup_class="fixed top-[calc(50%+1.25rem*var(--nested-dialogs))] left-1/2 -mt-8 flex w-96 max-w-[calc(100vw-3rem)] -translate-x-1/2 -translate-y-1/2 flex-col gap-4 scale-[calc(1-0.1*var(--nested-dialogs))] bg-white dark:bg-neutral-950 p-4 text-neutral-950 dark:text-white border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[top,scale,opacity] duration-100 ease-out after:absolute after:inset-0 after:bg-black/5 after:opacity-0 after:transition-opacity after:duration-100 after:ease-out after:pointer-events-none data-[ending-style]:top-[calc(50%+0.25rem+1.25rem*var(--nested-dialogs))] data-[ending-style]:scale-[0.96] data-[ending-style]:opacity-0 data-[nested-dialog-open]:after:opacity-100 data-[starting-style]:top-[calc(50%+0.25rem+1.25rem*var(--nested-dialogs))] data-[starting-style]:scale-[0.96] data-[starting-style]:opacity-0"
        modal="trap-focus"
        content_class="contents"
        title_class="text-base font-bold"
        description_class="text-sm text-neutral-600 dark:text-neutral-400"
        footer_class="flex items-center justify-end gap-3"
      >
        <:trigger>Customize</:trigger>
        <:title>Customize notifications</:title>
        <:description>Review your settings here.</:description>
        <:close>
          <button
            type="button"
            data-close
            class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
          >
            Close
          </button>
        </:close>
      </.dialog>
    </.dialog>
    """
  end

  def example(%{section: "dialog-uncontained"} = assigns) do
    ~H"""
    <.dialog
      id="baseui-dialog-uncontained"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      backdrop_class="fixed inset-0 min-h-dvh bg-black/20 dark:bg-black/50 transition-opacity duration-150 data-[starting-style]:opacity-0 data-[ending-style]:opacity-0 supports-[-webkit-touch-callout:none]:absolute"
      viewport_class="fixed inset-0 grid place-items-center px-4 py-12 xl:py-6"
      popup_class="group/popup relative flex h-full w-full max-w-[70rem] xl:max-w-none justify-center pointer-events-none transition-opacity duration-150 data-[starting-style]:opacity-0 data-[ending-style]:opacity-0"
      content_class="contents"
      footer_class="contents"
    >
      <:trigger>Open dialog</:trigger>
      <:close>
        <button
          type="button"
          data-close
          class="absolute right-0 -top-10 flex h-8 w-8 items-center justify-center border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 text-neutral-950 dark:text-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none hover:bg-neutral-100 dark:hover:bg-neutral-800 active:bg-neutral-200 dark:active:bg-neutral-700 xl:top-0 pointer-events-auto focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
          aria-label="Close"
        >
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-linecap="square"
            stroke-linejoin="round"
            style="display: block"
          >
            <path d="m2.5 2.5 11 11m-11 0 11-11" />
          </svg>
        </button>
      </:close>
      <div class="pointer-events-auto h-full w-full max-w-[70rem] bg-white dark:bg-neutral-950 p-4 text-neutral-950 dark:text-white border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[scale] duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] group-data-[starting-style]/popup:scale-105">
      </div>
    </.dialog>
    """
  end

  def example(%{section: "dialog-outside-scroll"} = assigns) do
    ~H"""
    <.dialog
      id="baseui-dialog-outside-scroll"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      backdrop_class="fixed inset-0 bg-black/20 dark:bg-black/50 transition-opacity duration-[600ms] data-[starting-style]:opacity-0 data-[ending-style]:opacity-0 data-[ending-style]:duration-[350ms] data-[ending-style]:ease-[cubic-bezier(0.375,0.015,0.545,0.455)] supports-[-webkit-touch-callout:none]:absolute"
      viewport_class="fixed inset-0 overflow-y-auto overscroll-contain flex min-h-full items-center justify-center"
      popup_class="outline-0 relative mx-auto my-16 flex w-[min(40rem,calc(100vw-2rem))] flex-col gap-4 bg-white dark:bg-neutral-950 p-4 text-neutral-950 dark:text-white border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[translate] duration-[700ms] ease-[cubic-bezier(0.45,1.005,0,1.005)] data-[starting-style]:translate-y-[100dvh] data-[ending-style]:translate-y-[max(100dvh,100%)] data-[ending-style]:duration-[350ms] data-[ending-style]:ease-[cubic-bezier(0.375,0.015,0.545,0.455)] motion-reduce:transition-none"
      content_class="contents"
      title_class="text-base font-bold pr-8"
      description_class="text-sm text-neutral-600 dark:text-neutral-400 pr-8"
      footer_class="contents"
    >
      <:trigger>Open dialog</:trigger>
      <:title>Dialog</:title>
      <:description>
        This layout keeps an outer container scrollable while the dialog can extend past the bottom edge.
      </:description>
      <:close>
        <button
          type="button"
          data-close
          aria-label="Close"
          class="absolute -top-1 -right-1 inline-flex items-center justify-center w-8 h-8 border-none bg-transparent p-0 text-neutral-950 dark:text-white hover:bg-neutral-100 dark:hover:bg-neutral-800 active:bg-neutral-200 dark:active:bg-neutral-700 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
        >
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-linecap="square"
            stroke-linejoin="round"
            style="display: block"
          >
            <path d="m2.5 2.5 11 11m-11 0 11-11" />
          </svg>
        </button>
      </:close>
      <div class="flex flex-col gap-4">
        <section
          :for={
            item <- [
              %{
                title: "What a dialog is for",
                body:
                  "Use a dialog when you need the user to complete a focused task or read something important without navigating away. It opens on top of the page and returns focus back where it started when closed."
              },
              %{
                title: "Anatomy at a glance",
                body:
                  "Root, Trigger, Portal, Backdrop, Viewport, Popup, Title, Description, Close. Keep the title short and the first paragraph specific so screen readers announce something meaningful."
              },
              %{
                title: "Opening and closing",
                body:
                  "Control it using external state via the `open` and `onOpenChange` props, or let it manage state for you internally."
              },
              %{
                title: "Keyboard and focus behavior",
                body:
                  "Focus moves inside the dialog when it opens. Tab and Shift+Tab loop within, and Esc requests close."
              },
              %{
                title: "Accessible labeling",
                body:
                  "Set an explicit title and description using the `Dialog.Title` and `Dialog.Description` components."
              },
              %{
                title: "Backdrop and page scrolling",
                body:
                  "The backdrop visually separates layers while background content is inert. Don't rely on dimness alone—keep copy clear and buttons obvious so actions are easy to choose."
              },
              %{
                title: "Portals and stacking",
                body:
                  "Dialogs render in a portal so they sit above the `isolation: isolate` app content and avoid local z-index wars."
              },
              %{
                title: "Viewport overflow",
                body:
                  "Let long content overflow the bottom edge and reveal as you scroll the page container. Keep generous padding at the top and bottom so the dialog doesn't feel jammed against the edges."
              },
              %{
                title: "Nested dialogs and confirmations",
                body:
                  "If closing a dialog needs confirmation, open a child alert dialog rather than mutating the current one. The parent stays visible behind it; only the topmost layer should feel interactive."
              },
              %{
                title: "Transitions that respect motion settings",
                body:
                  "Use small, fast transitions (opacity plus a few pixels of Y translation or scale). Subtle motion helps people notice what changed without slowing them down."
              },
              %{
                title: "Controlled vs. uncontrolled",
                body:
                  "Controlled state is best when other parts of the page need to react to open/close. Uncontrolled is fine for local cases where only the dialog matters."
              },
              %{
                title: "Close affordances",
                body:
                  "Always offer a visible close button in the corner. Don't rely only on Esc or the backdrop for pointer outside presses. Touch screen readers and accessibility users benefit from a clear, targetable control to click to close the dialog."
              },
              %{
                title: "Forms inside dialogs",
                body:
                  "Keep forms short; longer flows usually deserve a full page. Validate inline, keep button text specific (\"Create project\"), and disable destructive actions until the input is valid."
              },
              %{
                title: "Content guidelines",
                body:
                  "Lead with the outcome (\"Rename project?\") and follow with one or two short, concrete sentences. Avoid long prose; link out for details instead."
              },
              %{
                title: "SSR and hydration notes",
                body:
                  "Because dialogs render in a portal, make sure your portal container exists on the client."
              },
              %{
                title: "Mobile ergonomics",
                body:
                  "Use larger touch targets and keep the close button reachable with the thumb. Avoid full-screen modals unless the task truly needs a whole screen."
              },
              %{
                title: "Theming and density",
                body:
                  "Match spacing and corner radius to your system. Use a slightly denser layout than pages so the dialog feels purpose-built, not like a mini web page."
              },
              %{
                title: "Internationalization",
                body:
                  "Plan for longer text. Buttons can grow to two lines; titles should wrap gracefully. Keep destructive terms consistent across locales."
              },
              %{
                title: "Performance",
                body:
                  "Children are mounted lazily when the dialog opens. If the dialog can reopen often, consider the `keepMounted` prop sparingly to perform the work only once on mount to avoid re-initializing complex React trees on each open."
              },
              %{
                title: "When a popover is better",
                body:
                  "If the content is a small hint or a few quick actions anchored to a control, use a popover or menu instead of a dialog. Dialogs interrupt on purpose—use that sparingly."
              },
              %{
                title: "Follow-up and cleanup",
                body:
                  "After a successful action, close the dialog and show confirmation in context (toast, inline message, or updated UI) so people can see the result of what they just did."
              }
            ]
          }
          class="flex flex-col gap-1"
        >
          <h3 class="text-sm font-bold">{item.title}</h3>
          <p class="text-sm text-neutral-700 dark:text-neutral-300">{item.body}</p>
        </section>
      </div>
      <p class="text-sm text-neutral-600 dark:text-neutral-400">
        Related docs: <a
          class="text-neutral-950 dark:text-white underline underline-offset-[0.16em] decoration-[1px] hover:no-underline focus-visible:outline-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white focus-visible:outline-offset-2"
          href="#"
        >
          Scroll Area
        </a>, <a
          class="text-neutral-950 dark:text-white underline underline-offset-[0.16em] decoration-[1px] hover:no-underline focus-visible:outline-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white focus-visible:outline-offset-2"
          href="#"
        >
          Drawer
        </a>, <a
          class="text-neutral-950 dark:text-white underline underline-offset-[0.16em] decoration-[1px] hover:no-underline focus-visible:outline-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white focus-visible:outline-offset-2"
          href="#"
        >
          Popover
        </a>.
      </p>
    </.dialog>
    """
  end

  def example(%{section: "dialog-inside-scroll"} = assigns) do
    ~H"""
    <.dialog
      id="baseui-dialog-inside-scroll"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      backdrop_class="fixed inset-0 bg-black opacity-20 transition-opacity duration-150 data-[starting-style]:opacity-0 data-[ending-style]:opacity-0 dark:opacity-50 supports-[-webkit-touch-callout:none]:absolute"
      viewport_class="fixed inset-0 flex items-center justify-center overflow-hidden py-6 [@media(min-height:600px)]:pb-12 [@media(min-height:600px)]:pt-8"
      popup_class="relative flex w-[min(40rem,calc(100vw-2rem))] max-h-full max-w-full min-h-0 flex-col bg-white dark:bg-neutral-950 text-neutral-950 dark:text-white border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[scale,opacity] duration-100 ease-out data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0"
      title_class="text-base font-bold p-4 pb-1 border-b-0"
      description_class="text-sm text-neutral-600 dark:text-neutral-400 px-4 pb-4 border-b border-neutral-950 dark:border-white"
      content_class="flex min-h-0 flex-auto flex-col overflow-y-auto overscroll-contain"
      footer_class="flex justify-end gap-3 p-4 border-t border-neutral-950 dark:border-white"
    >
      <:trigger>Open dialog</:trigger>
      <:title>Dialog</:title>
      <:description>
        This layout keeps the popup fully on screen while allowing its content to scroll.
      </:description>
      <section
        :for={
          item <- [
            %{
              title: "What a dialog is for",
              body:
                "Use a dialog when you need the user to complete a focused task or read something important without navigating away. It opens on top of the page and returns focus back where it started when closed."
            },
            %{
              title: "Anatomy at a glance",
              body:
                "Root, Trigger, Portal, Backdrop, Popup, Title/Description, Close. Keep the title short and the first paragraph specific so screen readers announce something meaningful."
            },
            %{
              title: "Opening and closing",
              body:
                "Control it using external state via the `open` and `onOpenChange` props, or let it manage state for you internally."
            },
            %{
              title: "Keyboard and focus behavior",
              body:
                "Focus moves inside the dialog when it opens. Tab and Shift+Tab loop within, and Esc requests close."
            },
            %{
              title: "Accessible labeling",
              body:
                "Set an explicit title and description using the `Dialog.Title` and `Dialog.Description` components."
            },
            %{
              title: "Backdrop and page scrolling",
              body:
                "The backdrop visually separates layers while background content is inert. Don't rely on dimness alone—keep copy clear and buttons obvious so actions are easy to choose."
            },
            %{
              title: "Portals and stacking",
              body:
                "Dialogs render in a portal so they sit above the `isolation: isolate` app content and avoid local z-index wars."
            },
            %{
              title: "Viewport overflow",
              body:
                "Let long content overflow the bottom edge and reveal as you scroll the page container. Keep generous padding at the top and bottom so the dialog doesn't feel jammed against the edges."
            },
            %{
              title: "Nested dialogs and confirmations",
              body:
                "If closing a dialog needs confirmation, open a child alert dialog rather than mutating the current one. The parent stays visible behind it; only the topmost layer should feel interactive."
            },
            %{
              title: "Transitions that respect motion settings",
              body:
                "Use small, fast transitions (opacity plus a few pixels of Y translation or scale). Subtle motion helps people notice what changed without slowing them down."
            },
            %{
              title: "Controlled vs. uncontrolled",
              body:
                "Controlled state is best when other parts of the page need to react to open/close. Uncontrolled is fine for local cases where only the dialog matters."
            },
            %{
              title: "Close affordances",
              body:
                "Always offer a visible close button in the corner. Don't rely only on Esc or the backdrop for pointer outside presses. Touch screen readers and accessibility users benefit from a clear, targetable control to click to close the dialog."
            },
            %{
              title: "Forms inside dialogs",
              body:
                "Keep forms short; longer flows usually deserve a full page. Validate inline, keep button text specific (\"Create project\"), and disable destructive actions until the input is valid."
            },
            %{
              title: "Content guidelines",
              body:
                "Lead with the outcome (\"Rename project?\") and follow with one or two short, concrete sentences. Avoid long prose; link out for details instead."
            },
            %{
              title: "SSR and hydration notes",
              body:
                "Because dialogs render in a portal, make sure your portal container exists on the client."
            },
            %{
              title: "Mobile ergonomics",
              body:
                "Use larger touch targets and keep the close button reachable with the thumb. Avoid full-screen modals unless the task truly needs a whole screen."
            },
            %{
              title: "Theming and density",
              body:
                "Match spacing and corner radius to your system. Use a slightly denser layout than pages so the dialog feels purpose-built, not like a mini web page."
            },
            %{
              title: "Internationalization",
              body:
                "Plan for longer text. Buttons can grow to two lines; titles should wrap gracefully. Keep destructive terms consistent across locales."
            },
            %{
              title: "Performance",
              body:
                "Children are mounted lazily when the dialog opens. If the dialog can reopen often, consider the `keepMounted` prop sparingly to perform the work only once on mount to avoid re-initializing complex React trees on each open."
            },
            %{
              title: "When a popover is better",
              body:
                "If the content is a small hint or a few quick actions anchored to a control, use a popover or menu instead of a dialog. Dialogs interrupt on purpose—use that sparingly."
            },
            %{
              title: "Follow-up and cleanup",
              body:
                "After a successful action, close the dialog and show confirmation in context (toast, inline message, or updated UI) so people can see the result of what they just did."
            }
          ]
        }
        class="flex flex-col gap-1 p-4"
      >
        <h3 class="text-sm font-bold">{item.title}</h3>
        <p class="text-sm text-neutral-700 dark:text-neutral-300">{item.body}</p>
      </section>
      <:close>
        <button
          type="button"
          data-close
          class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
        >
          Close
        </button>
      </:close>
    </.dialog>
    """
  end

  def example(%{section: "dialog-close-confirmation"} = assigns) do
    ~H"""
    <.dialog
      id="baseui-dialog-close-confirmation"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      backdrop_class="fixed inset-0 min-h-dvh bg-black opacity-20 transition-opacity duration-150 data-[ending-style]:opacity-0 data-[starting-style]:opacity-0 dark:opacity-50 supports-[-webkit-touch-callout:none]:absolute"
      popup_class="fixed top-[calc(50%+1.25rem*var(--nested-dialogs))] left-1/2 -mt-8 flex w-96 max-w-[calc(100vw-3rem)] -translate-x-1/2 -translate-y-1/2 flex-col gap-1 scale-[calc(1-0.1*var(--nested-dialogs))] bg-white dark:bg-neutral-950 p-4 text-neutral-950 dark:text-white border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[top,scale,opacity] duration-100 ease-out after:absolute after:inset-0 after:bg-black/5 after:opacity-0 after:transition-opacity after:duration-100 after:ease-out after:pointer-events-none data-[ending-style]:top-[calc(50%+0.25rem+1.25rem*var(--nested-dialogs))] data-[ending-style]:scale-[0.96] data-[ending-style]:opacity-0 data-[nested-dialog-open]:after:opacity-100 data-[starting-style]:top-[calc(50%+0.25rem+1.25rem*var(--nested-dialogs))] data-[starting-style]:scale-[0.96] data-[starting-style]:opacity-0"
      content_class="contents"
      title_class="text-base font-bold"
    >
      <:trigger>Tweet</:trigger>
      <:title>New tweet</:title>
      <form class="flex flex-col gap-4">
        <textarea
          aria-labelledby="baseui-dialog-close-confirmation-title"
          required
          class="min-h-32 w-full border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 p-2 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 dark:text-white placeholder:text-neutral-500 dark:placeholder:text-neutral-400 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white"
          placeholder="What's on your mind?"
        ></textarea>
        <div class="flex justify-end gap-3">
          <button
            type="button"
            data-close
            class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
          >
            Cancel
          </button>
          <button
            type="submit"
            class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:bg-neutral-100 dark:hover:bg-neutral-800 active:bg-neutral-200 dark:active:bg-neutral-700 disabled:border-neutral-500 disabled:text-neutral-500 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
          >
            Tweet
          </button>
        </div>
      </form>
    </.dialog>
    """
  end

  def example(%{section: "dialog-detached-triggers-simple"} = assigns) do
    ~H"""
    <.dialog
      id="baseui-dialog-detached-triggers-simple"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      backdrop_class="fixed inset-0 min-h-dvh bg-black opacity-20 transition-opacity duration-150 data-[ending-style]:opacity-0 data-[starting-style]:opacity-0 dark:opacity-50 supports-[-webkit-touch-callout:none]:absolute"
      popup_class="fixed top-1/2 left-1/2 -mt-8 flex w-96 max-w-[calc(100vw-3rem)] -translate-x-1/2 -translate-y-1/2 flex-col gap-4 bg-white dark:bg-neutral-950 p-4 text-neutral-950 dark:text-white border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
      content_class="contents"
      title_class="text-base font-bold"
      description_class="text-sm text-neutral-600 dark:text-neutral-400"
      footer_class="flex justify-end gap-3"
    >
      <:trigger>View notifications</:trigger>
      <:title>Notifications</:title>
      <:description>You are all caught up. Good job!</:description>
      <:close>
        <button
          type="button"
          data-close
          class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
        >
          Close
        </button>
      </:close>
    </.dialog>
    """
  end

  def example(%{section: "dialog-detached-triggers-controlled"} = assigns) do
    ~H"""
    <.dialog
      id="baseui-dialog-detached-triggers-controlled"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      backdrop_class="fixed inset-0 min-h-dvh bg-black opacity-20 transition-opacity duration-150 data-[ending-style]:opacity-0 data-[starting-style]:opacity-0 dark:opacity-50 supports-[-webkit-touch-callout:none]:absolute"
      popup_class="fixed top-1/2 left-1/2 -mt-8 flex w-96 max-w-[calc(100vw-3rem)] -translate-x-1/2 -translate-y-1/2 flex-col gap-4 bg-white dark:bg-neutral-950 p-4 text-neutral-950 dark:text-white border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
      content_class="contents"
      title_class="text-base font-bold"
      footer_class="flex justify-end gap-3"
    >
      <:trigger>Open 1</:trigger>
      <:title>Dialog 1</:title>
      <:close>
        <button
          type="button"
          data-close
          class="flex h-8 items-center justify-center gap-2 border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
        >
          Close
        </button>
      </:close>
    </.dialog>
    """
  end

  def example(%{section: "drawer-hero"} = assigns) do
    ~H"""
    <.drawer
      id="baseui-drawer-hero"
      side="right"
      swipe_direction="right"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      backdrop_class="[--backdrop-opacity:0.2] [--bleed:3rem] dark:[--backdrop-opacity:0.7] fixed inset-0 min-h-dvh bg-black opacity-[calc(var(--backdrop-opacity)*(1-var(--drawer-swipe-progress)))] transition-opacity duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] data-[swiping]:duration-0 data-[ending-style]:opacity-0 data-[starting-style]:opacity-0 data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)] supports-[-webkit-touch-callout:none]:absolute"
      viewport_class="[--viewport-padding:0px] supports-[-webkit-touch-callout:none]:[--viewport-padding:0.625rem] fixed inset-0 flex items-stretch justify-end p-(--viewport-padding)"
      popup_class="[--bleed:3rem] supports-[-webkit-touch-callout:none]:[--bleed:0px] h-full w-[calc(20rem+3rem)] max-w-[calc(100vw-3rem+3rem)] -mr-[3rem] border-l border-neutral-950 bg-white p-6 pr-[calc(1.5rem+3rem)] text-neutral-950 outline-none shadow-[0.25rem_0.25rem_0] shadow-black/12 overflow-y-auto overscroll-contain touch-auto [transform:translateX(var(--drawer-swipe-movement-x))] transition-transform duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] data-[swiping]:select-none data-[ending-style]:[transform:translateX(calc(100%-var(--bleed)+var(--viewport-padding)+2px))] data-[starting-style]:[transform:translateX(calc(100%-var(--bleed)+var(--viewport-padding)+2px))] data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)] supports-[-webkit-touch-callout:none]:mr-0 supports-[-webkit-touch-callout:none]:w-[20rem] supports-[-webkit-touch-callout:none]:max-w-[calc(100vw-3rem)] supports-[-webkit-touch-callout:none]:border supports-[-webkit-touch-callout:none]:pr-6 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
      content_class="mx-auto w-full max-w-[32rem]"
      title_class="mb-1 text-base font-bold"
      description_class="mb-6 text-sm text-neutral-600 dark:text-neutral-400"
      footer_class="flex justify-end gap-3"
    >
      <:trigger>Open drawer</:trigger>
      <:title>Drawer</:title>
      <:description>
        This is a drawer that slides in from the side. You can swipe to dismiss it.
      </:description>
      <:close>
        <button
          type="button"
          data-close
          class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
        >
          Close
        </button>
      </:close>
    </.drawer>
    """
  end

  def example(%{section: "drawer-mobile-nav"} = assigns) do
    ~H"""
    <.drawer
      id="baseui-drawer-mobile-nav"
      side="bottom"
      swipe_direction="down"
      labelledby="baseui-drawer-mobile-nav-title"
      describedby="baseui-drawer-mobile-nav-desc"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      backdrop_class="[--backdrop-opacity:1] dark:[--backdrop-opacity:0.7] fixed inset-0 min-h-dvh bg-[linear-gradient(to_bottom,rgb(0_0_0/5%)_0,rgb(0_0_0/10%)_50%)] opacity-[calc(var(--backdrop-opacity)*(1-var(--drawer-swipe-progress)))] transition-opacity duration-600 ease-[var(--ease-out-fast)] supports-[-webkit-touch-callout:none]:absolute data-[starting-style]:opacity-0 data-[ending-style]:opacity-0 data-[ending-style]:duration-350 data-[ending-style]:ease-[cubic-bezier(0.375,0.015,0.545,0.455)]"
      viewport_class="group fixed inset-0 flex min-h-full items-end justify-center overflow-y-auto pt-8 transition-transform duration-600 ease-[cubic-bezier(0.45,1.005,0,1.005)] group-data-[starting-style]:translate-y-[100dvh] min-[42rem]:px-16 min-[42rem]:py-16"
      popup_class="group w-full max-w-[42rem] outline-none transition-transform duration-600 ease-[cubic-bezier(0.45,1.005,0,1.005)] [transform:translateY(var(--drawer-swipe-movement-y))] data-[swiping]:select-none data-[ending-style]:[transform:translateY(calc(max(100dvh,100%)+2px))] data-[ending-style]:duration-350 data-[ending-style]:ease-[cubic-bezier(0.375,0.015,0.545,0.455)] motion-reduce:transition-none"
      content_class="w-full"
    >
      <:trigger>Open mobile menu</:trigger>
      <nav
        aria-label="Navigation"
        class="relative flex flex-col border-t border-neutral-950 bg-white px-6 pt-4 pb-6 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-shadow duration-350 ease-[cubic-bezier(0.375,0.015,0.545,0.455)] group-data-[ending-style]:shadow-[0.25rem_0.25rem_0] group-data-[ending-style]:shadow-black/0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none min-[42rem]:border"
      >
        <div class="grid grid-cols-[1fr_auto_1fr] items-start">
          <div aria-hidden="true" class="h-9 w-9"></div>
          <div class="h-1 w-12 justify-self-center bg-neutral-300 dark:bg-neutral-700"></div>
          <button
            type="button"
            data-close
            aria-label="Close menu"
            class="flex h-8 w-8 items-center justify-center justify-self-end border-0 bg-transparent text-neutral-950 hover:bg-neutral-100 active:bg-neutral-200 dark:text-white dark:hover:bg-neutral-800 dark:active:bg-neutral-700 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
          >
            <svg
              width="16"
              height="16"
              viewBox="0 0 16 16"
              fill="none"
              stroke="currentColor"
              stroke-linecap="square"
              stroke-linejoin="round"
              style="display: block"
            >
              <path d="m2.5 2.5 11 11m-11 0 11-11" />
            </svg>
          </button>
        </div>
        <h2 id="baseui-drawer-mobile-nav-title" class="m-0 mb-1 text-base font-bold">Menu</h2>
        <p
          id="baseui-drawer-mobile-nav-desc"
          class="m-0 mb-5 text-sm text-neutral-600 dark:text-neutral-400"
        >
          Scroll the long list. Flick down from the top to dismiss.
        </p>
        <div class="pb-8">
          <ul class="grid list-none gap-1 p-0 m-0">
            <li
              :for={
                item <- [
                  {"/react/overview", "Overview"},
                  {"/react/components", "Components"},
                  {"/react/utils", "Utilities"},
                  {"/react/overview/releases", "Releases"}
                ]
              }
              class="flex"
            >
              <a
                class="flex h-12 w-full items-center border border-neutral-950 bg-white px-4 text-sm text-neutral-950 no-underline hover:bg-neutral-100 active:bg-neutral-200 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:bg-neutral-800 dark:active:bg-neutral-700 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
                href={elem(item, 0)}
              >
                {elem(item, 1)}
              </a>
            </li>
          </ul>
          <ul aria-label="Component links" class="mt-6 grid list-none gap-1 p-0 m-0">
            <li
              :for={
                item <- [
                  {"/react/components/accordion", "Accordion"},
                  {"/react/components/alert-dialog", "Alert Dialog"},
                  {"/react/components/autocomplete", "Autocomplete"},
                  {"/react/components/avatar", "Avatar"},
                  {"/react/components/button", "Button"},
                  {"/react/components/checkbox", "Checkbox"},
                  {"/react/components/checkbox-group", "Checkbox Group"},
                  {"/react/components/collapsible", "Collapsible"},
                  {"/react/components/combobox", "Combobox"},
                  {"/react/components/context-menu", "Context Menu"},
                  {"/react/components/dialog", "Dialog"},
                  {"/react/components/drawer", "Drawer"},
                  {"/react/components/field", "Field"},
                  {"/react/components/fieldset", "Fieldset"},
                  {"/react/components/form", "Form"},
                  {"/react/components/input", "Input"},
                  {"/react/components/menu", "Menu"},
                  {"/react/components/menubar", "Menubar"},
                  {"/react/components/meter", "Meter"},
                  {"/react/components/navigation-menu", "Navigation Menu"},
                  {"/react/components/number-field", "Number Field"},
                  {"/react/components/otp-field", "OTP Field"},
                  {"/react/components/popover", "Popover"},
                  {"/react/components/preview-card", "Preview Card"},
                  {"/react/components/progress", "Progress"},
                  {"/react/components/radio", "Radio"},
                  {"/react/components/scroll-area", "Scroll Area"},
                  {"/react/components/select", "Select"},
                  {"/react/components/separator", "Separator"},
                  {"/react/components/slider", "Slider"},
                  {"/react/components/switch", "Switch"},
                  {"/react/components/tabs", "Tabs"},
                  {"/react/components/toast", "Toast"},
                  {"/react/components/toggle", "Toggle"},
                  {"/react/components/toggle-group", "Toggle Group"},
                  {"/react/components/toolbar", "Toolbar"},
                  {"/react/components/tooltip", "Tooltip"}
                ]
              }
              class="flex"
            >
              <a
                class="flex h-12 w-full items-center border border-neutral-950 bg-white px-4 text-sm text-neutral-950 no-underline hover:bg-neutral-100 active:bg-neutral-200 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:bg-neutral-800 dark:active:bg-neutral-700 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
                href={elem(item, 0)}
              >
                {elem(item, 1)}
              </a>
            </li>
          </ul>
        </div>
      </nav>
    </.drawer>
    """
  end

  def example(%{section: "drawer-nested"} = assigns) do
    ~H"""
    <.drawer
      id="baseui-drawer-nested"
      side="bottom"
      swipe_direction="down"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      backdrop_class="[--backdrop-opacity:0.2] [--bleed:3rem] dark:[--backdrop-opacity:0.7] fixed inset-0 min-h-dvh bg-black opacity-[calc(var(--backdrop-opacity)*(1-var(--drawer-swipe-progress)))] transition-opacity duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] data-[swiping]:duration-0 data-[ending-style]:opacity-0 data-[starting-style]:opacity-0 data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)] supports-[-webkit-touch-callout:none]:absolute"
      viewport_class="fixed inset-0 flex items-end justify-center"
      popup_class="[--bleed:3rem] relative -mx-px -mb-[3rem] w-[calc(100%+2px)] max-h-[calc(80vh+3rem)] border border-neutral-950 border-b-0 bg-white px-6 pt-4 pb-[calc(1.5rem+env(safe-area-inset-bottom,0px)+3rem)] text-neutral-950 outline-none shadow-[0.25rem_0.25rem_0] shadow-black/12 overflow-y-auto overscroll-contain touch-auto [transform:translateY(var(--drawer-swipe-movement-y))] transition-transform duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] data-[swiping]:select-none data-[starting-style]:[transform:translateY(calc(100%-var(--bleed)+2px))] data-[ending-style]:[transform:translateY(calc(100%-var(--bleed)+2px))] data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)] dark:border-white dark:border-b-0 dark:bg-neutral-950 dark:text-white dark:shadow-none"
      handle_class="mx-auto mb-4 h-1 w-12 bg-neutral-300 dark:bg-neutral-700"
      content_class="mx-auto w-full max-w-[32rem]"
      title_class="mb-1 text-base font-bold text-center"
      description_class="mb-6 text-sm text-neutral-600 text-center dark:text-neutral-400"
    >
      <:trigger>Open drawer stack</:trigger>
      <:handle></:handle>
      <:title>Account</:title>
      <:description>
        Nested drawers can be styled to stack, while each drawer remains independently focus managed.
      </:description>
      <div class="flex items-center justify-end gap-4">
        <div class="mr-auto">
          <.drawer
            id="baseui-drawer-nested-security"
            side="bottom"
            swipe_direction="down"
            modal={false}
            trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
            viewport_class="fixed inset-0 flex items-end justify-center"
            popup_class="[--bleed:3rem] relative -mx-px -mb-[3rem] w-[calc(100%+2px)] max-h-[calc(80vh+3rem)] border border-neutral-950 border-b-0 bg-white px-6 pt-4 pb-[calc(1.5rem+3rem)] text-neutral-950 outline-none shadow-[0.25rem_0.25rem_0] shadow-black/12 overflow-y-auto overscroll-contain touch-auto [transform:translateY(var(--drawer-swipe-movement-y))] transition-transform duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] data-[swiping]:select-none data-[starting-style]:[transform:translateY(calc(100%-var(--bleed)+2px))] data-[ending-style]:[transform:translateY(calc(100%-var(--bleed)+2px))] data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)] dark:border-white dark:border-b-0 dark:bg-neutral-950 dark:text-white dark:shadow-none"
            handle_class="mx-auto mb-4 h-1 w-12 bg-neutral-300 dark:bg-neutral-700"
            content_class="mx-auto w-full max-w-[32rem]"
            title_class="mb-1 text-base font-bold text-center"
            description_class="mb-6 text-sm text-neutral-600 text-center dark:text-neutral-400"
          >
            <:trigger>Security settings</:trigger>
            <:handle></:handle>
            <:title>Security</:title>
            <:description>Review sign-in activity and update your security preferences.</:description>
            <ul class="mb-6 list-disc pl-5 text-neutral-700 dark:text-neutral-300">
              <li>Passkeys enabled</li>
              <li>2FA via authenticator app</li>
              <li>3 signed-in devices</li>
            </ul>
            <div class="flex items-center justify-end gap-4">
              <div class="mr-auto">
                <.drawer
                  id="baseui-drawer-nested-advanced"
                  side="bottom"
                  swipe_direction="down"
                  modal={false}
                  trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
                  viewport_class="fixed inset-0 flex items-end justify-center"
                  popup_class="[--bleed:3rem] relative -mx-px -mb-[3rem] w-[calc(100%+2px)] max-h-[calc(80vh+3rem)] border border-neutral-950 border-b-0 bg-white px-6 pt-4 pb-[calc(1.5rem+3rem)] text-neutral-950 outline-none shadow-[0.25rem_0.25rem_0] shadow-black/12 overflow-y-auto overscroll-contain touch-auto [transform:translateY(var(--drawer-swipe-movement-y))] transition-transform duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] data-[swiping]:select-none data-[starting-style]:[transform:translateY(calc(100%-var(--bleed)+2px))] data-[ending-style]:[transform:translateY(calc(100%-var(--bleed)+2px))] data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)] dark:border-white dark:border-b-0 dark:bg-neutral-950 dark:text-white dark:shadow-none"
                  handle_class="mx-auto mb-4 h-1 w-12 bg-neutral-300 dark:bg-neutral-700"
                  content_class="mx-auto w-full max-w-[32rem]"
                  title_class="mb-1 text-base font-bold text-center"
                  description_class="mb-6 text-sm text-neutral-600 text-center dark:text-neutral-400"
                >
                  <:trigger>Advanced options</:trigger>
                  <:handle></:handle>
                  <:title>Advanced</:title>
                  <:description>
                    This drawer is taller to demonstrate variable-height stacking.
                  </:description>
                  <div class="grid gap-2 mb-4">
                    <label
                      class="text-sm font-bold text-neutral-700 dark:text-neutral-300"
                      for="device-name-tw"
                    >
                      Device name
                    </label>
                    <input
                      id="device-name-tw"
                      class="h-8 w-full border border-neutral-950 bg-white px-2 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 dark:border-white dark:bg-neutral-950 dark:text-white focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
                      value="Personal laptop"
                    />
                  </div>
                  <div class="grid gap-2 mb-4">
                    <label
                      class="text-sm font-bold text-neutral-700 dark:text-neutral-300"
                      for="notes-tw"
                    >
                      Notes
                    </label>
                    <textarea
                      id="notes-tw"
                      class="min-h-32 w-full resize-y border border-neutral-950 bg-white p-2 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 dark:border-white dark:bg-neutral-950 dark:text-white focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
                      rows="3"
                    >Rotate recovery codes and revoke older sessions.</textarea>
                  </div>
                  <:close>
                    <div class="flex justify-end">
                      <button
                        type="button"
                        data-close
                        class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
                      >
                        Done
                      </button>
                    </div>
                  </:close>
                </.drawer>
              </div>
              <button
                type="button"
                data-close
                class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
              >
                Close
              </button>
            </div>
          </.drawer>
        </div>
        <button
          type="button"
          data-close
          class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
        >
          Close
        </button>
      </div>
    </.drawer>
    """
  end

  def example(%{section: "drawer-non-modal"} = assigns) do
    ~H"""
    <.drawer
      id="baseui-drawer-non-modal"
      side="right"
      swipe_direction="right"
      modal={false}
      dismissible={false}
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      viewport_class="[--viewport-padding:0px] supports-[-webkit-touch-callout:none]:[--viewport-padding:0.625rem] fixed inset-0 flex items-stretch justify-end p-(--viewport-padding) pointer-events-none"
      popup_class="[--bleed:3rem] supports-[-webkit-touch-callout:none]:[--bleed:0px] pointer-events-auto h-full w-[calc(20rem+3rem)] max-w-[calc(100vw-3rem+3rem)] -mr-[3rem] border-l border-neutral-950 bg-white p-6 pr-[calc(1.5rem+3rem)] text-neutral-950 outline-none shadow-[0.25rem_0.25rem_0] shadow-black/12 overflow-y-auto overscroll-contain touch-auto [transform:translateX(var(--drawer-swipe-movement-x))] transition-[transform,box-shadow] duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] data-[swiping]:select-none data-[ending-style]:shadow-[0.25rem_0.25rem_0] data-[ending-style]:shadow-black/0 data-[ending-style]:[transform:translateX(calc(100%-var(--bleed)+var(--viewport-padding)+2px))] data-[starting-style]:shadow-[0.25rem_0.25rem_0] data-[starting-style]:shadow-black/0 data-[starting-style]:[transform:translateX(calc(100%-var(--bleed)+var(--viewport-padding)+2px))] data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)] supports-[-webkit-touch-callout:none]:mr-0 supports-[-webkit-touch-callout:none]:w-[20rem] supports-[-webkit-touch-callout:none]:max-w-[calc(100vw-3rem)] supports-[-webkit-touch-callout:none]:border supports-[-webkit-touch-callout:none]:pr-6 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
      content_class="mx-auto w-full max-w-[32rem]"
      title_class="mb-1 text-base font-bold"
      description_class="mb-6 text-sm text-neutral-600 dark:text-neutral-400"
      footer_class="flex justify-end gap-3"
    >
      <:trigger>Open non-modal drawer</:trigger>
      <:title>Non-modal drawer</:title>
      <:description>
        This drawer does not trap focus and ignores outside clicks. Use the close button or swipe to dismiss it.
      </:description>
      <:close>
        <button
          type="button"
          data-close
          class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
        >
          Close
        </button>
      </:close>
    </.drawer>
    """
  end

  def example(%{section: "drawer-position"} = assigns) do
    ~H"""
    <.drawer
      id="baseui-drawer-position"
      side="bottom"
      swipe_direction="down"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      backdrop_class="[--backdrop-opacity:0.2] [--bleed:3rem] dark:[--backdrop-opacity:0.7] fixed inset-0 min-h-dvh bg-black opacity-[calc(var(--backdrop-opacity)*(1-var(--drawer-swipe-progress)))] transition-opacity duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] data-[swiping]:duration-0 data-[ending-style]:opacity-0 data-[starting-style]:opacity-0 data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)] supports-[-webkit-touch-callout:none]:absolute"
      viewport_class="fixed inset-0 flex items-end justify-center"
      popup_class="-mb-[3rem] w-full max-h-[calc(80vh+3rem)] border-t border-neutral-950 bg-white px-6 pb-[calc(1.5rem+env(safe-area-inset-bottom,0px)+3rem)] pt-4 text-neutral-950 outline-none shadow-[0.25rem_0.25rem_0] shadow-black/12 overflow-y-auto overscroll-contain touch-auto [transform:translateY(var(--drawer-swipe-movement-y))] transition-transform duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] data-[swiping]:select-none data-[ending-style]:[transform:translateY(calc(100%-3rem+2px))] data-[starting-style]:[transform:translateY(calc(100%-3rem+2px))] data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)] dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
      handle_class="mx-auto mb-4 h-1 w-12 bg-neutral-300 dark:bg-neutral-700"
      content_class="mx-auto w-full max-w-[32rem]"
      title_class="mb-1 text-base font-bold text-center"
      description_class="mb-6 text-sm text-neutral-600 text-center dark:text-neutral-400"
      footer_class="flex justify-center gap-3"
    >
      <:trigger>Open bottom drawer</:trigger>
      <:handle></:handle>
      <:title>Notifications</:title>
      <:description>You are all caught up. Good job!</:description>
      <:close>
        <button
          type="button"
          data-close
          class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
        >
          Close
        </button>
      </:close>
    </.drawer>
    """
  end

  def example(%{section: "drawer-snap-points"} = assigns) do
    ~H"""
    <.drawer
      id="baseui-drawer-snap-points"
      side="bottom"
      swipe_direction="down"
      snap_points={["31rem", 1]}
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      backdrop_class="[--backdrop-opacity:0.2] [--bleed:3rem] dark:[--backdrop-opacity:0.7] fixed inset-0 min-h-dvh bg-black opacity-[calc(var(--backdrop-opacity)*(1-var(--drawer-swipe-progress)))] transition-opacity duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] data-[swiping]:duration-0 data-[ending-style]:opacity-0 data-[starting-style]:opacity-0 data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)] supports-[-webkit-touch-callout:none]:absolute"
      viewport_class="fixed inset-0 flex items-end justify-center touch-none [--bleed:3rem] [--top-margin:1rem] after:pointer-events-none after:fixed after:inset-x-0 after:bottom-0 after:h-[var(--bleed)] after:bg-white after:content-[''] data-[closed]:after:opacity-0 dark:after:bg-neutral-950"
      popup_class="relative z-1 flex w-full max-h-[calc(100dvh-var(--top-margin))] min-h-0 flex-col overflow-visible border-t border-neutral-950 bg-white text-neutral-950 outline-none touch-none shadow-[0.25rem_0.25rem_0] shadow-black/12 [padding-bottom:max(0px,calc(var(--drawer-snap-point-offset)+var(--drawer-swipe-movement-y)))] [transform:translateY(calc(var(--drawer-snap-point-offset)+var(--drawer-swipe-movement-y)))] transition-[transform,box-shadow] duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] after:pointer-events-none after:absolute after:inset-x-0 after:top-full after:h-[var(--bleed)] after:bg-[inherit] after:content-[''] data-[swiping]:select-none data-[ending-style]:[transform:translateY(calc(100%+2px))] data-[starting-style]:[transform:translateY(calc(100%+2px))] data-[starting-style]:[padding-bottom:0] data-[ending-style]:[padding-bottom:0] data-[starting-style]:shadow-[0.25rem_0.25rem_0] data-[starting-style]:shadow-black/0 data-[ending-style]:shadow-[0.25rem_0.25rem_0] data-[ending-style]:shadow-black/0 data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)] dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
      handle_class="shrink-0 border-b border-neutral-300 px-6 pt-3.5 pb-4 touch-none dark:border-neutral-700"
      title_class="cursor-default text-center text-base font-bold"
      content_class="min-h-0 flex-1 overflow-y-auto overscroll-contain touch-auto px-6 pt-4 pb-[calc(1.5rem+env(safe-area-inset-bottom,0px))]"
    >
      <:trigger>Open snap drawer</:trigger>
      <:handle>
        <div class="mx-auto mb-2.5 h-1 w-12 shrink-0 bg-neutral-300 dark:bg-neutral-700"></div>
        <h2 class="cursor-default text-center text-base font-bold">Snap points</h2>
      </:handle>
      <div class="mx-auto w-full max-w-90">
        <p class="mb-4 text-sm text-neutral-600 text-center dark:text-neutral-400">
          Drag the sheet to snap between a compact peek and a near full-height view.
        </p>
        <div class="grid gap-3 mb-6" aria-hidden="true">
          <div :for={_ <- 1..20} class="h-12 bg-neutral-200 dark:bg-neutral-700"></div>
        </div>
        <div class="flex items-center justify-end gap-3">
          <button
            type="button"
            data-close
            class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
          >
            Close
          </button>
        </div>
      </div>
    </.drawer>
    """
  end

  def example(%{section: "drawer-swipe-area"} = assigns) do
    ~H"""
    <div class="relative min-h-80 w-full overflow-hidden border border-neutral-950 bg-white text-neutral-950 dark:border-white dark:bg-neutral-950 dark:text-white">
      <.drawer
        id="baseui-drawer-swipe-area"
        side="right"
        swipe_direction="right"
        modal={false}
        swipe_area={true}
        swipe_area_class="absolute inset-y-0 right-0 z-[1] w-10 border-l-2 border-dashed border-blue-800 bg-blue-800/10 dark:border-blue-500 dark:bg-blue-500/10"
        backdrop_class="[--backdrop-opacity:0.2] [--bleed:3rem] dark:[--backdrop-opacity:0.7] absolute inset-0 min-h-dvh bg-black opacity-[calc(var(--backdrop-opacity)*(1-var(--drawer-swipe-progress)))] transition-opacity duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] data-[swiping]:duration-0 data-[ending-style]:opacity-0 data-[starting-style]:opacity-0 data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)] supports-[-webkit-touch-callout:none]:absolute"
        viewport_class="[--viewport-padding:0px] supports-[-webkit-touch-callout:none]:[--viewport-padding:0.625rem] absolute inset-0 z-20 flex items-stretch justify-end p-(--viewport-padding)"
        popup_class="[--bleed:3rem] supports-[-webkit-touch-callout:none]:[--bleed:0px] h-full w-[calc(20rem+3rem)] max-w-[calc(100vw-3rem+3rem)] -mr-[3rem] border-l border-neutral-950 bg-white p-6 pr-[calc(1.5rem+3rem)] text-neutral-950 outline-none shadow-[0.25rem_0.25rem_0] shadow-black/12 overflow-y-auto touch-auto [transform:translateX(var(--drawer-swipe-movement-x))] transition-transform duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] data-[swiping]:select-none data-[ending-style]:[transform:translateX(calc(100%-var(--bleed)+var(--viewport-padding)+2px))] data-[starting-style]:[transform:translateX(calc(100%-var(--bleed)+var(--viewport-padding)+2px))] data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)] supports-[-webkit-touch-callout:none]:mr-0 supports-[-webkit-touch-callout:none]:w-[20rem] supports-[-webkit-touch-callout:none]:max-w-[calc(100vw-3rem)] supports-[-webkit-touch-callout:none]:border supports-[-webkit-touch-callout:none]:pr-6 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
        content_class="mx-auto w-full max-w-[32rem]"
        title_class="mb-1 text-base font-bold"
        description_class="mb-6 text-sm text-neutral-600 dark:text-neutral-400"
        footer_class="flex justify-end gap-3"
      >
        <:swipe_area_inner>
          <span class="pointer-events-none absolute right-0 top-1/2 z-0 mr-2 -translate-y-1/2 -rotate-90 origin-center whitespace-nowrap text-xs font-bold tracking-[0.12em] text-blue-800 uppercase dark:text-blue-500">
            Swipe here
          </span>
        </:swipe_area_inner>
        <:title>Library</:title>
        <:description>
          Swipe from the edge whenever you want to jump back into your playlists.
        </:description>
        <:close>
          <button
            type="button"
            data-close
            class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
          >
            Close
          </button>
        </:close>
      </.drawer>
      <div class="flex min-h-80 flex-col items-center justify-center gap-3 p-4 text-center">
        <p class="text-sm text-neutral-600 text-center dark:text-neutral-400 pr-12">
          Swipe from the right edge to open the drawer.
        </p>
      </div>
    </div>
    """
  end

  def example(%{section: "drawer-uncontained"} = assigns) do
    ~H"""
    <.drawer
      id="baseui-drawer-uncontained"
      side="bottom"
      swipe_direction="down"
      trigger_class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      backdrop_class="[--backdrop-opacity:0.4] fixed inset-0 min-h-dvh bg-black opacity-[calc(var(--backdrop-opacity)*(1-var(--drawer-swipe-progress)))] transition-opacity duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] data-[swiping]:duration-0 data-[starting-style]:opacity-0 data-[ending-style]:opacity-0 data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)] supports-[-webkit-touch-callout:none]:absolute dark:[--backdrop-opacity:0.7]"
      viewport_class="fixed inset-0 flex items-end justify-center"
      popup_class="pointer-events-none flex w-full max-w-[20rem] flex-col gap-3 px-4 pb-[calc(1rem+env(safe-area-inset-bottom,0px))] outline-none focus-visible:outline-none [transform:translateY(var(--drawer-swipe-movement-y))] transition-transform duration-[450ms] ease-[cubic-bezier(0.32,0.72,0,1)] data-[swiping]:select-none data-[starting-style]:[transform:translateY(calc(100%+1rem+2px))] data-[ending-style]:[transform:translateY(calc(100%+1rem+2px))] data-[ending-style]:duration-[calc(var(--drawer-swipe-strength)*400ms)]"
      content_class="pointer-events-auto overflow-hidden border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
    >
      <:trigger>Open action sheet</:trigger>
      <:title><span class="sr-only">Profile actions</span></:title>
      <:description><span class="sr-only">Choose an action for this user.</span></:description>
      <ul
        class="m-0 list-none divide-y divide-neutral-950 p-0 dark:divide-white"
        aria-label="Profile actions"
      >
        <li :for={
          action <- ["Unfollow", "Mute", "Add to Favourites", "Add to Close Friends", "Restrict"]
        }>
          <button
            type="button"
            data-close
            class="h-10 w-full border-0 bg-transparent px-5 text-center text-sm text-neutral-950 select-none hover:bg-neutral-100 active:bg-neutral-200 focus-visible:bg-neutral-100 focus-visible:outline-none dark:text-white dark:hover:bg-neutral-800 dark:active:bg-neutral-700 dark:focus-visible:bg-neutral-800"
          >
            {action}
          </button>
        </li>
      </ul>
      <div class="pointer-events-auto overflow-hidden border border-neutral-950 bg-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:border-white dark:bg-neutral-950 dark:shadow-none">
        <button
          type="button"
          data-close
          class="h-10 w-full border-0 bg-transparent px-5 text-center text-sm text-red-700 select-none dark:text-red-400 hover:bg-neutral-100 active:bg-neutral-200 focus-visible:bg-neutral-100 focus-visible:outline-none dark:hover:bg-neutral-800 dark:active:bg-neutral-700 dark:focus-visible:bg-neutral-800"
        >
          Block User
        </button>
      </div>
    </.drawer>
    """
  end

  def example(%{section: "field-hero"} = assigns) do
    ~H"""
    <.field
      :let={f}
      id="baseui-field-hero"
      name="name"
      label="Name"
      errors={["Please enter your name"]}
      class="flex w-full max-w-64 flex-col items-start gap-1"
      label_class="text-sm font-bold text-neutral-950 dark:text-white"
      error_class="text-sm text-red-700 dark:text-red-400"
      description_class="text-sm text-neutral-600 dark:text-neutral-400"
    >
      <input
        type="text"
        required
        placeholder="Required"
        id={f.id}
        name={f.name}
        aria-describedby={f.describedby}
        aria-invalid={f.invalid && "true"}
        disabled={f.disabled}
        class="h-8 self-stretch border border-neutral-950 bg-white dark:bg-neutral-950 px-2 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 placeholder:text-neutral-500 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:text-white dark:placeholder:text-neutral-400"
      />
      <:description>Visible on your profile</:description>
    </.field>
    """
  end

  def example(%{section: "fieldset-hero"} = assigns) do
    ~H"""
    <.fieldset
      id="baseui-fieldset-hero"
      class="flex w-full max-w-64 flex-col gap-4"
      legend_class="border-b border-neutral-950 text-base font-bold text-neutral-950 dark:border-white dark:text-white"
    >
      <:legend>Billing details</:legend>

      <.field
        :let={f}
        id="baseui-fieldset-hero-company"
        label="Company"
        class="flex flex-col items-start gap-1"
        label_class="text-sm font-bold text-neutral-950 dark:text-white"
      >
        <input
          id={f.id}
          name={f.name}
          placeholder="Enter company name"
          aria-describedby={f.describedby}
          class="h-8 w-full border border-neutral-950 bg-white dark:bg-neutral-950 px-2 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 placeholder:text-neutral-500 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:text-white dark:placeholder:text-neutral-400"
        />
      </.field>

      <.field
        :let={f}
        id="baseui-fieldset-hero-tax-id"
        label="Tax ID"
        class="flex flex-col items-start gap-1"
        label_class="text-sm font-bold text-neutral-950 dark:text-white"
      >
        <input
          id={f.id}
          name={f.name}
          placeholder="Enter fiscal number"
          aria-describedby={f.describedby}
          class="h-8 w-full border border-neutral-950 bg-white dark:bg-neutral-950 px-2 text-sm any-pointer-coarse:text-base font-normal text-neutral-950 placeholder:text-neutral-500 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:text-white dark:placeholder:text-neutral-400"
        />
      </.field>
    </.fieldset>
    """
  end

  def example(%{section: "menu-hero"} = assigns) do
    ~H"""
    <.menu
      id="baseui-menu-hero"
      side_offset={8}
      trigger_class="flex h-8 items-center justify-center gap-1.5 rounded-none border border-neutral-950 bg-white pl-3 pr-2 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[popup-open]:bg-neutral-100 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 dark:data-[popup-open]:bg-neutral-800 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      popup_class="relative origin-[var(--transform-origin)] border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
    >
      <:trigger>
        Song
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block">
          <path d="M12 6H4l4 4.5z" />
        </svg>
      </:trigger>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Add to Library
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Add to Playlist
      </:item>
      <:item type="separator" class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Play Next
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Play Last
      </:item>
      <:item type="separator" class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Favorite
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Share
      </:item>
    </.menu>
    """
  end

  def example(%{section: "menu-arrow"} = assigns) do
    ~H"""
    <.menu
      id="baseui-menu-arrow"
      side_offset={8}
      trigger_class="flex h-8 items-center justify-center gap-1.5 rounded-none border border-neutral-950 bg-white pl-3 pr-2 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[popup-open]:bg-neutral-100 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 dark:data-[popup-open]:bg-neutral-800 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      popup_class="relative origin-[var(--transform-origin)] border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
    >
      <:trigger>
        Song
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block">
          <path d="M12 6H4l4 4.5z" />
        </svg>
      </:trigger>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white">
        Add to Library
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white">
        Add to Playlist
      </:item>
      <:item type="separator" class="m-1 h-px bg-neutral-950 dark:bg-white" />
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white">
        Play Next
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white">
        Play Last
      </:item>
      <:item type="separator" class="m-1 h-px bg-neutral-950 dark:bg-white" />
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white">
        Favorite
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white">
        Share
      </:item>
    </.menu>
    """
  end

  def example(%{section: "menu-checkbox-items"} = assigns) do
    ~H"""
    <.menu
      id="baseui-menu-checkbox-items"
      side_offset={8}
      trigger_class="flex h-8 items-center justify-center gap-1.5 rounded-none border border-neutral-950 bg-white pl-3 pr-2 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[popup-open]:bg-neutral-100 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 dark:data-[popup-open]:bg-neutral-800 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      popup_class="relative origin-[var(--transform-origin)] border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
    >
      <:trigger>
        Workspace
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block">
          <path d="M12 6H4l4 4.5z" />
        </svg>
      </:trigger>
      <:check_icon>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          style="display: block"
        >
          <path d="m2.5 8.5 4 4 7-9" />
        </svg>
      </:check_icon>
      <:item
        type="checkbox"
        checked={true}
        class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-2 pr-8 pl-2.5 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400"
        indicator_class="col-start-1 data-[unchecked]:invisible"
      >
        <span class="col-start-2">Minimap</span>
      </:item>
      <:item
        type="checkbox"
        checked={true}
        class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-2 pr-8 pl-2.5 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400"
        indicator_class="col-start-1 data-[unchecked]:invisible"
      >
        <span class="col-start-2">Search</span>
      </:item>
      <:item
        type="checkbox"
        checked={false}
        class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-2 pr-8 pl-2.5 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400"
        indicator_class="col-start-1 data-[unchecked]:invisible"
      >
        <span class="col-start-2">Sidebar</span>
      </:item>
    </.menu>
    """
  end

  def example(%{section: "menu-radio-items"} = assigns) do
    ~H"""
    <.menu
      id="baseui-menu-radio-items"
      side_offset={8}
      trigger_class="flex h-8 items-center justify-center gap-1.5 rounded-none border border-neutral-950 bg-white pl-3 pr-2 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[popup-open]:bg-neutral-100 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 dark:data-[popup-open]:bg-neutral-800 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      popup_class="relative origin-[var(--transform-origin)] border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
    >
      <:trigger>
        Sort
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block">
          <path d="M12 6H4l4 4.5z" />
        </svg>
      </:trigger>
      <:check_icon>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          style="display: block"
        >
          <path d="m2.5 8.5 4 4 7-9" />
        </svg>
      </:check_icon>
      <:item
        type="radio"
        name="sort"
        value="date"
        checked={true}
        class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-2 pr-8 pl-2.5 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400"
        indicator_class="col-start-1 data-[unchecked]:invisible"
      >
        <span class="col-start-2">Date</span>
      </:item>
      <:item
        type="radio"
        name="sort"
        value="name"
        class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-2 pr-8 pl-2.5 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400"
        indicator_class="col-start-1 data-[unchecked]:invisible"
      >
        <span class="col-start-2">Name</span>
      </:item>
      <:item
        type="radio"
        name="sort"
        value="type"
        class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-2 pr-8 pl-2.5 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400"
        indicator_class="col-start-1 data-[unchecked]:invisible"
      >
        <span class="col-start-2">Type</span>
      </:item>
    </.menu>
    """
  end

  def example(%{section: "menu-group-labels"} = assigns) do
    ~H"""
    <.menu
      id="baseui-menu-group-labels"
      side_offset={8}
      trigger_class="flex h-8 items-center justify-center gap-1.5 rounded-none border border-neutral-950 bg-white pl-3 pr-2 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[popup-open]:bg-neutral-100 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 dark:data-[popup-open]:bg-neutral-800 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      popup_class="relative origin-[var(--transform-origin)] border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
    >
      <:trigger>
        View
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block">
          <path d="M12 6H4l4 4.5z" />
        </svg>
      </:trigger>
      <:check_icon>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          style="display: block"
        >
          <path d="m2.5 8.5 4 4 7-9" />
        </svg>
      </:check_icon>
      <:item
        type="label"
        class="py-2 pr-8 pl-[2.125rem] text-sm leading-4 text-neutral-500 select-none dark:text-neutral-400"
      >
        Sort
      </:item>
      <:item
        type="radio"
        name="view-sort"
        value="date"
        checked={true}
        class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-2 pr-8 pl-2.5 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400"
        indicator_class="col-start-1 data-[unchecked]:invisible"
      >
        <span class="col-start-2">Date</span>
      </:item>
      <:item
        type="radio"
        name="view-sort"
        value="name"
        class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-2 pr-8 pl-2.5 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400"
        indicator_class="col-start-1 data-[unchecked]:invisible"
      >
        <span class="col-start-2">Name</span>
      </:item>
      <:item
        type="radio"
        name="view-sort"
        value="type"
        class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-2 pr-8 pl-2.5 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400"
        indicator_class="col-start-1 data-[unchecked]:invisible"
      >
        <span class="col-start-2">Type</span>
      </:item>
      <:item type="separator" class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
      <:item
        type="label"
        class="py-2 pr-8 pl-[2.125rem] text-sm leading-4 text-neutral-500 select-none dark:text-neutral-400"
      >
        Workspace
      </:item>
      <:item
        type="checkbox"
        checked={true}
        class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-2 pr-8 pl-2.5 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400"
        indicator_class="col-start-1 data-[unchecked]:invisible"
      >
        <span class="col-start-2">Minimap</span>
      </:item>
      <:item
        type="checkbox"
        checked={true}
        class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-2 pr-8 pl-2.5 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400"
        indicator_class="col-start-1 data-[unchecked]:invisible"
      >
        <span class="col-start-2">Search</span>
      </:item>
      <:item
        type="checkbox"
        checked={false}
        class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-2 pr-8 pl-2.5 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400"
        indicator_class="col-start-1 data-[unchecked]:invisible"
      >
        <span class="col-start-2">Sidebar</span>
      </:item>
    </.menu>
    """
  end

  def example(%{section: "menu-open-on-hover"} = assigns) do
    ~H"""
    <.menu
      id="baseui-menu-open-on-hover"
      side_offset={8}
      open_on_hover
      trigger_class="flex h-8 items-center justify-center gap-1.5 rounded-none border border-neutral-950 bg-white pl-3 pr-2 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[popup-open]:bg-neutral-100 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 dark:data-[popup-open]:bg-neutral-800 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      popup_class="relative origin-[var(--transform-origin)] border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
    >
      <:trigger>
        Add to playlist
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block">
          <path d="M12 6H4l4 4.5z" />
        </svg>
      </:trigger>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Get Up!
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Inside Out
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Night Beats
      </:item>
      <:item type="separator" class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        New playlist…
      </:item>
    </.menu>
    """
  end

  def example(%{section: "menu-submenu"} = assigns) do
    ~H"""
    <.menu
      id="baseui-menu-submenu"
      side_offset={8}
      trigger_class="flex h-8 items-center justify-center gap-1.5 rounded-none border border-neutral-950 bg-white pl-3 pr-2 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[popup-open]:bg-neutral-100 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 dark:data-[popup-open]:bg-neutral-800 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      popup_class="relative origin-[var(--transform-origin)] border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
    >
      <:trigger>
        Song
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block">
          <path d="M12 6H4l4 4.5z" />
        </svg>
      </:trigger>
      <.menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Add to Library
      </.menu_item>
      <.menu_submenu
        id="baseui-menu-submenu-playlist"
        label="Add to Playlist"
        trigger_class="flex cursor-default items-center justify-between gap-4 py-2 pr-2 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400"
        popup_class="relative origin-[var(--transform-origin)] border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
      >
        <:chevron>
          <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block">
            <path d="M6 12V4l4.5 4z" />
          </svg>
        </:chevron>
        <.menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
          Add to Library
        </.menu_item>
        <.menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
          Add to Playlist
        </.menu_item>
        <.menu_separator class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
        <.menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
          Play Next
        </.menu_item>
        <.menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
          Play Last
        </.menu_item>
        <.menu_separator class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
        <.menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
          Favorite
        </.menu_item>
        <.menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
          Share
        </.menu_item>
      </.menu_submenu>
      <.menu_separator class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
      <.menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Play Next
      </.menu_item>
      <.menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Play Last
      </.menu_item>
      <.menu_separator class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
      <.menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Favorite
      </.menu_item>
      <.menu_item class="flex cursor-default py-2 pr-6 pl-4 text-sm leading-4 outline-hidden select-none data-[popup-open]:relative data-[popup-open]:z-0 data-[popup-open]:before:absolute data-[popup-open]:before:inset-x-1 data-[popup-open]:before:inset-y-0 data-[popup-open]:before:z-[-1] data-[popup-open]:before:bg-neutral-100 data-[popup-open]:before:content-[''] data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[highlighted]:data-[popup-open]:before:bg-neutral-950 data-[disabled]:text-neutral-500 dark:data-[popup-open]:before:bg-neutral-800 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[highlighted]:data-[popup-open]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Share
      </.menu_item>
    </.menu>
    """
  end

  def example(%{section: "menu-detached-triggers-simple"} = assigns) do
    ~H"""
    <.menu
      id="baseui-menu-detached-triggers-simple"
      side_offset={8}
      trigger_class="flex size-8 items-center justify-center rounded-none border border-neutral-950 bg-white text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 data-[popup-open]:bg-neutral-100 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 dark:data-[popup-open]:bg-neutral-800 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      popup_class="relative origin-[var(--transform-origin)] border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
    >
      <:trigger>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="currentColor"
          style="display: block"
          aria-label="Project actions"
        >
          <circle cx="3" cy="8" r="1" />
          <circle cx="8" cy="8" r="1" />
          <circle cx="13" cy="8" r="1" />
        </svg>
      </:trigger>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Rename
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Duplicate
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Move to folder
      </:item>
      <:item type="separator" class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Archive
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400 text-red-600">
        Delete
      </:item>
    </.menu>
    """
  end

  def example(%{section: "menu-detached-triggers-full"} = assigns) do
    ~H"""
    <.menu
      id="baseui-menu-detached-triggers-full"
      side_offset={8}
      trigger_class="flex h-8 items-center justify-center rounded-none border border-neutral-950 bg-white px-3 text-sm font-normal text-neutral-950 select-none hover:bg-neutral-100 active:bg-neutral-200 data-[popup-open]:bg-neutral-100 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:bg-neutral-800 dark:active:bg-neutral-700 dark:data-[popup-open]:bg-neutral-800 focus-visible:outline focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      popup_class="relative h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] py-1 origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-none transition-[width,height,opacity,scale] duration-[0.35s] ease-[cubic-bezier(0.22,1,0.36,1)] data-[starting-style]:scale-90 data-[starting-style]:opacity-0 data-[ending-style]:scale-90 data-[ending-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
    >
      <:trigger>Library</:trigger>
      <.menu_group
        id="baseui-menu-full-g1"
        label="Library"
        label_class="px-4 py-2 text-sm leading-4 text-neutral-500 select-none dark:text-neutral-400"
      >
        <.menu_item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white">
          Add to library
        </.menu_item>
        <.menu_item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white">
          Add to favorites
        </.menu_item>
      </.menu_group>
      <.menu_separator class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white" />
      <.menu_group>
        <.menu_item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white">
          Create playlist
        </.menu_item>
        <.menu_item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white">
          Create station
        </.menu_item>
      </.menu_group>
    </.menu>
    """
  end

  def example(%{section: "menu-detached-triggers-controlled"} = assigns) do
    ~H"""
    <.menu
      id="baseui-menu-detached-triggers-controlled"
      side_offset={8}
      trigger_class="flex h-8 items-center justify-center gap-2 rounded-none border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white active:bg-neutral-200 data-[popup-open]:bg-neutral-100 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:bg-neutral-800 dark:active:bg-neutral-700 dark:data-[popup-open]:bg-neutral-800"
      popup_class="relative origin-[var(--transform-origin)] border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
    >
      <:trigger>Playback</:trigger>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Play
      </:item>
      <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm leading-4 outline-hidden select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] data-[disabled]:text-neutral-500 dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white dark:data-[disabled]:text-neutral-400">
        Add to queue
      </:item>
    </.menu>
    """
  end

  def example(%{section: "menubar-hero"} = assigns) do
    ~H"""
    <.menubar
      id="baseui-menubar-hero"
      class="flex items-center"
      menu_class="relative"
      trigger_class="h-8 border-0 bg-transparent px-3 text-sm font-normal text-neutral-950 select-none data-[popup-open]:bg-neutral-100 data-[pressed]:bg-neutral-100 data-[disabled]:text-neutral-500 dark:text-white dark:focus-visible:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800 dark:data-[pressed]:bg-neutral-800 dark:data-[disabled]:text-neutral-400 focus-visible:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 focus-visible:relative dark:focus-visible:outline-white"
      popup_class="absolute left-0 top-full mt-1 z-10 origin-[var(--transform-origin)] border border-neutral-950 bg-white py-1 text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-none transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[instant]:transition-none data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 data-[closed]:hidden dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
    >
      <:menu label="File">
        <button
          type="button"
          role="menuitem"
          class="flex w-full cursor-default items-center justify-between gap-4 py-2 pr-4 pl-4 text-left text-sm leading-4 font-normal outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          New
        </button>
        <button
          type="button"
          role="menuitem"
          class="flex w-full cursor-default items-center justify-between gap-4 py-2 pr-4 pl-4 text-left text-sm leading-4 font-normal outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          Open
        </button>
        <button
          type="button"
          role="menuitem"
          class="flex w-full cursor-default items-center justify-between gap-4 py-2 pr-4 pl-4 text-left text-sm leading-4 font-normal outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          Save
        </button>
        <button
          type="button"
          role="menuitem"
          class="flex w-full cursor-default items-center justify-between gap-4 py-2 pr-2 pl-4 text-left text-sm leading-4 font-normal outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          Export
          <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block;">
            <path d="M6 12V4l4.5 4z" />
          </svg>
        </button>
        <div
          data-part="separator"
          role="separator"
          class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white"
        >
        </div>
        <button
          type="button"
          role="menuitem"
          class="flex w-full cursor-default items-center justify-between gap-4 py-2 pr-4 pl-4 text-left text-sm leading-4 font-normal outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          Print
        </button>
      </:menu>

      <:menu label="Edit">
        <button
          type="button"
          role="menuitem"
          class="flex w-full cursor-default items-center justify-between gap-4 py-2 pr-4 pl-4 text-left text-sm leading-4 font-normal outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          Cut
        </button>
        <button
          type="button"
          role="menuitem"
          class="flex w-full cursor-default items-center justify-between gap-4 py-2 pr-4 pl-4 text-left text-sm leading-4 font-normal outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          Copy
        </button>
        <button
          type="button"
          role="menuitem"
          class="flex w-full cursor-default items-center justify-between gap-4 py-2 pr-4 pl-4 text-left text-sm leading-4 font-normal outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          Paste
        </button>
      </:menu>

      <:menu label="View">
        <button
          type="button"
          role="menuitem"
          class="flex w-full cursor-default items-center justify-between gap-4 py-2 pr-4 pl-4 text-left text-sm leading-4 font-normal outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          Zoom In
        </button>
        <button
          type="button"
          role="menuitem"
          class="flex w-full cursor-default items-center justify-between gap-4 py-2 pr-4 pl-4 text-left text-sm leading-4 font-normal outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          Zoom Out
        </button>
        <button
          type="button"
          role="menuitem"
          class="flex w-full cursor-default items-center justify-between gap-4 py-2 pr-2 pl-4 text-left text-sm leading-4 font-normal outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          Layout
          <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block;">
            <path d="M6 12V4l4.5 4z" />
          </svg>
        </button>
        <div
          data-part="separator"
          role="separator"
          class="mx-1 my-1 h-px bg-neutral-950 dark:bg-white"
        >
        </div>
        <button
          type="button"
          role="menuitem"
          class="flex w-full cursor-default items-center justify-between gap-4 py-2 pr-4 pl-4 text-left text-sm leading-4 font-normal outline-none select-none data-[highlighted]:relative data-[highlighted]:z-0 data-[highlighted]:text-white data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:z-[-1] data-[highlighted]:before:bg-neutral-950 data-[highlighted]:before:content-[''] dark:data-[highlighted]:text-neutral-950 dark:data-[highlighted]:before:bg-white"
        >
          Full Screen
        </button>
      </:menu>

      <:menu label="Help" disabled></:menu>
    </.menubar>
    """
  end

  def example(%{section: "meter-hero"} = assigns) do
    ~H"""
    <.meter
      id="baseui-meter-hero"
      value={24}
      label="Storage Used"
      show_value
      class="grid max-w-full w-60 grid-cols-2 gap-y-2"
      label_class="text-sm font-normal text-neutral-950 dark:text-white"
      value_class="text-right text-sm text-neutral-950 dark:text-white"
      track_class="col-span-2 h-3 overflow-hidden bg-neutral-200 dark:bg-neutral-800"
      indicator_class="bg-neutral-950 transition-[width] duration-500 dark:bg-white"
    />
    """
  end

  def example(%{section: "navigation_menu-hero"} = assigns) do
    ~H"""
    <.navigation_menu
      id="baseui-navigation_menu-hero"
      style="--duration: 0.35s; --easing: cubic-bezier(0.22, 1, 0.36, 1);"
      class="min-w-max text-neutral-950 dark:text-white"
      list_class="relative flex gap-px"
      trigger_class="flex h-8 items-center justify-center gap-1.5 bg-transparent px-2 text-sm font-normal text-neutral-950 no-underline select-none min-[501px]:px-3 hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
      link_class="flex h-8 items-center justify-center gap-1.5 bg-transparent px-2 text-sm font-normal text-neutral-950 no-underline select-none min-[501px]:px-3 hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
      icon_class="transition-transform duration-200 ease-[ease] data-[open]:rotate-180"
      positioner_class="h-[var(--positioner-height)] w-[var(--positioner-width)] max-w-[var(--available-width)] transition-[top,left,right,bottom] duration-[var(--duration)] ease-[var(--easing)] before:absolute before:content-[''] data-[instant]:transition-none data-[side=bottom]:before:top-[-10px] data-[side=bottom]:before:right-0 data-[side=bottom]:before:left-0 data-[side=bottom]:before:h-2.5 data-[side=left]:before:top-0 data-[side=left]:before:right-[-10px] data-[side=left]:before:bottom-0 data-[side=left]:before:w-2.5 data-[side=right]:before:top-0 data-[side=right]:before:bottom-0 data-[side=right]:before:left-[-10px] data-[side=right]:before:w-2.5 data-[side=top]:before:right-0 data-[side=top]:before:bottom-[-10px] data-[side=top]:before:left-0 data-[side=top]:before:h-2.5"
      popup_class="relative h-[var(--popup-height)] w-[var(--popup-width)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-none transition-[opacity,transform,width,height,scale] duration-[var(--duration)] ease-[var(--easing)] data-[ending-style]:scale-90 data-[ending-style]:opacity-0 data-[ending-style]:duration-150 data-[ending-style]:ease-[ease] data-[starting-style]:scale-90 data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
      arrow_class="relative block h-1.5 w-3 overflow-clip transition-[left,right] duration-[var(--duration)] ease-[var(--easing)] before:absolute before:bottom-0 before:left-1/2 before:block before:h-[calc(6px*sqrt(2))] before:w-[calc(6px*sqrt(2))] before:-translate-x-1/2 before:translate-y-1/2 before:rotate-45 before:border before:border-neutral-950 before:bg-white before:content-[''] data-[side=bottom]:top-[-6px] data-[side=left]:right-[-9px] data-[side=left]:rotate-90 data-[side=right]:left-[-9px] data-[side=right]:-rotate-90 data-[side=top]:bottom-[-6px] data-[side=top]:rotate-180 dark:before:border-white dark:before:bg-neutral-950"
      viewport_class="relative h-full w-full overflow-hidden"
      content_class="h-full w-[calc(100vw-40px)] p-2 min-[500px]:w-max min-[500px]:max-w-[400px] transition-[opacity,transform,translate] duration-[var(--duration)] ease-[var(--easing)] data-[starting-style]:opacity-0 data-[ending-style]:opacity-0 data-[starting-style]:data-[activation-direction=left]:translate-x-[-50%] data-[starting-style]:data-[activation-direction=right]:translate-x-[50%] data-[ending-style]:data-[activation-direction=left]:translate-x-[50%] data-[ending-style]:data-[activation-direction=right]:translate-x-[-50%]"
    >
      <:icon>
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" class="block">
          <path d="M12 6H4l4 4.5z" />
        </svg>
      </:icon>

      <:item label="Overview">
        <ul class="m-0 grid list-none grid-cols-2 p-0 max-[500px]:grid-cols-1">
          <li>
            <a
              href="#"
              class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
            >
              <h3 class="m-0 mb-1 text-sm leading-4 font-normal">Quick Start</h3>
              <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                Install and assemble your first component.
              </p>
            </a>
          </li>
          <li>
            <a
              href="#"
              class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
            >
              <h3 class="m-0 mb-1 text-sm leading-4 font-normal">Accessibility</h3>
              <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                Learn how we build accessible components.
              </p>
            </a>
          </li>
          <li>
            <a
              href="#"
              class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
            >
              <h3 class="m-0 mb-1 text-sm leading-4 font-normal">Releases</h3>
              <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                See what's new in the latest Base UI versions.
              </p>
            </a>
          </li>
          <li>
            <a
              href="#"
              class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
            >
              <h3 class="m-0 mb-1 text-sm leading-4 font-normal">About</h3>
              <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                Learn more about Base UI and our mission.
              </p>
            </a>
          </li>
        </ul>
      </:item>

      <:item label="Handbook">
        <ul class="m-0 flex max-w-[400px] list-none flex-col justify-center p-0">
          <li>
            <a
              href="#"
              class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
            >
              <h3 class="m-0 mb-1 text-sm leading-4 font-normal">Styling</h3>
              <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                Base UI components can be styled with plain CSS, Tailwind CSS, CSS-in-JS, or CSS Modules.
              </p>
            </a>
          </li>
          <li>
            <a
              href="#"
              class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
            >
              <h3 class="m-0 mb-1 text-sm leading-4 font-normal">Animation</h3>
              <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                Base UI components can be animated with CSS transitions, CSS animations, or JavaScript libraries.
              </p>
            </a>
          </li>
          <li>
            <a
              href="#"
              class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
            >
              <h3 class="m-0 mb-1 text-sm leading-4 font-normal">Composition</h3>
              <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
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

  def example(%{section: "navigation_menu-nested"} = assigns) do
    ~H"""
    <.navigation_menu
      id="baseui-navigation_menu-nested"
      style="--duration: 0.35s; --easing: cubic-bezier(0.22, 1, 0.36, 1);"
      class="min-w-max text-neutral-950 dark:text-white"
      list_class="relative flex gap-px"
      trigger_class="flex h-8 items-center justify-center gap-1.5 bg-transparent px-2 text-sm font-normal text-neutral-950 no-underline select-none min-[501px]:px-3 hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
      icon_class="transition-transform duration-200 ease-[ease] data-[open]:rotate-180"
      positioner_class="h-[var(--positioner-height)] w-[var(--positioner-width)] max-w-[var(--available-width)] transition-[top,left,right,bottom] duration-[var(--duration)] ease-[var(--easing)] before:absolute before:content-[''] data-[instant]:transition-none data-[side=bottom]:before:top-[-10px] data-[side=bottom]:before:right-0 data-[side=bottom]:before:left-0 data-[side=bottom]:before:h-2.5 data-[side=left]:before:top-0 data-[side=left]:before:right-[-10px] data-[side=left]:before:bottom-0 data-[side=left]:before:w-2.5 data-[side=right]:before:top-0 data-[side=right]:before:bottom-0 data-[side=right]:before:left-[-10px] data-[side=right]:before:w-2.5 data-[side=top]:before:right-0 data-[side=top]:before:bottom-[-10px] data-[side=top]:before:left-0 data-[side=top]:before:h-2.5"
      popup_class="relative h-[var(--popup-height)] w-[var(--popup-width)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-none transition-[opacity,transform,width,height,scale] duration-[var(--duration)] ease-[var(--easing)] data-[ending-style]:scale-90 data-[ending-style]:opacity-0 data-[ending-style]:duration-150 data-[ending-style]:ease-[ease] data-[starting-style]:scale-90 data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
      arrow_class="relative block h-1.5 w-3 overflow-clip transition-[left,right] duration-[var(--duration)] ease-[var(--easing)] before:absolute before:bottom-0 before:left-1/2 before:block before:h-[calc(6px*sqrt(2))] before:w-[calc(6px*sqrt(2))] before:-translate-x-1/2 before:translate-y-1/2 before:rotate-45 before:border before:border-neutral-950 before:bg-white before:content-[''] data-[side=bottom]:top-[-6px] data-[side=left]:right-[-9px] data-[side=left]:rotate-90 data-[side=right]:left-[-9px] data-[side=right]:-rotate-90 data-[side=top]:bottom-[-6px] data-[side=top]:rotate-180 dark:before:border-white dark:before:bg-neutral-950"
      viewport_class="relative h-full w-full overflow-hidden"
      content_class="h-full w-[calc(100vw-40px)] p-2 min-[500px]:w-max min-[500px]:min-w-[400px] transition-[opacity,transform,translate] duration-[var(--duration)] ease-[var(--easing)] data-[starting-style]:opacity-0 data-[ending-style]:opacity-0 data-[starting-style]:data-[activation-direction=left]:translate-x-[-50%] data-[starting-style]:data-[activation-direction=right]:translate-x-[50%] data-[ending-style]:data-[activation-direction=left]:translate-x-[50%] data-[ending-style]:data-[activation-direction=right]:translate-x-[-50%]"
    >
      <:icon>
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" class="block">
          <path d="M12 6H4l4 4.5z" />
        </svg>
      </:icon>

      <:item label="Overview">
        <ul class="m-0 grid list-none grid-cols-2 p-0 min-[640px]:grid-cols-[12rem_12rem]">
          <li>
            <a
              href="#"
              class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
            >
              <h3 class="m-0 mb-1 text-sm leading-4 font-normal">Quick Start</h3>
              <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                Install and assemble your first component.
              </p>
            </a>
          </li>
          <li>
            <a
              href="#"
              class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
            >
              <h3 class="m-0 mb-1 text-sm leading-4 font-normal">Accessibility</h3>
              <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                Learn how we build accessible components.
              </p>
            </a>
          </li>
          <li>
            <a
              href="#"
              class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
            >
              <h3 class="m-0 mb-1 text-sm leading-4 font-normal">Releases</h3>
              <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                See what's new in the latest Base UI versions.
              </p>
            </a>
          </li>
          <li class="relative">
            <div class="m-0 flex w-full min-w-[10rem] flex-col items-start gap-1 border-0 bg-transparent p-2 text-left text-inherit hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800">
              <span class="m-0 mb-1 text-sm leading-4 font-normal">Handbook</span>
              <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                How to use Base UI effectively.
              </p>
            </div>
            <ul class="m-0 flex list-none flex-col justify-center p-0">
              <li>
                <a
                  href="#"
                  class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
                >
                  <h3 class="m-0 mb-1 text-sm leading-4 font-normal">Styling</h3>
                  <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                    Base UI components can be styled with plain CSS, Tailwind CSS, CSS-in-JS, or CSS Modules.
                  </p>
                </a>
              </li>
              <li>
                <a
                  href="#"
                  class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
                >
                  <h3 class="m-0 mb-1 text-sm leading-4 font-normal">Animation</h3>
                  <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                    Base UI components can be animated with CSS transitions, CSS animations, or JavaScript libraries.
                  </p>
                </a>
              </li>
              <li>
                <a
                  href="#"
                  class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
                >
                  <h3 class="m-0 mb-1 text-sm leading-4 font-normal">Composition</h3>
                  <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
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
      id="baseui-navigation_menu-nested-inline"
      style="--duration: 0.35s; --easing: cubic-bezier(0.22, 1, 0.36, 1);"
      class="min-w-max text-neutral-950 dark:text-white"
      list_class="relative flex gap-px"
      trigger_class="flex h-8 items-center justify-center gap-1.5 bg-transparent px-2 text-sm font-normal text-neutral-950 no-underline select-none min-[501px]:px-3 hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
      link_class="flex h-8 items-center justify-center gap-1.5 bg-transparent px-2 text-sm font-normal text-neutral-950 no-underline select-none min-[501px]:px-3 hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
      icon_class="transition-transform duration-200 ease-[ease] data-[open]:rotate-180"
      positioner_class="h-[var(--positioner-height)] w-[var(--positioner-width)] max-w-[var(--available-width)] transition-[top,left,right,bottom] duration-[var(--duration)] ease-[var(--easing)] before:absolute before:content-[''] data-[instant]:transition-none data-[side=bottom]:before:top-[-10px] data-[side=bottom]:before:right-0 data-[side=bottom]:before:left-0 data-[side=bottom]:before:h-2.5 data-[side=left]:before:top-0 data-[side=left]:before:right-[-10px] data-[side=left]:before:bottom-0 data-[side=left]:before:w-2.5 data-[side=right]:before:top-0 data-[side=right]:before:bottom-0 data-[side=right]:before:left-[-10px] data-[side=right]:before:w-2.5 data-[side=top]:before:right-0 data-[side=top]:before:bottom-[-10px] data-[side=top]:before:left-0 data-[side=top]:before:h-2.5"
      popup_class="relative h-[var(--popup-height)] w-[var(--popup-width)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 outline-none transition-[opacity,transform,width,height,scale] duration-[var(--duration)] ease-[var(--easing)] data-[ending-style]:scale-90 data-[ending-style]:opacity-0 data-[ending-style]:duration-150 data-[ending-style]:ease-[ease] data-[ending-style]:transition-[opacity,scale] data-[starting-style]:scale-90 data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
      arrow_class="relative block h-1.5 w-3 overflow-clip transition-[left,right] duration-[var(--duration)] ease-[var(--easing)] before:absolute before:bottom-0 before:left-1/2 before:block before:h-[calc(6px*sqrt(2))] before:w-[calc(6px*sqrt(2))] before:-translate-x-1/2 before:translate-y-1/2 before:rotate-45 before:border before:border-neutral-950 before:bg-white before:content-[''] data-[side=bottom]:top-[-6px] data-[side=left]:right-[-9px] data-[side=left]:rotate-90 data-[side=right]:left-[-9px] data-[side=right]:-rotate-90 data-[side=top]:bottom-[-6px] data-[side=top]:rotate-180 dark:before:border-white dark:before:bg-neutral-950"
      viewport_class="relative h-full w-full overflow-hidden"
      content_class="h-full p-0 min-[700px]:[width:min(675px,calc(100vw-40px))] transition-[opacity,translate] duration-[calc(var(--duration)*0.5),var(--duration)] ease-[ease,cubic-bezier(0.4,0,0.2,1)] data-[starting-style]:data-[activation-direction=left]:opacity-0 data-[starting-style]:data-[activation-direction=right]:opacity-0 data-[ending-style]:opacity-0 data-[ending-style]:duration-[calc(var(--duration)*0.5)] data-[ending-style]:ease-[ease] data-[starting-style]:data-[activation-direction=left]:translate-x-[-2rem] data-[starting-style]:data-[activation-direction=right]:translate-x-[2rem] data-[ending-style]:data-[activation-direction=left]:translate-x-[2rem] data-[ending-style]:data-[activation-direction=right]:translate-x-[-2rem]"
    >
      <:icon>
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" class="block">
          <path d="M12 6H4l4 4.5z" />
        </svg>
      </:icon>

      <:item label="Product">
        <div class="grid grid-cols-1 overflow-hidden overflow-clip min-[700px]:grid-cols-[13rem_minmax(0,1fr)]">
          <ul class="m-0 flex list-none flex-row gap-1 overflow-x-auto p-2 min-[700px]:flex-col min-[700px]:gap-px min-[700px]:overflow-x-visible min-[700px]:overflow-y-clip min-[700px]:border-r min-[700px]:border-r-neutral-950 dark:min-[700px]:border-r-white">
            <li>
              <div class="m-0 flex w-full min-w-[10rem] flex-col items-start gap-1 border-0 bg-transparent p-2 text-left text-inherit hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800">
                <span class="text-sm leading-4 font-normal text-neutral-950 dark:text-white">
                  Developers
                </span>
                <span class="text-sm text-neutral-500 dark:text-neutral-400">
                  Go from idea to UI faster.
                </span>
              </div>
            </li>
            <li>
              <div class="m-0 flex w-full min-w-[10rem] flex-col items-start gap-1 border-0 bg-transparent p-2 text-left text-inherit hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800">
                <span class="text-sm leading-4 font-normal text-neutral-950 dark:text-white">
                  Design Systems
                </span>
                <span class="text-sm text-neutral-500 dark:text-neutral-400">
                  Keep patterns aligned across teams.
                </span>
              </div>
            </li>
            <li>
              <div class="m-0 flex w-full min-w-[10rem] flex-col items-start gap-1 border-0 bg-transparent p-2 text-left text-inherit hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800">
                <span class="text-sm leading-4 font-normal text-neutral-950 dark:text-white">
                  Engineering Leads
                </span>
                <span class="text-sm text-neutral-500 dark:text-neutral-400">
                  Roll out shared UI without drag.
                </span>
              </div>
            </li>
            <li>
              <div class="m-0 flex w-full min-w-[10rem] flex-col items-start gap-1 border-0 bg-transparent p-2 text-left text-inherit hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800">
                <span class="text-sm leading-4 font-normal text-neutral-950 dark:text-white">
                  Startups
                </span>
                <span class="text-sm text-neutral-500 dark:text-neutral-400">
                  Ship polished basics while things change.
                </span>
              </div>
            </li>
          </ul>
          <div class="relative min-h-[16.5rem] overflow-hidden border-t border-neutral-950 min-[700px]:border-t-0 dark:border-white">
            <div class="flex h-full flex-col gap-4 p-4">
              <div>
                <h4 class="m-0 text-base leading-5 font-normal">
                  Build product UI without giving up control
                </h4>
                <p class="m-0 mt-1 text-sm text-neutral-500 dark:text-neutral-400">
                  Start with accessible parts and shape them to your app instead of working around a preset design system.
                </p>
              </div>
              <ul class="-mx-2 m-0 flex list-none flex-col gap-0 p-0">
                <li>
                  <a
                    href="#"
                    class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
                  >
                    <h5 class="m-0 text-sm leading-4 font-normal">Quick start</h5>
                    <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                      Install Base UI and get your first interactive primitive on screen fast.
                    </p>
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
                  >
                    <h5 class="m-0 text-sm leading-4 font-normal">Composition</h5>
                    <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
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
        <div class="flex flex-col gap-4 p-4 text-neutral-950 dark:text-white">
          <div>
            <h4 class="m-0 text-base leading-5 font-normal">Where teams usually start</h4>
            <p class="m-0 mt-1 text-sm text-neutral-500 dark:text-neutral-400">
              These are the docs people reach for first when they are turning a prototype into shared UI.
            </p>
          </div>
          <ul class="-mx-2 m-0 flex list-none flex-col gap-0 p-0">
            <li>
              <a
                href="#"
                class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
              >
                <h5 class="m-0 text-sm leading-4 font-normal">Accessibility handbook</h5>
                <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                  Take a practical pass over focus order, semantics, and keyboard support.
                </p>
              </a>
            </li>
            <li>
              <a
                href="#"
                class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
              >
                <h5 class="m-0 text-sm leading-4 font-normal">Composition handbook</h5>
                <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
                  Learn when to wrap parts, share behavior, and expose flexible APIs.
                </p>
              </a>
            </li>
            <li>
              <a
                href="#"
                class="relative block h-full w-full border-0 bg-transparent p-2 text-left text-inherit no-underline hover:bg-neutral-100 data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:hover:bg-neutral-800 dark:data-[popup-open]:bg-neutral-800"
              >
                <h5 class="m-0 text-sm leading-4 font-normal">Styling handbook</h5>
                <p class="m-0 text-sm text-neutral-500 dark:text-neutral-400">
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

  def example(%{section: "number_field-hero"} = assigns) do
    ~H"""
    <.number_field
      id="baseui-number_field-hero"
      value={100}
      scrub_cursor
      class="flex flex-col items-start gap-1"
      scrub_area_class="cursor-ew-resize font-bold select-none"
      scrub_area_label_class="cursor-ew-resize text-sm font-bold text-neutral-950 dark:text-white"
      scrub_cursor_class="drop-shadow-[0_1px_1px_#0008] filter"
      group_class="flex h-8"
      decrement_class="flex h-full w-8 items-center justify-center border border-r-0 border-neutral-950 bg-white bg-clip-padding text-neutral-950 outline-0 select-none dark:border-white dark:bg-neutral-950 dark:text-white hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400"
      increment_class="flex h-full w-8 items-center justify-center border border-l-0 border-neutral-950 bg-white bg-clip-padding text-neutral-950 outline-0 select-none dark:border-white dark:bg-neutral-950 dark:text-white hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400"
      input_class="h-full w-[7ch] border border-neutral-950 bg-white px-2 text-left text-sm font-normal text-neutral-950 tabular-nums any-pointer-coarse:text-base dark:border-white dark:bg-neutral-950 dark:text-white focus:z-1 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white"
    >
      <:scrub_area>Amount</:scrub_area>
      <:scrub_cursor_icon>
        <svg
          width="26"
          height="14"
          viewBox="0 0 24 14"
          fill="black"
          stroke="white"
          style="display: block;"
        >
          <path d="M19.5 5.5L6.49737 5.51844V2L1 6.9999L6.5 12L6.49737 8.5L19.5 8.5V12L25 6.9999L19.5 2V5.5Z" />
        </svg>
      </:scrub_cursor_icon>
      <:decrement_icon>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          stroke-linecap="square"
          stroke-linejoin="round"
          style="display: block;"
        >
          <path d="M1.5 8h13" />
        </svg>
      </:decrement_icon>
      <:increment_icon>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          stroke-linecap="square"
          stroke-linejoin="round"
          style="display: block;"
        >
          <path d="M1.5 8h13M8 14.5v-13" />
        </svg>
      </:increment_icon>
    </.number_field>
    """
  end

  def example(%{section: "otp_field-hero"} = assigns) do
    ~H"""
    <div class="flex w-full max-w-80 flex-col items-start gap-1">
      <label
        for="baseui-otp_field-hero"
        class="text-sm font-bold text-neutral-950 dark:text-white"
      >
        Verification code
      </label>
      <.otp_field
        id="baseui-otp_field-hero"
        length={6}
        label="Verification code"
        class="flex w-full gap-2"
        input_class="m-0 h-10 w-10 rounded-none border border-neutral-950 bg-white dark:bg-neutral-950 text-center font-inherit text-base font-normal text-neutral-950 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:text-white"
      />
      <p class="m-0 text-sm text-neutral-600 dark:text-neutral-400">
        Enter the 6-character code we sent to your device.
      </p>
    </div>
    """
  end

  def example(%{section: "otp_field-alphanumeric"} = assigns) do
    ~H"""
    <div class="flex w-full max-w-80 flex-col items-start gap-1">
      <label
        for="baseui-otp_field-alphanumeric"
        class="text-sm font-bold text-neutral-950 dark:text-white"
      >
        Recovery code
      </label>
      <.otp_field
        id="baseui-otp_field-alphanumeric"
        length={6}
        validation_type="alphanumeric"
        label="Recovery code"
        class="flex w-full gap-2"
        input_class="m-0 h-10 w-10 rounded-none border border-neutral-950 bg-white dark:bg-neutral-950 text-center font-inherit text-base font-normal text-neutral-950 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:text-white"
      />
      <p class="m-0 text-sm text-neutral-600 dark:text-neutral-400">
        Accept letters and numbers for backup codes such as <code class="font-mono">A7C9XZ</code>.
      </p>
    </div>
    """
  end

  def example(%{section: "otp_field-password"} = assigns) do
    ~H"""
    <div class="flex w-full max-w-80 flex-col items-start gap-1">
      <label
        for="baseui-otp_field-password"
        class="text-sm font-bold text-neutral-950 dark:text-white"
      >
        Access code
      </label>
      <.otp_field
        id="baseui-otp_field-password"
        length={6}
        mask
        label="Access code"
        class="flex w-full gap-2"
        input_class="m-0 h-10 w-10 rounded-none border border-neutral-950 bg-white dark:bg-neutral-950 text-center font-inherit text-base font-normal text-neutral-950 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:text-white"
      />
      <p class="m-0 text-sm text-neutral-600 dark:text-neutral-400">
        Use <code class="font-mono">mask</code> to obscure the code on shared screens.
      </p>
    </div>
    """
  end

  def example(%{section: "otp_field-focused-placeholder"} = assigns) do
    ~H"""
    <div class="flex w-full max-w-80 flex-col items-start gap-1">
      <label
        for="baseui-otp_field-focused-placeholder"
        class="text-sm font-bold text-neutral-950 dark:text-white"
      >
        Verification code
      </label>
      <.otp_field
        id="baseui-otp_field-focused-placeholder"
        length={6}
        placeholder="•"
        label="Verification code"
        class="flex w-full gap-2"
        input_class="m-0 h-10 w-10 rounded-none border border-neutral-950 bg-white dark:bg-neutral-950 text-center font-inherit text-base font-normal text-neutral-950 placeholder:text-neutral-500 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white focus:placeholder:text-transparent dark:border-white dark:text-white dark:placeholder:text-neutral-400"
      />
      <p class="m-0 text-sm text-neutral-600 dark:text-neutral-400">
        Placeholder hints can stay visible until the active slot is focused.
      </p>
    </div>
    """
  end

  def example(%{section: "otp_field-grouped"} = assigns) do
    ~H"""
    <div class="flex w-full max-w-80 flex-col items-start gap-1">
      <label
        for="baseui-otp_field-grouped"
        class="text-sm font-bold text-neutral-950 dark:text-white"
      >
        Verification code
      </label>
      <.otp_field
        id="baseui-otp_field-grouped"
        length={6}
        group={3}
        separator=""
        label="Verification code"
        class="flex w-full items-center gap-2"
        input_class="m-0 h-10 w-10 rounded-none border border-neutral-950 bg-white dark:bg-neutral-950 text-center font-inherit text-base font-normal text-neutral-950 focus:outline-2 focus:-outline-offset-1 focus:outline-neutral-950 dark:focus:outline-white dark:border-white dark:text-white"
        separator_class="h-px w-4 bg-current text-neutral-950 dark:text-white"
      />
    </div>
    """
  end

  def example(%{section: "popover-hero"} = assigns) do
    ~H"""
    <.popover
      id="baseui-popover-hero"
      side_offset={8}
      trigger_class="flex h-8 items-center justify-center border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm font-normal whitespace-nowrap text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 data-[popup-open]:bg-neutral-100 dark:data-[popup-open]:bg-neutral-800 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      popup_class="group relative flex h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] max-w-[500px] flex-col gap-1 origin-[var(--transform-origin)] bg-white dark:bg-neutral-950 p-3 text-neutral-950 dark:text-white outline-none border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
      title_class="text-sm font-bold"
      description_class="text-sm text-neutral-600 dark:text-neutral-400"
      arrow_class="relative block w-3 h-1.5 overflow-clip group-data-[side=bottom]:top-[-6px] group-data-[side=left]:right-[-9px] group-data-[side=left]:rotate-90 group-data-[side=right]:left-[-9px] group-data-[side=right]:-rotate-90 group-data-[side=top]:bottom-[-6px] group-data-[side=top]:rotate-180 before:content-[''] before:absolute before:bottom-0 before:left-1/2 before:w-[calc(6px*sqrt(2))] before:h-[calc(6px*sqrt(2))] before:bg-white dark:before:bg-neutral-950 before:border before:border-neutral-950 dark:before:border-white before:[transform:translate(-50%,50%)_rotate(45deg)]"
    >
      <:trigger>Notifications</:trigger>
      <:arrow></:arrow>
      <:title>Notifications</:title>
      <:description>You are all caught up. Good job!</:description>
    </.popover>
    """
  end

  def example(%{section: "popover-open-on-hover"} = assigns) do
    ~H"""
    <.popover
      id="baseui-popover-open-on-hover"
      open_on_hover
      side_offset={8}
      trigger_class="flex h-8 items-center justify-center border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm font-normal whitespace-nowrap text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 data-[popup-open]:bg-neutral-100 dark:data-[popup-open]:bg-neutral-800 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      popup_class="group relative flex h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] max-w-[500px] flex-col gap-1 origin-[var(--transform-origin)] bg-white dark:bg-neutral-950 p-3 text-neutral-950 dark:text-white outline-none border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
      title_class="text-sm font-bold"
      description_class="text-sm text-neutral-600 dark:text-neutral-400"
      arrow_class="relative block w-3 h-1.5 overflow-clip group-data-[side=bottom]:top-[-6px] group-data-[side=left]:right-[-9px] group-data-[side=left]:rotate-90 group-data-[side=right]:left-[-9px] group-data-[side=right]:-rotate-90 group-data-[side=top]:bottom-[-6px] group-data-[side=top]:rotate-180 before:content-[''] before:absolute before:bottom-0 before:left-1/2 before:w-[calc(6px*sqrt(2))] before:h-[calc(6px*sqrt(2))] before:bg-white dark:before:bg-neutral-950 before:border before:border-neutral-950 dark:before:border-white before:[transform:translate(-50%,50%)_rotate(45deg)]"
    >
      <:trigger>Notifications</:trigger>
      <:arrow></:arrow>
      <:title>Notifications</:title>
      <:description>You are all caught up. Good job!</:description>
    </.popover>
    """
  end

  def example(%{section: "popover-detached-triggers-simple"} = assigns) do
    ~H"""
    <.popover
      id="baseui-popover-detached-triggers-simple"
      side_offset={8}
      trigger_class="flex h-8 items-center justify-center border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm font-normal whitespace-nowrap text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 data-[popup-open]:bg-neutral-100 dark:data-[popup-open]:bg-neutral-800 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      popup_class="group relative flex h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] max-w-[500px] flex-col gap-1 origin-[var(--transform-origin)] bg-white dark:bg-neutral-950 p-3 text-neutral-950 dark:text-white outline-none border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
      title_class="text-sm font-bold"
      description_class="text-sm text-neutral-600 dark:text-neutral-400"
      arrow_class="relative block w-3 h-1.5 overflow-clip group-data-[side=bottom]:top-[-6px] group-data-[side=left]:right-[-9px] group-data-[side=left]:rotate-90 group-data-[side=right]:left-[-9px] group-data-[side=right]:-rotate-90 group-data-[side=top]:bottom-[-6px] group-data-[side=top]:rotate-180 before:content-[''] before:absolute before:bottom-0 before:left-1/2 before:w-[calc(6px*sqrt(2))] before:h-[calc(6px*sqrt(2))] before:bg-white dark:before:bg-neutral-950 before:border before:border-neutral-950 dark:before:border-white before:[transform:translate(-50%,50%)_rotate(45deg)]"
    >
      <:trigger>Notifications</:trigger>
      <:arrow></:arrow>
      <:title>Notifications</:title>
      <:description>You are all caught up. Good job!</:description>
    </.popover>
    """
  end

  def example(%{section: "popover-detached-triggers-full"} = assigns) do
    ~H"""
    <.popover
      id="baseui-popover-detached-triggers-full"
      side_offset={8}
      trigger_class="flex h-8 items-center justify-center border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm font-normal whitespace-nowrap text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 data-[popup-open]:bg-neutral-100 dark:data-[popup-open]:bg-neutral-800 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      popup_class="group relative flex h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] max-w-[31.25rem] flex-col gap-1 origin-[var(--transform-origin)] bg-white dark:bg-neutral-950 p-2 text-neutral-950 dark:text-white outline-none border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[width,height,opacity,scale] duration-[0.35s] ease-[cubic-bezier(0.22,1,0.36,1)] data-[ending-style]:scale-90 data-[ending-style]:opacity-0 data-[starting-style]:scale-90 data-[starting-style]:opacity-0"
      arrow_class="relative block w-3 h-1.5 overflow-clip transition-[left] duration-[0.35s] ease-[cubic-bezier(0.22,1,0.36,1)] group-data-[side=bottom]:top-[-6px] group-data-[side=left]:right-[-9px] group-data-[side=left]:rotate-90 group-data-[side=right]:left-[-9px] group-data-[side=right]:-rotate-90 group-data-[side=top]:bottom-[-6px] group-data-[side=top]:rotate-180 before:content-[''] before:absolute before:bottom-0 before:left-1/2 before:w-[calc(6px*sqrt(2))] before:h-[calc(6px*sqrt(2))] before:bg-white dark:before:bg-neutral-950 before:border before:border-neutral-950 dark:before:border-white before:[transform:translate(-50%,50%)_rotate(45deg)]"
    >
      <:trigger>Profile</:trigger>
      <:arrow></:arrow>
      <div class="grid w-max grid-cols-[auto_auto] gap-x-2">
        <h2 class="col-start-2 col-end-3 row-start-1 row-end-2 text-sm font-bold">
          Jason Eventon
        </h2>
        <span class="col-start-1 col-end-2 row-start-1 row-end-3 inline-flex h-12 w-12 items-center justify-center overflow-hidden bg-neutral-200 dark:bg-neutral-800 align-middle text-sm leading-none font-bold text-neutral-950 dark:text-white select-none">
          <img
            src="https://images.unsplash.com/photo-1543610892-0b1f7e6d8ac1?w=128&h=128&dpr=2&q=80"
            width="48"
            height="48"
            class="h-full w-full object-cover"
          />
        </span>
        <span class="col-start-2 col-end-3 row-start-2 row-end-3 text-sm text-neutral-600 dark:text-neutral-400">
          Pro plan
        </span>
        <div class="col-start-1 col-end-3 row-start-3 row-end-4 flex flex-col gap-2 pt-2 text-sm">
          <a
            href="#"
            class="text-neutral-950 dark:text-white underline underline-offset-[0.16em] decoration-[1px] hover:no-underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
          >
            Profile settings
          </a>
          <a
            href="#"
            class="text-neutral-950 dark:text-white underline underline-offset-[0.16em] decoration-[1px] hover:no-underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
          >
            Log out
          </a>
        </div>
      </div>
    </.popover>
    """
  end

  def example(%{section: "popover-detached-triggers-controlled"} = assigns) do
    ~H"""
    <.popover
      id="baseui-popover-detached-triggers-controlled"
      side_offset={8}
      trigger_class="flex h-8 items-center justify-center border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 px-3 text-sm font-normal whitespace-nowrap text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 data-[popup-open]:bg-neutral-100 dark:data-[popup-open]:bg-neutral-800 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      popup_class="group relative flex h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] max-w-[500px] flex-col gap-1 origin-[var(--transform-origin)] bg-white dark:bg-neutral-950 p-3 text-neutral-950 dark:text-white outline-none border border-neutral-950 dark:border-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
      title_class="text-sm font-bold"
      description_class="text-sm text-neutral-600 dark:text-neutral-400"
      arrow_class="relative block w-3 h-1.5 overflow-clip group-data-[side=bottom]:top-[-6px] group-data-[side=left]:right-[-9px] group-data-[side=left]:rotate-90 group-data-[side=right]:left-[-9px] group-data-[side=right]:-rotate-90 group-data-[side=top]:bottom-[-6px] group-data-[side=top]:rotate-180 before:content-[''] before:absolute before:bottom-0 before:left-1/2 before:w-[calc(6px*sqrt(2))] before:h-[calc(6px*sqrt(2))] before:bg-white dark:before:bg-neutral-950 before:border before:border-neutral-950 dark:before:border-white before:[transform:translate(-50%,50%)_rotate(45deg)]"
    >
      <:trigger>Trigger 1</:trigger>
      <:arrow></:arrow>
      <:title>Notifications</:title>
      <:description>You are all caught up. Good job!</:description>
    </.popover>
    """
  end

  def example(%{section: "preview_card-hero"} = assigns) do
    ~H"""
    <p class="m-0 text-base text-neutral-950 text-balance dark:text-white">
      The principles of good
      <.preview_card
        id="baseui-preview_card-hero"
        side_offset={8}
        class="inline"
        trigger_class="cursor-pointer text-neutral-950 underline decoration-neutral-950/60 decoration-1 underline-offset-2 outline-0 hover:decoration-neutral-950 data-[popup-open]:decoration-neutral-950 focus-visible:no-underline focus-visible:outline-2 focus-visible:outline-neutral-950 dark:text-white dark:decoration-white/60 dark:hover:decoration-white dark:data-[popup-open]:decoration-white dark:focus-visible:outline-white"
        popup_class="group relative h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[transform,opacity] duration-100 ease-out data-[ending-style]:[transform:scale(0.98)] data-[ending-style]:opacity-0 data-[starting-style]:[transform:scale(0.98)] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
        arrow_class="relative block h-1.5 w-3 overflow-clip group-data-[side=bottom]:top-[-6px] group-data-[side=left]:right-[-9px] group-data-[side=left]:rotate-90 group-data-[side=right]:left-[-9px] group-data-[side=right]:-rotate-90 group-data-[side=top]:bottom-[-6px] group-data-[side=top]:rotate-180 before:absolute before:bottom-0 before:left-1/2 before:h-[calc(6px*sqrt(2))] before:w-[calc(6px*sqrt(2))] before:border before:border-neutral-950 before:bg-white before:content-[''] before:[transform:translate(-50%,50%)_rotate(45deg)] dark:before:border-white dark:before:bg-neutral-950"
      >
        <:trigger>typography</:trigger>
        <:arrow></:arrow>
        <div class="flex w-min flex-col gap-2 p-2">
          <img
            width="224"
            height="150"
            class="block max-w-none"
            src="https://images.unsplash.com/photo-1619615391095-dfa29e1672ef?q=80&w=448&h=300"
            alt="Station Hofplein signage in Rotterdam, Netherlands"
          />
          <p class="m-0 text-sm text-pretty">
            <strong>Typography</strong> is the art and science of arranging type to make written
            language clear, visually appealing, and effective in communication.
          </p>
        </div>
      </.preview_card>
      remain in the digital age.
    </p>
    """
  end

  def example(%{section: "preview_card-detached-triggers-simple"} = assigns) do
    ~H"""
    <p class="m-0 text-base text-neutral-950 text-balance dark:text-white">
      The principles of good
      <.preview_card
        id="baseui-preview_card-detached-triggers-simple"
        side_offset={8}
        class="inline"
        trigger_class="cursor-pointer text-neutral-950 underline decoration-neutral-950/60 decoration-1 underline-offset-2 outline-0 hover:decoration-neutral-950 data-[popup-open]:decoration-neutral-950 focus-visible:no-underline focus-visible:outline-2 focus-visible:outline-neutral-950 dark:text-white dark:decoration-white/60 dark:hover:decoration-white dark:data-[popup-open]:decoration-white dark:focus-visible:outline-white"
        popup_class="group relative h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[transform,opacity] duration-100 ease-out data-[ending-style]:[transform:scale(0.98)] data-[ending-style]:opacity-0 data-[starting-style]:[transform:scale(0.98)] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
        arrow_class="relative block h-1.5 w-3 overflow-clip group-data-[side=bottom]:top-[-6px] group-data-[side=left]:right-[-9px] group-data-[side=left]:rotate-90 group-data-[side=right]:left-[-9px] group-data-[side=right]:-rotate-90 group-data-[side=top]:bottom-[-6px] group-data-[side=top]:rotate-180 before:absolute before:bottom-0 before:left-1/2 before:h-[calc(6px*sqrt(2))] before:w-[calc(6px*sqrt(2))] before:border before:border-neutral-950 before:bg-white before:content-[''] before:[transform:translate(-50%,50%)_rotate(45deg)] dark:before:border-white dark:before:bg-neutral-950"
      >
        <:trigger>typography</:trigger>
        <:arrow></:arrow>
        <div class="flex w-min flex-col gap-2 p-2">
          <img
            width="224"
            height="150"
            class="block max-w-none"
            src="https://images.unsplash.com/photo-1619615391095-dfa29e1672ef?q=80&w=448&h=300"
            alt="Station Hofplein signage in Rotterdam, Netherlands"
          />
          <p class="m-0 text-sm text-pretty">
            <strong>Typography</strong> is the art and science of arranging type to make
            written language clear, visually appealing, and effective in communication.
          </p>
        </div>
      </.preview_card>
      remain in the digital age.
    </p>
    """
  end

  def example(%{section: "preview_card-detached-triggers-controlled"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-baseline justify-center gap-2">
      <p class="m-0 text-base text-neutral-950 text-balance dark:text-white">
        Discover
        <.preview_card
          id="baseui-preview_card-detached-triggers-controlled-typography"
          side_offset={8}
          class="inline"
          trigger_class="cursor-pointer text-neutral-950 underline decoration-neutral-950/60 decoration-1 underline-offset-2 outline-0 hover:decoration-neutral-950 data-[popup-open]:decoration-neutral-950 focus-visible:no-underline focus-visible:outline-2 focus-visible:outline-neutral-950 dark:text-white dark:decoration-white/60 dark:hover:decoration-white dark:data-[popup-open]:decoration-white dark:focus-visible:outline-white"
          popup_class="group relative h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[transform,opacity] duration-100 ease-out data-[ending-style]:[transform:scale(0.98)] data-[ending-style]:opacity-0 data-[starting-style]:[transform:scale(0.98)] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
          arrow_class="relative block h-1.5 w-3 overflow-clip group-data-[side=bottom]:top-[-6px] group-data-[side=left]:right-[-9px] group-data-[side=left]:rotate-90 group-data-[side=right]:left-[-9px] group-data-[side=right]:-rotate-90 group-data-[side=top]:bottom-[-6px] group-data-[side=top]:rotate-180 before:absolute before:bottom-0 before:left-1/2 before:h-[calc(6px*sqrt(2))] before:w-[calc(6px*sqrt(2))] before:border before:border-neutral-950 before:bg-white before:content-[''] before:[transform:translate(-50%,50%)_rotate(45deg)] dark:before:border-white dark:before:bg-neutral-950"
        >
          <:trigger>typography</:trigger>
          <:arrow></:arrow>
          <div class="flex w-min flex-col gap-2 p-2">
            <img
              width="224"
              height="150"
              class="block max-w-none"
              src="https://images.unsplash.com/photo-1619615391095-dfa29e1672ef?q=80&w=448&h=300"
              alt="Station Hofplein signage in Rotterdam, Netherlands"
            />
            <p class="m-0 text-sm text-pretty">
              <strong>Typography</strong> is the art and science of arranging type.
            </p>
          </div>
        </.preview_card>
        ,
        <.preview_card
          id="baseui-preview_card-detached-triggers-controlled-design"
          side_offset={8}
          class="inline"
          trigger_class="cursor-pointer text-neutral-950 underline decoration-neutral-950/60 decoration-1 underline-offset-2 outline-0 hover:decoration-neutral-950 data-[popup-open]:decoration-neutral-950 focus-visible:no-underline focus-visible:outline-2 focus-visible:outline-neutral-950 dark:text-white dark:decoration-white/60 dark:hover:decoration-white dark:data-[popup-open]:decoration-white dark:focus-visible:outline-white"
          popup_class="group relative h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[transform,opacity] duration-100 ease-out data-[ending-style]:[transform:scale(0.98)] data-[ending-style]:opacity-0 data-[starting-style]:[transform:scale(0.98)] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
          arrow_class="relative block h-1.5 w-3 overflow-clip group-data-[side=bottom]:top-[-6px] group-data-[side=left]:right-[-9px] group-data-[side=left]:rotate-90 group-data-[side=right]:left-[-9px] group-data-[side=right]:-rotate-90 group-data-[side=top]:bottom-[-6px] group-data-[side=top]:rotate-180 before:absolute before:bottom-0 before:left-1/2 before:h-[calc(6px*sqrt(2))] before:w-[calc(6px*sqrt(2))] before:border before:border-neutral-950 before:bg-white before:content-[''] before:[transform:translate(-50%,50%)_rotate(45deg)] dark:before:border-white dark:before:bg-neutral-950"
        >
          <:trigger>design</:trigger>
          <:arrow></:arrow>
          <div class="flex w-min flex-col gap-2 p-2">
            <img
              width="241"
              height="240"
              class="block max-w-none"
              src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Braun_ABW30_%28schwarz%29.jpg/250px-Braun_ABW30_%28schwarz%29.jpg"
              alt="Braun ABW30"
            />
            <p class="m-0 text-sm text-pretty">
              A <strong>design</strong> is the concept or proposal for an object, process, or system.
            </p>
          </div>
        </.preview_card>
        , or
        <.preview_card
          id="baseui-preview_card-detached-triggers-controlled-art"
          side_offset={8}
          class="inline"
          trigger_class="cursor-pointer text-neutral-950 underline decoration-neutral-950/60 decoration-1 underline-offset-2 outline-0 hover:decoration-neutral-950 data-[popup-open]:decoration-neutral-950 focus-visible:no-underline focus-visible:outline-2 focus-visible:outline-neutral-950 dark:text-white dark:decoration-white/60 dark:hover:decoration-white dark:data-[popup-open]:decoration-white dark:focus-visible:outline-white"
          popup_class="group relative h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[transform,opacity] duration-100 ease-out data-[ending-style]:[transform:scale(0.98)] data-[ending-style]:opacity-0 data-[starting-style]:[transform:scale(0.98)] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
          arrow_class="relative block h-1.5 w-3 overflow-clip group-data-[side=bottom]:top-[-6px] group-data-[side=left]:right-[-9px] group-data-[side=left]:rotate-90 group-data-[side=right]:left-[-9px] group-data-[side=right]:-rotate-90 group-data-[side=top]:bottom-[-6px] group-data-[side=top]:rotate-180 before:absolute before:bottom-0 before:left-1/2 before:h-[calc(6px*sqrt(2))] before:w-[calc(6px*sqrt(2))] before:border before:border-neutral-950 before:bg-white before:content-[''] before:[transform:translate(-50%,50%)_rotate(45deg)] dark:before:border-white dark:before:bg-neutral-950"
        >
          <:trigger>art</:trigger>
          <:arrow></:arrow>
          <div class="flex w-min flex-col gap-2 p-2">
            <img
              width="206"
              height="240"
              class="block max-w-none"
              src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/MonaLisa_sfumato.jpeg/250px-MonaLisa_sfumato.jpeg"
              alt="Mona Lisa"
            />
            <p class="m-0 text-sm text-pretty">
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
        class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 font-[inherit] text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:bg-neutral-100 active:bg-neutral-200 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:bg-neutral-800 dark:active:bg-neutral-700 disabled:border-neutral-500 disabled:text-neutral-500 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      >
        Open programmatically
      </button>
    </div>
    """
  end

  def example(%{section: "preview_card-detached-triggers-full"} = assigns) do
    ~H"""
    <p class="m-0 text-base text-neutral-950 text-balance dark:text-white">
      Discover
      <.preview_card
        id="baseui-preview_card-detached-triggers-full-typography"
        side_offset={8}
        class="inline"
        trigger_class="cursor-pointer text-neutral-950 underline decoration-neutral-950/60 decoration-1 underline-offset-2 outline-0 hover:decoration-neutral-950 data-[popup-open]:decoration-neutral-950 focus-visible:no-underline focus-visible:outline-2 focus-visible:outline-neutral-950 dark:text-white dark:decoration-white/60 dark:hover:decoration-white dark:data-[popup-open]:decoration-white dark:focus-visible:outline-white"
        popup_class="group relative h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[width,height,opacity,transform] duration-[0.35s] ease-[cubic-bezier(0.22,1,0.36,1)] data-[ending-style]:[transform:scale(0.98)] data-[ending-style]:opacity-0 data-[starting-style]:[transform:scale(0.98)] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
        arrow_class="relative block h-1.5 w-3 overflow-clip group-data-[side=bottom]:top-[-6px] group-data-[side=left]:right-[-9px] group-data-[side=left]:rotate-90 group-data-[side=right]:left-[-9px] group-data-[side=right]:-rotate-90 group-data-[side=top]:bottom-[-6px] group-data-[side=top]:rotate-180 before:absolute before:bottom-0 before:left-1/2 before:h-[calc(6px*sqrt(2))] before:w-[calc(6px*sqrt(2))] before:border before:border-neutral-950 before:bg-white before:content-[''] before:[transform:translate(-50%,50%)_rotate(45deg)] dark:before:border-white dark:before:bg-neutral-950"
      >
        <:trigger>typography</:trigger>
        <:arrow></:arrow>
        <div class="flex w-min flex-col gap-2 p-2">
          <img
            width="224"
            height="150"
            class="block max-w-none"
            src="https://images.unsplash.com/photo-1619615391095-dfa29e1672ef?q=80&w=448&h=300"
            alt="Station Hofplein signage in Rotterdam, Netherlands"
          />
          <p class="m-0 text-sm text-pretty">
            <strong>Typography</strong> is the art and science of arranging type.
          </p>
        </div>
      </.preview_card>
      ,
      <.preview_card
        id="baseui-preview_card-detached-triggers-full-design"
        side_offset={8}
        class="inline"
        trigger_class="cursor-pointer text-neutral-950 underline decoration-neutral-950/60 decoration-1 underline-offset-2 outline-0 hover:decoration-neutral-950 data-[popup-open]:decoration-neutral-950 focus-visible:no-underline focus-visible:outline-2 focus-visible:outline-neutral-950 dark:text-white dark:decoration-white/60 dark:hover:decoration-white dark:data-[popup-open]:decoration-white dark:focus-visible:outline-white"
        popup_class="group relative h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[width,height,opacity,transform] duration-[0.35s] ease-[cubic-bezier(0.22,1,0.36,1)] data-[ending-style]:[transform:scale(0.98)] data-[ending-style]:opacity-0 data-[starting-style]:[transform:scale(0.98)] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
        arrow_class="relative block h-1.5 w-3 overflow-clip group-data-[side=bottom]:top-[-6px] group-data-[side=left]:right-[-9px] group-data-[side=left]:rotate-90 group-data-[side=right]:left-[-9px] group-data-[side=right]:-rotate-90 group-data-[side=top]:bottom-[-6px] group-data-[side=top]:rotate-180 before:absolute before:bottom-0 before:left-1/2 before:h-[calc(6px*sqrt(2))] before:w-[calc(6px*sqrt(2))] before:border before:border-neutral-950 before:bg-white before:content-[''] before:[transform:translate(-50%,50%)_rotate(45deg)] dark:before:border-white dark:before:bg-neutral-950"
      >
        <:trigger>design</:trigger>
        <:arrow></:arrow>
        <div class="flex w-min flex-col gap-2 p-2">
          <img
            width="250"
            height="249"
            class="block max-w-none"
            src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Braun_ABW30_%28schwarz%29.jpg/250px-Braun_ABW30_%28schwarz%29.jpg"
            alt="Braun ABW30"
          />
          <p class="m-0 text-sm text-pretty">
            A <strong>design</strong> is the concept or proposal for an object, process, or system.
          </p>
        </div>
      </.preview_card>
      , or
      <.preview_card
        id="baseui-preview_card-detached-triggers-full-art"
        side_offset={8}
        class="inline"
        trigger_class="cursor-pointer text-neutral-950 underline decoration-neutral-950/60 decoration-1 underline-offset-2 outline-0 hover:decoration-neutral-950 data-[popup-open]:decoration-neutral-950 focus-visible:no-underline focus-visible:outline-2 focus-visible:outline-neutral-950 dark:text-white dark:decoration-white/60 dark:hover:decoration-white dark:data-[popup-open]:decoration-white dark:focus-visible:outline-white"
        popup_class="group relative h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] origin-[var(--transform-origin)] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[width,height,opacity,transform] duration-[0.35s] ease-[cubic-bezier(0.22,1,0.36,1)] data-[ending-style]:[transform:scale(0.98)] data-[ending-style]:opacity-0 data-[starting-style]:[transform:scale(0.98)] data-[starting-style]:opacity-0 dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
        arrow_class="relative block h-1.5 w-3 overflow-clip group-data-[side=bottom]:top-[-6px] group-data-[side=left]:right-[-9px] group-data-[side=left]:rotate-90 group-data-[side=right]:left-[-9px] group-data-[side=right]:-rotate-90 group-data-[side=top]:bottom-[-6px] group-data-[side=top]:rotate-180 before:absolute before:bottom-0 before:left-1/2 before:h-[calc(6px*sqrt(2))] before:w-[calc(6px*sqrt(2))] before:border before:border-neutral-950 before:bg-white before:content-[''] before:[transform:translate(-50%,50%)_rotate(45deg)] dark:before:border-white dark:before:bg-neutral-950"
      >
        <:trigger>art</:trigger>
        <:arrow></:arrow>
        <div class="flex w-min flex-col gap-2 p-2">
          <img
            width="250"
            height="290"
            class="block max-w-none"
            src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/MonaLisa_sfumato.jpeg/250px-MonaLisa_sfumato.jpeg"
            alt="Mona Lisa"
          />
          <p class="m-0 text-sm text-pretty">
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

  def example(%{section: "progress-hero"} = assigns) do
    ~H"""
    <.progress
      id="baseui-progress-hero"
      value={20}
      label="Export data"
      show_value
      class="grid max-w-full w-60 grid-cols-2 gap-y-2"
      label_class="text-sm font-normal text-neutral-950 dark:text-white"
      value_class="text-right text-sm text-neutral-950 dark:text-white"
      track_class="col-span-2 h-1 overflow-hidden bg-neutral-200 dark:bg-neutral-800"
      indicator_class="bg-neutral-950 transition-[width] duration-500 dark:bg-white"
    />
    """
  end

  def example(%{section: "radio-hero"} = assigns) do
    ~H"""
    <div
      role="radiogroup"
      aria-labelledby="baseui-radio-hero-label"
      class="flex flex-col items-start gap-1 text-neutral-950 dark:text-white"
    >
      <div class="text-sm font-bold" id="baseui-radio-hero-label">
        Best apple
      </div>

      <.radio
        id="baseui-radio-hero-fuji"
        name="baseui-radio-hero"
        value="fuji-apple"
        checked
        class="flex items-center gap-2 text-sm font-normal text-neutral-950 dark:text-white"
        input_class="peer sr-only"
        indicator_class="flex size-4 shrink-0 items-center justify-center border rounded-full p-0 border-neutral-950 bg-white text-white dark:border-white dark:bg-neutral-950 dark:text-neutral-950 data-[checked]:bg-neutral-950 data-[checked]:text-white dark:data-[checked]:bg-white dark:data-[checked]:text-neutral-950 before:size-2 before:rounded-full before:bg-current data-[unchecked]:before:hidden peer-focus-visible:outline-2 peer-focus-visible:outline-offset-2 peer-focus-visible:outline-neutral-950 dark:peer-focus-visible:outline-white"
      >
        Fuji
      </.radio>

      <.radio
        id="baseui-radio-hero-gala"
        name="baseui-radio-hero"
        value="gala-apple"
        class="flex items-center gap-2 text-sm font-normal text-neutral-950 dark:text-white"
        input_class="peer sr-only"
        indicator_class="flex size-4 shrink-0 items-center justify-center border rounded-full p-0 border-neutral-950 bg-white text-white dark:border-white dark:bg-neutral-950 dark:text-neutral-950 data-[checked]:bg-neutral-950 data-[checked]:text-white dark:data-[checked]:bg-white dark:data-[checked]:text-neutral-950 before:size-2 before:rounded-full before:bg-current data-[unchecked]:before:hidden peer-focus-visible:outline-2 peer-focus-visible:outline-offset-2 peer-focus-visible:outline-neutral-950 dark:peer-focus-visible:outline-white"
      >
        Gala
      </.radio>

      <.radio
        id="baseui-radio-hero-granny"
        name="baseui-radio-hero"
        value="granny-smith-apple"
        class="flex items-center gap-2 text-sm font-normal text-neutral-950 dark:text-white"
        input_class="peer sr-only"
        indicator_class="flex size-4 shrink-0 items-center justify-center border rounded-full p-0 border-neutral-950 bg-white text-white dark:border-white dark:bg-neutral-950 dark:text-neutral-950 data-[checked]:bg-neutral-950 data-[checked]:text-white dark:data-[checked]:bg-white dark:data-[checked]:text-neutral-950 before:size-2 before:rounded-full before:bg-current data-[unchecked]:before:hidden peer-focus-visible:outline-2 peer-focus-visible:outline-offset-2 peer-focus-visible:outline-neutral-950 dark:peer-focus-visible:outline-white"
      >
        Granny Smith
      </.radio>
    </div>
    """
  end

  def example(%{section: "scroll_area-hero"} = assigns) do
    ~H"""
    <.scroll_area
      id="baseui-scroll_area-hero"
      orientation="vertical"
      class="h-[8.5rem] w-96 max-w-[calc(100vw-8rem)] bg-white dark:bg-neutral-950"
      viewport_class="h-full border border-neutral-950 dark:border-white focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      content_class="flex flex-col gap-4 py-2 pr-5 pl-3 text-sm leading-[1.375rem] text-neutral-950 dark:text-white"
      scrollbar_class="m-px flex w-4 justify-center bg-black/12 dark:bg-white/12 opacity-0 transition-opacity pointer-events-none data-[hovering]:opacity-100 data-[hovering]:pointer-events-auto data-[scrolling]:opacity-100 data-[scrolling]:duration-0 data-[scrolling]:pointer-events-auto"
      thumb_class="w-full h-[var(--scroll-area-thumb-height)] bg-neutral-950 dark:bg-white"
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
      id="baseui-scroll_area-both"
      orientation="both"
      class="h-80 w-80 max-w-[calc(100vw-8rem)]"
      viewport_class="h-full border border-neutral-950 dark:border-white focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      content_class="pt-3 pr-6 pb-6 pl-3"
      scrollbar_class="relative m-px flex bg-black/12 dark:bg-white/12 opacity-0 transition-opacity pointer-events-none data-[orientation=vertical]:w-4 data-[orientation=horizontal]:h-4 data-[hovering]:pointer-events-auto data-[hovering]:opacity-100 data-[scrolling]:pointer-events-auto data-[scrolling]:opacity-100 data-[scrolling]:duration-0"
      thumb_class="bg-neutral-950 dark:bg-white data-[orientation=vertical]:w-full data-[orientation=vertical]:h-[var(--scroll-area-thumb-height)] data-[orientation=horizontal]:h-full data-[orientation=horizontal]:w-[var(--scroll-area-thumb-width)]"
    >
      <ul class="m-0 grid list-none grid-cols-[repeat(10,6.25rem)] grid-rows-[repeat(10,6.25rem)] gap-3 p-0">
        <li
          :for={i <- 1..100}
          class="flex items-center justify-center bg-neutral-200 dark:bg-neutral-800 text-sm font-bold text-neutral-600 dark:text-neutral-400"
        >
          {i}
        </li>
      </ul>
    </.scroll_area>
    """
  end

  def example(%{section: "scroll_area-scroll-fade"} = assigns) do
    ~H"""
    <.scroll_area
      id="baseui-scroll_area-scroll-fade"
      orientation="vertical"
      class="h-48 w-96 max-w-[calc(100vw-8rem)] bg-neutral-100 dark:bg-neutral-800 has-[>_[data-part=viewport]:focus-visible]:outline-2 has-[>_[data-part=viewport]:focus-visible]:outline-offset-0 has-[>_[data-part=viewport]:focus-visible]:outline-neutral-950 dark:has-[>_[data-part=viewport]:focus-visible]:outline-white"
      viewport_class="h-full bg-neutral-100 dark:bg-neutral-800 outline-none mask-linear-[to_bottom,transparent_0,black_min(40px,var(--scroll-area-overflow-y-start)),black_calc(100%_-_min(40px,var(--scroll-area-overflow-y-end,40px))),transparent_100%] mask-no-repeat"
      content_class="flex flex-col gap-4 py-2 pr-5 pl-3 text-sm leading-[1.375rem] text-neutral-950 dark:text-white"
      scrollbar_class="m-px flex w-4 justify-center bg-black/8 dark:bg-white/12 opacity-0 transition-opacity duration-150 pointer-events-none data-[hovering]:opacity-100 data-[hovering]:pointer-events-auto data-[scrolling]:opacity-100 data-[scrolling]:duration-0 data-[scrolling]:pointer-events-auto"
      thumb_class="w-full h-[var(--scroll-area-thumb-height)] bg-neutral-950 dark:bg-white"
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

  def example(%{section: "select-hero"} = assigns) do
    ~H"""
    <.select
      id="baseui-select-hero"
      label="Apple"
      placeholder="Select apple"
      class="flex flex-col items-start gap-1"
      label_class="cursor-default text-sm font-bold text-neutral-950 dark:text-white"
      trigger_class="flex h-8 min-w-40 items-center justify-between gap-3 pl-2 pr-1 text-sm leading-none whitespace-nowrap border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 data-[popup-open]:bg-neutral-100 dark:data-[popup-open]:bg-neutral-800 font-normal focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      value_class="data-[placeholder]:text-neutral-500 dark:data-[placeholder]:text-neutral-400"
      icon_class="flex items-center"
      positioner_class="outline-hidden select-none z-10"
      popup_class="group min-w-[var(--anchor-width)] origin-[var(--transform-origin)] py-1 bg-clip-padding border border-neutral-950 bg-white text-neutral-950 outline-hidden shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[side=none]:translate-y-px data-[side=none]:min-w-[calc(var(--anchor-width)+1.75rem)] data-[side=none]:data-[ending-style]:transition-none data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 data-[side=none]:data-[starting-style]:scale-100 data-[side=none]:data-[starting-style]:opacity-100 data-[side=none]:data-[starting-style]:transition-none dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
      item_class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-1.5 pr-4 pl-2.5 text-sm outline-hidden select-none data-[highlighted]:bg-neutral-950 data-[highlighted]:text-white dark:data-[highlighted]:bg-white dark:data-[highlighted]:text-neutral-950"
      item_indicator_class="col-start-1"
      item_text_class="col-start-2"
    >
      <:icon>
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" class="block">
          <path d="M11 10H5l3 3.5zm0-4H5l3-3.5z" />
        </svg>
      </:icon>
      <:item_indicator>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          class="block"
        >
          <path d="m2.5 8.5 4 4 7-9" />
        </svg>
      </:item_indicator>
      <:option value="gala">Gala</:option>
      <:option value="fuji">Fuji</:option>
      <:option value="honeycrisp">Honeycrisp</:option>
      <:option value="granny-smith">Granny Smith</:option>
      <:option value="pink-lady">Pink Lady</:option>
    </.select>
    """
  end

  def example(%{section: "select-grouped"} = assigns) do
    ~H"""
    <.select
      id="baseui-select-grouped"
      label="Produce"
      placeholder="Select produce"
      class="flex flex-col items-start gap-1"
      label_class="cursor-default text-sm font-bold text-neutral-950 dark:text-white"
      trigger_class="flex h-8 min-w-44 items-center justify-between gap-3 pl-2 pr-1 text-sm leading-none whitespace-nowrap border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 data-[popup-open]:bg-neutral-100 dark:data-[popup-open]:bg-neutral-800 font-normal focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      value_class="data-[placeholder]:text-neutral-500 dark:data-[placeholder]:text-neutral-400"
      icon_class="flex items-center"
      positioner_class="outline-hidden select-none z-10"
      popup_class="group min-w-[var(--anchor-width)] origin-[var(--transform-origin)] py-1 bg-clip-padding border border-neutral-950 bg-white text-neutral-950 outline-hidden shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[side=none]:translate-y-px data-[side=none]:min-w-[calc(var(--anchor-width)+1.75rem)] data-[side=none]:data-[ending-style]:transition-none data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 data-[side=none]:data-[starting-style]:scale-100 data-[side=none]:data-[starting-style]:opacity-100 data-[side=none]:data-[starting-style]:transition-none dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
      group_class="block pb-0.5 last:pb-0"
      group_label_class="py-1.5 pr-4 pl-[2.125rem] text-sm leading-5 text-neutral-500 select-none dark:text-neutral-400"
      item_class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-1.5 pr-4 pl-2.5 text-sm outline-hidden select-none group-data-[side=none]:pr-12 data-[highlighted]:bg-neutral-950 data-[highlighted]:text-white dark:data-[highlighted]:bg-white dark:data-[highlighted]:text-neutral-950"
      item_indicator_class="col-start-1"
      item_text_class="col-start-2"
    >
      <:icon>
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" class="block">
          <path d="M11 10H5l3 3.5zm0-4H5l3-3.5z" />
        </svg>
      </:icon>
      <:item_indicator>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          class="block"
        >
          <path d="m2.5 8.5 4 4 7-9" />
        </svg>
      </:item_indicator>
      <:option value="apple" group="Fruits">Apple</:option>
      <:option value="banana" group="Fruits">Banana</:option>
      <:option value="mango" group="Fruits">Mango</:option>
      <:option value="kiwi" group="Fruits">Kiwi</:option>
      <:option value="grape" group="Fruits">Grape</:option>
      <:option value="orange" group="Fruits">Orange</:option>
      <:option value="strawberry" group="Fruits">Strawberry</:option>
      <:option value="watermelon" group="Fruits">Watermelon</:option>
      <:option value="broccoli" group="Vegetables">Broccoli</:option>
      <:option value="carrot" group="Vegetables">Carrot</:option>
      <:option value="cauliflower" group="Vegetables">Cauliflower</:option>
      <:option value="cucumber" group="Vegetables">Cucumber</:option>
      <:option value="kale" group="Vegetables">Kale</:option>
      <:option value="pepper" group="Vegetables">Bell pepper</:option>
      <:option value="spinach" group="Vegetables">Spinach</:option>
      <:option value="zucchini" group="Vegetables">Zucchini</:option>
    </.select>
    """
  end

  def example(%{section: "select-multiple"} = assigns) do
    ~H"""
    <.select
      id="baseui-select-multiple"
      label="Languages"
      multiple
      value={["javascript", "typescript"]}
      placeholder="Select languages"
      class="flex flex-col items-start gap-1"
      label_class="cursor-default text-sm font-bold text-neutral-950 dark:text-white"
      trigger_class="flex h-8 min-w-[14rem] items-center justify-between gap-3 pl-2 pr-1 text-sm leading-none whitespace-nowrap border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 data-[popup-open]:bg-neutral-100 dark:data-[popup-open]:bg-neutral-800 font-normal focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      value_class="data-[placeholder]:text-neutral-500 dark:data-[placeholder]:text-neutral-400"
      icon_class="flex items-center"
      positioner_class="outline-hidden z-10"
      popup_class="group max-h-[var(--available-height)] min-w-[var(--anchor-width)] origin-[var(--transform-origin)] bg-clip-padding overflow-y-auto border border-neutral-950 bg-white py-1 text-neutral-950 outline-hidden shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[side=none]:min-w-[calc(var(--anchor-width)+1.75rem)] data-[side=none]:data-[ending-style]:transition-none data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 data-[side=none]:data-[starting-style]:scale-100 data-[side=none]:data-[starting-style]:opacity-100 data-[side=none]:data-[starting-style]:transition-none dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
      item_class="grid cursor-default grid-cols-[1rem_1fr] items-center gap-2 py-1.5 pr-2.5 pl-2.5 text-sm outline-hidden select-none scroll-my-1 [@media(hover:hover)]:data-[highlighted]:bg-neutral-950 [@media(hover:hover)]:data-[highlighted]:text-white dark:[@media(hover:hover)]:data-[highlighted]:bg-white dark:[@media(hover:hover)]:data-[highlighted]:text-neutral-950"
      item_indicator_class="col-start-1"
      item_text_class="col-start-2"
    >
      <:icon>
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" class="block">
          <path d="M11 10H5l3 3.5zm0-4H5l3-3.5z" />
        </svg>
      </:icon>
      <:item_indicator>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          class="block"
        >
          <path d="m2.5 8.5 4 4 7-9" />
        </svg>
      </:item_indicator>
      <:option value="javascript">JavaScript</:option>
      <:option value="typescript">TypeScript</:option>
      <:option value="python">Python</:option>
      <:option value="java">Java</:option>
      <:option value="csharp">C#</:option>
      <:option value="php">PHP</:option>
      <:option value="cpp">C++</:option>
      <:option value="rust">Rust</:option>
      <:option value="go">Go</:option>
      <:option value="swift">Swift</:option>
    </.select>
    """
  end

  def example(%{section: "select-object-values"} = assigns) do
    ~H"""
    <.select
      id="baseui-select-object-values"
      label="Shipping method"
      value="standard"
      class="flex flex-col items-start gap-1"
      label_class="cursor-default text-sm font-bold text-neutral-950 dark:text-white"
      trigger_class="flex min-h-8 min-w-[16rem] items-center justify-between gap-3 pl-2 pr-1 py-1.5 text-sm leading-none whitespace-nowrap border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 data-[popup-open]:bg-neutral-100 dark:data-[popup-open]:bg-neutral-800 font-normal focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      icon_class="flex items-center"
      positioner_class="outline-hidden select-none z-10"
      popup_class="group min-w-[var(--anchor-width)] origin-[var(--transform-origin)] py-1 bg-clip-padding border border-neutral-950 bg-white text-neutral-950 outline-hidden shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[side=none]:translate-y-px data-[side=none]:min-w-[calc(var(--anchor-width)+1.75rem)] data-[side=none]:data-[ending-style]:transition-none data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0 data-[side=none]:data-[starting-style]:scale-100 data-[side=none]:data-[starting-style]:opacity-100 data-[side=none]:data-[starting-style]:transition-none dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
      item_class="group/item grid cursor-default grid-cols-[1rem_1fr] items-start gap-2 py-1.5 pr-4 pl-2.5 text-sm outline-hidden select-none data-[highlighted]:bg-neutral-950 data-[highlighted]:text-white dark:data-[highlighted]:bg-white dark:data-[highlighted]:text-neutral-950"
      item_indicator_class="col-start-1 flex items-center justify-center self-start relative top-[0.4em]"
      item_text_class="col-start-2 flex flex-col gap-0.5"
    >
      <:icon>
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" class="block">
          <path d="M11 10H5l3 3.5zm0-4H5l3-3.5z" />
        </svg>
      </:icon>
      <:item_indicator>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          stroke="currentColor"
          class="block"
        >
          <path d="m2.5 8.5 4 4 7-9" />
        </svg>
      </:item_indicator>
      <:option value="standard">
        <span class="text-sm">Standard</span>
        <span class="text-xs text-neutral-600 group-data-[highlighted]/item:text-neutral-400 dark:text-neutral-400 dark:group-data-[highlighted]/item:text-neutral-600">
          Delivers in 4-6 business days ($4.99)
        </span>
      </:option>
      <:option value="express">
        <span class="text-sm">Express</span>
        <span class="text-xs text-neutral-600 group-data-[highlighted]/item:text-neutral-400 dark:text-neutral-400 dark:group-data-[highlighted]/item:text-neutral-600">
          Delivers in 2-3 business days ($9.99)
        </span>
      </:option>
      <:option value="overnight">
        <span class="text-sm">Overnight</span>
        <span class="text-xs text-neutral-600 group-data-[highlighted]/item:text-neutral-400 dark:text-neutral-400 dark:group-data-[highlighted]/item:text-neutral-600">
          Delivers next business day ($19.99)
        </span>
      </:option>
    </.select>
    """
  end

  def example(%{section: "separator-hero"} = assigns) do
    ~H"""
    <div class="flex gap-4 text-nowrap">
      <a
        href="#"
        class="text-sm text-neutral-950 decoration-neutral-300 decoration-1 underline-offset-2 hover:underline focus-visible:no-underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:decoration-neutral-700"
      >
        Home
      </a>
      <a
        href="#"
        class="text-sm text-neutral-950 decoration-neutral-300 decoration-1 underline-offset-2 hover:underline focus-visible:no-underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:decoration-neutral-700"
      >
        Pricing
      </a>
      <a
        href="#"
        class="text-sm text-neutral-950 decoration-neutral-300 decoration-1 underline-offset-2 hover:underline focus-visible:no-underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:decoration-neutral-700"
      >
        Blog
      </a>
      <a
        href="#"
        class="text-sm text-neutral-950 decoration-neutral-300 decoration-1 underline-offset-2 hover:underline focus-visible:no-underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:decoration-neutral-700"
      >
        Support
      </a>

      <.separator
        id="baseui-separator-hero"
        orientation="vertical"
        class="w-px bg-neutral-300 dark:bg-neutral-700"
      />

      <a
        href="#"
        class="text-sm text-neutral-950 decoration-neutral-300 decoration-1 underline-offset-2 hover:underline focus-visible:no-underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:decoration-neutral-700"
      >
        Log in
      </a>
      <a
        href="#"
        class="text-sm text-neutral-950 decoration-neutral-300 decoration-1 underline-offset-2 hover:underline focus-visible:no-underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:text-white dark:decoration-neutral-700"
      >
        Sign up
      </a>
    </div>
    """
  end

  def example(%{section: "slider-hero"} = assigns) do
    ~H"""
    <.slider
      id="baseui-slider-hero"
      value={25}
      label="Volume"
      control_class="flex w-56 touch-none items-center py-3 select-none"
      track_class="h-1 w-full bg-neutral-200 select-none dark:bg-neutral-800"
      indicator_class="bg-neutral-950 select-none dark:bg-white"
      thumb_class="size-4 border border-neutral-950 bg-white select-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:border-white dark:bg-neutral-950"
    />
    """
  end

  def example(%{section: "slider-range-slider"} = assigns) do
    ~H"""
    <.slider
      id="baseui-slider-range-slider"
      values={[25, 45]}
      thumb_labels={["Minimum value", "Maximum value"]}
      control_class="flex w-56 touch-none items-center py-3 select-none"
      track_class="h-1 w-full bg-neutral-200 select-none dark:bg-neutral-800"
      indicator_class="bg-neutral-950 select-none dark:bg-white"
      thumb_class="size-4 border border-neutral-950 bg-white select-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:border-white dark:bg-neutral-950"
    />
    """
  end

  def example(%{section: "slider-edge-alignment"} = assigns) do
    ~H"""
    <.slider
      id="baseui-slider-edge-alignment"
      value={25}
      label="Volume"
      control_class="flex w-56 touch-none items-center py-3 select-none"
      track_class="h-1 w-full bg-neutral-200 select-none dark:bg-neutral-800"
      indicator_class="bg-neutral-950 select-none dark:bg-white"
      thumb_class="size-4 border border-neutral-950 bg-white select-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:border-white dark:bg-neutral-950"
    />
    """
  end

  def example(%{section: "slider-vertical"} = assigns) do
    ~H"""
    <.slider
      id="baseui-slider-vertical"
      value={35}
      orientation="vertical"
      label="Volume"
      control_class="flex touch-none select-none data-[orientation=vertical]:h-32 data-[orientation=vertical]:px-3"
      track_class="bg-neutral-200 select-none dark:bg-neutral-800 data-[orientation=vertical]:h-full data-[orientation=vertical]:w-1"
      indicator_class="bg-neutral-950 select-none dark:bg-white"
      thumb_class="size-4 border border-neutral-950 bg-white select-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:border-white dark:bg-neutral-950"
    />
    """
  end

  def example(%{section: "switch-hero"} = assigns) do
    ~H"""
    <.switch
      id="baseui-switch-hero"
      checked
      class="group inline-flex items-center gap-2 text-sm font-normal text-neutral-950 select-none dark:text-white focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      track_class="flex h-5 w-9 shrink-0 items-center border border-neutral-950 bg-white p-0.5 transition-colors duration-150 ease-[ease] dark:border-white dark:bg-neutral-950 group-data-[checked]:bg-neutral-950 dark:group-data-[checked]:bg-white"
      thumb_class="block size-3.5 bg-neutral-950 transition-[translate,background-color] duration-150 ease-[ease] data-[checked]:translate-x-4 data-[checked]:bg-white dark:bg-white dark:data-[checked]:bg-neutral-950"
    >
      Notifications
    </.switch>
    """
  end

  def example(%{section: "tabs-hero"} = assigns) do
    ~H"""
    <.tabs
      id="baseui-tabs-hero"
      default_value="overview"
      class="w-full max-w-xs"
      list_class="relative z-1 -mb-px flex gap-1"
      indicator_class="absolute top-0 left-0 -z-1 h-full w-(--active-tab-width) translate-x-(--active-tab-left) border-x border-t border-neutral-950 bg-white transition-[translate,width] duration-150 ease-in-out dark:border-white dark:bg-neutral-950"
      panels_class="grid w-full min-h-32 grid-cols-1 border border-neutral-950 dark:border-white"
    >
      <:tab
        value="overview"
        class="flex h-[calc(2rem+1px)] items-center justify-center bg-transparent px-2 py-0 font-inherit text-sm font-normal leading-5 break-keep whitespace-nowrap text-neutral-600 outline-none select-none hover:text-neutral-950 focus-visible:outline-2 focus-visible:outline-solid focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white data-[active]:text-neutral-950 dark:text-neutral-300 dark:hover:text-white dark:data-[active]:text-white"
      >
        Overview
      </:tab>
      <:tab
        value="projects"
        class="flex h-[calc(2rem+1px)] items-center justify-center bg-transparent px-2 py-0 font-inherit text-sm font-normal leading-5 break-keep whitespace-nowrap text-neutral-600 outline-none select-none hover:text-neutral-950 focus-visible:outline-2 focus-visible:outline-solid focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white data-[active]:text-neutral-950 dark:text-neutral-300 dark:hover:text-white dark:data-[active]:text-white"
      >
        Projects
      </:tab>
      <:tab
        value="account"
        class="flex h-[calc(2rem+1px)] items-center justify-center bg-transparent px-2 py-0 font-inherit text-sm font-normal leading-5 break-keep whitespace-nowrap text-neutral-600 outline-none select-none hover:text-neutral-950 focus-visible:outline-2 focus-visible:outline-solid focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white data-[active]:text-neutral-950 dark:text-neutral-300 dark:hover:text-white dark:data-[active]:text-white"
      >
        Account
      </:tab>

      <:panel
        value="overview"
        class="col-start-1 row-start-1 flex w-full items-center justify-center bg-white p-4 text-center text-sm text-neutral-950 outline-none focus-visible:z-1 focus-visible:outline-2 focus-visible:outline-solid focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:bg-neutral-950 dark:text-white [&[hidden]]:hidden"
      >
        <p>Workspace stats and activity.</p>
      </:panel>
      <:panel
        value="projects"
        class="col-start-1 row-start-1 flex w-full items-center justify-center bg-white p-4 text-center text-sm text-neutral-950 outline-none focus-visible:z-1 focus-visible:outline-2 focus-visible:outline-solid focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:bg-neutral-950 dark:text-white [&[hidden]]:hidden"
      >
        <p>Milestones and deadlines.</p>
      </:panel>
      <:panel
        value="account"
        class="col-start-1 row-start-1 flex w-full items-center justify-center bg-white p-4 text-center text-sm text-neutral-950 outline-none focus-visible:z-1 focus-visible:outline-2 focus-visible:outline-solid focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white dark:bg-neutral-950 dark:text-white [&[hidden]]:hidden"
      >
        <p>Profile and preferences.</p>
      </:panel>
    </.tabs>
    """
  end

  def example(%{section: "toast-hero"} = assigns) do
    ~H"""
    <.toast
      id="baseui-toast-hero"
      trigger_class="flex h-8 items-center justify-center gap-2 rounded-none border border-neutral-950 bg-white px-3 py-0 font-[inherit] text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:bg-neutral-100 active:bg-neutral-200 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:bg-neutral-800 dark:active:bg-neutral-700 disabled:border-neutral-500 disabled:text-neutral-500 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      viewport_class="fixed top-auto right-[1rem] bottom-[1rem] z-[1] mx-auto w-[calc(100vw-2rem)] sm:right-[2rem] sm:bottom-[2rem] sm:w-[22.5rem]"
      toast_class="[--gap:0.75rem] [--peek:0.75rem] [--scale:calc(max(0,1-(var(--toast-index)*0.1)))] [--shrink:calc(1-var(--scale))] [--height:var(--toast-frontmost-height,var(--toast-height))] [--offset-y:calc(var(--toast-offset-y)*-1+calc(var(--toast-index)*var(--gap)*-1)+var(--toast-swipe-movement-y))] absolute right-0 bottom-0 left-auto z-[calc(1000-var(--toast-index))] mr-0 w-full origin-bottom [transform:translateX(var(--toast-swipe-movement-x))_translateY(calc(var(--toast-swipe-movement-y)-(var(--toast-index)*var(--peek))-(var(--shrink)*var(--height))))_scale(var(--scale))] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 select-none dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none after:absolute after:top-full after:left-0 after:h-[calc(var(--gap)+1px)] after:w-full after:content-[''] data-[ending-style]:opacity-0 data-[expanded]:[transform:translateX(var(--toast-swipe-movement-x))_translateY(calc(var(--offset-y)))] data-[limited]:opacity-0 data-[starting-style]:[transform:translateY(150%)] [&[data-ending-style]:not([data-limited]):not([data-swipe-direction])]:[transform:translateY(150%)] data-[ending-style]:data-[swipe-direction=down]:[transform:translateY(calc(var(--toast-swipe-movement-y)+150%))] data-[expanded]:data-[ending-style]:data-[swipe-direction=down]:[transform:translateY(calc(var(--toast-swipe-movement-y)+150%))] data-[ending-style]:data-[swipe-direction=left]:[transform:translateX(calc(var(--toast-swipe-movement-x)-150%))_translateY(var(--offset-y))] data-[expanded]:data-[ending-style]:data-[swipe-direction=left]:[transform:translateX(calc(var(--toast-swipe-movement-x)-150%))_translateY(var(--offset-y))] data-[ending-style]:data-[swipe-direction=right]:[transform:translateX(calc(var(--toast-swipe-movement-x)+150%))_translateY(var(--offset-y))] data-[expanded]:data-[ending-style]:data-[swipe-direction=right]:[transform:translateX(calc(var(--toast-swipe-movement-x)+150%))_translateY(var(--offset-y))] data-[ending-style]:data-[swipe-direction=up]:[transform:translateY(calc(var(--toast-swipe-movement-y)-150%))] data-[expanded]:data-[ending-style]:data-[swipe-direction=up]:[transform:translateY(calc(var(--toast-swipe-movement-y)-150%))] h-[var(--height)] data-[expanded]:h-[var(--toast-height)] [transition:transform_0.5s_cubic-bezier(0.22,1,0.36,1),opacity_0.5s,height_0.15s]"
      content_class="flex h-full items-center gap-4 p-3 overflow-hidden transition-opacity duration-[250ms] ease-[cubic-bezier(0.22,1,0.36,1)] data-[behind]:opacity-0 data-[expanded]:opacity-100"
      close_class="flex h-8 shrink-0 items-center justify-center gap-2 rounded-none border border-neutral-950 bg-white px-3 py-0 font-[inherit] text-sm leading-none whitespace-nowrap font-normal text-neutral-950 hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
    >
      <:trigger>Create toast</:trigger>
      <:close>Dismiss</:close>
      <:template>
        <div class="flex min-w-0 flex-1 flex-col gap-1">
          <div class="text-sm font-bold">Toast <span data-toast-count></span> created</div>
          <div class="text-sm">This is a toast notification.</div>
        </div>
      </:template>
    </.toast>
    """
  end

  def example(%{section: "toast-position"} = assigns) do
    ~H"""
    <.toast
      id="baseui-toast-position"
      trigger_class="flex h-8 items-center justify-center gap-2 rounded-none border border-neutral-950 bg-white px-3 py-0 font-[inherit] text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:bg-neutral-100 active:bg-neutral-200 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:bg-neutral-800 dark:active:bg-neutral-700 disabled:border-neutral-500 disabled:text-neutral-500 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      viewport_class="fixed top-[1rem] right-0 bottom-auto left-0 z-[1] mx-auto w-[calc(100vw-2rem)] max-w-[22.5rem]"
      toast_class="[--gap:0.75rem] [--peek:0.75rem] [--scale:calc(max(0,1-(var(--toast-index)*0.1)))] [--shrink:calc(1-var(--scale))] [--height:var(--toast-frontmost-height,var(--toast-height))] [--offset-y:calc(var(--toast-offset-y)+(var(--toast-index)*var(--gap))+var(--toast-swipe-movement-y))] absolute top-0 right-0 left-0 z-[calc(1000-var(--toast-index))] mx-auto w-full origin-top [transform:translateX(var(--toast-swipe-movement-x))_translateY(calc(var(--toast-swipe-movement-y)+(var(--toast-index)*var(--peek))+(var(--shrink)*var(--height))))_scale(var(--scale))] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 select-none dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none after:absolute after:bottom-full after:left-0 after:h-[calc(var(--gap)+1px)] after:w-full after:content-[''] data-[ending-style]:opacity-0 data-[expanded]:[transform:translateX(var(--toast-swipe-movement-x))_translateY(calc(var(--offset-y)))] data-[limited]:opacity-0 data-[starting-style]:[transform:translateY(-150%)] [&[data-ending-style]:not([data-limited]):not([data-swipe-direction])]:[transform:translateY(-150%)] data-[ending-style]:data-[swipe-direction=down]:[transform:translateY(calc(var(--toast-swipe-movement-y)+150%))] data-[expanded]:data-[ending-style]:data-[swipe-direction=down]:[transform:translateY(calc(var(--toast-swipe-movement-y)+150%))] data-[ending-style]:data-[swipe-direction=left]:[transform:translateX(calc(var(--toast-swipe-movement-x)-150%))_translateY(var(--offset-y))] data-[expanded]:data-[ending-style]:data-[swipe-direction=left]:[transform:translateX(calc(var(--toast-swipe-movement-x)-150%))_translateY(var(--offset-y))] data-[ending-style]:data-[swipe-direction=right]:[transform:translateX(calc(var(--toast-swipe-movement-x)+150%))_translateY(var(--offset-y))] data-[expanded]:data-[ending-style]:data-[swipe-direction=right]:[transform:translateX(calc(var(--toast-swipe-movement-x)+150%))_translateY(var(--offset-y))] data-[ending-style]:data-[swipe-direction=up]:[transform:translateY(calc(var(--toast-swipe-movement-y)-150%))] data-[expanded]:data-[ending-style]:data-[swipe-direction=up]:[transform:translateY(calc(var(--toast-swipe-movement-y)-150%))] h-[var(--height)] data-[expanded]:h-[var(--toast-height)] [transition:transform_0.5s_cubic-bezier(0.22,1,0.36,1),opacity_0.5s,height_0.15s]"
      content_class="flex h-full items-center gap-4 p-3 overflow-hidden transition-opacity duration-[250ms] ease-[cubic-bezier(0.22,1,0.36,1)] data-[behind]:opacity-0 data-[expanded]:opacity-100"
      close_class="flex h-8 shrink-0 items-center justify-center gap-2 rounded-none border border-neutral-950 bg-white px-3 py-0 font-[inherit] text-sm leading-none whitespace-nowrap font-normal text-neutral-950 hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
    >
      <:trigger>Create toast</:trigger>
      <:close>Dismiss</:close>
      <:template>
        <div class="flex min-w-0 flex-1 flex-col gap-1">
          <div class="text-sm font-bold">Toast <span data-toast-count></span> created</div>
          <div class="text-sm">This is a toast notification.</div>
        </div>
      </:template>
    </.toast>
    """
  end

  def example(%{section: "toast-anchored"} = assigns) do
    ~H"""
    <.toast
      id="baseui-toast-anchored"
      trigger_class="flex h-8 items-center justify-center gap-2 rounded-none border border-neutral-950 bg-white px-3 py-0 font-[inherit] text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:bg-neutral-100 active:bg-neutral-200 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:bg-neutral-800 dark:active:bg-neutral-700 disabled:border-neutral-500 disabled:text-neutral-500 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      viewport_class="fixed top-auto right-[1rem] bottom-[1rem] z-[1] mx-auto w-[calc(100vw-2rem)] sm:right-[2rem] sm:bottom-[2rem] sm:w-[22.5rem]"
      toast_class="[--gap:0.75rem] [--peek:0.75rem] [--scale:calc(max(0,1-(var(--toast-index)*0.1)))] [--shrink:calc(1-var(--scale))] [--height:var(--toast-frontmost-height,var(--toast-height))] [--offset-y:calc(var(--toast-offset-y)*-1+calc(var(--toast-index)*var(--gap)*-1)+var(--toast-swipe-movement-y))] absolute right-0 bottom-0 left-auto z-[calc(1000-var(--toast-index))] mr-0 w-full origin-bottom [transform:translateX(var(--toast-swipe-movement-x))_translateY(calc(var(--toast-swipe-movement-y)-(var(--toast-index)*var(--peek))-(var(--shrink)*var(--height))))_scale(var(--scale))] border border-neutral-950 bg-white text-neutral-950 shadow-[0.25rem_0.25rem_0] shadow-black/12 select-none dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none after:absolute after:top-full after:left-0 after:h-[calc(var(--gap)+1px)] after:w-full after:content-[''] data-[ending-style]:opacity-0 data-[expanded]:[transform:translateX(var(--toast-swipe-movement-x))_translateY(calc(var(--offset-y)))] data-[limited]:opacity-0 data-[starting-style]:[transform:translateY(150%)] [&[data-ending-style]:not([data-limited]):not([data-swipe-direction])]:[transform:translateY(150%)] data-[ending-style]:data-[swipe-direction=down]:[transform:translateY(calc(var(--toast-swipe-movement-y)+150%))] data-[expanded]:data-[ending-style]:data-[swipe-direction=down]:[transform:translateY(calc(var(--toast-swipe-movement-y)+150%))] data-[ending-style]:data-[swipe-direction=left]:[transform:translateX(calc(var(--toast-swipe-movement-x)-150%))_translateY(var(--offset-y))] data-[expanded]:data-[ending-style]:data-[swipe-direction=left]:[transform:translateX(calc(var(--toast-swipe-movement-x)-150%))_translateY(var(--offset-y))] data-[ending-style]:data-[swipe-direction=right]:[transform:translateX(calc(var(--toast-swipe-movement-x)+150%))_translateY(var(--offset-y))] data-[expanded]:data-[ending-style]:data-[swipe-direction=right]:[transform:translateX(calc(var(--toast-swipe-movement-x)+150%))_translateY(var(--offset-y))] data-[ending-style]:data-[swipe-direction=up]:[transform:translateY(calc(var(--toast-swipe-movement-y)-150%))] data-[expanded]:data-[ending-style]:data-[swipe-direction=up]:[transform:translateY(calc(var(--toast-swipe-movement-y)-150%))] h-[var(--height)] data-[expanded]:h-[var(--toast-height)] [transition:transform_0.5s_cubic-bezier(0.22,1,0.36,1),opacity_0.5s,height_0.15s]"
      content_class="flex h-full items-center gap-4 p-3 overflow-hidden transition-opacity duration-[250ms] ease-[cubic-bezier(0.22,1,0.36,1)] data-[behind]:opacity-0 data-[expanded]:opacity-100"
      close_class="flex h-8 shrink-0 items-center justify-center gap-2 rounded-none border border-neutral-950 bg-white px-3 py-0 font-[inherit] text-sm leading-none whitespace-nowrap font-normal text-neutral-950 hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:bg-neutral-200 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:bg-neutral-700 data-[disabled]:border-neutral-500 data-[disabled]:text-neutral-500 disabled:border-neutral-500 disabled:text-neutral-500 dark:data-[disabled]:border-neutral-400 dark:data-[disabled]:text-neutral-400 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
    >
      <:trigger>Stacked toast</:trigger>
      <:close>Dismiss</:close>
      <:template>
        <div class="flex min-w-0 flex-1 flex-col gap-1">
          <div class="text-sm">Copied</div>
        </div>
      </:template>
    </.toast>
    """
  end

  def example(%{section: "toggle-hero"} = assigns) do
    ~H"""
    <.toggle
      id="baseui-toggle-hero"
      aria-label="Favorite"
      class="flex size-8 items-center justify-center border-none rounded-none bg-transparent text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:bg-neutral-200 dark:active:not-data-[disabled]:bg-neutral-700 data-[pressed]:text-neutral-950 dark:data-[pressed]:text-white focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white [&[data-pressed]_[data-icon=outline]]:hidden [&:not([data-pressed])_[data-icon=filled]]:hidden"
    >
      <svg
        data-icon="filled"
        width="16"
        height="16"
        viewBox="0 0 16 16"
        fill="currentColor"
        class="block"
      >
        <path d="M7.99961 13.8667C7.88761 13.8667 7.77561 13.8315 7.68121 13.7611C7.43321 13.5766 1.59961 9.1963 1.59961 5.8667C1.59961 3.80856 3.27481 2.13336 5.33294 2.13336C6.59054 2.13336 7.49934 2.81176 7.99961 3.3131C8.49988 2.81176 9.40868 2.13336 10.6663 2.13336C12.7244 2.13336 14.3996 3.80803 14.3996 5.8667C14.3996 9.1963 8.56601 13.5766 8.31801 13.7616C8.22361 13.8315 8.11161 13.8667 7.99961 13.8667Z" />
      </svg>
      <svg
        data-icon="outline"
        width="16"
        height="16"
        viewBox="0 0 16 16"
        fill="currentColor"
        class="block"
      >
        <path
          fill-rule="evenodd"
          clip-rule="evenodd"
          d="m7.99961 4.8232-.75505-.75666c-.40333-.40419-1.0559-.86651-1.91162-.86651-1.46903 0-2.66666 1.19764-2.66666 2.66667 0 .5412.24648 1.2356.75339 2.04713.49581.79376 1.17682 1.59861 1.89311 2.33647 1.06989 1.1022 2.1604 1.9962 2.68705 2.4102.52751-.4149 1.61735-1.3085 2.68657-2.4101.7163-.73792 1.3973-1.54278 1.8932-2.33656.5069-.81154.7533-1.50594.7533-2.04714 0-1.46947-1.1975-2.66667-2.6666-2.66667-.85574 0-1.50831.46232-1.91164.86651zm-.01387-1.52394c-.5031-.49988-1.40673-1.1659-2.6528-1.1659-2.05813 0-3.73333 1.6752-3.73333 3.73334 0 3.3296 5.8336 7.7099 6.0816 7.8944a.532.532 0 0 0 .3184.1056c.112 0 .224-.0352.3184-.1051.248-.185 6.08159-4.5653 6.08159-7.8949 0-2.05867-1.6752-3.73334-3.7333-3.73334-1.24617 0-2.14985.66611-2.65293 1.166q-.0069.00686-.0137.01367c.00002-.00003-.00002.00002 0 0-.00459-.0046-.00927-.00914-.01393-.01377"
        />
      </svg>
    </.toggle>
    """
  end

  def example(%{section: "toggle_group-hero"} = assigns) do
    ~H"""
    <.toggle_group
      id="baseui-toggle_group-hero"
      aria-label="Text alignment"
      value={["left"]}
      class="flex gap-px p-px border border-neutral-950 dark:border-white"
    >
      <:item
        value="left"
        aria-label="Align left"
        class="flex size-8 items-center justify-center border-none rounded-none bg-transparent text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:not-data-[pressed]:bg-neutral-200 dark:active:not-data-[disabled]:not-data-[pressed]:bg-neutral-700 data-[pressed]:bg-neutral-950 data-[pressed]:text-white dark:data-[pressed]:bg-white dark:data-[pressed]:text-neutral-950 data-[pressed]:hover:not-data-[disabled]:bg-neutral-950 data-[pressed]:hover:not-data-[disabled]:text-white dark:data-[pressed]:hover:not-data-[disabled]:bg-white dark:data-[pressed]:hover:not-data-[disabled]:text-neutral-950 focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      >
        <svg
          width="16"
          height="16"
          fill="none"
          viewBox="0 0 16 16"
          stroke="currentColor"
          style="display: block"
        >
          <path stroke-linecap="square" stroke-linejoin="round" d="M2.5 4.5h11m-11 7h9M2.5 8h5" />
        </svg>
      </:item>
      <:item
        value="center"
        aria-label="Align center"
        class="flex size-8 items-center justify-center border-none rounded-none bg-transparent text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:not-data-[pressed]:bg-neutral-200 dark:active:not-data-[disabled]:not-data-[pressed]:bg-neutral-700 data-[pressed]:bg-neutral-950 data-[pressed]:text-white dark:data-[pressed]:bg-white dark:data-[pressed]:text-neutral-950 data-[pressed]:hover:not-data-[disabled]:bg-neutral-950 data-[pressed]:hover:not-data-[disabled]:text-white dark:data-[pressed]:hover:not-data-[disabled]:bg-white dark:data-[pressed]:hover:not-data-[disabled]:text-neutral-950 focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      >
        <svg width="16" height="16" viewBox="0 0 16 16" stroke="currentColor" style="display: block">
          <path stroke-linecap="square" stroke-linejoin="round" d="M2.5 4.5h11m-10 7h9M5.5 8h5" />
        </svg>
      </:item>
      <:item
        value="right"
        aria-label="Align right"
        class="flex size-8 items-center justify-center border-none rounded-none bg-transparent text-neutral-950 dark:text-white select-none hover:not-data-[disabled]:bg-neutral-100 dark:hover:not-data-[disabled]:bg-neutral-800 active:not-data-[disabled]:not-data-[pressed]:bg-neutral-200 dark:active:not-data-[disabled]:not-data-[pressed]:bg-neutral-700 data-[pressed]:bg-neutral-950 data-[pressed]:text-white dark:data-[pressed]:bg-white dark:data-[pressed]:text-neutral-950 data-[pressed]:hover:not-data-[disabled]:bg-neutral-950 data-[pressed]:hover:not-data-[disabled]:text-white dark:data-[pressed]:hover:not-data-[disabled]:bg-white dark:data-[pressed]:hover:not-data-[disabled]:text-neutral-950 focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      >
        <svg width="16" height="16" viewBox="0 0 16 16" stroke="currentColor" style="display: block">
          <path stroke-linecap="square" stroke-linejoin="round" d="M2.5 4.5h11m-9 7h9M8.5 8h5" />
        </svg>
      </:item>
    </.toggle_group>
    """
  end

  def example(%{section: "toggle_group-multiple"} = assigns) do
    ~H"""
    <.toggle_group
      id="baseui-toggle_group-multiple"
      multiple
      value={["bold", "italic"]}
      aria-label="Text formatting options"
      class="flex gap-px p-px border border-neutral-950 dark:border-white"
    >
      <:item
        value="bold"
        aria-label="Bold"
        class="flex size-8 items-center justify-center border-none rounded-none bg-transparent text-neutral-950 dark:text-white select-none hover:bg-neutral-100 dark:hover:bg-neutral-800 data-[pressed]:bg-neutral-950 data-[pressed]:text-white dark:data-[pressed]:bg-white dark:data-[pressed]:text-neutral-950 data-[pressed]:hover:bg-neutral-950 data-[pressed]:hover:text-white dark:data-[pressed]:hover:bg-white dark:data-[pressed]:hover:text-neutral-950 focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      >
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block">
          <path d="M3.73353 2.13333C3.4386 2.13333 3.2002 2.37226 3.2002 2.66666C3.2002 2.96106 3.4386 3.2 3.73353 3.2H4.26686V12.8H3.73353C3.4386 12.8 3.2002 13.0389 3.2002 13.3333C3.2002 13.6277 3.4386 13.8667 3.73353 13.8667H9.86686C11.7783 13.8667 13.3335 12.3115 13.3335 10.4C13.3335 8.9968 12.4945 7.78881 11.2929 7.24375C11.8897 6.70615 12.2669 5.93066 12.2669 5.06666C12.2669 3.44906 10.9506 2.13333 9.33353 2.13333H3.73353ZM6.93353 3.2H8.26686C9.29619 3.2 10.1335 4.03733 10.1335 5.06666C10.1335 6.096 9.29619 6.93333 8.26686 6.93333H6.93353V3.2ZM6.93353 8H7.73353H8.26686C9.59006 8 10.6669 9.0768 10.6669 10.4C10.6669 11.7232 9.59006 12.8 8.26686 12.8H6.93353V8Z" />
        </svg>
      </:item>
      <:item
        value="italic"
        aria-label="Italic"
        class="flex size-8 items-center justify-center border-none rounded-none bg-transparent text-neutral-950 dark:text-white select-none hover:bg-neutral-100 dark:hover:bg-neutral-800 data-[pressed]:bg-neutral-950 data-[pressed]:text-white dark:data-[pressed]:bg-white dark:data-[pressed]:text-neutral-950 data-[pressed]:hover:bg-neutral-950 data-[pressed]:hover:text-white dark:data-[pressed]:hover:bg-white dark:data-[pressed]:hover:text-neutral-950 focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      >
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block">
          <path d="M8.52599 2.12186C8.48583 2.12267 8.44578 2.1265 8.4062 2.13332H6.93328C6.86261 2.13232 6.79244 2.14538 6.72686 2.17173C6.66127 2.19808 6.60158 2.23721 6.55125 2.28683C6.50092 2.33646 6.46096 2.39559 6.43368 2.46079C6.4064 2.526 6.39235 2.59597 6.39235 2.66665C6.39235 2.73733 6.4064 2.80731 6.43368 2.87251C6.46096 2.93772 6.50092 2.99685 6.55125 3.04647C6.60158 3.0961 6.66127 3.13522 6.72686 3.16157C6.79244 3.18793 6.86261 3.20099 6.93328 3.19999H7.70099L6.69057 12.8H5.86661C5.79594 12.799 5.72577 12.812 5.66019 12.8384C5.59461 12.8648 5.53492 12.9039 5.48459 12.9535C5.43425 13.0031 5.39429 13.0623 5.36701 13.1275C5.33973 13.1927 5.32568 13.2626 5.32568 13.3333C5.32568 13.404 5.33973 13.474 5.36701 13.5392C5.39429 13.6044 5.43425 13.6635 5.48459 13.7131C5.53492 13.7628 5.59461 13.8019 5.66019 13.8282C5.72577 13.8546 5.79594 13.8677 5.86661 13.8667H9.06661C9.13729 13.8677 9.20745 13.8546 9.27304 13.8282C9.33862 13.8019 9.39831 13.7628 9.44864 13.7131C9.49897 13.6635 9.53894 13.6044 9.56622 13.5392C9.5935 13.474 9.60754 13.404 9.60754 13.3333C9.60754 13.2626 9.5935 13.1927 9.56622 13.1275C9.53894 13.0623 9.49897 13.0031 9.44864 12.9535C9.39831 12.9039 9.33862 12.8648 9.27304 12.8384C9.20745 12.812 9.13729 12.799 9.06661 12.8H8.2989L9.30932 3.19999H10.1333C10.204 3.20099 10.2741 3.18793 10.3397 3.16157C10.4053 3.13522 10.465 3.0961 10.5153 3.04647C10.5656 2.99685 10.6056 2.93772 10.6329 2.87251C10.6602 2.80731 10.6742 2.73733 10.6742 2.66665C10.6742 2.59597 10.6602 2.526 10.6329 2.46079C10.6056 2.39559 10.5656 2.33646 10.5153 2.28683C10.465 2.23721 10.4053 2.19808 10.3397 2.17173C10.2741 2.14538 10.204 2.13232 10.1333 2.13332H8.66349C8.61807 2.12555 8.57207 2.12171 8.52599 2.12186Z" />
        </svg>
      </:item>
      <:item
        value="underline"
        aria-label="Underline"
        class="flex size-8 items-center justify-center border-none rounded-none bg-transparent text-neutral-950 dark:text-white select-none hover:bg-neutral-100 dark:hover:bg-neutral-800 data-[pressed]:bg-neutral-950 data-[pressed]:text-white dark:data-[pressed]:bg-white dark:data-[pressed]:text-neutral-950 data-[pressed]:hover:bg-neutral-950 data-[pressed]:hover:text-white dark:data-[pressed]:hover:bg-white dark:data-[pressed]:hover:text-neutral-950 focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      >
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block">
          <path d="M3.73331 2.13332C3.66264 2.13232 3.59247 2.14538 3.52689 2.17173C3.46131 2.19809 3.40161 2.23721 3.35128 2.28684C3.30095 2.33646 3.26099 2.39559 3.23371 2.4608C3.20643 2.526 3.19238 2.59598 3.19238 2.66666C3.19238 2.73734 3.20643 2.80731 3.23371 2.87252C3.26099 2.93772 3.30095 2.99685 3.35128 3.04648C3.40161 3.0961 3.46131 3.13523 3.52689 3.16158C3.59247 3.18793 3.66264 3.20099 3.73331 3.19999V7.99999C3.73331 10.224 5.55144 12.2667 7.99998 12.2667C10.4485 12.2667 12.2666 10.224 12.2666 7.99999V3.19999C12.3373 3.20099 12.4075 3.18793 12.4731 3.16158C12.5386 3.13523 12.5983 3.0961 12.6487 3.04648C12.699 2.99685 12.739 2.93772 12.7662 2.87252C12.7935 2.80731 12.8076 2.73734 12.8076 2.66666C12.8076 2.59598 12.7935 2.526 12.7662 2.4608C12.739 2.39559 12.699 2.33646 12.6487 2.28684C12.5983 2.23721 12.5386 2.19809 12.4731 2.17173C12.4075 2.14538 12.3373 2.13232 12.2666 2.13332H10.1333C10.0626 2.13232 9.99247 2.14538 9.92689 2.17173C9.8613 2.19809 9.80161 2.23721 9.75128 2.28684C9.70095 2.33646 9.66099 2.39559 9.63371 2.4608C9.60643 2.526 9.59238 2.59598 9.59238 2.66666C9.59238 2.73734 9.60643 2.80731 9.63371 2.87252C9.66099 2.93772 9.70095 2.99685 9.75128 3.04648C9.80161 3.0961 9.8613 3.13523 9.92689 3.16158C9.99247 3.18793 10.0626 3.20099 10.1333 3.19999V8.97187C10.1333 10.0855 9.32179 11.0818 8.21352 11.1896C6.94152 11.3138 5.86665 10.3136 5.86665 9.06666V3.19999C5.93732 3.20099 6.00748 3.18793 6.07307 3.16158C6.13865 3.13523 6.19834 3.0961 6.24867 3.04648C6.299 2.99685 6.33897 2.93772 6.36625 2.87252C6.39353 2.80731 6.40757 2.73734 6.40757 2.66666C6.40757 2.59598 6.39353 2.526 6.36625 2.4608C6.33897 2.39559 6.299 2.33646 6.24867 2.28684C6.19834 2.23721 6.13865 2.19809 6.07307 2.17173C6.00748 2.14538 5.93732 2.13232 5.86665 2.13332H3.73331ZM3.73331 13.3333C3.66264 13.3323 3.59247 13.3454 3.52689 13.3717C3.46131 13.3981 3.40161 13.4372 3.35128 13.4868C3.30095 13.5365 3.26099 13.5956 3.23371 13.6608C3.20643 13.726 3.19238 13.796 3.19238 13.8667C3.19238 13.9373 3.20643 14.0073 3.23371 14.0725C3.26099 14.1377 3.30095 14.1969 3.35128 14.2465C3.40161 14.2961 3.46131 14.3352 3.52689 14.3616C3.59247 14.3879 3.66264 14.401 3.73331 14.4H12.2666C12.3373 14.401 12.4075 14.3879 12.4731 14.3616C12.5386 14.3352 12.5983 14.2961 12.6487 14.2465C12.699 14.1969 12.739 14.1377 12.7662 14.0725C12.7935 14.0073 12.8076 13.9373 12.8076 13.8667C12.8076 13.796 12.7935 13.726 12.7662 13.6608C12.739 13.5956 12.699 13.5365 12.6487 13.4868C12.5983 13.4372 12.5386 13.3981 12.4731 13.3717C12.4075 13.3454 12.3373 13.3323 12.2666 13.3333H3.73331Z" />
        </svg>
      </:item>
    </.toggle_group>
    """
  end

  def example(%{section: "toolbar-hero"} = assigns) do
    ~H"""
    <.toolbar
      id="baseui-toolbar-hero"
      class="flex w-150 items-center gap-px border border-neutral-950 bg-white p-px dark:border-white dark:bg-neutral-950"
    >
      <:item
        group="Alignment"
        group_class="flex"
        label="Align left"
        class="flex h-8 min-w-8 items-center justify-center gap-2 border-0 bg-transparent px-3 font-[inherit] text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:not-data-[pressed]:bg-neutral-200 data-[pressed]:bg-neutral-950 data-[pressed]:text-white data-[pressed]:hover:not-data-[disabled]:bg-neutral-950 data-[pressed]:hover:not-data-[disabled]:text-white data-[popup-open]:!bg-neutral-100 data-[popup-open]:!text-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:not-data-[pressed]:bg-neutral-700 dark:data-[pressed]:bg-white dark:data-[pressed]:text-neutral-950 dark:data-[pressed]:hover:not-data-[disabled]:bg-white dark:data-[pressed]:hover:not-data-[disabled]:text-neutral-950 dark:data-[popup-open]:!bg-neutral-800 dark:data-[popup-open]:!text-white focus-visible:bg-transparent focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      >
        Align Left
      </:item>
      <:item
        group="Alignment"
        label="Align right"
        class="flex h-8 min-w-8 items-center justify-center gap-2 border-0 bg-transparent px-3 font-[inherit] text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:not-data-[pressed]:bg-neutral-200 data-[pressed]:bg-neutral-950 data-[pressed]:text-white data-[pressed]:hover:not-data-[disabled]:bg-neutral-950 data-[pressed]:hover:not-data-[disabled]:text-white data-[popup-open]:!bg-neutral-100 data-[popup-open]:!text-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:not-data-[pressed]:bg-neutral-700 dark:data-[pressed]:bg-white dark:data-[pressed]:text-neutral-950 dark:data-[pressed]:hover:not-data-[disabled]:bg-white dark:data-[pressed]:hover:not-data-[disabled]:text-neutral-950 dark:data-[popup-open]:!bg-neutral-800 dark:data-[popup-open]:!text-white focus-visible:bg-transparent focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      >
        Align Right
      </:item>
      <:item type="separator" class="m-1 h-4 w-px bg-neutral-950 dark:bg-white" />
      <:item
        group="Numerical format"
        group_class="flex"
        label="Format as currency"
        class="flex h-8 min-w-8 items-center justify-center gap-2 border-0 bg-transparent font-[inherit] text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:not-data-[pressed]:bg-neutral-200 data-[pressed]:bg-neutral-950 data-[pressed]:text-white data-[pressed]:hover:not-data-[disabled]:bg-neutral-950 data-[pressed]:hover:not-data-[disabled]:text-white data-[popup-open]:!bg-neutral-100 data-[popup-open]:!text-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:not-data-[pressed]:bg-neutral-700 dark:data-[pressed]:bg-white dark:data-[pressed]:text-neutral-950 dark:data-[pressed]:hover:not-data-[disabled]:bg-white dark:data-[pressed]:hover:not-data-[disabled]:text-neutral-950 dark:data-[popup-open]:!bg-neutral-800 dark:data-[popup-open]:!text-white focus-visible:bg-transparent focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      >
        $
      </:item>
      <:item
        group="Numerical format"
        label="Format as percent"
        class="flex h-8 min-w-8 items-center justify-center gap-2 border-0 bg-transparent font-[inherit] text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:not-data-[pressed]:bg-neutral-200 data-[pressed]:bg-neutral-950 data-[pressed]:text-white data-[pressed]:hover:not-data-[disabled]:bg-neutral-950 data-[pressed]:hover:not-data-[disabled]:text-white data-[popup-open]:!bg-neutral-100 data-[popup-open]:!text-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:not-data-[pressed]:bg-neutral-700 dark:data-[pressed]:bg-white dark:data-[pressed]:text-neutral-950 dark:data-[pressed]:hover:not-data-[disabled]:bg-white dark:data-[pressed]:hover:not-data-[disabled]:text-neutral-950 dark:data-[popup-open]:!bg-neutral-800 dark:data-[popup-open]:!text-white focus-visible:bg-transparent focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      >
        %
      </:item>
      <:item type="separator" class="m-1 h-4 w-px bg-neutral-950 dark:bg-white" />
      <:item
        label="Font family"
        class="flex h-8 min-w-32 cursor-default items-center justify-between gap-2 border-0 bg-transparent px-2 font-[inherit] text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none hover:not-data-[disabled]:bg-neutral-100 active:not-data-[disabled]:not-data-[pressed]:bg-neutral-200 data-[pressed]:bg-neutral-950 data-[pressed]:text-white data-[pressed]:hover:not-data-[disabled]:bg-neutral-950 data-[pressed]:hover:not-data-[disabled]:text-white data-[popup-open]:!bg-neutral-100 data-[popup-open]:!text-neutral-950 dark:text-white dark:hover:not-data-[disabled]:bg-neutral-800 dark:active:not-data-[disabled]:not-data-[pressed]:bg-neutral-700 dark:data-[pressed]:bg-white dark:data-[pressed]:text-neutral-950 dark:data-[pressed]:hover:not-data-[disabled]:bg-white dark:data-[pressed]:hover:not-data-[disabled]:text-neutral-950 dark:data-[popup-open]:!bg-neutral-800 dark:data-[popup-open]:!text-white focus-visible:bg-transparent focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      >
        Helvetica
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" class="block">
          <path d="M11 10H5l3 3.5zm0-4H5l3-3.5z" />
        </svg>
      </:item>
      <:item type="separator" class="m-1 h-4 w-px bg-neutral-950 dark:bg-white" />
      <:item
        type="link"
        href="#"
        class="mr-[0.875rem] ml-auto flex-none self-center font-[inherit] text-sm text-neutral-500 no-underline hover:text-blue-700 dark:text-neutral-400 dark:hover:text-blue-500 focus-visible:outline-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white"
      >
        Edited 51m ago
      </:item>
    </.toolbar>
    """
  end

  def example(%{section: "tooltip-hero"} = assigns) do
    ~H"""
    <div class="flex border border-neutral-950 bg-white dark:border-white dark:bg-neutral-950">
      <.tooltip
        :for={
          {id, label, icon} <- [
            {"bold", "Bold", :bold},
            {"italic", "Italic", :italic},
            {"underline", "Underline", :underline}
          ]
        }
        id={"baseui-tooltip-hero-#{id}"}
        side_offset={11}
        trigger_label={label}
        trigger_class="flex size-8 items-center justify-center border-0 bg-transparent text-neutral-950 select-none data-[popup-open]:bg-neutral-100 focus-visible:bg-transparent focus-visible:outline-2 focus-visible:outline-neutral-950 dark:focus-visible:outline-white hover:bg-neutral-100 active:bg-neutral-200 dark:text-white dark:data-[popup-open]:bg-neutral-800 dark:hover:bg-neutral-800 dark:active:bg-neutral-700"
        popup_class="relative flex flex-col border border-neutral-950 bg-white px-2 py-1 text-sm text-neutral-950 origin-[var(--transform-origin)] shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[transform,opacity] duration-100 ease-out data-[ending-style]:opacity-0 data-[ending-style]:[transform:scale(0.98)] data-[instant]:transition-none data-[starting-style]:opacity-0 data-[starting-style]:[transform:scale(0.98)] dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
        arrow_class="relative block w-3 h-1.5 overflow-clip data-[side=bottom]:top-[-6px] data-[side=left]:right-[-9px] data-[side=left]:rotate-90 data-[side=right]:left-[-9px] data-[side=right]:-rotate-90 data-[side=top]:bottom-[-6px] data-[side=top]:rotate-180 before:content-[''] before:absolute before:bottom-0 before:left-1/2 before:w-[calc(6px*sqrt(2))] before:h-[calc(6px*sqrt(2))] before:bg-white dark:before:bg-neutral-950 before:border before:border-neutral-950 dark:before:border-white before:[transform:translate(-50%,50%)_rotate(45deg)]"
      >
        <:trigger>
          <.tooltip_hero_icon kind={icon} />
        </:trigger>
        <:arrow></:arrow>
        {label}
      </.tooltip>
    </div>
    """
  end

  def example(%{section: "tooltip-detached-triggers-simple"} = assigns) do
    ~H"""
    <.tooltip
      id="baseui-tooltip-detached-triggers-simple"
      side_offset={11}
      trigger_label="Delete"
      trigger_class="flex size-8 items-center justify-center border border-neutral-950 bg-white text-neutral-950 select-none data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white hover:bg-neutral-100 active:bg-neutral-200 dark:border-white dark:bg-neutral-950 dark:text-white dark:data-[popup-open]:bg-neutral-800 dark:hover:bg-neutral-800 dark:active:bg-neutral-700"
      popup_class="relative flex flex-col border border-neutral-950 bg-white px-2 py-1 text-sm text-neutral-950 origin-[var(--transform-origin)] shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[transform,opacity] duration-100 ease-out data-[ending-style]:opacity-0 data-[ending-style]:[transform:scale(0.98)] data-[instant]:transition-none data-[starting-style]:opacity-0 data-[starting-style]:[transform:scale(0.98)] dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
      arrow_class="relative block w-3 h-1.5 overflow-clip data-[side=bottom]:top-[-6px] data-[side=left]:right-[-9px] data-[side=left]:rotate-90 data-[side=right]:left-[-9px] data-[side=right]:-rotate-90 data-[side=top]:bottom-[-6px] data-[side=top]:rotate-180 before:content-[''] before:absolute before:bottom-0 before:left-1/2 before:w-[calc(6px*sqrt(2))] before:h-[calc(6px*sqrt(2))] before:bg-white dark:before:bg-neutral-950 before:border before:border-neutral-950 dark:before:border-white before:[transform:translate(-50%,50%)_rotate(45deg)]"
    >
      <:trigger>
        <.tooltip_hero_icon kind={:trash} />
      </:trigger>
      <:arrow></:arrow>
      Delete
    </.tooltip>
    """
  end

  def example(%{section: "tooltip-detached-triggers-controlled"} = assigns) do
    ~H"""
    <div class="flex gap-2 flex-wrap justify-center">
      <div class="flex">
        <.tooltip
          :for={
            {id, icon, extra} <- [
              {"1", :headphones, ""},
              {"2", :stopwatch, "border-l-0"},
              {"3", :trash, "border-l-0"}
            ]
          }
          id={"baseui-tooltip-detached-triggers-controlled-#{id}"}
          side_offset={11}
          trigger_label="Controlled tooltip"
          trigger_class={[
            "flex size-8 items-center justify-center border border-neutral-950 bg-white text-neutral-950 select-none data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white focus-visible:relative hover:bg-neutral-100 active:bg-neutral-200 dark:border-white dark:bg-neutral-950 dark:text-white dark:data-[popup-open]:bg-neutral-800 dark:hover:bg-neutral-800 dark:active:bg-neutral-700",
            extra
          ]}
          popup_class="relative flex flex-col border border-neutral-950 bg-white px-2 py-1 text-sm text-neutral-950 origin-[var(--transform-origin)] shadow-[0.25rem_0.25rem_0] shadow-black/12 transition-[transform,opacity] duration-100 ease-out data-[ending-style]:opacity-0 data-[ending-style]:[transform:scale(0.98)] data-[instant]:transition-none data-[starting-style]:opacity-0 data-[starting-style]:[transform:scale(0.98)] dark:border-white dark:bg-neutral-950 dark:text-white dark:shadow-none"
          arrow_class="relative block w-3 h-1.5 overflow-clip data-[side=bottom]:top-[-6px] data-[side=left]:right-[-9px] data-[side=left]:rotate-90 data-[side=right]:left-[-9px] data-[side=right]:-rotate-90 data-[side=top]:bottom-[-6px] data-[side=top]:rotate-180 before:content-[''] before:absolute before:bottom-0 before:left-1/2 before:w-[calc(6px*sqrt(2))] before:h-[calc(6px*sqrt(2))] before:bg-white dark:before:bg-neutral-950 before:border before:border-neutral-950 dark:before:border-white before:[transform:translate(-50%,50%)_rotate(45deg)]"
        >
          <:trigger>
            <.tooltip_hero_icon kind={icon} />
          </:trigger>
          <:arrow></:arrow>
          Controlled tooltip
        </.tooltip>
      </div>

      <button
        type="button"
        class="flex h-8 items-center justify-center gap-2 border border-neutral-950 bg-white px-3 text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white hover:bg-neutral-100 active:bg-neutral-200 dark:border-white dark:bg-neutral-950 dark:text-white dark:hover:bg-neutral-800 dark:active:bg-neutral-700"
      >
        Open programmatically
      </button>
    </div>
    """
  end

  def example(%{section: "tooltip-detached-triggers-full"} = assigns) do
    ~H"""
    <div class="flex">
      <.tooltip
        :for={
          {id, icon, label, payload, extra} <- [
            {"1", :headphones, "Listen to audio preview", "Listen to audio preview", ""},
            {"2", :stopwatch, "Set a timer", "Set a timer", "border-l-0"},
            {"3", :trash, "Delete: This action cannot be undone",
             "Delete: This action cannot be undone", "border-l-0"}
          ]
        }
        id={"baseui-tooltip-detached-triggers-full-#{id}"}
        side_offset={11}
        trigger_label={label}
        trigger_class={[
          "flex size-8 items-center justify-center border border-neutral-950 bg-white text-sm leading-none whitespace-nowrap font-normal text-neutral-950 select-none data-[popup-open]:bg-neutral-100 focus-visible:outline-2 focus-visible:-outline-offset-1 focus-visible:outline-neutral-950 dark:focus-visible:outline-white focus-visible:relative hover:bg-neutral-100 active:bg-neutral-200 dark:border-white dark:bg-neutral-950 dark:text-white dark:data-[popup-open]:bg-neutral-800 dark:hover:bg-neutral-800 dark:active:bg-neutral-700",
          extra
        ]}
        popup_class="relative h-[var(--popup-height,auto)] w-[var(--popup-width,auto)] max-w-[500px] border border-neutral-950 dark:border-white bg-white dark:bg-neutral-950 text-sm text-neutral-950 dark:text-white px-2 py-1 origin-[var(--transform-origin)] shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none transition-[width,height,opacity,transform] duration-[0.35s] ease-[cubic-bezier(0.22,1,0.36,1)] data-[ending-style]:opacity-0 data-[ending-style]:[transform:scale(0.9)] data-[instant]:transition-none data-[starting-style]:opacity-0 data-[starting-style]:[transform:scale(0.9)]"
        arrow_class="relative block w-3 h-1.5 overflow-clip transition-[left] duration-[0.35s] ease-[cubic-bezier(0.22,1,0.36,1)] data-[instant]:transition-none data-[side=bottom]:top-[-6px] data-[side=left]:right-[-9px] data-[side=left]:rotate-90 data-[side=right]:left-[-9px] data-[side=right]:-rotate-90 data-[side=top]:bottom-[-6px] data-[side=top]:rotate-180 before:content-[''] before:absolute before:bottom-0 before:left-1/2 before:w-[calc(6px*sqrt(2))] before:h-[calc(6px*sqrt(2))] before:bg-white dark:before:bg-neutral-950 before:border before:border-neutral-950 dark:before:border-white before:[transform:translate(-50%,50%)_rotate(45deg)]"
      >
        <:trigger>
          <.tooltip_hero_icon kind={icon} />
        </:trigger>
        <:arrow></:arrow>
        {payload}
      </.tooltip>
    </div>
    """
  end

  def example(%{section: "tree-hero"} = assigns) do
    ~H"""
    <.tree
      id="baseui-tree-hero"
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
      class="w-56 border border-neutral-950 bg-white py-1 text-neutral-950 select-none dark:border-white dark:bg-neutral-950 dark:text-white"
      node_class="outline-none [&:focus-visible>[data-part=label]]:outline-2 [&:focus-visible>[data-part=label]]:-outline-offset-1 [&:focus-visible>[data-part=label]]:outline-neutral-950 dark:[&:focus-visible>[data-part=label]]:outline-white"
      label_class="flex h-8 cursor-default items-center gap-1.5 pr-3 pl-[calc(var(--label-offset)+0.5rem)] text-sm leading-none whitespace-nowrap hover:not-data-[selected]:bg-neutral-100 data-[selected]:bg-neutral-950 data-[selected]:text-white dark:hover:not-data-[selected]:bg-neutral-800 dark:data-[selected]:bg-white dark:data-[selected]:text-neutral-950"
      expand_icon_class="grid size-4 shrink-0 place-items-center transition-transform duration-100 ease-[ease-out] [[data-expanded=true]>[data-part=label]>&]:rotate-90"
      label_text_class="inline-flex items-center gap-2 truncate"
    >
      <:expand_icon>
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display: block">
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
          class="block shrink-0"
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
          class="block shrink-0"
        >
          <path d="M3.5 1.5h6l3 3v11h-9z" />
          <path d="M9.5 1.5v3.5h3" />
        </svg>
        {n.node.label}
      </:node>
    </.tree>
    """
  end

  def example(assigns), do: ~H""

  def tooltip_hero_icon(%{kind: :bold} = assigns) do
    ~H"""
    <svg
      width="16"
      height="16"
      viewBox="0 0 16 16"
      fill="currentColor"
      style="display: block"
      aria-hidden="true"
    >
      <path d="M3.73353 2.13333C3.4386 2.13333 3.2002 2.37226 3.2002 2.66666C3.2002 2.96106 3.4386 3.2 3.73353 3.2H4.26686V12.8H3.73353C3.4386 12.8 3.2002 13.0389 3.2002 13.3333C3.2002 13.6277 3.4386 13.8667 3.73353 13.8667H9.86686C11.7783 13.8667 13.3335 12.3115 13.3335 10.4C13.3335 8.9968 12.4945 7.78881 11.2929 7.24375C11.8897 6.70615 12.2669 5.93066 12.2669 5.06666C12.2669 3.44906 10.9506 2.13333 9.33353 2.13333H3.73353ZM6.93353 3.2H8.26686C9.29619 3.2 10.1335 4.03733 10.1335 5.06666C10.1335 6.096 9.29619 6.93333 8.26686 6.93333H6.93353V3.2ZM6.93353 8H7.73353H8.26686C9.59006 8 10.6669 9.0768 10.6669 10.4C10.6669 11.7232 9.59006 12.8 8.26686 12.8H6.93353V8Z" />
    </svg>
    """
  end

  def tooltip_hero_icon(%{kind: :italic} = assigns) do
    ~H"""
    <svg
      width="16"
      height="16"
      viewBox="0 0 16 16"
      fill="currentColor"
      style="display: block"
      aria-hidden="true"
    >
      <path d="M8.52599 2.12186C8.48583 2.12267 8.44578 2.1265 8.4062 2.13332H6.93328C6.86261 2.13232 6.79244 2.14538 6.72686 2.17173C6.66127 2.19808 6.60158 2.23721 6.55125 2.28683C6.50092 2.33646 6.46096 2.39559 6.43368 2.46079C6.4064 2.526 6.39235 2.59597 6.39235 2.66665C6.39235 2.73733 6.4064 2.80731 6.43368 2.87251C6.46096 2.93772 6.50092 2.99685 6.55125 3.04647C6.60158 3.0961 6.66127 3.13522 6.72686 3.16157C6.79244 3.18793 6.86261 3.20099 6.93328 3.19999H7.70099L6.69057 12.8H5.86661C5.79594 12.799 5.72577 12.812 5.66019 12.8384C5.59461 12.8648 5.53492 12.9039 5.48459 12.9535C5.43425 13.0031 5.39429 13.0623 5.36701 13.1275C5.33973 13.1927 5.32568 13.2626 5.32568 13.3333C5.32568 13.404 5.33973 13.474 5.36701 13.5392C5.39429 13.6044 5.43425 13.6635 5.48459 13.7131C5.53492 13.7628 5.59461 13.8019 5.66019 13.8282C5.72577 13.8546 5.79594 13.8677 5.86661 13.8667H9.06661C9.13729 13.8677 9.20745 13.8546 9.27304 13.8282C9.33862 13.8019 9.39831 13.7628 9.44864 13.7131C9.49897 13.6635 9.53894 13.6044 9.56622 13.5392C9.5935 13.474 9.60754 13.404 9.60754 13.3333C9.60754 13.2626 9.5935 13.1927 9.56622 13.1275C9.53894 13.0623 9.49897 13.0031 9.44864 12.9535C9.39831 12.9039 9.33862 12.8648 9.27304 12.8384C9.20745 12.812 9.13729 12.799 9.06661 12.8H8.2989L9.30932 3.19999H10.1333C10.204 3.20099 10.2741 3.18793 10.3397 3.16157C10.4053 3.13522 10.465 3.0961 10.5153 3.04647C10.5656 2.99685 10.6056 2.93772 10.6329 2.87251C10.6602 2.80731 10.6742 2.73733 10.6742 2.66665C10.6742 2.59597 10.6602 2.526 10.6329 2.46079C10.6056 2.39559 10.5656 2.33646 10.5153 2.28683C10.465 2.23721 10.4053 2.19808 10.3397 2.17173C10.2741 2.14538 10.204 2.13232 10.1333 2.13332H8.66349C8.61807 2.12555 8.57207 2.12171 8.52599 2.12186Z" />
    </svg>
    """
  end

  def tooltip_hero_icon(%{kind: :underline} = assigns) do
    ~H"""
    <svg
      width="16"
      height="16"
      viewBox="0 0 16 16"
      fill="currentColor"
      style="display: block"
      aria-hidden="true"
    >
      <path d="M3.73331 2.13332C3.66264 2.13232 3.59247 2.14538 3.52689 2.17173C3.46131 2.19809 3.40161 2.23721 3.35128 2.28684C3.30095 2.33646 3.26099 2.39559 3.23371 2.4608C3.20643 2.526 3.19238 2.59598 3.19238 2.66666C3.19238 2.73734 3.20643 2.80731 3.23371 2.87252C3.26099 2.93772 3.30095 2.99685 3.35128 3.04648C3.40161 3.0961 3.46131 3.13523 3.52689 3.16158C3.59247 3.18793 3.66264 3.20099 3.73331 3.19999V7.99999C3.73331 10.224 5.55144 12.2667 7.99998 12.2667C10.4485 12.2667 12.2666 10.224 12.2666 7.99999V3.19999C12.3373 3.20099 12.4075 3.18793 12.4731 3.16158C12.5386 3.13523 12.5983 3.0961 12.6487 3.04648C12.699 2.99685 12.739 2.93772 12.7662 2.87252C12.7935 2.80731 12.8076 2.73734 12.8076 2.66666C12.8076 2.59598 12.7935 2.526 12.7662 2.4608C12.739 2.39559 12.699 2.33646 12.6487 2.28684C12.5983 2.23721 12.5386 2.19809 12.4731 2.17173C12.4075 2.14538 12.3373 2.13232 12.2666 2.13332H10.1333C10.0626 2.13232 9.99247 2.14538 9.92689 2.17173C9.8613 2.19809 9.80161 2.23721 9.75128 2.28684C9.70095 2.33646 9.66099 2.39559 9.63371 2.4608C9.60643 2.526 9.59238 2.59598 9.59238 2.66666C9.59238 2.73734 9.60643 2.80731 9.63371 2.87252C9.66099 2.93772 9.70095 2.99685 9.75128 3.04648C9.80161 3.0961 9.8613 3.13523 9.92689 3.16158C9.99247 3.18793 10.0626 3.20099 10.1333 3.19999V8.97187C10.1333 10.0855 9.32179 11.0818 8.21352 11.1896C6.94152 11.3138 5.86665 10.3136 5.86665 9.06666V3.19999C5.93732 3.20099 6.00748 3.18793 6.07307 3.16158C6.13865 3.13523 6.19834 3.0961 6.24867 3.04648C6.299 2.99685 6.33897 2.93772 6.36625 2.87252C6.39353 2.80731 6.40757 2.73734 6.40757 2.66666C6.40757 2.59598 6.39353 2.526 6.36625 2.4608C6.33897 2.39559 6.299 2.33646 6.24867 2.28684C6.19834 2.23721 6.13865 2.19809 6.07307 2.17173C6.00748 2.14538 5.93732 2.13232 5.86665 2.13332H3.73331ZM3.73331 13.3333C3.66264 13.3323 3.59247 13.3454 3.52689 13.3717C3.46131 13.3981 3.40161 13.4372 3.35128 13.4868C3.30095 13.5365 3.26099 13.5956 3.23371 13.6608C3.20643 13.726 3.19238 13.796 3.19238 13.8667C3.19238 13.9373 3.20643 14.0073 3.23371 14.0725C3.26099 14.1377 3.30095 14.1969 3.35128 14.2465C3.40161 14.2961 3.46131 14.3352 3.52689 14.3616C3.59247 14.3879 3.66264 14.401 3.73331 14.4H12.2666C12.3373 14.401 12.4075 14.3879 12.4731 14.3616C12.5386 14.3352 12.5983 14.2961 12.6487 14.2465C12.699 14.1969 12.739 14.1377 12.7662 14.0725C12.7935 14.0073 12.8076 13.9373 12.8076 13.8667C12.8076 13.796 12.7935 13.726 12.7662 13.6608C12.739 13.5956 12.699 13.5365 12.6487 13.4868C12.5983 13.4372 12.5386 13.3981 12.4731 13.3717C12.4075 13.3454 12.3373 13.3323 12.2666 13.3333H3.73331Z" />
    </svg>
    """
  end

  def tooltip_hero_icon(%{kind: :headphones} = assigns) do
    ~H"""
    <svg
      width="16"
      height="16"
      viewBox="0 0 16 16"
      fill="none"
      stroke="currentColor"
      style="display: block"
      aria-hidden="true"
    >
      <path stroke-linecap="round" d="M1.5 11V7.5c0-2.5 2.5-6 6.5-6s6.5 3.5 6.5 6V11" />
      <path d="M12 7.5c1.3807 0 2.5 1.11929 2.5 2.5v2c0 1.3807-1.1193 2.5-2.5 2.5h-1.5v-7zm-8 0h1.5v7H4c-1.38071 0-2.5-1.1193-2.5-2.5v-2c0-1.38071 1.11929-2.5 2.5-2.5Z" />
    </svg>
    """
  end

  def tooltip_hero_icon(%{kind: :stopwatch} = assigns) do
    ~H"""
    <svg
      width="16"
      height="16"
      viewBox="0 0 16 16"
      fill="none"
      stroke="currentColor"
      style="display: block"
      aria-hidden="true"
    >
      <circle cx="8" cy="8.5" r="6" />
      <path stroke-linecap="square" stroke-linejoin="round" d="M8 9.5v-5m0-2v-2m-2 0h4M12 4l1.5-1.5" />
    </svg>
    """
  end

  def tooltip_hero_icon(%{kind: :trash} = assigns) do
    ~H"""
    <svg
      width="16"
      height="16"
      viewBox="0 0 16 16"
      fill="none"
      stroke="currentColor"
      stroke-linejoin="round"
      style="display: block"
      aria-hidden="true"
    >
      <path stroke-linecap="square" d="M2.5 4h11" />
      <path stroke-linecap="round" d="M6.5 4V3c0-.82843.67157-1.5 1.5-1.5s1.5.67157 1.5 1.5v1" />
      <path
        stroke-linecap="square"
        d="m3.5 4 .87069 9.1422c.07332.7699.7199 1.3578 1.49324 1.3578h4.27217c.7733 0 1.4199-.5879 1.4932-1.3578L12.5 4"
      />
    </svg>
    """
  end

  # ── generic sample data for the autocomplete demos ────────────────────────
  defp baseui_autocomplete_tags do
    [
      %{value: "feature", group: "Type"},
      %{value: "bug", group: "Type"},
      %{value: "docs", group: "Area"},
      %{value: "design", group: "Area"},
      %{value: "urgent", group: "Priority"}
    ]
  end

  defp baseui_autocomplete_limit_tags do
    Enum.map(~w(react vue svelte angular solid qwik ember preact lit alpine), &%{value: &1})
  end

  defp baseui_autocomplete_docs do
    [
      %{title: "Quick start", description: "Install and render your first component."},
      %{title: "Styling", description: "Bring your own CSS or Tailwind utilities."},
      %{title: "Accessibility", description: "Built-in ARIA roles and keyboard support."},
      %{title: "Theming", description: "Tokens, dark mode, and variants."}
    ]
  end

  defp baseui_autocomplete_movies do
    [
      %{title: "Sample Film One", year: 2021},
      %{title: "Sample Film Two", year: 2019},
      %{title: "Another Picture", year: 2023},
      %{title: "A Short Story", year: 2018}
    ]
  end

  defp baseui_autocomplete_palette_suggestions do
    [
      %{label: "New file", name: "new-file"},
      %{label: "New window", name: "new-window"},
      %{label: "Open recent", name: "open-recent"}
    ]
  end

  defp baseui_autocomplete_palette_commands do
    [
      %{label: "Toggle theme", name: "toggle-theme"},
      %{label: "Format document", name: "format"},
      %{label: "Go to line", name: "goto-line"},
      %{label: "Find in files", name: "find"}
    ]
  end

  defp baseui_autocomplete_emojis do
    [
      %{emoji: "😀", name: "grinning", group: "Smileys"},
      %{emoji: "🎉", name: "party", group: "Objects"},
      %{emoji: "🚀", name: "rocket", group: "Travel"},
      %{emoji: "❤️", name: "heart", group: "Symbols"},
      %{emoji: "👍", name: "thumbs up", group: "People"}
    ]
  end
end
