defmodule MishkaChelekom.MCP.Resources.ListColors do
  @moduledoc """
  List all available color variants for Mishka Chelekom components.

  Colors are read dynamically from priv/components/*.exs configuration files.
  Multiple colors can be specified as comma-separated values when generating components.

  Each color has corresponding CSS variables that can be customized in
  `priv/mishka_chelekom/config.exs`. Use the `list_css_variables` resource to see
  all customizable CSS variables for each color theme.
  """

  use Anubis.Server.Component,
    type: :resource,
    uri: "mishka_chelekom://colors",
    name: "list_colors",
    description: "List all available color variants for Mishka Chelekom components",
    mime_type: "application/json"

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.ComponentConfig

  @color_descriptions %{
    "base" => "Default base color, typically neutral",
    "white" => "White background with dark text",
    "dark" => "Dark background with light text",
    "natural" => "Natural, neutral gray tones",
    "primary" => "Primary brand color (cyan/teal by default)",
    "secondary" => "Secondary accent color (blue by default)",
    "success" => "Success/positive state (green by default)",
    "warning" => "Warning state (yellow/orange by default)",
    "danger" => "Danger/error state (red by default)",
    "info" => "Informational state (light blue by default)",
    "silver" => "Silver/gray neutral tones",
    "misc" => "Miscellaneous accent colors (purple by default)",
    "dawn" => "Warm dawn tones (brown/orange by default)",
    "transparent" => "Transparent background",
    "error" => "Error state, alias for danger"
  }

  # CSS variables that can be customized for each color theme
  @color_css_variables %{
    "primary" => [
      "primary_light",
      "primary_dark",
      "primary_hover_light",
      "primary_hover_dark",
      "primary_bordered_bg_light",
      "primary_bordered_bg_dark",
      "shadow_primary"
    ],
    "secondary" => [
      "secondary_light",
      "secondary_dark",
      "secondary_hover_light",
      "secondary_hover_dark",
      "secondary_bordered_bg_light",
      "secondary_bordered_bg_dark",
      "shadow_secondary"
    ],
    "success" => [
      "success_light",
      "success_dark",
      "success_hover_light",
      "success_hover_dark",
      "success_bordered_bg_light",
      "success_bordered_bg_dark",
      "shadow_success"
    ],
    "warning" => [
      "warning_light",
      "warning_dark",
      "warning_hover_light",
      "warning_hover_dark",
      "warning_bordered_bg_light",
      "warning_bordered_bg_dark",
      "shadow_warning"
    ],
    "danger" => [
      "danger_light",
      "danger_dark",
      "danger_hover_light",
      "danger_hover_dark",
      "danger_bordered_bg_light",
      "danger_bordered_bg_dark",
      "shadow_danger"
    ],
    "info" => [
      "info_light",
      "info_dark",
      "info_hover_light",
      "info_hover_dark",
      "info_bordered_bg_light",
      "info_bordered_bg_dark",
      "shadow_info"
    ],
    "misc" => [
      "misc_light",
      "misc_dark",
      "misc_hover_light",
      "misc_hover_dark",
      "misc_bordered_bg_light",
      "misc_bordered_bg_dark",
      "shadow_misc"
    ],
    "dawn" => [
      "dawn_light",
      "dawn_dark",
      "dawn_hover_light",
      "dawn_hover_dark",
      "dawn_bordered_bg_light",
      "dawn_bordered_bg_dark",
      "shadow_dawn"
    ],
    "silver" => [
      "silver_light",
      "silver_dark",
      "silver_hover_light",
      "silver_hover_dark",
      "silver_bordered_bg_light",
      "silver_bordered_bg_dark",
      "shadow_silver"
    ],
    "natural" => [
      "natural_light",
      "natural_dark",
      "natural_hover_light",
      "natural_hover_dark",
      "natural_bordered_bg_light",
      "natural_bordered_bg_dark",
      "shadow_natural"
    ]
  }

  @impl true
  def read(_params, frame) do
    colors = ComponentConfig.list_colors()

    colors_with_descriptions =
      Enum.map(colors, fn color ->
        css_vars = Map.get(@color_css_variables, color, [])

        %{
          name: color,
          description: Map.get(@color_descriptions, color, "Color variant"),
          usage: "--color \"#{color}\"",
          css_variables: css_vars,
          customizable: css_vars != []
        }
      end)

    response =
      Response.resource()
      |> Response.json(%{
        colors: colors,
        details: colors_with_descriptions,
        description: "Available color variants for components (read from component configs)",
        usage_example: "mix mishka.ui.gen.component alert --color \"info,danger,warning\"",
        customization: %{
          description:
            "Each color can be customized via CSS variables in priv/mishka_chelekom/config.exs",
          how_to_customize: [
            "1. Run: mix mishka.ui.css.config --init",
            "2. Edit priv/mishka_chelekom/config.exs",
            "3. Uncomment and change color values in css_overrides map",
            "4. Run: mix mishka.ui.css.config --regenerate"
          ],
          example: """
          css_overrides: %{
            primary_light: "#2563eb",
            primary_dark: "#3b82f6",
            danger_light: "#dc2626"
          }
          """,
          related_tools: [
            "list_css_variables - See all CSS variables by category",
            "update_config - Generate config code for specific overrides",
            "get_config - View current config file"
          ]
        }
      })

    {:reply, response, frame}
  end
end
