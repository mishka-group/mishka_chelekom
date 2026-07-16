defmodule MishkaWeb.ChelekomLive.Docs.RangeLive do
  use MishkaWeb, :live_view
  alias Mishka.Docs.Chelekom.User

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

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    init_form = User.changeset(%User{}, %{})

    socket =
      socket
      |> assign(page_title: "Form Range slider - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(:form, to_form(init_form))
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = User.changeset(%User{}, user_params)

    new_socket =
      socket
      |> assign(:form, to_form(changeset, action: :validate))

    {:noreply, new_socket}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"user" => user_params}, socket) do
    changeset = User.changeset(%User{}, user_params)

    case Ecto.Changeset.apply_action(changeset, :update) do
      {:ok, _user} ->
        reset_changeset = User.changeset(%User{}, %{})

        new_socket =
          socket
          |> assign(form: to_form(reset_changeset))
          |> put_flash(:info, "The User concerned is updated successfully")

        {:noreply, new_socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp code_string(1) do
    """
    <!--Default-->
    <.range_field value="10" color="natural" />

    <.range_field value="20" color="danger" />

    <.range_field value="30" color="warning" />

    <.range_field value="40" color="success" />

    <.range_field value="50" color="secondary" />

    <.range_field value="60" color="primary" />

    <.range_field value="70" color="info" />

    <.range_field value="80" color="dawn" />

    <.range_field value="90" color="misc" />

    <.range_field value="100" color="dark" />

    <!--Custome-->

    <.range_field appearance="custom" value="80" color="natural" />

    <.range_field appearance="custom" value="80" color="danger" />

    <.range_field appearance="custom" value="40" color="warning" />

    <.range_field appearance="custom" color="success" />

    <.range_field appearance="custom" color="secondary" />

    <.range_field appearance="custom" color="primary" />

    <.range_field appearance="custom" color="info" />

    <.range_field appearance="custom" color="dawn" />

    <.range_field appearance="custom" color="misc" />

    <.range_field appearance="custom" color="dark" />
    """
  end

  defp code_string(2) do
    """
    <.range_field value="80" />

    <.range_field appearance="custom" value="80" color="danger" step="10" />
    """
  end

  defp code_string(3) do
    """
    <.range_field value="80" step="1" min="0" max="100" />

    <.range_field appearance="custom" value="80" color="danger" step="10" min="0" max="100" />
    """
  end

  defp code_string(4) do
    """
    <.range_field
      appearance="custom"
      value="30"
      color="warning"
      size="small"
      min="100"
      id="mishka-chelekom"
      max="1500"
      name="mishka-chelekom"
      step="2"
    >
      <:range_value position="start">Min ($100)</:range_value>
      <:range_value position="middle">$700</:range_value>
      <:range_value position="end">Max ($1500)</:range_value>
    </.range_field>
    """
  end

  defp component_config() do
    [
      name: "range_field",
      args: [
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
        only: ["range_field"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/range-field"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Range slider component for Phoenix and Phoenix LiveView with floating labels and slots to display minimum, maximum, and average values beneath the slider.",
      keywords:
        "phoenix Range slider component, Range slider component, liveview Range slider component, elixir, liveview, mishka chelekom Range slider component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form Range slider - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form Range slider - Chelekom Phoenix & LiveView component",
      og_title: "Form Range slider - Chelekom Phoenix & LiveView component",
      og_description:
        "Range slider component for Phoenix and Phoenix LiveView with floating labels and slots to display minimum, maximum, and average values beneath the slider.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form Range slider - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Range slider component for Phoenix and Phoenix LiveView with floating labels and slots to display minimum, maximum, and average values beneath the slider."
    }
  end
end
