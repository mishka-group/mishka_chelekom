defmodule MishkaWeb.ChelekomLive.Docs.FooterLive do
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
      |> assign(page_title: "Footer - Chelekom Phoenix & LiveView component")
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
      |> assign(code_19: code_string(19))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.footer variant="default" color="natural"></.footer>

    <.footer variant="default" color="white"></.footer>

    <.footer variant="default" color="primary"></.footer>

    <.footer variant="default" color="secondary"></.footer>

    <.footer variant="default" color="dark"></.footer>

    <.footer variant="default" color="success"></.footer>

    <.footer variant="default" color="warning"></.footer>

    <.footer variant="default" color="danger"></.footer>

    <.footer variant="default" color="info"></.footer>

    <.footer variant="default" color="light"></.footer>

    <.footer variant="default" color="misc"></.footer>

    <.footer variant="default" color="dawn"></.footer>
    """
  end

  defp code_string(2) do
    """
    <.footer variant="outline" color="natural"></.footer>

    <.footer variant="outline" color="primary"></.footer>

    <.footer variant="outline" color="secondary"></.footer>

    <.footer variant="outline" color="dark"></.footer>

    <.footer variant="outline" color="success"></.footer>

    <.footer variant="outline" color="warning"></.footer>

    <.footer variant="outline" color="danger"></.footer>

    <.footer variant="outline" color="info"></.footer>

    <.footer variant="outline" color="light"></.footer>

    <.footer variant="outline" color="misc"></.footer>

    <.footer variant="outline" color="dawn"></.footer>
    """
  end

  defp code_string(3) do
    """
    <.footer variant="shadow" color="natural"></.footer>

    <.footer variant="shadow" color="primary"></.footer>

    <.footer variant="shadow" color="secondary"></.footer>

    <.footer variant="shadow" color="success"></.footer>

    <.footer variant="shadow" color="warning"></.footer>

    <.footer variant="shadow" color="danger"></.footer>

    <.footer variant="shadow" color="info"></.footer>

    <.footer variant="shadow" color="light"></.footer>

    <.footer variant="shadow" color="misc"></.footer>

    <.footer variant="shadow" color="dawn"></.footer>
    """
  end

  defp code_string(4) do
    """
    <.footer variant="bordered" color="natural"></.footer>

    <.footer variant="bordered" color="white"></.footer>

    <.footer variant="bordered" color="dark"></.footer>

    <.footer variant="bordered" color="primary"></.footer>

    <.footer variant="bordered" color="secondary"></.footer>

    <.footer variant="bordered" color="dark"></.footer>

    <.footer variant="bordered" color="success"></.footer>

    <.footer variant="bordered" color="warning"></.footer>

    <.footer variant="bordered" color="danger"></.footer>

    <.footer variant="bordered" color="info"></.footer>

    <.footer variant="bordered" color="light"></.footer>

    <.footer variant="bordered" color="misc"></.footer>

    <.footer variant="bordered" color="dawn"></.footer>
    """
  end

  defp code_string(5) do
    """
    <.footer variant="transparent" color="natural"></.footer>

    <.footer variant="transparent" color="primary"></.footer>

    <.footer variant="transparent" color="secondary"></.footer>

    <.footer variant="transparent" color="success"></.footer>

    <.footer variant="transparent" color="warning"></.footer>

    <.footer variant="transparent" color="danger"></.footer>

    <.footer variant="transparent" color="info"></.footer>

    <.footer variant="transparent" color="light"></.footer>

    <.footer variant="transparent" color="misc"></.footer>

    <.footer variant="transparent" color="dawn"></.footer>
    """
  end

  defp code_string(18) do
    """
    <.footer variant="gradient" color="natural"></.footer>

    <.footer variant="gradient" color="primary"></.footer>

    <.footer variant="gradient" color="secondary"></.footer>

    <.footer variant="gradient" color="success"></.footer>

    <.footer variant="gradient" color="warning"></.footer>

    <.footer variant="gradient" color="danger"></.footer>

    <.footer variant="gradient" color="info"></.footer>

    <.footer variant="gradient" color="light"></.footer>

    <.footer variant="gradient" color="misc"></.footer>

    <.footer variant="gradient" color="dawn"></.footer>
    """
  end

  defp code_string(6) do
    """
    <.footer rounded="extra_small"></.footer>
    <.footer rounded="small"></.footer>
    <.footer rounded="medium"></.footer>
    <.footer rounded="large"></.footer>
    <.footer rounded="extra_large"></.footer>
    """
  end

  defp code_string(7) do
    """
    <.footer border="extra_small"></.footer>
    <.footer border="small"></.footer>
    <.footer border="medium"></.footer>
    <.footer border="large"></.footer>
    <.footer border="extra_large"></.footer>
    """
  end

  defp code_string(8) do
    """
    <.footer space="extra_small"></.footer>
    <.footer space="small"></.footer>
    <.footer space="medium"></.footer>
    <.footer space="large"></.footer>
    <.footer space="extra_large"></.footer>
    """
  end

  defp code_string(9) do
    """
    <.footer padding="extra_small"></.footer>
    <.footer padding="small"></.footer>
    <.footer padding="medium"></.footer>
    <.footer padding="large"></.footer>
    <.footer padding="extra_large"></.footer>
    """
  end

  defp code_string(10) do
    """
    <.footer max_width="extra_small"></.footer>
    <.footer max_width="small"></.footer>
    <.footer max_width="medium"></.footer>
    <.footer max_width="large"></.footer>
    <.footer max_width="extra_large"></.footer>
    """
  end

  defp code_string(11) do
    """
    <.footer text_position="left"></.footer>
    <.footer text_position="center"></.footer>
    <.footer text_position="right"></.footer>
    """
  end

  defp code_string(12) do
    """
    <.footer font_weight="font-light"></.footer>
    <.footer font_weight="font-bold"></.footer>
    <.footer font_weight="font-medium"></.footer>
    """
  end

  defp code_string(13) do
    """
    <.footer class="your_classes" color="secondary" padding="large" space="medium">
      <.footer_section class="your_clsses" padding="large">
        <.list color="secondary" space="large">
          <:item><.link navigate="/path">link</.link></:item>
          <:item><.link navigate="/path">link</.link></:item>
          <:item><.link navigate="/path">link</.link></:item>
        </.list>

        <p class="text-sm">A description inside footer section</p>
      </.footer_section>

      <.footer_section text_position="center" class="border-t" padding="small">
        Copyright
      </.footer_section>
    </.footer>
    """
  end

  defp code_string(14) do
    """
    <.footer>
      <.footer_section class="your_clsses" space="extra_small"></.footer_section>
      <.footer_section class="your_clsses" space="small"></.footer_section>
      <.footer_section class="your_clsses" space="medium"></.footer_section>
      <.footer_section class="your_clsses" space="large"></.footer_section>
      <.footer_section class="your_clsses" space="extra_large"></.footer_section>
    </.footer>
    """
  end

  defp code_string(15) do
    """
    <.footer>
      <.footer_section class="your_clsses" padding="extra_small"></.footer_section>
      <.footer_section class="your_clsses" padding="small"></.footer_section>
      <.footer_section class="your_clsses" padding="medium"></.footer_section>
      <.footer_section class="your_clsses" padding="large"></.footer_section>
      <.footer_section class="your_clsses" padding="extra_large"></.footer_section>
    </.footer>
    """
  end

  defp code_string(16) do
    """
    <.footer>
      <.footer_section class="your_clsses" text_position="center"></.footer_section>
      <.footer_section class="your_clsses" text_position="right"></.footer_section>
      <.footer_section class="your_clsses" text_position="left"></.footer_section>
    </.footer>
    """
  end

  defp code_string(17) do
    """
    <.footer>
      <.footer_section class="your_clsses" font_weight="font-bold"></.footer_section>
      <.footer_section class="your_clsses" font_weight="font-light"></.footer_section>
      <.footer_section class="your_clsses" font_weight="font-medium"></.footer_section>
    </.footer>
    """
  end

  defp code_string(19) do
    """
    <.footer>All Rights Reserved</.footer>
    """
  end

  defp component_config() do
    [
      name: "footer",
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
        rounded: ["extra_small", "small", "medium", "large", "extra_large"],
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        type: ["footer", "footer_section"],
        only: ["footer", "footer_section"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/footer"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Customizable footer component for Phoenix and Phoenix LiveView, offering flexible layout options, responsive design.",
      keywords:
        "phoenix footer component, footer component, liveview footer component, elixir, liveview, mishka chelekom footer component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Footer - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Footer - Chelekom Phoenix & LiveView component",
      og_title: "Footer - Chelekom Phoenix & LiveView component",
      og_description:
        "Customizable footer component for Phoenix and Phoenix LiveView, offering flexible layout options, responsive design.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Footer - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Customizable footer component for Phoenix and Phoenix LiveView, offering flexible layout options, responsive design."
    }
  end
end
