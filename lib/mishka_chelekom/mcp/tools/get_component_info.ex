defmodule MishkaChelekom.MCP.Tools.GetComponentInfo do
  @moduledoc """
  Get detailed information about a specific Mishka Chelekom component.

  Combines data from:
  - priv/components/*.exs (config: variants, colors, sizes, dependencies)
  - priv/usage-rules/components/*.md (documentation: attributes, slots, examples)

  ## Usage

      get_component_info(name: "alert")
      get_component_info(name: "button")
  """

  use Anubis.Server.Component, type: :tool

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.PathHelper

  schema do
    field(:name, :string,
      required: true,
      description: "Component name (e.g., alert, button, modal, accordion)"
    )
  end

  @impl true
  def execute(%{name: name}, frame) do
    config_info = get_config_info(name)
    usage_rules_info = get_usage_rules_info(name)

    content = format_response(name, config_info, usage_rules_info)

    response =
      Response.tool()
      |> Response.text(content)

    {:reply, response, frame}
  end

  # Read from priv/components/{name}.exs
  defp get_config_info(name) do
    config_path =
      :code.priv_dir(:mishka_chelekom)
      |> Path.join("components/#{name}.exs")

    if File.exists?(config_path) do
      try do
        {[{_key, config}], _bindings} = Code.eval_file(config_path)
        args = Keyword.get(config, :args, [])

        %{
          found: true,
          category: Keyword.get(config, :category, "general"),
          variants: Keyword.get(args, :variant, []),
          colors: Keyword.get(args, :color, []),
          sizes: Keyword.get(args, :size, []),
          rounded: Keyword.get(args, :rounded, []),
          padding: Keyword.get(args, :padding, []),
          space: Keyword.get(args, :space, []),
          types: Keyword.get(args, :only, []),
          helpers: format_helpers(Keyword.get(args, :helpers, [])),
          necessary_deps: Keyword.get(config, :necessary, []),
          optional_deps: Keyword.get(config, :optional, []),
          scripts: Keyword.get(config, :scripts, [])
        }
      rescue
        _ -> %{found: false}
      end
    else
      %{found: false}
    end
  end

  # Read from priv/usage-rules/components/{name}.md
  defp get_usage_rules_info(name) do
    usage_rules_path = PathHelper.component_doc_path(name)

    if File.exists?(usage_rules_path) do
      case File.read(usage_rules_path) do
        {:ok, content} -> %{found: true, content: content}
        {:error, _} -> %{found: false}
      end
    else
      %{found: false}
    end
  end

  defp format_response(name, config_info, usage_rules_info) do
    sections = [format_header(name)]

    # Config info section
    sections =
      if config_info.found do
        sections ++ [format_config_section(config_info)]
      else
        sections
      end

    # Usage rules section (full documentation)
    sections =
      if usage_rules_info.found do
        sections ++ ["\n---\n\n## 📚 Full Documentation\n\n#{usage_rules_info.content}"]
      else
        sections
      end

    # Footer
    sections = sections ++ [format_footer(name)]

    Enum.join(sections, "\n")
  end

  defp format_header(name) do
    """
    # #{format_name(name)} Component

    📖 Docs: https://mishka.tools/chelekom/docs/#{format_doc_url(name)}
    ⚡ Generate: `mix mishka.ui.gen.component #{name}`
    """
  end

  defp format_config_section(config) do
    lines = ["## ⚙️ Configuration Options\n", "**Category:** #{config.category}\n"]

    lines = add_if_not_empty(lines, config.types, "Component Types")
    lines = add_if_not_empty(lines, config.variants, "Variants")
    lines = add_if_not_empty(lines, config.colors, "Colors")
    lines = add_if_not_empty(lines, config.sizes, "Sizes")
    lines = add_if_not_empty(lines, config.rounded, "Rounded")
    lines = add_if_not_empty(lines, config.padding, "Padding")
    lines = add_if_not_empty(lines, config.space, "Space")

    lines =
      if config.necessary_deps != [] do
        lines ++
          [
            "**Required Dependencies:** #{Enum.join(config.necessary_deps, ", ")} (auto-installed)\n"
          ]
      else
        lines
      end

    lines =
      if config.optional_deps != [] do
        lines ++ ["**Optional Dependencies:** #{Enum.join(config.optional_deps, ", ")}\n"]
      else
        lines
      end

    lines =
      if config.scripts != [] do
        scripts_list = config.scripts |> Enum.map(&(&1[:module] || &1.module)) |> Enum.join(", ")
        lines ++ ["**JavaScript Hooks:** #{scripts_list}\n"]
      else
        lines
      end

    lines =
      if config.helpers != [] do
        lines ++ ["**Helper Functions:** #{Enum.join(config.helpers, ", ")}\n"]
      else
        lines
      end

    Enum.join(lines, "")
  end

  defp add_if_not_empty(lines, list, label) do
    if list != [] do
      lines ++ ["**#{label}:** #{Enum.join(list, ", ")}\n"]
    else
      lines
    end
  end

  defp format_footer(name) do
    """

    ---

    ## 🛠️ Quick Commands

    ```bash
    # Generate with all options
    mix mishka.ui.gen.component #{name}

    # Generate with specific options
    mix mishka.ui.gen.component #{name} --color primary,danger --variant default,outline

    # Custom module name
    mix mishka.ui.gen.component #{name} --module MyAppWeb.Components.Custom#{format_name(name)}
    ```
    """
  end

  defp format_name(name) do
    name
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join("")
  end

  defp format_doc_url(name) do
    form_components = [
      "checkbox_card",
      "checkbox_field",
      "color_field",
      "combobox",
      "date_time_field",
      "email_field",
      "fieldset",
      "file_field",
      "form_wrapper",
      "input_field",
      "native_select",
      "number_field",
      "password_field",
      "radio_card",
      "radio_field",
      "range_field",
      "search_field",
      "tel_field",
      "text_field",
      "textarea_field",
      "toggle_field",
      "url_field"
    ]

    url_name = String.replace(name, "_", "-")

    if name in form_components do
      "forms/#{url_name}"
    else
      url_name
    end
  end

  defp format_helpers(helpers) when is_list(helpers) do
    Enum.map(helpers, fn
      {name, arity} -> "#{name}/#{arity}"
      other -> inspect(other)
    end)
  end

  defp format_helpers(_), do: []
end
