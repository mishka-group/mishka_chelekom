defmodule MishkaWeb.ChelekomLive.Docs.NavbarLive do
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
      |> assign(page_title: "Navbar - Chelekom Phoenix & LiveView component")
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
      |> assign(code_16: code_string(16))
      |> assign(code_17: code_string(17))
      |> assign(code_18: code_string(18))
      |> assign(code_19: code_string(19))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.navbar variant="default" color="natural"></.navbar>
    <.navbar variant="default" color="white"></.navbar>
    <.navbar variant="default" color="primary"></.navbar>
    <.navbar variant="default" color="secondary"></.navbar>
    <.navbar variant="default" color="dark"></.navbar>
    <.navbar variant="default" color="success"></.navbar>
    <.navbar variant="default" color="warning"></.navbar>
    <.navbar variant="default" color="danger"></.navbar>
    <.navbar variant="default" color="info"></.navbar>
    <.navbar variant="default" color="silver"></.navbar>
    <.navbar variant="default" color="misc"></.navbar>
    <.navbar variant="default" color="dawn"></.navbar>
    """
  end

  defp code_string(2) do
    """
    <.navbar color="natural" variant="shadow"></.navbar>
    <.navbar color="primary" variant="shadow"></.navbar>
    <.navbar color="secondary" variant="shadow"></.navbar>
    <.navbar color="success" variant="shadow"></.navbar>
    <.navbar color="warning" variant="shadow"></.navbar>
    <.navbar color="danger" variant="shadow"></.navbar>
    <.navbar color="info" variant="shadow"></.navbar>
    <.navbar color="silver" variant="shadow"></.navbar>
    <.navbar color="misc" variant="shadow"></.navbar>
    <.navbar color="dawn" variant="shadow"></.navbar>
    """
  end

  defp code_string(3) do
    """
    <.navbar color="natural" variant="bordered"></.navbar>
    <.navbar color="white" variant="bordered"></.navbar>
    <.navbar color="primary" variant="bordered"></.navbar>
    <.navbar color="secondary" variant="bordered"></.navbar>
    <.navbar color="dark" variant="bordered"></.navbar>
    <.navbar color="success" variant="bordered"></.navbar>
    <.navbar color="warning" variant="bordered"></.navbar>
    <.navbar color="danger" variant="bordered"></.navbar>
    <.navbar color="info" variant="bordered"></.navbar>
    <.navbar color="silver" variant="bordered"></.navbar>
    <.navbar color="misc" variant="bordered"></.navbar>
    <.navbar color="dawn" variant="bordered"></.navbar>
    """
  end

  defp code_string(4) do
    """
    <.navbar rounded="extra_small"></.navbar>
    <.navbar rounded="small"></.navbar>
    <.navbar rounded="medium"></.navbar>
    <.navbar rounded="large"></.navbar>
    <.navbar rounded="extra_large"></.navbar>
    """
  end

  defp code_string(5) do
    """
    <.navbar border="extra_small"></.navbar>
    <.navbar border="small"></.navbar>
    <.navbar border="medium"></.navbar>
    <.navbar border="large"></.navbar>
    <.navbar border="extra_large"></.navbar>
    """
  end

  defp code_string(6) do
    """
    <.navbar padding="extra_small"></.navbar>
    <.navbar padding="small"></.navbar>
    <.navbar padding="medium"></.navbar>
    <.navbar padding="large"></.navbar>
    <.navbar padding="extra_large"></.navbar>
    """
  end

  defp code_string(7) do
    """
    <.navbar max_width="extra_small"></.navbar>
    <.navbar max_width="small"></.navbar>
    <.navbar max_width="medium"></.navbar>
    <.navbar max_width="large"></.navbar>
    <.navbar max_width="extra_large"></.navbar>
    """
  end

  defp code_string(8) do
    """
    <.navbar text_position="left"></.navbar>
    <.navbar text_position="center"></.navbar>
    <.navbar text_position="right"></.navbar>
    """
  end

  defp code_string(9) do
    """
    <.navbar font_weight="font-silver"></.navbar>
    <.navbar font_weight="font-bold"></.navbar>
    <.navbar font_weight="font-medium"></.navbar>
    """
  end

  defp code_string(10) do
    """
    <.navbar link="/"></.navbar>
    """
  end

  defp code_string(11) do
    """
    <.navbar link="/" image="/path" image_class="your_classes"></.navbar>
    """
  end

  defp code_string(12) do
    """
    <.navbar link="/" image="/path" name="your_brand"></.navbar>
    """
  end

  defp code_string(13) do
    """
    <.navbar relative>
      <:list>
        <.dropdown width="w-full" relative="md:relative" clickable>
          <:trigger width="full" trigger_id="unique_id_1">
            <button class="text-start w-full block">Dropdown</button>
          </:trigger>

          <:content
            space="small"
            id="unique_id_1"
            rounded="large"
            width="large"
            padding="extra_small"
          >
            <ul class="space-y-5">
              <li>
                <.dropdown width="w-full" position="right" nomobile clickable>
                  <:trigger trigger_id="unique_id_2">
                    <button class="py-1 px-2">dropdown nested</button>
                  </:trigger>

                  <:content
                    id="unique_id_2"
                    space="small"
                    rounded="large"
                    width="large"
                    padding="extra_small"
                  >
                    <ul class="space-y-5">
                      <li class="py-1 px-2">Docs</li>
                      <li class="py-1 px-2">Footer</li>
                    </ul>
                  </:content>
                </.dropdown>
              </li>
              <li class="py-1 px-2">Memory</li>
              <li class="py-1 px-2">Design</li>
              <li>
                <.dropdown width="w-full" position="right" clickable>
                  <:trigger trigger_id="unique_id_3">
                    <button class="py-1 px-2">Dropdown</button>
                  </:trigger>

                  <:content
                    id="unique_id_3"
                    space="small"
                    rounded="large"
                    width="large"
                    padding="extra_small"
                  >
                    <ul class="space-y-5">
                      <li class="py-1 px-2">Security</li>
                      <li class="py-1 px-2">Roadmap</li>
                    </ul>
                  </:content>
                </.dropdown>
              </li>
              <li class="py-1 px-2">Tabs</li>
              <li class="py-1 px-2">Lists</li>
            </ul>
          </:content>
        </.dropdown>
      </:list>
      <:list><.link title="Mishka" navigate="/">Mishka</.link></:list>
      <:list><.link title="Chelekom" navigate="/chelekom">Chelekom</.link></:list>
      <:list><.link title="Blog" navigate="/blog">Blog</.link></:list>
      <:list><.link navigate="/chelekom/docs">Docs</.link></:list>
    </.navbar>

    """
  end

  defp code_string(14) do
    """
    <.navbar>
      <:list><.link title="Mishka" navigate="/">Mishka</.link></:list>
      <:list><.link title="Chelekom" navigate="/chelekom">Chelekom</.link></:list>
      <:list><.link title="Blog" navigate="/blog">Blog</.link></:list>
      <:list><.link navigate="/chelekom/docs">Docs</.link></:list>
    </.navbar>
    """
  end

  defp code_string(15) do
    """
    <.navbar>
      <:list icon="hero_icons" icon_class="your_classes">
        <.link title="Mishka" navigate="/">Mishka</.link>
      </:list>
      <:list icon="hero_icons" icon_class="your_classes">
        <.link title="Chelekom" navigate="/chelekom">Chelekom</.link>
      </:list>
      <:list icon="hero_icons" icon_class="your_classes">
        <.link title="Blog" navigate="/blog">Blog</.link>
      </:list>

      <!--Change order of text and icon by using icon_position prop -->
      <:list icon="hero_icons" icon_class="your_classes" icon_position="end">
        <.link navigate="/chelekom/docs">Docs</.link>
      </:list>
    </.navbar>
    """
  end

  defp code_string(16) do
    """
    <.navbar color="natural" variant="gradient"></.navbar>
    <.navbar color="primary" variant="gradient"></.navbar>
    <.navbar color="secondary" variant="gradient"></.navbar>
    <.navbar color="success" variant="gradient"></.navbar>
    <.navbar color="warning" variant="gradient"></.navbar>
    <.navbar color="danger" variant="gradient"></.navbar>
    <.navbar color="info" variant="gradient"></.navbar>
    <.navbar color="silver" variant="gradient"></.navbar>
    <.navbar color="misc" variant="gradient"></.navbar>
    <.navbar color="dawn" variant="gradient"></.navbar>
    """
  end

  defp code_string(17) do
    """
    <.navbar
      max_width="extra_large"
    >
      <:start_content>
        <.link
          navigate={~p"/"}
          class="flex items-center space-x-3 rtl:space-x-reverse mb-5 md:mb-0"
        >
          <img src={~p"/images/mishka-logo-white.svg"} class="dark:hidden size-10" />
          <img src={~p"/images/mishka-logo.svg"} class="hidden dark:block size-10" />
          <h1 class="text-xl font-semibold">Mishka</h1>
        </.link>
      </:start_content>

      <:list>
        <.link title="Mishak" navigate="/">Mishka</.link>
      </:list>

      <:list>
        <.link title="Mishak chelekom" navigate="/chelekom">Chelekom</.link>
      </:list>

      <:list>
        <.link title="Mishak blog" navigate="/blog">Blog</.link>
      </:list>

      <:list>
        <.link navigate="/chelekom/docs">Docs</.link>
      </:list>
    </.navbar>

    <.navbar
      max_width="extra_large"
    >
      <:list>
        <.link title="Mishak" navigate="/">Mishka</.link>
      </:list>

      <:list>
        <.link title="Mishak chelekom" navigate="/chelekom">Chelekom</.link>
      </:list>

      <:list>
        <.link title="Mishak blog" navigate="/blog">Blog</.link>
      </:list>

      <:list>
        <.link navigate="/chelekom/docs">Docs</.link>
      </:list>

      <:end_content>
        <.link
          navigate={~p"/"}
          class="flex items-center space-x-3 rtl:space-x-reverse mb-5 md:mb-0"
        >
          <img src={~p"/images/mishka-logo-white.svg"} class="dark:hidden size-10" />
          <img src={~p"/images/mishka-logo.svg"} class="hidden dark:block size-10" />
          <h1 class="text-xl font-semibold">Mishka</h1>
        </.link>
      </:end_content>
    </.navbar>

    """
  end

  defp code_string(18) do
    """
    <.navbar>
      <:start_content>
        <.link
          navigate="/path"
          class="flex items-center space-x-3 rtl:space-x-reverse mb-5 md:mb-0"
        >
          <img src="/path" class="hidden dark:block size-10" />
          <img src="/path" class="dark:hidden size-10" />
          <h1 class="text-xl font-semibold">
            Mishka
          </h1>
        </.link>
      </:start_content>
      <:list><.link title="Mishak" navigate="/">Mishka</.link></:list>

      <:list><.link title="Mishak chelekom" navigate="/chelekom">Chelekom</.link></:list>

      <:list><.link title="Mishak blog" navigate="/blog">Blog</.link></:list>

      <:list><.link navigate="/chelekom/docs">Docs</.link></:list>
    </.navbar>
    """
  end

  defp code_string(19) do
    """
    <.navbar content_position="center">
      Mishka Chelekom Library
    </.navbar>
    """
  end

  defp component_config() do
    [
      name: "navbar",
      args: [
        variant: ["default", "shadow", "bordered", "gradient", "base"],
        color: [
          "base",
          "natural",
          "white",
          "primary",
          "secondary",
          "dark",
          "success",
          "warning",
          "danger",
          "info",
          "silver",
          "misc",
          "dawn"
        ],
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["navbar", "header"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/navbar"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Navbar components for Phoenix and Phoenix LiveView, featuring responsive navigation bars with customizable styles, logos, menus, and interactive buttons.",
      keywords:
        "phoenix navbar component, navbar component, liveview navbar component, elixir, liveview, mishka chelekom navbar component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Navbar - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Navbar - Chelekom Phoenix & LiveView component",
      og_title: "Navbar - Chelekom Phoenix & LiveView component",
      og_description:
        "Navbar components for Phoenix and Phoenix LiveView, featuring responsive navigation bars with customizable styles, logos, menus, and interactive buttons.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Navbar - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Navbar components for Phoenix and Phoenix LiveView, featuring responsive navigation bars with customizable styles, logos, menus, and interactive buttons."
    }
  end
end
