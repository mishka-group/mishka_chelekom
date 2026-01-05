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
    to: Anubis.Server.Transport.StreamableHTTP.Plug,
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
