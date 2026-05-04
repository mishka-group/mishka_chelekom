defmodule MishkaWeb.ChelekomLive.Docs.KeyboardLive do
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
      |> assign(page_title: "Keyboard - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.keyboard variant="default" color="natural">Ctrl + C</.keyboard>
    <.keyboard variant="default" color="dark">Ctrl + C</.keyboard>
    <.keyboard variant="default" color="white">Ctrl + C</.keyboard>
    <.keyboard variant="default" color="info">Ctrl + C</.keyboard>
    <.keyboard variant="default" color="success">Ctrl + C</.keyboard>
    <.keyboard variant="default" color="warning">Ctrl + C</.keyboard>
    <.keyboard variant="default" color="danger">Ctrl + C</.keyboard>
    <.keyboard variant="default" color="silver">Ctrl + C</.keyboard>
    <.keyboard variant="default" color="misc">Ctrl + C</.keyboard>
    <.keyboard variant="default" color="dawn">Ctrl + C</.keyboard>
    <.keyboard variant="default" color="primary">Ctrl + C</.keyboard>
    <.keyboard variant="default" color="secondary">Ctrl + C</.keyboard>
    """
  end

  defp code_string(2) do
    """
    <.keyboard variant="outline" color="natural">Ctrl + K</.keyboard>
    <.keyboard variant="outline" color="info">Ctrl + K</.keyboard>
    <.keyboard variant="outline" color="success">Ctrl + K</.keyboard>
    <.keyboard variant="outline" color="warning">Ctrl + K</.keyboard>
    <.keyboard variant="outline" color="danger">Ctrl + K</.keyboard>
    <.keyboard variant="outline" color="silver">Ctrl + K</.keyboard>
    <.keyboard variant="outline" color="misc">Ctrl + K</.keyboard>
    <.keyboard variant="outline" color="dawn">Ctrl + K</.keyboard>
    <.keyboard variant="outline" color="primary">Ctrl + K</.keyboard>
    <.keyboard variant="outline" color="secondary">Ctrl + K</.keyboard>
    """
  end

  defp code_string(3) do
    """
    <.keyboard variant="shadow" color="natural">Ctrl + V</.keyboard>
    <.keyboard variant="shadow" color="info">Ctrl + V</.keyboard>
    <.keyboard variant="shadow" color="success">Ctrl + V</.keyboard>
    <.keyboard variant="shadow" color="warning">Ctrl + V</.keyboard>
    <.keyboard variant="shadow" color="danger">Ctrl + V</.keyboard>
    <.keyboard variant="shadow" color="silver">Ctrl + V</.keyboard>
    <.keyboard variant="shadow" color="misc">Ctrl + V</.keyboard>
    <.keyboard variant="shadow" color="dawn">Ctrl + V</.keyboard>
    <.keyboard variant="shadow" color="primary">Ctrl + V</.keyboard>
    <.keyboard variant="shadow" color="secondary">Ctrl + V</.keyboard>
    """
  end

  defp code_string(4) do
    """
    <.keyboard variant="bordered" color="natural">Ctrl + A</.keyboard>
    <.keyboard variant="bordered" color="dark">Ctrl + A</.keyboard>
    <.keyboard variant="bordered" color="white">Ctrl + A</.keyboard>
    <.keyboard variant="bordered" color="info">Ctrl + A</.keyboard>
    <.keyboard variant="bordered" color="success">Ctrl + A</.keyboard>
    <.keyboard variant="bordered" color="warning">Ctrl + A</.keyboard>
    <.keyboard variant="bordered" color="danger">Ctrl + A</.keyboard>
    <.keyboard variant="bordered" color="silver">Ctrl + A</.keyboard>
    <.keyboard variant="bordered" color="misc">Ctrl + A</.keyboard>
    <.keyboard variant="bordered" color="dawn">Ctrl + A</.keyboard>
    <.keyboard variant="bordered" color="primary">Ctrl + A</.keyboard>
    <.keyboard variant="bordered" color="secondary">Ctrl + A</.keyboard>
    """
  end

  defp code_string(5) do
    """
    <.keyboard variant="transparent" color="natural">Ctrl + D</.keyboard>
    <.keyboard variant="transparent" color="info">Ctrl + D</.keyboard>
    <.keyboard variant="transparent" color="success">Ctrl + D</.keyboard>
    <.keyboard variant="transparent" color="warning">Ctrl + D</.keyboard>
    <.keyboard variant="transparent" color="danger">Ctrl + D</.keyboard>
    <.keyboard variant="transparent" color="silver">Ctrl + D</.keyboard>
    <.keyboard variant="transparent" color="misc">Ctrl + D</.keyboard>
    <.keyboard variant="transparent" color="dawn">Ctrl + D</.keyboard>
    <.keyboard variant="transparent" color="primary">Ctrl + D</.keyboard>
    <.keyboard variant="transparent" color="secondary">Ctrl + D</.keyboard>
    """
  end

  defp code_string(6) do
    """
    <.keyboard rounded="extra_small">Ctrl + K</.keyboard>
    <.keyboard rounded="small">Ctrl + K</.keyboard>
    <.keyboard rounded="medium">Ctrl + K</.keyboard>
    <.keyboard rounded="large">Ctrl + K</.keyboard>
    <.keyboard rounded="extra_large">Ctrl + K</.keyboard>
    <.keyboard rounded="full">Ctrl + K</.keyboard>
    <.keyboard rounded="none">Ctrl + K</.keyboard>
    """
  end

  defp code_string(7) do
    """
    <.keyboard size="extra_small" color="danger">Ctrl + C</.keyboard>
    <.keyboard size="small" color="danger">Ctrl + C</.keyboard>
    <.keyboard size="medium" color="danger">Ctrl + C</.keyboard>
    <.keyboard size="large" color="danger">Ctrl + C</.keyboard>
    <.keyboard size="extra_large" color="danger">Ctrl + C</.keyboard>
    """
  end

  defp code_string(8) do
    """
    <.keyboard font_weight="font-bold">Bold</.keyboard>
    <.keyboard font_weight="font-semibold">Semibold</.keyboard>
    <.keyboard font_weight="font-medium">Medium</.keyboard>
    <.keyboard font_weight="font-silver">silver</.keyboard>
    <.keyboard font_weight="font-black">Black</.keyboard>
    """
  end

  defp code_string(9) do
    """
    <.keyboard variant="gradient" color="natural">Ctrl + D</.keyboard>
    <.keyboard variant="gradient" color="info">Ctrl + D</.keyboard>
    <.keyboard variant="gradient" color="success">Ctrl + D</.keyboard>
    <.keyboard variant="gradient" color="warning">Ctrl + D</.keyboard>
    <.keyboard variant="gradient" color="danger">Ctrl + D</.keyboard>
    <.keyboard variant="gradient" color="silver">Ctrl + D</.keyboard>
    <.keyboard variant="gradient" color="misc">Ctrl + D</.keyboard>
    <.keyboard variant="gradient" color="dawn">Ctrl + D</.keyboard>
    <.keyboard variant="gradient" color="primary">Ctrl + D</.keyboard>
    <.keyboard variant="gradient" color="secondary">Ctrl + D</.keyboard>
    """
  end

  defp code_string(10) do
    """
    <.keyboard>Ctrl + D</.keyboard>
    """
  end

  defp component_config() do
    [
      name: "keyboard",
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
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full", "none"],
        only: ["keyboard"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/keyboard"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Flexible keyboard component for Phoenix LiveView, offering customizable key displays, ideal for visually representing shortcuts, key combinations, or inputs",
      keywords:
        "phoenix keyboard component, keyboard component, liveview keyboard component, elixir, liveview, mishka chelekom keyboard component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Keyboard - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Keyboard - Chelekom Phoenix & LiveView component",
      og_title: "Keyboard - Chelekom Phoenix & LiveView component",
      og_description:
        "Flexible keyboard component for Phoenix LiveView, offering customizable key displays, ideal for visually representing shortcuts, key combinations, or inputs",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Keyboard - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Flexible keyboard component for Phoenix LiveView, offering customizable key displays, ideal for visually representing shortcuts, key combinations, or inputs"
    }
  end
end
