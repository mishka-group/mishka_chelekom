defmodule MishkaWeb.ChelekomLive.Docs.CheckboxLive do
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
    CustomBlock,
    CustomInlineCode
  }

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    init_form = User.changeset(%User{}, %{})

    socket =
      socket
      |> assign(page_title: "Form checkbox field - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(:form, to_form(init_form))
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))
      |> assign(code_5: code_string(5))
      |> assign(code_6: code_string(6))
      |> assign(code_7: code_string(7))

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
    <.checkbox_field color="base" />
    <.checkbox_field color="white" />
    <.checkbox_field color="primary" />
    <.checkbox_field color="secondary" />
    <.checkbox_field color="dark" />
    <.checkbox_field color="success" />
    <.checkbox_field color="warning" />
    <.checkbox_field color="danger" />
    <.checkbox_field color="info" />
    <.checkbox_field color="light" />
    <.checkbox_field color="misc" />
    <.checkbox_field color="dawn" />
    """
  end

  defp code_string(2) do
    """
    <.checkbox_field label_class="your_classes" />
    """
  end

  defp code_string(3) do
    """
    <.checkbox_field reverse />
    <.checkbox_field />
    """
  end

  defp code_string(4) do
    """
    <.checkbox_field checked />
    """
  end

  defp code_string(5) do
    """
    <.checkbox_field multiple />
    """
  end

  defp code_string(6) do
    """
    <.group_checkbox id="" variation="horizontal" name="" space="large" color="danger">
      <:checkbox value="10">Label of item 1 in group</:checkbox>
      <:checkbox value="30">Label of item 2 in group</:checkbox>
      <:checkbox value="50">Label of item 3 in group</:checkbox>
      <:checkbox value="60" checked={true}>Label of item 4 in group</:checkbox>
    </.group_checkbox>

    <!--Default is vertical variation-->
    <.group_checkbox id="" name="" space="large" color="info">
      <:checkbox value="10">Label of item 1 in group</:checkbox>
      <:checkbox value="30">Label of item 2 in group</:checkbox>
      <:checkbox value="50">Label of item 3 in group</:checkbox>
      <:checkbox value="60" checked={true}>Label of item 4 in group</:checkbox>
    </.group_checkbox>
    """
  end

  defp code_string(7) do
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

        <.h3>What is your hobbies?</.h3>

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

        <hr />

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

  defp component_config() do
    [
      name: "checkbox_field",
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
        rounded: ["extra_small", "small", "medium", "large", "extra_large"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        type: ["checkbox_field", "group_checkbox"],
        only: ["checkbox_field", "group_checkbox"],
        helpers: [checkbox_check: 3],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/checkbox-field"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Form checkbox component for Phoenix and Phoenix LiveView, featuring floating labels and versatile input styles.",
      keywords:
        "phoenix checkbox component, checkbox component, liveview checkbox component, elixir, liveview, mishka chelekom form field component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form checkbox field - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form checkbox field - Chelekom Phoenix & LiveView component",
      og_title: "Form checkbox field - Chelekom Phoenix & LiveView component",
      og_description:
        "Form checkbox component for Phoenix and Phoenix LiveView, featuring floating labels and versatile input styles.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form checkbox field - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Form checkbox component for Phoenix and Phoenix LiveView, featuring floating labels and versatile input styles."
    }
  end
end
