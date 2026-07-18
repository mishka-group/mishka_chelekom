defmodule DevelopmentWeb.Showcase.ChipDemo do
  @moduledoc """
  Interactive `chip` inside a real `<.form>`: the native checkboxes fire `phx-change` (no JS),
  the server owns the checked list — so the selection survives any re-render — and the disabled
  chip is never submitted. Nothing is persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.Chip

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:topics, fn -> ["elixir"] end)}
  end

  @impl true
  def handle_event("change", params, socket) do
    {:noreply, assign(socket, topics: Map.get(params["chip_demo"] || %{}, "topics", []))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={%{}} as={:chip_demo} phx-target={@myself} phx-change="change">
        <div class="flex flex-wrap gap-2">
          <.chip
            :for={topic <- ~w(design elixir phoenix liveview)}
            id={"#{@id}-#{topic}"}
            name="chip_demo[topics][]"
            value={topic}
            checked={topic in @topics}
            class={cc()}
          >
            {topic}
          </.chip>
          <.chip id={"#{@id}-locked"} name="chip_demo[topics][]" value="locked" disabled class={cc()}>
            locked
          </.chip>
        </div>
      </.form>
      <p class="mt-2 text-xs text-[var(--c-base-content)]/50">
        Submits as <code>chip_demo[topics][]</code>
        — {(@topics == [] && "none") || Enum.join(@topics, ", ")}
      </p>
    </div>
    """
  end

  defp cc do
    [
      "inline-flex cursor-pointer items-center gap-1.5 rounded-full border border-[var(--c-base-300)] px-3 py-1 text-sm select-none",
      "has-[:checked]:border-[var(--c-primary)] has-[:checked]:bg-[var(--c-primary)]/10 has-[:checked]:text-[var(--c-primary)]",
      "has-[:focus-visible]:ring-2 has-[:focus-visible]:ring-[var(--c-primary)]/40",
      "data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50",
      "[&_[data-part=input]]:sr-only"
    ]
  end
end
