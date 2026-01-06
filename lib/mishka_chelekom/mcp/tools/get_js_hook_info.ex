defmodule MishkaChelekom.MCP.Tools.GetJsHookInfo do
  @moduledoc """
  Get information about JavaScript hooks used by Mishka Chelekom components.

  Reads documentation from usage-rules/js/*.md files.
  JS hooks provide interactive behavior for components like clipboard, carousel, etc.

  ## Usage

      get_js_hook_info(name: "clipboard")
      get_js_hook_info(name: "collapsible")

  ## Available Hooks

  - clipboard - Copy to clipboard functionality
  - collapsible - Accordion/collapse behavior
  - carousel - Image/content carousel
  - combobox - Searchable select with autocomplete
  - floating - Tooltip/popover positioning
  - gallery_filter - Gallery filtering
  - scroll_area - Custom scrollbar
  - sidebar - Sidebar toggle behavior
  """

  use Anubis.Server.Component, type: :tool

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.ComponentConfig
  alias MishkaChelekom.MCP.PathHelper

  schema do
    field(:name, :string,
      required: false,
      description:
        "JS hook name (e.g., clipboard, collapsible, carousel). Leave empty to list all hooks."
    )
  end

  @impl true
  def execute(params, frame) do
    name = params[:name]

    content =
      if name && name != "" do
        get_hook_info(name)
      else
        list_all_hooks()
      end

    response =
      Response.tool()
      |> Response.text(content)

    {:reply, response, frame}
  end

  defp get_hook_info(name) do
    # Normalize name (handle both "collapsible" and "Collapsible")
    normalized_name = name |> String.downcase() |> String.replace(" ", "_")

    usage_rules_path = PathHelper.js_hook_doc_path(normalized_name)

    if File.exists?(usage_rules_path) do
      case File.read(usage_rules_path) do
        {:ok, content} ->
          format_hook_doc(normalized_name, content)

        {:error, _} ->
          fallback_response(normalized_name)
      end
    else
      fallback_response(normalized_name)
    end
  end

  defp list_all_hooks do
    hooks = ComponentConfig.list_js_hooks()
    scripts_by_component = ComponentConfig.list_scripts()

    hooks_info =
      Enum.map(hooks, fn hook ->
        # Find which components use this hook
        using_components =
          scripts_by_component
          |> Enum.filter(fn {_comp, scripts} ->
            Enum.any?(scripts, fn script ->
              file = script[:file] || script.file
              String.contains?(file, hook.name)
            end)
          end)
          |> Enum.map(fn {comp, _} -> comp end)

        components_str =
          if using_components == [] do
            "manual use"
          else
            Enum.join(using_components, ", ")
          end

        "- **#{hook.module}** (`#{hook.file}`) - Used by: #{components_str}"
      end)
      |> Enum.join("\n")

    """
    # ⚡ JavaScript Hooks

    Mishka Chelekom provides #{length(hooks)} JavaScript hooks for interactive behavior.

    ## Available Hooks

    #{hooks_info}

    ## Location

    Hooks are located in `priv/assets/js/` and copied to your project's `assets/vendor/` when generating components that need them.

    ## Usage in LiveView

    ```javascript
    // In app.js
    import { Clipboard, Collapsible, Carousel } from "./vendor/mishka_components.js"

    let liveSocket = new LiveSocket("/live", Socket, {
      hooks: { Clipboard, Collapsible, Carousel }
    })
    ```

    ## Get Detailed Info

    Use `get_js_hook_info(name: "clipboard")` to get documentation for a specific hook.
    """
  end

  defp format_hook_doc(name, content) do
    """
    # #{format_name(name)} JavaScript Hook

    #{content}

    ---
    📁 Location: `priv/assets/js/#{name}.js`
    📖 Full docs: https://mishka.tools/chelekom/docs
    """
  end

  defp fallback_response(name) do
    hooks = ComponentConfig.list_js_hooks()
    hook_names = Enum.map(hooks, & &1.name) |> Enum.join(", ")

    """
    # #{format_name(name)} Hook

    Documentation not found for hook: #{name}

    ## Available Hooks

    #{hook_names}

    ## Basic Usage

    ```javascript
    // In app.js
    import { #{format_name(name)} } from "./vendor/mishka_components.js"

    let liveSocket = new LiveSocket("/live", Socket, {
      hooks: { #{format_name(name)} }
    })
    ```

    ## Get Full Documentation

    📖 Visit: https://mishka.tools/chelekom/docs
    """
  end

  defp format_name(name) do
    name
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join("")
  end
end
