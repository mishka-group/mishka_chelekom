defmodule MishkaChelekom.MCP.Resources.ListComponents do
  @moduledoc """
  List all available Mishka Chelekom components.

  Returns component names organized by category, read dynamically from
  priv/components/*.exs configuration files.
  """

  use Anubis.Server.Component,
    type: :resource,
    uri: "mishka_chelekom://components",
    name: "list_components",
    description: "List all available Mishka Chelekom UI components with their categories",
    mime_type: "text/plain"

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.ComponentConfig

  @category_icons %{
    "general" => "🧩",
    "forms" => "📝",
    "navigations" => "🧭",
    "overlays" => "🪟",
    "media" => "🎬",
    "feedback" => "💬"
  }

  @impl true
  def read(_params, frame) do
    components = ComponentConfig.list_components()
    categories = ComponentConfig.components_by_category()
    scripts = ComponentConfig.list_scripts()
    dependencies = ComponentConfig.list_dependencies()
    actual_count = ComponentConfig.count_actual_components()
    js_hooks = ComponentConfig.list_js_hooks()

    # Build formatted summary
    summary =
      build_summary(categories, length(components), actual_count, scripts, dependencies, js_hooks)

    response =
      Response.resource()
      |> Response.text(summary)

    {:reply, response, frame}
  end

  defp build_summary(categories, config_count, actual_count, scripts, dependencies, js_hooks) do
    category_sections =
      categories
      |> Enum.sort_by(fn {_cat, comps} -> -length(comps) end)
      |> Enum.map(fn {category, comps} ->
        icon = Map.get(@category_icons, category, "📦")
        count = length(comps)

        # Group components by features
        {with_js, _without_js} = Enum.split_with(comps, &Map.has_key?(scripts, &1))
        {with_deps, _without_deps} = Enum.split_with(comps, &Map.has_key?(dependencies, &1))

        components_list = comps |> Enum.sort() |> Enum.join(", ")

        js_note =
          if length(with_js) > 0,
            do: "\n   ⚡ Requires JS: #{Enum.join(Enum.sort(with_js), ", ")}",
            else: ""

        deps_note =
          if length(with_deps) > 0,
            do: "\n   🔗 Has dependencies: #{Enum.join(Enum.sort(with_deps), ", ")}",
            else: ""

        """
        #{icon} **#{String.capitalize(category)}** (#{count})
           #{components_list}#{js_note}#{deps_note}
        """
      end)
      |> Enum.join("\n")

    # JS Hooks section
    hooks_list = js_hooks |> Enum.map(& &1.module) |> Enum.join(", ")

    """
    # 🎨 Mishka Chelekom Components

    📊 **#{actual_count} total components** (#{config_count} config files) across #{map_size(categories)} categories

    #{category_sections}

    ---

    ## ⚡ JavaScript Hooks (#{length(js_hooks)})

    #{hooks_list}

    These hooks are used by some components automatically, or can be used manually in your LiveView.
    Location: `priv/assets/js/`

    ---

    ## 📚 Links

    🌐 **Site:** https://mishka.tools/chelekom
    📖 **Docs:** https://mishka.tools/chelekom/docs

    ---

    ## 🛠️ Commands

    ⚡ **Generate:** `mix mishka.ui.gen.component <name>`
    🔍 **Search:** Use `search_components` tool to find components
    ℹ️  **Info:** Use `get_component_info` tool for detailed options

    ---

    ## 💡 Usage Rules (AI Context)

    Sync component documentation to your AI context file:

    ```
    mix usage_rules.sync CLAUDE.md --all --inline usage_rules:all --link-to-folder deps
    ```

    This generates inline documentation for AI tools (Claude Code, Cursor) to understand your project's components.
    📖 Learn more: https://hexdocs.pm/usage_rules/readme.html
    """
  end
end
