defmodule MishkaChelekom.MCP.Resources.GetConfig do
  @moduledoc """
  Read the current Mishka Chelekom configuration from the user's project.

  Returns the contents of `priv/mishka_chelekom/config.exs` if it exists,
  otherwise returns default configuration values.

  ## Configuration Options

  - `exclude_components` - Components to skip during generation
  - `component_colors` - Limit which colors are generated
  - `component_variants` - Limit which variants are generated
  - `component_sizes` - Limit which sizes are generated
  - `component_rounded` - Limit rounded options
  - `component_padding` - Limit padding options
  - `component_space` - Limit space options
  - `component_prefix` - Prefix for function names (e.g., "mishka_")
  - `module_prefix` - Prefix for module names (e.g., "mishka_")
  - `css_overrides` - CSS variable overrides
  - `css_merge_strategy` - :merge or :replace
  - `custom_css_path` - Path to custom CSS file
  """

  use Anubis.Server.Component,
    type: :resource,
    uri: "mishka_chelekom://config",
    name: "get_config",
    description:
      "Read current Mishka Chelekom configuration from priv/mishka_chelekom/config.exs",
    mime_type: "text/plain"

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.PathHelper

  @impl true
  def read(_params, frame) do
    config_path = PathHelper.user_config_path()

    content =
      if File.exists?(config_path) do
        format_existing_config(config_path)
      else
        format_no_config()
      end

    response =
      Response.resource()
      |> Response.text(content)

    {:reply, response, frame}
  end

  defp format_existing_config(config_path) do
    case File.read(config_path) do
      {:ok, raw_content} ->
        parsed = parse_config(config_path)

        """
        # Mishka Chelekom Configuration

        **Config File:** `#{config_path}`
        **Status:** Found

        ---

        ## Current Settings

        ### Component Filters

        | Setting | Value |
        |---------|-------|
        | Excluded Components | #{format_list(parsed[:exclude_components])} |
        | Colors | #{format_list(parsed[:component_colors])} |
        | Variants | #{format_list(parsed[:component_variants])} |
        | Sizes | #{format_list(parsed[:component_sizes])} |
        | Rounded | #{format_list(parsed[:component_rounded])} |
        | Padding | #{format_list(parsed[:component_padding])} |
        | Space | #{format_list(parsed[:component_space])} |

        ### Prefixes

        | Setting | Value |
        |---------|-------|
        | Component Prefix | #{format_value(parsed[:component_prefix])} |
        | Module Prefix | #{format_value(parsed[:module_prefix])} |

        ### CSS Configuration

        | Setting | Value |
        |---------|-------|
        | Merge Strategy | #{parsed[:css_merge_strategy] || ":merge"} |
        | Custom CSS Path | #{format_value(parsed[:custom_css_path])} |
        | CSS Overrides | #{format_overrides_count(parsed[:css_overrides])} |

        #{format_active_overrides(parsed[:css_overrides])}

        ---

        ## Raw Config File

        ```elixir
        #{raw_content}
        ```

        ---

        ## Commands

        ```bash
        # Validate configuration
        mix mishka.ui.css.config --validate

        # Show current configuration
        mix mishka.ui.css.config --show

        # Regenerate CSS with overrides
        mix mishka.ui.css.config --regenerate
        ```
        """

      {:error, reason} ->
        """
        # Mishka Chelekom Configuration

        **Config File:** `#{config_path}`
        **Status:** Error reading file
        **Error:** #{inspect(reason)}
        """
    end
  end

  defp format_no_config do
    """
    # Mishka Chelekom Configuration

    **Status:** No configuration file found

    The config file `priv/mishka_chelekom/config.exs` does not exist yet.
    It will be created automatically when you generate components with `--global` flag,
    or you can create it manually.

    ---

    ## Create Config File

    ```bash
    # Create sample config
    mix mishka.ui.css.config --init

    # Or generate components with global flag (creates config automatically)
    mix mishka.ui.gen.components --import --helpers --global --yes
    ```

    ---

    ## Default Settings (when no config exists)

    | Setting | Default |
    |---------|---------|
    | Excluded Components | (none) |
    | Colors | (all) |
    | Variants | (all) |
    | Sizes | (all) |
    | Rounded | (all) |
    | Padding | (all) |
    | Space | (all) |
    | Component Prefix | (none) |
    | Module Prefix | (none) |
    | CSS Merge Strategy | :merge |
    | CSS Overrides | (none) |

    ---

    ## Available Configuration Options

    ```elixir
    config :mishka_chelekom,
      # Exclude specific components
      exclude_components: ["carousel", "gallery"],

      # Limit colors (reduces generated code)
      component_colors: ["primary", "danger", "success"],

      # Limit variants
      component_variants: ["default", "outline"],

      # Prefix function names: <.button> becomes <.mishka_button>
      component_prefix: "mishka_",

      # Prefix module names: Button becomes MishkaButton
      module_prefix: "mishka_",

      # Override CSS variables
      css_overrides: %{
        primary_light: "#007f8c",
        danger_light: "#de1135"
      }
    ```
    """
  end

  defp parse_config(config_path) do
    try do
      config = Config.Reader.read!(config_path)
      Keyword.get(config, :mishka_chelekom, []) |> Map.new()
    rescue
      _ -> %{}
    end
  end

  defp format_list(nil), do: "(all - no filter)"
  defp format_list([]), do: "(all - no filter)"
  defp format_list(list) when is_list(list), do: Enum.join(list, ", ")
  defp format_list(other), do: inspect(other)

  defp format_value(nil), do: "(not set)"
  defp format_value(""), do: "(not set)"
  defp format_value(value), do: "`#{value}`"

  defp format_overrides_count(nil), do: "0 variables"
  defp format_overrides_count(map) when is_map(map), do: "#{map_size(map)} variables"
  defp format_overrides_count(_), do: "0 variables"

  defp format_active_overrides(nil), do: ""
  defp format_active_overrides(map) when map == %{}, do: ""

  defp format_active_overrides(map) when is_map(map) do
    overrides =
      map
      |> Enum.map(fn {key, value} -> "| `#{key}` | `#{value}` |" end)
      |> Enum.join("\n")

    """

    ### Active CSS Overrides

    | Variable | Value |
    |----------|-------|
    #{overrides}
    """
  end

  defp format_active_overrides(_), do: ""
end
