defmodule MishkaChelekomWeb.Examples.PopoverLive do
  use Phoenix.LiveView
  use Phoenix.Component
  import MishkaChelekomComponents
  import MishkaChelekom.{Popover}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
