defmodule MishkaWeb.ChelekomLive.Docs.ColorLive do
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
      |> assign(page_title: "Form color picker - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.color_field color="info" value="#0000000" />
    """
  end

  defp component_config() do
    [
      name: "color_field",
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
          "silver",
          "misc",
          "dawn"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["color_field"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/color-field"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Form color picker component for Phoenix and Phoenix LiveView with floating labels and customizable palette selection.",
      keywords:
        "phoenix Form color picker component, Form color picker component, liveview Form color picker component, elixir, liveview, mishka chelekom color picker component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form color picker - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form color picker - Chelekom Phoenix & LiveView component",
      og_title: "Form color picker - Chelekom Phoenix & LiveView component",
      og_description:
        "Form color picker component for Phoenix and Phoenix LiveView with floating labels and customizable palette selection.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form color picker - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Form color picker component for Phoenix and Phoenix LiveView with floating labels and customizable palette selection."
    }
  end
end
