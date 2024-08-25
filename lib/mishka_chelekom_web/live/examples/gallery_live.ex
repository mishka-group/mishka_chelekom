defmodule MishkaChelekomWeb.Examples.GalleryLive do
  use Phoenix.LiveView
  use Phoenix.Component
  import MishkaChelekom.Gallery

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
