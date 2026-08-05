defmodule DevelopmentWeb.Showcase.TagsInputDemo do
  @moduledoc """
  Interactive `tags_input`: add on Enter (a `<.form phx-submit>` whose reset clears the draft — no
  JS hook), remove via each token's ✕. The tags submit as `tags_demo[tags][]`. Nothing is persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.TagsInput

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:tags, fn -> ["elixir", "phoenix"] end)
     |> assign_new(:form, fn -> to_form(%{"tag" => ""}, as: :tags_demo) end)}
  end

  @impl true
  def handle_event("add", %{"tags_demo" => %{"tag" => tag}}, socket) do
    tag = String.trim(tag)
    tags = socket.assigns.tags
    tags = if tag != "" and tag not in tags, do: tags ++ [tag], else: tags

    {:noreply, assign(socket, tags: tags, form: to_form(%{"tag" => ""}, as: :tags_demo))}
  end

  def handle_event("remove", %{"tag" => tag}, socket) do
    {:noreply, assign(socket, tags: List.delete(socket.assigns.tags, tag))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} id={"#{@id}-tags-form"} phx-target={@myself} phx-submit="add">
        <.tags_input
          id={"#{@id}-ti"}
          name="tags_demo[tags][]"
          tags={@tags}
          input_name={@form[:tag].name}
          input_value={@form[:tag].value}
          placeholder="Add a tag and press Enter…"
          on_remove={JS.push("remove", target: @myself)}
          class={fc()}
        />
      </.form>
      <p class="mt-2 text-xs text-[var(--c-base-content)]/50">
        Submits as <code>tags_demo[tags][]</code>
        — {(@tags == [] && "none") || Enum.join(@tags, ", ")}
      </p>
    </div>
    """
  end

  defp fc do
    [
      "flex flex-wrap items-center gap-1.5 rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-2 py-1.5 text-sm cursor-text focus-within:ring-2 focus-within:ring-[var(--c-primary)]/30 [&[data-disabled]]:opacity-60",
      "[&_[data-part=tag]]:inline-flex [&_[data-part=tag]]:items-center [&_[data-part=tag]]:gap-1 [&_[data-part=tag]]:rounded [&_[data-part=tag]]:bg-[var(--c-base-200)] [&_[data-part=tag]]:py-0.5 [&_[data-part=tag]]:pr-1 [&_[data-part=tag]]:pl-2",
      "[&_[data-part=remove]]:inline-flex [&_[data-part=remove]]:size-4 [&_[data-part=remove]]:items-center [&_[data-part=remove]]:justify-center [&_[data-part=remove]]:rounded-full [&_[data-part=remove]]:leading-none [&_[data-part=remove]]:text-[var(--c-base-content)]/50 [&_[data-part=remove]]:hover:bg-[var(--c-base-300)] [&_[data-part=remove]]:hover:text-[var(--c-base-content)]",
      "[&_[data-part=input]]:min-w-24 [&_[data-part=input]]:flex-1 [&_[data-part=input]]:border-0 [&_[data-part=input]]:bg-transparent [&_[data-part=input]]:p-0.5 [&_[data-part=input]]:outline-none"
    ]
  end
end
