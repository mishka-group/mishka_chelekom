defmodule MishkaChelekomWeb.Examples.AlertLive do
  use Phoenix.LiveView
  use Phoenix.Component

  def mount(_params, _session, socket) do
    new_socket =
      socket
      |> put_flash(:misc, "It worked!")

    {:ok, new_socket}
  end
end
