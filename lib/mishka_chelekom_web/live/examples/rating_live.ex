defmodule MishkaChelekomWeb.Examples.RatingLive do
  use Phoenix.LiveView
  use Phoenix.Component

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("rating", %{"action" => "select", "number" => item} = _params, socket) do
    IO.inspect(item, label: "Rating=-==-==>")
    {:noreply, socket}
  end
end
