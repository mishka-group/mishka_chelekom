defmodule MishkaWeb.ChelekomLive.Docs.SpinnerLive do
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
      |> assign(page_title: "Spinner - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <!--Default type is type="default", ther is no need to specify it-->
    <.spinner />
    <.spinner type="bars" />
    <.spinner type="dots" />
    <.spinner type="pinging" />
    """
  end

  defp code_string(2) do
    """
    <.spinner color="base" />
    <.spinner color="natural" />
    <.spinner color="white" />
    <.spinner color="dark" />
    <.spinner color="primary" />
    <.spinner color="secondary" />
    <.spinner color="success" />
    <.spinner color="warning" />
    <.spinner color="danger" />
    <.spinner color="info" />
    <.spinner color="silver" />
    <.spinner color="misc" />
    <.spinner color="dawn" />
    """
  end

  defp code_string(3) do
    """
    <.spinner color="info" size="extra_small" />
    <.spinner color="info" size="small" />
    <.spinner color="info" size="medium" />
    <.spinner color="info" size="large" />
    <.spinner color="info" size="extra_large" />
    <.spinner color="info" size="double_large" />
    <.spinner color="info" size="triple_large" />
    <.spinner color="info" size="quadruple_large" />
    """
  end

  defp component_config() do
    [
      name: "spinner",
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
        type: ["default", "pinging", "dots", "bars"],
        only: ["spinner"],
        helper: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/spinner"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Flexible spinner component for Phoenix and LiveView applications, offering visual cues for loading states with adjustable size, color, and style.",
      keywords:
        "phoenix spinner component, spinner component, liveview spinner component, elixir, liveview, mishka chelekom spinner component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Spinner - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Spinner - Chelekom Phoenix & LiveView component",
      og_title: "Spinner - Chelekom Phoenix & LiveView component",
      og_description:
        "Flexible spinner component for Phoenix and LiveView applications, offering visual cues for loading states with adjustable size, color, and style.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Spinner - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Flexible spinner component for Phoenix and LiveView applications, offering visual cues for loading states with adjustable size, color, and style."
    }
  end
end
