defmodule MishkaChelekomWeb.Examples.AlertLive do
  use Phoenix.LiveView
  use Phoenix.Component
  import MishkaChelekomWeb.CoreComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end