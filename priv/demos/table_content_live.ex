defmodule MishkaWeb.ChelekomLive.Docs.TableContentLive do
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
      |> assign(page_title: "Table of contents - Chelekom Phoenix & LiveView component")
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

  defp code_string(1) do
    """
    <.table_content color="white" variant="default"></.table_content>
    <.table_content color="primary" variant="bordered"></.table_content>
    <.table_content color="secondary" variant="outline"></.table_content>
    <.table_content color="dark" variant="default"></.table_content>
    <.table_content color="success" variant="bordered"></.table_content>
    <.table_content color="warning" variant="outline"></.table_content>
    <.table_content color="danger" variant="default"></.table_content>
    <.table_content color="info" variant="bordered"></.table_content>
    <.table_content color="silver" variant="outline"></.table_content>
    <.table_content color="misc" variant="default"></.table_content>
    <.table_content color="dawn" variant="bordered"></.table_content>
    <.table_content color="silver" variant="outline"></.table_content>
    <.table_content color="dawn" variant="gradient"></.table_content>
    """
  end

  defp code_string(2) do
    """
    <.table_content rounded="extra_small"></.table_content>
    <.table_content rounded="small"></.table_content>
    <.table_content rounded="medium"></.table_content>
    <.table_content rounded="large"></.table_content>
    <.table_content rounded="extra_large"></.table_content>
    """
  end

  defp code_string(3) do
    """
    <.table_content border="extra_small"></.table_content>
    <.table_content border="small"></.table_content>
    <.table_content border="medium"></.table_content>
    <.table_content border="large"></.table_content>
    <.table_content border="extra_large"></.table_content>
    """
  end

  defp code_string(4) do
    """
    <.table_content size="extra_small"></.table_content>
    <.table_content size="small"></.table_content>
    <.table_content size="medium"></.table_content>
    <.table_content size="large"></.table_content>
    <.table_content size="extra_large"></.table_content>
    """
  end

  defp code_string(5) do
    """
    <.table_content space="extra_small"></.table_content>
    <.table_content space="small"></.table_content>
    <.table_content space="medium"></.table_content>
    <.table_content space="large"></.table_content>
    <.table_content space="extra_large"></.table_content>
    """
  end

  defp code_string(6) do
    """
    <.table_content padding="extra_small"></.table_content>
    <.table_content padding="small"></.table_content>
    <.table_content padding="medium"></.table_content>
    <.table_content padding="large"></.table_content>
    <.table_content padding="extra_large"></.table_content>
    <.table_content padding="double_large"></.table_content>
    <.table_content padding="triple_large"></.table_content>
    <.table_content padding="quadruple_large"></.table_content>
    """
  end

  defp code_string(7) do
    """
    <.table_content title="title of table-content"></.table_content>
    """
  end

  defp code_string(8) do
    """
    <.table_content animated></.table_content>
    """
  end

  defp code_string(9) do
    """
    <.table_content >
      <.content_item link_title="Home" link="/path" />
      <.content_item link_title="Overview" link="/path" />
      <.content_item link_title="Slots" link="/path" />
    </.table_content>
    """
  end

  defp code_string(10) do
    """
     <.table_content>
      <.content_item title="your_title">
        <.link patch="/path"></.link>
      </.content_item>

      <.content_item title="your_title">
        <.link patch="/path"></.link>
      </.content_item>

      <.content_item title="your_title">
        <.link navigate="/path"></.link>
      </.content_item>
    </.table_content>
    """
  end

  defp code_string(11) do
    """
     <.table_content>
      <.content_item icon="hero-home" icon_class="your_class">
        <.link patch="/path"></.link>
      </.content_item>
    </.table_content>
    """
  end

  defp code_string(12) do
    """
    <.table_content>
      <.content_item active>
        <.link patch="/path"></.link>
      </.content_item>

      <.content_item>
        <.link patch="/path"></.link>
      </.content_item>
    </.table_content>
    """
  end

  defp code_string(13) do
    """
    <.table_content>
      <.content_item font_weight="font-thin">
        <.link patch="/path"></.link>
      </.content_item>

      <.content_item font_weight="font-bold">
        <.link patch="/path"></.link>
      </.content_item>
    </.table_content>
    """
  end

  defp code_string(14) do
    """
    <.table_content>
      <.content_item title="Table content props">
        <.content_wrapper>
          <.content_item icon="hero-chevron-right">
            <.link patch="/path">Overview</.link>
          </.content_item>
          <.content_item icon="hero-chevron-right">
            <.link patch="/path">Color and Variants</.link>
          </.content_item>

          <.content_item icon="hero-chevron-right">
            <.link patch="/path">Space</.link>
          </.content_item>

          <.content_item icon="hero-chevron-right">
            <.link patch="/path">Padding</.link>
          </.content_item>

          <.content_item icon="hero-chevron-right">
            <.link patch="/path">Rounded</.link>
          </.content_item>

          <.content_item icon="hero-chevron-right">
            <.link patch="/path">Size</.link>
          </.content_item>
        </.content_wrapper>
      </.content_item>

      <.content_item title="Table content item props">
        <.content_wrapper>
          <.content_item icon="hero-chevron-right">
            <.link patch="/path">Overview</.link>
          </.content_item>

          <.content_item icon="hero-chevron-right">
            <.link patch="/path">Color and Variants</.link>
          </.content_item>

          <.content_item icon="hero-chevron-right">
            <.link patch="/path">Space</.link>
          </.content_item>

          <.content_item icon="hero-chevron-right">
            <.link patch="/path">Padding</.link>
          </.content_item>

          <.content_item icon="hero-chevron-right">
            <.link patch="/path">Rounded</.link>
          </.content_item>

          <.content_item icon="hero-chevron-right">
            <.link patch="/path">Size</.link>
          </.content_item>
        </.content_wrapper>
      </.content_item>
    </.table_content>
    """
  end

  defp code_string(15) do
    """
    <.table_content >
      <:item link_title="Home" link="/path"><:/item>
      <:item link_title="Overview" link="/path"><:/item>
      <:item link_title="Slots" link="/path"><:/item>
    </.table_content>

    <.table_content >
      <:item>
        <.link patch="/path">Home<./link>
      <:/item>
      <:item>
        <.link patch="/path">Overview<./link>
      <:/item>
      <:item>
        <.link patch="/path">Slots<./link>
      <:/item>
    </.table_content>
    """
  end

  defp component_config() do
    [
      name: "table_content",
      args: [
        variant: ["outline", "default", "bordered", "transparent", "gradient", "base"],
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
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        padding: [
          "extra_small",
          "small",
          "medium",
          "large",
          "extra_large",
          "double_large",
          "triple_large",
          "quadruple_large"
        ],
        type: ["table_content", "content_wrapper", "content_item"],
        only: ["table_content", "content_wrapper", "content_item"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/table-content"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Phoenix LiveView table content component with links for smooth scrolling to specific items using anchor tags.",
      keywords:
        "phoenix table of content component, table of content component, liveview table of content component, elixir, liveview, mishka chelekom table of content component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Table of contents - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Table of contents - Chelekom Phoenix & LiveView component",
      og_title: "Table of contents - Chelekom Phoenix & LiveView component",
      og_description:
        "Phoenix LiveView table content component with links for smooth scrolling to specific items using anchor tags.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Table of contents - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Phoenix LiveView table content component with links for smooth scrolling to specific items using anchor tags."
    }
  end
end
