defmodule MishkaWeb.ChelekomLive.Docs.FieldsetLive do
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
      |> assign(page_title: "Form fieldset - Chelekom Phoenix & LiveView component")
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
    <.fieldset space="medium" color="warning">
      <:control>
        <.checkbox_field
          name="example"
          label="Fieldset group of checkboxes"
        />
      </:control>
      <:control>
        <.checkbox_field
          name="example"
          label="Fieldset group of checkboxes"
        />
      </:control>
      <:control>
        <.checkbox_field
          name="example"
          label="Fieldset group of checkboxes"
          checked
        />
      </:control>
    </.fieldset>
    """
  end

  defp code_string(2) do
    """
    <.fieldset legend="Lable">
      <:control>
        <.checkbox_field
          name="example"
          label="Fieldset group of checkboxes"
        />
      </:control>
      <:control>
        <.checkbox_field
          name="example"
          label="Fieldset group of checkboxes"
        />
      </:control>
      <:control>
        <.checkbox_field
          name="example"
          label="Fieldset group of checkboxes"
          checked
        />
      </:control>
    </.fieldset>
    """
  end

  defp component_config() do
    [
      name: "fieldset",
      args: [
        variant: ["default", "outline", "unbordered", "shadow", "transparent", "gradient", "base"],
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
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        padding: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full"],
        only: ["fieldset"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/fieldset"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Fieldset component for Phoenix and Phoenix LiveView with customizable grouping and enhanced form organization.",
      keywords:
        "phoenix fieldset component, fieldset component, liveview fieldset component, elixir, liveview, mishka chelekom fieldset component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form fieldset - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form fieldset - Chelekom Phoenix & LiveView component",
      og_title: "Form fieldset - Chelekom Phoenix & LiveView component",
      og_description:
        "Fieldset component for Phoenix and Phoenix LiveView with customizable grouping and enhanced form organization.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form fieldset - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Fieldset component for Phoenix and Phoenix LiveView with customizable grouping and enhanced form organization."
    }
  end
end
