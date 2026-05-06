defmodule MishkaWeb.ChelekomLive.Docs.BlockquoteLive do
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
      |> assign(page_title: "Blockquote - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.blockquote>
      <p>Any content or HTML can go here.</p>
      <:caption image="/path" image_class="classes" position="right">
        Mishka Chelekom
      </:caption>
      <:caption position="left">
        Mishka Chelekom
      </:caption>
      <:caption position="center">
        Mishka Chelekom
      </:caption>
    </.blockquote>
    """
  end

  defp code_string(2) do
    """
    <.blockquote variant="default" color="natural">Default color="natural" Natural</.blockquote>

    <.blockquote variant="default" color="white">Info</.blockquote>

    <.blockquote variant="default" color="indarkfo">Info</.blockquote>

    <.blockquote variant="default" color="info">Info</.blockquote>

    <.blockquote variant="default" color="success">Success</.blockquote>

    <.blockquote variant="default" color="warning">Warning</.blockquote>

    <.blockquote variant="default" color="danger">Danger</.blockquote>

    <.blockquote variant="default" color="silver">Light</.blockquote>

    <.blockquote variant="default" color="misc">Misc</.blockquote>

    <.blockquote variant="default" color="dawn">Dawn</.blockquote>

    <.blockquote variant="default" color="primary">Primary</.blockquote>

    <.blockquote variant="default" color="secondary">Secondary</.blockquote>
    """
  end

  defp code_string(3) do
    """
    <.blockquote variant="outline" color="natural">Natural</.blockquote>

    <.blockquote variant="outline" color="info">Info</.blockquote>

    <.blockquote variant="outline" color="success">Success</.blockquote>

    <.blockquote variant="outline" color="warning">Warning</.blockquote>

    <.blockquote variant="outline" color="danger">Danger</.blockquote>

    <.blockquote variant="outline" color="silver">Light</.blockquote>

    <.blockquote variant="outline" color="misc">Misc</.blockquote>

    <.blockquote variant="outline" color="dawn">Dawn</.blockquote>

    <.blockquote variant="outline" color="primary">Primary</.blockquote>

    <.blockquote variant="outline" color="secondary">Secondary</.blockquote>
    """
  end

  defp code_string(4) do
    """
    <.blockquote variant="shadow" color="natural">Natural</.blockquote>

    <.blockquote variant="shadow" color="info">Info</.blockquote>

    <.blockquote variant="shadow" color="success">Success</.blockquote>

    <.blockquote variant="shadow" color="warning">Warning</.blockquote>

    <.blockquote variant="shadow" color="danger">Danger</.blockquote>

    <.blockquote variant="shadow" color="silver">Light</.blockquote>

    <.blockquote variant="shadow" color="misc">Misc</.blockquote>

    <.blockquote variant="shadow" color="dawn">Dawn</.blockquote>

    <.blockquote variant="shadow" color="primary">Primary</.blockquote>

    <.blockquote variant="shadow" color="secondary">Secondary</.blockquote>
    """
  end

  defp code_string(5) do
    """
    <.blockquote variant="bordered" color="natural">Natural</.blockquote>

    <.blockquote variant="bordered" color="white">White</.blockquote>

    <.blockquote variant="bordered" color="dark">Dark</.blockquote>

    <.blockquote variant="bordered" color="info">Info</.blockquote>

    <.blockquote variant="bordered" color="success">Success</.blockquote>

    <.blockquote variant="bordered" color="warning">Warning</.blockquote>

    <.blockquote variant="bordered" color="danger">Danger</.blockquote>

    <.blockquote variant="bordered" color="silver">Light</.blockquote>

    <.blockquote variant="bordered" color="misc">Misc</.blockquote>

    <.blockquote variant="bordered" color="dawn">Dawn</.blockquote>

    <.blockquote variant="bordered" color="primary">Primary</.blockquote>

    <.blockquote variant="bordered" color="secondary">Secondary</.blockquote>
    """
  end

  defp code_string(6) do
    """
    <.blockquote variant="transparent" color="natural">Natural</.blockquote>

    <.blockquote variant="transparent" color="dark">Dark</.blockquote>

    <.blockquote variant="transparent" color="info">Info</.blockquote>

    <.blockquote variant="transparent" color="success">Success</.blockquote>

    <.blockquote variant="transparent" color="warning">Warning</.blockquote>

    <.blockquote variant="transparent" color="danger">Danger</.blockquote>

    <.blockquote variant="transparent" color="silver">Light</.blockquote>

    <.blockquote variant="transparent" color="misc">Misc</.blockquote>

    <.blockquote variant="transparent" color="dawn">Dawn</.blockquote>

    <.blockquote variant="transparent" color="primary">Primary</.blockquote>

    <.blockquote variant="transparent" color="secondary">Secondary</.blockquote>
    """
  end

  defp code_string(7) do
    """
    <.blockquote rounded="extra_small">extra small</.blockquote>
    <.blockquote rounded="small">small</.blockquote>
    <.blockquote rounded="medium">medium</.blockquote>
    <.blockquote rounded="large">large</.blockquote>
    <.blockquote rounded="extra_large">extra large</.blockquote>
    """
  end

  defp code_string(8) do
    """
    <.blockquote border="extra_small">extra small</.blockquote>
    <.blockquote border="small">small</.blockquote>
    <.blockquote border="medium">medium</.blockquote>
    <.blockquote border="large">large</.blockquote>
    <.blockquote border="extra_large">extra large</.blockquote>
    <.blockquote right_border>Right border</.blockquote>
    <.blockquote left_border>Left border</.blockquote>
    <.blockquote hide_border>Hide border</.blockquote>
    <.blockquote full_border>Full</.blockquote>
    """
  end

  defp code_string(9) do
    """
    <.blockquote size="extra_small">extra small</.blockquote>
    <.blockquote size="small">small</.blockquote>
    <.blockquote size="medium">medium</.blockquote>
    <.blockquote size="large">large</.blockquote>
    <.blockquote size="extra_large">extra large</.blockquote>
    """
  end

  defp code_string(10) do
    """
    <.blockquote space="extra_small">extra small</.blockquote>
    <.blockquote space="small">small</.blockquote>
    <.blockquote space="medium">medium</.blockquote>
    <.blockquote space="large">large</.blockquote>
    <.blockquote space="extra_large">extra large</.blockquote>
    """
  end

  defp code_string(11) do
    """
    <.blockquote padding="extra_small">extra small</.blockquote>
    <.blockquote padding="small">small</.blockquote>
    <.blockquote padding="medium">medium</.blockquote>
    <.blockquote padding="large">large</.blockquote>
    <.blockquote padding="extra_large">extra large</.blockquote>
    """
  end

  defp code_string(12) do
    """
    <.blockquote icon_class="color-blue-400">medium</.blockquote>
    <.blockquote icon="hero-star">extra small</.blockquote>
    <.blockquote hide_icon>small</.blockquote>
    """
  end

  defp code_string(13) do
    """
    <.blockquote variant="gradient" color="natural">Natural</.blockquote>

    <.blockquote variant="gradient" color="info">Info</.blockquote>

    <.blockquote variant="gradient" color="success">Success</.blockquote>

    <.blockquote variant="gradient" color="warning">Warning</.blockquote>

    <.blockquote variant="gradient" color="danger">Danger</.blockquote>

    <.blockquote variant="gradient" color="silver">Light</.blockquote>

    <.blockquote variant="gradient" color="misc">Misc</.blockquote>

    <.blockquote variant="gradient" color="dawn">Dawn</.blockquote>

    <.blockquote variant="gradient" color="primary">Primary</.blockquote>

    <.blockquote variant="gradient" color="secondary">Secondary</.blockquote>
    """
  end

  defp code_string(14) do
    """
    <.blockquote class="border">
      <p>Any content or HTML can go here.</p>
      <:caption image="/path" image_class="classes" position="right">
        Mishka Chelekom
      </:caption>
    </.blockquote>
    """
  end

  defp component_config() do
    [
      name: "blockquote",
      args: [
        variant: ["default", "outline", "transparent", "shadow", "bordered", "gradient", "base"],
        color: [
          "base",
          "natural",
          "white",
          "natudarkral",
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
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full", "none"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        only: ["blockquote"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/blockquote"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Blockquote component for Phoenix and Phoenix LiveView, ideal for highlighting quotes or key content.",
      keywords:
        "phoenix blockquote component, blockquote component, liveview blockquote component, elixir, liveview, mishka chelekom blockquote component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Blockquote - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Blockquote - Chelekom Phoenix & LiveView component",
      og_title: "Blockquote - Chelekom Phoenix & LiveView component",
      og_description:
        "Blockquote component for Phoenix and Phoenix LiveView, ideal for highlighting quotes or key content.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Blockquote - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Blockquote component for Phoenix and Phoenix LiveView, ideal for highlighting quotes or key content."
    }
  end
end
