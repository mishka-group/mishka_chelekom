defmodule MishkaWeb.ChelekomLive.Docs.RadioCardLive do
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
      |> assign(page_title: "Form Radio card - Chelekom Phoenix & LiveView component")
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
    <.radio_card name="id="uniqu_naem"" id="uniqu_id">
      <:radio value="" title="8-core CPU" description="32 GB RAM"></:radio>
      <:radio value="" title="6-core CPU" description="24 GB RAM"></:radio>
      <:radio value="" title="4-core CPU" description="16 GB RAM"></:radio>
    </.radio_card>
    """
  end

  defp code_string(2) do
    """
    <.radio_card name="" variant="default" color="natural"></.radio_card>
    <.radio_card name="" variant="default" color="primary"></.radio_card>
    <.radio_card name="" variant="default" color="secondary"></.radio_card>
    <.radio_card name="" variant="default" color="success"></.radio_card>
    <.radio_card name="" variant="default" color="danger"></.radio_card>
    <.radio_card name="" variant="default" color="warning"></.radio_card>
    <.radio_card name="" variant="default" color="misc"></.radio_card>
    <.radio_card name="" variant="default" color="dawn"></.radio_card>
    <.radio_card name="" variant="default" color="silver"></.radio_card>
    <.radio_card name="" variant="default" color="info"></.radio_card>
    <.radio_card name="" variant="default" color="dark"></.radio_card>
    <.radio_card name="" variant="default" color="white"></.radio_card>
    """
  end

  defp code_string(3) do
    """
    <.radio_card name="" variant="outline" color="natural"></.radio_card>
    <.radio_card name="" variant="outline" color="primary"></.radio_card>
    <.radio_card name="" variant="outline" color="secondary"></.radio_card>
    <.radio_card name="" variant="outline" color="success"></.radio_card>
    <.radio_card name="" variant="outline" color="danger"></.radio_card>
    <.radio_card name="" variant="outline" color="warning"></.radio_card>
    <.radio_card name="" variant="outline" color="misc"></.radio_card>
    <.radio_card name="" variant="outline" color="dawn"></.radio_card>
    <.radio_card name="" variant="outline" color="silver"></.radio_card>
    <.radio_card name="" variant="outline" color="info"></.radio_card>
    """
  end

  defp code_string(4) do
    """
    <.radio_card name="" variant="shadow" color="natural"></.radio_card>
    <.radio_card name="" variant="shadow" color="primary"></.radio_card>
    <.radio_card name="" variant="shadow" color="secondary"></.radio_card>
    <.radio_card name="" variant="shadow" color="success"></.radio_card>
    <.radio_card name="" variant="shadow" color="danger"></.radio_card>
    <.radio_card name="" variant="shadow" color="warning"></.radio_card>
    <.radio_card name="" variant="shadow" color="misc"></.radio_card>
    <.radio_card name="" variant="shadow" color="dawn"></.radio_card>
    <.radio_card name="" variant="shadow" color="silver"></.radio_card>
    <.radio_card name="" variant="shadow" color="info"></.radio_card>
    """
  end

  defp code_string(5) do
    """
    <.radio_card name="" variant="bordered" color="natural"></.radio_card>
    <.radio_card name="" variant="bordered" color="primary"></.radio_card>
    <.radio_card name="" variant="bordered" color="secondary"></.radio_card>
    <.radio_card name="" variant="bordered" color="success"></.radio_card>
    <.radio_card name="" variant="bordered" color="danger"></.radio_card>
    <.radio_card name="" variant="bordered" color="warning"></.radio_card>
    <.radio_card name="" variant="bordered" color="misc"></.radio_card>
    <.radio_card name="" variant="bordered" color="dawn"></.radio_card>
    <.radio_card name="" variant="bordered" color="silver"></.radio_card>
    <.radio_card name="" variant="bordered" color="info"></.radio_card>
    <.radio_card name="" variant="bordered" color="white"></.radio_card>
    <.radio_card name="" variant="bordered" color="dark"></.radio_card>
    """
  end

  defp code_string(6) do
    """
    <.radio_card name="" rounded="extra_small" ></.radio_card>
    <.radio_card name="" rounded="small" ></.radio_card>
    <.radio_card name="" rounded="medium" ></.radio_card>
    <.radio_card name="" rounded="large" ></.radio_card>
    <.radio_card name="" rounded="extra_large" ></.radio_card>
    """
  end

  defp code_string(7) do
    """
    <.radio_card name="" border="extra_small" ></.radio_card>
    <.radio_card name="" border="small" ></.radio_card>
    <.radio_card name="" border="medium" ></.radio_card>
    <.radio_card name="" border="large" ></.radio_card>
    <.radio_card name="" border="extra_large" ></.radio_card>
    """
  end

  defp code_string(8) do
    """
    <.radio_card name="" space="extra_small" ></.radio_card>
    <.radio_card name="" space="small" ></.radio_card>
    <.radio_card name="" space="medium" ></.radio_card>
    <.radio_card name="" space="large" ></.radio_card>
    <.radio_card name="" space="extra_large" ></.radio_card>
    """
  end

  defp code_string(9) do
    """
    <.radio_card name="" padding="extra_small" ></.radio_card>
    <.radio_card name="" padding="small" ></.radio_card>
    <.radio_card name="" padding="medium" ></.radio_card>
    <.radio_card name="" padding="large" ></.radio_card>
    <.radio_card name="" padding="extra_large" ></.radio_card>
    """
  end

  defp code_string(10) do
    """
    <.radio_card name="" size="extra_small" ></.radio_card>
    <.radio_card name="" size="small" ></.radio_card>
    <.radio_card name="" size="medium" ></.radio_card>
    <.radio_card name="" size="large" ></.radio_card>
    <.radio_card name="" size="extra_large" ></.radio_card>
    """
  end

  defp code_string(11) do
    """
    <.radio_card cols="one"></.radio_card>
    <.radio_card cols="two"></.radio_card>
    <.radio_card cols="three"></.radio_card>
    <.radio_card cols="four"></.radio_card>
    <.radio_card cols="five"></.radio_card>
    <.radio_card cols="six"></.radio_card>
    <.radio_card cols="seven"></.radio_card>
    <.radio_card cols="eight"></.radio_card>
    <.radio_card cols="nine"></.radio_card>
    <.radio_card cols="ten"></.radio_card>
    <.radio_card cols="eleven"></.radio_card>
    <.radio_card cols="twelve"></.radio_card>
    """
  end

  defp code_string(12) do
    """
    <.radio_card cols_gap="extra_small"></.radio_card>
    <.radio_card cols_gap="small"></.radio_card>
    <.radio_card cols_gap="medium"></.radio_card>
    <.radio_card cols_gap="large"></.radio_card>
    <.radio_card cols_gap="extra_large"></.radio_card>
    """
  end

  defp code_string(13) do
    """
    <.radio_card show_radio></.radio_card>
    """
  end

  defp code_string(14) do
    """
    <.radio_card show_radio reverse></.radio_card>
    """
  end

  defp code_string(15) do
    """
    <!--All the props of radio slot-->
    <.radio_card name="" id="" class="text-center">
      <:radio value="" checked></:radio>
      <!--Use hero icons-->
      <:radio icon=""></:radio>
      <:radio icon_class=""></:radio>
      <:radio title="This is a title"></:radio>
      <:radio content_class="text-lg"></:radio>
      <:radio description="This is a description"></:radio>
      <:radio>
        <div class="flex flex-col justify-center items-center gap-2 text-md">
          <.icon name="hero-home" class="size-5" />
          <div>Custom content</div>
        </div>
      </:radio>
    </.radio_card>
    """
  end

  defp code_string(16) do
    """
    <.radio_card label="This is label of this group"></.radio_card>
    """
  end

  defp code_string(17) do
    """
    <.radio_card description="This is a description"></.radio_card>
    """
  end

  defp component_config() do
    [
      name: "radio_card",
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
        only: ["radio_card"],
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
        "Form radio card component presented as clickable cards. Includes customizable styles, multiple card layouts, and interactive selection patterns for Phoenix and LiveView applications.",
      keywords:
        "phoenix radio card component, radio card form, radio card component, liveview radio card component, elixir, liveview, mishka chelekom radio card component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form Radio card - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form Radio card - Chelekom Phoenix & LiveView component",
      og_title: "Form Radio card - Chelekom Phoenix & LiveView component",
      og_description:
        "Form radio card component presented as clickable cards. Includes customizable styles, multiple card layouts, and interactive selection patterns for Phoenix and LiveView applications.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form Radio card - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Form radio card component presented as clickable cards. Includes customizable styles, multiple card layouts, and interactive selection patterns for Phoenix and LiveView applications."
    }
  end
end
