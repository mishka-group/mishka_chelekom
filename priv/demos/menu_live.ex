defmodule MishkaWeb.ChelekomLive.Docs.MenuLive do
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
      |> assign(page_title: "Menu - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.menu padding="extra_small"></.menu>
    <.menu padding="small"></.menu>
    <.menu padding="medium"></.menu>
    <.menu padding="large"></.menu>
    <.menu padding="extra_large"></.menu>
    """
  end

  defp code_string(2) do
    """
    <.menu space="extra_small"></.menu>
    <.menu space="small"></.menu>
    <.menu space="medium"></.menu>
    <.menu space="large"></.menu>
    <.menu space="extra_large"></.menu>
    """
  end

  defp code_string(3) do
    """
    <!--Choose any color for buttons and accordion as -->
    list_menues = [
      %{
        id: "Dashboard",
        navigate: "/path",
        title: "Dashboard",
        size: "extra_small",
        color: "misc",
        variant: "transparent",
        rounded: "large",
        class: "class name",
        display: "flex",
        icon_class: "",
        icon: "hero-home",
        active: true
      },
      %{
        id: "Settings",
        title: "Settings",
        padding: "pl-5 space-y-3 mt-3",
        size: "extra_small",
        rounded: "large",
        color: "misc",
        variant: "menu",
        icon: "",
        icon_class: "",
        sub_items: [
          %{
            navigate: "/path",
            title: "Account Settings",
            size: "extra_small",
            color: "misc",
            variant: "transparent",
            rounded: "large",
            class: "class name",
            display: "flex",
            icon_class: "",
            icon: ""
          }
        ]
      }
    ]

    <.menu menu_items={@list_menues} />
    """
  end

  defp code_string(4) do
    """
    <!--Choose any color for buttons and accordion as -->
    <.menu space="small">
      <li>
        <.button_link variant="transparent" navigate="/path">Dashboard</.button_link>
      </li>

      <li>
        <.button_link variant="transparent" navigate="/path">Footer</.button_link>
      </li>

      <li>
        <.accordion id="unique_id" variant="transparent" padding="small">
          <:item title="Settings">
          <.button_link variant="transparent" navigate="/path">Account</.button_link>
          </:item>
        </.accordion>
      </li>

      <li>
        <.button_link variant="transparent" navigate="/path">Modal</.button_link>
      </li>

      <li>
        <.button_link variant="transparent" navigate="/path">List</.button_link>
      </li>
    </.menu>
    """
  end

  defp component_config() do
    [
      name: "menu",
      args: [
        space: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        only: ["menu"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: ["accordion", "button"]
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/menu"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "A menu component for Phoenix LiveView that works as a wrapper for menu content, supporting nested items and customizable styles.",
      keywords:
        "phoenix menu component, menu component, liveview menu component, elixir, liveview, mishka chelekom menu component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Menu - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Menu - Chelekom Phoenix & LiveView component",
      og_title: "Menu - Chelekom Phoenix & LiveView component",
      og_description:
        "A menu component for Phoenix LiveView that works as a wrapper for menu content, supporting nested items and sub menus and customizable styles.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Menu - Chelekom Phoenix & LiveView component",
      twitter_description:
        "A menu component for Phoenix LiveView that works as a wrapper for menu content, supporting nested items and sub menus and customizable styles."
    }
  end
end
