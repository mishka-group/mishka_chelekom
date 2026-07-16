defmodule MishkaWeb.ChelekomLive.Docs.EmailLive do
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
    CustomBlock
  }

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Form email input - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
     <.email_field />
    """
  end

  defp component_config() do
    [
      name: "email_field",
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
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full"],
        only: ["email_field"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/email-field"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Form email input component for Phoenix and Phoenix LiveView with floating labels and real-time validation.",
      keywords:
        "phoenix email input component, email input component, liveview email input component, elixir, liveview, mishka chelekom email input component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form email input - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form email input - Chelekom Phoenix & LiveView component",
      og_title: "Form email input - Chelekom Phoenix & LiveView component",
      og_description:
        "Form email input component for Phoenix and Phoenix LiveView with floating labels and real-time validation.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form email input - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Form email input component for Phoenix and Phoenix LiveView with floating labels and real-time validation."
    }
  end
end
