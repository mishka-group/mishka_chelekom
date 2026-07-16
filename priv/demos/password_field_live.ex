defmodule MishkaWeb.ChelekomLive.Docs.PasswordLive do
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
      |> assign(page_title: "Form password input - Chelekom Phoenix & LiveView component")
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
    <password_field />
    """
  end

  defp code_string(2) do
    """
    <password_field show_password />
    """
  end

  defp component_config() do
    [
      name: "password_field",
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
        only: ["password_field"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/password-field"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Form password input component for Phoenix and Phoenix LiveView with floating labels and secure input handling.",
      keywords:
        "phoenix form password input component, form password input component, liveview form password input component, elixir, liveview, mishka chelekom form password input component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form password input - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form password input - Chelekom Phoenix & LiveView component",
      og_title: "Form password input - Chelekom Phoenix & LiveView component",
      og_description:
        "Form password input component for Phoenix and Phoenix LiveView with floating labels and secure input handling.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form password input - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Form password input component for Phoenix and Phoenix LiveView with floating labels and secure input handling."
    }
  end
end
