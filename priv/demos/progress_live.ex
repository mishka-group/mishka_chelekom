defmodule MishkaWeb.ChelekomLive.Docs.ProgressLive do
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
      |> assign(page_title: "Progress - Chelekom Phoenix & LiveView component")
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
      |> assign(code_18: code_string(18))
      |> assign(code_19: code_string(19))
      |> assign(code_20: code_string(20))
      |> assign(code_21: code_string(21))
      |> assign(code_22: code_string(22))
      |> assign(code_23: code_string(23))
      |> assign(code_24: code_string(24))
      |> assign(code_25: code_string(25))
      |> assign(code_26: code_string(26))
      |> assign(code_27: code_string(27))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.progress variant="default" color="natural" />
    <.progress variant="default" color="white" />
    <.progress variant="default" color="primary" />
    <.progress variant="default" color="secondary" />
    <.progress variant="default" color="dark" />
    <.progress variant="default" color="success" />
    <.progress variant="default" color="warning" />
    <.progress variant="default" color="danger" />
    <.progress variant="default" color="info" />
    <.progress variant="default" color="light" />
    <.progress variant="default" color="misc" />
    <.progress variant="default" color="dawn" />
    """
  end

  defp code_string(2) do
    """
    <.progress variant="gradient" color="natural" />
    <.progress variant="gradient" color="primary" />
    <.progress variant="gradient" color="secondary" />
    <.progress variant="gradient" color="dark" />
    <.progress variant="gradient" color="success" />
    <.progress variant="gradient" color="warning" />
    <.progress variant="gradient" color="danger" />
    <.progress variant="gradient" color="info" />
    <.progress variant="gradient" color="light" />
    <.progress variant="gradient" color="misc" />
    <.progress variant="gradient" color="dawn" />
    """
  end

  defp code_string(3) do
    """
    <.progress value={4} />
    <.ring_progress value={32} />
    <.semi_circle_progress value={77} />
    """
  end

  defp code_string(4) do
    """
    <!--Horizontal-->
    <.progress />
    <.progress variation="horizontal" />

    <.progress variation="vertical" />
    """
  end

  defp code_string(5) do
    """
    <.progress size="extra_small" />
    <.progress size="small" />
    <.progress size="medium" />
    <.progress size="large" />
    <.progress size="extra_large" />
    <.progress size="double_large" />
    <.progress size="triple_large" />
    <.progress size="quadruple_large" />

    <.progress variation="vertical" size="extra_small" />
    <.progress variation="vertical" size="small" />
    <.progress variation="vertical" size="medium" />
    <.progress variation="vertical" size="large" />
    <.progress variation="vertical" size="extra_large" />
    <.progress variation="vertical" size="double_large" />
    <.progress variation="vertical" size="triple_large" />
    <.progress variation="vertical" size="quadruple_large" />
    """
  end

  defp code_string(6) do
    """
    <.progress>
      <.progress_section color="dawn" value={80} />
    </.progress>
    """
  end

  defp code_string(7) do
    """
     <.progress>
      <.progress_section csp_nonce={@csp_nonce} color="primary" value={10} />
      <.progress_section csp_nonce={@csp_nonce} color="secondary" value={15} />
      <.progress_section csp_nonce={@csp_nonce} color="misc" value={10} />
      <.progress_section csp_nonce={@csp_nonce} color="danger" value={5} />
      <.progress_section csp_nonce={@csp_nonce} color="warning" value={10} />
      <.progress_section csp_nonce={@csp_nonce} color="success" value={10} />
      <.progress_section csp_nonce={@csp_nonce} color="info" value={5} />
    </.progress>

    <!--Vertical-->
    <.progress
      variation="vertical"
      size="w-5 height-[350px]"
    >
      <.progress_section value={60} csp_nonce={@csp_nonce} variation="vertical">
      </.progress_section>
      <.progress_section value={30} csp_nonce={@csp_nonce} variation="vertical">
      </.progress_section>
      <.progress_section value={10} csp_nonce={@csp_nonce} variation="vertical">
      </.progress_section>
    </.progress>
    """
  end

  defp code_string(8) do
    """
     <.progress size="extra_large">
      <.progress_section color="primary" value={10}>
        <:label class="fonte-bold">Images</:label>
      </.progress_section>
      <.progress_section color="secondary" value={5}>
        <:label class="text-white">15%</:label>
      </.progress_section>
      <.progress_section color="misc" value={30}>
       <:label class="font-bold">Other</:label>
      </.progress_section>
    </.progress>

    <.progress size="extra_large">
      <.progress_section csp_nonce={@csp_nonce} color="misc" value={20}>
        <:label class="font-bold">80%</:label>
      </.progress_section>
    </.progress>
    """
  end

  defp code_string(9) do
    """
    <.progress />
    """
  end

  defp code_string(10) do
    """
    <.ring_progress value={30} max={60} />
    <.ring_progress value={30} max={100} />
    """
  end

  defp code_string(11) do
    """
    <.ring_progress size={150} />
    """
  end

  defp code_string(12) do
    """
    <.ring_progress thickness={4} />
    """
  end

  defp code_string(13) do
    """
    <.ring_progress color="natural" />
    <.ring_progress color="white" />
    <.ring_progress color="primary" />
    <.ring_progress color="secondary" />
    <.ring_progress color="dark" />
    <.ring_progress color="success" />
    <.ring_progress color="warning" />
    <.ring_progress color="danger" />
    <.ring_progress color="info" />
    <.ring_progress color="light" />
    <.ring_progress color="misc" />
    <.ring_progress color="dawn" />
    """
  end

  defp code_string(14) do
    """
    <.ring_progress label="Uploading" />
    """
  end

  defp code_string(15) do
    """
    <.ring_progress />
    """
  end

  defp code_string(16) do
    """
    <.semi_circle_progress />
    """
  end

  defp code_string(17) do
    """
    <.ring_progress linecap="butt" />
    <.ring_progress linecap="round" />
    <.ring_progress linecap="square" />
    """
  end

  defp code_string(18) do
    """
    <.semi_circle_progress value={20} />
    """
  end

  defp code_string(19) do
    """
    <.semi_circle_progress size={150} />
    """
  end

  defp code_string(20) do
    """
    <.semi_circle_progress thickness={2} />
    """
  end

  defp code_string(21) do
    """
    <.semi_circle_progress orientation="up" />
    <.semi_circle_progress orientation="down" />
    """
  end

  defp code_string(22) do
    """
    <.semi_circle_progress fill_direction="left-to-right"/>
    <.semi_circle_progress fill_direction="right-to-left" />
    """
  end

  defp code_string(23) do
    """
    <.semi_circle_progress transition_duration={150} />
    """
  end

  defp code_string(24) do
    """
    <.semi_circle_progress linecap="butt" />
    <.semi_circle_progress linecap="round" />
    <.semi_circle_progress linecap="square" />
    """
  end

  defp code_string(25) do
    """
    <.semi_circle_progress color="natural" />
    <.semi_circle_progress color="white" />
    <.semi_circle_progress color="primary" />
    <.semi_circle_progress color="secondary" />
    <.semi_circle_progress color="dark" />
    <.semi_circle_progress color="success" />
    <.semi_circle_progress color="warning" />
    <.semi_circle_progress color="danger" />
    <.semi_circle_progress color="info" />
    <.semi_circle_progress color="light" />
    <.semi_circle_progress color="misc" />
    <.semi_circle_progress color="dawn" />
    """
  end

  defp code_string(26) do
    """
    <.semi_circle_progress label="Uploading" />
    """
  end

  defp code_string(27) do
    """
    <.progress size="extra_large">
      <.progress_section color="primary" value={10}>
        <:tooltip label="Images" position="top" class="font-bold">
          Tooltip content for Images
        </:tooltip>
      </.progress_section>

      <.progress_section color="secondary" value={5}>
        <:tooltip label="15%" position="bottom" class="text-white">
          Only 5% left
        </:tooltip>
      </.progress_section>

      <.progress_section color="misc" value={30}>
        <:tooltip label="Other" position="top" clickable={true} class="font-bold">
          This section represents other files
        </:tooltip>
      </.progress_section>
    </.progress>

    <.progress size="extra_large">
      <.progress_section csp_nonce={@csp_nonce} color="misc" value={20}>
        <:tooltip label="80%" position="right" clickable={true} class="font-bold">
          80% of content processed
        </:tooltip>
      </.progress_section>
    </.progress>

    <!--Vertical-->
    <.progress
      variation="vertical"
      size="w-5 height-[350px]"
    >
      <.progress_section value={60} csp_nonce={@csp_nonce} variation="vertical">
        <:tooltip label="1" position="right">Step 1</:tooltip>
      </.progress_section>
      <.progress_section value={30} csp_nonce={@csp_nonce} variation="vertical">
        <:tooltip label="2" position="right">Step 2</:tooltip>
      </.progress_section>
      <.progress_section value={10} csp_nonce={@csp_nonce} variation="vertical">
        <:tooltip label="3" position="right">Step 3</:tooltip>
      </.progress_section>
    </.progress>
    """
  end

  defp component_config() do
    [
      name: "progress",
      args: [
        variant: ["default", "gradient", "base"],
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
        size: [
          "extra_small",
          "small",
          "medium",
          "large",
          "extra_large",
          "double_large",
          "triple_large",
          "quadruple_large"
        ],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full"],
        type: ["progress", "progress_section"],
        only: ["progress", "progress_section"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/progress"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Interactive progress bars for Phoenix LiveView with horizontal and vertical options, colors, sizes, gradients, and chunked or segmented progress sections.",
      keywords:
        "phoenix progress component, progress component, liveview progress component, elixir, liveview, mishka chelekom progress component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Progress - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Progress - Chelekom Phoenix & LiveView component",
      og_title: "Progress - Chelekom Phoenix & LiveView component",
      og_description:
        "Interactive progress bars for Phoenix LiveView with horizontal and vertical options, colors, sizes, gradients, and chunked or segmented progress sections.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Progress - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Interactive progress bars for Phoenix LiveView with horizontal and vertical options, colors, sizes, gradients, and chunked or segmented progress sections."
    }
  end
end
