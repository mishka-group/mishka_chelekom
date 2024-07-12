defmodule MishkaChelekomWeb.AdminFormLive do
  use Phoenix.LiveView
  import MishkaChelekomWeb.CoreComponents

  def mount(_params, _session, socket) do
    # Let's assume a fixed temperature for now
    temperature = 70
    {:ok, assign(socket, :temperature, temperature)}
  end

  def handle_event("inc", _params, socket) do
    {:noreply, update(socket, :temperature, &(&1 + 1))}
  end
end
