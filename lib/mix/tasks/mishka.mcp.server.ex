defmodule Mix.Tasks.Mishka.Mcp.Server do
  @moduledoc """
  Starts the Mishka Chelekom MCP Server.

  The server provides an MCP (Model Context Protocol) interface for AI tools
  like Claude Code, Cursor, and Claude Desktop to interact with the
  Mishka Chelekom component library.

  ## Usage

      mix mishka.mcp.server

  ## Options

  * `--port` or `-p` - HTTP port to listen on (default: 4003)

  ## Connecting AI Tools

  Once the server is running, connect your AI tools:

  ### Claude Code

      claude mcp add --transport http mishka-chelekom http://localhost:4003/mcp

  ### Cursor / VSCode

  Create `.mcp.json` in your project root:

      {
        "mcpServers": {
          "mishka-chelekom": {
            "type": "http",
            "url": "http://localhost:4003/mcp"
          }
        }
      }

  ## Available Tools

  The MCP server provides these tools:

  - `generate_component` - Generate mix commands for creating components
  - `get_component_info` - Get detailed component configuration options
  - `get_example` - Get HEEx code examples for components
  - `search_components` - Search components by name or functionality

  ## Available Resources

  - `list_components` - List all available components with categories
  - `list_colors` - List available color variants
  - `list_variants` - List available style variants
  - `list_sizes` - List available size options
  """

  use Mix.Task

  @shortdoc "Starts the Mishka Chelekom MCP Server"

  @impl Mix.Task
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        strict: [port: :integer],
        aliases: [p: :port]
      )

    port = Keyword.get(opts, :port, 4003)

    Mix.shell().info("""

    Starting Mishka Chelekom MCP Server...

    Server URL: http://localhost:#{port}/mcp

    Connect your AI tools:

      Claude Code:
        claude mcp add --transport http mishka-chelekom http://localhost:#{port}/mcp

      Cursor/VSCode (.mcp.json):
        {
          "mcpServers": {
            "mishka-chelekom": {
              "type": "http",
              "url": "http://localhost:#{port}/mcp"
            }
          }
        }

    Press Ctrl+C twice to stop the server.

    """)

    # Start the application dependencies
    Application.ensure_all_started(:plug_cowboy)

    # Start the MCP supervisor
    {:ok, _pid} = MishkaChelekom.MCP.Supervisor.start_link(port: port)

    Mix.shell().info("MCP Server started successfully on port #{port}")

    # Keep the process alive
    Process.sleep(:infinity)
  end
end
