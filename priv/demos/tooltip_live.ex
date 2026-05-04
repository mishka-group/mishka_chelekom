defmodule MishkaWeb.ChelekomLive.Docs.TooltipLive do
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
      |> assign(page_title: "Tooltip - Chelekom Phoenix & LiveView component")
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
      |> assign(code_14: code_string(14))
      |> assign(code_15: code_string(15))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.tooltip text="Tooltip text" variant="default" color="natural">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" variant="default" color="white">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" variant="default" color="primary">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" variant="default" color="secondary">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" variant="default" color="dark">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" variant="default" color="success">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" variant="default" color="warning">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" variant="default" color="danger">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" variant="default" color="info">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" variant="default" color="light">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" variant="default" color="misc">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" variant="default" color="dawn">
      <.button>tooltip</.button>
    </.tooltip>
    """
  end

  defp code_string(2) do
    """
    <.tooltip text="Tooltip text" color="natural" variant="shadow">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="primary" variant="shadow">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="secondary" variant="shadow">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="success" variant="shadow">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="warning" variant="shadow">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="danger" variant="shadow">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="info" variant="shadow">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="light" variant="shadow">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="misc" variant="shadow">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="dawn" variant="shadow">
      <.button>tooltip</.button>
    </.tooltip>
    """
  end

  defp code_string(3) do
    """
    <.tooltip text="Tooltip extra small padding" padding="extra_small">
      <.button>Extra Small</.button>
    </.tooltip>

    <.tooltip text="Tooltip small padding" padding="small">
      <.button>Small</.button>
    </.tooltip>

    <.tooltip text="Tooltip medium padding" padding="medium">
      <.button>Medium</.button>
    </.tooltip>

    <.tooltip text="Tooltip large padding" padding="large">
      <.button>Large</.button>
    </.tooltip>

    <.tooltip text="Tooltip extra large padding" padding="extra_large">
      <.button>Extra Large</.button>
    </.tooltip>

    <.tooltip text="Tooltip No padding" padding="none">
      <.button>None</.button>
    </.tooltip>
    """
  end

  defp code_string(4) do
    """
    <.tooltip text="Tooltip extra small radius" rounded="extra_small">
      <.button>Extra Small</.button>
    </.tooltip>

    <.tooltip text="Tooltip small radius" rounded="small">
      <.button>Small</.button>
    </.tooltip>

    <.tooltip text="Tooltip medium radius" rounded="medium">
      <.button>Medium</.button>
    </.tooltip>

    <.tooltip text="Tooltip large radius" rounded="large">
      <.button>Large</.button>
    </.tooltip>

    <.tooltip text="Tooltip extra large radius" rounded="extra_large">
      <.button>Extra Large</.button>
    </.tooltip>

    <.tooltip text="Tooltip No radius" rounded="None">
      <.button>None</.button>
    </.tooltip>
    """
  end

  defp code_string(5) do
    """
    <.tooltip text="Tooltip extra small size" size="extra_small">
      <.button>Extra Small Size</.button>
    </.tooltip>

    <.tooltip text="Tooltip small size" size="small">
      <.button>Small Size</.button>
    </.tooltip>

    <.tooltip text="Tooltip medium size" size="medium">
      <.button>Medium Size</.button>
    </.tooltip>

    <.tooltip text="Tooltip large size" size="large">
      <.button>Large Size</.button>
    </.tooltip>

    <.tooltip text="Tooltip extra large size" size="extra_large">
      <.button>Extra Large Size</.button>
    </.tooltip>
    """
  end

  defp code_string(6) do
    """
    <.tooltip text="Tooltip extra small width" width="extra_small">
      <.button>Extra Small Width</.button>
    </.tooltip>

    <.tooltip text="Tooltip small width" width="small">
      <.button>Small Width</.button>
    </.tooltip>

    <.tooltip text="Tooltip medium width" width="medium">
      <.button>Medium Width</.button>
    </.tooltip>

    <.tooltip text="Tooltip large width" width="large">
      <.button>Large Width</.button>
    </.tooltip>

    <.tooltip text="Tooltip extra large width" width="extra_large">
      <.button>Extra Large Width</.button>
    </.tooltip>

    <.tooltip text="Tooltip fit width" width="fit">
      <.button>Fit Width</.button>
    </.tooltip>
    """
  end

  defp code_string(7) do
    """
    <.tooltip text="This is a tooltip text prop example">
      <.button>Hover me</.button>
    </.tooltip>

    <.tooltip text="Another small text for tooltip">
      <.button>Small text</.button>
    </.tooltip>

    <.tooltip text="Hover to see this tooltip">
      <.button>Hover here</.button>
    </.tooltip>

    <.tooltip text="The text prop defines the tooltip's content">
      <.button>See text prop</.button>
    </.tooltip>
    """
  end

  defp code_string(8) do
    """
    <.tooltip text="Tooltip positioned at the top" position="top">
      <.button>Top Position</.button>
    </.tooltip>

    <.tooltip text="Tooltip positioned at the bottom" position="bottom">
      <.button>Bottom Position</.button>
    </.tooltip>

    <.tooltip text="Tooltip positioned at the left" position="left">
      <.button>Left Position</.button>
    </.tooltip>

    <.tooltip text="Tooltip positioned at the right" position="right">
      <.button>Right Position</.button>
    </.tooltip>
    """
  end

  defp code_string(9) do
    """
    <.tooltip text="Text positioned to the left" text_position="left">
      <.button>Left Text Position</.button>
    </.tooltip>

    <.tooltip text="Text positioned to the right" text_position="right">
      <.button>Right Text Position</.button>
    </.tooltip>

    <.tooltip text="Text positioned in the center" text_position="center">
      <.button>Center Text Position</.button>
    </.tooltip>

    <.tooltip text="Text justified" text_position="justify">
      <.button>Justified Text</.button>
    </.tooltip>

    <.tooltip text="Text starting position" text_position="start">
      <.button>Start Text Position</.button>
    </.tooltip>

    <.tooltip text="Text ending position" text_position="end">
      <.button>End Text Position</.button>
    </.tooltip>
    """
  end

  defp code_string(10) do
    """
    <.tooltip text="Thin font weight" font_weight="font-thin">
      <.button>Thin Font</.button>
    </.tooltip>

    <.tooltip text="Light font weight" font_weight="font-light">
      <.button>Light Font</.button>
    </.tooltip>

    <.tooltip text="Normal font weight" font_weight="font-normal">
      <.button>Normal Font</.button>
    </.tooltip>

    <.tooltip text="Medium font weight" font_weight="font-medium">
      <.button>Medium Font</.button>
    </.tooltip>

    <.tooltip text="Semibold font weight" font_weight="font-semibold">
      <.button>Semibold Font</.button>
    </.tooltip>

    <.tooltip text="Bold font weight" font_weight="font-bold">
      <.button>Bold Font</.button>
    </.tooltip>

    <.tooltip text="Extrabold font weight" font_weight="font-extrabold">
      <.button>Extrabold Font</.button>
    </.tooltip>
    """
  end

  defp code_string(11) do
    """
    <.tooltip text="Tooltip text" color="natural" variant="bordered">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="primary" variant="bordered">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="secondary" variant="bordered">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="success" variant="bordered">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="warning" variant="bordered">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="danger" variant="bordered">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="info" variant="bordered">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="light" variant="bordered">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="misc" variant="bordered">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="dawn" variant="bordered">
      <.button>tooltip</.button>
    </.tooltip>
    """
  end

  defp code_string(12) do
    """
    <.tooltip text="Tooltip text" color="natural" variant="gradient">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="white" variant="gradient">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="dark" variant="gradient">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="primary" variant="gradient">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="secondary" variant="gradient">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="success" variant="gradient">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="warning" variant="gradient">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="danger" variant="gradient">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="info" variant="gradient">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="light" variant="gradient">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="misc" variant="gradient">
      <.button>tooltip</.button>
    </.tooltip>

    <.tooltip text="Tooltip text" color="dawn" variant="gradient">
      <.button>tooltip</.button>
    </.tooltip>
    """
  end

  defp code_string(13) do
    """
    <.tooltip
      text="Contnet"
      color="dark"
      show_arrow={false}
    >
      <.button color="secondary" size="small">
        Trigger
      </.button>
    </.tooltip>
    """
  end

  defp code_string(14) do
    """
    <.tooltip text="Tooltip text">
      <.button>tooltip</.button>
    </.tooltip>
    """
  end

  defp code_string(15) do
    """
    <.tooltip
      position="top"
      text="This is a clickable tooltip"
      width="min-w-40"
      rounded="large"
      size="extra_small"
      variant="default"
      clickable
      color="info"
    >
      <:trigger>
        <span class="cursor-pointer">Click me to see tooltip</span>
      </:trigger>
    </.tooltip>

    <.tooltip
      position="bottom"
      text="Click tooltip with inline display"
      width="min-w-32"
      rounded="medium"
      size="small"
      variant="shadow"
      clickable
      inline
      color="primary"
    >
      <:trigger>
        <span class="cursor-pointer text-blue-600 underline">Inline clickable tooltip</span>
      </:trigger>
    </.tooltip>

    <.tooltip
      position="right"
      text="Another clickable example"
      width="large"
      rounded="small"
      size="medium"
      variant="bordered"
      clickable
      color="success"
    >
      <:trigger>
        <button class="bg-green-500 text-white px-4 py-2 rounded">Click for tooltip</button>
      </:trigger>
    </.tooltip>
    """
  end

  defp component_config() do
    [
      name: "tooltip",
      args: [
        variant: ["default", "shadow", "bordered", "gradient"],
        color: [
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
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        only: ["tooltip"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/tooltip"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Tooltips for Phoenix and Phoenix LiveView offer customizable options to display contextual information when users hover or focus on elements, enhancing user engagement.",
      keywords:
        "phoenix tooltip component, tooltip component, liveview tooltip component, elixir, liveview, mishka chelekom tooltip component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Tooltip - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Tooltip - Chelekom Phoenix & LiveView component",
      og_title: "Tooltip - Chelekom Phoenix & LiveView component",
      og_description:
        "Tooltips for Phoenix and Phoenix LiveView offer customizable options to display contextual information when users hover or focus on elements, enhancing user engagement.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Tooltip - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Tooltips for Phoenix and Phoenix LiveView offer customizable options to display contextual information when users hover or focus on elements, enhancing user engagement."
    }
  end
end
