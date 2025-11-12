defmodule MishkaChelekom.CSSConfig do
  @moduledoc """
  Handles CSS configuration and merging for Mishka Chelekom components.
  Allows users to override specific CSS variables or provide custom CSS files.
  """

  # Configuration keys and their default values
  @config_mappings [
    {:css_overrides, %{}},
    {:custom_css_path, nil},
    {:css_merge_strategy, :merge},
    {:exclude_components, []},
    {:component_colors, []},
    {:component_variants, []},
    {:component_sizes, []},
    {:component_rounded, []},
    {:component_padding, []},
    {:component_space, []},
    {:component_prefix, nil}
  ]

  @doc """
  Loads user configuration from priv/mishka_chelekom/config.exs if it exists.
  Returns a map with configuration options or defaults.
  """
  def load_user_config(igniter) do
    config_path = user_config_path(igniter)

    # Check if the config exists in igniter's sources (for tests) or on disk
    config_source = igniter.rewrite.sources[config_path]

    cond do
      # Config exists in memory (during tests)
      config_source != nil ->
        content = Rewrite.Source.get(config_source, :content)
        load_config_from_string(content)

      # Config exists on disk
      File.exists?(config_path) ->
        load_config_from_file(config_path)

      # No config found
      true ->
        default_config()
    end
  end

  # Load config from a file path
  defp load_config_from_file(config_path) do
    try do
      config = Config.Reader.read!(config_path)
      extract_mishka_config(config)
    rescue
      _ -> default_config()
    end
  end

  # Parse config content from string (for test environments)
  defp load_config_from_string(content) do
    # Write to a temporary file and use Config.Reader
    temp_path = Path.join(System.tmp_dir!(), "mishka_config_#{:rand.uniform(999_999)}.exs")

    try do
      File.write!(temp_path, content)
      config = Config.Reader.read!(temp_path)
      extract_mishka_config(config)
    rescue
      _ -> default_config()
    after
      File.rm(temp_path)
    end
  end

  # Extract mishka configuration from the config
  defp extract_mishka_config(config) do
    mishka_config = Keyword.get(config, :mishka_chelekom, [])

    # Build the config map by extracting each key with its default
    Enum.reduce(@config_mappings, %{}, fn {key, default}, acc ->
      Map.put(acc, key, Keyword.get(mishka_config, key, default))
    end)
  end

  @doc """
  Generates the final CSS content by merging defaults with user overrides.
  """
  def generate_css_content(igniter) do
    config = load_user_config(igniter)

    case config.css_merge_strategy do
      :replace when not is_nil(config.custom_css_path) ->
        # User wants to completely replace with their custom CSS
        read_custom_css(config.custom_css_path, igniter)

      _ ->
        # Default: merge strategy
        merge_css_with_overrides(config)
    end
  end

  # Private functions

  defp default_config do
    # Use empty keyword list to get all defaults from extract_mishka_config
    extract_mishka_config([])
  end

  defp user_config_path(_igniter) do
    # Use the actual project's priv directory, not the build directory
    Path.join(["priv", "mishka_chelekom", "config.exs"])
  end

  defp read_custom_css(path, _igniter) do
    full_path =
      if Path.type(path) == :absolute do
        path
      else
        Path.join(File.cwd!(), path)
      end

    case File.read(full_path) do
      {:ok, content} ->
        content

      {:error, _} ->
        # Fall back to default if custom file not found
        read_default_css()
    end
  end

  defp merge_css_with_overrides(config) do
    default_css = read_default_css()

    if map_size(config.css_overrides) == 0 do
      default_css
    else
      apply_css_overrides(default_css, config.css_overrides)
    end
  end

  defp read_default_css do
    # Get the path from the library's priv directory
    css_path = Path.join(:code.priv_dir(:mishka_chelekom), "assets/css/mishka_chelekom.css")

    if File.exists?(css_path) do
      File.read!(css_path)
    else
      # Fallback to checking deps directory (for development)
      deps_path = "deps/mishka_chelekom/priv/assets/css/mishka_chelekom.css"

      if File.exists?(deps_path) do
        File.read!(deps_path)
      else
        # Last resort: return a minimal default CSS
        ":root {\n    /* Default CSS variables */\n}"
      end
    end
  end

  defp apply_css_overrides(css_content, overrides) do
    # Parse the :root section and replace variables
    Enum.reduce(overrides, css_content, fn {key, value}, acc ->
      # Convert atom key to CSS variable name
      css_var = "--#{String.replace(to_string(key), "_", "-")}"

      # Replace the variable value in the CSS
      regex = ~r/#{Regex.escape(css_var)}:\s*[^;]+;/
      replacement = "#{css_var}: #{value};"

      if Regex.match?(regex, acc) do
        Regex.replace(regex, acc, replacement)
      else
        # If variable doesn't exist, add it to the :root section
        add_variable_to_root(acc, css_var, value)
      end
    end)
  end

  defp add_variable_to_root(css_content, var_name, value) do
    # Find the :root block and add the variable
    case Regex.run(~r/:root\s*\{([^}]*)\}/s, css_content) do
      [full_match, root_content] ->
        new_root_content = String.trim_trailing(root_content) <> "\n    #{var_name}: #{value};\n"
        String.replace(css_content, full_match, ":root {#{new_root_content}}")

      _ ->
        # If no :root block exists, create one
        ":root {\n    #{var_name}: #{value};\n}\n\n" <> css_content
    end
  end

  @doc """
  Creates a sample configuration file for users.
  """
  def create_sample_config(igniter) do
    config_path = user_config_path(igniter)

    sample_content = """
    # Mishka Chelekom CSS Configuration
    #
    # This file allows you to customize the CSS variables used by Mishka components.
    # Uncomment and modify only the variables you want to override.
    # Variable names use underscores instead of dashes (e.g., primary_light instead of --primary-light)

    import Config

    config :mishka_chelekom,
      component_prefix: nil,
      # List of components to exclude from generation when using mix mishka.ui.gen.components
      # Example: ["alert", "badge", "button"]
      exclude_components: [],

      # Component attribute filters - limit which values are generated (reduces code size)
      # If empty or not specified, all values will be included

      # List of colors to include in component generation
      # Example: ["base", "primary", "danger", "success"]
      component_colors: [],

      # List of variants to include in component generation
      # Example: ["default", "outline", "bordered"]
      component_variants: [],

      # List of sizes to include in component generation
      # Example: ["small", "medium", "large"]
      component_sizes: [],

      # List of rounded options to include in component generation
      # Example: ["small", "medium", "full"]
      component_rounded: [],

      # List of padding options to include in component generation
      # Example: ["small", "medium", "large"]
      component_padding: [],

      # List of space options to include in component generation
      # Example: ["small", "medium", "large", "none"]
      component_space: [],

      # Override specific CSS variables (uncomment and modify as needed)
      css_overrides: %{
        # === Base Colors ===
        # base_border_light: "#e4e4e7",
        # base_border_dark: "#27272a",
        # base_text_light: "#09090b",
        # base_text_dark: "#fafafa",
        # base_bg_dark: "#18181b",
        # base_hover_light: "#f8f9fa",
        # base_hover_dark: "#242424",
        # base_disabled_bg_light: "#f1f3f5",
        # base_text_hover_light: "#1b1b1f",
        # base_text_hover_dark: "#ededed",
        # base_disabled_bg_dark: "#2e2e2e",
        # base_disabled_text_light: "#adb5bd",
        # base_disabled_text_dark: "#696969",
        # base_disabled_border_light: "#dee2e6",
        # base_disabled_border_dark: "#424242",
        # base_tab_bg_light: "#f4f4f5",

        # === Default Colors ===
        # default_dark_bg: "#282828",
        # default_light_gray: "#f4f4f4",
        # default_gray: "#b6b6b6",
        # ring_dark: "#050404",
        # default_device_dark: "#404040",
        # range_light_gray: "#e6e6e6",

        # === Natural Theme ===
        # natural_light: "#4b4b4b",
        # natural_dark: "#dddddd",
        # natural_hover_light: "#282828",
        # natural_hover_dark: "#e8e8e8",
        # natural_bordered_hover_light: "#E8E8E8",
        # natural_bordered_hover_dark: "#5E5E5E",
        # natural_bg_light: "#f3f3f3",
        # natural_bg_dark: "#4b4b4b",
        # natural_border_light: "#282828",
        # natural_border_dark: "#e8e8e8",
        # natural_bordered_text_light: "#282828",
        # natural_bordered_text_dark: "#e8e8e8",
        # natural_bordered_bg_light: "#f3f3f3",
        # natural_bordered_bg_dark: "#4b4b4b",
        # natural_disabled_light: "#dddddd",
        # natural_disabled_dark: "#727272",

        # === Primary Theme ===
        # primary_light: "#007f8c",
        # primary_dark: "#01b8ca",
        # primary_hover_light: "#016974",
        # primary_hover_dark: "#77d5e3",
        # primary_bordered_text_light: "#016974",
        # primary_bordered_text_dark: "#77d5e3",
        # primary_bordered_bg_light: "#e2f8fb",
        # primary_bordered_bg_dark: "#002d33",
        # primary_indicator_light: "#1a535a",
        # primary_indicator_dark: "#b0e7ef",
        # primary_border_light: "#000000",
        # primary_border_dark: "#b0e7ef",
        # primary_gradient_indicator_dark: "#cdeef3",

        # === Secondary Theme ===
        # secondary_light: "#266ef1",
        # secondary_dark: "#6daafb",
        # secondary_hover_light: "#175bcc",
        # secondary_hover_dark: "#a9c9ff",
        # secondary_bordered_text_light: "#175bcc",
        # secondary_bordered_text_dark: "#a9c9ff",
        # secondary_bordered_bg_light: "#eff4fe",
        # secondary_bordered_bg_dark: "#002661",
        # secondary_indicator_light: "#1948a3",
        # secondary_indicator_dark: "#cddeff",
        # secondary_border_light: "#1948a3",
        # secondary_border_dark: "#cddeff",
        # secondary_gradient_indicator_dark: "#dee9fe",

        # === Success Theme ===
        # success_light: "#0e8345",
        # success_dark: "#06c167",
        # success_hover_light: "#166c3b",
        # success_hover_dark: "#7fd99a",
        # success_bordered_text_light: "#166c3b",
        # success_bordered_text_dark: "#7fd99a",
        # success_bordered_bg_light: "#eaf6ed",
        # success_bordered_bg_dark: "#002f14",
        # success_indicator_light: "#047857",
        # success_indicator_alt_light: "#0d572d",
        # success_indicator_dark: "#b1eac2",
        # success_border_light: "#0d572d",
        # success_border_dark: "#b1eac2",
        # success_gradient_indicator_dark: "#d3efda",

        # === Warning Theme ===
        # warning_light: "#ca8d01",
        # warning_dark: "#fdc034",
        # warning_hover_light: "#976a01",
        # warning_hover_dark: "#fdd067",
        # warning_bordered_text_light: "#976a01",
        # warning_bordered_text_dark: "#fdd067",
        # warning_bordered_bg_light: "#fff7e6",
        # warning_bordered_bg_dark: "#322300",
        # warning_indicator_light: "#ff8b08",
        # warning_indicator_alt_light: "#654600",
        # warning_indicator_dark: "#fedf99",
        # warning_border_light: "#654600",
        # warning_border_dark: "#fedf99",
        # warning_gradient_indicator_dark: "#feefcc",

        # === Danger Theme ===
        # danger_light: "#de1135",
        # danger_dark: "#fc7f79",
        # danger_hover_light: "#bb032a",
        # danger_hover_dark: "#ffb2ab",
        # danger_bordered_text_light: "#bb032a",
        # danger_bordered_text_dark: "#ffb2ab",
        # danger_bordered_bg_light: "#fff0ee",
        # danger_bordered_bg_dark: "#520810",
        # danger_indicator_light: "#e73b3b",
        # danger_indicator_alt_light: "#950f22",
        # danger_indicator_dark: "#ffd2cd",
        # danger_border_light: "#950f22",
        # danger_border_dark: "#ffd2cd",
        # danger_gradient_indicator_dark: "#ffe1de",

        # === Info Theme ===
        # info_light: "#0b84ba",
        # info_dark: "#3eb7ed",
        # info_hover_light: "#08638c",
        # info_hover_dark: "#6ec9f2",
        # info_bordered_text_light: "#0b84ba",
        # info_bordered_text_dark: "#6ec9f2",
        # info_bordered_bg_light: "#e7f6fd",
        # info_bordered_bg_dark: "#03212f",
        # info_indicator_light: "#004fc4",
        # info_indicator_alt_light: "#06425d",
        # info_indicator_dark: "#9fdbf6",
        # info_border_light: "#06425d",
        # info_border_dark: "#9fdbf6",
        # info_gradient_indicator_dark: "#cfedfb",

        # === Misc Theme ===
        # misc_light: "#8750c5",
        # misc_dark: "#ba83f9",
        # misc_hover_light: "#653c94",
        # misc_hover_dark: "#cba2fa",
        # misc_bordered_text_light: "#653c94",
        # misc_bordered_text_dark: "#cba2fa",
        # misc_bordered_bg_light: "#f6f0fe",
        # misc_bordered_bg_dark: "#221431",
        # misc_indicator_light: "#52059c",
        # misc_indicator_alt_light: "#442863",
        # misc_indicator_dark: "#ddc1fc",
        # misc_border_light: "#442863",
        # misc_border_dark: "#ddc1fc",
        # misc_gradient_indicator_dark: "#eee0fd",

        # === Dawn Theme ===
        # dawn_light: "#a86438",
        # dawn_dark: "#db976b",
        # dawn_hover_light: "#7e4b2a",
        # dawn_hover_dark: "#e4b190",
        # dawn_bordered_text_light: "#7e4b2a",
        # dawn_bordered_text_dark: "#e4b190",
        # dawn_bordered_bg_light: "#fbf2ed",
        # dawn_bordered_bg_dark: "#2a190e",
        # dawn_indicator_light: "#4d4137",
        # dawn_indicator_alt_light: "#54321c",
        # dawn_indicator_dark: "#edcbb5",
        # dawn_border_light: "#54321c",
        # dawn_border_dark: "#edcbb5",
        # dawn_gradient_indicator_dark: "#f6e5da",

        # === Silver Theme ===
        # silver_light: "#868686",
        # silver_dark: "#a6a6a6",
        # silver_hover_light: "#727272",
        # silver_hover_dark: "#bbbbbb",
        # silver_hover_bordered_light: "#E8E8E8",
        # silver_hover_bordered_dark: "#5E5E5E",
        # silver_bordered_text_light: "#727272",
        # silver_bordered_text_dark: "#bbbbbb",
        # silver_bordered_bg_light: "#f3f3f3",
        # silver_bordered_bg_dark: "#4b4b4b",
        # silver_indicator_light: "#707483",
        # silver_indicator_alt_light: "#5e5e5e",
        # silver_indicator_dark: "#dddddd",
        # silver_border_light: "#5e5e5e",
        # silver_border_dark: "#dddddd",

        # === Borders & States ===
        # bordered_white_border: "#dddddd",
        # bordered_dark_bg: "#282828",
        # bordered_dark_border: "#727272",
        # disabled_bg_light: "#f3f3f3",
        # disabled_bg_dark: "#4b4b4b",
        # disabled_text_light: "#bbbbbb",
        # disabled_text_dark: "#868686",

        # === Shadows ===
        # shadow_natural: "rgba(134, 134, 134, 0.5)",
        # shadow_primary: "rgba(0, 149, 164, 0.5)",
        # shadow_secondary: "rgba(6, 139, 238, 0.5)",
        # shadow_success: "rgba(0, 154, 81, 0.5)",
        # shadow_warning: "rgba(252, 176, 1, 0.5)",
        # shadow_danger: "rgba(248, 52, 70, 0.5)",
        # shadow_info: "rgba(14, 165, 233, 0.5)",
        # shadow_misc: "rgba(169, 100, 247, 0.5)",
        # shadow_dawn: "rgba(210, 125, 70, 0.5)",
        # shadow_silver: "rgba(134, 134, 134, 0.5)",

        # === Gradients ===
        # gradient_natural_from_light: "#282828",
        # gradient_natural_to_light: "#727272",
        # gradient_natural_from_dark: "#a6a6a6",
        # gradient_primary_from_light: "#016974",
        # gradient_primary_to_light: "#01b8ca",
        # gradient_primary_from_dark: "#01b8ca",
        # gradient_primary_to_dark: "#b0e7ef",
        # gradient_secondary_from_light: "#175bcc",
        # gradient_secondary_to_light: "#6daafb",
        # gradient_secondary_from_dark: "#6daafb",
        # gradient_secondary_to_dark: "#cddeff",
        # gradient_success_from_light: "#166c3b",
        # gradient_success_to_light: "#06c167",
        # gradient_success_from_dark: "#06c167",
        # gradient_success_to_dark: "#b1eac2",
        # gradient_warning_from_light: "#976a01",
        # gradient_warning_to_light: "#fdc034",
        # gradient_warning_from_dark: "#fdc034",
        # gradient_warning_to_dark: "#fedf99",
        # gradient_danger_from_light: "#bb032a",
        # gradient_danger_to_light: "#fc7f79",
        # gradient_danger_from_dark: "#fc7f79",
        # gradient_danger_to_dark: "#ffd2cd",
        # gradient_info_from_light: "#08638c",
        # gradient_info_to_light: "#3eb7ed",
        # gradient_info_from_dark: "#3eb7ed",
        # gradient_info_to_dark: "#9fdbf6",
        # gradient_misc_from_light: "#653c94",
        # gradient_misc_to_light: "#ba83f9",
        # gradient_misc_from_dark: "#ba83f9",
        # gradient_misc_to_dark: "#ddc1fc",
        # gradient_dawn_from_light: "#7e4b2a",
        # gradient_dawn_to_light: "#db976b",
        # gradient_dawn_from_dark: "#db976b",
        # gradient_dawn_to_dark: "#edcbb5",
        # gradient_silver_from_light: "#5e5e5e",
        # gradient_silver_to_light: "#a6a6a6",
        # gradient_silver_from_dark: "#868686",
        # gradient_silver_to_dark: "#bbbbbb",

        # === Form Elements ===
        # base_form_border_light: "#8b8b8d",
        # base_form_border_dark: "#818182",
        # base_form_focus_dark: "#696969",
        # form_white_text: "#3e3e3e",
        # form_white_focus: "#dadada",

        # === Checkbox Colors ===
        # checkbox_unchecked_dark: "#333333",
        # checkbox_white_checked: "#ede8e8",
        # checkbox_dark_checked: "#616060",
        # checkbox_primary_checked: "#0095a4",
        # checkbox_secondary_checked: "#068bee",
        # checkbox_success_checked: "#009a51",
        # checkbox_warning_checked: "#fcb001",
        # checkbox_danger_checked: "#f83446",
        # checkbox_info_checked: "#0ea5e9",
        # checkbox_misc_checked: "#a964f7",
        # checkbox_dawn_checked: "#d27d46",
        # checkbox_silver_checked: "#a6a6a6",

        # === Stepper Colors ===
        # stepper_loading_icon_fill: "#2563eb",
        # stepper_current_step_text_light: "#2563eb",
        # stepper_current_step_text_dark: "#1971c2",
        # stepper_current_step_border_light: "#2563eb",
        # stepper_current_step_border_dark: "#1971c2",
        # stepper_completed_step_bg_light: "#14b8a6",
        # stepper_completed_step_bg_dark: "#099268",
        # stepper_completed_step_border_light: "#14b8a6",
        # stepper_completed_step_border_dark: "#099268",
        # stepper_canceled_step_bg_light: "#fa5252",
        # stepper_canceled_step_bg_dark: "#e03131",
        # stepper_canceled_step_border_light: "#fa5252",
        # stepper_canceled_step_border_dark: "#e03131",
        # stepper_separator_completed_border_light: "#14b8a6",
        # stepper_separator_completed_border_dark: "#099268"
      },

      # Strategy for handling CSS
      # :merge - Merge overrides with defaults (recommended)
      # :replace - Completely replace with custom CSS file
      css_merge_strategy: :merge,

      # Path to custom CSS file (only used when css_merge_strategy is :replace)
      # custom_css_path: "priv/static/css/custom_mishka.css"
      custom_css_path: nil
    """

    {igniter, config_path, sample_content}
  end

  @doc """
  Updates the component_prefix value in the user's config file.
  Creates the config file with sample content if it doesn't exist.
  """
  def update_component_prefix(igniter, prefix) when is_binary(prefix) do
    config_path = user_config_path(igniter)

    # Get existing content or create sample config
    existing_content =
      case Rewrite.source(igniter.rewrite, config_path) do
        {:ok, source} ->
          Rewrite.Source.get(source, :content)

        {:error, _} ->
          # Config doesn't exist, check file system
          if File.exists?(config_path) do
            File.read!(config_path)
          else
            # Create sample config content
            {_igniter, _path, sample_content} = create_sample_config(igniter)
            sample_content
          end
      end

    # Update the component_prefix line
    updated_content = update_prefix_in_content(existing_content, prefix)

    # Write the updated content
    igniter
    |> Igniter.create_or_update_file(config_path, updated_content, fn source ->
      Rewrite.Source.update(source, :content, updated_content)
    end)
  end

  defp update_prefix_in_content(content, prefix) do
    regex = ~r/component_prefix:\s*(?:nil|"[^"]*")/

    if Regex.match?(regex, content) do
      Regex.replace(regex, content, ~s(component_prefix: "#{prefix}"))
    else
      add_prefix_to_config(content, prefix)
    end
  end

  defp add_prefix_to_config(content, prefix) do
    case Regex.run(~r/(config :mishka_chelekom,)\s*\n/, content) do
      [_, config_line] ->
        String.replace(
          content,
          config_line,
          "#{config_line}\n    component_prefix: \"#{prefix}\",\n"
        )

      nil ->
        content
    end
  end
end
