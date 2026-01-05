defmodule MishkaChelekom.MCP.Tools.GetMixTaskInfo do
  @moduledoc """
  Get information about Mishka Chelekom Mix tasks.

  Reads documentation from usage-rules/mix-tasks.md.
  Provides detailed info about available CLI commands for component generation,
  uninstallation, CSS configuration, and asset management.

  ## Usage

      get_mix_task_info()

  ## Available Mix Tasks

  - `mix mishka.ui.gen.component` - Generate a single component
  - `mix mishka.ui.gen.components` - Generate multiple components
  - `mix mishka.ui.uninstall` - Remove installed components
  - `mix mishka.ui.add` - Import from external sources
  - `mix mishka.ui.export` - Export components to JSON
  - `mix mishka.ui.css.config` - Manage CSS configuration
  - `mix mishka.assets.install` - Run package manager commands
  - `mix mishka.assets.deps` - Manage JS dependencies
  """

  use Anubis.Server.Component, type: :tool

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.PathHelper

  schema do
    field(:task, :string,
      required: false,
      description:
        "Specific task name (e.g., 'gen.component', 'uninstall'). Leave empty for full documentation."
    )
  end

  @impl true
  def execute(params, frame) do
    task = params[:task]

    content =
      if task && task != "" do
        get_task_section(task)
      else
        get_full_documentation()
      end

    response =
      Response.tool()
      |> Response.text(content)

    {:reply, response, frame}
  end

  defp get_full_documentation do
    usage_rules_path = PathHelper.mix_tasks_doc_path()

    if File.exists?(usage_rules_path) do
      case File.read(usage_rules_path) do
        {:ok, content} ->
          """
          #{content}

          ---
          📖 Full CLI docs: https://mishka.tools/chelekom/docs/cli
          """

        {:error, _} ->
          fallback_response()
      end
    else
      fallback_response()
    end
  end

  defp get_task_section(task) do
    # Normalize task name
    normalized =
      task
      |> String.downcase()
      |> String.replace("mix mishka.", "")
      |> String.replace("mishka.", "")
      |> String.replace(".", "_")

    # Map common names to full task names
    task_mapping = %{
      "gen_component" => "mishka.ui.gen.component",
      "gen_components" => "mishka.ui.gen.components",
      "generate" => "mishka.ui.gen.component",
      "uninstall" => "mishka.ui.uninstall",
      "remove" => "mishka.ui.uninstall",
      "add" => "mishka.ui.add",
      "import" => "mishka.ui.add",
      "export" => "mishka.ui.export",
      "css" => "mishka.ui.css.config",
      "css_config" => "mishka.ui.css.config",
      "assets_install" => "mishka.assets.install",
      "assets_deps" => "mishka.assets.deps",
      "deps" => "mishka.assets.deps"
    }

    full_task =
      Map.get(task_mapping, normalized, "mishka.ui.#{String.replace(normalized, "_", ".")}")

    # Read full docs and try to extract section
    usage_rules_path = PathHelper.mix_tasks_doc_path()

    if File.exists?(usage_rules_path) do
      case File.read(usage_rules_path) do
        {:ok, content} ->
          extract_task_section(content, full_task)

        {:error, _} ->
          task_not_found(task)
      end
    else
      task_not_found(task)
    end
  end

  defp extract_task_section(content, task_name) do
    # Try to find section by task name (## mix mishka.ui.xxx)
    section_pattern = ~r/## mix #{Regex.escape(task_name)}.*?(?=\n## mix |\n---|\z)/s

    case Regex.run(section_pattern, content) do
      [section] ->
        """
        #{section}

        ---
        📖 Full CLI docs: https://mishka.tools/chelekom/docs/cli
        """

      nil ->
        # Return full docs if section not found
        """
        # Mix Task: #{task_name}

        Section not found. Here's the full documentation:

        #{content}

        ---
        📖 Full CLI docs: https://mishka.tools/chelekom/docs/cli
        """
    end
  end

  defp task_not_found(task) do
    """
    # Mix Task Not Found: #{task}

    ## Available Mix Tasks

    | Task | Description |
    |------|-------------|
    | `mix mishka.ui.gen.component` | Generate a single component |
    | `mix mishka.ui.gen.components` | Generate multiple components at once |
    | `mix mishka.ui.uninstall` | Remove installed components |
    | `mix mishka.ui.add` | Import from external sources |
    | `mix mishka.ui.export` | Export components to JSON |
    | `mix mishka.ui.css.config` | Manage CSS configuration |
    | `mix mishka.assets.install` | Run package manager commands |
    | `mix mishka.assets.deps` | Manage JS dependencies |

    ## Quick Examples

    ```bash
    # Generate button component
    mix mishka.ui.gen.component button

    # Generate multiple components
    mix mishka.ui.gen.components button,alert,modal

    # Uninstall a component
    mix mishka.ui.uninstall accordion

    # Initialize CSS config
    mix mishka.ui.css.config --init
    ```

    ---
    📖 Full CLI docs: https://mishka.tools/chelekom/docs/cli
    """
  end

  defp fallback_response do
    """
    # Mishka Chelekom Mix Tasks

    Documentation file not found at usage-rules/mix-tasks.md

    ## Available Mix Tasks

    | Task | Description |
    |------|-------------|
    | `mix mishka.ui.gen.component` | Generate a single component |
    | `mix mishka.ui.gen.components` | Generate multiple components |
    | `mix mishka.ui.uninstall` | Remove installed components |
    | `mix mishka.ui.add` | Import from external sources |
    | `mix mishka.ui.export` | Export components to JSON |
    | `mix mishka.ui.css.config` | Manage CSS configuration |
    | `mix mishka.assets.install` | Run package manager commands |
    | `mix mishka.assets.deps` | Manage JS dependencies |

    ---
    📖 Full CLI docs: https://mishka.tools/chelekom/docs/cli
    """
  end
end
