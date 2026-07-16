defmodule MishkaWeb.ChelekomLive.Docs.InputLive do
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
      |> assign(page_title: "Form input - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.input name="name" value="" type="text" label="Full Name" />
    <.input name="add" value="" type="text" label="Adress" />
    <.input name="tel" value="" type="text" label="Phone" />
    <.input name="zip" value="" type="text" label="Zipcode" />
    <.input name="email" value="" label="Email" />

    <.input
      name="job"
      type="select"
      label="Choose your Job"
      value="true"
      options={[
        {"foo", 1},
        {"bar", 2}
      ]}
    />

    <.input
      name="start-houre"
      value=""
      type="datetime-local"
      label="Start office hour"
    />

    <.input
      name="start-day"
      value=""
      type="datetime-local"
      label="Start office day"
    />

    <.input name="" value="" type="checkbox" label="Terms" />

    <.input name="sal" value="" type="range" label="Salary" />
    """
  end

  defp component_config() do
    [
      name: "input_field",
      args: [
        only: ["input_field"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/input-field"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Built-in Phoenix LiveView input component offering a wide range of form field types, seamless real-time updates, and powerful validation features.",
      keywords:
        "phoenix form input component, form input component, liveview form input component, elixir, liveview, mishka chelekom form input component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form input - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form input - Chelekom Phoenix & LiveView component",
      og_title: "Form input - Chelekom Phoenix & LiveView component",
      og_description:
        "Built-in Phoenix LiveView input component offering a wide range of form field types, seamless real-time updates, and powerful validation features.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form input - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Built-in Phoenix LiveView input component offering a wide range of form field types, seamless real-time updates, and powerful validation features."
    }
  end
end
