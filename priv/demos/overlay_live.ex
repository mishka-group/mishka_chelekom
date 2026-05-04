defmodule MishkaWeb.ChelekomLive.Docs.OverlayLive do
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
      |> assign(page_title: "Overlay - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))
      |> assign(code_5: code_string(5))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.overlay color="base" />
    <.overlay color="natural" />
    <.overlay color="white" />
    <.overlay color="dark" />
    <.overlay color="primary" />
    <.overlay color="secondary" />
    <.overlay color="success" />
    <.overlay color="warning" />
    <.overlay color="danger" />
    <.overlay color="info" />
    <.overlay color="misc" />
    <.overlay color="dawn" />
    <.overlay color="silver" />
    """
  end

  defp code_string(2) do
    """
    <.overlay opacity="transparent" />
    <.overlay opacity="translucent" />
    <.overlay opacity="semi_transparent" />
    <.overlay opacity="lightly_tinted" />
    <.overlay opacity="tinted" />
    <.overlay opacity="semi_opaque" />
    <.overlay opacity="opaque" />
    <.overlay opacity="heavily_tinted" />
    <.overlay opacity="almost_solid" />
    """
  end

  defp code_string(3) do
    """
    <.overlay blur="extra_small" />
    <.overlay blur="small" />
    <.overlay blur="medium" />
    <.overlay blur="large" />
    <.overlay blur="extra_large" />
    """
  end

  defp code_string(4) do
    """
    <.overlay color="misc" blur="small">
      <div class="flex justify-center items-center gap-4 h-full">
        <.spinner color="silver" size="large" />
        <div class="text-white">Use components and any HTML in overlay</div>
      </div>
    </.overlay>
    """
  end

  defp code_string(5) do
    """
    <.overlay z_index="z-10" />
    <.overlay z_index="z-20" />
    """
  end

  defp component_config() do
    [
      name: "overlay",
      args: [
        color: [
          "base",
          "natural",
          "white",
          "dark",
          "primary",
          "secondary",
          "success",
          "warning",
          "danger",
          "info",
          "misc",
          "dawn",
          "silver"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["overlay"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/overlay"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Customizable overlay component for Phoenix LiveView, offering flexible options for color themes, opacity, blur effects, and even loading states or HTML content within",
      keywords:
        "phoenix overlay component, overlay component, liveview overlay component, elixir, liveview, mishka chelekom overlay component",
      base: MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/overlay",
      canonical: MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/overlay",
      og_image: page_image_url,
      og_image_alt: "Overlay - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Overlay - Chelekom Phoenix & LiveView component",
      og_title: "Overlay - Chelekom Phoenix & LiveView component",
      og_description:
        "Customizable overlay component for Phoenix LiveView, offering flexible options for color themes, opacity, blur effects, and even loading states or HTML content within",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Overlay - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Customizable overlay component for Phoenix LiveView, offering flexible options for color themes, opacity, blur effects, and even loading states or HTML content within"
    }
  end
end
