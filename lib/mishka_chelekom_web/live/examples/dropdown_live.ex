defmodule MishkaChelekomWeb.Examples.DropdownLive do
  use Phoenix.LiveView
  use Phoenix.Component
  import MishkaChelekomWeb.CoreComponents
  import MishkaChelekom.{Dropdown, Typography}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
