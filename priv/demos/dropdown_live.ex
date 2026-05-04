defmodule MishkaWeb.ChelekomLive.Docs.DropdownLive do
  use MishkaWeb, :live_view

  import MishkaWeb.Components.{
    CustomNav,
    CustomInfo,
    CustomTableContent,
    CustomTable,
    CustomSearch,
    CustomTypography,
    CustomCodeWrapper,
    CustomCliProps,
    CustomInlineCode,
    CustomBlock
  }

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Dropdown - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))
      |> assign(code_5: code_string(5))
      |> assign(code_6: code_string(6))
      |> assign(code_7: code_string(7))
      |> assign(code_8: code_string(8))
      |> assign(code_9: code_string(9))
      |> assign(code_10: code_string(10))
      |> assign(code_11: code_string(11))
      |> assign(code_12: code_string(12))
      |> assign(code_13: code_string(13))
      |> assign(code_14: code_string(14))
      |> assign(code_15: code_string(15))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.dropdown relative="relative" space="small" rounded="large" padding="extra_small">
      <:trigger class="custom_class">
        <.button size="extra_small">
          Toggle Dropdown
        </.button>
      </:trigger>

      <:content class="custom_class">
         <ul class="text-sm">
            <li class="py-1 px-1.5">
              <.link class="block hover:text-gray-600 dark:hover:text-gray-400" navigate="/path">
                Dashboard
              </.link>
            </li>
            <li class="py-1 px-1.5">
              <.link class="block hover:text-gray-600 dark:hover:text-gray-400" navigate="/path">
                Settings
              </.link>
            </li>
            <li class="py-1 px-1.5">
              <.link class="block hover:text-gray-600 dark:hover:text-gray-400" navigate="/path">
                Earning
              </.link>
            </li>
            <li class="py-1 px-1.5">
              <.link class="block hover:text-gray-600 dark:hover:text-gray-400" navigate="/path">
                Sign out
              </.link>
            </li>
          </ul>
      </:content>
    </.dropdown>
    """
  end

  defp code_string(2) do
    """
    <!--Base is default color and variant-->
    <.dropdown></.dropdown>

    <.dropdown  variant="default" color="natural"></.dropdown>

    <.dropdown variant="default" color="white"></.dropdown>

    <.dropdown variant="default" color="dark"></.dropdown>

    <.dropdown variant="default" color="primary"></.dropdown>

    <.dropdown variant="shadow" color="secondary"></.dropdown>

    <.dropdown variant="shadow" color="dark"></.dropdown>

    <.dropdown variant="bordered" color="success"></.dropdown>

    <.dropdown variant="bordered" color="warning"></.dropdown>

    <.dropdown variant="outline" color="danger"></.dropdown>

    <.dropdown variant="outline" color="info"></.dropdown>

    <.dropdown variant="default" color="silver"></.dropdown>

    <.dropdown variant="shadow" color="misc"></.dropdown>

    <.dropdown variant="bordered" color="dawn"></.dropdown>
    """
  end

  defp code_string(3) do
    """
    <.dropdown position="left"></.dropdown>

    <.dropdown position="right"></.dropdown>

    <.dropdown position="top"></.dropdown>

    <.dropdown position="top-left"></.dropdown>

    <.dropdown position="top-right"></.dropdown>

    <.dropdown position="bottom-left"></.dropdown>

    <.dropdown position="bottom-right"></.dropdown>
    """
  end

  defp code_string(4) do
    """
    <.dropdown relative="relative">
      <:trigger></:trigger>

      <:content></:content>
    </.dropdown>
    """
  end

  defp code_string(5) do
    """
    <.dropdown relative="relative" clickable id="unique_id">
      <:trigger></:trigger>

      <:content></:content>
    </.dropdown>
    """
  end

  defp code_string(6) do
    """
    <!--This is ecxactly how to use this prop-->
    <div class="relative">
      <.dropdown relative="md:relative" content_width="large" padding="extra_small">
        <:trigger>
          <.button class="w-full">Dropdown</.button>
        </:trigger>

        <:content>
          <ul class="space-y-5">
            <li>
              <.dropdown position="right" nomobile>
                <:trigger>
                  <button>Nested Dropdown</button>
                </:trigger>

                <:content
                  space="small"
                  rounded="large"
                  width="large"
                  padding="extra_small"
                >
                  <ul class="space-y-5">
                    <li>Security</li>
                    <li>Memory</li>
                    <li>Design</li>
                  </ul>
                </:content>
              </.dropdown>
            </li>
            <li>Tabs</li>
            <li>Links</li>
          </ul>
        </:content>
      </.dropdown>
    </div>
    """
  end

  defp code_string(7) do
    """
    <.dropdown relative="relative" width="w-full"></.dropdown>
    <.dropdown relative="relative" width="w-1/2"></.dropdown>
    <.dropdown relative="relative" width="w-fit"></.dropdown>
    """
  end

  defp code_string(8) do
    """
    <.dropdown relative="relative" rounded="extra_small"></.dropdown>

    <.dropdown relative="relative" rounded="small"></.dropdown>

    <.dropdown relative="relative" rounded="medium"></.dropdown>

    <.dropdown relative="relative" rounded="large"></.dropdown>

    <.dropdown relative="relative" rounded="extra_large"></.dropdown>
    """
  end

  defp code_string(9) do
    """
    <.dropdown relative="relative" space="extra_small"></.dropdown>

    <.dropdown relative="relative" space="small"></.dropdown>

    <.dropdown relative="relative" space="medium"></.dropdown>

    <.dropdown relative="relative" space="large"></.dropdown>

    <.dropdown relative="relative" space="extra_large"></.dropdown>
    """
  end

  defp code_string(10) do
    """
    <.dropdown relative="relative" border="extra_small"></.dropdown>

    <.dropdown relative="relative" border="small"></.dropdown>

    <.dropdown relative="relative border="medium""></.dropdown>

    <.dropdown relative="relative" border="large"></.dropdown>

    <.dropdown relative="relative" border="extra_large"></.dropdown>
    """
  end

  defp code_string(11) do
    """
     <.dropdown relative="relative" padding="extra_small"></.dropdown>

    <.dropdown relative="relative" padding="extra_small"></.dropdown>

    <.dropdown relative="relative" padding="extra_small"></.dropdown>

    <.dropdown relative="relative" padding="extra_small"></.dropdown>

    <.dropdown relative="relative" padding="extra_small"></.dropdown>
    """
  end

  defp code_string(12) do
    """
    <.dropdown relative="relative" width="extra_small"></.dropdown>

    <.dropdown relative="relative" width="small"></.dropdown>

    <.dropdown relative="relative" width="medium"></.dropdown>

    <.dropdown relative="relative" width="large"></.dropdown>

    <.dropdown relative="relative" width="extra_large"></.dropdown>

    <.dropdown relative="relative" width="double_large"></.dropdown>

    <.dropdown relative="relative" width="triple_large"></.dropdown>

    <.dropdown relative="relative" width="quadruple_large"></.dropdown>

    <.dropdown relative="relative" width="full"></.dropdown>
    """
  end

  defp code_string(13) do
    """
     <.dropdown relative="relative" size="extra_small"></.dropdown>

    <.dropdown relative="relative" size="small"></.dropdown>

    <.dropdown relative="relative" size="medium"></.dropdown>

    <.dropdown relative="relative" size="large"></.dropdown>

    <.dropdown relative="relative" size="extra_large"></.dropdown>
    """
  end

  defp code_string(14) do
    """
    <.dropdown relative="relative" font_Weight="font-bold"></.dropdown>

    <.dropdown relative="relative" font_Weight="font-thin"></.dropdown>
    """
  end

  defp code_string(15) do
    """
    <.dropdown smart_position={false}></.dropdown>
    <.dropdown smart_position={true}></.dropdown>
    """
  end

  defp component_config() do
    [
      name: "dropdown",
      args: [
        variant: ["default", "outline", "bordered", "shadow", "gradient", "base"],
        color: [
          "base",
          "natural",
          "white",
          "dark",
          "primary",
          "secondary",
          "success",
          "warning",
          "danger",
          "info",
          "silver",
          "misc",
          "dawn"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        type: ["dropdown", "dropdown_trigger", "dropdown_content"],
        only: ["dropdown", "dropdown_trigger", "dropdown_content"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/dropdown"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Dynamic dropdown menus with flexible styles and triggers in Phoenix LiveView to enhance user navigation and interaction.",
      keywords:
        "phoenix dropdown component, dropdown component, liveview dropdown component, elixir, liveview, mishka chelekom dropdown component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Dropdown - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Dropdown - Chelekom Phoenix & LiveView component",
      og_title: "Dropdown - Chelekom Phoenix & LiveView component",
      og_description:
        "Dynamic dropdown menus with flexible styles and triggers in Phoenix LiveView to enhance user navigation and interaction.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Dropdown - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Dynamic dropdown menus with flexible styles and triggers in Phoenix LiveView to enhance user navigation and interaction."
    }
  end
end
