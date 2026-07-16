defmodule MishkaWeb.ChelekomLive.Docs.ToggleLive do
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
      |> assign(page_title: "Form toggle switch - Chelekom Phoenix & LiveView component")
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
    <.toggle_field color="base" />
    <.toggle_field color="danger" />
    <.toggle_field color="dark" />
    <.toggle_field color="warning" />
    <.toggle_field color="natural" />
    <.toggle_field color="white" />
    <.toggle_field color="success" />
    <.toggle_field color="silver" />
    <.toggle_field color="misc" />
    <.toggle_field color="dawn" />
    <.toggle_field color="info" />
    <.toggle_field color="primary" />
    <.toggle_field color="secondary" />
    """
  end

  defp code_string(2) do
    """
    <.toggle_field color="primary" />
    <.toggle_field color="secondary" checked={true} />
    """
  end

  defp code_string(3) do
    """
    <.form_wrapper
        for={@form}
        id="user-form"
        phx-change="validate"
        phx-submit="save"
        class="space-y-5"
      >
        <.input label="Full name" field={@form[:fullname]} />

        <.input
          field={@form[:job]}
          type="select"
          label="Choose your Job"
          options={Ecto.Enum.values(User, :job)}
        />

        <.h3>What are your hobbies?</.h3>

        <.group_checkbox variation="horizontal" field={@form[:hobbies]} color="danger">
          <:checkbox
            value="reading"
            checked={checkbox_check(:list, {:hobbies, "reading"}, @form)}
          >
            Reading
          </:checkbox>
          <:checkbox
            value="programming"
            checked={checkbox_check(:list, {:hobbies, "programming"}, @form)}
          >
            Programming
          </:checkbox>
          <:checkbox
            value="photography"
            checked={checkbox_check(:list, {:hobbies, "photography"}, @form)}
          >
            Photography
          </:checkbox>
        </.group_checkbox>

        <.toggle_field
          field={@form[:accepted_terms]}
          label="Terms"
          checked={toggle_check(:accepted_terms, @form)}
          color="primary"
          phx-debounce="300"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save User</.button>
        </:actions>
      </.form_wrapper>
    """
  end

  defp code_string(4) do
    """
    <!--Default is full-->
    <.toggle_field rounded="extra_small" />
    <.toggle_field rounded="small" />
    <.toggle_field rounded="medium" />
    <.toggle_field rounded="large" />
    <.toggle_field rounded="extra_large" />
    <.toggle_field rounded="full" />
    """
  end

  defp component_config() do
    [
      name: "toggle_field",
      args: [
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
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["toggle_field"],
        helpers: [toggle_check: 2],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/toggle"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Toggle switch component for Phoenix and Phoenix LiveView with seamless on/off functionality and customizable styling for intuitive interaction.",
      keywords:
        "phoenix form toggle switch component, form toggle switch component, liveview form toggle switch component, elixir, liveview, mishka chelekom form toggle switch component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form toggle switch - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form toggle switch - Chelekom Phoenix & LiveView component",
      og_title: "Form toggle switch - Chelekom Phoenix & LiveView component",
      og_description:
        "Toggle switch component for Phoenix and Phoenix LiveView with seamless on/off functionality and customizable styling for intuitive interaction.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form toggle switch - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Toggle switch component for Phoenix and Phoenix LiveView with seamless on/off functionality and customizable styling for intuitive interaction."
    }
  end
end
