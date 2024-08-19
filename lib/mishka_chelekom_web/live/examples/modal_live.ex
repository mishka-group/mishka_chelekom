defmodule MishkaChelekomWeb.Examples.ModalLive do
  use Phoenix.LiveView
  use Phoenix.Component

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :modal_select, false)}
  end
end
