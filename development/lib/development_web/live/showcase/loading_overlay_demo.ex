defmodule DevelopmentWeb.Showcase.LoadingOverlayDemo do
  @moduledoc """
  Server-driven `loading_overlay`: the button pushes `handle_event "toggle"`, which flips the
  `loading` assign; the overlay fades over the card while it is set. The toggle lives outside the
  covered box so it stays clickable.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.LoadingOverlay

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_new(:loading, fn -> false end)}
  end

  @impl true
  def handle_event("toggle", _params, socket) do
    {:noreply, update(socket, :loading, &(!&1))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="relative h-40 w-72 overflow-hidden rounded-lg border border-[var(--c-base-300)] p-4">
        <h4 class="font-medium">Quarterly report</h4>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          Revenue is up 12% and churn is down — the numbers keep loading behind this overlay.
        </p>
        <.loading_overlay visible={@loading} label="Loading report" class={loc()}>
          <span class="size-6 animate-spin rounded-full border-2 border-[var(--c-base-300)] border-t-[var(--c-primary)]"></span>
        </.loading_overlay>
      </div>
      <button
        type="button"
        phx-target={@myself}
        phx-click="toggle"
        class="mt-3 rounded-md border border-[var(--c-base-300)] px-3 py-1.5 text-sm hover:bg-[var(--c-base-200)]"
      >
        {(@loading && "Hide") || "Show"} loading
      </button>
    </div>
    """
  end

  defp loc do
    [
      "absolute inset-0 flex items-center justify-center bg-[var(--c-base-100)]/70 backdrop-blur-sm transition-opacity duration-200",
      "[&:not([data-visible])]:pointer-events-none [&:not([data-visible])]:opacity-0"
    ]
  end
end
