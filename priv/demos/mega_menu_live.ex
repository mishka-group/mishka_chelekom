defmodule MishkaWeb.ChelekomLive.Docs.MegaMenuLive do
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
      |> assign(page_title: "Mega Menu - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <div class="relative w-full">
      <.mega_menu
        space="small"
        rounded="large"
        padding="extra_small"
        top_gap="large"
      >
          <:trigger>
            <.button>MegaMenu</.button>
          </:trigger>

          <div class="grid md:grid-cols-2 lg:grid-cols-3">
          <ul class="space-y-4 sm:mb-4 md:mb-0" aria-labelledby="mega-menu-full-cta-button">
            <li class="hover:underline hover:text-blue-600 cursor-pointer">
              Product Categories
            </li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">
              Customer Support
            </li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">
              About Us
            </li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">
              Contact
            </li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline hover:text-blue-600 cursor-pointer">
              Blog
            </li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">
              Privacy Policy
            </li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">
              Terms of Service
            </li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">
              Documentation
            </li>
          </ul>
        </div>
      </.mega_menu>
    </div>
    """
  end

  defp code_string(2) do
    """
    <!--Default is base it's not necessary to specify the name of color and variant-->
    <.mega_menu></.mega_menu>
    <.mega_menu color="white" variant="default"></.mega_menu>
    <.mega_menu color="primary" variant="outline"></.mega_menu>
    <.mega_menu color="secondary" variant="bordered"></.mega_menu>
    <.mega_menu color="natural" variant="shadow"></.mega_menu>
    <.mega_menu color="success" variant="default"></.mega_menu>
    <.mega_menu color="warning" variant="outline"></.mega_menu>
    <.mega_menu color="danger" variant="bordered"></.mega_menu>
    <.mega_menu color="info" variant="shadow"></.mega_menu>
    <.mega_menu color="silver" variant="default"></.mega_menu>
    <.mega_menu color="misc" variant="outline"></.mega_menu>
    <.mega_menu color="dark" variant="bordered"></.mega_menu>
    <.mega_menu color="dawn" variant="gradient"></.mega_menu>
    """
  end

  defp code_string(3) do
    """
    <.mega_menu id="unique_id" clickable></.mega_menu>
    """
  end

  defp code_string(4) do
    """
    <.mega_menu size="extra_small"></.mega_menu>
    <.mega_menu size="small"></.mega_menu>
    <.mega_menu size="medium"></.mega_menu>
    <.mega_menu size="large"></.mega_menu>
    <.mega_menu size="extra_large"></.mega_menu>
    """
  end

  defp code_string(5) do
    """
    <.mega_menu space="small"></.mega_menu>
    <.mega_menu space="medium"></.mega_menu>
    <.mega_menu space="large"></.mega_menu>
    <.mega_menu space="extra_small"></.mega_menu>
    <.mega_menu space="medium"></.mega_menu>
    """
  end

  defp code_string(6) do
    """
    <.mega_menu padding="small"></.mega_menu>
    <.mega_menu padding="medium"></.mega_menu>
    <.mega_menu padding="large"></.mega_menu>
    <.mega_menu padding="extra_small"></.mega_menu>
    <.mega_menu padding="medium"></.mega_menu>
    """
  end

  defp code_string(7) do
    """
    <.mega_menu rounded="small"></.mega_menu>
    <.mega_menu rounded="medium"></.mega_menu>
    <.mega_menu rounded="large"></.mega_menu>
    <.mega_menu rounded="extra_small"></.mega_menu>
    <.mega_menu rounded="medium"></.mega_menu>
    """
  end

  defp code_string(8) do
    """
    <.mega_menu border="small"></.mega_menu>
    <.mega_menu border="medium"></.mega_menu>
    <.mega_menu border="large"></.mega_menu>
    <.mega_menu border="extra_small"></.mega_menu>
    <.mega_menu border="medium"></.mega_menu>
    """
  end

  defp code_string(9) do
    """
    <.mega_menu font_weight="font-bold"></.mega_menu>
    <.mega_menu font_weight="font-silver"></.mega_menu>
    <.mega_menu font_weight="font-semibold"></.mega_menu>
    """
  end

  defp code_string(10) do
    """
    <.mega_menu>
       <:trigger>
        <button>Trigger button</button>
      </:trigger>
    </.mega_menu>

    <.mega_menu>
       <:trigger>
        <.button>Trigger button</.button>
      </:trigger>
    </.mega_menu>

    """
  end

  defp code_string(11) do
    """
    <.mega_menu top_gap="small"></.mega_menu>
    <.mega_menu top_gap="medium"></.mega_menu>
    <.mega_menu top_gap="large"></.mega_menu>
    <.mega_menu top_gap="extra_small"></.mega_menu>
    <.mega_menu top_gap="medium"></.mega_menu>
    """
  end

  defp component_config() do
    [
      name: "mega_menu",
      args: [
        variant: ["default", "outline", "bordered", "shadow", "gradeint", "base"],
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
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        space: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        only: ["mega_menu"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/mega-menu"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Mega menu component for Phoenix and Phoenix LiveView, serving as a full-width dropdown in the navbar to display an organized list of menu items with customizable sizes, variants, and styles.",
      keywords:
        "phoenix mega menu component, mega menu component, liveview mega menu component, elixir, liveview, mishka chelekom mega menu component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Mega Menu - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Mega Menu - Chelekom Phoenix & LiveView component",
      og_title: "Mega Menu - Chelekom Phoenix & LiveView component",
      og_description:
        "Mega menu component for Phoenix and Phoenix LiveView, serving as a full-width dropdown in the navbar to display an organized list of menu items with customizable sizes, variants, and styles.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Mega Menu - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Mega menu component for Phoenix and Phoenix LiveView, serving as a full-width dropdown in the navbar to display an organized list of menu items with customizable sizes, variants, and styles."
    }
  end
end
