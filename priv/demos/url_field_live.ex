defmodule MishkaWeb.ChelekomLive.Docs.UrlLive do
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
      |> assign(page_title: "URL input field - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.url_field
      value=""
      space="small"
      label=""
      placeholder=""
    />
    """
  end

  defp component_config() do
    [
      name: "url_field",
      args: [
        variant: ["outline", "default", "shadow", "bordered", "transparent", "base"],
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
          "misc",
          "dawn",
          "silver"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["url_field"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/url-field"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "URL input field component for Phoenix and Phoenix LiveView, designed to accept web addresses with built-in validation for proper URL formatting.",
      keywords:
        "phoenix URL input field component, URL input field component, liveview URL input field component, elixir, liveview, mishka chelekom URL input field component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "URL input field - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "URL input field - Chelekom Phoenix & LiveView component",
      og_title: "URL input field - Chelekom Phoenix & LiveView component",
      og_description:
        "URL input field component for Phoenix and Phoenix LiveView, designed to accept web addresses with built-in validation for proper URL formatting.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "URL input field - Chelekom Phoenix & LiveView component",
      twitter_description:
        "URL input field component for Phoenix and Phoenix LiveView, designed to accept web addresses with built-in validation for proper URL formatting."
    }
  end
end
