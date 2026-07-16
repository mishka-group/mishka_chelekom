defmodule MishkaWeb.ChelekomLive.Docs.NumberLive do
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
      |> assign(page_title: "Form Number input - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.number_field />
    """
  end

  defp code_string(2) do
    """
    <.number_field controls="hide" />
    <.number_field controls="fixed" />
    """
  end

  defp component_config() do
    [
      name: "number_field",
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
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["number_field"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/number-field"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Number input component for Phoenix and Phoenix LiveView with flexible formatting and validation options.",
      keywords:
        "phoenix number input component, number input component, liveview number input component, elixir, liveview, mishka chelekom number input component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form Number input - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form Number input - Chelekom Phoenix & LiveView component",
      og_title: "Form Number input - Chelekom Phoenix & LiveView component",
      og_description:
        "Number input component for Phoenix and Phoenix LiveView with flexible formatting and validation options.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form Number input - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Number input component for Phoenix and Phoenix LiveView with flexible formatting and validation options."
    }
  end
end
