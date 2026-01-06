defmodule MishkaChelekom.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Required for MCP server (both standalone and Phoenix integration)
      Anubis.Server.Registry,
      # MCP Server process with transport (does NOT start its own HTTP server)
      # - Phoenix integration: router forward handles HTTP
      # - Standalone: MCP.Supervisor starts Bandit for HTTP
      {MishkaChelekom.MCP.Server, transport: {:streamable_http, start: true}}
    ]

    opts = [strategy: :one_for_one, name: MishkaChelekom.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
