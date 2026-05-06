defmodule MishkaWeb.ChelekomLive.Docs.JumbotronLive do
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
      |> assign(page_title: "Jumbotron - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <!--You can use any HTML tag or Mishka Chelekom components within jumbotron tags-->
    <.jumbotron variant="default" color="natural">Natural</.jumbotron>
    <.jumbotron variant="default" color="white">White</.jumbotron>
    <.jumbotron variant="default" color="dark">Dark</.jumbotron>
    <.jumbotron variant="default" color="info">Info</.jumbotron>
    <.jumbotron variant="default" color="success">Success</.jumbotron>
    <.jumbotron variant="default" color="warning">Warning</.jumbotron>
    <.jumbotron variant="default" color="danger">Danger</.jumbotron>
    <.jumbotron variant="default" color="silver">Silver</.jumbotron>
    <.jumbotron variant="default" color="misc">Misc</.jumbotron>
    <.jumbotron variant="default" color="dawn">Dawn</.jumbotron>
    <.jumbotron variant="default" color="primary">Primary</.jumbotron>
    <.jumbotron variant="default" color="secondary">Secondary</.jumbotron>
    """
  end

  defp code_string(2) do
    """
    <!--You can use any HTML tag or Mishka Chelekom components within jumbotron tags-->
    <.jumbotron variant="outline" color="natural">Natural</.jumbotron>
    <.jumbotron variant="outline" color="info">Info</.jumbotron>
    <.jumbotron variant="outline" color="success">Success</.jumbotron>
    <.jumbotron variant="outline" color="warning">Warning</.jumbotron>
    <.jumbotron variant="outline" color="danger">Danger</.jumbotron>
    <.jumbotron variant="outline" color="silver">Silver</.jumbotron>
    <.jumbotron variant="outline" color="misc">Misc</.jumbotron>
    <.jumbotron variant="outline" color="dawn">Dawn</.jumbotron>
    <.jumbotron variant="outline" color="primary">Primary</.jumbotron>
    <.jumbotron variant="outline" color="secondary">Secondary</.jumbotron>
    """
  end

  defp code_string(3) do
    """
    <!--You can use any HTML tag or Mishka Chelekom components within jumbotron tags-->
    <.jumbotron variant="shadow" color="natural">Natural</.jumbotron>
    <.jumbotron variant="shadow" color="info">Info</.jumbotron>
    <.jumbotron variant="shadow" color="success">Success</.jumbotron>
    <.jumbotron variant="shadow" color="warning">Warning</.jumbotron>
    <.jumbotron variant="shadow" color="danger">Danger</.jumbotron>
    <.jumbotron variant="shadow" color="silver">Silver</.jumbotron>
    <.jumbotron variant="shadow" color="misc">Misc</.jumbotron>
    <.jumbotron variant="shadow" color="dawn">Dawn</.jumbotron>
    <.jumbotron variant="shadow" color="primary">Primary</.jumbotron>
    <.jumbotron variant="shadow" color="secondary">Secondary</.jumbotron>
    """
  end

  defp code_string(4) do
    """
    <!--You can use any HTML tag or Mishka Chelekom components within jumbotron tags-->
    <.jumbotron variant="bordered" color="natural">Natural</.jumbotron>
    <.jumbotron variant="bordered" color="dark">Dark</.jumbotron>
    <.jumbotron variant="bordered" color="white">White</.jumbotron>
    <.jumbotron variant="bordered" color="info">Info</.jumbotron>
    <.jumbotron variant="bordered" color="success">Success</.jumbotron>
    <.jumbotron variant="bordered" color="warning">Warning</.jumbotron>
    <.jumbotron variant="bordered" color="danger">Danger</.jumbotron>
    <.jumbotron variant="bordered" color="silver">Silver</.jumbotron>
    <.jumbotron variant="bordered" color="misc">Misc</.jumbotron>
    <.jumbotron variant="bordered" color="dawn">Dawn</.jumbotron>
    <.jumbotron variant="bordered" color="primary">Primary</.jumbotron>
    <.jumbotron variant="bordered" color="secondary">Secondary</.jumbotron>
    """
  end

  defp code_string(5) do
    """
    <!--You can use any HTML tag or Mishka Chelekom components within jumbotron tags-->
    <.jumbotron variant="transparent" color="natural">Natural</.jumbotron>
    <.jumbotron variant="transparent" color="info">Info</.jumbotron>
    <.jumbotron variant="transparent" color="success">Success</.jumbotron>
    <.jumbotron variant="transparent" color="warning">Warning</.jumbotron>
    <.jumbotron variant="transparent" color="danger">Danger</.jumbotron>
    <.jumbotron variant="transparent" color="silver">Silver</.jumbotron>
    <.jumbotron variant="transparent" color="misc">Misc</.jumbotron>
    <.jumbotron variant="transparent" color="dawn">Dawn</.jumbotron>
    <.jumbotron variant="transparent" color="primary">Primary</.jumbotron>
    <.jumbotron variant="transparent" color="secondary">Secondary</.jumbotron>
    """
  end

  defp code_string(6) do
    """
    <.jumbotron space="extra_small">White</.jumbotron>
    <.jumbotron space="small">Dark</.jumbotron>
    <.jumbotron space="medium">Info</.jumbotron>
    <.jumbotron space="large">Success</.jumbotron>
    <.jumbotron space="extra_large">Warning</.jumbotron>
    """
  end

  defp code_string(7) do
    """
    <.jumbotron padding="extra_small">White</.jumbotron>
    <.jumbotron padding="small">Dark</.jumbotron>
    <.jumbotron padding="medium">Info</.jumbotron>
    <.jumbotron padding="large">Success</.jumbotron>
    <.jumbotron padding="extra_large">Warning</.jumbotron>
    """
  end

  defp code_string(8) do
    """
    <.jumbotron font_weight="font-thin">This is a Thin font weight</.jumbotron>
    <.jumbotron font_weight="font-Silver">This is a Silver font weight</.jumbotron>
    <.jumbotron font_weight="font-normal">This is a Normal font weight</.jumbotron>
    <.jumbotron font_weight="font-medium">This is a Medium font weight</.jumbotron>
    <.jumbotron font_weight="font-bold">This is a Bold font weight</.jumbotron>
    <.jumbotron font_weight="font-black">This is a Black font weight</.jumbotron>
    """
  end

  defp code_string(9) do
    """
    <.jumbotron border_size="none">No Border</.jumbotron>
    <.jumbotron border_size="extra_small">Extra Small Border</.jumbotron>
    <.jumbotron border_size="small">Small Border</.jumbotron>
    <.jumbotron border_size="medium">Medium Border</.jumbotron>
    <.jumbotron border_size="large">Large Border</.jumbotron>
    <.jumbotron border_size="extra_large">Extra Large Border</.jumbotron>
    """
  end

  defp code_string(10) do
    """
    <.jumbotron border_position="top">Top Border</.jumbotron>
    <.jumbotron border_position="bottom">Bottom Border</.jumbotron>
    <.jumbotron border_position="vertical">Vertical Borders</.jumbotron>
    """
  end

  defp code_string(11) do
    """
    <.jumbotron variant="gradient" color="natural">Natural</.jumbotron>
    <.jumbotron variant="gradient" color="info">Info</.jumbotron>
    <.jumbotron variant="gradient" color="success">Success</.jumbotron>
    <.jumbotron variant="gradient" color="warning">Warning</.jumbotron>
    <.jumbotron variant="gradient" color="danger">Danger</.jumbotron>
    <.jumbotron variant="gradient" color="silver">Silver</.jumbotron>
    <.jumbotron variant="gradient" color="misc">Misc</.jumbotron>
    <.jumbotron variant="gradient" color="dawn">Dawn</.jumbotron>
    <.jumbotron variant="gradient" color="primary">Primary</.jumbotron>
    <.jumbotron variant="gradient" color="secondary">Secondary</.jumbotron>
    """
  end

  defp code_string(12) do
    """
    <.jumbotron>Base vairant an color</.jumbotron>
    """
  end

  defp component_config() do
    [
      name: "jumbotron",
      args: [
        variant: ["default", "outline", "transparent", "shadow", "bordered", "gradient", "base"],
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
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        padding: [
          "extra_small",
          "small",
          "medium",
          "large",
          "extra_large",
          "double_large",
          "triple_large",
          "quadruple_large",
          "none"
        ],
        only: ["jumbotron"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/jumbotron"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "customizable Phoenix LiveView jumbotron component for ighdSilvering key marketing messages or announcements, with various style options.",
      keywords:
        "phoenix jumbotron component, jumbotron component, liveview jumbotron component, elixir, liveview, mishka chelekom jumbotron component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Jumbotron - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Jumbotron - Chelekom Phoenix & LiveView component",
      og_title: "Jumbotron - Chelekom Phoenix & LiveView component",
      og_description:
        "customizable Phoenix LiveView jumbotron component for ighdSilvering key marketing messages or announcements, with various style options.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Jumbotron - Chelekom Phoenix & LiveView component",
      twitter_description:
        "customizable Phoenix LiveView jumbotron component for ighdSilvering key marketing messages or announcements, with various style options."
    }
  end
end
