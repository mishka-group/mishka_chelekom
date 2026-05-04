defmodule MishkaWeb.ChelekomLive.Docs.CollapseLive do
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
      |> assign(page_title: "Collapse - Chelekom Phoenix & LiveView component")
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
    <!-- Basic collapse example -->
    <.collapse id="basic-collapse">
      <:trigger>
        <button class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
          Toggle Content
        </button>
      </:trigger>

      <div class="p-4 bg-gray-100 mt-2 rounded">
        This content will be hidden/shown when clicking the trigger button.
      </div>
    </.collapse>
    """
  end

  defp code_string(2) do
    """
    <!-- Initially open collapse -->
    <.collapse id="open-collapse" open={true}>
      <:trigger>
        <button class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600">
          Toggle (Initially Open)
        </button>
      </:trigger>

      <div class="p-4 bg-green-100 mt-2 rounded">
        This content is initially visible when the page loads.
      </div>
    </.collapse>
    """
  end

  defp code_string(3) do
    """
    <!-- Custom duration collapse -->
    <.collapse id="slow-collapse" duration={500}>
      <:trigger>
        <button class="px-4 py-2 bg-purple-500 text-white rounded hover:bg-purple-600">
          Slow Animation (500ms)
        </button>
      </:trigger>

      <div class="p-4 bg-purple-100 mt-2 rounded">
        This collapse animation takes 500ms instead of the default 200ms.
      </div>
    </.collapse>
    """
  end

  defp code_string(4) do
    """
    <!-- Lazy loading collapse -->
    <.collapse id="lazy-collapse" lazy={true}>
      <:trigger>
        <button class="px-4 py-2 bg-orange-500 text-white rounded hover:bg-orange-600">
          Lazy Loaded Content
        </button>
      </:trigger>

      <div class="p-4 bg-orange-100 mt-2 rounded">
        This content is lazy loaded - it's only rendered in the DOM when first opened.
        <img src="https://via.placeholder.com/400x200" alt="Lazy loaded image" class="mt-2" />
      </div>
    </.collapse>
    """
  end

  defp code_string(5) do
    """
    <!-- Server events collapse -->
    <.collapse id="server-collapse" server_events={true}>
      <:trigger>
        <button class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600">
          Server Events Enabled
        </button>
      </:trigger>

      <div class="p-4 bg-red-100 mt-2 rounded">
        This collapse sends open/close events to the LiveView server.
        Check your browser's network tab to see the events.
      </div>
    </.collapse>
    """
  end

  defp component_config() do
    [
      name: "collapse",
      args: [
        only: ["collapse"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  def handle_event("collapsible_open", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("collapsible_close", _params, socket) do
    {:noreply, socket}
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/collapse"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Phoenix LiveView collapse component with smooth animations, lazy loading, server events, and customizable triggers for showing/hiding content.",
      keywords:
        "phoenix collapse component, collapse component, liveview collapse component, collapsible content, toggle component, elixir, liveview, mishka chelekom collapse component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "collapse - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "collapse - Chelekom Phoenix & LiveView component",
      og_title: "collapse - Chelekom Phoenix & LiveView component",
      og_description:
        "Phoenix LiveView collapse component with smooth animations, lazy loading, server events, and customizable triggers for showing/hiding content.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "collapse - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Phoenix LiveView collapse component with smooth animations, lazy loading, server events, and customizable triggers for showing/hiding content."
    }
  end
end
