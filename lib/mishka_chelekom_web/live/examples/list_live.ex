defmodule MishkaChelekomWeb.Examples.ListLive do
  use Phoenix.LiveView
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
