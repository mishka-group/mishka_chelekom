defmodule MishkaWeb.ChelekomLive.Docs.TimelineLive do
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
      |> assign(page_title: "Timeline - Chelekom Phoenix & LiveView component")
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
    <.timeline color="base"></.timeline>
    <.timeline color="white"></.timeline>
    <.timeline color="primary"></.timeline>
    <.timeline color="secondary"></.timeline>
    <.timeline color="dark"></.timeline>
    <.timeline color="success"></.timeline>
    <.timeline color="warning"></.timeline>
    <.timeline color="danger"></.timeline>
    <.timeline color="info"></.timeline>
    <.timeline color="natural"></.timeline>
    <.timeline color="misc"></.timeline>
    <.timeline color="dawn"></.timeline>
    <.timeline color="silver"></.timeline>
    """
  end

  defp code_string(2) do
    """
    <.timeline horizontal>
      <.timeline_section horizontal></.timeline_section>
      <.timeline_section horizontal></.timeline_section>
      <.timeline_section horizontal></.timeline_section>
      <.timeline_section horizontal></.timeline_section>
      <.timeline_section horizontal></.timeline_section>
      <.timeline_section horizontal></.timeline_section>
    </.timeline>
    """
  end

  defp code_string(3) do
    """
    <.timeline>
      <.timeline_section></.timeline_section>
      <.timeline_section></.timeline_section>
      <.timeline_section></.timeline_section>
      <.timeline_section></.timeline_section>
      <.timeline_section></.timeline_section>
      <.timeline_section></.timeline_section>
    </.timeline>
    """
  end

  defp code_string(4) do
    """
    <.timeline>
      <.timeline_section line_size="extra_small"></.timeline_section>
      <.timeline_section line_size="small"></.timeline_section>
      <.timeline_section line_size="medium"></.timeline_section>
      <.timeline_section line_size="large"></.timeline_section>
      <.timeline_section line_size="extra_large"></.timeline_section>
    </.timeline>
    """
  end

  defp code_string(5) do
    """
    <.timeline>
      <.timeline_section size="extra_small"></.timeline_section>
      <.timeline_section size="small"></.timeline_section>
      <.timeline_section size="medium"></.timeline_section>
      <.timeline_section size="large"></.timeline_section>
      <.timeline_section size="extra_large"></.timeline_section>
      <.timeline_section size="double_large"></.timeline_section>
      <.timeline_section size="triple_large"></.timeline_section>
      <.timeline_section size="quadruple_large"></.timeline_section>
    </.timeline>
    """
  end

  defp code_string(6) do
    """
    <.timeline>
      <.timeline_section bullet_icon="hero-home"></.timeline_section>
      <.timeline_section bullet_icon="hero-tag"></.timeline_section>
    </.timeline>
    """
  end

  defp code_string(7) do
    """
    <.timeline>
      <.timeline_section title="This is title"></.timeline_section>
      <.timeline_section title="This is title"></.timeline_section>
    </.timeline>
    """
  end

  defp code_string(8) do
    """
    <.timeline>
      <.timeline_section description="This is description"></.timeline_section>
      <.timeline_section description="This is description"></.timeline_section>
    </.timeline>
    """
  end

  defp code_string(9) do
    """
    <.timeline>
      <.timeline_section time="Oct, 24"></.timeline_section>
      <.timeline_section time="Oct, 24"></.timeline_section>
    </.timeline>
    """
  end

  defp code_string(10) do
    """
    <.timeline>
      <.timeline_section image="/path" size="extra_small"></.timeline_section>
      <.timeline_section image="/path" size="small"></.timeline_section>
      <.timeline_section image="/path" size="medium"></.timeline_section>
      <.timeline_section image="/path" size="large"></.timeline_section>
      <.timeline_section image="/path" size="extra_large"></.timeline_section>
      <.timeline_section image="/path" size="double_large"></.timeline_section>
      <.timeline_section image="/path" size="triple_large"></.timeline_section>
      <.timeline_section image="/path" size="quadruple_large"></.timeline_section>
    </.timeline>
    """
  end

  defp code_string(11) do
    """
    <.timeline hide_last_line>
      <.timeline_section></.timeline_section>
      <.timeline_section></.timeline_section>
      <.timeline_section></.timeline_section>
      <.timeline_section></.timeline_section>
      <.timeline_section></.timeline_section>
      <.timeline_section></.timeline_section>
      <.timeline_section></.timeline_section>
      <.timeline_section></.timeline_section>
    </.timeline>
    """
  end

  defp code_string(12) do
    """
    <.timeline>
      <.timeline_section line_style="solid"></.timeline_section>
      <.timeline_section line_style="dashed"></.timeline_section>
      <.timeline_section line_style="dotted"></.timeline_section>
    </.timeline>

    <!--Examples-->
    <.timeline color="success" horizontal>
      <.timeline_section horizontal line_style="dashed" line_size="extra_large" />

      <.timeline_section horizontal line_style="dotted" />
    </.timeline>

    <.timeline color="warning">
      <.timeline_section line_style="dashed" />

      <.timeline_section line_style="dotted" />
    </.timeline>
    """
  end

  defp component_config() do
    [
      name: "timeline",
      args: [
        color: [
          "base",
          "white",
          "primary",
          "secondary",
          "dark",
          "success",
          "warning",
          "danger",
          "info",
          "natural",
          "misc",
          "dawn",
          "silver"
        ],
        size: [
          "extra_small",
          "small",
          "medium",
          "large",
          "extra_large",
          "double_large",
          "triple_large",
          "quadruple_large"
        ],
        type: ["timeline", "timeline_section"],
        only: ["timeline", "timeline_section"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/timeline"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Customizable timeline component for Phoenix LiveView, ideal for displaying chronological events with support for horizontal and vertical timelines.",
      keywords:
        "phoenix timeline component, timeline component, liveview timeline component, elixir, liveview, mishka chelekom timeline component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Timeline - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Timeline - Chelekom Phoenix & LiveView component",
      og_title: "Timeline - Chelekom Phoenix & LiveView component",
      og_description:
        "Customizable timeline component for Phoenix LiveView, ideal for displaying chronological events with support for horizontal and vertical timelines.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Timeline - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Customizable timeline component for Phoenix LiveView, ideal for displaying chronological events with support for horizontal and vertical timelines."
    }
  end
end
