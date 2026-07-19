defmodule DevelopmentWeb.Showcase.RollingNumberDemo do
  @moduledoc """
  Server-driven `rolling_number`: a button pushes `handle_event "randomize"`, which assigns a new
  value; the re-render triggers the hook's `updated()` so the number animates to the new target.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.RollingNumber

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_new(:value, fn -> 1000 end)}
  end

  @impl true
  def handle_event("randomize", _params, socket) do
    {:noreply, assign(socket, value: Enum.random(100..999_999))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex items-center gap-4">
      <.rolling_number id={"#{@id}-n"} value={@value} class="text-3xl font-bold tabular-nums" />
      <button
        type="button"
        phx-target={@myself}
        phx-click="randomize"
        class="rounded-md border border-[var(--c-base-300)] px-3 py-1.5 text-sm hover:bg-[var(--c-base-200)]"
      >
        Randomize
      </button>
    </div>
    """
  end
end
