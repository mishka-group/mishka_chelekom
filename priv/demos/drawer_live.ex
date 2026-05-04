defmodule MishkaWeb.ChelekomLive.Docs.DrawerLive do
  use MishkaWeb, :live_view
  alias MishkaWeb.Components.Drawer

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
      |> assign(page_title: "Drawer - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
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
     <.button phx-click={Drawer.show_drawer("drawer_id", "bottom")}>Open</.button>
     <.button phx-click={Drawer.show_drawer("drawer_id", "top")}>Open</.button>
     <.button phx-click={Drawer.show_drawer("drawer_id", "right")}>Open</.button>
     <.button phx-click={Drawer.hide_drawer("drawer_id", "left")}>Open</.button>
    """
  end

  defp code_string(2) do
    """
    <.drawer id="unique_id" color="natural"></.drawer>

    <.drawer id="unique_id" color="white"></.drawer>

    <.drawer id="unique_id" color="dark"></.drawer>

    <.drawer id="unique_id" color="primary"></.drawer>

    <.drawer id="unique_id" color="secondary"></.drawer>

    <.drawer id="unique_id" color="success"></.drawer>

    <.drawer id="unique_id" color="warning"></.drawer>

    <.drawer id="unique_id" color="danger"></.drawer>

    <.drawer id="unique_id" color="info"></.drawer>

    <.drawer id="unique_id" color="silver"/.drawer>

    <.drawer id="unique_id" color="misc"></.drawer>

    <.drawer id="unique_id" color="dawn"></.drawer>
    """
  end

  defp code_string(3) do
    """
    <.drawer id="unique_id" variant="outline" color="natural"></.drawer>

    <.drawer id="unique_id" variant="outline" color="primary"></.drawer>

    <.drawer id="unique_id" variant="outline" color="secondary"></.drawer>

    <.drawer id="unique_id" variant="outline" color="success"></.drawer>

    <.drawer id="unique_id" variant="outline" color="warning"></.drawer>

    <.drawer id="unique_id" variant="outline" color="danger"></.drawer>

    <.drawer id="unique_id" variant="outline" color="info"></.drawer>

    <.drawer id="unique_id" variant="outline" color="silver"/.drawer>

    <.drawer id="unique_id" variant="outline" color="misc"></.drawer>

    <.drawer id="unique_id" variant="outline" color="dawn"></.drawer>
    """
  end

  defp code_string(6) do
    """
    <.drawer id="unique_id" variant="transparent" color="natural"></.drawer>

    <.drawer id="unique_id" variant="transparent" color="primary"></.drawer>

    <.drawer id="unique_id" variant="transparent" color="secondary"></.drawer>

    <.drawer id="unique_id" variant="transparent" color="success"></.drawer>

    <.drawer id="unique_id" variant="transparent" color="warning"></.drawer>

    <.drawer id="unique_id" variant="transparent" color="danger"></.drawer>

    <.drawer id="unique_id" variant="transparent" color="info"></.drawer>

    <.drawer id="unique_id" variant="transparent" color="silver"/.drawer>

    <.drawer id="unique_id" variant="transparent" color="misc"></.drawer>

    <.drawer id="unique_id" variant="transparent" color="dawn"></.drawer>
    """
  end

  defp code_string(7) do
    """
    <.drawer id="unique_id" border="extra_small"></.drawer>

    <.drawer id="unique_id" border="small"></.drawer>

    <.drawer id="unique_id" border="medium"></.drawer>

    <.drawer id="unique_id" border="large"></.drawer>

    <.drawer id="unique_id" border="extra_large"></.drawer>
    """
  end

  defp code_string(8) do
    """
    <.drawer id="unique_id" size="extra_small"></.drawer>

    <.drawer id="unique_id" size="small"></.drawer>

    <.drawer id="unique_id" size="medium"></.drawer>

    <.drawer id="unique_id" size="large"></.drawer>

    <.drawer id="unique_id" size="extra_large"></.drawer>
    """
  end

  defp code_string(9) do
    """
     <.drawer title="Drawer Title" title_class="your_classes"></.drawer>
    """
  end

  defp code_string(10) do
    """
    <.drawer id="unique_id" position="left"></.drawer>

    <.drawer id="unique_id" position="right"></.drawer>

    <.drawer id="unique_id" position="top"></.drawer>

    <.drawer id="unique_id" position="bottom"></.drawer>
    """
  end

  defp code_string(11) do
    """
    <.drawer id="unique_id" show={true}></.drawer>
    <!--You can omit specifying the show prop if its value is false-->
    <.drawer id="unique_id" show={false}></.drawer>
    <.drawer id="unique_id"></.drawer>
    """
  end

  defp code_string(12) do
    """
    <.drawer id="unique_id">
      <:header>
        <div>Content within header slot</div>
      </:header>
    </.drawer>
    """
  end

  defp code_string(13) do
    """
    <.drawer id="unique_id" variant="bordered" color="natural"></.drawer>

    <.drawer id="unique_id" variant="bordered" color="white"></.drawer>

    <.drawer id="unique_id" variant="bordered" color="dark"></.drawer>

    <.drawer id="unique_id" variant="bordered" color="primary"></.drawer>

    <.drawer id="unique_id" variant="bordered" color="secondary"></.drawer>

    <.drawer id="unique_id" variant="bordered" color="success"></.drawer>

    <.drawer id="unique_id" variant="bordered" color="warning"></.drawer>

    <.drawer id="unique_id" variant="bordered" color="danger"></.drawer>

    <.drawer id="unique_id" variant="bordered" color="info"></.drawer>

    <.drawer id="unique_id" variant="bordered" color="silver"/.drawer>

    <.drawer id="unique_id" variant="bordered" color="misc"></.drawer>

    <.drawer id="unique_id" variant="bordered" color="dawn"></.drawer>
    """
  end

  defp code_string(14) do
    """
    <.drawer id="unique_id" variant="gradient" color="natural"></.drawer>

    <.drawer id="unique_id" variant="gradient" color="primary"></.drawer>

    <.drawer id="unique_id" variant="gradient" color="secondary"></.drawer>

    <.drawer id="unique_id" variant="gradient" color="success"></.drawer>

    <.drawer id="unique_id" variant="gradient" color="warning"></.drawer>

    <.drawer id="unique_id" variant="gradient" color="danger"></.drawer>

    <.drawer id="unique_id" variant="gradient" color="info"></.drawer>

    <.drawer id="unique_id" variant="gradient" color="silver"/.drawer>

    <.drawer id="unique_id" variant="gradient" color="misc"></.drawer>

    <.drawer id="unique_id" variant="gradient" color="dawn"></.drawer>
    """
  end

  defp code_string(15) do
    """
    <.drawer id="unique_id"></.drawer>
    """
  end

  defp component_config() do
    [
      name: "drawer",
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
        only: ["drawer"],
        helpers: [hide_drawer: 3, show_drawer: 3],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/drawer"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Flexible sliding drawers for Phoenix and LiveView with customizable positioning, styling, and interactive show and hide functionality.",
      keywords:
        "phoenix drawer component, drawer component, liveview drawer component, elixir, liveview, mishka chelekom drawer component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Drawer - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Drawer - Chelekom Phoenix & LiveView component",
      og_title: "Drawer - Chelekom Phoenix & LiveView component",
      og_description:
        "Flexible sliding drawers for Phoenix and LiveView with customizable positioning, styling, and interactive show and hide functionality.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Drawer - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Flexible sliding drawers for Phoenix and LiveView with customizable positioning, styling, and interactive show and hide functionality."
    }
  end
end
