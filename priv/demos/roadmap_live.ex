defmodule MishkaWeb.ChelekomLive.Docs.RoadmapLive do
  use MishkaWeb, :live_view

  import MishkaWeb.Components.{
    CustomNav,
    CustomTableContent,
    CustomTypography,
    CustomMobileNavButton
  }

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Roadmap - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/roadmap"

    page_image_url =
      MishkaWeb.Endpoint.url() <> "/images/docs/chelekom/roadmap.png"

    %{
      description:
        "Roadmap of Mishka Chelekom project. Check out the stages and features of this Phoenix LiveView UI kit and components.",
      keywords:
        "Mishka Chelekom Roadmap, Phoenix LiveView Roadmap, UI Kit, Roadmap, Components Roadmap",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Roadmap - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Roadmap - Chelekom Phoenix & LiveView component",
      og_title: "Roadmap - Chelekom Phoenix & LiveView component",
      og_description:
        "Roadmap of Mishka Chelekom project. Check out the stages and features of this Phoenix LiveView UI kit and components.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Roadmap - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Roadmap of Mishka Chelekom project. Check out the stages and features of this Phoenix LiveView UI kit and components."
    }
  end
end
