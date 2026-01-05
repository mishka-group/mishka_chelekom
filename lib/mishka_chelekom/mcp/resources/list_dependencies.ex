defmodule MishkaChelekom.MCP.Resources.ListDependencies do
  @moduledoc """
  List all component dependencies for Mishka Chelekom components.

  Dependencies are read dynamically from priv/components/*.exs configuration files.
  Components may have necessary (required) or optional dependencies on other components.
  """

  use Anubis.Server.Component,
    type: :resource,
    uri: "mishka_chelekom://dependencies",
    name: "list_dependencies",
    description:
      "List all component dependencies (necessary and optional) for Mishka Chelekom components",
    mime_type: "application/json"

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.ComponentConfig

  @impl true
  def read(_params, frame) do
    dependencies = ComponentConfig.list_dependencies()
    necessary_deps = ComponentConfig.list_necessary_deps()
    optional_deps = ComponentConfig.list_optional_deps()

    # Count components with dependencies
    components_with_deps = Map.keys(dependencies)

    response =
      Response.resource()
      |> Response.json(%{
        total_components_with_dependencies: length(components_with_deps),
        all_necessary_dependencies: necessary_deps,
        all_optional_dependencies: optional_deps,
        by_component: dependencies,
        description:
          "Component dependencies - necessary deps are auto-installed, optional can be added manually",
        note: %{
          necessary:
            "These components will be automatically installed when you generate the parent component",
          optional: "These components can be optionally added for enhanced functionality"
        },
        usage_example:
          "mix mishka.ui.gen.component modal  # Will auto-install 'icon' if it's a necessary dependency"
      })

    {:reply, response, frame}
  end
end
