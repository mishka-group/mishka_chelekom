defmodule Mix.Tasks.Mishka.Mcp.Server do
  @moduledoc """
  Starts the Mishka Chelekom MCP Server.

  The server provides an MCP (Model Context Protocol) interface for AI tools
  like Claude Code, Cursor, and Claude Desktop to interact with the
  Mishka Chelekom component library.

  ## Usage

      # HTTP transport (default) — long-running server on port 4003
      mix mishka.mcp.server

      # Stdio transport — MCP client spawns this process and talks over stdin/stdout
      mix mishka.mcp.server --transport stdio

  ## Options

  * `--transport` or `-t` - Transport to use: `http` (default) or `stdio`
  * `--port` or `-p` - HTTP port to listen on (default: 4003, http transport only)

  ## Transports

  ### HTTP (default)

  Starts a Bandit HTTP listener that AI tools connect to over the network.
  Suitable for running as a background service.

      mix mishka.mcp.server
      mix mishka.mcp.server --port 5000

  ### Stdio

  Speaks the MCP stdio protocol over stdin/stdout. The MCP client (e.g.
  Claude Code) spawns this command itself — no separate server needed.
  This is the zero-setup option for project-local `.mcp.json` files
  shared via version control.

      mix mishka.mcp.server --transport stdio

  > Stdio mode prints nothing to stdout (stdout is the protocol channel).
  > All logs are redirected to stderr by the transport.

  ## Connecting AI Tools

  ### Claude Code (HTTP)

      claude mcp add --transport http mishka-chelekom http://localhost:4003/mcp

  ### Claude Code (Stdio)

      claude mcp add --transport stdio mishka-chelekom \\
        --env MIX_QUIET=1 -- mix mishka.mcp.server --transport stdio

  ### Cursor / VSCode (HTTP) — create `.mcp.json` in project root:

      {
        "mcpServers": {
          "mishka-chelekom": {
            "type": "http",
            "url": "http://localhost:4003/mcp"
          }
        }
      }

  ### Cursor / VSCode (Stdio) — create `.mcp.json` in project root:

      {
        "mcpServers": {
          "mishka-chelekom": {
            "type": "stdio",
            "command": "mix",
            "args": ["mishka.mcp.server", "--transport", "stdio"],
            "env": {"MIX_QUIET": "1"}
          }
        }
      }

  > `MIX_QUIET=1` keeps Mix's `Compiling …` messages off stdout when a
  > rebuild happens, so the MCP handshake stays clean on first run.

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
    case parse_args(args) do
      {:ok, {:http, port}} -> run_http(port: port)
      {:ok, :stdio} -> run_stdio()
      {:error, msg} -> Mix.raise(msg)
    end
  end

  @doc """
  Parses task argv into a transport selection.

  Returns:
    * `{:ok, {:http, port}}` — default, HTTP transport on `port` (default 4003)
    * `{:ok, :stdio}` — stdio transport
    * `{:error, message}` — unknown `--transport` value

  Public so it can be unit-tested without running the (blocking) task.
  """
  def parse_args(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        strict: [port: :integer, transport: :string],
        aliases: [p: :port, t: :transport]
      )

    case Keyword.get(opts, :transport, "http") do
      "http" ->
        {:ok, {:http, Keyword.get(opts, :port, 4003)}}

      "stdio" ->
        {:ok, :stdio}

      other ->
        {:error, "Unknown --transport #{inspect(other)}. Expected one of: http, stdio"}
    end
  end

  defp run_http(opts) do
    port = Keyword.fetch!(opts, :port)

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

    Application.ensure_all_started(:telemetry)
    Application.ensure_all_started(:bandit)
    Application.ensure_all_started(:mishka_chelekom)

    # Standalone HTTP needs its own Bandit listener — the Application only
    # starts the MCP server process + streamable_http transport handler.
    {:ok, _pid} = MishkaChelekom.MCP.Supervisor.start_link(port: port)

    Mix.shell().info("MCP Server started successfully on port #{port}")

    Process.sleep(:infinity)
  end

  defp run_stdio do
    # Stdout is the MCP protocol channel — anything that is not JSON-RPC
    # corrupts the stream. Silence Logger entirely so server/transport
    # events don't leak to stdout. (Anubis's transport tries to redirect
    # the Erlang :default handler, but Elixir's Logger uses its own
    # handlers, so that redirect is a no-op here.)
    Logger.configure(level: :none)

    # Override the default transport so the MCP server child starts with
    # :stdio instead of :streamable_http.
    Application.put_env(:mishka_chelekom, :mcp_transport, :stdio)

    Application.ensure_all_started(:telemetry)
    Application.ensure_all_started(:mishka_chelekom)

    Process.sleep(:infinity)
  end
end
