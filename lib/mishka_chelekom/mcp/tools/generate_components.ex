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
    parts = ["mix mishka.ui.gen.components"]

    # Add components list (if not all)
    components = params[:components]

    parts =
      if components && components != "" && components != "all" do
        parts ++ [components]
      else
        parts
      end

    # Add flags
    parts = if params[:import], do: parts ++ ["--import"], else: parts
    parts = if params[:helpers], do: parts ++ ["--helpers"], else: parts
    parts = if params[:global], do: parts ++ ["--global"], else: parts

    # Add exclude
    parts =
      if params[:exclude] && params[:exclude] != "" do
        parts ++ ["--exclude", params[:exclude]]
      else
        parts
      end

    # Add prefixes
    parts =
      if params[:module_prefix] && params[:module_prefix] != "" do
        parts ++ ["--module-prefix", params[:module_prefix]]
      else
        parts
      end

    parts =
      if params[:component_prefix] && params[:component_prefix] != "" do
        parts ++ ["--component-prefix", params[:component_prefix]]
      else
        parts
      end

    # Always add --yes for non-interactive
    parts = parts ++ ["--yes"]

    Enum.join(parts, " ")
  end

  defp get_components_list(params) do
    components = params[:components]

    cond do
      components == nil || components == "" || components == "all" ->
        # Get all available components
        ComponentConfig.list_components()
        |> Enum.map(& &1.name)

      true ->
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
