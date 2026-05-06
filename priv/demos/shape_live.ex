defmodule MishkaWeb.ChelekomLive.Docs.ShapeLive do
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
    CustomInlineCode
  }

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  @shapes ~w(squircle circle square heart star star_alt diamond pentagon hexagon hexagon_alt decagon triangle triangle_down triangle_left triangle_right)

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "Shape - Chelekom Phoenix & LiveView component")
     |> assign(seo_tags: seo_tags())
     |> assign(shapes: @shapes)
     |> assign(code_basic: code(:basic))
     |> assign(code_image: code(:image))
     |> assign(code_sizes: code(:sizes))
     |> assign(code_half: code(:half))
     |> assign(code_content: code(:content))
     |> assign(code_all_shapes: code(:all_shapes))}
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  defp code(:basic) do
    """
    <.shape variant="squircle" src="/avatar.jpg" alt="User avatar" />
    """
  end

  defp code(:image) do
    """
    <.shape variant="hexagon" size="large" src="/avatar.jpg" alt="User" />
    <.shape variant="heart" size="medium" src="/cover.jpg" alt="Cover" />
    """
  end

  defp code(:sizes) do
    """
    <.shape variant="circle" size="extra_small" src="..." />
    <.shape variant="circle" size="small" src="..." />
    <.shape variant="circle" size="medium" src="..." />
    <.shape variant="circle" size="large" src="..." />
    <.shape variant="circle" size="extra_large" src="..." />
    """
  end

  defp code(:half) do
    """
    <.shape variant="hexagon" half="first" src="..." />
    <.shape variant="hexagon" half="second" src="..." />
    """
  end

  defp code(:content) do
    """
    <.shape variant="hexagon" size="large">
      <div class="bg-gradient-to-br from-primary-light to-primary-dark size-full
                  flex items-center justify-center text-white">
        AB
      </div>
    </.shape>
    """
  end

  defp code(:all_shapes) do
    """
    <.shape :for={shape <- @shapes} variant={shape} size="medium" src="..." />
    """
  end

  defp component_config() do
    [
      name: "shape",
      args: [
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["shape"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/shape"
    page_image_url = MishkaWeb.Endpoint.url() <> "/images/docs/chelekom/shape.png"

    %{
      description:
        "Clip content to geometric shapes (squircle, hexagon, heart, star, diamond, triangle variants) — pure CSS clip-path & masks for Phoenix LiveView.",
      keywords:
        "phoenix shape component, mask component, clip-path, squircle, hexagon, mishka chelekom shape",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Shape - Chelekom",
      twitter_image_alt: "Shape - Chelekom",
      og_title: "Shape - Chelekom Phoenix & LiveView component",
      og_description:
        "Clip content to 15 geometric shapes with size tokens and half-mode for two-column reveals.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Shape - Chelekom",
      twitter_description: "Clip content to 15 geometric shapes for Phoenix LiveView."
    }
  end
end
