defmodule MishkaChelekom.MCP.Tools.UninstallComponent do
  @moduledoc """
  Generate mix commands for uninstalling Mishka Chelekom components.

  Returns the appropriate `mix mishka.ui.uninstall` command with options.

  ## Usage

      uninstall_component(name: "accordion")
      uninstall_component(name: "accordion,button,alert")
      uninstall_component(all: true)

  ## Options

  - `name` - Component name(s) to uninstall (comma-separated)
  - `all` - Uninstall all Mishka components
  - `dry_run` - Preview what will be removed without making changes
  - `force` - Force removal even if other components depend on it
  - `keep_js` - Keep JavaScript files even if unused
  """

  use Anubis.Server.Component, type: :tool

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.ComponentConfig

  schema do
    field(:name, :string,
      description:
        "Component name(s) to uninstall (comma-separated, e.g., 'accordion' or 'button,alert,modal')"
    )

    field(:all, :boolean, description: "Uninstall all Mishka components")

    field(:dry_run, :boolean, description: "Preview removal without making changes")

    field(:force, :boolean,
      description: "Force removal even when other components depend on them"
    )

    field(:keep_js, :boolean,
      description: "Keep JavaScript files even if unused by remaining components"
    )
  end

  @impl true
  def execute(params, frame) do
    command = build_command(params)
    warnings = get_warnings(params)

    content = format_response(command, params, warnings)

    response =
      Response.tool()
      |> Response.text(content)

    {:reply, response, frame}
  end

  defp build_command(params) do
    parts = ["mix mishka.ui.uninstall"]

    # Add --all flag or component names
    parts =
      cond do
        params[:all] ->
          parts ++ ["--all"]

        params[:name] && params[:name] != "" ->
          parts ++ [params[:name]]

        true ->
          parts
      end

    # Add optional flags
    parts = if params[:dry_run], do: parts ++ ["--dry-run"], else: parts
    parts = if params[:force], do: parts ++ ["--force"], else: parts
    parts = if params[:keep_js], do: parts ++ ["--keep-js"], else: parts

    # Add --yes for non-interactive (unless dry-run)
    parts =
      if params[:dry_run] do
        parts
      else
        parts ++ ["--yes"]
      end

    Enum.join(parts, " ")
  end

  defp get_warnings(params) do
    warnings = []

    # Check dependencies if specific components are being removed
    warnings =
      if params[:name] && !params[:all] && !params[:force] do
        components = String.split(params[:name], ",") |> Enum.map(&String.trim/1)
        dependencies = ComponentConfig.list_dependencies()

        # Find components that depend on the ones being removed
        dependent_components =
          dependencies
          |> Enum.filter(fn {_comp, deps} ->
            necessary = deps.necessary || []
            Enum.any?(components, &(&1 in necessary))
          end)
          |> Enum.map(fn {comp, _} -> comp end)

        if dependent_components != [] do
          warnings ++
            [
              "⚠️ These components depend on the ones you're removing: #{Enum.join(dependent_components, ", ")}",
              "   Use --force to remove anyway, or remove dependent components first."
            ]
        else
          warnings
        end
      else
        warnings
      end

    # Add all-removal warning
    if params[:all] do
      warnings ++
        [
          "⚠️ This will remove ALL Mishka Chelekom files from your project!",
          "   Including: components, CSS, JS, and config files."
        ]
    else
      warnings
    end
  end

  defp format_response(command, params, warnings) do
    warnings_section =
      if warnings != [] do
        """
        ## ⚠️ Warnings

        #{Enum.join(warnings, "\n")}

        """
      else
        ""
      end

    dry_run_note =
      if params[:dry_run] do
        """
        ## 🔍 Dry Run Mode

        This command will only PREVIEW what will be removed, without making any changes.
        Remove `--dry-run` to actually perform the uninstall.

        """
      else
        ""
      end

    """
    # Uninstall Component(s)

    ## Command

    ```bash
    #{command}
    ```

    #{dry_run_note}#{warnings_section}

    ## What This Will Do

    #{if params[:all], do: "- Remove ALL component files\n- Remove CSS vendor file\n- Remove JS vendor file\n- Remove config file\n- Clean up imports", else: "- Remove specified component file(s)\n- Clean up related imports\n- Remove unused JS files (unless --keep-js)"}

    ## Recommended Usage

    ```bash
    # Preview what will be removed (safe)
    mix mishka.ui.uninstall #{params[:name] || "--all"} --dry-run

    # Actually remove (with confirmation)
    mix mishka.ui.uninstall #{params[:name] || "--all"}

    # Force removal ignoring dependencies
    mix mishka.ui.uninstall #{params[:name] || "--all"} --force --yes

    # Full cleanup
    mix mishka.ui.uninstall --all --yes
    ```

    ---
    📖 Full docs: https://mishka.tools/chelekom/docs/cli
    """
  end
end
