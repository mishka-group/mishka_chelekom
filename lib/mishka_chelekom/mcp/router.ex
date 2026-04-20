defmodule MishkaChelekom.MCP.TransportPlug do
  @moduledoc false
  # Defers Anubis.Server.Transport.StreamableHTTP.Plug.init/1 to runtime.
  # Plug.Router calls init/1 at compile time, but the Anubis plug reads a
  # persistent term that is only written when the supervisor starts at runtime.
  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, opts) do
    real_opts = Anubis.Server.Transport.StreamableHTTP.Plug.init(opts)
    Anubis.Server.Transport.StreamableHTTP.Plug.call(conn, real_opts)
  end
end

defmodule MishkaChelekom.MCP.Router do
  @moduledoc """
  HTTP Router for the Mishka Chelekom MCP Server.

  Routes MCP protocol requests to the Anubis server handler.
  The server runs on `http://localhost:4003/mcp`.
  """

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  forward("/mcp",
    to: MishkaChelekom.MCP.TransportPlug,
    init_opts: [server: MishkaChelekom.MCP.Server]
  )

  get "/" do
    send_resp(conn, 200, """
    Mishka Chelekom MCP Server

    Connect your AI tools to: http://localhost:4003/mcp

    Available endpoints:
    - POST /mcp - MCP protocol endpoint

    For Claude Code:
      claude mcp add --transport http mishka-chelekom http://localhost:4003/mcp

    For Cursor/VSCode (.mcp.json):
      {
        "mcpServers": {
          "mishka-chelekom": {
            "type": "http",
            "url": "http://localhost:4003/mcp"
          }
        }
      }

    Documentation: https://mishka.tools/chelekom/docs
    """)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
