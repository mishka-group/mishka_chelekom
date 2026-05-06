defmodule MishkaWeb.ChelekomLive.Docs.ButtonLive do
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
      |> assign(page_title: "Button - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.button variant="default" color="natural">Natural</.button>

    <.button variant="default" color="white">White</.button>

    <.button variant="default" color="dark">Dark</.button>

    <.button variant="default" color="primary">Primary</.button>

    <.button variant="default" color="secondary">Secondary</.button>

    <.button variant="default" color="success">Success</.button>

    <.button variant="default" color="warning">Warning</.button>

    <.button variant="default" color="danger">Danger</.button>

    <.button variant="default" color="info">Info</.button>

    <.button variant="default" color="silver">Silver</.button>

    <.button variant="default" color="misc">Misc</.button>

    <.button variant="default" color="dawn">Dawn</.button>
    """
  end

  defp code_string(2) do
    """
    <.button variant="outline" color="natural">Natural</.button>

    <.button variant="outline" color="primary">Primary</.button>

    <.button variant="outline" color="secondary">Secondary</.button>

    <.button variant="outline" color="success">Success</.button>

    <.button variant="outline" color="warning">Warning</.button>

    <.button variant="outline" color="danger">Danger</.button>

    <.button variant="outline" color="info">Info</.button>

    <.button variant="outline" color="silver">Silver</.button>

    <.button variant="outline" color="misc">Misc</.button>

    <.button variant="outline" color="dawn">Dawn</.button>
    """
  end

  defp code_string(3) do
    """
    <.button variant="transparent" color="natural">Natural</.button>

    <.button variant="transparent" color="primary">Primary</.button>

    <.button variant="transparent" color="secondary">Secondary</.button>

    <.button variant="transparent" color="success">Success</.button>

    <.button variant="transparent" color="warning">Warning</.button>

    <.button variant="transparent" color="danger">Danger</.button>

    <.button variant="transparent" color="info">Info</.button>

    <.button variant="transparent" color="silver">Silver</.button>

    <.button variant="transparent" color="misc">Misc</.button>

    <.button variant="transparent" color="dawn">Dawn</.button>
    """
  end

  defp code_string(4) do
    """
    <.button variant="subtle" color="natural">Natural</.button>

    <.button variant="subtle" color="primary">Primary</.button>

    <.button variant="subtle" color="secondary">Secondary</.button>

    <.button variant="subtle" color="success">Success</.button>

    <.button variant="subtle" color="warning">Warning</.button>

    <.button variant="subtle" color="danger">Danger</.button>

    <.button variant="subtle" color="info">Info</.button>

    <.button variant="subtle" color="silver">Silver</.button>

    <.button variant="subtle" color="misc">Misc</.button>

    <.button variant="subtle" color="dawn">Dawn</.button>
    """
  end

  defp code_string(5) do
    """
    <.button variant="shadow" color="natural">Natural</.button>

    <.button variant="shadow" color="primary">Primary</.button>

    <.button variant="shadow" color="secondary">Secondary</.button>

    <.button variant="shadow" color="success">Success</.button>

    <.button variant="shadow" color="warning">Warning</.button>

    <.button variant="shadow" color="danger">Danger</.button>

    <.button variant="shadow" color="info">Info</.button>

    <.button variant="shadow" color="silver">Silver</.button>

    <.button variant="shadow" color="misc">Misc</.button>

    <.button variant="shadow" color="dawn">Dawn</.button>
    """
  end

  defp code_string(6) do
    """
    <.button variant="inverted" color="natural">Natural</.button>

    <.button variant="inverted" color="primary">Primary</.button>

    <.button variant="inverted" color="secondary">Secondary</.button>

    <.button variant="inverted" color="success">Success</.button>

    <.button variant="inverted" color="warning">Warning</.button>

    <.button variant="inverted" color="danger">Danger</.button>

    <.button variant="inverted" color="info">Info</.button>

    <.button variant="inverted" color="silver">Silver</.button>

    <.button variant="inverted" color="misc">Misc</.button>

    <.button variant="inverted" color="dawn">Dawn</.button>
    """
  end

  defp code_string(7) do
    """
    <.button variant="default_gradient" color="natural">Natural</.button>

    <.button variant="default_gradient" color="primary">Primary</.button>

    <.button variant="default_gradient" color="secondary">Secondary</.button>

    <.button variant="default_gradient" color="success">Success</.button>

    <.button variant="default_gradient" color="warning">Warning</.button>

    <.button variant="default_gradient" color="danger">Danger</.button>

    <.button variant="default_gradient" color="info">Info</.button>

    <.button variant="default_gradient" color="misc">Misc</.button>

    <.button variant="default_gradient" color="dawn">Dawn</.button>

    <.button variant="default_gradient" color="silver">Silver</.button>
    """
  end

  defp code_string(8) do
    """
    <.button variant="outline_gradient" color="natural">Natural</.button>

    <.button variant="outline_gradient" color="primary">Primary</.button>

    <.button variant="outline_gradient" color="secondary">Secondary</.button>

    <.button variant="outline_gradient" color="success">Success</.button>

    <.button variant="outline_gradient" color="warning">Warning</.button>

    <.button variant="outline_gradient" color="danger">Danger</.button>

    <.button variant="outline_gradient" color="info">Info</.button>

    <.button variant="outline_gradient" color="misc">Misc</.button>

    <.button variant="outline_gradient" color="dawn">Dawn</.button>

    <.button variant="outline_gradient" color="silver">Silver</.button>
    """
  end

  defp code_string(9) do
    """
    <.button variant="inverted_gradient" color="natural">Natural</.button>

    <.button variant="inverted_gradient" color="primary">Primary</.button>

    <.button variant="inverted_gradient" color="secondary">Secondary</.button>

    <.button variant="inverted_gradient" color="success">Success</.button>

    <.button variant="inverted_gradient" color="warning">Warning</.button>

    <.button variant="inverted_gradient" color="danger">Danger</.button>

    <.button variant="inverted_gradient" color="info">Info</.button>

    <.button variant="inverted_gradient" color="misc">Misc</.button>

    <.button variant="inverted_gradient" color="dawn">Dawn</.button>

    <.button variant="inverted_gradient" color="silver">Silver</.button>
    """
  end

  defp code_string(10) do
    """
    <.button rounded="extra_small">Extra Small</.button>

    <.button rounded="small">Small</.button>

    <.button rounded="medium">Medium</.button>

    <.button rounded="large">Large</.button>

    <.button rounded="extra_large">Extra Large</.button>
    """
  end

  defp code_string(11) do
    """
    <.button display="flex">Flex</.button>

    <.button display="inline-flex">Inline Flex</.button>

    <.button display="block">Block</.button>

    <.button display="inline-block">Inline Block</.button>

    <.button display="flex">Flex</.button>
    """
  end

  defp code_string(12) do
    """
    <.button icon="hero-bookmark" icon_class="size-4" />

    <.button icon="hero-plus">Button</.button>

    <.button icon="hero-bell">Button</.button>

    <.button icon="hero-magnifying-glass-circle-solid">Button</.button>

    <.button icon="hero-play">Button</.button>
    """
  end

  defp code_string(13) do
    """
    <.button left_indicator indicator_size="extra_small">
      Extra Small Indicator - Left
    </.button>

    <.button right_indicator indicator_size="small">
      Small Indicator - Right
    </.button>

    <.button top_left_indicator indicator_size="medium">
      Medium Indicator - Top Left
    </.button>

    <.button top_center_indicator indicator_size="large">
      Large Indicator - Top Center
    </.button>

    <.button top_right_indicator indicator_size="extra_large">
      Extra Large Indicator - Top Right
    </.button>

    <.button middle_left_indicator indicator_size="medium">
      Medium Indicator - Middle Left
    </.button>

    <.button middle_right_indicator indicator_size="medium">
      Medium Indicator - Middle Right
    </.button>

    <.button bottom_left_indicator indicator_size="medium">
      Medium Indicator - Bottom Left
    </.button>

    <.button bottom_center_indicator indicator_size="medium">
      Medium Indicator - Bottom Center
    </.button>

    <.button bottom_right_indicator indicator_size="medium">
      Medium Indicator - Bottom Right
    </.button>
    """
  end

  defp code_string(14) do
    """
    <.button left_indicator pinging>
      Extra Small Indicator - Left (Pinging)
    </.button>

    <.button right_indicator pinging>
      Small Indicator - Right (Pinging)
    </.button>

    <.button top_left_indicator pinging>
      Medium Indicator - Top Left (Pinging)
    </.button>

    <.button top_center_indicator pinging>
      Large Indicator - Top Center (Pinging)
    </.button>

    <.button top_right_indicator pinging>
      Extra Large Indicator - Top Right (Pinging)
    </.button>
    """
  end

  defp code_string(15) do
    """
    <.button circle size="extra_small">Extra Small Button</.button>

    <.button circle size="small">Small Button</.button>

    <.button circle size="medium">Medium Button</.button>

    <.button circle size="large">Large Button</.button>

    <.button circle size="extra_large">Extra Large Button</.button>

    <.button circle rounded="full" size="extra_large">
      Extra Large Button
    </.button>
    """
  end

  defp code_string(16) do
    """
    <.button_link navigate="/" color="primary" size="extra_small">Primary</.button_link>

    <.button_link navigate="/" color="secondary" size="small">Secondary</.button_link>

    <.button_link navigate="/" color="info" size="medium">Info</.button_link>

    <.button_link navigate="/" color="misc" size="large">Misc</.button_link>

    <.button_link navigate="/" color="silver" size="extra_large">Silver</.button_link>
    """
  end

  defp code_string(17) do
    """
    <.button_group variation="vertical" color="primary">
      <.button icon="hero-signal" color="info"/>
      <.button icon="hero-share" color="info"/>
      <.button icon="hero-rss" color="info"/>
    </.button_group>

    <.button_group color="misc">
      <.button variant="inverted" color="misc">
        Button
      </.button>

      <.button variant="inverted" color="misc">
        Button
      </.button>

      <.button variant="inverted" color="misc">
        Button
      </.button>

      <.button variant="inverted" color="misc">
        Button
      </.button>
    </.button_group>
    """
  end

  defp code_string(18) do
    """
    <.input_button type="submit" size="extra_small" value="Primary" />

    <.input_button type="submit" size="small" value="Secondary" />

    <.input_button type="button" size="medium" value="Info" />

    <.input_button type="button" size="large" value="Misc" />

    <.input_button type="reset" size="extra_large" value="silver" />
    """
  end

  defp code_string(19) do
    """
    <.button disabled>default</.button>

    <.button disabled variant="inverted">inverted</.button>

    <.button disabled variant="shadow">shadow</.button>

    <.button disabled variant="inverted_gradient">gradient</.button>

    <.button disabled variant="outline_gradient">gradient</.button>

    <.button disabled variant="default_gradient">gradient</.button>

    <.button disabled variant="outline">outline</.button>

    <.button disabled variant="transparent">Transparent</.button>

    <.button disabled variant="subtle">Subtle</.button>
    """
  end

  defp code_string(20) do
    """
    <.button size="extra_small">Extra Small</.button>

    <.button size="small">Small</.button>

    <.button size="medium">Medium</.button>

    <.button size="large">Large</.button>

    <.button size="extra_large">Extra Large</.button>
    """
  end

  defp code_string(21) do
    """
    <.button font_weight="font-bold">Bold</.button>

    <.button font_weight="font-semibold">Semibold</.button>

    <.button font_weight="font-medium">Medium</.button>

    <.button font_weight="font-thin">Silver</.button>

    <.button font_weight="font-black">Black</.button>
    """
  end

  defp code_string(22) do
    """
    <.button variant="bordered" color="natural">Natural</.button>

    <.button variant="bordered" color="primary">Primary</.button>

    <.button variant="bordered" color="secondary">Secondary</.button>

    <.button variant="bordered" color="success">Success</.button>

    <.button variant="bordered" color="warning">Warning</.button>

    <.button variant="bordered" color="danger">Danger</.button>

    <.button variant="bordered" color="info">Info</.button>

    <.button variant="bordered" color="silver">Silver</.button>

    <.button variant="bordered" color="misc">Misc</.button>

    <.button variant="bordered" color="dawn">Dawn</.button>
    """
  end

  defp code_string(23) do
    """
    <.button size="extra_small" full_width>Natural</.button>
    """
  end

  defp code_string(24) do
    """
    <.button>
      <:loading>
        <.spinner />
      </:loading>
    </.button>

    <.button variant="outline" color="dawn">
      <:loading position="end" color="dawn">
        <.spinner />
      </:loading>
    </.button>

    <.button_link navigate="/" variant="inverted" color="misc">
      <:loading position="end">
        <.spinner />
      </:loading>
    </.button_link>
    """
  end

  defp code_string(25) do
    """
    <.button>Base</.button>
    """
  end

  defp code_string(26) do
    """
    <.button line_height="leading-6">Leading 6</.button>
    <.button line_height="leading-7">Leading 7</.button>
    <.button line_height="leading-8">Leading 8</.button>
    """
  end

  defp component_config() do
    [
      name: "button",
      args: [
        variant: [
          "base",
          "default",
          "outline",
          "transparent",
          "subtle",
          "shadow",
          "inverted",
          "bordered",
          "default_gradient",
          "outline_gradient",
          "inverted_gradient"
        ],
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
          "silver",
          "misc",
          "dawn",
          "transparent"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large", "full"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full", "none"],
        type: ["button_group", "button", "input_button", "button_link", "back"],
        only: ["button_group", "button", "input_button", "button_link", "back"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/button"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Interactive buttons and button groups for Phoenix and Phoenix LiveView, including form input and link buttons to boost user engagement.",
      keywords:
        "phoenix button component, button component, liveview button component, elixir, liveview, mishka chelekom button component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Button - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Button - Chelekom Phoenix & LiveView component",
      og_title: "Button - Chelekom Phoenix & LiveView component",
      og_description:
        "Interactive buttons and button groups for Phoenix and Phoenix LiveView, including form input and link buttons to boost user engagement.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Button - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Interactive buttons and button groups for Phoenix and Phoenix LiveView, including form input and link buttons to boost user engagement."
    }
  end
end
