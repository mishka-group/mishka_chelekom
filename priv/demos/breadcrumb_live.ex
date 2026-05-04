defmodule MishkaWeb.ChelekomLive.Docs.BreadcrumbLive do
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
    CustomInlineCode
  }

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Breadcrumb - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))
      |> assign(code_5: code_string(5))
      |> assign(code_16: code_string(16))
      |> assign(code_17: code_string(17))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.breadcrumb>
      <:item>item 1</:item>
      <:item>item 2</:item>
      <:item>item 3</:item>
      <:item>item 4</:item>
      <:item>item 5</:item>
    </.breadcrumb>
    """
  end

  defp code_string(2) do
    """
    <.breadcrumb>
      <:item title="title" link="/path">Link1</:item>
      <:item title="title" link="/path">Link2</:item>
      <:item>No link</:item>
    </.breadcrumb>
    """
  end

  defp code_string(3) do
    """
    <.breadcrumb>
      <:item icon="hero-cloud">Item1</:item>
      <:item icon="hero-circle-stack">Item2</:item>
      <:item icon="hero-envelope">Item3</:item>
    </.breadcrumb>
    """
  end

  defp code_string(4) do
    """
    <.breadcrumb separator_text="_" separator_text_class="">
      <:item>Mishka Chelekom</:item>
      <:item>Image</:item>
      <:item>Gallery</:item>
    </.breadcrumb>
    """
  end

  defp code_string(5) do
    """
    <!-- Note: The base color is the default color for breadcrumbs -->
    <.breadcrumb>
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb color="natural">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb color="primary">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb color="dark">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb color="white">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb color="secondary">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb color="success">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb color="warning">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb color="danger">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb color="info">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb color="silver">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb color="misc">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb color="dawn">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>
    """
  end

  defp code_string(16) do
    """
    <.breadcrumb size="extra_small">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb size="small">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb size="medium">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb size="large">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb size="extra_large">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>
    """
  end

  defp code_string(17) do
    """
    <.breadcrumb separator_icon="hero-star" separator_icon_class="">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>

    <.breadcrumb separator_icon="hero-x-mark">
      <:item>Item 1</:item>
      <:item>Item 2</:item>
      <:item>Item 3</:item>
    </.breadcrumb>
    """
  end

  defp component_config() do
    [
      name: "breadcrumb",
      args: [
        color: [
          "base",
          "natural",
          "dark",
          "white",
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
        only: ["breadcrumb"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/breadcrumb"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Breadcrumb component in Phoenix and LiveView improves website navigation by offering a clickable trail of links, enhancing user experience and engagement.",
      keywords:
        "phoenix breadcrumb component, breadcrumb component, liveview breadcrumb component, elixir, liveview, mishka chelekom breadcrumb component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Breadcrumb - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Breadcrumb - Chelekom Phoenix & LiveView component",
      og_title: "Breadcrumb - Chelekom Phoenix & LiveView component",
      og_description:
        "Breadcrumb component in Phoenix and LiveView improves website navigation by offering a clickable trail of links, enhancing user experience and engagement.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Breadcrumb - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Breadcrumb component in Phoenix and LiveView improves website navigation by offering a clickable trail of links, enhancing user experience and engagement."
    }
  end
end
