defmodule Mix.Tasks.Mishka.Mcp.Setup do
  @moduledoc """
  Sets up the Mishka Chelekom MCP Server in your Phoenix application.

  This task adds the necessary configuration to your Phoenix router to serve
  the MCP (Model Context Protocol) endpoint, allowing AI tools like Claude Code,
  Cursor, and Claude Desktop to interact with your Mishka Chelekom components.

  ## Usage

      mix mishka.mcp.setup

  ## Options

  * `--path` or `-p` - Custom MCP endpoint path (default: "/mcp")
  * `--dev-only` - Only enable MCP in development (default: true)
  * `--yes` - Skip confirmation prompts

  ## What This Task Does

  1. Adds the MCP route to your Phoenix router
  2. Configures the route to use `Anubis.Server.Transport.StreamableHTTP.Plug`
  3. Wraps it in a dev_routes condition (unless --dev-only=false)

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
        yes: :boolean
      ],
      defaults: [
        path: "/mcp",
        dev_only: true
      ],
      aliases: [
        p: :path
      ]
    }
  end

  def igniter(igniter) do
    options = igniter.args.options
    mcp_path = Keyword.get(options, :path, "/mcp")
    dev_only = Keyword.get(options, :dev_only, true)

    app_name = Igniter.Project.Application.app_name(igniter)
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    router_module = Module.concat(web_module, Router)

    # Create the MCP server module
    igniter = create_mcp_server_module(igniter, web_module)

    # Add the route to the router
    igniter = add_mcp_route(igniter, router_module, web_module, mcp_path, dev_only, app_name)

    igniter
    |> Igniter.add_notice("""

    MCP Server setup complete!

    ## Next Steps

    1. Run `mix deps.get` to install dependencies
    2. Start your Phoenix server: `mix phx.server`
    3. Connect your AI tools:

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

    ## Available MCP Tools

    - list_components - List all available components
    - get_component_info - Get component configuration options
    - get_example - Get HEEx code examples
    - search_components - Search by name or functionality
    - get_docs - Fetch documentation
    """)
  end

  defp create_mcp_server_module(igniter, web_module) do
    mcp_server_module = Module.concat(web_module, MCPServer)

    proper_location =
      Igniter.Project.Module.proper_location(igniter, mcp_server_module)

    content = """
    defmodule #{inspect(mcp_server_module)} do
      @moduledoc \"\"\"
      MCP Server for Mishka Chelekom components.

      This module re-exports the MishkaChelekom.MCP.Server for use in your Phoenix application.
      It allows AI tools to interact with the component library.

      ## Usage

      The server is automatically mounted at `/mcp` in development mode.
      Connect your AI tools using HTTP transport.
      \"\"\"

      use Anubis.Server,
        name: "mishka-chelekom",
        version: "0.1.0",
        capabilities: [:tools, :resources]

      # Re-export all components from MishkaChelekom.MCP.Server
      def __components__() do
        MishkaChelekom.MCP.Server.__components__()
      end

      def __components__(type) do
        MishkaChelekom.MCP.Server.__components__(type)
      end
    end
    """

    igniter
    |> Igniter.create_new_file(proper_location, content, on_exists: :skip)
  end

  defp add_mcp_route(igniter, router_module, web_module, mcp_path, dev_only, app_name) do
    mcp_server_module = Module.concat(web_module, MCPServer)

    route_code =
      if dev_only do
        """
        # MCP Server for AI tools (development only)
        if Application.compile_env(#{inspect(app_name)}, :dev_routes) do
          forward "#{mcp_path}", Anubis.Server.Transport.StreamableHTTP.Plug,
            server: #{inspect(mcp_server_module)}
        end
        """
      else
        """
        # MCP Server for AI tools
        forward "#{mcp_path}", Anubis.Server.Transport.StreamableHTTP.Plug,
          server: #{inspect(mcp_server_module)}
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
