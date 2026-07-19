defmodule DevelopmentWeb.Showcase.FloatingWindowDemo do
  @moduledoc """
  `floating_window` inside a relative stage: drag the title bar to move the panel. On release the
  hook pushes `handle_event "moved"` (via `on_move`) so the server tracks the coordinates; the ✕ in
  the title bar closes the window client-side (`JS.hide`) without starting a drag.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.FloatingWindow
  alias Phoenix.LiveView.JS

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_new(:pos, fn -> {24, 24} end)}
  end

  @impl true
  def handle_event("moved", %{"x" => x, "y" => y}, socket) do
    {:noreply, assign(socket, pos: {x, y})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-2">
      <div
        class="relative h-64 overflow-hidden rounded-lg border border-[var(--c-base-300)]"
        style="background-image: radial-gradient(var(--c-base-300) 1px, transparent 0); background-size: 16px 16px;"
      >
        <.floating_window
          id={"#{@id}-win"}
          x={elem(@pos, 0)}
          y={elem(@pos, 1)}
          on_move="moved"
          label="Demo window"
          class="absolute w-56 rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] shadow-lg"
          handle_class="flex cursor-grab items-center justify-between gap-2 rounded-t-lg border-b border-[var(--c-base-300)] bg-[var(--c-base-200)] px-3 py-1.5 active:cursor-grabbing"
          body_class="p-3 text-sm text-[var(--c-base-content)]/80"
        >
          <:handle>
            <span class="font-medium">Drag me</span>
            <button
              type="button"
              phx-click={JS.hide(to: "##{@id}-win")}
              class="rounded p-0.5 leading-none text-[var(--c-base-content)]/50 hover:bg-[var(--c-base-300)]"
              aria-label="Close"
            >
              ✕
            </button>
          </:handle>
          A movable panel. The title bar is the drag handle; the ✕ closes without dragging.
        </.floating_window>
      </div>
      <p class="text-sm text-[var(--c-base-content)]/70">
        Position on the server: <span class="font-mono">{elem(@pos, 0)}, {elem(@pos, 1)}</span>
      </p>
    </div>
    """
  end
end
