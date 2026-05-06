defmodule MishkaWeb.ChelekomLive.Docs.BannerLive do
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

  @all_banners Enum.map(1..120, &"banner-example-#{&1}")

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Banner - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(banner_pos: "none")
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("dismiss", _, socket) do
    {:noreply, socket}
  end

  def handle_event("banner_position", %{"pos" => pos}, socket) do
    socket =
      socket
      |> assign(banner_pos: if(Enum.member?(@all_banners, pos), do: pos, else: "none"))

    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.banner variant="default" color="natural">Default natural</.banner>
    <.banner variant="default" color="white">Default white</.banner>
    <.banner variant="default" color="dark">Default Dark</.banner>
    <.banner variant="default" color="info">Default Info</.banner>
    <.banner variant="default" color="success">Default Success</.banner>
    <.banner variant="default" color="warning">Default Warning</.banner>
    <.banner variant="default" color="danger">Default Danger</.banner>
    <.banner variant="default" color="silver">Default Silver</.banner>
    <.banner variant="default" color="misc">Default Misc</.banner>
    <.banner variant="default" color="dawn">Default Dawn</.banner>
    <.banner variant="default" color="primary">Default Primary</.banner>
    <.banner variant="default" color="secondary">Default Secondary</.banner>
    """
  end

  defp code_string(2) do
    """
    <.banner variant="outline">Outline natural</.banner>
    <.banner variant="outline" color="info">Outline Info</.banner>
    <.banner variant="outline" color="success">Outline Success</.banner>
    <.banner variant="outline" color="warning">Outline Warning</.banner>
    <.banner variant="outline" color="danger">Outline Danger</.banner>
    <.banner variant="outline" color="silver">Outline Silver</.banner>
    <.banner variant="outline" color="misc">Outline Misc</.banner>
    <.banner variant="outline" color="dawn">Outline Dawn</.banner>
    <.banner variant="outline" color="primary">Outline Primary</.banner>
    <.banner variant="outline" color="secondary">Outline Secondary</.banner>
    """
  end

  defp code_string(3) do
    """
    <.banner variant="shadow">Shadow natural</.banner>
    <.banner variant="shadow" color="info">Shadow Info</.banner>
    <.banner variant="shadow" color="success">Shadow Success</.banner>
    <.banner variant="shadow" color="warning">Shadow Warning</.banner>
    <.banner variant="shadow" color="danger">Shadow Danger</.banner>
    <.banner variant="shadow" color="silver">Shadow Silver</.banner>
    <.banner variant="shadow" color="misc">Shadow Misc</.banner>
    <.banner variant="shadow" color="dawn">Shadow Dawn</.banner>
    <.banner variant="shadow" color="primary">Shadow Primary</.banner>
    <.banner variant="shadow" color="secondary">Shadow Secondary</.banner>
    """
  end

  defp code_string(5) do
    """
    <.banner variant="transparent">Transparent natural</.banner>
    <.banner variant="transparent" color="info">Transparent Info</.banner>
    <.banner variant="transparent" color="success">Transparent Success</.banner>
    <.banner variant="transparent" color="warning">Transparent Warning</.banner>
    <.banner variant="transparent" color="danger">Transparent Danger</.banner>
    <.banner variant="transparent" color="silver">Transparent Silver</.banner>
    <.banner variant="transparent" color="misc">Transparent Misc</.banner>
    <.banner variant="transparent" color="dawn">Transparent Dawn</.banner>
    <.banner variant="transparent" color="primary">Transparent Primary</.banner>
    <.banner variant="transparent" color="secondary">Transparent Secondary</.banner>
    """
  end

  defp code_string(6) do
    """
    <.banner border="extra_small">Border extra small of Banner</.banner>
    <.banner border="small">Border small of Banner</.banner>
    <.banner border="medium">Border medium of Banner</.banner>
    <.banner border="large">Border large of Banner</.banner>
    <.banner border="extra_large">Border extra large of Banner</.banner>
    """
  end

  defp code_string(7) do
    """
    <.banner border_position="top">Border top of Banner</.banner>
    <.banner border_position="bottom">Border bottom of Banner</.banner>
    <.banner border_position="all">Border full of Banner</.banner>
    <.banner border_position="none">No border on Banner</.banner>
    """
  end

  defp code_string(8) do
    """
    <.banner rounded="extra_small" rounded_position="top">extra small</.banner>
    <.banner rounded="extra_small" rounded_position="bottom">extra small</.banner>
    <.banner rounded="extra_small" rounded_position="all">extra small</.banner>

    <.banner rounded="small" rounded_position="top">small</.banner>
    <.banner rounded="small" rounded_position="bottom">small</.banner>
    <.banner rounded="small" rounded_position="all">small</.banner>

    <.banner rounded="medium" rounded_position="top">medium</.banner>
    <.banner rounded="medium" rounded_position="bottom">medium</.banner>
    <.banner rounded="medium" rounded_position="all">medium</.banner>

    <.banner rounded="large" rounded_position="top">large</.banner>
    <.banner rounded="large" rounded_position="bottom">large</.banner>
    <.banner rounded="large" rounded_position="all">large</.banner>

    <.banner rounded="extra_large" rounded_position="top">extra large</.banner>
    <.banner rounded="extra_large" rounded_position="bottom">extra large</.banner>
    <.banner rounded="extra_large" rounded_position="all">extra large</.banner>

    <.banner rounded="none" rounded_position="none">None</.banner>
    """
  end

  defp code_string(9) do
    """
    <.banner space="extra_small">Space extra small</.banner>
    <.banner space="small">Space small</.banner>
    <.banner space="medium">Space medium</.banner>
    <.banner space="large">Space large</.banner>
    <.banner space="extra_large">Space extra large</.banner>
    <.banner space="none">Space none</.banner>
    """
  end

  defp code_string(10) do
    """
    <.banner padding="extra_small">Padding extra small</.banner>
    <.banner padding="small">Padding small</.banner>
    <.banner padding="medium">Padding medium</.banner>
    <.banner padding="large">Padding large</.banner>
    <.banner padding="extra_large">Padding extra large</.banner>
    <.banner padding="none">Padding none</.banner>
    """
  end

  defp code_string(11) do
    """
    <.banner font_weight="font-thin">Font thin</.banner>
    <.banner font_weight="font-light">Font Silver</.banner>
    <.banner font_weight="font-normal">Font normal</.banner>
    <.banner font_weight="font-medium">Font medium</.banner>
    <.banner font_weight="font-semibold">Font semibold</.banner>
    <.banner font_weight="font-bold">Font bold</.banner>
    <.banner font_weight="font-extrabold">Font extrabold</.banner>
    <.banner font_weight="font-black">Font black</.banner>
    """
  end

  defp code_string(12) do
    """
    <.banner vertical_position="top" vertical_size="none">
      Vertical
    </.banner>

    <.banner vertical_position="top" vertical_size="extra_small">
      Vertical
    </.banner>

    <.banner vertical_position="top" vertical_size="small">
      Vertical
    </.banner>

    <.banner vertical_position="top" vertical_size="medium">
      Vertical
    </.banner>

    <.banner vertical_position="top" vertical_size="large">
      Vertical
    </.banner>

    <.banner vertical_position="top" vertical_size="extra_large">
      Vertical
    </.banner>

    <.banner vertical_position="bottom" vertical_size="none">
     Vertical
    </.banner>

    <.banner vertical_position="bottom" vertical_size="extra_small">
     Vertical
    </.banner>

    <.banner vertical_position="bottom" vertical_size="small">
     Vertical
    </.banner>

    <.banner vertical_position="bottom" vertical_size="medium">
     Vertical
    </.banner>

    <.banner vertical_position="bottom" vertical_size="large">
     Vertical
    </.banner>

    <.banner vertical_position="bottom" vertical_size="extra_large">
     Vertical
    </.banner>

    <.banner vertical_size="none">Vertical</.banner>

    <.banner vertical_size="extra_small">Vertical</.banner>

    <.banner vertical_size="small">Vertical</.banner>

    <.banner vertical_size="medium">Vertical</.banner>

    <.banner vertical_size="large">Vertical</.banner>

    <.banner vertical_size="extra_large">Vertical</.banner>
    """
  end

  defp code_string(13) do
    """
    <.banner position="top_left" position_size="none">
      Top Left No Size
    </.banner>

    <.banner position="top_left" position_size="extra_small">
      Top Left Extra Small
    </.banner>

    <.banner position="top_left" position_size="small">
      Top Left Small
    </.banner>

    <.banner position="top_left" position_size="medium">
      Top Left Medium
    </.banner>

    <.banner position="top_left" position_size="large">
      Top Left Large
    </.banner>

    <.banner position="top_left" position_size="extra_large">
      Top Left Extra Large
    </.banner>

    <.banner position="top_right" position_size="none">
      Top Right No Size
    </.banner>

    <.banner position="top_right" position_size="extra_small">
      Top Right Extra Small
    </.banner>

    <.banner position="top_right" position_size="small">
      Top Right Small
    </.banner>

    <.banner position="top_right" position_size="medium">
      Top Right Medium
    </.banner>

    <.banner position="top_right" position_size="large">
      Top Right Large
    </.banner>

    <.banner position="top_right" position_size="extra_large">
      Top Right Extra Large
    </.banner>

    <.banner position="bottom_left" position_size="none">
      Bottom Left No Size
    </.banner>

    <.banner position="bottom_left" position_size="extra_small">
      Bottom Left Extra Small
    </.banner>

    <.banner position="bottom_left" position_size="small">
      Bottom Left Small
    </.banner>

    <.banner position="bottom_left" position_size="medium">
      Bottom Left Medium
    </.banner>

    <.banner position="bottom_left" position_size="large">
      Bottom Left Large
    </.banner>

    <.banner position="bottom_left" position_size="extra_large">
      Bottom Left Extra Large
    </.banner>

    <.banner position="bottom_right" position_size="none">
      Bottom Right No Size
    </.banner>

    <.banner position="bottom_right" position_size="extra_small">
      Bottom Right Extra Small
    </.banner>

    <.banner position="bottom_right" position_size="small">
      Bottom Right Small
    </.banner>

    <.banner position="bottom_right" position_size="medium">
      Bottom Right Medium
    </.banner>

    <.banner position="bottom_right" position_size="large">
      Bottom Right Large
    </.banner>

    <.banner position="bottom_right" position_size="extra_large">
      Bottom Right Extra Large
    </.banner>

    <.banner position="center">Center</.banner>

    <.banner position="full">Full Width</.banner>
    """
  end

  defp code_string(14) do
    """
    <.banner right_dismiss>Right dismiss</.banner>
    <.banner left_dismiss>Left dismiss</.banner>
    """
  end

  defp code_string(15) do
    """
    <.banner variant="bordered">Bordered natural</.banner>
    <.banner variant="bordered" color="dark">Bordered Dark</.banner>
    <.banner variant="bordered" color="white">Bordered White</.banner>
    <.banner variant="bordered" color="info">Bordered Info</.banner>
    <.banner variant="bordered" color="success">Bordered Success</.banner>
    <.banner variant="bordered" color="warning">Bordered Warning</.banner>
    <.banner variant="bordered" color="danger">Bordered Danger</.banner>
    <.banner variant="bordered" color="silver">Bordered Silver</.banner>
    <.banner variant="bordered" color="misc">Bordered Misc</.banner>
    <.banner variant="bordered" color="dawn">Bordered Dawn</.banner>
    <.banner variant="bordered" color="primary">Bordered Primary</.banner>
    <.banner variant="bordered" color="secondary">Bordered Secondary</.banner>
    """
  end

  defp code_string(16) do
    """
    <.banner variant="gradient">Gradient natural</.banner>
    <.banner variant="gradient" color="info">Gradient Info</.banner>
    <.banner variant="gradient" color="success">Gradient Success</.banner>
    <.banner variant="gradient" color="warning">Gradient Warning</.banner>
    <.banner variant="gradient" color="danger">Gradient Danger</.banner>
    <.banner variant="gradient" color="silver">Gradient Silver</.banner>
    <.banner variant="gradient" color="misc">Gradient Misc</.banner>
    <.banner variant="gradient" color="dawn">Gradient Dawn</.banner>
    <.banner variant="gradient" color="primary">Gradient Primary</.banner>
    <.banner variant="gradient" color="secondary">Gradient Secondary</.banner>
    """
  end

  defp code_string(17) do
    """
    <.banner>Base banner color & variant</.banner>
    """
  end

  defp component_config() do
    [
      name: "banner",
      args: [
        variant: ["default", "outline", "transparent", "shadow", "bordered", "gradient", "base"],
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
        space: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        only: ["banner"],
        helpers: [show_banner: 2, hide_banner: 2],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/banner"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Customizable, dismissible banners for Phoenix LiveView with flexible positioning and smooth animation transitions to enhance user interaction.",
      keywords:
        "phoenix banner component, banner component, liveview banner component, elixir, liveview, mishka chelekom banner component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Banner - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Banner - Chelekom Phoenix & LiveView component",
      og_title: "Banner - Chelekom Phoenix & LiveView component",
      og_description: "",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Banner - Chelekom Phoenix & LiveView component",
      twitter_description: ""
    }
  end
end
