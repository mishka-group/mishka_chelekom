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

  # The path is built only once ComponentConfig.known_js_hook?/1 accepted the name.
  # sobelow_skip ["Traversal.FileModule"]
  defp get_hook_info(name) do
    # Normalize name (handle both "collapsible" and "Collapsible")
    normalized_name = name |> String.downcase() |> String.replace(" ", "_")

    # The path is built only from a hook this kit ships, never from the name as given.
    with true <- ComponentConfig.known_js_hook?(normalized_name),
         usage_rules_path = PathHelper.js_hook_doc_path(normalized_name),
         true <- File.exists?(usage_rules_path),
         {:ok, content} <- File.read(usage_rules_path) do
      format_hook_doc(normalized_name, content)
    else
      _not_found -> fallback_response(normalized_name)
    end
  end

  defp list_all_hooks do
    hooks = ComponentConfig.list_js_hooks()
    scripts_by_component = ComponentConfig.list_scripts()

    hooks_info =
      Enum.map_join(hooks, "\n", fn hook ->
        using_components = using_components(hook, scripts_by_component)

        components_str =
          if using_components == [] do
            "manual use"
          else
            Enum.join(using_components, ", ")
          end

        "- **#{hook.module}** (`#{hook.file}`) - Used by: #{components_str}"
      end)

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

  # The components whose `scripts:` name this hook's file.
  defp using_components(hook, scripts_by_component) do
    for {comp, scripts} <- scripts_by_component,
        Enum.any?(scripts, &String.contains?(&1[:file] || &1.file, hook.name)),
        do: comp
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
    hook_names = Enum.map_join(hooks, ", ", & &1.name)

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
    |> Enum.map_join(&String.capitalize/1)
  end
end
