defmodule MishkaWeb.ChelekomLive.Docs.BadgeLive do
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
      |> assign(page_title: "Badge - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("dismiss", _params, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.badge variant="default" color="natural">Natural</.badge>

    <.badge variant="default" color="white">White</.badge>

    <.badge variant="default" color="dark">Dark</.badge>

    <.badge variant="default" color="primary">Primary</.badge>

    <.badge variant="default" color="secondary">Secondary</.badge>

    <.badge variant="default" color="success">Success</.badge>

    <.badge variant="default" color="warning">Warning</.badge>

    <.badge variant="default" color="danger">Danger</.badge>

    <.badge variant="default" color="info">Info</.badge>

    <.badge variant="default" color="silver">Silver</.badge>

    <.badge variant="default" color="misc">Misc</.badge>

    <.badge variant="default" color="dawn">Dawn</.badge>
    """
  end

  defp code_string(2) do
    """
    <.badge variant="outline" color="natural>Natural</.badge>

    <.badge variant="outline" color="primary">Primary</.badge>

    <.badge variant="outline" color="secondary">Secondary</.badge>

    <.badge variant="outline" color="success">Success</.badge>

    <.badge variant="outline" color="warning">Warning</.badge>

    <.badge variant="outline" color="danger">Danger</.badge>

    <.badge variant="outline" color="info">Info</.badge>

    <.badge variant="outline" color="silver">Silver</.badge>

    <.badge variant="outline" color="misc">Misc</.badge>

    <.badge variant="outline" color="dawn">Dawn</.badge>
    """
  end

  defp code_string(3) do
    """
    <.badge variant="transparent" color="natural>Natural</.badge>

    <.badge variant="transparent" color="primary">Primary</.badge>

    <.badge variant="transparent" color="secondary">Secondary</.badge>

    <.badge variant="transparent" color="success">Success</.badge>

    <.badge variant="transparent" color="warning">Warning</.badge>

    <.badge variant="transparent" color="danger">Danger</.badge>

    <.badge variant="transparent" color="info">Info</.badge>

    <.badge variant="transparent" color="silver">Silver</.badge>

    <.badge variant="transparent" color="misc">Misc</.badge>

    <.badge variant="transparent" color="dawn">Dawn</.badge>
    """
  end

  defp code_string(4) do
    """
    <.badge variant="outline" border="extra_small">Extra Small</.badge>

    <.badge variant="outline" border="small">Small</.badge>

    <.badge variant="outline" border="medium">Medium</.badge>

    <.badge variant="outline" border="large">Large</.badge>

    <.badge variant="outline" border="extra_large">Extra Large</.badge>
    """
  end

  defp code_string(5) do
    """
    <.badge variant="shadow" color="natural>Natural</.badge>

    <.badge variant="shadow" color="primary">Primary</.badge>

    <.badge variant="shadow" color="secondary">Secondary</.badge>

    <.badge variant="shadow" color="success">Success</.badge>

    <.badge variant="shadow" color="warning">Warning</.badge>

    <.badge variant="shadow" color="danger">Danger</.badge>

    <.badge variant="shadow" color="info">Info</.badge>

    <.badge variant="shadow" color="silver">Silver</.badge>

    <.badge variant="shadow" color="misc">Misc</.badge>

    <.badge variant="shadow" color="dawn">Dawn</.badge>
    """
  end

  defp code_string(6) do
    """
    <!--How to use dismiss prop, each item should have id-->
    <.badge id="badge-dismiss-1" dismiss>Primary</.badge>

    <.badge id="badge-dismiss-2" right_dismiss>Secondary</.badge>

    <.badge id="badge-dismiss-3" left_dismiss>Secondary</.badge>
    """
  end

  defp code_string(7) do
    """
    <.badge rounded="extra_small">Extra Small</.badge>

    <.badge rounded="small">Small</.badge>

    <.badge rounded="medium">Medium</.badge>

    <.badge rounded="large">Large</.badge>

    <.badge rounded="extra_large">Extra Large</.badge>
    """
  end

  defp code_string(8) do
    """
    <.badge size="extra_small">Extra Small</.badge>

    <.badge size="small">Small</.badge>

    <.badge size="medium">Medium</.badge>

    <.badge size="large">Large</.badge>

    <.badge size="extra_large">Extra Large</.badge>
    """
  end

  defp code_string(9) do
    """
    <.badge icon="hero-bookmark" icon_class="size-4" />

    <.badge icon="hero-plus">badge</.badge>

    <.badge icon="hero-bell">badge</.badge>

    <.badge icon="hero-magnifying-glass-circle-solid">badge</.badge>

    <.badge icon="hero-play">badge</.badge>
    """
  end

  defp code_string(10) do
    """
    <.badge left_indicator indicator_size="extra_small">
      Extra Small - Left
    </.badge>

    <.badge right_indicator indicator_size="small">
      Small - Right
    </.badge>

    <.badge top_left_indicator indicator_size="medium">
      Medium - Top Left
    </.badge>

    <.badge top_center_indicator indicator_size="large">
      Large - Top Center
    </.badge>

    <.badge top_right_indicator indicator_size="extra_large">
      Extra Large - Top Right
    </.badge>

    <.badge middle_left_indicator indicator_size="medium">
      Medium - Middle Left
    </.badge>

    <.badge middle_right_indicator indicator_size="medium">
      Medium - Middle Right
    </.badge>

    <.badge bottom_left_indicator indicator_size="medium">
      Medium - Bottom Left
    </.badge>

    <.badge bottom_center_indicator indicator_size="medium">
      Medium - Bottom Center
    </.badge>

    <.badge bottom_right_indicator indicator_size="medium">
      Medium - Bottom Right
    </.badge>
    """
  end

  defp code_string(11) do
    """
    <.badge left_indicator pinging>
      Extra Small - Left (Pinging)
    </.badge>

    <.badge right_indicator pinging>
      Small - Right (Pinging)
    </.badge>

    <.badge top_left_indicator pinging>
      Medium - Top Left (Pinging)
    </.badge>

    <.badge top_center_indicator pinging>
      Large - Top Center (Pinging)
    </.badge>

    <.badge top_right_indicator pinging>
      Extra Large - Top Right (Pinging)
    </.badge>
    """
  end

  defp code_string(12) do
    """
    <.badge circle size="extra_small">Extra Small Badge</.badge>

    <.badge circle size="small">Small Badge</.badge>

    <.badge circle size="medium">Medium Badge</.badge>

    <.badge circle size="large">Large Badge</.badge>

    <.badge circle size="extra_large">Extra Large Badge</.badge>

    <.badge circle rounded="full" size="extra_large">
      Extra Large Badge
    </.badge>
    """
  end

  defp code_string(13) do
    """
    <.badge font_weight="font-bold">Bold</.badge>

    <.badge font_weight="font-semibold">Semibold</.badge>

    <.badge font_weight="font-medium">Medium</.badge>

    <.badge font_weight="font-Silver">Silver</.badge>

    <.badge font_weight="font-black">Black</.badge>
    """
  end

  defp code_string(14) do
    """
    def handle_event("dismiss", params, socket) do
      {:noreply, socket}
    end
    """
  end

  defp code_string(15) do
    """
    <.badge variant="bordered" color="natural>Natural</.badge>

    <.badge variant="bordered" color="white">White</.badge>

    <.badge variant="bordered" color="dark">Dark</.badge>

    <.badge variant="bordered" color="primary">Primary</.badge>

    <.badge variant="bordered" color="secondary">Secondary</.badge>

    <.badge variant="bordered" color="success">Success</.badge>

    <.badge variant="bordered" color="warning">Warning</.badge>

    <.badge variant="bordered" color="danger">Danger</.badge>

    <.badge variant="bordered" color="info">Info</.badge>

    <.badge variant="bordered" color="silver">Silver</.badge>

    <.badge variant="bordered" color="misc">Misc</.badge>

    <.badge variant="bordered" color="dawn">Dawn</.badge>
    """
  end

  defp code_string(16) do
    """
    <.badge variant="gradient" color="natural>Natural</.badge>

    <.badge variant="gradient" color="primary">Primary</.badge>

    <.badge variant="gradient" color="secondary">Secondary</.badge>

    <.badge variant="gradient" color="success">Success</.badge>

    <.badge variant="gradient" color="warning">Warning</.badge>

    <.badge variant="gradient" color="danger">Danger</.badge>

    <.badge variant="gradient" color="info">Info</.badge>

    <.badge variant="gradient" color="silver">Silver</.badge>

    <.badge variant="gradient" color="misc">Misc</.badge>

    <.badge variant="gradient" color="dawn">Dawn</.badge>
    """
  end

  defp code_string(17) do
    """
    <.badge color="dawn" class="relative" size="extra_large">
      <.badge color="dawn" rounded="full" circle size="extra_small" badge_position="top-left">
          +9
      </.badge>
      Notification
    </.badge>


    <.button color="dawn" class="relative" size="extra_large">
      <.badge color="misc" rounded="full" circle badge_position="bottom-left">
          +9
      </.badge>
      Notification
    </.button>

    <div class="relative" size="extra_large">
      <.badge color="primary" rounded="full" circle size="small" badge_position="top-right">
          11
      </.badge>
      Emails
    </div>

    <div class="relative" size="extra_large">
      <.badge color="danger" circle badge_position="bottom-right">
          11
      </.badge>
      Emails
    </div>
    """
  end

  defp code_string(18) do
    """
    <.badge>Base</.badge>
    <.badge size="small" rounded="medium">Base</.badge>
    <.badge size="medium" rounded="extra_large">Base</.badge>
    <.badge size="large">Base</.badge>
    <.badge size="extra_large" rounded="full">Base</.badge>
    """
  end

  defp component_config() do
    [
      name: "badge",
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
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full", "none"],
        only: ["badge"],
        helpers: [hide_badge: 2, show_badge: 2],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/badge"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Interactive Badge for Phoenix LiveView supports icons, and indicators, making it ideal for real-time notifications, status updates in your web app.",
      keywords:
        "phoenix badge component, badge component, liveview badge component, elixir, liveview, mishka chelekom badge component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Badge - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Badge - Chelekom Phoenix & LiveView component",
      og_title: "Badge - Chelekom Phoenix & LiveView component",
      og_description:
        "Interactive Badge for Phoenix LiveView supports icons, and indicators, making it ideal for real-time notifications, status updates in your web app.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Badge - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Interactive Badge for Phoenix LiveView supports icons, and indicators, making it ideal for real-time notifications, status updates in your web app."
    }
  end
end
