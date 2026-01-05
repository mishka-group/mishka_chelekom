defmodule MishkaChelekom.MCP.Resources.ListScripts do
  @moduledoc """
  List all JavaScript dependencies for Mishka Chelekom components.

  Scripts are read dynamically from priv/components/*.exs configuration files.
  Some components require JavaScript for interactive behavior.
  """

  use Anubis.Server.Component,
    type: :resource,
    uri: "mishka_chelekom://scripts",
    name: "list_scripts",
    description: "List all JavaScript dependencies required by Mishka Chelekom components",
    mime_type: "application/json"

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.ComponentConfig

  @impl true
  def read(_params, frame) do
    scripts_by_component = ComponentConfig.list_scripts()
    unique_scripts = ComponentConfig.list_unique_scripts()

    # Format unique scripts for display
    formatted_scripts =
      Enum.map(unique_scripts, fn script ->
        %{
          file: script[:file] || script.file,
          module: script[:module] || script.module,
          imports: script[:imports] || script.imports,
          type: script[:type] || script.type
        }
      end)

    # Get list of components that require JS
    components_with_js = Map.keys(scripts_by_component)

    response =
      Response.resource()
      |> Response.json(%{
        total_scripts: length(formatted_scripts),
        total_components_with_js: length(components_with_js),
        unique_scripts: formatted_scripts,
        by_component: scripts_by_component,
        components_requiring_js: components_with_js,
        description: "JavaScript files required by components for interactive behavior",
        note:
          "Scripts are automatically copied to your project when generating components that need them"
      })

    {:reply, response, frame}
  end
end
