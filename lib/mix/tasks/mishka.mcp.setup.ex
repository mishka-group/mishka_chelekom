defmodule Mix.Tasks.Mishka.Mcp.Setup do
  @moduledoc """
  Sets up the Mishka Chelekom MCP Server in your Phoenix application.

  This task adds the necessary configuration to your Phoenix router to serve
  the MCP (Model Context Protocol) endpoint, allowing AI tools like Claude Code,
  Cursor, and Claude Desktop to interact with your Mishka Chelekom components.

  ## Usage

      # HTTP transport (default) — patches your Phoenix router
      mix mishka.mcp.setup

      # Stdio transport — writes .mcp.json so the client spawns the server itself
      mix mishka.mcp.setup --stdio

  ## Options

  * `--path` or `-p` - Custom MCP endpoint path (default: "/mcp", http only)
  * `--dev-only` - Only enable MCP in development (default: true, http only)
  * `--yes` - Skip confirmation prompts
  * `--stdio` or `-s` - Write .mcp.json with stdio entry instead of patching router

  ## What This Task Does

  ### Default (HTTP)

  1. Adds the MCP route to your Phoenix router
  2. Configures the route to use `Anubis.Server.Transport.StreamableHTTP.Plug`
  3. Wraps it in a dev_routes condition (unless --dev-only=false)

  ### With `--stdio`

  1. Creates (or merges into) `.mcp.json` in the project root
  2. Adds a `mishka-chelekom` server entry that spawns
     `mix mishka.mcp.server --transport stdio`
  3. Sets `MIX_QUIET=1` in the entry's env so Mix compile output never
     corrupts the protocol stream

  No Phoenix changes are made in `--stdio` mode — stdio doesn't need a route.

  ## After Setup

  Start your Phoenix server and connect your AI tools:

  ### Claude Code

      claude mcp add --transport http mishka-chelekom http://localhost:4000/mcp

  ### Cursor / VSCode

  Create `.mcp.json` in your project root:

      {
        "mcpServers": {
          "mishka-chelekom": {
            "type": "http",
            "url": "http://localhost:4000/mcp"
          }
        }
      }
  """

  use Igniter.Mix.Task

  @example "mix mishka.mcp.setup"
  @shortdoc "Set up MCP server in your Phoenix router"

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      adds_deps: [{:anubis, "~> 0.2"}],
      installs: [],
      example: @example,
      only: nil,
      positional: [],
      composes: [],
      schema: [
        path: :string,
        dev_only: :boolean,
        yes: :boolean,
        stdio: :boolean
      ],
      defaults: [
        path: "/mcp",
        dev_only: true,
        stdio: false
      ],
      aliases: [
        p: :path,
        s: :stdio
      ]
    }
  end

  def igniter(igniter) do
    Application.ensure_all_started(:owl)
    options = igniter.args.options

    if Mix.env() != :test,
      do: MishkaChelekom.Generators.Core.banner(IO.ANSI.light_magenta(), "MCP Setup")

    tty? = IO.ANSI.enabled?()
    spin? = Mix.env() != :test and tty?
    if spin?, do: Owl.Spinner.start(id: :my_spinner, labels: [processing: "Please wait..."])

    final =
      if Keyword.get(options, :stdio, false) do
        setup_stdio(igniter)
      else
        setup_http(igniter, options)
      end

    if spin? do
      if Map.get(final, :issues, []) == [],
        do: Owl.Spinner.stop(id: :my_spinner, resolution: :ok, label: "Done"),
        else: Owl.Spinner.stop(id: :my_spinner, resolution: :error, label: "Error")
    end

    final
  end

  defp setup_stdio(igniter) do
    mcp_json_path = ".mcp.json"

    igniter
    |> Igniter.create_or_update_file(
      mcp_json_path,
      fresh_mcp_json(),
      fn source ->
        current = Rewrite.Source.get(source, :content)
        merged = merge_stdio_entry(current)
        Rewrite.Source.update(source, :content, merged)
      end
    )
    |> Igniter.add_notice(stdio_notice(mcp_json_path))
  end

  @doc false
  # Public for tests. Returns the JSON contents we write when no .mcp.json
  # exists yet — a fresh file with just the mishka-chelekom stdio entry.
  def fresh_mcp_json do
    Jason.encode!(%{"mcpServers" => %{"mishka-chelekom" => stdio_entry()}}, pretty: true) <> "\n"
  end

  @doc false
  # Public for tests. Given the current contents of a .mcp.json (any string),
  # return new contents that:
  #   * preserve any other mcpServers entries the user already has
  #   * insert/replace the mishka-chelekom entry with the stdio config
  # If the current contents are not valid JSON, we overwrite with a fresh file
  # rather than silently corrupt the user's data.
  def merge_stdio_entry(current) when is_binary(current) do
    case Jason.decode(current) do
      {:ok, %{} = decoded} ->
        servers = Map.get(decoded, "mcpServers", %{})
        servers = Map.put(servers, "mishka-chelekom", stdio_entry())
        Jason.encode!(Map.put(decoded, "mcpServers", servers), pretty: true) <> "\n"

      _ ->
        fresh_mcp_json()
    end
  end

  defp stdio_entry do
    %{
      "type" => "stdio",
      "command" => "mix",
      "args" => ["mishka.mcp.server", "--transport", "stdio"],
      "env" => %{"MIX_QUIET" => "1"}
    }
  end

  defp stdio_notice(path) do
    """

    Stdio MCP setup complete!

    Wrote #{path} with the mishka-chelekom entry:

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

    ## Next Steps

    1. Restart Claude Code (or your MCP client) so it reads the new
       #{path}.
    2. Inside the client, verify the connection (in Claude Code: `/mcp`).

    No server to start — your MCP client will spawn `mix mishka.mcp.server
    --transport stdio` itself whenever it needs to talk to chelekom.
    `MIX_QUIET=1` keeps Mix's compile output off stdout so the protocol
    handshake stays clean even after code changes.
    """
  end

  defp setup_http(igniter, options) do
    mcp_path = Keyword.get(options, :path, "/mcp")
    dev_only = Keyword.get(options, :dev_only, true)

    app_name = Igniter.Project.Application.app_name(igniter)
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    router_module = Module.concat(web_module, Router)

    # Add the route to the router (uses MishkaChelekom.MCP.Server directly)
    igniter = add_mcp_route(igniter, router_module, mcp_path, dev_only, app_name)

    igniter
    |> Igniter.add_notice("""

    MCP Server setup complete!

    ## Next Steps

    1. Start your Phoenix server: `mix phx.server`
    2. Connect your AI tools (uses Phoenix port, not 4003):

       Claude Code:
         claude mcp add --transport http mishka-chelekom http://localhost:4000#{mcp_path}

       Cursor/VSCode (.mcp.json):
         {
           "mcpServers": {
             "mishka-chelekom": {
               "type": "http",
               "url": "http://localhost:4000#{mcp_path}"
             }
           }
         }

    Note: The MCP endpoint runs on your Phoenix port (default 4000),
    not on port 4003 like the standalone server.

    ## Available MCP Tools (11)

    - generate_component - Generate mix command for a single component
    - generate_components - Generate mix command for multiple components
    - get_component_info - Get component configuration options (variants, colors, sizes)
    - get_example - Get HEEx code examples with usage patterns
    - get_js_hook_info - Get JavaScript hook documentation
    - get_mix_task_info - Get mix task documentation
    - search_components - Search components by name or functionality
    - uninstall_component - Generate uninstall command
    - update_config - Update project configuration settings
    - validate_config - Validate configuration file for errors
    - get_docs - Fetch documentation from mishka.tools

    ## Available MCP Resources (9)

    - list_components - List all available components with categories
    - list_colors - List color variants with CSS variables
    - list_variants - List style variants (default, outline, shadow, etc.)
    - list_sizes - List size options (small, medium, large, etc.)
    - list_spaces - List spacing options
    - list_scripts - List JavaScript hooks (Carousel, Clipboard, etc.)
    - list_dependencies - List component dependencies
    - list_css_variables - List all CSS custom properties
    - get_config - Get current project configuration
    """)
  end

  defp add_mcp_route(igniter, router_module, mcp_path, dev_only, app_name) do
    route_code =
      if dev_only do
        """
        # MCP Server for AI tools (development only)
        if Application.compile_env(#{inspect(app_name)}, :dev_routes) do
          forward "#{mcp_path}", Anubis.Server.Transport.StreamableHTTP.Plug,
            server: MishkaChelekom.MCP.Server
        end
        """
      else
        """
        # MCP Server for AI tools
        forward "#{mcp_path}", Anubis.Server.Transport.StreamableHTTP.Plug,
          server: MishkaChelekom.MCP.Server
        """
      end

    # Add the route after the existing routes
    igniter
    |> Igniter.Project.Module.find_and_update_module!(router_module, fn zipper ->
      # Check if MCP route already exists
      if has_mcp_route?(zipper, mcp_path) do
        {:ok, zipper}
      else
        # Find the last scope or forward and add after it
        case find_insertion_point(zipper) do
          {:ok, zipper} ->
            # Insert the route code after the current position
            new_code = Sourceror.parse_string!(route_code)

            {:ok,
             zipper
             |> Sourceror.Zipper.insert_right(new_code)
             |> Sourceror.Zipper.right()}

          :error ->
            # If no good insertion point, add at the end of the module
            case Igniter.Code.Common.move_to_do_block(zipper) do
              {:ok, zipper} ->
                new_code = Sourceror.parse_string!(route_code)
                {:ok, Sourceror.Zipper.append_child(zipper, new_code)}

              :error ->
                {:ok, zipper}
            end
        end
      end
    end)
  end

  defp has_mcp_route?(zipper, mcp_path) do
    # Search for existing forward to MCP path
    case Sourceror.Zipper.find(zipper, fn node ->
           match?(
             {:forward, _, [{:__block__, _, [^mcp_path]} | _]},
             node
           ) or
             match?(
               {:forward, _, [^mcp_path | _]},
               node
             )
         end) do
      nil -> false
      _ -> true
    end
  end

  defp find_insertion_point(zipper) do
    # Try to find the last scope or pipeline in the router
    case Igniter.Code.Common.move_to_do_block(zipper) do
      {:ok, zipper} ->
        # Move to the last child in the do block
        zipper
        |> Sourceror.Zipper.down()
        |> case do
          nil ->
            :error

          zipper ->
            # Find the last sibling
            find_last_sibling(zipper)
        end

      :error ->
        :error
    end
  end

  defp find_last_sibling(zipper) do
    case Sourceror.Zipper.right(zipper) do
      nil -> {:ok, zipper}
      next_zipper -> find_last_sibling(next_zipper)
    end
  end
end
