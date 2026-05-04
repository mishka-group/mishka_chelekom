defmodule MishkaWeb.ChelekomLive.Docs.SidebarLive do
  use MishkaWeb, :live_view
  alias MishkaWeb.Components.Sidebar

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

  @all_sidebars Enum.map(1..12, &"sidebar-example-#{&1}")

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Sidebar - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(sidebar_pos: "none")
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))
      |> assign(code_5: code_string(5))
      |> assign(code_6: code_string(6))
      |> assign(code_7: code_string(7))
      |> assign(code_8: code_string(8))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("sidebar_position", %{"pos" => pos}, socket) do
    socket =
      socket
      |> assign(sidebar_pos: if(Enum.member?(@all_sidebars, pos), do: pos, else: "none"))

    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <!--Default variant is base which has only one color named base-->
    <!--You don't need to specify name of variant and color for base variant-->
    <.sidebar id="unique_id" variant="base" color="white"></.sidebar>

    <.sidebar id="unique_id" variant="default" color="white"></.sidebar>

    <.sidebar id="unique_id" variant="outline" color="primary"></.sidebar>

    <.sidebar id="unique_id" variant="transparent" color="secondary"></.sidebar>

    <.sidebar id="unique_id" variant="unbordered" color="dark"></.sidebar>

    <.sidebar id="unique_id" variant="shadow" color="success"></.sidebar>

    <.sidebar id="unique_id" variant="outline" color="warning"></.sidebar>

    <.sidebar id="unique_id" variant="shadow" color="danger"></.sidebar>

    <.sidebar id="unique_id" variant="unbordered" color="info"></.sidebar>

    <.sidebar id="unique_id" variant="transparent" color="light"></.sidebar>

    <.sidebar id="unique_id" variant="default" color="misc"></.sidebar>

    <.sidebar id="unique_id" color="dawn"></.sidebar>
    """
  end

  defp code_string(2) do
    """
    <.sidebar id="unique_id" border="extra_small"></.sidebar>

    <.sidebar id="unique_id" border="small"></.sidebar>

    <.sidebar id="unique_id" border="medium"></.sidebar>

    <.sidebar id="unique_id" border="large"></.sidebar>

    <.sidebar id="unique_id" border="extra_large"></.sidebar>
    """
  end

  defp code_string(3) do
    """
    <.sidebar id="unique_id" size="extra_small"></.sidebar>

    <.sidebar id="unique_id" size="small"></.sidebar>

    <.sidebar id="unique_id" size="medium"></.sidebar>

    <.sidebar id="unique_id" size="large"></.sidebar>

    <.sidebar id="unique_id" size="extra_large"></.sidebar>
    """
  end

  defp code_string(4) do
    """
    <.sidebar id="unique_id" position="start"></.sidebar>
    <.sidebar id="unique_id" position="end"></.sidebar>
    """
  end

  defp code_string(5) do
    """
    <.sidebar id="unique_id" hide_position="left"></.sidebar>
    <.sidebar id="unique_id" hide_position="right"></.sidebar>
    """
  end

  defp code_string(6) do
    """
    <button
      phx-click={Sidebar.show_sidebar("unique_sidebar_id", "hide_poistion_value")}
    >
      Open Sidebar
    </button>
    """
  end

  defp code_string(7) do
    """
    <.sidebar minimize>
      <:item
        icon="user"
        icon_class="text-gray-500"
        label="Profile"
        label_class="text-sm text-gray-700"
        link="/profile"
      />
      <:item
        icon="bell"
        icon_class="text-red-400"
        label="Notifications"
        label_class="font-medium"
        link="/notifications"
      />
    </.sidebar>
    """
  end

  defp code_string(8) do
    """
    <.sidebar>
      <:item
        icon="hero-user"
        icon_class="text-gray-500"
        label="Profile"
        label_class="text-sm text-gray-700"
        link="/profile"
      />
      <:item
        icon="hero-bell"
        icon_class="text-red-400"
        label="Notifications"
        label_class="font-medium"
        link="/notifications"
      />
    </.sidebar>
    """
  end

  defp component_config() do
    [
      name: "sidebar",
      args: [
        variant: ["default", "outline", "transparent", "bordered", "gradient", "base"],
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
        only: ["sidebar"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/sidebar"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Customizable sidebar for Phoenix LiveView, offering dynamic navigation and collapsible content with configurable themes, sizes, and behavior.",
      keywords:
        "phoenix sidebar component, sidebar component, liveview sidebar component, elixir, liveview, mishka chelekom sidebar component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Sidebar - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Sidebar - Chelekom Phoenix & LiveView component",
      og_title: "Sidebar - Chelekom Phoenix & LiveView component",
      og_description:
        "Customizable sidebar for Phoenix LiveView, offering dynamic navigation and collapsible content with configurable themes, sizes, and behavior.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Sidebar - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Customizable sidebar for Phoenix LiveView, offering dynamic navigation and collapsible content with configurable themes, sizes, and behavior."
    }
  end
end
