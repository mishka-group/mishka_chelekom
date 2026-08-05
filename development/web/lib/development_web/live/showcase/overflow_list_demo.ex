defmodule DevelopmentWeb.Showcase.OverflowListDemo do
  @moduledoc """
  `overflow_list` inside a resizable box: drag the right edge to shrink it and watch items collapse
  into the `+N` counter. `on_change` pushes `handle_event "overflow"` so the server can report how
  many items are currently hidden.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.OverflowList

  @tags ~w(Design Phoenix Elixir LiveView Tailwind Headless Accessibility Components Mishka Chelekom)

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:tags, @tags)
     |> assign_new(:hidden, fn -> 0 end)}
  end

  @impl true
  def handle_event("overflow", %{"hidden" => hidden}, socket) do
    {:noreply, assign(socket, hidden: hidden)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-2">
      <div
        class="resize-x overflow-auto rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-2"
        style="width: 26rem; min-width: 7rem; max-width: 100%;"
      >
        <.overflow_list
          id={"#{@id}-list"}
          min_visible={1}
          on_change="overflow"
          class={list()}
          item_class="whitespace-nowrap rounded-full bg-[var(--c-primary)]/10 px-2.5 py-0.5 text-sm text-[var(--c-primary)]"
        >
          <:item :for={tag <- @tags}>{tag}</:item>
        </.overflow_list>
      </div>
      <p class="text-sm text-[var(--c-base-content)]/70">
        Hidden on the server: <span class="font-medium">{@hidden}</span>
        · drag the box's right edge to resize
      </p>
    </div>
    """
  end

  defp list do
    "flex items-center gap-2 overflow-hidden " <>
      "[&_[data-part=item][data-hidden]]:hidden [&_[data-part=item]]:shrink-0 " <>
      "[&_[data-part=counter][data-hidden]]:hidden [&_[data-part=counter]]:shrink-0 [&_[data-part=counter]]:whitespace-nowrap [&_[data-part=counter]]:rounded-full [&_[data-part=counter]]:bg-[var(--c-base-200)] [&_[data-part=counter]]:px-2.5 [&_[data-part=counter]]:py-0.5 [&_[data-part=counter]]:text-sm [&_[data-part=counter]]:font-medium [&_[data-part=counter]]:text-[var(--c-base-content)]/70"
  end
end
