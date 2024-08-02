defmodule MishkaChelekomWeb.Examples.PaginationLive do
  use Phoenix.LiveView
  use Phoenix.Component
  import MishkaChelekom.Pagination

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :posts, %{total: 20, active: 1})}
  end

  def handle_event("pagination", %{"action" => "first"} = _params, socket) do
    {:noreply, assign(socket, :posts, %{total: 20, active: 1})}
  end

  def handle_event("pagination", %{"action" => "next"} = _params, socket) do
    {:noreply, assign(socket, :posts, %{total: 20, active: socket.assigns.posts.active + 1})}
  end

  def handle_event("pagination", %{"action" => "select", "page" => page} = _params, socket) do
    {:noreply, assign(socket, :posts, %{total: 20, active: page})}
  end

  def handle_event("pagination", %{"action" => "previous"} = _params, socket) do
    {:noreply, assign(socket, :posts, %{total: 20, active: socket.assigns.posts.active - 1})}
  end

  def handle_event("pagination", %{"action" => "last"} = _params, socket) do
    {:noreply, assign(socket, :posts, %{total: 20, active: socket.assigns.posts.total})}
  end
end
