defmodule DevelopmentWeb.Showcase.PillsInputFormDemo do
  @moduledoc """
  Interactive `pills_input` (composing `pill`) inside a Phoenix `<.form>`: add an email on Enter (the
  form's reset clears the draft — no JS hook), remove via each pill's ✕. The emails submit as
  `pills_demo[emails][]`; clicking the control focuses the input via `JS.focus`. Not persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.PillsInput
  import DevelopmentWeb.Components.Headless.Pill

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:emails, fn -> ["ann@example.com", "ben@example.com"] end)
     |> assign_new(:form, fn -> to_form(%{"email" => ""}, as: :pills_demo) end)}
  end

  @impl true
  def handle_event("add", %{"pills_demo" => %{"email" => email}}, socket) do
    email = String.trim(email)
    emails = socket.assigns.emails
    emails = if email != "" and email not in emails, do: emails ++ [email], else: emails
    {:noreply, assign(socket, emails: emails, form: to_form(%{"email" => ""}, as: :pills_demo))}
  end

  def handle_event("remove", %{"email" => email}, socket) do
    {:noreply, assign(socket, emails: List.delete(socket.assigns.emails, email))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-md">
      <.form for={@form} phx-target={@myself} phx-submit="add">
        <.pills_input
          id={"#{@id}-pi"}
          input_name={@form[:email].name}
          input_value={@form[:email].value}
          placeholder="Add email and press Enter…"
          class={pic()}
        >
          <:pills>
            <.pill
              :for={email <- @emails}
              with_remove
              remove_label={"Remove #{email}"}
              on_remove={JS.push("remove", value: %{email: email}, target: @myself)}
              class={pillc()}
            >
              {email}
            </.pill>
          </:pills>
        </.pills_input>
        <input :for={email <- @emails} type="hidden" name="pills_demo[emails][]" value={email} />
      </.form>
      <p class="mt-2 text-xs text-[var(--c-base-content)]/50">
        Recipients (server): {(@emails == [] && "none") || Enum.join(@emails, ", ")}
      </p>
    </div>
    """
  end

  defp pic do
    "flex flex-wrap items-center gap-1.5 rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-2 py-1.5 text-sm cursor-text focus-within:ring-2 focus-within:ring-[var(--c-primary)]/30 [&_[data-part=input]]:min-w-24 [&_[data-part=input]]:flex-1 [&_[data-part=input]]:border-0 [&_[data-part=input]]:bg-transparent [&_[data-part=input]]:p-0.5 [&_[data-part=input]]:outline-none"
  end

  defp pillc do
    "inline-flex items-center gap-1 rounded-full bg-[var(--c-base-200)] py-0.5 pr-1 pl-2 [&_[data-part=remove]]:inline-flex [&_[data-part=remove]]:size-4 [&_[data-part=remove]]:items-center [&_[data-part=remove]]:justify-center [&_[data-part=remove]]:rounded-full [&_[data-part=remove]]:leading-none [&_[data-part=remove]]:text-[var(--c-base-content)]/50 [&_[data-part=remove]]:hover:bg-[var(--c-base-300)] [&_[data-part=remove]]:hover:text-[var(--c-base-content)]"
  end
end
