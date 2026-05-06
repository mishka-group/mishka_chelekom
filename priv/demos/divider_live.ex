defmodule MishkaWeb.ChelekomLive.Docs.DividerLive do
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
      |> assign(page_title: "Divider - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.divider />

    <.hr />
    """
  end

  defp code_string(2) do
    """
    <.divider type="dashed" />
    <.divider type="dotted" />
    <.divider type="solid" />

    <.hr type="dashed" />
    <.hr type="dotted" />
    <.hr type="solid" />
    """
  end

  defp code_string(3) do
    """
    <.divider color="base" />
    <.divider color="primary" />
    <.divider color="white" />
    <.divider color="dark" />
    <.divider color="secondary" />
    <.divider color="success" />
    <.divider color="danger" />
    <.divider color="info" />
    <.divider color="misc" />
    <.divider color="dawn" />
    <.divider color="silver" />
    <.divider color="natural" />
    """
  end

  defp code_string(4) do
    """
    <.divider size="extra_small" />
    <.divider size="small" />
    <.divider size="medium" />
    <.divider size="large" />
    <.divider size="extra_large" />
    """
  end

  defp code_string(5) do
    """
    <.divider width="half" />
    <.divider width="full" />
    """
  end

  defp code_string(6) do
    """
    <!--Both horizontal and vertical <.divider/> and <.hr/> has support margin-->

    <.divider margin="extra_small" />
    <.divider margin="small" />
    <.divider margin="medium" />
    <.divider margin="large" />
    <.divider margin="extra_large" />
    <.divider margin="none" />
    """
  end

  defp code_string(7) do
    """
    <.divider variation="horizontal" />
    <.divider margin="vertical" />
    """
  end

  defp code_string(8) do
    """
    <.divider variation="vertical" height="h-full" />
    <.divider variation="vertical" color="natural" height="half" />
    <.divider variation="vertical" height="h-1/3" />
    """
  end

  defp code_string(9) do
    """
    <.divider type="dashed" size="small" color="silver">
      <:text position="right">Or</:text>
    </.divider>

    <.divider size="small" color="success">
      <:text position="left">Or</:text>
    </.divider>

    <.divider type="dotted" size="small" color="warning">
      <:text position="middle">Or</:text>
    </.divider>
    """
  end

  defp code_string(10) do
    """
    <.divider type="dashed" size="small" color="danger">
    <:icon position="right" name="hero-circle-stack" />
    </.divider>

    <.divider size="small" color="misc">
      <:icon position="left" name="hero-star" />
    </.divider>

    <.divider type="dotted" size="small" color="dawn">
      <:icon position="middle" name="hero-at-symbol" />
    </.divider>
    """
  end

  defp component_config() do
    [
      name: "divider",
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
        type: ["divider", "hr"],
        only: ["divider", "hr"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/divider"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Phoenix LiveView divider component supporting customizable horizontal and vertical dividers, with options for icons and text directly on the line.",
      keywords:
        "phoenix divider component, divider component, liveview divider component, elixir, liveview, mishka chelekom divider component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Divider - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Divider - Chelekom Phoenix & LiveView component",
      og_title: "Divider - Chelekom Phoenix & LiveView component",
      og_description:
        "Phoenix LiveView divider component supporting customizable horizontal and vertical dividers, with options for icons and text directly on the line.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Divider - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Phoenix LiveView divider component supporting customizable horizontal and vertical dividers, with options for icons and text directly on the line."
    }
  end
end
