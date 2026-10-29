defmodule MishkaChelekom.MCP.Supervisor do
  @moduledoc """
  Supervisor for the Mishka Chelekom MCP Server.

  This supervisor manages the MCP server and its HTTP transport.
  It can be started manually or via the `mix mishka.mcp.server` task.

  ## Starting the Server

  ### Via Mix Task (Recommended)

      mix mishka.mcp.server

  ### Programmatically

      MishkaChelekom.MCP.Supervisor.start_link(port: 4003)

  ### In Your Application Supervisor

      children = [
        {MishkaChelekom.MCP.Supervisor, port: 4003}
      ]

  ## Options

  - `:port` - HTTP port to listen on (default: 4003)
  - `:ip` - address to listen on (default: `{127, 0, 0, 1}`, so only this machine can connect).
    Pass `{0, 0, 0, 0}` (or another address) to accept connections from other machines; the
    server has no authentication, so only on a network you trust.
  """

  use Supervisor

  @default_port 4003
  @default_ip {127, 0, 0, 1}

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    port = Keyword.get(opts, :port, @default_port)
    ip = Keyword.get(opts, :ip, @default_ip)

    # MCP Server and Registry are already started by MishkaChelekom.Application
    # We only need to start the HTTP server for standalone mode
    children = [
      http_server_child(port, ip)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp http_server_child(port, ip) do
    cond do
      Code.ensure_loaded?(Bandit) ->
        {Bandit, plug: MishkaChelekom.MCP.Router, port: port, ip: ip}

      Code.ensure_loaded?(Plug.Cowboy) ->
        {Plug.Cowboy,
         scheme: :http, plug: MishkaChelekom.MCP.Router, options: [port: port, ip: ip]}

      true ->
        raise ~s(No HTTP server available. Please add {:bandit, "~> 1.0"} or {:plug_cowboy, "~> 2.7"} to your dependencies.)
    end
  end
end
