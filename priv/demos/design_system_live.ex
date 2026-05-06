defmodule MishkaWeb.ChelekomLive.Docs.DesignSystemLive do
  use MishkaWeb, :live_view

  import MishkaWeb.Components.{
    CustomNav,
    CustomTableContent,
    CustomMobileNavButton,
    CustomTypography,
    CustomInlineCode,
    CustomColors
  }

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Design system - Chelekom Phoenix UIKit and components")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    def deps do
      [
        {:mishka_chelekom, "~> 0.0.8", only: :dev}
      ]
    end
    """
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs"

    page_image_url =
      MishkaWeb.Endpoint.url() <> "/images/docs/chelekom/design-system.png"

    %{
      description:
        "Documentation of design system of Chelekom library to create components and UI kit in Phoenix and Phoenix LiveView",
      keywords:
        "Chelekom documentation, Phoenix components documentation, LiveView components documentation",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Design system - Chelekom Phoenix UIKit and components",
      twitter_image_alt: "Design system - Chelekom Phoenix UIKit and components",
      og_title: "Design system - Chelekom Phoenix UIKit and components",
      og_description:
        "Documentation of design system of Chelekom library to create components and UI kit in Phoenix and Phoenix LiveView",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Design system - Chelekom Phoenix UIKit and components",
      twitter_description:
        "Documentation of design system of Chelekom library to create components and UI kit in Phoenix and Phoenix LiveView"
    }
  end
end
