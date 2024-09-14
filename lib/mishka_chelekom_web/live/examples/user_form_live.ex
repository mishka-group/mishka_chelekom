defmodule MishkaChelekomWeb.Examples.UserFormLive do
  use Phoenix.LiveView
  alias MishkaChelekom.User
  import MishkaChelekomWeb.CoreComponents

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    init_form = User.changeset(%User{}, %{})

    new_socket =
      socket
      |> assign(:form, to_form(init_form))
      |> assign(:uploaded_files, [])
      |> allow_upload(:avatar, accept: ~w(.jpg .jpeg), max_entries: 2)

    {:ok, new_socket}
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
      {:ok, user} ->
        uploaded_files =
          consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
            dest =
              Path.join([
                :code.priv_dir(:mishka_chelekom),
                "static",
                "uploads",
                Path.basename(path)
              ])

            # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
            # File.cp!(path, dest)
            {:ok, "/uploads/#{Path.basename(dest)}"}
          end)

        new_socket =
          socket
          |> update(:uploaded_files, &(&1 ++ uploaded_files))
          |> put_flash(:info, "User ::#{user.fullname}:: updated successfully")

        {:noreply, new_socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
