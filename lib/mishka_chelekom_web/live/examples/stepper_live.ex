defmodule MishkaChelekomWeb.Examples.StepperLive do
  use Phoenix.LiveView
  use Phoenix.Component
  import MishkaChelekomComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
