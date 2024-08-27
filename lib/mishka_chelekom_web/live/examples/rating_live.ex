defmodule MishkaChelekomWeb.Examples.RatingLive do
  use Phoenix.LiveView
  use Phoenix.Component

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
