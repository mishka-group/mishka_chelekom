defmodule MishkaWeb.ChelekomLive.Docs.PopoverLive do
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

  def mount(_params, session, socket) do
    nonce = Map.get(session, "style_csp_nonce")

    socket =
      socket
      |> assign(page_title: "Popover - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags(), csp_nonce: nonce)
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
      |> assign(code_16: code_string(16))
      |> assign(code_17: code_string(17))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <!--This popover is clickable -->
    <!--so use a unique ID for the content, and reference that ID in the trigger_id -->
     <.popover clickable id="uniqu_id" rounded="small" width="large" color="dawn" padding="small">
      <:trigger class="custom_class">
        <.button color="dawn" size="small">popover trigger</.button>
      </:trigger>

      <:content class="custom_class">
        Content within popover content component
      </:content>
    </.popover>

    <!--Example of popover with :trigger and :content -->
    <.popover
      clickable
      id="uniqu_id"
      rounded="small"
      width="large"
      color="dawn"
      padding="small"
    >
      <:trigger>
        <.button color="dawn" size="small">popover trigger</.button>
      </:trigger>

      <:content
        class="custom_class"
      >
        Content within popover content component
      </:content>
    </.popover>
    """
  end

  defp code_string(2) do
    """
    <!--an example of how to use inline popover within a <p> tag-->
     <p>
      Learn more about
        <.popover inline>
          <:trigger class="your_classes">Mishka Chelekom</:trigger>
          <:content class="custom_class">
            <span class="p-4 block">
              <span class="text-lg font-semibold block">About Mishka Chelekom</span>
            </span>
          </:content>
        </.popover>
      and its UI components.
    </p>


    <!--Clickable inline-->
    <!--if you add clickable to popover keep in mind use unique IDs-->
    <p>
      Learn more about
        <.popover clickable inline>
          <:trigger trigger_id="unique_id">Mishka Chelekom</:trigger>
          <:content>
            <span class="p-4 block">
              <span class="text-lg font-semibold block">About Mishka Chelekom</span>
            </span>
          </:content>
        </.popover>
      and its UI components.
    </p>
    """
  end

  defp code_string(3) do
    """
    <.popover clickable id="unique_id">
      <:trigger></:trigger>

      <:content></:content>
    </.popover>
    """
  end

  defp code_string(4) do
    """
    <.popover color="white">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover color="primary">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover color="secondary">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover color="dark">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover color="success">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover color="warning">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover color="danger">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover color="info">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover color="silver">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover color="misc">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover color="dawn">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>
    """
  end

  defp code_string(5) do
    """
    <.popover variant="shadow" color="primary">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="shadow" color="secondary">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="shadow" color="success">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="shadow" color="warning">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="shadow" color="danger">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="shadow" color="info">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="shadow" color="silver">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="shadow" color="misc">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="shadow" color="dawn">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>
    """
  end

  defp code_string(6) do
    """
    <!--The position is set to top by default, you don't need to specify it.-->
    <.popover>
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover position="bottom">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover position="left">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover position="right">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>
    """
  end

  defp code_string(7) do
    """
    <.popover size="extra_small">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover size="small">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover size="medium">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover size="large">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover size="extra_large">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>
    """
  end

  defp code_string(8) do
    """
    <.popover space="extra_small">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover space="small">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover space="medium">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover space="large">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover space="extra_large">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>
    """
  end

  defp code_string(9) do
    """
    <.popover padding="extra_small">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover padding="small">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover padding="medium">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover padding="large">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover padding="extra_large">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>
    """
  end

  defp code_string(10) do
    """
    <.popover width="extra_small">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover width="small">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover width="medium">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover width="large">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover width="extra_large">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover width="double_large">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover width="triple_large">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover width="quadruple_large">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>
    """
  end

  defp code_string(11) do
    """
    <.popover rounded="extra_small">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover rounded="small">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover rounded="medium">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover rounded="large">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover rounded="extra_large">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover rounded="none">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>
    """
  end

  defp code_string(12) do
    """
    <.popover text_position="left">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover text_position="right">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover text_position="center">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover text_position="justify">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover text_position="start">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover text_position="end">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>
    """
  end

  defp code_string(13) do
    """
     <.popover font_weight="font-thin">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover font_weight="font-normal">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>
    """
  end

  defp code_string(14) do
    """
    <.popover variant="bordered" color="white">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="bordered" color="primary">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="bordered" color="secondary">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="bordered" color="dark">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="bordered" color="success">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="bordered" color="warning">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="bordered" color="danger">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="bordered" color="info">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="bordered" color="silver">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="bordered" color="misc">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="bordered" color="dawn">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>
    """
  end

  defp code_string(15) do
    """
    <.popover variant="gradient" color="primary">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="gradient" color="secondary">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="gradient" color="success">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="gradient" color="warning">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="gradient" color="danger">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="gradient" color="info">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="gradient" color="silver">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="gradient" color="misc">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>

    <.popover variant="gradient" color="dawn">
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>
    """
  end

  defp code_string(16) do
    """
    <!--By default show_arrow is true-->
    <.popover>
      <:trigger></:trigger>

      <:content show_arrow={false}></:content>
    </.popover>

    <.popover>
      <:trigger></:trigger>

      <:content show_arrow={true}></:content>
    </.popover>
    """
  end

  defp code_string(17) do
    """
    <.popover>
      <:trigger class="your_classes"></:trigger>
      <:content></:content>
    </.popover>
    """
  end

  defp component_config() do
    [
      name: "popover",
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
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        type: ["popover"],
        only: ["popover"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/popover"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "interactive popovers in Phoenix and LiveView with customizable triggers, layouts, and styling",
      keywords:
        "phoenix popover component, popover component, liveview popover component, elixir, liveview, mishka chelekom popover component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Popover - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Popover - Chelekom Phoenix & LiveView component",
      og_title: "Popover - Chelekom Phoenix & LiveView component",
      og_description:
        "interactive popovers in Phoenix and LiveView with customizable triggers, layouts, and styling",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Popover - Chelekom Phoenix & LiveView component",
      twitter_description:
        "interactive popovers in Phoenix and LiveView with customizable triggers, layouts, and styling"
    }
  end
end
