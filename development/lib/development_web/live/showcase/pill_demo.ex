defmodule DevelopmentWeb.Showcase.PillDemo do
  @moduledoc """
  What a pill is *for*: showing values already chosen. Each pill carries a hidden input in its
  slot, so the selection posts as a real list on submit; its ✕ pushes `remove` with the tag via
  `JS.push(value:)`, since the remove button forwards `on_remove` only. Nothing is persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.Pill

  @available ~w(bug enhancement docs question wontfix good-first-issue)

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(available: @available)
     |> assign_new(:labels, fn -> ["bug", "docs"] end)
     |> assign_new(:posted, fn -> nil end)}
  end

  @impl true
  def handle_event("add", %{"tag" => tag}, socket) do
    labels = socket.assigns.labels

    {:noreply, assign(socket, labels: (tag in labels && labels) || labels ++ [tag], posted: nil)}
  end

  def handle_event("remove", %{"tag" => tag}, socket) do
    {:noreply, assign(socket, labels: List.delete(socket.assigns.labels, tag), posted: nil)}
  end

  def handle_event("save", params, socket) do
    {:noreply, assign(socket, posted: get_in(params, ["pill_demo", "labels"]) || [])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={%{}} as={:pill_demo} id={"#{@id}-pill-form"} phx-target={@myself} phx-submit="save">
        <div class="flex min-h-9 flex-wrap items-center gap-1.5 rounded-md border border-[var(--c-base-300)] p-2">
          <.pill
            :for={tag <- @labels}
            id={"#{@id}-#{tag}"}
            with_remove
            remove_label={"Remove #{tag}"}
            on_remove={JS.push("remove", value: %{tag: tag}, target: @myself)}
            class={pill_class()}
          >
            {tag}<input type="hidden" name="pill_demo[labels][]" value={tag} />
          </.pill>
          <span :if={@labels == []} class="px-1 text-sm text-[var(--c-base-content)]/40">
            No labels — add one below.
          </span>
        </div>

        <div class="mt-2 flex flex-wrap items-center gap-1.5">
          <button
            :for={tag <- @available -- @labels}
            type="button"
            phx-click="add"
            phx-value-tag={tag}
            phx-target={@myself}
            class="rounded-full border border-dashed border-[var(--c-base-300)] px-2.5 py-0.5 text-sm text-[var(--c-base-content)]/60 hover:border-[var(--c-primary)] hover:text-[var(--c-primary)]"
          >
            + {tag}
          </button>
        </div>

        <button
          type="submit"
          class="mt-3 rounded-md border border-[var(--c-base-300)] px-3 py-1.5 text-sm hover:bg-[var(--c-base-200)]"
        >
          Submit
        </button>
      </.form>

      <p class="mt-2 text-xs text-[var(--c-base-content)]/50">
        Posts as <code>pill_demo[labels][]</code>
        — {(@posted && ((@posted == [] && "submitted empty") || Enum.join(@posted, ", "))) ||
          "not submitted yet"}
      </p>
    </div>
    """
  end

  defp pill_class do
    [
      "inline-flex items-center gap-1 rounded-full bg-[var(--c-base-200)] py-0.5 pr-1 pl-2.5 text-sm",
      "[&_[data-part=label]]:leading-none",
      "[&_[data-part=remove]]:inline-flex [&_[data-part=remove]]:size-4 [&_[data-part=remove]]:items-center [&_[data-part=remove]]:justify-center [&_[data-part=remove]]:rounded-full [&_[data-part=remove]]:leading-none [&_[data-part=remove]]:text-[var(--c-base-content)]/50 [&_[data-part=remove]]:hover:bg-[var(--c-base-300)] [&_[data-part=remove]]:hover:text-[var(--c-base-content)]"
    ]
  end
end
