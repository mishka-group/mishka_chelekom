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
  import DevelopmentWeb.Components.Headless.Checkbox
  import DevelopmentWeb.Components.Headless.Dialog
  import DevelopmentWeb.Components.Headless.Menu
  import DevelopmentWeb.Components.Headless.Pill
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
