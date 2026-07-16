defmodule MishkaWeb.ChelekomLive.Docs.TelLive do
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
      |> assign(page_title: "Telephone input field - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.tel_field
      name=""
      value=""
      label="Tel"
      placeholder="Enter a telephone number"
    />
    """
  end

  defp component_config() do
    [
      name: "tel_field",
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
        only: ["tel_field"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/tel-field"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Telephone input field component for Phoenix and Phoenix LiveView with floating labels and validation for standardized phone number formats.",
      keywords:
        "phoenix Telephone input field component, Telephone input field component, liveview Telephone input field component, elixir, liveview, mishka chelekom Telephone input field component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Telephone input field - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Telephone input field - Chelekom Phoenix & LiveView component",
      og_title: "Telephone input field - Chelekom Phoenix & LiveView component",
      og_description:
        "Telephone input field component for Phoenix and Phoenix LiveView with floating labels and validation for standardized phone number formats.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Telephone input field - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Telephone input field component for Phoenix and Phoenix LiveView with floating labels and validation for standardized phone number formats."
    }
  end
end
