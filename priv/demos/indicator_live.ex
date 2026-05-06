defmodule MishkaWeb.ChelekomLive.Docs.IndicatorLive do
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
      |> assign(page_title: "Indicator - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_5: code_string(5))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.indicator color="base" />
    <.indicator color="natural" />
    <.indicator color="white" />
    <.indicator color="primary" />
    <.indicator color="secondary" />
    <.indicator color="dark" />
    <.indicator color="success" />
    <.indicator color="warning" />
    <.indicator color="danger" />
    <.indicator color="info" />
    <.indicator color="silver" />
    <.indicator color="misc" />
    <.indicator color="dawn" />
    """
  end

  defp code_string(2) do
    """
    <.indicator pinging color="white" />
    <.indicator pinging color="primary" />
    <.indicator pinging color="secondary" />
    <.indicator pinging color="dark" />
    <.indicator pinging color="success" />
    <.indicator pinging color="warning" />
    <.indicator pinging color="danger" />
    <.indicator pinging color="info" />
    <.indicator pinging color="silver" />
    <.indicator pinging color="misc" />
    <.indicator pinging color="dawn" />
    """
  end

  defp code_string(3) do
    """
    <.indicator size="extra_small" />
    <.indicator size="small" />
    <.indicator size="medium" />
    <.indicator size="large" />
    <.indicator size="extra_large" />
    """
  end

  defp code_string(5) do
    """
    <.indicator top_left />
    <.indicator top_center />
    <.indicator top_right />
    <.indicator middle_left />
    <.indicator middle_right />
    <.indicator bottom_left />
    <.indicator bottom_center />
    <.indicator bottom_right />
    """
  end

  defp component_config() do
    [
      name: "indicator",
      args: [
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
        only: ["indicator"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/indicator"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Flexible indicator component for Phoenix LiveView that visually highlights status updates, notifications, or key UI elements with customizable size, color, and position options.",
      keywords:
        "phoenix indicator component, indicator component, liveview indicator component, elixir, liveview, mishka chelekom indicator component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Indicator - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Indicator - Chelekom Phoenix & LiveView component",
      og_title: "Indicator - Chelekom Phoenix & LiveView component",
      og_description:
        "Flexible indicator component for Phoenix LiveView that visually highlights status updates, notifications, or key UI elements with customizable size, color, and position options.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Indicator - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Flexible indicator component for Phoenix LiveView that visually highlights status updates, notifications, or key UI elements with customizable size, color, and position options."
    }
  end
end
