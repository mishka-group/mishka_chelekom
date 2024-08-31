defmodule MishkaChelekomWeb.Examples.CryptoLive do
  use Phoenix.LiveView
  use Phoenix.Component
  import MishkaChelekomWeb.CoreComponents
  import MishkaChelekom.{Dropdown}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
