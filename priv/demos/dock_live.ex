defmodule MishkaWeb.ChelekomLive.Docs.DockLive do
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

  @toggleable_examples ~w(
    dock-example-fixed-bottom
    dock-example-fixed-top
    dock-example-sticky-bottom
    dock-example-sticky-top
    dock-example-fixed-bottom-center
    dock-example-fixed-top-center
    dock-example-android-glass
  )

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Dock - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(active_dock: "none")
      |> assign(code_base: code_string(:base))
      |> assign(code_default: code_string(:default))
      |> assign(code_shadow: code_string(:shadow))
      |> assign(code_bordered: code_string(:bordered))
      |> assign(code_gradient: code_string(:gradient))
      |> assign(code_size: code_string(:size))
      |> assign(code_rounded: code_string(:rounded))
      |> assign(code_padding: code_string(:padding))
      |> assign(code_space: code_string(:space))
      |> assign(code_border: code_string(:border))
      |> assign(code_max_width: code_string(:max_width))
      |> assign(code_position: code_string(:position))
      |> assign(code_show_labels: code_string(:show_labels))
      |> assign(code_active: code_string(:active))
      |> assign(code_badge: code_string(:badge))
      |> assign(code_item_color: code_string(:item_color))
      |> assign(code_item_links: code_string(:item_links))
      |> assign(code_item_classes: code_string(:item_classes))
      |> assign(code_glass: code_string(:glass))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("toggle_dock", %{"id" => id}, socket) when id in @toggleable_examples do
    new_value = if socket.assigns.active_dock == id, do: "none", else: id
    {:noreply, assign(socket, active_dock: new_value)}
  end

  def handle_event("toggle_dock", _params, socket) do
    {:noreply, assign(socket, active_dock: "none")}
  end

  defp code_string(:base) do
    """
    <.dock id="dock-base">
      <:item icon="hero-home" label="Home" navigate="/" active />
      <:item icon="hero-inbox" label="Inbox" navigate="/inbox" />
      <:item icon="hero-cog-6-tooth" label="Settings" navigate="/settings" />
    </.dock>
    """
  end

  defp code_string(:default) do
    """
    <.dock id="dock-default" variant="default" color="primary">
      <:item icon="hero-home" label="Home" navigate="/" />
      <:item icon="hero-inbox" label="Inbox" navigate="/inbox" active />
      <:item icon="hero-cog-6-tooth" label="Settings" navigate="/settings" />
    </.dock>

    <.dock id="dock-default-natural" variant="default" color="natural" />
    <.dock id="dock-default-success" variant="default" color="success" />
    <.dock id="dock-default-danger" variant="default" color="danger" />
    """
  end

  defp code_string(:shadow) do
    """
    <.dock id="dock-shadow" variant="shadow" color="primary">
      <:item icon="hero-home" label="Home" navigate="/" active />
      <:item icon="hero-inbox" label="Inbox" navigate="/inbox" />
      <:item icon="hero-cog-6-tooth" label="Settings" navigate="/settings" />
    </.dock>
    """
  end

  defp code_string(:bordered) do
    """
    <.dock id="dock-bordered" variant="bordered" color="success">
      <:item icon="hero-home" label="Home" navigate="/" active />
      <:item icon="hero-inbox" label="Inbox" navigate="/inbox" />
      <:item icon="hero-cog-6-tooth" label="Settings" navigate="/settings" />
    </.dock>
    """
  end

  defp code_string(:gradient) do
    """
    <.dock id="dock-gradient" variant="gradient" color="misc">
      <:item icon="hero-home" label="Home" navigate="/" />
      <:item icon="hero-inbox" label="Inbox" navigate="/inbox" active />
      <:item icon="hero-cog-6-tooth" label="Settings" navigate="/settings" />
    </.dock>
    """
  end

  defp code_string(:size) do
    """
    <.dock id="dock-xs" size="extra_small">...items...</.dock>
    <.dock id="dock-sm" size="small">...items...</.dock>
    <.dock id="dock-md" size="medium">...items...</.dock>
    <.dock id="dock-lg" size="large">...items...</.dock>
    <.dock id="dock-xl" size="extra_large">...items...</.dock>
    """
  end

  defp code_string(:rounded) do
    """
    <.dock id="dock-r-none" rounded="none">...</.dock>
    <.dock id="dock-r-small" rounded="small">...</.dock>
    <.dock id="dock-r-medium" rounded="medium">...</.dock>
    <.dock id="dock-r-large" rounded="large">...</.dock>
    <.dock id="dock-r-extra_large" rounded="extra_large">...</.dock>
    <.dock id="dock-r-full" rounded="full">...</.dock>
    """
  end

  defp code_string(:padding) do
    """
    <.dock id="dock-p-xs" padding="extra_small">...</.dock>
    <.dock id="dock-p-sm" padding="small">...</.dock>
    <.dock id="dock-p-md" padding="medium">...</.dock>
    <.dock id="dock-p-lg" padding="large">...</.dock>
    <.dock id="dock-p-xl" padding="extra_large">...</.dock>
    """
  end

  defp code_string(:space) do
    """
    <.dock id="dock-s-xs" space="extra_small">...</.dock>
    <.dock id="dock-s-sm" space="small">...</.dock>
    <.dock id="dock-s-md" space="medium">...</.dock>
    <.dock id="dock-s-lg" space="large">...</.dock>
    <.dock id="dock-s-xl" space="extra_large">...</.dock>
    """
  end

  defp code_string(:border) do
    """
    <.dock id="dock-b-xs" border="extra_small" variant="base">...</.dock>
    <.dock id="dock-b-sm" border="small" variant="base">...</.dock>
    <.dock id="dock-b-md" border="medium" variant="base">...</.dock>
    <.dock id="dock-b-lg" border="large" variant="base">...</.dock>
    <.dock id="dock-b-xl" border="extra_large" variant="base">...</.dock>
    """
  end

  defp code_string(:max_width) do
    """
    <.dock id="dock-mw-md" max_width="medium">...</.dock>
    <.dock id="dock-mw-lg" max_width="large">...</.dock>
    <.dock id="dock-mw-full" max_width="full">...</.dock>
    """
  end

  defp code_string(:position) do
    """
    <.dock id="dock-static" position="static">...</.dock>
    <.dock id="dock-sticky-bottom" position="sticky_bottom">...</.dock>
    <.dock id="dock-sticky-top" position="sticky_top">...</.dock>
    <.dock id="dock-fixed-bottom" position="fixed_bottom">...</.dock>
    <.dock id="dock-fixed-top" position="fixed_top">...</.dock>
    <.dock id="dock-fixed-bottom-center" position="fixed_bottom_center">...</.dock>
    <.dock id="dock-fixed-top-center" position="fixed_top_center">...</.dock>
    """
  end

  defp code_string(:show_labels) do
    """
    <.dock id="dock-no-labels" show_labels={false} rounded="full" size="large">
      <:item icon="hero-home" navigate="/" active />
      <:item icon="hero-magnifying-glass" navigate="/search" />
      <:item icon="hero-user" navigate="/profile" />
    </.dock>
    """
  end

  defp code_string(:active) do
    """
    <.dock id="dock-active-state">
      <:item icon="hero-home" label="Home" navigate="/" />
      <:item icon="hero-inbox" label="Inbox" navigate="/inbox" active />
      <:item icon="hero-cog-6-tooth" label="Settings" navigate="/settings" />
    </.dock>
    """
  end

  defp code_string(:badge) do
    """
    <.dock id="dock-with-badge">
      <:item icon="hero-home" label="Home" navigate="/" />
      <:item icon="hero-inbox" label="Inbox" navigate="/inbox" badge="3" active />
      <:item icon="hero-bell" label="Alerts" navigate="/alerts" badge="9+" />
    </.dock>
    """
  end

  defp code_string(:item_color) do
    """
    <.dock id="dock-item-color" variant="bordered">
      <:item icon="hero-home" label="Home" navigate="/" color="primary" />
      <:item icon="hero-heart" label="Saved" navigate="/saved" color="danger" />
      <:item icon="hero-bolt" label="Quick" navigate="/quick" color="warning" />
    </.dock>
    """
  end

  defp code_string(:item_links) do
    """
    <.dock id="dock-item-links">
      <:item icon="hero-home" label="Navigate" navigate="/" />
      <:item icon="hero-arrow-path" label="Patch" patch="/" />
      <:item icon="hero-link" label="External" href="https://mishka.tools" />
      <:item icon="hero-cursor-arrow-rays" label="Action" />
    </.dock>
    """
  end

  defp code_string(:item_classes) do
    """
    <.dock
      id="dock-classes"
      class="bg-natural-bordered-bg-light dark:bg-natural-bordered-bg-dark"
      item_class="hover:bg-base-hover-light dark:hover:bg-base-hover-dark"
      icon_class="text-primary-light dark:text-primary-dark"
      label_class="font-semibold"
      active_class="text-primary-light dark:text-primary-dark"
    >
      <:item icon="hero-home" label="Home" navigate="/" active />
      <:item icon="hero-inbox" label="Inbox" navigate="/inbox" />
      <:item icon="hero-cog-6-tooth" label="Settings" navigate="/settings" />
    </.dock>
    """
  end

  defp code_string(:glass) do
    """
    <.dock
      id="dock-glass"
      position="fixed_bottom_center"
      variant="base"
      rounded="full"
      padding="small"
      space="medium"
      border="none"
      show_labels={false}
      class={[
        "!bottom-8 px-3",
        "!bg-white/60 dark:!bg-base-bg-dark/60 backdrop-blur-xl backdrop-saturate-150",
        "!border !border-base-border-light/40 dark:!border-base-border-dark/40",
        "!shadow-xl",
        "!text-base-text-light dark:!text-base-text-dark"
      ]}
    >
      <:item icon="hero-home" navigate="/" active />
      <:item icon="hero-newspaper" navigate="/blog" />
      <:item icon="hero-squares-2x2" navigate="/chelekom" />
      <:item icon="hero-bell" navigate="/" badge="3" />
      <:item icon="hero-user" navigate="/" />
    </.dock>
    """
  end

  defp component_config() do
    [
      name: "dock",
      args: [
        variant: ["default", "shadow", "bordered", "gradient", "base"],
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
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full", "none"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        max_width: ["extra_small", "small", "medium", "large", "extra_large", "full"],
        only: ["dock"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: ["icon"]
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/dock"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Dock — a flexible bottom navigation bar for Phoenix LiveView with full Chelekom design-system tokens, multiple variants, sizes, and positions including a centered floating-pill mode.",
      keywords:
        "phoenix dock component, dock component, bottom navigation, mobile navigation, liveview dock component, elixir, liveview, mishka chelekom dock component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Dock - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Dock - Chelekom Phoenix & LiveView component",
      og_title: "Dock - Chelekom Phoenix & LiveView component",
      og_description:
        "A flexible Phoenix LiveView dock / bottom navigation component with full Chelekom design-system tokens, variants, sizes, and positioning.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Dock - Chelekom Phoenix & LiveView component",
      twitter_description:
        "A flexible Phoenix LiveView dock / bottom navigation component with full Chelekom design-system tokens, variants, sizes, and positioning."
    }
  end
end
