defmodule MishkaWeb.ChelekomLive.Docs.SpeedDialLive do
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

  @all_dial Enum.map(1..33, &"speed-dial-example-#{&1}")

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "SpeedDial - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(dial_pos: "none")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("dial_position", %{"pos" => pos}, socket) do
    socket =
      socket
      |> assign(dial_pos: if(Enum.member?(@all_dial, pos), do: pos, else: "none"))

    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.speed_dial color="white"></.speed_dial>
    <.speed_dial color="natural"></.speed_dial>
    <.speed_dial color="primary"></.speed_dial>
    <.speed_dial color="secondary"></.speed_dial>
    <.speed_dial color="dark"></.speed_dial>
    <.speed_dial color="success"></.speed_dial>
    <.speed_dial color="warning"></.speed_dial>
    <.speed_dial color="danger"></.speed_dial>
    <.speed_dial color="info"></.speed_dial>
    <.speed_dial color="light"></.speed_dial>
    <.speed_dial color="misc"></.speed_dial>
    <.speed_dial color="dawn"></.speed_dial>
    """
  end

  defp code_string(2) do
    """
    <.speed_dial color="natural" variant="shadow"></.speed_dial>
    <.speed_dial color="primary" variant="shadow"></.speed_dial>
    <.speed_dial color="secondary" variant="shadow"></.speed_dial>
    <.speed_dial color="success" variant="shadow"></.speed_dial>
    <.speed_dial color="warning" variant="shadow"></.speed_dial>
    <.speed_dial color="danger" variant="shadow"></.speed_dial>
    <.speed_dial color="info" variant="shadow"></.speed_dial>
    <.speed_dial color="light" variant="shadow"></.speed_dial>
    <.speed_dial color="misc" variant="shadow"></.speed_dial>
    <.speed_dial color="dawn" variant="shadow"></.speed_dial>
    """
  end

  defp code_string(3) do
    """
    <.speed_dial color="natural" variant="bordered"></.speed_dial>
    <.speed_dial color="white" variant="bordered"></.speed_dial>
    <.speed_dial color="primary" variant="bordered"></.speed_dial>
    <.speed_dial color="secondary" variant="bordered"></.speed_dial>
    <.speed_dial color="dark" variant="bordered"></.speed_dial>
    <.speed_dial color="success" variant="bordered"></.speed_dial>
    <.speed_dial color="warning" variant="bordered"></.speed_dial>
    <.speed_dial color="danger" variant="bordered"></.speed_dial>
    <.speed_dial color="info" variant="bordered"></.speed_dial>
    <.speed_dial color="light" variant="bordered"></.speed_dial>
    <.speed_dial color="misc" variant="bordered"></.speed_dial>
    <.speed_dial color="dawn" variant="bordered"></.speed_dial>
    """
  end

  defp code_string(4) do
    """
    <.speed_dial action_position="top-start">
      <:item></:item>
    </.speed_dial>
    <.speed_dial action_position="top-end">
      <:item></:item>
    </.speed_dial>
    <.speed_dial action_position="bottom-start">
      <:item></:item>
    </.speed_dial>
    <.speed_dial action_position="bottom-end">
      <:item></:item>
    </.speed_dial>
    """
  end

  defp code_string(5) do
    """
    <.speed_dial wrapper_position="top">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial wrapper_position="left">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial wrapper_position="bottom">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial wrapper_position="right">
      <:item icon="hero-home" />
    </.speed_dial>
    """
  end

  defp code_string(6) do
    """
    <.speed_dial rounded="extra_small">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial rounded="small">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial rounded="medium">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial rounded="large">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial rounded="extra_large">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial rounded="full">
      <:item icon="hero-home" />
    </.speed_dial>
    """
  end

  defp code_string(7) do
    """
    <.speed_dial border="extra_small">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial border="small">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial border="medium">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial border="large">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial border="extra_large">
      <:item icon="hero-home" />
    </.speed_dial>
    """
  end

  defp code_string(8) do
    """
    <.speed_dial size="extra_small">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial size="small">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial size="medium">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial size="large">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial size="extra_large">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial size="double_large">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial size="triple_large">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial size="quadruple_large">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial size="fit">
      <:item icon="hero-home" />
    </.speed_dial>
    """
  end

  defp code_string(9) do
    """
    <.speed_dial space="extra_small">
      <:item icon="hero-home" />
      <:item icon="hero-star" />
    </.speed_dial>
    <.speed_dial space="small">
      <:item icon="hero-home" />
      <:item icon="hero-star" />
    </.speed_dial>
    <.speed_dial space="medium">
      <:item icon="hero-home" />
      <:item icon="hero-star" />
    </.speed_dial>
    <.speed_dial space="large">
      <:item icon="hero-home" />
      <:item icon="hero-star" />
    </.speed_dial>
    <.speed_dial space="extra_large">
      <:item icon="hero-home" />
      <:item icon="hero-star" />
    </.speed_dial>
    """
  end

  defp code_string(10) do
    """
    <.speed_dial width="extra_small">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial width="small">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial width="medium">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial width="large">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial width="extra_large">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial width="double_large">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial width="triple_large">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial width="quadruple_large">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial width="fit">
      <:item icon="hero-home" />
    </.speed_dial>
    """
  end

  defp code_string(11) do
    """
    <.speed_dial padding="extra_small">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial padding="small">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial padding="medium">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial padding="large">
      <:item icon="hero-home" />
    </.speed_dial>
    <.speed_dial padding="extra_large">
      <:item icon="hero-home" />
    </.speed_dial>
    """
  end

  defp code_string(12) do
    """
    <.speed_dial clickable id="unique_id">
      <:item icon="hero-home" />
      <:item icon="hero-star" />
    </.speed_dial>
    """
  end

  defp code_string(13) do
    """
    <.speed_dial icon="hero-home">
      <:item icon="hero-home" />
      <:item icon="hero-star" />
    </.speed_dial>
    """
  end

  defp code_string(14) do
    """
    <.speed_dial icon="hero-home" icon_animated>
      <:item icon="hero-home" />
      <:item icon="hero-star" />
    </.speed_dial>
    """
  end

  defp code_string(15) do
    """
    <.speed_dial>
      <:item icon="hero-home" color="info" />
      <:item icon="hero-star" color="secondary" />
      <:item icon="hero-chart-bar" color="primary" />
    </.speed_dial>
    """
  end

  defp code_string(16) do
    """
    <.speed_dial>
      <:item icon="hero-home" href="/path" />
      <:item icon="hero-star" navigate="/path" />
      <:item icon="hero-chart-bar" patch="/path" />
    </.speed_dial>
    """
  end

  defp code_string(17) do
    """
    <.speed_dial>
      <:item icon="hero-home" icon_class="your_classes" />
      <:item icon="hero-star" icon_class="your_classes" />
      <:item icon="hero-chart-bar" icon_class="your_classes" />
    </.speed_dial>
    """
  end

  defp code_string(18) do
    """
    <.speed_dial>
      <:item>Home</:item>
      <:item>Mishka<:item>
    </.speed_dial>
    """
  end

  defp code_string(19) do
    """
    <.speed_dial>
      <:item content_class="font-bold text-amber-800">Home</:item>
      <:item content_class="font-bold text-amber-800">Mishka<:item>
    </.speed_dial>
    """
  end

  defp code_string(20) do
    """
    <.speed_dial color="natural" variant="bordered"></.speed_dial>
    <.speed_dial color="primary" variant="bordered"></.speed_dial>
    <.speed_dial color="secondary" variant="bordered"></.speed_dial>
    <.speed_dial color="success" variant="bordered"></.speed_dial>
    <.speed_dial color="warning" variant="bordered"></.speed_dial>
    <.speed_dial color="danger" variant="bordered"></.speed_dial>
    <.speed_dial color="info" variant="bordered"></.speed_dial>
    <.speed_dial color="light" variant="bordered"></.speed_dial>
    <.speed_dial color="misc" variant="bordered"></.speed_dial>
    <.speed_dial color="dawn" variant="bordered"></.speed_dial>
    """
  end

  defp code_string(21) do
    """
    <.speed_dial></.speed_dial>
    """
  end

  defp component_config() do
    [
      name: "speed_dial",
      args: [
        variant: ["default", "bordered", "shadow", "gradient", "base"],
        color: [
          "base",
          "natural",
          "primary",
          "secondary",
          "success",
          "warning",
          "danger",
          "info",
          "silver",
          "misc",
          "dark",
          "white",
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
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full"],
        only: ["speed_dial"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/speed-dial"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Interactive speed dial menus for Phoenix LiveView, offering quick access to multiple actions with customizable icons, colors, and animations.",
      keywords:
        "phoenix speed dial component, speed dial component, liveview speed dial component, elixir, liveview, mishka chelekom speed dial component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "SpeedDial - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "SpeedDial - Chelekom Phoenix & LiveView component",
      og_title: "SpeedDial - Chelekom Phoenix & LiveView component",
      og_description:
        "Interactive speed dial menus for Phoenix LiveView, offering quick access to multiple actions with customizable icons, colors, and animations.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "SpeedDial - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Interactive speed dial menus for Phoenix LiveView, offering quick access to multiple actions with customizable icons, colors, and animations."
    }
  end
end
