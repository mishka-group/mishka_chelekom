defmodule MishkaWeb.ChelekomLive.Docs.CheckboxCardLive do
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
    CustomInlineCode
  }

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    init_form = User.changeset(%User{}, %{})

    socket =
      socket
      |> assign(page_title: "Checkbox card - Chelekom Phoenix & LiveView component")
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
      |> assign(code_16: code_string(16))
      |> assign(code_17: code_string(17))

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

  def radio_card_icons(icon) do
    %{
      "frontend" => "hero-academic-cap",
      "backend" => "hero-cog-6-tooth",
      "designer" => "hero-lifebuoy"
    }[icon]
  end

  defp code_string(1) do
    """
    <.checkbox_card name="id="uniqu_naem"" id="uniqu_id">
      <:checkbox value="" title="8-core CPU" description="32 GB RAM"></:checkbox>
      <:checkbox value="" title="6-core CPU" description="24 GB RAM"></:checkbox>
      <:checkbox value="" title="4-core CPU" description="16 GB RAM"></:checkbox>
    </.checkbox_card>
    """
  end

  defp code_string(2) do
    """
    <.checkbox_card name="" variant="default" color="natural"></.checkbox_card>
    <.checkbox_card name="" variant="default" color="primary"></.checkbox_card>
    <.checkbox_card name="" variant="default" color="secondary"></.checkbox_card>
    <.checkbox_card name="" variant="default" color="success"></.checkbox_card>
    <.checkbox_card name="" variant="default" color="danger"></.checkbox_card>
    <.checkbox_card name="" variant="default" color="warning"></.checkbox_card>
    <.checkbox_card name="" variant="default" color="misc"></.checkbox_card>
    <.checkbox_card name="" variant="default" color="dawn"></.checkbox_card>
    <.checkbox_card name="" variant="default" color="silver"></.checkbox_card>
    <.checkbox_card name="" variant="default" color="info"></.checkbox_card>
    <.checkbox_card name="" variant="default" color="dark"></.checkbox_card>
    <.checkbox_card name="" variant="default" color="white"></.checkbox_card>
    """
  end

  defp code_string(3) do
    """
    <.checkbox_card name="" variant="outline" color="natural"></.checkbox_card>
    <.checkbox_card name="" variant="outline" color="primary"></.checkbox_card>
    <.checkbox_card name="" variant="outline" color="secondary"></.checkbox_card>
    <.checkbox_card name="" variant="outline" color="success"></.checkbox_card>
    <.checkbox_card name="" variant="outline" color="danger"></.checkbox_card>
    <.checkbox_card name="" variant="outline" color="warning"></.checkbox_card>
    <.checkbox_card name="" variant="outline" color="misc"></.checkbox_card>
    <.checkbox_card name="" variant="outline" color="dawn"></.checkbox_card>
    <.checkbox_card name="" variant="outline" color="silver"></.checkbox_card>
    <.checkbox_card name="" variant="outline" color="info"></.checkbox_card>
    """
  end

  defp code_string(4) do
    """
    <.checkbox_card name="" variant="shadow" color="natural"></.checkbox_card>
    <.checkbox_card name="" variant="shadow" color="primary"></.checkbox_card>
    <.checkbox_card name="" variant="shadow" color="secondary"></.checkbox_card>
    <.checkbox_card name="" variant="shadow" color="success"></.checkbox_card>
    <.checkbox_card name="" variant="shadow" color="danger"></.checkbox_card>
    <.checkbox_card name="" variant="shadow" color="warning"></.checkbox_card>
    <.checkbox_card name="" variant="shadow" color="misc"></.checkbox_card>
    <.checkbox_card name="" variant="shadow" color="dawn"></.checkbox_card>
    <.checkbox_card name="" variant="shadow" color="silver"></.checkbox_card>
    <.checkbox_card name="" variant="shadow" color="info"></.checkbox_card>
    """
  end

  defp code_string(5) do
    """
    <.checkbox_card name="" variant="bordered" color="natural"></.checkbox_card>
    <.checkbox_card name="" variant="bordered" color="primary"></.checkbox_card>
    <.checkbox_card name="" variant="bordered" color="secondary"></.checkbox_card>
    <.checkbox_card name="" variant="bordered" color="success"></.checkbox_card>
    <.checkbox_card name="" variant="bordered" color="danger"></.checkbox_card>
    <.checkbox_card name="" variant="bordered" color="warning"></.checkbox_card>
    <.checkbox_card name="" variant="bordered" color="misc"></.checkbox_card>
    <.checkbox_card name="" variant="bordered" color="dawn"></.checkbox_card>
    <.checkbox_card name="" variant="bordered" color="silver"></.checkbox_card>
    <.checkbox_card name="" variant="bordered" color="info"></.checkbox_card>
    <.checkbox_card name="" variant="bordered" color="white"></.checkbox_card>
    <.checkbox_card name="" variant="bordered" color="dark"></.checkbox_card>
    """
  end

  defp code_string(6) do
    """
    <.checkbox_card name="" rounded="extra_small" ></.checkbox_card>
    <.checkbox_card name="" rounded="small" ></.checkbox_card>
    <.checkbox_card name="" rounded="medium" ></.checkbox_card>
    <.checkbox_card name="" rounded="large" ></.checkbox_card>
    <.checkbox_card name="" rounded="extra_large" ></.checkbox_card>
    """
  end

  defp code_string(7) do
    """
    <.checkbox_card name="" border="extra_small" ></.checkbox_card>
    <.checkbox_card name="" border="small" ></.checkbox_card>
    <.checkbox_card name="" border="medium" ></.checkbox_card>
    <.checkbox_card name="" border="large" ></.checkbox_card>
    <.checkbox_card name="" border="extra_large" ></.checkbox_card>
    """
  end

  defp code_string(8) do
    """
    <.checkbox_card name="" space="extra_small" ></.checkbox_card>
    <.checkbox_card name="" space="small" ></.checkbox_card>
    <.checkbox_card name="" space="medium" ></.checkbox_card>
    <.checkbox_card name="" space="large" ></.checkbox_card>
    <.checkbox_card name="" space="extra_large" ></.checkbox_card>
    """
  end

  defp code_string(9) do
    """
    <.checkbox_card name="" padding="extra_small" ></.checkbox_card>
    <.checkbox_card name="" padding="small" ></.checkbox_card>
    <.checkbox_card name="" padding="medium" ></.checkbox_card>
    <.checkbox_card name="" padding="large" ></.checkbox_card>
    <.checkbox_card name="" padding="extra_large" ></.checkbox_card>
    """
  end

  defp code_string(10) do
    """
    <.checkbox_card name="" size="extra_small" ></.checkbox_card>
    <.checkbox_card name="" size="small" ></.checkbox_card>
    <.checkbox_card name="" size="medium" ></.checkbox_card>
    <.checkbox_card name="" size="large" ></.checkbox_card>
    <.checkbox_card name="" size="extra_large" ></.checkbox_card>
    """
  end

  defp code_string(11) do
    """
    <.checkbox_card cols="one"></.checkbox_card>
    <.checkbox_card cols="two"></.checkbox_card>
    <.checkbox_card cols="three"></.checkbox_card>
    <.checkbox_card cols="four"></.checkbox_card>
    <.checkbox_card cols="five"></.checkbox_card>
    <.checkbox_card cols="six"></.checkbox_card>
    <.checkbox_card cols="seven"></.checkbox_card>
    <.checkbox_card cols="eight"></.checkbox_card>
    <.checkbox_card cols="nine"></.checkbox_card>
    <.checkbox_card cols="ten"></.checkbox_card>
    <.checkbox_card cols="eleven"></.checkbox_card>
    <.checkbox_card cols="twelve"></.checkbox_card>
    """
  end

  defp code_string(12) do
    """
    <.checkbox_card cols_gap="extra_small"></.checkbox_card>
    <.checkbox_card cols_gap="small"></.checkbox_card>
    <.checkbox_card cols_gap="medium"></.checkbox_card>
    <.checkbox_card cols_gap="large"></.checkbox_card>
    <.checkbox_card cols_gap="extra_large"></.checkbox_card>
    """
  end

  defp code_string(13) do
    """
    <.checkbox_card show_checkbox></.checkbox_card>
    """
  end

  defp code_string(14) do
    """
    <.checkbox_card show_checkbox reverse></.checkbox_card>
    """
  end

  defp code_string(15) do
    """
    <!--All the props of checkbox slot-->
    <.checkbox_card name="" id="" class="text-center">
      <:checkbox value="" checked></:checkbox>
      <!--Use hero icons-->
      <:checkbox icon=""></:checkbox>
      <:checkbox icon_class=""></:checkbox>
      <:checkbox title="This is a title"></:checkbox>
      <:checkbox content_class="text-lg"></:checkbox>
      <:checkbox description="This is a description"></:checkbox>
      <:checkbox>
        <div class="flex flex-col justify-center items-center gap-2 text-md">
          <.icon name="hero-home" class="size-5" />
          <div>Custom content</div>
        </div>
      </:checkbox>
    </.checkbox_card>
    """
  end

  defp code_string(16) do
    """
    <.checkbox_card label="This is label of this group"></.checkbox_card>
    """
  end

  defp code_string(17) do
    """
    <.checkbox_card description="This is a description"></.checkbox_card>
    """
  end

  defp component_config() do
    [
      name: "checkbox_card",
      args: [
        variant: ["default", "outline", "shadow", "bordered", "base"],
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
          "dark",
          "white",
          "dawn"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        space: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        padding: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["checkbox_card"],
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
        "Form checkbox card component for Phoenix LiveView forms. Features customizable styles, multiple variants, responsive design, and supports both single and group selections.",
      keywords:
        "phoenix Form Checkbox card component, Form Checkbox card component, liveview Form Checkbox card component, elixir, liveview, mishka chelekom Form Checkbox card component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form Checkbox card - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form Checkbox card - Chelekom Phoenix & LiveView component",
      og_title: "Form Checkbox card - Chelekom Phoenix & LiveView component",
      og_description:
        "Form checkbox card component for Phoenix LiveView forms. Features customizable styles, multiple variants, responsive design, and supports both single and group selections.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form Checkbox card - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Form checkbox card component for Phoenix LiveView forms. Features customizable styles, multiple variants, responsive design, and supports both single and group selections."
    }
  end
end
