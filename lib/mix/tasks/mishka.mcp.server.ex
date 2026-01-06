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

  ## Available Tools (11)

  - `generate_component` - Generate mix command for a single component
  - `generate_components` - Generate mix command for multiple components
  - `get_component_info` - Get component configuration options (variants, colors, sizes)
  - `get_example` - Get HEEx code examples with usage patterns
  - `get_js_hook_info` - Get JavaScript hook documentation
  - `get_mix_task_info` - Get mix task documentation
  - `search_components` - Search components by name or functionality
  - `uninstall_component` - Generate uninstall command
  - `update_config` - Update project configuration settings
  - `validate_config` - Validate configuration file for errors
  - `get_docs` - Fetch documentation from mishka.tools

  ## Available Resources (9)

  - `list_components` - List all available components with categories
  - `list_colors` - List color variants with CSS variables
  - `list_variants` - List style variants (default, outline, shadow, etc.)
  - `list_sizes` - List size options (small, medium, large, etc.)
  - `list_spaces` - List spacing options
  - `list_scripts` - List JavaScript hooks (Carousel, Clipboard, etc.)
  - `list_dependencies` - List component dependencies
  - `list_css_variables` - List all CSS custom properties
  - `get_config` - Get current project configuration
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

    # Start all required applications
    Application.ensure_all_started(:telemetry)
    Application.ensure_all_started(:bandit)
    Application.ensure_all_started(:mishka_chelekom)

    # Start the MCP supervisor (only starts Bandit HTTP server)
    {:ok, _pid} = MishkaChelekom.MCP.Supervisor.start_link(port: port)

    Mix.shell().info("MCP Server started successfully on port #{port}")

    # Keep the process alive
    Process.sleep(:infinity)
  end
end
