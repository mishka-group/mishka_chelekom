defmodule MishkaChelekomWeb.Examples.TableLive do
  use Phoenix.LiveView
  use Phoenix.Component
  import MishkaChelekomComponents

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :posts, %{total: 5, active: 1})}
  end

  def handle_event("pagination", %{"action" => "first"} = _params, socket) do
    {:noreply, assign(socket, :posts, %{total: 5, active: 1})}
  end

  def handle_event("pagination", %{"action" => "next"} = _params, socket) do
    {:noreply, assign(socket, :posts, %{total: 5, active: socket.assigns.posts.active + 1})}
  end

  def handle_event("pagination", %{"action" => "select", "page" => page} = _params, socket) do
    {:noreply, assign(socket, :posts, %{total: 5, active: page})}
  end

  def handle_event("pagination", %{"action" => "previous"} = _params, socket) do
    {:noreply, assign(socket, :posts, %{total: 5, active: socket.assigns.posts.active - 1})}
  end

  def handle_event("pagination", %{"action" => "last"} = _params, socket) do
    {:noreply, assign(socket, :posts, %{total: 5, active: socket.assigns.posts.total})}
  end
end
