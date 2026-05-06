defmodule MishkaWeb.ChelekomLive.Docs.ScrollAreaLive do
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

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Scroll Area - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags(), star: 3)
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))
      |> assign(code_5: code_string(5))
      |> assign(code_6: code_string(6))
      |> assign(code_7: code_string(7))
      |> assign(code_8: code_string(8))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.scroll_area id="unique_id">
      // Content
    </.scroll_area>
    """
  end

  defp code_string(2) do
    """
    <.scroll_area id="unique_id" horizontal vertical={false}>
      // Content
    </.scroll_area>
    """
  end

  defp code_string(3) do
    """
    <.scroll_area id="unique_id" type="auto">
      // Content
    </.scroll_area>

    <.scroll_area id="unique_id" type="hover">
      // Content
    </.scroll_area>

    <.scroll_area id="unique_id" type="never">
      // Content
    </.scroll_area>
    """
  end

  defp code_string(4) do
    """
    <.scroll_area width="w-full md:w-2/3">
      // Content
    </.scroll_area>
    """
  end

  defp code_string(5) do
    """
    <.scroll_area height="h-fit md:h-80">
      // Content
    </.scroll_area>
    """
  end

  defp code_string(6) do
    """
    <.scroll_area content_class="py-7 px-1">
      // Content
    </.scroll_area>
    """
  end

  defp code_string(7) do
    """
    <.scroll_area padding="extra_small"></.scroll_area>
    <.scroll_area padding="small"></.scroll_area>
    <.scroll_area padding="medium"></.scroll_area>
    <.scroll_area padding="large"></.scroll_area>
    <.scroll_area padding="extra_large"></.scroll_area>
    """
  end

  defp code_string(8) do
    """
    <.scroll_area id="unique_id" vertical={false}>
      // Content
    </.scroll_area>
    """
  end

  defp component_config() do
    [
      name: "scroll_area",
      args: [
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        only: ["scroll_area"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: [],
      scripts: [
        %{
          type: "file",
          file: "scrollArea.js",
          module: "ScrollArea",
          imports: "import ScrollArea from \"./scrollArea.js\";"
        }
      ]
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/scroll-area"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Phoenix LiveView scrollable areas with customizable size, for better content organization in Phoenix LiveView applications.",
      keywords:
        "phoenix scroll area component, scroll area component, liveview scroll area component, elixir, liveview, mishka chelekom scroll area component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Scroll Area - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Scroll Area - Chelekom Phoenix & LiveView component",
      og_title: "Scroll Area - Chelekom Phoenix & LiveView component",
      og_description:
        "Phoenix LiveView scrollable areas with customizable size, for better content organization in Phoenix LiveView applications.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Scroll Area - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Phoenix LiveView scrollable areas with customizable size, for better content organization in Phoenix LiveView applications"
    }
  end
end
