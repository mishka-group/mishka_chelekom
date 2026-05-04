defmodule MishkaWeb.ChelekomLive.Docs.SecurityLive do
  use MishkaWeb, :live_view

  import MishkaWeb.Components.{
    CustomNav,
    CustomTableContent,
    CustomTypography,
    CustomInlineCode,
    CustomMobileNavButton
  }

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Security Guide of Mishka Chelekom Phoenix Component")
      |> assign(seo_tags: seo_tags())

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/security"

    page_image_url =
      MishkaWeb.Endpoint.url() <> "/images/docs/chelekom/security.png"

    %{
      description:
        "What is Security in Phoenix Components? and Comprehensive Guide to Phoenix and LiveView Component Security",
      keywords:
        "LiveView Component Security, Phoenix Component Security, Mishka Chelekom Security",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Security Guide of Mishka Chelekom Phoenix Component",
      twitter_image_alt: "Security Guide of Mishka Chelekom Phoenix Component",
      og_title: "Security Guide of Mishka Chelekom Phoenix Component",
      og_description:
        "What is Security in Phoenix Components? and Comprehensive Guide to Phoenix and LiveView Component Security",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Security Guide of Mishka Chelekom Phoenix Component",
      twitter_description:
        "What is Security in Phoenix Components? and Comprehensive Guide to Phoenix and LiveView Component Security"
    }
  end
end
