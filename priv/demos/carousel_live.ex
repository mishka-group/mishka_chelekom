defmodule MishkaWeb.ChelekomLive.Docs.CarouselLive do
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
      |> assign(page_title: "Carousel - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))
      |> assign(code_5: code_string(5))
      |> assign(code_6: code_string(6))
      |> assign(code_7: code_string(7))
      |> assign(code_8: code_string(8))
      |> assign(code_9: code_string(9))
      |> assign(code_10: code_string(10))
      |> assign(code_11: code_string(11))
      |> assign(code_12: code_string(12))
      |> assign(code_13: code_string(13))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <!--ADD a UNIQUE id TO Carousel-->
    <.carousel id="unique_id">
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
    </.carousel>
    """
  end

  defp code_string(2) do
    """
    <!--ADD a UNIQUE id TO Carousel-->
    <.carousel id="unique_id">
      <:slide image="/path" image_class="Classed of image" />
      <:slide image="/path" image_class="Classed of image" />
      <:slide image="/path" image_class="Classed of image" />
      <:slide image="/path" image_class="Classed of image" />
    </.carousel>
    """
  end

  defp code_string(3) do
    """
    <!--ADD a UNIQUE id TO Carousel-->
    <.carousel id="unique_id">
      <:slide image="/path" patch="/path" />
      <:slide image="/path" patch="/path" />
      <:slide image="/path" patch="/path" />
      <:slide image="/path" patch="/path" />
    </.carousel>
    """
  end

  defp code_string(4) do
    """
    <!--ADD a UNIQUE id TO Carousel-->
    <.carousel id="unique_id">
      <:slide
        image="/path"
        title="This is title prop"
      />
      <:slide
        image="/path"
        title="This is title prop"
        description="This is description prop"
      />
      <:slide
        image="/path"
        description="This is description prop"
      />
    </.carousel>
    """
  end

  defp code_string(5) do
    """
    <!--ADD a UNIQUE id TO Carousel-->
    <.carousel id="unique_id">
      <:slide
        image="/path"
        title="This is title prop"
        content_position="start"
      />
      <:slide
        image="/path"
        title="This is title prop"
        description="This is description prop"
        content_position="end"
      />
      <:slide
        image="/path"
        description="This is description prop"
        content_position="center"
      />
      <:slide
        image="/path"
        description="This is description prop"
        content_position="between"
      />
      <:slide
        image="/path"
        description="This is description prop"
        content_position="around"
      />
    </.carousel>
    """
  end

  defp code_string(6) do
    """
    <!--ADD a UNIQUE id TO Carousel-->
    <.carousel id="unique_id">
      <:slide image="/path" />
      <:slide image="/path" active />
      <:slide image="/path" />
      <:slide image="/path" />
    </.carousel>

    <.carousel id="unique_id">
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" active />
      <:slide image="/path" />
    </.carousel>
    """
  end

  defp code_string(7) do
    """
    <.carousel id="unique_id" overlay="primary">
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
    </.carousel>

    <.carousel id="unique_id" overlay="secondary">
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
    </.carousel>

    <.carousel id="unique_id" overlay="success">
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
    </.carousel>

    <.carousel id="unique_id" overlay="warning">
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
    </.carousel>

    <.carousel id="unique_id" overlay="danger">
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
    </.carousel>

    <.carousel id="unique_id" overlay="info">
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
    </.carousel>

    <.carousel id="unique_id" overlay="misc">
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
    </.carousel>

    <.carousel id="unique_id" overlay="dawn">
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
    </.carousel>

    <.carousel id="unique_id" overlay="light">
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
    </.carousel>

    <.carousel id="unique_id" overlay="dark">
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
      <:slide image="/path" />
    </.carousel>
    """
  end

  defp code_string(8) do
    """
    <.carousel id="unique_id" size="extra_small">
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
    </.carousel>

    <.carousel id="unique_id" size="small">
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
    </.carousel>

    <.carousel id="unique_id" size="medium">
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
    </.carousel>

    <.carousel id="unique_id" size="large">
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
    </.carousel>

    <.carousel id="unique_id" size="extra_large">
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
    </.carousel>
    """
  end

  defp code_string(9) do
    """
    <.carousel id="unique_id" padding="extra_small">
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
    </.carousel>

    <.carousel id="unique_id" padding="small">
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
    </.carousel>

    <.carousel id="unique_id" padding="medium">
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
    </.carousel>

    <.carousel id="unique_id" padding="large">
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
    </.carousel>

    <.carousel id="unique_id" padding="extra_large">
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
    </.carousel>
    """
  end

  defp code_string(10) do
    """
    <.carousel id="unique_id" text_position="start">
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
    </.carousel>

    <.carousel id="unique_id" text_position="end">
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
    </.carousel>

    <.carousel id="unique_id" text_position="center">
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
    </.carousel>

    """
  end

  defp code_string(11) do
    """
    <.carousel id="unique_id" indicator>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path" active />
    </.carousel>
    """
  end

  defp code_string(12) do
    """
    <.carousel autoplay>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path" active />
    </.carousel>
    """
  end

  defp code_string(13) do
    """
    <.carousel autoplay autoplay_interval={3000}>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path"/>
      <:slide image="/path" active />
    </.carousel>
    """
  end

  defp component_config() do
    [
      name: "carousel",
      args: [
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
          "silver",
          "misc",
          "dawn"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        padding: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["carousel"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: ["image"]
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/carousel"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Interactive carousel component for Phoenix and LiveView, offering dynamic image or content navigation with customizable controls.",
      keywords:
        "phoenix carousel component, carousel component, liveview carousel component, elixir, liveview, mishka chelekom carousel component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Carousel - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Carousel - Chelekom Phoenix & LiveView component",
      og_title: "Carousel - Chelekom Phoenix & LiveView component",
      og_description:
        "Interactive carousel component for Phoenix and LiveView, offering dynamic image or content navigation with customizable controls.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Carousel - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Interactive carousel component for Phoenix and LiveView, offering dynamic image or content navigation with customizable controls."
    }
  end
end
