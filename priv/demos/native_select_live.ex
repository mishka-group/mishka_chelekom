defmodule MishkaWeb.ChelekomLive.Docs.NativeSelectLive do
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
      |> assign(page_title: "Form Native select - Chelekom Phoenix & LiveView component")
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
    <.native_select
      name="countries"
      space="small"
      color="danger"
      description="This is description"
      label="This is outline label"
    >
    </.native_select>
    """
  end

  defp code_string(2) do
    """
    <.native_select
      name="countries"
      space="small"
      description="This is description"
      label="This is outline label"
    >
     <:option value="nl" selected>
       NL
     </:option>

     <:option value="usa" disabled>
       USA
     </:option>

     <:option value="uae">
       UAE
     </:option>
    </.native_select>
    """
  end

  defp code_string(3) do
    """
    <.native_select
      multiple
      name="countries"
      space="small"
      description="This is description"
      label="This is outline label"
    >
     <:option value="nl">
       NL
     </:option>

     <:option value="usa">
       USA
     </:option>

     <:option value="uae">
       UAE
     </:option>
    </.native_select>
    """
  end

  defp component_config() do
    [
      name: "native_select",
      args: [
        variant: ["default", "shadow", "bordered", "native", "base"],
        color: [
          "base",
          "white",
          "natural",
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
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full"],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        type: ["native_select", "select_option_group"],
        only: ["native_select", "select_option_group"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/native-select"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Native select component for Phoenix and Phoenix LiveView with seamless dropdown selection.",
      keywords:
        "phoenix form native select component, form native select component, liveview form native select component, elixir, liveview, mishka chelekom form native select component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form Native select - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form Native select - Chelekom Phoenix & LiveView component",
      og_title: "Form Native select - Chelekom Phoenix & LiveView component",
      og_description:
        "Native select component for Phoenix and Phoenix LiveView with seamless dropdown selection.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form Native select - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Native select component for Phoenix and Phoenix LiveView with seamless dropdown selection."
    }
  end
end
