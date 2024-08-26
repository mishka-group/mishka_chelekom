defmodule MishkaChelekomWeb.Examples.PopoverLive do
  use Phoenix.LiveView
  use Phoenix.Component
  import MishkaChelekomWeb.CoreComponents
  import MishkaChelekom.{Popover, Avatar, Typography}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
