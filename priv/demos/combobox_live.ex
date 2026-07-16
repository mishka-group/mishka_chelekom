defmodule MishkaWeb.ChelekomLive.Docs.ComboboxLive do
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
      |> assign(page_title: "Combobox - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(:form, to_form(init_form))
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
      |> assign(code_11: code_string(11))
      |> assign(code_12: code_string(12))
      |> assign(code_13: code_string(13))
      |> assign(code_14: code_string(14))
      |> assign(code_15: code_string(15))
      |> assign(:creatable_languages, [
        {"Elixir", "elixir"},
        {"JavaScript", "javascript"},
        {"Python", "python"},
        {"Rust", "rust"},
        {"Go", "go"},
        {"TypeScript", "typescript"},
        {"Ruby", "ruby"},
        {"Java", "java"}
      ])

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

  @impl Phoenix.LiveView
  def handle_event("add_language", %{"value" => "error"}, socket) do
    {:reply, %{error: "This value is not allowed"}, socket}
  end

  def handle_event("add_language", %{"value" => value}, socket) do
    {:reply, %{value: value, label: value}, socket}
  end

  def radio_card_icons(icon) do
    %{
      "frontend" => "hero-academic-cap",
      "backend" => "hero-cog-6-tooth",
      "designer" => "hero-lifebuoy"
    }[icon]
  end

  defp code_string(1) do
    """
    <.combobox>
      <:option value="ca">Canada</:option>
      <:option value="us">United States</:option>
      <:option value="mx">Mexico</:option>
      <:option value="sp">Spain</:option>
      <:option value="de">Germany</:option>
      <:option value="jp">Japan</:option>
      <:option value="ch">China</:option>
      <:option value="sw">Sweden</:option>
    </.combobox>
    """
  end

  defp code_string(2) do
    """
    <.combobox variant="default"></.combobox> //natural
    <.combobox variant="default" color="primary"></.combobox>
    <.combobox variant="default" color="secondary"></.combobox>
    <.combobox variant="default" color="misc"></.combobox>
    <.combobox variant="default" color="dawn"></.combobox>
    <.combobox variant="default" color="info"></.combobox>
    <.combobox variant="default" color="danger"></.combobox>
    <.combobox variant="default" color="success"></.combobox>
    <.combobox variant="default" color="warning"></.combobox>
    <.combobox variant="default" color="silver"></.combobox>
    """
  end

  defp code_string(3) do
    """
    <.combobox variant="bordered"></.combobox> //natural
    <.combobox variant="bordered" color="primary"></.combobox>
    <.combobox variant="bordered" color="secondary"></.combobox>
    <.combobox variant="bordered" color="misc"></.combobox>
    <.combobox variant="bordered" color="dawn"></.combobox>
    <.combobox variant="bordered" color="info"></.combobox>
    <.combobox variant="bordered" color="danger"></.combobox>
    <.combobox variant="bordered" color="success"></.combobox>
    <.combobox variant="bordered" color="warning"></.combobox>
    <.combobox variant="bordered" color="silver"></.combobox>
    """
  end

  defp code_string(4) do
    """
    <.combobox label="This is label"></.combobox>
    """
  end

  defp code_string(5) do
    """
    <.combobox description="This is description"></.combobox>
    """
  end

  defp code_string(6) do
    """
    <.combobox rounded="extra_small"></.combobox>
    <.combobox rounded="small"></.combobox>
    <.combobox rounded="medium"></.combobox>
    <.combobox rounded="large"></.combobox>
    <.combobox rounded="extra_large"></.combobox>
    """
  end

  defp code_string(7) do
    """
    <.combobox border="extra_small"></.combobox>
    <.combobox border="small"></.combobox>
    <.combobox border="medium"></.combobox>
    <.combobox border="large"></.combobox>
    <.combobox border="extra_large"></.combobox>
    """
  end

  defp code_string(8) do
    """
    <.combobox padding="extra_small"></.combobox>
    <.combobox padding="small"></.combobox>
    <.combobox padding="medium"></.combobox>
    <.combobox padding="large"></.combobox>
    <.combobox padding="extra_large"></.combobox>
    """
  end

  defp code_string(9) do
    """
    <.combobox size="extra_small"></.combobox>
    <.combobox size="small"></.combobox>
    <.combobox size="medium"></.combobox>
    <.combobox size="large"></.combobox>
    <.combobox size="extra_large"></.combobox>
    """
  end

  defp code_string(10) do
    """
    <.combobox searchable></.combobox>
    """
  end

  defp code_string(11) do
    """
    <.combobox searchable search_placeholder="Searrrch"></.combobox>
    """
  end

  defp code_string(12) do
    """
    <.combobox>
        <:option group="Group 1">Sedan</:option>
        <:option group="Group 1" value=""></:option>
        <:option group="Group 1" value=""></:option>
        <:option group="Group 1" value=""></:option>

        <:option group="Group 2" value=""></:option>
        <:option group="Group 2" value=""></:option>
        <:option group="Group 2" value=""></:option>
        <:option group="Group 2" value=""></:option>

        <:option group="Group 3" value=""></:option>
        <:option group="Group 3" value=""></:option>
        <:option group="Group 3" value=""></:option>
      </.combobox>
    """
  end

  defp code_string(13) do
    """
    <.combobox muktiple={true}>
      <.option>Sedan</.option>
      <.option value=""></.option>
      <.option value=""></.option>
      <.option value=""></.option>
    </.combobox>
    """
  end

  defp code_string(14) do
    """
    <.combobox space="extra_small"></.combobox>
    <.combobox space="small"></.combobox>
    <.combobox space="medium"></.combobox>
    <.combobox space="large"></.combobox>
    <.combobox space="extra_large"></.combobox>
    """
  end

  defp code_string(15) do
    """
    <.combobox
      id="language-select"
      options={@creatable_languages}
      placeholder="Select a language"
      searchable
      creatable
      create_label="Add"
      on_create="add_language"
    />

    # In your LiveView — reject by pattern matching:
    def handle_event("add_language", %{"value" => "error"}, socket) do
      {:reply, %{error: "This value is not allowed"}, socket}
    end

    # Accept (optionally modify value/label):
    def handle_event("add_language", %{"value" => value}, socket) do
      {:reply, %{value: value, label: value}, socket}
    end
    """
  end

  defp component_config() do
    [
      name: "combobox",
      args: [
        variant: ["default", "bordered", "base"],
        color: [
          "base",
          "natural",
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
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        space: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        padding: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["combobox"],
        helpers: [combobox_check: 3],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/combobox"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Interactive searchable combobox component for Phoenix LiveView with real-time filtering and keyboard navigation",
      keywords:
        "phoenix Interactive searchable combobox component for Phoenix LiveView with real-time filtering and keyboard navigation",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form Combobox - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form Combobox - Chelekom Phoenix & LiveView component",
      og_title: "Form Combobox - Chelekom Phoenix & LiveView component",
      og_description:
        "Interactive searchable combobox component for Phoenix LiveView with real-time filtering and keyboard navigation",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form Combobox - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Interactive searchable combobox component for Phoenix LiveView with real-time filtering and keyboard navigation"
    }
  end
end
