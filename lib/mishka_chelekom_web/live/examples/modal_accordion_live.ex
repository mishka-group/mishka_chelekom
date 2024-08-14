defmodule MishkaChelekomWeb.Examples.ModalAccordionLive do
  use Phoenix.LiveView
  import MishkaChelekom.ModalAccordion

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
