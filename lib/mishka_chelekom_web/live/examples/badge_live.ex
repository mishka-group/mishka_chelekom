defmodule MishkaChelekomWeb.Examples.BadgeLive do
  use Phoenix.LiveView
  use Phoenix.Component
  import MishkaChelekomWeb.CoreComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("dismiss", params, socket) do
    IO.inspect(params, label: "-=-=-=-=-=-==-=-=-=-=--=>")
    {:noreply, socket}
  end
end
