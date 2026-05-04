defmodule MishkaWeb.ChelekomLive.Docs.TabsLive do
  use MishkaWeb, :live_view
  alias Phoenix.LiveView.JS

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
      |> assign(page_title: "Tabs - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("something", %{"name" => "mishka.tools"}, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <!--Each tab needs a unique ID-->
    <.tabs variant="default" color="white"></.tabs>
    <.tabs variant="default" color="primary"></.tabs>
    <.tabs variant="default" color="secondary"></.tabs>
    <.tabs variant="default" color="dark"></.tabs>
    <.tabs variant="default" color="success"></.tabs>
    <.tabs variant="default" color="warning"></.tabs>
    <.tabs variant="default" color="danger"></.tabs>
    <.tabs variant="default" color="info"></.tabs>
    <.tabs variant="default" color="light"></.tabs>
    <.tabs variant="default" color="misc"></.tabs>
    <.tabs variant="default" color="dawn"></.tabs>
    """
  end

  defp code_string(2) do
    """
    <!--Each tab needs a unique ID-->

    <.tabs variant="pills" color="white"></.tabs>
    <.tabs variant="pills" color="primary"></.tabs>
    <.tabs variant="pills" color="secondary"></.tabs>
    <.tabs variant="pills" color="dark"></.tabs>
    <.tabs variant="pills" color="success"></.tabs>
    <.tabs variant="pills" color="warning"></.tabs>
    <.tabs variant="pills" color="danger"></.tabs>
    <.tabs variant="pills" color="info"></.tabs>
    <.tabs variant="pills" color="light"></.tabs>
    <.tabs variant="pills" color="misc"></.tabs>
    <.tabs variant="pills" color="dawn"></.tabs>
    """
  end

  defp code_string(3) do
    """
    <!--Each tab needs a unique ID-->

    <.tabs size="extra_small"></.tabs>
    <.tabs size="small"></.tabs>
    <.tabs size="medium"></.tabs>
    <.tabs size="large"></.tabs>
    <.tabs size="extra_large"></.tabs>
    """
  end

  defp code_string(4) do
    """
    <!--Each tab needs a unique ID-->

    <.tabs border="extra_small"></.tabs>
    <.tabs border="small"></.tabs>
    <.tabs border="medium"></.tabs>
    <.tabs border="large"></.tabs>
    <.tabs border="extra_large"></.tabs>
    """
  end

  defp code_string(5) do
    """
    <!--Each tab needs a unique ID-->

    <.tabs rounded="extra_small"></.tabs>
    <.tabs rounded="small"></.tabs>
    <.tabs rounded="medium"></.tabs>
    <.tabs rounded="large"></.tabs>
    <.tabs rounded="extra_large"></.tabs>
    """
  end

  defp code_string(6) do
    """
    <!--Each tab needs a unique ID-->

    <.tabs padding="extra_small"></.tabs>
    <.tabs padding="small"></.tabs>
    <.tabs padding="medium"></.tabs>
    <.tabs padding="large"></.tabs>
    <.tabs padding="extra_large"></.tabs>
    """
  end

  defp code_string(7) do
    """
    <!--Each tab needs a unique ID-->

    <.tabs font_weight="mefont-bolddium"></.tabs>
    <.tabs font_weight="font-black"></.tabs>
    <.tabs font_weight="font-light"></.tabs>
    """
  end

  defp code_string(8) do
    """
    <!--Each tab needs a unique ID-->

    <.tabs gap="extra_small"></.tabs>
    <.tabs gap="small"></.tabs>
    <.tabs gap="medium"></.tabs>
    <.tabs gap="large"></.tabs>
    <.tabs gap="extra_large"></.tabs>

    <.tabs vertical gap="extra_small"></.tabs>
    <.tabs vertical gap="small"></.tabs>
    <.tabs vertical gap="medium"></.tabs>
    <.tabs vertical gap="large"></.tabs>
    <.tabs vertical gap="extra_large"></.tabs>
    """
  end

  defp code_string(9) do
    """
    <!--Each tab needs a unique ID-->

    <.tabs vertical></.tabs>
    <.tabs variant="pills" vertical></.tabs>
    """
  end

  defp code_string(10) do
    """
    <!--Each tab needs a unique ID-->

    <!--Start is default-->
    <.tabs vertical placement="start"></.tabs>
    <.tabs vertical placement="end"></.tabs>
    """
  end

  defp code_string(11) do
    """
    <!--Each tab needs a unique ID-->

    <.tabs>
      <:tab>Profile</:tab>
      <:tab>Tickets</:tab>
      <:tab>Settings</:tab>
    </.tabs>
    """
  end

  defp code_string(12) do
    """
    <!--Each tab needs a unique ID-->

    <!--icon_position default is start-->

    <.tabs>
      <:tab icon="hero-home" icon_class="your_classes"></:tab>
      <:tab icon="hero-home" icon_class="your_classes"></:tab>
      <:tab icon="hero-home" icon_class="your_classes" icon_position="end"></:tab>
      <:tab icon="hero-home" icon_class="your_classes" icon_position="end"></:tab>
    </.tabs>
    """
  end

  defp code_string(13) do
    """
    <!--Each tab needs a unique ID-->

    <.tabs>
      <:tab></:tab>
      <:tab active></:tab>
      <:tab></:tab>
    </.tabs>

    <.tabs>
      <:tab active></:tab>
      <:tab></:tab>
      <:tab></:tab>
    </.tabs>

    <.tabs>
      <:tab active></:tab>
      <:tab></:tab>
      <:tab active></:tab>
    </.tabs>
    """
  end

  defp code_string(14) do
    """
    <!--Each tab needs a unique ID-->

    <!--Each tab slot is related to a panel slot in order-->
    <.tabs>
      <:tab></:tab>
      <:tab></:tab>
      <:tab></:tab>


      <:panel></:panel>
      <:panel></:panel>
      <:panel></:panel>
    </.tabs>
    """
  end

  defp code_string(15) do
    """
    <.tabs>
      <:tab
        badge="hero-home"
        badge_variant="bordered"
        badge_size="size-8">
      </:tab>
      <:tab
        badge="hero-home"
        badge_variant="default"
        badge_size="extra_large">
      </:tab>
      <:tab
        badge="hero-home"
        badge_variant="base"
        badge_position="end">
      </:tab>
      <:tab
        badge="hero-home"
        badge_variant="outline"
        badge_color="info"
        badge_position="end">
      </:tab>
    </.tabs>
    """
  end

  defp component_config() do
    [
      name: "tabs",
      args: [
        variant: ["default", "pills"],
        color: [
          "natural",
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
        padding: ["extra_small", "small", "medium", "large", "none"],
        only: ["tabs"],
        helpers: [show_tab: 3, hide_tab: 3],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/tabs"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Interactive tab component supporting both horizontal and vertical orientations, designed for Phoenix and Phoenix LiveView, enabling seamless content switching for enhanced user navigation.",
      keywords:
        "phoenix tabs component, tabs component, liveview tabs component, elixir, liveview, mishka chelekom tabs component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Tabs - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Tabs - Chelekom Phoenix & LiveView component",
      og_title: "Tabs - Chelekom Phoenix & LiveView component",
      og_description:
        "Interactive tab component supporting both horizontal and vertical orientations, designed for Phoenix and Phoenix LiveView, enabling seamless content switching for enhanced user navigation.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Tabs - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Interactive tab component supporting both horizontal and vertical orientations, designed for Phoenix and Phoenix LiveView, enabling seamless content switching for enhanced user navigation."
    }
  end
end
