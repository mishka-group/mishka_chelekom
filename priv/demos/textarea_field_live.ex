defmodule MishkaWeb.ChelekomLive.Docs.TextareaLive do
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
      |> assign(page_title: "Textarea component - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.textarea_field
      name=""
      value=""
      label="Message"
      placeholder="Your message"
    />
    """
  end

  defp code_string(2) do
    """
    <.textarea_field
      name=""
      value=""
      label="Message"
      placeholder="Your message"
      disable_resize
    />
    """
  end

  defp code_string(3) do
    """
    <.textarea_field
      name=""
      value=""
      label="Message"
      placeholder="Your message"
      rows="40"
    />
    """
  end

  defp component_config() do
    [
      name: "textarea_field",
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
        size: ["extra_small", "small", "medium", "large", "extra_large", "auto"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["textarea_field"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/textarea-field"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Textarea component for Phoenix and Phoenix LiveView with floating labels, offering flexible multi-line text input and customizable resizing options for dynamic content handling.",
      keywords:
        "phoenix form textarea component component, form textarea component component, liveview form textarea component component, elixir, liveview, mishka chelekom form textarea component component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Textarea component - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Textarea component - Chelekom Phoenix & LiveView component",
      og_title: "Textarea component - Chelekom Phoenix & LiveView component",
      og_description:
        "Textarea component for Phoenix and Phoenix LiveView with floating labels, offering flexible multi-line text input and customizable resizing options for dynamic content handling.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Textarea component - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Textarea component for Phoenix and Phoenix LiveView with floating labels, offering flexible multi-line text input and customizable resizing options for dynamic content handling."
    }
  end
end
