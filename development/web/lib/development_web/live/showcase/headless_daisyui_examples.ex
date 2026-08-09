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
  import DevelopmentWeb.Components.Headless.Checkbox
  import DevelopmentWeb.Components.Headless.Dialog
  import DevelopmentWeb.Components.Headless.Menu
  import DevelopmentWeb.Components.Headless.Select
  import DevelopmentWeb.Components.Headless.Switch
  import DevelopmentWeb.Components.Headless.Tabs

  @faq [
    {"What is a skin?",
     "A stylesheet that paints the classes and data-attributes the headless component already emits. It never touches markup, ARIA or behavior."},
    {"Does it change the component?",
     "No. The same generated module renders both galleries — only the stylesheet differs, so keyboard navigation and screen-reader semantics are identical."},
    {"Can I still use utility classes?",
     "Yes. Every per-part class attribute still applies on top, so you can override any part the skin paints."}
  ]

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
    "menu" => [
      {"menu-hero", "Dropdown menu",
       "A daisyUI button opening a `menu` popup, with separators splitting the groups of actions."},
      {"menu-placement", "Placement",
       "daisyUI ships sixteen `dropdown-{top,bottom,left,right}` × `dropdown-{start,center,end}` classes; ours are the `side` and `align` attributes."},
      {"menu-hover", "On hover", "daisyUI's `dropdown-hover` — our `open_on_hover` attribute."},
      {"menu-sizes", "Sizes", "`menu-xs` through `menu-lg` on the popup part."},
      {"menu-rich", "Checkboxes, radios and a submenu",
       "The full menu surface — checkbox items, a radio group and a nested submenu — all painted by the skin."},
      {"menu-card", "Card as dropdown",
       "daisyUI's card-shaped dropdown: arbitrary content in the popup instead of rows."}
    ]
  }

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
    assigns = assign(assigns, :sizes, ~w(xs sm md lg))

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
end
