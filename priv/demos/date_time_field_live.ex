defmodule MishkaWeb.ChelekomLive.Docs.DateTimeLive do
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
      |> assign(page_title: "Date-time form - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.date_time_field />
    """
  end

  defp code_string(2) do
    """
    <!--Date is default type-->
    <.date_time_field type="date" />
    <.date_time_field type="datetime-local" />
    <.date_time_field type="time" />
    <.date_time_field type="week" />
    <.date_time_field type="month" />
    """
  end

  defp component_config() do
    [
      name: "date_time_field",
      args: [
        variant: ["outline", "default", "bordered", "shadow", "transparent", "base"],
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
          "misc",
          "dawn",
          "silver"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["date_time_field"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/date-time-field"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Date-time form component for Phoenix and Phoenix LiveView with floating labels and flexible input options.",
      keywords:
        "phoenix Date-time form component, Date-time form component, liveview Date-time form component, elixir, liveview, mishka chelekom Date-time form component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Date-time form - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Date-time form - Chelekom Phoenix & LiveView component",
      og_title: "Date-time form - Chelekom Phoenix & LiveView component",
      og_description:
        "Date-time form component for Phoenix and Phoenix LiveView with floating labels and flexible input options.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Date-time form - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Date-time form component for Phoenix and Phoenix LiveView with floating labels and flexible input options."
    }
  end
end
