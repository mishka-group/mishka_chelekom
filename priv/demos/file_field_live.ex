defmodule MishkaWeb.ChelekomLive.Docs.FileLive do
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
      |> assign(
        page_title: "Form file upload and dropzone - Chelekom Phoenix & LiveView component"
      )
      |> assign(seo_tags: seo_tags())
      |> assign(:form, to_form(init_form))
      |> assign(:uploaded_files, [])
      |> allow_upload(:avatar,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 3,
        max_file_size: 250_000
      )
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))
      |> assign(code_5: code_string(5))
      |> assign(code_6: code_string(6))

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
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"user" => user_params}, socket) do
    changeset = User.changeset(%User{}, user_params)

    case Ecto.Changeset.apply_action(changeset, :update) do
      {:ok, _user} ->
        reset_changeset = User.changeset(%User{}, %{})

        uploaded_files =
          consume_uploaded_entries(socket, :avatar, fn %{path: _path}, _entry ->
            # dest = Path.join([:code.priv_dir(:mishka), "static", "uploads", Path.basename(path)])
            # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
            # File.cp!(path, dest)
            {:ok, "File discarded after processing"}
          end)

        new_socket =
          socket
          |> update(:uploaded_files, &(&1 ++ uploaded_files))
          |> assign(form: to_form(reset_changeset))
          |> put_flash(:info, "The User concerned is updated successfully")

        {:noreply, new_socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp code_string(1) do
    """
    <.file_field color="base" />
    <.file_field color="danger" />
    <.file_field color="warning" />
    <.file_field color="success" />
    <.file_field color="primary" />
    <.file_field color="secondary" />
    <.file_field color="info" />
    <.file_field color="misc" />
    <.file_field color="dawn" />
    <.file_field color="light" />
    <.file_field color="dark" />
    """
  end

  defp code_string(2) do
    """
    <.file_field dropzone />

    <.file_field target={:avatar} uploads={@uploads} dropzone />
    """
  end

  defp code_string(3) do
    """
    <.file_field color="white" variant="outline" dropzone />
    <.file_field color="primary" variant="outline" dropzone />
    <.file_field color="secondary" variant="outline" dropzone />
    <.file_field color="dark" variant="outline" dropzone />
    <.file_field color="success" variant="outline" dropzone />
    <.file_field color="warning" variant="outline" dropzone />
    <.file_field color="danger" variant="outline" dropzone />
    <.file_field color="info" variant="outline" dropzone />
    <.file_field color="light" variant="outline" dropzone />
    <.file_field color="misc" variant="outline" dropzone />
    <.file_field color="dawn" variant="outline" dropzone />

    <.file_field color="white" variant="default" dropzone />
    <.file_field color="primary" variant="default" dropzone />
    <.file_field color="secondary" variant="default" dropzone />
    <.file_field color="dark" variant="default" dropzone />
    <.file_field color="success" variant="default" dropzone />
    <.file_field color="warning" variant="default" dropzone />
    <.file_field color="danger" variant="default" dropzone />
    <.file_field color="info" variant="default" dropzone />
    <.file_field color="light" variant="default" dropzone />
    <.file_field color="misc" variant="default" dropzone />
    <.file_field color="dawn" variant="default" dropzone />

    <.file_field color="white" variant="shadow" dropzone />
    <.file_field color="primary" variant="shadow" dropzone />
    <.file_field color="secondary" variant="shadow" dropzone />
    <.file_field color="dark" variant="shadow" dropzone />
    <.file_field color="success" variant="shadow" dropzone />
    <.file_field color="warning" variant="shadow" dropzone />
    <.file_field color="danger" variant="shadow" dropzone />
    <.file_field color="info" variant="shadow" dropzone />
    <.file_field color="light" variant="shadow" dropzone />
    <.file_field color="misc" variant="shadow" dropzone />
    <.file_field color="dawn" variant="shadow" dropzone />

    <.file_field color="base" variant="base" dropzone />
    """
  end

  defp code_string(4) do
    """
    <!--Default is type file-->
    <.file_field dropzone dropzone_type="file" />

    <.file_field dropzone dropzone_type="image" />
    """
  end

  defp code_string(5) do
    """
    <.file_field
      dropzone
      dropzone_type="image"
      dropzone_icon="hero-upload"
      dropzone_title="Upload your documents here"
      dropzone_description="Supports PDF files up to 10MB"
    />
    """
  end

  defp code_string(6) do
    """
    <.file_field multiple />
    """
  end

  defp component_config() do
    [
      name: "file_field",
      args: [
        variant: ["default", "outline", "bordered", "shadow", "gradient", "transparent"],
        color: [
          "natural",
          "white",
          "primary",
          "secondary",
          "dark",
          "success",
          "warning",
          "danger",
          "info",
          "misc",
          "dawn",
          "silver"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["file_field"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: ["spinner", "progress"]
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms/file-field"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/forms-#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Form file upload and dropzone component for Phoenix and Phoenix LiveView with floating labels and seamless drag-and-drop functionality.",
      keywords:
        "phoenix form file component, form file component, liveview form file component, elixir, liveview, mishka chelekom form file component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Form file upload and dropzone - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Form file upload and dropzone - Chelekom Phoenix & LiveView component",
      og_title: "Form file upload and dropzone - Chelekom Phoenix & LiveView component",
      og_description:
        "Form file upload and dropzone component for Phoenix and Phoenix LiveView with floating labels and seamless drag-and-drop functionality.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Form file upload and dropzone - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Form file upload and dropzone component for Phoenix and Phoenix LiveView with floating labels and seamless drag-and-drop functionality."
    }
  end
end
