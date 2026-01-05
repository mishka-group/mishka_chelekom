defmodule MishkaChelekom.MCP.Server do
  @moduledoc """
  MCP Server for Mishka Chelekom component library.

  Provides tools and resources for AI assistants to:
  - List available components
  - Get component details (variants, colors, sizes)
  - Generate mix commands for component creation
  - Get HEEx code examples

  ## Usage

  Start the server with:

      iex -S mix

  The server runs on `http://localhost:4003/mcp`

  ## Connecting AI Tools

  ### Claude Code
      claude mcp add --transport http mishka-chelekom http://localhost:4003/mcp

  ### Cursor / VSCode (.mcp.json)
      {
        "mcpServers": {
          "mishka-chelekom": {
            "type": "http",
            "url": "http://localhost:4003/mcp"
          }
        }
      }
  """

  use Anubis.Server,
    name: "Mishka Chelekom",
    version: "0.0.9",
    capabilities: [:tools, :resources]

  # Resources - Data AI can read
  component(MishkaChelekom.MCP.Resources.ListComponents)
  component(MishkaChelekom.MCP.Resources.ListColors)
  component(MishkaChelekom.MCP.Resources.ListVariants)
  component(MishkaChelekom.MCP.Resources.ListSizes)
  component(MishkaChelekom.MCP.Resources.ListSpaces)
  component(MishkaChelekom.MCP.Resources.ListScripts)
  component(MishkaChelekom.MCP.Resources.ListDependencies)
  component(MishkaChelekom.MCP.Resources.GetConfig)
  component(MishkaChelekom.MCP.Resources.ListCssVariables)

  # Tools - Actions AI can perform
  component(MishkaChelekom.MCP.Tools.GenerateComponent)
  component(MishkaChelekom.MCP.Tools.GenerateComponents)
  component(MishkaChelekom.MCP.Tools.GetComponentInfo)
  component(MishkaChelekom.MCP.Tools.GetExample)
  component(MishkaChelekom.MCP.Tools.GetJsHookInfo)
  component(MishkaChelekom.MCP.Tools.GetMixTaskInfo)
  component(MishkaChelekom.MCP.Tools.SearchComponents)
  component(MishkaChelekom.MCP.Tools.UninstallComponent)
  component(MishkaChelekom.MCP.Tools.UpdateConfig)
  component(MishkaChelekom.MCP.Tools.ValidateConfig)
  component(MishkaChelekom.MCP.Tools.GetDocs)
end
