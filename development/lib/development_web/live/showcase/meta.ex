defmodule DevelopmentWeb.Showcase.Meta do
  @moduledoc """
  Authored, human-written metadata that can't be derived from the catalogs: a one-line
  description for every styled and headless component, and the styled↔headless cross-link map.

  Everything else on a component page (attributes, slots, real examples, the macro/override
  snippets) is *derived* from `priv/components/chelekom.json` and the `.exs` catalogs — so this
  module is the single place to curate prose. Add a component here and its page reads well; miss
  one and it falls back to a sensible generated sentence.
  """

  @styled %{
    "accordion" =>
      "Vertically stacked, expandable sections that reveal one or more panels of content.",
    "alert" => "Prominent inline message communicating status — info, success, warning or error.",
    "avatar" =>
      "User or entity image with fallback initials, sizes, shapes and status indicators.",
    "badge" => "Small count or status label, often attached to an icon or button.",
    "blockquote" => "Styled quotation block for highlighting excerpts and citations.",
    "breadcrumb" => "Hierarchical navigation trail showing the user's location in the app.",
    "button" => "Clickable action element with variants, colors, sizes, icons and loading state.",
    "card" => "Flexible content container with media, header, body and footer regions.",
    "carousel" => "Rotating slideshow of images or content with controls and indicators.",
    "chat" => "Conversation bubbles for messaging interfaces, with author, time and status.",
    "checkbox_card" => "Selectable card wrapping a checkbox for richer multi-select options.",
    "checkbox_field" => "Form checkbox input with label, description, colors and error state.",
    "clipboard" => "Copy-to-clipboard control with feedback for any text or value.",
    "collapse" => "Single toggleable region that shows or hides its content.",
    "color_field" => "Form input for picking and entering color values.",
    "combobox" => "Text input paired with a filterable dropdown list of options.",
    "date_time_field" => "Form input for selecting dates and times.",
    "device_mockup" =>
      "Decorative device frame (phone, tablet, laptop) wrapping a screenshot or content.",
    "divider" => "Horizontal or vertical line separating content, optionally with a label.",
    "dock" => "macOS-style dock bar of icon actions.",
    "drawer" => "Panel that slides in from a screen edge for navigation or details.",
    "dropdown" => "Toggleable menu of actions anchored to a trigger.",
    "email_field" => "Form input for email addresses with validation styling.",
    "fieldset" => "Groups related form controls under a shared legend.",
    "file_field" => "Form input for uploading files, with styling and states.",
    "footer" => "Page footer with columns of links, branding and legal text.",
    "form_wrapper" => "Styled container that lays out a form and its actions.",
    "gallery" => "Grid of images with layout and spacing options.",
    "icon" => "Renders a Heroicon (or custom) SVG icon by name.",
    "image" => "Responsive image with rounded, shadow and aspect-ratio options.",
    "indicator" => "Small dot or badge marking status or notifications on an element.",
    "input_field" => "General-purpose text form input with label, sizes and states.",
    "jumbotron" => "Large hero banner for headlines and calls to action.",
    "keyboard" => "Renders keystrokes as styled <kbd> keys.",
    "layout" => "Page layout scaffold with header, sidebar and content regions.",
    "list" => "Ordered, unordered and description lists with styling.",
    "mega_menu" => "Wide multi-column navigation panel anchored to a nav item.",
    "menu" => "Vertical list of navigation or action items.",
    "modal" => "Centered overlay dialog for focused tasks and confirmations.",
    "native_select" => "Styled wrapper around a native <select> element.",
    "navbar" => "Top navigation bar with brand, links and a responsive menu.",
    "number_field" => "Form input for numeric values with min, max and step.",
    "overlay" => "Dimmed backdrop layer used behind modals and drawers.",
    "pagination" => "Page navigation controls for paged lists and tables.",
    "password_field" => "Form input for passwords with a reveal toggle and states.",
    "popover" => "Floating panel of rich content anchored to a trigger.",
    "progress" => "Bar or ring showing completion of a task.",
    "radio_card" => "Selectable card wrapping a radio input for richer single-select.",
    "radio_field" => "Form radio input with label, colors and error state.",
    "range_field" => "Slider form input for selecting a value within a range.",
    "rating" => "Star (or custom) rating input and display.",
    "scroll_area" => "Scrollable region with custom, styled scrollbars.",
    "search_field" => "Form input for search with icon and clear affordances.",
    "shape" => "Decorative geometric shapes and dividers.",
    "sidebar" => "Collapsible vertical navigation panel for app shells.",
    "skeleton" => "Animated placeholder blocks shown while content loads.",
    "speed_dial" => "Floating action button that expands to reveal more actions.",
    "spinner" => "Animated loading indicator in several styles and sizes.",
    "stat" => "Compact figure with label, value and trend for dashboards.",
    "stepper" => "Step-by-step progress indicator for multi-stage flows.",
    "table_content" => "Table-of-contents navigation generated from page sections.",
    "table" => "Data table with headers, rows, styling and density options.",
    "tabs" => "Tabbed interface that switches between panels of content.",
    "tel_field" => "Form input for telephone numbers.",
    "text_field" => "Single-line text form input with label, sizes, colors and states.",
    "textarea_field" => "Multi-line text form input with label and states.",
    "timeline" => "Vertical or horizontal sequence of dated events.",
    "toast" => "Transient notification that appears and auto-dismisses.",
    "toggle_field" => "On/off switch form input with label and colors.",
    "tooltip" => "Small hint shown on hover or focus of an element.",
    "typography" => "Text styles — headings, paragraphs, lead and inline elements.",
    "url_field" => "Form input for URLs with validation styling.",
    "video" => "Responsive video player wrapper with ratio and styling."
  }

  @headless %{
    "accordion" =>
      "Disclosure group where each header toggles its panel — full ARIA and keyboard.",
    "action_icon" => "Icon-only action button with a required accessible label.",
    "alert_dialog" => "Modal dialog that interrupts to confirm a critical action; focus-trapped.",
    "anchor" => "A plain, themeable link.",
    "autocomplete" => "Text input with an ARIA listbox of filtered suggestions.",
    "avatar" => "Image with loading and fallback states, unstyled.",
    "burger" => "Hamburger navigation toggle with aria-expanded and an animated icon.",
    "checkbox_group" => "Group of checkboxes sharing a label and state.",
    "checkbox" => "Accessible checkbox supporting checked and indeterminate state.",
    "chip" => "Selectable pill backed by a native checkbox or radio input.",
    "close_button" => "Icon-only button with a required accessible label, for dismissing UI.",
    "code" => "Inline or block code, semantics only.",
    "collapsible" => "A single trigger/panel pair that expands and collapses.",
    "color_swatch" => "Display a single color as a labelled swatch.",
    "combobox" => "Input plus popup listbox combining typing and selection.",
    "context_menu" => "Right-click menu with roving focus and keyboard support.",
    "dialog" => "Modal dialog with focus trap, ARIA and paired-presence state.",
    "drawer" => "Edge panel with focus management and dismissal behaviour.",
    "empty_state" =>
      "Presentational placeholder for empty views — indicator, title, description and actions, unstyled.",
    "fieldset" => "Accessible grouping of form controls with a legend.",
    "field" => "Label, control, description and error wiring for one form field.",
    "mark" => "Highlight an inline run of text with <mark>.",
    "mask_input" => "Text field that formats itself to a pattern as you type.",
    "highlight" => "Wrap case-insensitive matches of query terms in <mark>.",
    "json_input" => "Textarea for JSON with a server-validated error state.",
    "loading_overlay" => "Cover a container with a centered loader (toggle via visible).",
    "marquee" => "Continuously scrolling row of content (pure CSS).",
    "number_formatter" => "Render a number with separators, prefix and suffix.",
    "hue_slider" => "Pick a hue (0–360°) on a rainbow track (reuses Slider).",
    "alpha_slider" => "Pick an opacity (0–100) over a checkerboard (reuses Slider).",
    "splitter" => "Two resizable panes with a draggable, keyboard-friendly divider.",
    "scroller" => "Horizontal scroll row with prev/next controls.",
    "semi_circle_progress" => "Half-circle progress gauge (SVG, no JS).",
    "rolling_number" => "Animate a number rolling to its value.",
    "color_picker" => "Saturation/value area with a hue slider and preview.",
    "menubar" => "Horizontal application menu bar with submenus and roving focus.",
    "menu" => "Popup menu of actions with roving tabindex and keyboard.",
    "meter" => "Static gauge reporting a value within a known range (ARIA meter).",
    "navigation_menu" => "Site navigation with disclosure submenus.",
    "nav_link" => "Navigation item; a link, or a disclosure with nested links.",
    "number_field" => "Spinbutton input with increment/decrement and clamping.",
    "otp_field" => "Segmented one-time-code input with paste and keyboard handling.",
    "pill" => "Compact tag/token with an optional accessible remove button.",
    "pills_input" => "Input-shaped container for pills plus a text field.",
    "popover" => "Anchored floating panel with dismissal and focus return.",
    "preview_card" => "Hover/focus card that reveals a rich preview.",
    "progress" => "Determinate or indeterminate progress bar (ARIA progressbar).",
    "radio_group" => "Single-select radio group with roving focus.",
    "radio" => "A single accessible radio control.",
    "scroll_area" => "Scrollable region with accessible custom scrollbars.",
    "select" => "Listbox select with typeahead and keyboard navigation.",
    "segmented_control" => "Row of mutually-exclusive segments (native radios).",
    "separator" => "Semantic divider (ARIA separator), horizontal or vertical.",
    "slider" => "Range slider with one or more thumbs, keyboard and ARIA.",
    "spoiler" => "Clamp long content behind a Show more / Show less toggle.",
    "switch" => "On/off toggle with switch role and keyboard.",
    "tabs" => "Tab list and panels with roving focus and ARIA.",
    "tags_input" => "Removable tokens plus a text field for entering a list of values.",
    "theme_icon" => "A container that wraps an icon, decorative or labelled.",
    "toast" => "Live-region notification stack with timing and dismissal.",
    "toggle_group" => "A set of toggle buttons, single- or multiple-pressed.",
    "toggle" => "Two-state toggle button (aria-pressed).",
    "toolbar" => "Group of controls sharing a roving tabindex.",
    "tooltip" => "Hover/focus hint wired with aria-describedby.",
    "tree" =>
      "Unstyled tree view — Mantine's Tree converted to a Phoenix headless component for Mishka " <>
        "Chelekom: expand/collapse, selection, cascading checkboxes, keyboard nav, drag & drop and " <>
        "async loading.",
    "visually_hidden" => "Hidden visually but available to screen readers."
  }

  @links %{
    "accordion" => "accordion",
    "modal" => "dialog",
    "drawer" => "drawer",
    "popover" => "popover",
    "tooltip" => "tooltip",
    "menu" => "menu",
    "combobox" => "combobox",
    "scroll_area" => "scroll_area",
    "avatar" => "avatar",
    "progress" => "progress",
    "tabs" => "tabs",
    "toast" => "toast",
    "fieldset" => "fieldset",
    "number_field" => "number_field",
    "divider" => "separator",
    "collapse" => "collapsible",
    "toggle_field" => "toggle",
    "native_select" => "select",
    "radio_field" => "radio",
    "checkbox_field" => "checkbox",
    "range_field" => "slider",
    "date_time_field" => "calendar"
  }

  @reverse_links Map.new(@links, fn {styled, headless} -> {headless, styled} end)

  @doc "One-line description for a styled component (generated fallback if not authored)."
  def styled_description(name),
    do: Map.get(@styled, name) || "A #{humanize(name)} component."

  @doc "One-line description for a headless component (generated fallback if not authored)."
  def headless_description(name),
    do: Map.get(@headless, name) || "An accessible, unstyled #{humanize(name)} component."

  @doc "The headless component a styled one maps to, or nil."
  def headless_sibling(styled_name), do: Map.get(@links, styled_name)

  @doc "The styled component a headless one maps to, or nil."
  def styled_sibling(headless_name), do: Map.get(@reverse_links, headless_name)

  defp humanize(name), do: name |> String.replace("_", " ")
end
