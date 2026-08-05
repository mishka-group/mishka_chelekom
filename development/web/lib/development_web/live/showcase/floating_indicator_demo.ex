defmodule DevelopmentWeb.Showcase.FloatingIndicatorDemo do
  @moduledoc """
  `floating_indicator` as a segmented switch. Clicking a target slides the indicator (client-side) and
  pushes `handle_event "select"` via `on_change`, so the server tracks the active section. Nothing is
  persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.FloatingIndicator

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_new(:active, fn -> "overview" end)}
  end

  @impl true
  def handle_event("select", %{"value" => value}, socket) do
    {:noreply, assign(socket, active: value)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-3">
      <.floating_indicator
        id={"#{@id}-tabs"}
        active={@active}
        on_change="select"
        label="Sections"
        class={group()}
        indicator_class="rounded-md bg-[var(--c-primary)] shadow"
        target_class={target()}
      >
        <:target value="overview">Overview</:target>
        <:target value="pricing">Pricing</:target>
        <:target value="reviews">Reviews</:target>
        <:target value="faq">FAQ</:target>
      </.floating_indicator>
      <p class="text-sm text-[var(--c-base-content)]/70">
        Active on the server: <span class="font-medium">{@active}</span>
      </p>
    </div>
    """
  end

  defp group do
    "relative inline-flex gap-1 rounded-lg bg-[var(--c-base-200)] p-1 " <>
      "[&_[data-part=indicator]]:absolute [&_[data-part=indicator]]:left-0 [&_[data-part=indicator]]:top-0 [&_[data-part=indicator]]:transition-all [&_[data-part=indicator]]:duration-200 [&_[data-part=indicator]]:ease-out"
  end

  defp target do
    "relative z-10 rounded-md px-3 py-1.5 text-sm font-medium text-[var(--c-base-content)]/70 transition-colors outline-none aria-pressed:text-primary-content"
  end
end
