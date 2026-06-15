defmodule DevelopmentWeb.Showcase.KitDemo do
  @moduledoc """
  Renders the RESULT of `DevelopmentWeb.ShowcaseKit` for the showcase "Customize it" section — the
  live, brand-customized component, delegating to the real one via the Kit's generated wrapper.
  """
  use DevelopmentWeb, :html
  import DevelopmentWeb.ShowcaseKit

  @available ~w(accordion alert avatar badge banner blockquote breadcrumb button card carousel chat checkbox_card checkbox_field color_field combobox date_time_field device_mockup divider dock drawer dropdown email_field fieldset file_field footer form_wrapper indicator jumbotron keyboard list mega_menu modal native_select navbar number_field overlay pagination password_field popover progress radio_card radio_field range_field rating search_field sidebar skeleton speed_dial spinner stat stepper table table_content tabs tel_field text_field textarea_field timeline toast toggle_field tooltip url_field)
  def available?(name), do: name in @available

  attr :component, :string, required: true

  def demo(%{component: "alert"} = assigns) do
    ~H"""
    <div class="space-y-2">
      <.alert_kit kind={:brand} title="New :brand color">
        Added via the Kit — delegates to the real <code>&lt;.alert&gt;</code>; classes win with a trailing <code>!</code>.
      </.alert_kit>
      <.alert_kit kind={:cocoa} title="Another added color, :cocoa" />
      <.alert_kit kind={:brand} variant="glow" title="New :glow variant (a glow ring + shadow)" />
    </div>
    """
  end

  def demo(%{component: "accordion"} = assigns) do
    ~H"""
    <.accordion_kit id="accordion-kit-demo" color="brand">
      <:item id="accordion-kit-demo-1" title="Brand accordion item one">
        Item one content
      </:item>

      <:item id="accordion-kit-demo-2" title="Brand accordion item two">
        Item two content
      </:item>
    </.accordion_kit>
    """
  end

  def demo(%{component: "avatar"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.avatar_kit id="avatar-kit-demo" color="brand">MK</.avatar_kit>
      <.avatar_kit id="avatar-kit-demo-icon" color="brand">
        <:icon name="hero-user" />
      </.avatar_kit>
    </div>
    """
  end

  def demo(%{component: "badge"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.badge_kit color="brand">Brand badge</.badge_kit>
      <.badge_kit>Default badge</.badge_kit>
    </div>
    """
  end

  def demo(%{component: "banner"} = assigns) do
    ~H"""
    <.banner_kit id="banner-kit-demo" color="brand" class="!static !w-full">
      Brand banner
    </.banner_kit>
    """
  end

  def demo(%{component: "blockquote"} = assigns) do
    ~H"""
    <.blockquote_kit id="blockquote-kit-demo" color="brand">
      Brand blockquote
    </.blockquote_kit>
    """
  end

  def demo(%{component: "breadcrumb"} = assigns) do
    ~H"""
    <.breadcrumb_kit id="breadcrumb-kit-demo" color="brand">
      <:item>Mishka Chelekom</:item>
      <:item>Accordion</:item>
      <:item>Alert</:item>
    </.breadcrumb_kit>
    """
  end

  def demo(%{component: "button"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <.button_kit id="button-kit-demo" color="brand">Brand button</.button_kit>
      <.button_kit id="button-kit-demo-icon" color="brand" icon="hero-bookmark">Save</.button_kit>
    </div>
    """
  end

  def demo(%{component: "card"} = assigns) do
    ~H"""
    <.card_kit id="card-kit-demo" color="brand" variant="default" padding="small">
      <.card_content>
        Brand card from Mishka Chelekom.
      </.card_content>
    </.card_kit>
    """
  end

  def demo(%{component: "carousel"} = assigns) do
    ~H"""
    <div class="w-full max-w-2xl">
      <.carousel_kit id="carousel-kit-demo" color="brand">
        <:slide image="https://picsum.photos/seed/chelekom-1/960/420" title="Brand carousel" />
        <:slide image="https://picsum.photos/seed/chelekom-2/960/420" title="Second slide" />
      </.carousel_kit>
    </div>
    """
  end

  def demo(%{component: "chat"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6">
      <.chat_kit id="chat-kit-demo" color="brand" variant="default">
        <.chat_section>
          <div>Shahryar Tavakkoli</div>
          <p>This bubble uses the Kit-customized brand color of the chat component.</p>
          <:status time="22:10" deliver="Delivered" />
        </.chat_section>
      </.chat_kit>
    </div>
    """
  end

  def demo(%{component: "checkbox_card"} = assigns) do
    ~H"""
    <.checkbox_card_kit
      id="checkbox_card-kit-demo"
      name="checkbox_card-kit-demo"
      color="brand"
      cols="two"
      size="medium"
      show_checkbox
    >
      <:checkbox value="basic" title="Basic Plan" description="For small teams"></:checkbox>
      <:checkbox value="pro" title="Pro Plan" description="For growing businesses"></:checkbox>
    </.checkbox_card_kit>
    """
  end

  def demo(%{component: "checkbox_field"} = assigns) do
    ~H"""
    <.checkbox_field_kit
      color="brand"
      id="checkbox_field-kit-demo"
      name="terms"
      value="true"
      checked={true}
      label="Brand checkbox_field"
    />
    """
  end

  def demo(%{component: "color_field"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.color_field_kit
        id="color_field-kit-demo"
        name="kit-color-1"
        value="#4f46e5"
        color="brand"
        label="Brand color"
        description="Kit-customized color field"
      />
      <.color_field_kit
        id="color_field-kit-demo-circle"
        name="kit-color-2"
        value="#4f46e5"
        color="brand"
        circle
        label="Brand color (circle)"
      />
    </div>
    """
  end

  def demo(%{component: "combobox"} = assigns) do
    ~H"""
    <.combobox_kit
      id="combobox-kit-demo"
      name="countries"
      color="brand"
      multiple
      searchable
      placeholder="Select countries..."
    >
      <:option value="ca">Canada</:option>
      <:option value="us">United States</:option>
      <:option value="mx">Mexico</:option>
    </.combobox_kit>
    """
  end

  def demo(%{component: "date_time_field"} = assigns) do
    assigns = assign(assigns, :form, to_form(%{}, as: :demo))

    ~H"""
    <.date_time_field_kit
      field={@form[:start]}
      color="brand"
      type="date"
      label="Brand date_time_field"
    />
    """
  end

  def demo(%{component: "device_mockup"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.device_mockup_kit id="device_mockup-kit-demo" color="brand">
        <div class="pt-10 px-4 space-y-2">
          <div class="h-3 w-24 bg-gray-300 rounded"></div>
          <div class="h-24 w-full bg-gray-200 rounded-lg"></div>
          <div class="h-3 w-32 bg-gray-300 rounded"></div>
        </div>
      </.device_mockup_kit>
    </div>
    """
  end

  def demo(%{component: "divider"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6 w-full">
      <.divider_kit id="divider-kit-demo" color="brand" />
      <.divider_kit id="divider-kit-demo-text" color="brand" size="small" position="middle">
        <:text>Brand divider</:text>
      </.divider_kit>
    </div>
    """
  end

  def demo(%{component: "dock"} = assigns) do
    ~H"""
    <.dock_kit id="dock-kit-demo" color="brand">
      <:item icon="hero-home" label="Home" navigate="/" active />
      <:item icon="hero-inbox" label="Inbox" navigate="/" />
      <:item icon="hero-cog-6-tooth" label="Settings" navigate="/" />
    </.dock_kit>
    """
  end

  def demo(%{component: "drawer"} = assigns) do
    ~H"""
    <div class="relative min-h-48">
      <.drawer_kit
        id="drawer-kit-demo"
        color="brand"
        position="left"
        size="small"
        title="Brand Drawer"
      >
        <ul>
          <li class="py-2 px-3 cursor-pointer">Home</li>
          <li class="py-2 px-3 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 cursor-pointer">Settings</li>
        </ul>
      </.drawer_kit>
    </div>
    """
  end

  def demo(%{component: "dropdown"} = assigns) do
    ~H"""
    <.dropdown_kit
      id="dropdown-kit-demo"
      color="brand"
      space="small"
      rounded="large"
      padding="extra_small"
    >
      <:trigger>
        <.button size="extra_small">
          Brand dropdown
        </.button>
      </:trigger>

      <:content>
        <ul class="text-xs">
          <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
          <li class="py-1.5 px-2 cursor-pointer">Settings</li>
          <li class="py-1.5 px-2 cursor-pointer">Earning</li>
          <li class="py-1.5 px-2 cursor-pointer">Sign out</li>
        </ul>
      </:content>
    </.dropdown_kit>
    """
  end

  def demo(%{component: "email_field"} = assigns) do
    ~H"""
    <.email_field_kit
      id="email_field-kit-demo"
      name="email"
      value=""
      color="brand"
      label="Brand email field"
    />
    """
  end

  def demo(%{component: "fieldset"} = assigns) do
    ~H"""
    <.fieldset_kit color="brand" id="fieldset-kit-demo" legend="News" space="small">
      <:control>
        <.checkbox_field
          name="fieldset_kit_newsletter"
          value=""
          space="small"
          label="Subscribe to newsletter updates"
          id="fieldset-kit-newsletter"
          checked
        />
      </:control>
      <:control>
        <.checkbox_field
          name="fieldset_kit_terms"
          value=""
          space="small"
          label="I accept the terms and conditions"
          id="fieldset-kit-terms"
        />
      </:control>
    </.fieldset_kit>
    """
  end

  def demo(%{component: "file_field"} = assigns) do
    assigns = assign(assigns, :form, to_form(%{}, as: :demo))

    ~H"""
    <.file_field_kit field={@form[:file]} color="brand" label="Brand file_field" />
    """
  end

  def demo(%{component: "footer"} = assigns) do
    ~H"""
    <.footer_kit id="footer-kit-demo" color="brand" variant="default" text_position="center">
      © Mishka Chelekom - All Rights Reserved
    </.footer_kit>
    """
  end

  def demo(%{component: "form_wrapper"} = assigns) do
    assigns = assign(assigns, :form, to_form(%{}, as: :demo))

    ~H"""
    <.form_wrapper_kit for={@form} color="brand">
      <p class="text-sm">A brand-customized form_wrapper.</p>
    </.form_wrapper_kit>
    """
  end

  def demo(%{component: "indicator"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-8">
      <.indicator_kit id="indicator-kit-demo" color="brand" size="medium" />
      <.indicator_kit id="indicator-kit-demo-ping" color="brand" size="medium" pinging />
    </div>
    """
  end

  def demo(%{component: "jumbotron"} = assigns) do
    ~H"""
    <.jumbotron_kit color="brand" padding="small" class="text-center" id="jumbotron-kit-demo">
      <h1 class="text-lg font-bold">Welcome to Mishka Chelekom</h1>
      <p class="text-sm mt-2">
        Your all-in-one solution for Phoenix LiveView components, tailored to your needs.
      </p>
    </.jumbotron_kit>
    """
  end

  def demo(%{component: "keyboard"} = assigns) do
    ~H"""
    <div class="flex items-center gap-4">
      <.keyboard_kit id="keyboard-kit-demo" color="brand">Ctrl + C</.keyboard_kit>
    </div>
    """
  end

  def demo(%{component: "list"} = assigns) do
    ~H"""
    <.list_kit id="list-kit-demo" color="brand" variant="bordered">
      <:item padding="small">Home</:item>
      <:item padding="small">Services</:item>
      <:item padding="small">About Us</:item>
      <:item padding="small">Contact</:item>
    </.list_kit>
    """
  end

  def demo(%{component: "mega_menu"} = assigns) do
    ~H"""
    <div class="relative w-full flex justify-center items-center">
      <.mega_menu_kit
        color="brand"
        id="mega_menu-kit-demo"
        rounded="large"
        padding="extra_small"
        top_gap="large"
      >
        <:trigger>
          <.button variant="outline" color="natural">Brand MegaMenu</.button>
        </:trigger>

        <div class="grid md:grid-cols-2">
          <ul class="space-y-4 sm:mb-4 md:mb-0">
            <li class="hover:underline cursor-pointer">Product Categories</li>
            <li class="hover:underline cursor-pointer">Customer Support</li>
            <li class="hover:underline cursor-pointer">About Us</li>
            <li class="hover:underline cursor-pointer">Contact</li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline cursor-pointer">Blog</li>
            <li class="hover:underline cursor-pointer">Privacy Policy</li>
            <li class="hover:underline cursor-pointer">Terms of Service</li>
            <li class="hover:underline cursor-pointer">Documentation</li>
          </ul>
        </div>
      </.mega_menu_kit>
    </div>
    """
  end

  def demo(%{component: "modal"} = assigns) do
    ~H"""
    <.modal_kit id="modal-kit-demo" color="brand" title="Brand modal">
      <p>Brand-customized modal content.</p>
    </.modal_kit>
    """
  end

  def demo(%{component: "native_select"} = assigns) do
    ~H"""
    <.native_select_kit
      name="native_select-kit-demo"
      id="native_select-kit-demo"
      color="brand"
      label="Brand native select"
      space="small"
    >
      <:option value="" selected>Choose one</:option>
      <:option value="v1">Backend developer</:option>
      <:option value="v2">Frontend developer</:option>
      <:option value="v3">Full stack developer</:option>
    </.native_select_kit>
    """
  end

  def demo(%{component: "navbar"} = assigns) do
    ~H"""
    <.navbar_kit id="navbar-kit-demo" color="brand" max_width="extra_large" name="Mishka" link="#">
      <:list><.link href="#">Mishka</.link></:list>
      <:list><.link href="#">Chelekom</.link></:list>
      <:list><.link href="#">Blog</.link></:list>
      <:list><.link href="#">Docs</.link></:list>
    </.navbar_kit>
    """
  end

  def demo(%{component: "number_field"} = assigns) do
    ~H"""
    <div class="grid md:grid-cols-2 gap-5">
      <.number_field_kit
        color="brand"
        id="number_field-kit-demo-1"
        name="number_field-kit-1"
        value=""
        space="small"
        size="small"
        label="Quantity"
        placeholder="Enter a number"
      />
      <.number_field_kit
        color="brand"
        id="number_field-kit-demo-2"
        name="number_field-kit-2"
        value="42"
        space="small"
        size="small"
        label="Amount"
        description="Brand-colored number field"
        placeholder="Enter a number"
      />
    </div>
    """
  end

  def demo(%{component: "overlay"} = assigns) do
    ~H"""
    <div class="relative h-96">
      <.overlay_kit id="overlay-kit-demo" color="brand" opacity="almost_solid">
        <div class="flex justify-center items-center h-full">
          <div class="text-white">Brand overlay</div>
        </div>
      </.overlay_kit>
    </div>
    """
  end

  def demo(%{component: "pagination"} = assigns) do
    ~H"""
    <.pagination_kit id="pagination-kit-demo" color="brand" total={10} active={1} size="small" />
    """
  end

  def demo(%{component: "password_field"} = assigns) do
    ~H"""
    <.password_field_kit
      id="password_field-kit-demo"
      color="brand"
      name="password"
      label="Password"
      placeholder="Enter your password"
      value=""
      show_password={true}
    >
      <:start_section>
        <.icon name="hero-lock-closed" class="size-4" />
      </:start_section>
    </.password_field_kit>
    """
  end

  def demo(%{component: "popover"} = assigns) do
    ~H"""
    <.popover_kit
      id="popover-kit-demo"
      color="brand"
      variant="default"
      width="large"
      padding="small"
      rounded="small"
    >
      <:trigger>
        <.button color="info" size="small" variant="outline">Brand popover</.button>
      </:trigger>
      <:content>
        Content within the brand popover
      </:content>
    </.popover_kit>
    """
  end

  def demo(%{component: "progress"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <.progress_kit id="progress-kit-demo" color="brand" value={60} />
    </div>
    """
  end

  def demo(%{component: "radio_card"} = assigns) do
    ~H"""
    <.radio_card_kit
      name="radio_card-kit-demo"
      id="radio_card-kit-demo"
      color="brand"
      cols="two"
      padding="medium"
      size="medium"
      class="text-center"
    >
      <:radio value="kit-basic" title="Basic Plan" description="For small teams"></:radio>
      <:radio value="kit-pro" title="Pro Plan" description="For growing businesses"></:radio>
    </.radio_card_kit>
    """
  end

  def demo(%{component: "radio_field"} = assigns) do
    ~H"""
    <.radio_field_kit
      color="brand"
      id="radio_field-kit-demo-1"
      name="kit_option"
      value="brand"
      label="Brand radio_field"
      checked
    />
    <.radio_field_kit
      color="brand"
      id="radio_field-kit-demo-2"
      name="kit_option"
      value="other"
      label="Another option"
    />
    """
  end

  def demo(%{component: "range_field"} = assigns) do
    ~H"""
    <.range_field_kit
      id="range_field-kit-demo"
      color="brand"
      appearance="custom"
      label="Brand range"
      name="range_field-kit-demo"
      value="40"
      min="0"
      max="100"
      step="5"
    >
      <:range_value position="start">0</:range_value>
      <:range_value position="middle">50</:range_value>
      <:range_value position="end">100</:range_value>
    </.range_field_kit>
    """
  end

  def demo(%{component: "rating"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.rating_kit id="rating-kit-demo" color="brand" select={3} size="large" />
      <.rating_kit id="rating-kit-demo-2" color="brand" select={5} size="large" />
    </div>
    """
  end

  def demo(%{component: "search_field"} = assigns) do
    assigns = assign(assigns, :form, to_form(%{}, as: :demo))

    ~H"""
    <.search_field_kit field={@form[:q]} color="brand" label="Brand search field" />
    """
  end

  def demo(%{component: "sidebar"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-6">
      <.sidebar_kit
        id="sidebar-kit-demo"
        color="brand"
        hide_position="left"
        list_wrapper_class="ps-2.5"
        class="!relative !h-auto !z-0 max-h-72 w-64 rounded"
      >
        <:item icon="hero-home" label="Dashboard" link="/" class="mb-3 text-[14px]" />
        <:item icon="hero-envelope" label="Messages" link="/" class="mb-3 text-[14px]" />
        <:item icon="hero-cog-6-tooth" label="Settings" link="/" class="mb-3 text-[14px]" />
      </.sidebar_kit>
    </div>
    """
  end

  def demo(%{component: "skeleton"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 w-full">
      <.skeleton_kit id="skeleton-kit-demo" color="brand" width="full" height="large" rounded="large" />
      <.skeleton_kit id="skeleton-kit-demo-2" color="brand" width="w-1/2" height="medium" animated />
    </div>
    """
  end

  def demo(%{component: "speed_dial"} = assigns) do
    ~H"""
    <div class="relative h-48">
      <.speed_dial_kit
        id="speed_dial-kit-demo"
        color="brand"
        size="large"
        icon="hero-plus"
        action_position="bottom-start"
      >
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial_kit>
    </div>
    """
  end

  def demo(%{component: "spinner"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-10">
      <.spinner_kit id="spinner-kit-demo" color="brand" size="large" />
      <.spinner_kit id="spinner-kit-demo-dots" color="brand" size="large" type="dots" />
    </div>
    """
  end

  def demo(%{component: "stat"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.stat_kit color="brand" title="Total revenue" value="$45,231.89" description="Last 30 days" />
    </div>
    """
  end

  def demo(%{component: "stepper"} = assigns) do
    ~H"""
    <.stepper_kit id="stepper-kit-demo" color="brand">
      <.stepper_section step="completed" title="Account" description="Create an account" />
      <.stepper_section step="current" title="Verify" description="Verify email" />
      <.stepper_section title="Finish" description="Get full access" />
    </.stepper_kit>
    """
  end

  def demo(%{component: "table"} = assigns) do
    ~H"""
    <.table_kit color="brand" rows_border="extra_small" id="table-kit-demo">
      <:header>Name</:header>
      <:header>Age</:header>
      <:header>Address</:header>

      <.tr>
        <.td>Alice Johnson</.td>
        <.td>34</.td>
        <.td>New York, No. 5 Broadway</.td>
      </.tr>

      <.tr>
        <.td>Michael Scott</.td>
        <.td>45</.td>
        <.td>Scranton, No. 2 Paper Road</.td>
      </.tr>
    </.table_kit>
    """
  end

  def demo(%{component: "table_content"} = assigns) do
    ~H"""
    <.table_content_kit id="table_content-kit-demo" color="brand" variant="bordered" rounded="large">
      <.content_item icon="hero-hashtag">
        <.link href="#overview">Overview</.link>
      </.content_item>
      <.content_item icon="hero-hashtag">
        <.link href="#colors">Color and Variants</.link>
      </.content_item>
      <.content_item icon="hero-hashtag" active>
        <.link href="#rounded">Rounded</.link>
      </.content_item>
    </.table_content_kit>
    """
  end

  def demo(%{component: "tabs"} = assigns) do
    ~H"""
    <.tabs_kit id="tabs-kit-demo" color="brand" variant="pills" padding="large">
      <:tab icon="hero-user-circle" active>Profile</:tab>
      <:tab icon="hero-cog-6-tooth">Settings</:tab>

      <:panel>
        <p>Brand-colored Profile tab content.</p>
      </:panel>
      <:panel>
        <p>Brand-colored Settings tab content.</p>
      </:panel>
    </.tabs_kit>
    """
  end

  def demo(%{component: "tel_field"} = assigns) do
    assigns = assign(assigns, :form, to_form(%{}, as: :demo))

    ~H"""
    <.tel_field_kit field={@form[:phone]} color="brand" label="Brand tel_field" />
    """
  end

  def demo(%{component: "text_field"} = assigns) do
    ~H"""
    <.text_field_kit
      id="text_field-kit-demo"
      name="text_field-kit-demo"
      value=""
      color="brand"
      space="small"
      size="small"
      label="Email Address"
      placeholder="Enter your email address"
    />
    """
  end

  def demo(%{component: "textarea_field"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.textarea_field_kit
        color="brand"
        id="textarea_field-kit-demo"
        name="textarea_kit_demo"
        value=""
        label="Message"
        placeholder="Type your message"
        description="Brand-customized textarea field"
      />
      <.textarea_field_kit
        color="brand"
        id="textarea_field-kit-demo-floating"
        name="textarea_kit_demo_floating"
        value=""
        floating="outer"
        label="Notes"
        placeholder="Add notes"
      />
    </div>
    """
  end

  def demo(%{component: "timeline"} = assigns) do
    ~H"""
    <.timeline_kit id="timeline-kit-demo" color="brand">
      <.timeline_section
        title="Initial Setup"
        time="24 Oct, 2024"
        description="Set up the initial project structure for Mishka Chelekom."
      >
        <div class="mt-1 -ms-1 p-1 inline-flex items-center gap-x-2 text-xs">
          Mona Aghili
        </div>
      </.timeline_section>

      <.timeline_section
        title="Component Development"
        time="30 Oct, 2024"
        description="Developed several core components, including the timeline and card."
      >
        <div class="mt-1 -ms-1 p-1 inline-flex items-center gap-x-2 text-xs">
          Mona Aghili
        </div>
      </.timeline_section>
    </.timeline_kit>
    """
  end

  def demo(%{component: "toast"} = assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-4">
      <.toast_kit id="toast-kit-demo" color="brand" variant="default" fixed={false}>
        Brand toast
      </.toast_kit>
      <.toast_kit id="toast-kit-demo-2" color="brand" variant="default" fixed={false}>
        Another brand toast
      </.toast_kit>
    </div>
    """
  end

  def demo(%{component: "toggle_field"} = assigns) do
    assigns = assign(assigns, :form, to_form(%{}, as: :demo))

    ~H"""
    <.toggle_field_kit
      field={@form[:enabled]}
      checked={true}
      color="brand"
      label="Brand toggle_field (on)"
    />
    """
  end

  def demo(%{component: "tooltip"} = assigns) do
    ~H"""
    <.tooltip_kit
      id="tooltip-kit-demo"
      color="brand"
      position="top"
      text="Brand tooltip"
    >
      <:trigger>
        <button class="p-2">Hover me</button>
      </:trigger>
    </.tooltip_kit>
    """
  end

  def demo(%{component: "url_field"} = assigns) do
    assigns = assign(assigns, :form, to_form(%{}, as: :demo))

    ~H"""
    <.url_field_kit field={@form[:url]} color="brand" label="Brand url field" />
    """
  end

  def demo(assigns), do: ~H""
end
