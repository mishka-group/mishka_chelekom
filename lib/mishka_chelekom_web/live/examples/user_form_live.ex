defmodule MishkaChelekomWeb.Examples.UserFormLive do
  use Phoenix.LiveView
  use Phoenix.Component
  alias MishkaChelekom.User

  def mount(_params, _session, socket) do
    User.changeset(%User{}, %{})
    |> IO.inspect()

    {:ok, socket}
  end
end
