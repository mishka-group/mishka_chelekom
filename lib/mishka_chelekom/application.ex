defmodule MishkaChelekom.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Required for MCP server (both standalone and Phoenix integration)
      Anubis.Server.Registry
    ]

    opts = [strategy: :one_for_one, name: MishkaChelekom.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
