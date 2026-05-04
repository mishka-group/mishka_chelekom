defmodule MishkaWeb.ChelekomLive.Docs.ImageLive do
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
      |> assign(page_title: "Image - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.image
      src="http://example.com"
      alt="Mishka Chelekom image"
      srcset="http://example.com 300w,
        http://example.com 600w"
      sizes="(max-width: 600px) 100vw, 50vw"
      loading="lazy"
      ismap
      decoding="async"
      fetchpriority="high"
      referrerpolicy="no-referrer"
      width="300"
      height="200"
    />
    """
  end

  defp code_string(2) do
    """
    <.image src="/path" shadow="extra_small" />
    <.image src="/path" shadow="small" />
    <.image src="/path" shadow="medium" />
    <.image src="/path" shadow="large" />
    <.image src="/path" shadow="extra_large" />
    """
  end

  defp code_string(3) do
    """
    <.image src="/path" rounded="extra_small" />
    <.image src="/path" rounded="small" />
    <.image src="/path" rounded="medium" />
    <.image src="/path" rounded="large" />
    <.image src="/path" rounded="extra_large" />
    """
  end

  defp code_string(4) do
    """
    <.image src="/path" filter="blue" filter_size="extra_small" />
    <.image src="/path" filter="blue" filter_size="small" />
    <.image src="/path" filter="blue" filter_size="medium" />
    <.image src="/path" filter="blue" filter_size="large" />
    <.image src="/path" filter="blue" filter_size="extra_large" />

    <.image src="/path" filter="brightness" filter_size="extra_small" />
    <.image src="/path" filter="brightness" filter_size="small" />
    <.image src="/path" filter="brightness" filter_size="medium" />
    <.image src="/path" filter="brightness" filter_size="large" />
    <.image src="/path" filter="brightness" filter_size="extra_large" />

    <.image src="/path" filter="contrast" filter_size="extra_small" />
    <.image src="/path" filter="contrast" filter_size="small" />
    <.image src="/path" filter="contrast" filter_size="medium" />
    <.image src="/path" filter="contrast" filter_size="large" />
    <.image src="/path" filter="contrast" filter_size="extra_large" />

    <.image src="/path" filter="hue" filter_size="extra_small" />
    <.image src="/path" filter="hue" filter_size="small" />
    <.image src="/path" filter="hue" filter_size="medium" />
    <.image src="/path" filter="hue" filter_size="large" />
    <.image src="/path" filter="hue" filter_size="extra_large" />

    <.image src="/path" filter="saturation" filter_size="extra_small" />
    <.image src="/path" filter="saturation" filter_size="small" />
    <.image src="/path" filter="saturation" filter_size="medium" />
    <.image src="/path" filter="saturation" filter_size="large" />
    <.image src="/path" filter="saturation" filter_size="extra_large" />

    <.image src="/path" filter="grayscale" />

    <.image src="/path" filter="invert" />

    <.image src="/path" filter="sepia" />
    """
  end

  defp component_config() do
    [
      name: "image",
      args: [
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full"],
        only: ["image"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/image"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Image component for Phoenix and Phoenix LiveView, designed with enhanced visual presentation and responsiveness.",
      keywords:
        "phoenix image component, image component, liveview image component, elixir, liveview, mishka chelekom image component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Image - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Image - Chelekom Phoenix & LiveView component",
      og_title: "Image - Chelekom Phoenix & LiveView component",
      og_description:
        "Image component for Phoenix and Phoenix LiveView, designed with enhanced visual presentation and responsiveness.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Image - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Image component for Phoenix and Phoenix LiveView, designed with enhanced visual presentation and responsiveness."
    }
  end
end
