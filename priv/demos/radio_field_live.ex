defmodule MishkaWeb.ChelekomLive.Docs.RadioLive do
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
      |> assign(page_title: "Form radio button - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(:form, to_form(init_form))
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))

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
    <.radio_fieldname="female" value="female" label="female" />

    <.radio_field name="male" value="male" label="Male" checked />
    """
  end

  defp code_string(2) do
    """
    <!--Default variation is vertical-->
    <.group_radio name="" id="" space="small" color="danger">
      <:radio value="option1">Option 1</:radio>
      <:radio value="option2">Option 2</:radio>
      <:radio value="option3">Option 3</:radio>
      <:radio value="option4" checked>Option 4</:radio>
    </.group_radio>

    <.group_radio name="" space="small" variation="horizontal">
      <:radio value="option1">Option 1</:radio>
      <:radio value="option2">Option 2</:radio>
      <:radio value="option3">Option 3</:radio>
      <:radio value="option4" checked>Option 4</:radio>
    </.group_radio>
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

        <.group_radio field={@form[:job]} space="small" variation="horizontal" color="misc">
          <:radio
            :for={item <- Ecto.Enum.values(User, :job)}
            value={"{#item}}"
            checked={radio_check(:list, {:job, {"{#item}"}}, @form)}
          >
            <%= String.capitalize({"{#item}"}) %>
          </:radio>
        </.group_radio>

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

        <.toggle_field
          field={@form[:accepted_terms]}
          label="Terms"
          checked={toggle_check(:accepted_terms, @form)}
          color="primary"
          phx-debounce="300"
        />

        <.radio_field
          field={@form[:subscribe]}
          checked={radio_check(:boolean, :subscribe, @form)}
          label="Subscribe?"
          color="danger"
          value="true"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save User</.button>
        </:actions>
      </.form_wrapper>
    """
  end

  defp component_config() do
    [
      name: "radio_field",
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
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["radio_field", "group_radio"],
        helpers: [radio_check: 3],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/radio-field"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Form radio button component for Phoenix and Phoenix LiveView with floating labels and customizable selection options.",
      keywords:
        "phoenix radio button component, radio button component, liveview radio button component, elixir, liveview, mishka chelekom radio button component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form radio button - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form radio button - Chelekom Phoenix & LiveView component",
      og_title: "Form radio button - Chelekom Phoenix & LiveView component",
      og_description:
        "Form radio button component for Phoenix and Phoenix LiveView with floating labels and customizable selection options.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form radio button - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Form radio button component for Phoenix and Phoenix LiveView with floating labels and customizable selection options."
    }
  end
end
