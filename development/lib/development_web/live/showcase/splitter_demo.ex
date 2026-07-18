defmodule DevelopmentWeb.Showcase.SplitterDemo do
  @moduledoc """
  Server-aware `splitter`: dragging the divider pushes `on_change` (`handle_event "resize"`) with the
  new percentage, which the server keeps in sync and echoes. `default_size` is bound to the assign so
  a re-render never fights the drag.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.Splitter

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_new(:size, fn -> 40 end)}
  end

  @impl true
  def handle_event("resize", %{"value" => v}, socket) do
    {:noreply, assign(socket, size: v)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.splitter id={"#{@id}-s"} default_size={@size} on_change="resize" class={sc()}>
        <:first>
          <div class="p-3 text-sm">Left pane — <strong>{@size}%</strong></div>
        </:first>
        <:second>
          <div class="p-3 text-sm">Right pane</div>
        </:second>
      </.splitter>
      <p class="mt-2 text-xs text-[var(--c-base-content)]/50">
        The server sees the size live via <code>on_change</code>: <strong>{@size}%</strong>
      </p>
    </div>
    """
  end

  defp sc do
    [
      "flex h-40 w-full overflow-hidden rounded-lg border border-[var(--c-base-300)]",
      "[&_[data-part=panel][data-index=0]]:w-[var(--chelekom-splitter-pos)] [&_[data-part=panel][data-index=0]]:shrink-0 [&_[data-part=panel][data-index=0]]:overflow-auto [&_[data-part=panel][data-index=0]]:bg-[var(--c-base-100)]",
      "[&_[data-part=panel][data-index=1]]:flex-1 [&_[data-part=panel][data-index=1]]:overflow-auto [&_[data-part=panel][data-index=1]]:bg-[var(--c-base-200)]",
      "[&_[data-part=resizer]]:w-1.5 [&_[data-part=resizer]]:shrink-0 [&_[data-part=resizer]]:cursor-col-resize [&_[data-part=resizer]]:bg-[var(--c-base-300)] [&_[data-part=resizer]]:outline-none [&_[data-part=resizer]:hover]:bg-[var(--c-primary)]/40 [&_[data-part=resizer]:focus-visible]:bg-[var(--c-primary)]",
      "[&[data-dragging]_[data-part=resizer]]:bg-[var(--c-primary)]"
    ]
  end
end
