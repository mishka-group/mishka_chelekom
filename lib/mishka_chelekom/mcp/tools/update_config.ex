defmodule MishkaChelekom.MCP.Tools.UpdateConfig do
  @moduledoc """
  Generate configuration updates for Mishka Chelekom.

  This tool helps modify the `priv/mishka_chelekom/config.exs` file by generating
  the appropriate Elixir code to add to the config.

  ## Usage

      update_config(setting: "component_colors", values: "primary,danger,success")
      update_config(setting: "exclude_components", values: "carousel,gallery")
      update_config(setting: "component_prefix", values: "mishka_")
      update_config(setting: "css_override", variable: "primary_light", value: "#2563eb")
  """

  use Anubis.Server.Component, type: :tool

  alias Anubis.Server.Response

  @valid_settings [
    "exclude_components",
    "component_colors",
    "component_variants",
    "component_sizes",
    "component_rounded",
    "component_padding",
    "component_space",
    "component_prefix",
    "module_prefix",
    "css_override",
    "css_merge_strategy"
  ]

  schema do
    field(:setting, :string,
      required: true,
      description:
        "Config setting to update: exclude_components, component_colors, component_variants, component_sizes, component_rounded, component_padding, component_space, component_prefix, module_prefix, css_override, css_merge_strategy"
    )

    field(:values, :string,
      description: "Values to set (comma-separated for lists, single value for strings)"
    )

    field(:variable, :string, description: "CSS variable name (only for css_override setting)")

    field(:value, :string, description: "CSS variable value (only for css_override setting)")
  end

  @impl true
  def execute(params, frame) do
    setting = params[:setting]

    content =
      cond do
        setting not in @valid_settings ->
          format_invalid_setting(setting)

        setting == "css_override" ->
          handle_css_override(params)

        setting in ["component_prefix", "module_prefix", "css_merge_strategy"] ->
          handle_string_setting(setting, params[:values])

        true ->
          handle_list_setting(setting, params[:values])
      end

    response =
      Response.tool()
      |> Response.text(content)

    {:reply, response, frame}
  end

  defp format_invalid_setting(setting) do
    """
    # Invalid Setting

    `#{setting}` is not a valid configuration setting.

    ## Valid Settings

    | Setting | Type | Description |
    |---------|------|-------------|
    | `exclude_components` | list | Components to skip during generation |
    | `component_colors` | list | Limit which colors are generated |
    | `component_variants` | list | Limit which variants are generated |
    | `component_sizes` | list | Limit which sizes are generated |
    | `component_rounded` | list | Limit rounded options |
    | `component_padding` | list | Limit padding options |
    | `component_space` | list | Limit space options |
    | `component_prefix` | string | Prefix for function names |
    | `module_prefix` | string | Prefix for module names |
    | `css_override` | special | Override a CSS variable |
    | `css_merge_strategy` | atom | :merge or :replace |

    ## Example Usage

    ```
    update_config(setting: "component_colors", values: "primary,danger,success")
    update_config(setting: "component_prefix", values: "mishka_")
    update_config(setting: "css_override", variable: "primary_light", value: "#2563eb")
    ```
    """
  end

  defp handle_css_override(%{variable: var, value: val}) when is_binary(var) and is_binary(val) do
    config_path = "priv/mishka_chelekom/config.exs"

    """
    # Update CSS Override

    ## Add to Config

    Open `#{config_path}` and add/update this in the `css_overrides` map:

    ```elixir
    css_overrides: %{
      # ... existing overrides ...
      #{var}: "#{val}"
    }
    ```

    ## Full Example

    ```elixir
    config :mishka_chelekom,
      css_overrides: %{
        #{var}: "#{val}"
      }
    ```

    ## Apply Changes

    After updating the config, regenerate CSS:

    ```bash
    mix mishka.ui.css.config --regenerate
    ```

    ---

    **Variable:** `#{var}` maps to CSS `--#{String.replace(var, "_", "-")}`
    **Value:** `#{val}`
    """
  end

  defp handle_css_override(_) do
    """
    # CSS Override

    To override a CSS variable, provide both `variable` and `value`:

    ```
    update_config(setting: "css_override", variable: "primary_light", value: "#2563eb")
    ```

    ## How It Works

    By default, all CSS variables are **commented out** in the config file and use
    the default colors. When you uncomment and change a value, it will override
    the default color for that CSS variable.

    ## Common Variables by Color Theme

    ### Primary (cyan/teal)
    | Variable | Default | Description |
    |----------|---------|-------------|
    | `primary_light` | #007f8c | Primary color (light mode) |
    | `primary_dark` | #01b8ca | Primary color (dark mode) |
    | `primary_hover_light` | #016974 | Primary hover (light) |
    | `primary_hover_dark` | #77d5e3 | Primary hover (dark) |

    ### Danger (red)
    | Variable | Default | Description |
    |----------|---------|-------------|
    | `danger_light` | #de1135 | Danger color (light mode) |
    | `danger_dark` | #fc7f79 | Danger color (dark mode) |
    | `danger_hover_light` | #bb032a | Danger hover (light) |
    | `danger_hover_dark` | #ffb2ab | Danger hover (dark) |

    ### Success (green)
    | Variable | Default | Description |
    |----------|---------|-------------|
    | `success_light` | #0e8345 | Success color (light mode) |
    | `success_dark` | #06c167 | Success color (dark mode) |

    ### Other Themes
    Available themes: secondary, warning, info, misc, dawn, silver, natural

    Each theme has similar variables: `{theme}_light`, `{theme}_dark`,
    `{theme}_hover_light`, `{theme}_hover_dark`, `{theme}_bordered_bg_light`, etc.

    ## Full Variable List

    Use `list_css_variables` resource to see all 200+ available CSS variables
    organized by category (themes, shadows, gradients, form elements, etc.)

    ## Related Tools

    - `list_css_variables` - See all CSS variables with defaults
    - `list_colors` - See component color options and their CSS variables
    - `get_config` - View current config file
    """
  end

  defp handle_string_setting(setting, nil) do
    format_setting_help(setting, :string)
  end

  defp handle_string_setting(setting, value) do
    config_path = "priv/mishka_chelekom/config.exs"

    formatted_value =
      case setting do
        "css_merge_strategy" -> ":#{value}"
        _ -> "\"#{value}\""
      end

    """
    # Update #{format_setting_name(setting)}

    ## Add to Config

    Open `#{config_path}` and add/update:

    ```elixir
    config :mishka_chelekom,
      #{setting}: #{formatted_value}
    ```

    #{setting_specific_notes(setting, value)}

    ## Apply Changes

    #{apply_changes_command(setting)}
    """
  end

  defp handle_list_setting(setting, nil) do
    format_setting_help(setting, :list)
  end

  defp handle_list_setting(setting, values) do
    config_path = "priv/mishka_chelekom/config.exs"

    list =
      values
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.map(&"\"#{&1}\"")
      |> Enum.join(", ")

    """
    # Update #{format_setting_name(setting)}

    ## Add to Config

    Open `#{config_path}` and add/update:

    ```elixir
    config :mishka_chelekom,
      #{setting}: [#{list}]
    ```

    #{setting_specific_notes(setting, values)}

    ## Apply Changes

    #{apply_changes_command(setting)}

    ---

    **Setting:** `#{setting}`
    **Values:** #{values}
    """
  end

  defp format_setting_help(setting, :string) do
    """
    # #{format_setting_name(setting)}

    Please provide a value:

    ```
    update_config(setting: "#{setting}", values: "your_value")
    ```

    #{setting_description(setting)}
    """
  end

  defp format_setting_help(setting, :list) do
    """
    # #{format_setting_name(setting)}

    Please provide values (comma-separated):

    ```
    update_config(setting: "#{setting}", values: "value1,value2,value3")
    ```

    #{setting_description(setting)}
    """
  end

  defp format_setting_name(setting) do
    setting
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp setting_description("exclude_components") do
    """
    ## Description

    Excludes specific components from generation when using `mix mishka.ui.gen.components`.

    ## Example

    ```
    update_config(setting: "exclude_components", values: "carousel,gallery,sidebar")
    ```
    """
  end

  defp setting_description("component_colors") do
    """
    ## Description

    Limits which color variants are generated, reducing code size.

    ## Available Colors

    primary, secondary, success, warning, danger, info, misc, dawn, silver, natural, white, dark

    ## Example

    ```
    update_config(setting: "component_colors", values: "primary,danger,success")
    ```
    """
  end

  defp setting_description("component_variants") do
    """
    ## Description

    Limits which style variants are generated.

    ## Common Variants

    default, outline, bordered, shadow, gradient, transparent

    ## Example

    ```
    update_config(setting: "component_variants", values: "default,outline")
    ```
    """
  end

  defp setting_description("component_prefix") do
    """
    ## Description

    Adds a prefix to all component function names.

    - `component_prefix: "mishka_"` makes `<.button>` become `<.mishka_button>`

    ## Example

    ```
    update_config(setting: "component_prefix", values: "mishka_")
    ```
    """
  end

  defp setting_description("module_prefix") do
    """
    ## Description

    Adds a prefix to all component module names.

    - `module_prefix: "mishka_"` makes `Button` become `MishkaButton`
    - File: `button.ex` becomes `mishka_button.ex`

    ## Example

    ```
    update_config(setting: "module_prefix", values: "mishka_")
    ```
    """
  end

  defp setting_description(_) do
    ""
  end

  defp setting_specific_notes("component_prefix", value) do
    """
    ## Effect

    After regenerating components:
    - `<.button>` becomes `<.#{value}button>`
    - `<.alert>` becomes `<.#{value}alert>`
    """
  end

  defp setting_specific_notes("module_prefix", value) do
    camel = value |> String.trim_trailing("_") |> Macro.camelize()

    """
    ## Effect

    After regenerating components:
    - `Button` module becomes `#{camel}Button`
    - `button.ex` file becomes `#{value}button.ex`
    """
  end

  defp setting_specific_notes("exclude_components", _) do
    """
    ## Note

    These components will be skipped when running `mix mishka.ui.gen.components`.
    """
  end

  defp setting_specific_notes(setting, _)
       when setting in ["component_colors", "component_variants", "component_sizes"] do
    """
    ## Note

    Only the specified values will be generated, reducing component code size.
    Leave empty `[]` to include all values.
    """
  end

  defp setting_specific_notes(_, _), do: ""

  defp apply_changes_command(setting) when setting in ["component_prefix", "module_prefix"] do
    """
    Regenerate components with the new prefix:

    ```bash
    mix mishka.ui.gen.components --yes
    ```
    """
  end

  defp apply_changes_command(setting)
       when setting in [
              "component_colors",
              "component_variants",
              "component_sizes",
              "component_rounded",
              "component_padding",
              "component_space",
              "exclude_components"
            ] do
    """
    Regenerate components with new filters:

    ```bash
    mix mishka.ui.gen.components --yes
    ```
    """
  end

  defp apply_changes_command("css_merge_strategy") do
    """
    Regenerate CSS:

    ```bash
    mix mishka.ui.css.config --regenerate
    ```
    """
  end

  defp apply_changes_command(_) do
    """
    ```bash
    mix mishka.ui.css.config --regenerate
    ```
    """
  end
end
