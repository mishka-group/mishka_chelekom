defmodule MishkaChelekomWeb.Examples.TelFieldLive do
  use Phoenix.LiveView
  use Phoenix.Component
  import MishkaChelekomComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end