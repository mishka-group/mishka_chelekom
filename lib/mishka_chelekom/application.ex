defmodule MishkaChelekom.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    # Transport is overridable via app env so `mix mishka.mcp.server --transport stdio`
    # can swap in :stdio before the app boots. Default preserves the existing
    # HTTP behavior (Phoenix-integrated route and standalone Bandit server).
    transport =
      Application.get_env(:mishka_chelekom, :mcp_transport, {:streamable_http, start: true})

    children = [
      # MCP Server process with transport (does NOT start its own HTTP server)
      # - Phoenix integration: router forward handles HTTP
      # - Standalone HTTP: MCP.Supervisor starts Bandit
      # - Stdio: Anubis stdio transport reads JSON-RPC from stdin/stdout
      {MishkaChelekom.MCP.Server, transport: transport}
    ]

    opts = [strategy: :one_for_one, name: MishkaChelekom.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
