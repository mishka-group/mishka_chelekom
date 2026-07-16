defmodule MishkaWeb.ChelekomLive.Docs.TextFieldLive do
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
      |> assign(page_title: "Form text input - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.text_field
      id="form-example-142"
      name="form-example-142"
      value=""
      space="small"
      description="Mishka chelekom text field"
      label="Text field"
      placeholder="Text field"
      variant="default"
    />
    """
  end

  defp component_config() do
    [
      name: "text_field",
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
        only: ["text_field"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/text-field"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Text input component for Phoenix and Phoenix LiveView with floating labels, supporting plain text entry and versatile form integration.",
      keywords:
        "phoenix text input component, text input component, liveview text input component, elixir, liveview, mishka chelekom text input component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form text input - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form text input - Chelekom Phoenix & LiveView component",
      og_title: "Form text input - Chelekom Phoenix & LiveView component",
      og_description:
        "Text input component for Phoenix and Phoenix LiveView with floating labels, supporting plain text entry and versatile form integration.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form text input - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Text input component for Phoenix and Phoenix LiveView with floating labels, supporting plain text entry and versatile form integration."
    }
  end
end
