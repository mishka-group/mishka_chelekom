defmodule MishkaChelekomWeb.Examples.CryptoLive do
  use Phoenix.LiveView
  use Phoenix.Component
  import MishkaChelekomComponents
  import MishkaChelekom.{Dropdown, Card, Typography, Button}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
