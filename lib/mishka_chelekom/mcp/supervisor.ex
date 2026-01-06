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
  """

  use Supervisor

  @default_port 4003

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    port = Keyword.get(opts, :port, @default_port)

    # MCP Server and Registry are already started by MishkaChelekom.Application
    # We only need to start the HTTP server for standalone mode
    children = [
      http_server_child(port)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp http_server_child(port) do
    cond do
      Code.ensure_loaded?(Bandit) ->
        {Bandit, plug: MishkaChelekom.MCP.Router, port: port}

      Code.ensure_loaded?(Plug.Cowboy) ->
        {Plug.Cowboy, scheme: :http, plug: MishkaChelekom.MCP.Router, options: [port: port]}

      true ->
        raise "No HTTP server available. Please add {:bandit, \"~> 1.0\"} or {:plug_cowboy, \"~> 2.7\"} to your dependencies."
    end
  end
end
