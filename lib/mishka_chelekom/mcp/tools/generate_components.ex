defmodule MishkaChelekom.MCP.Tools.GenerateComponents do
  @moduledoc """
  Generate mix commands for creating multiple Mishka Chelekom components at once.

  Returns the appropriate `mix mishka.ui.gen.components` command with options.

  ## Usage

      generate_components(components: "button,alert,modal")
      generate_components(components: "all", import: true, global: true)

  ## Options

  - `components` - Comma-separated list of components, or "all" for all components
  - `import` - Generate import macro file (default: false)
  - `helpers` - Include helper functions in import (default: false)
  - `global` - Replace CoreComponents with Mishka components (default: false)
  - `exclude` - Components to exclude (comma-separated)
  - `module_prefix` - Prefix for module names
  - `component_prefix` - Prefix for function names
  """

  use Anubis.Server.Component, type: :tool

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.ComponentConfig

  schema do
    field(:components, :string,
      required: false,
      description:
        "Comma-separated list of components (e.g., 'button,alert,modal') or 'all' for all components"
    )

    field(:import, :boolean, description: "Generate import macro file for easy component imports")

    field(:helpers, :boolean, description: "Include helper functions in the import file")

    field(:global, :boolean,
      description: "Replace Phoenix CoreComponents with Mishka components globally"
    )

    field(:exclude, :string, description: "Components to exclude (comma-separated)")

    field(:module_prefix, :string,
      description: "Prefix for module names (e.g., 'Mishka' creates MishkaButton)"
    )

    field(:component_prefix, :string,
      description: "Prefix for function names (e.g., 'mishka_' creates mishka_button/1)"
    )
  end

  @impl true
  def execute(params, frame) do
    command = build_command(params)
    components_list = get_components_list(params)

    content = format_response(command, components_list, params)

    response =
      Response.tool()
      |> Response.text(content)

    {:reply, response, frame}
  end

  defp build_command(params) do
    # The components (when not all), the flags and the options given, then --yes for a
    # non-interactive run.
    (["mix mishka.ui.gen.components"] ++
       option(nil, if(params[:components] != "all", do: params[:components])) ++
       flag(params[:import], "--import") ++
       flag(params[:helpers], "--helpers") ++
       flag(params[:global], "--global") ++
       option("--exclude", params[:exclude]) ++
       option("--module-prefix", params[:module_prefix]) ++
       option("--component-prefix", params[:component_prefix]) ++
       ["--yes"])
    |> Enum.join(" ")
  end

  defp flag(value, _flag) when value in [nil, false], do: []
  defp flag(_value, flag), do: [flag]

  defp option(_name, value) when value in [nil, false, ""], do: []
  defp option(nil, value), do: [value]
  defp option(name, value), do: [name, value]

  defp get_components_list(params) do
    components = params[:components]

    if components == nil || components == "" || components == "all" do
      # Get all available components
      ComponentConfig.list_components()
      |> Enum.map(& &1.name)
    else
      String.split(components, ",")
      |> Enum.map(&String.trim/1)
    end
  end

  defp format_response(command, components_list, params) do
    excluded = if params[:exclude], do: String.split(params[:exclude], ","), else: []
    final_components = Enum.reject(components_list, &(&1 in excluded))

    """
    # Generate Multiple Components

    ## Command

    ```bash
    #{command}
    ```

    ## Components to Generate (#{length(final_components)})

    #{Enum.join(final_components, ", ")}

    #{if excluded != [], do: "## Excluded: #{Enum.join(excluded, ", ")}\n", else: ""}

    ## What This Will Do

    1. Generate #{length(final_components)} component files in `lib/your_app_web/components/`
    #{if params[:import], do: "2. Create import macro file `mishka_components.ex`\n", else: ""}
    #{if params[:helpers], do: "3. Include helper functions in import file\n", else: ""}
    #{if params[:global], do: "4. Replace CoreComponents with Mishka components in web module\n", else: ""}

    ## Recommended Commands

    ```bash
    # New project setup (recommended)
    mix mishka.ui.gen.components --import --helpers --global --yes

    # Generate specific components only
    mix mishka.ui.gen.components button,alert,modal,card --yes

    # Generate all except heavy components
    mix mishka.ui.gen.components --exclude carousel,gallery,sidebar --yes
    ```

    ---
    📖 Full docs: https://mishka.tools/chelekom/docs/cli
    """
  end
end
