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
  import DevelopmentWeb.Components.Headless.Anchor
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
