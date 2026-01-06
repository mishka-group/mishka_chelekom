defmodule MishkaChelekom.MCP.Resources.ListCssVariables do
  @moduledoc """
  List all available CSS variables that can be overridden in Mishka Chelekom.

  These variables can be customized in `priv/mishka_chelekom/config.exs` using the
  `css_overrides` map. Variable names use underscores (e.g., `primary_light`)
  which map to CSS variables with dashes (e.g., `--primary-light`).

  By default, all values are commented out in the config file and use the default
  colors. Uncomment and change any value to customize your design system.
  """

  use Anubis.Server.Component,
    type: :resource,
    uri: "mishka_chelekom://css-variables",
    name: "list_css_variables",
    description: "List all CSS variables that can be overridden in config.exs",
    mime_type: "text/plain"

  alias Anubis.Server.Response

  # Complete CSS variables organized by category - matches config.ex exactly
  @css_variables %{
    "Base Colors" => [
      {:base_border_light, "#e4e4e7", "Light mode border color"},
      {:base_border_dark, "#27272a", "Dark mode border color"},
      {:base_text_light, "#09090b", "Light mode text color"},
      {:base_text_dark, "#fafafa", "Dark mode text color"},
      {:base_bg_dark, "#18181b", "Dark mode background"},
      {:base_hover_light, "#f8f9fa", "Light mode hover background"},
      {:base_hover_dark, "#242424", "Dark mode hover background"},
      {:base_disabled_bg_light, "#f1f3f5", "Light mode disabled background"},
      {:base_text_hover_light, "#1b1b1f", "Light mode text hover"},
      {:base_text_hover_dark, "#ededed", "Dark mode text hover"},
      {:base_disabled_bg_dark, "#2e2e2e", "Dark mode disabled background"},
      {:base_disabled_text_light, "#adb5bd", "Light mode disabled text"},
      {:base_disabled_text_dark, "#696969", "Dark mode disabled text"},
      {:base_disabled_border_light, "#dee2e6", "Light mode disabled border"},
      {:base_disabled_border_dark, "#424242", "Dark mode disabled border"},
      {:base_tab_bg_light, "#f4f4f5", "Light mode tab background"}
    ],
    "Default Colors" => [
      {:default_dark_bg, "#282828", "Default dark background"},
      {:default_light_gray, "#f4f4f4", "Default light gray"},
      {:default_gray, "#b6b6b6", "Default gray"},
      {:ring_dark, "#050404", "Dark ring color"},
      {:default_device_dark, "#404040", "Device mockup dark color"},
      {:range_light_gray, "#e6e6e6", "Range slider light gray"}
    ],
    "Natural Theme" => [
      {:natural_light, "#4b4b4b", "Natural gray (light mode)"},
      {:natural_dark, "#dddddd", "Natural gray (dark mode)"},
      {:natural_hover_light, "#282828", "Natural hover (light)"},
      {:natural_hover_dark, "#e8e8e8", "Natural hover (dark)"},
      {:natural_bordered_hover_light, "#E8E8E8", "Natural bordered hover (light)"},
      {:natural_bordered_hover_dark, "#5E5E5E", "Natural bordered hover (dark)"},
      {:natural_bg_light, "#f3f3f3", "Natural background (light)"},
      {:natural_bg_dark, "#4b4b4b", "Natural background (dark)"},
      {:natural_border_light, "#282828", "Natural border (light)"},
      {:natural_border_dark, "#e8e8e8", "Natural border (dark)"},
      {:natural_bordered_text_light, "#282828", "Natural bordered text (light)"},
      {:natural_bordered_text_dark, "#e8e8e8", "Natural bordered text (dark)"},
      {:natural_bordered_bg_light, "#f3f3f3", "Natural bordered background (light)"},
      {:natural_bordered_bg_dark, "#4b4b4b", "Natural bordered background (dark)"},
      {:natural_disabled_light, "#dddddd", "Natural disabled (light)"},
      {:natural_disabled_dark, "#727272", "Natural disabled (dark)"}
    ],
    "Primary Theme" => [
      {:primary_light, "#007f8c", "Primary color (light mode)"},
      {:primary_dark, "#01b8ca", "Primary color (dark mode)"},
      {:primary_hover_light, "#016974", "Primary hover (light)"},
      {:primary_hover_dark, "#77d5e3", "Primary hover (dark)"},
      {:primary_bordered_text_light, "#016974", "Primary bordered text (light)"},
      {:primary_bordered_text_dark, "#77d5e3", "Primary bordered text (dark)"},
      {:primary_bordered_bg_light, "#e2f8fb", "Primary bordered background (light)"},
      {:primary_bordered_bg_dark, "#002d33", "Primary bordered background (dark)"},
      {:primary_indicator_light, "#1a535a", "Primary indicator (light)"},
      {:primary_indicator_dark, "#b0e7ef", "Primary indicator (dark)"},
      {:primary_border_light, "#000000", "Primary border (light)"},
      {:primary_border_dark, "#b0e7ef", "Primary border (dark)"},
      {:primary_gradient_indicator_dark, "#cdeef3", "Primary gradient indicator (dark)"}
    ],
    "Secondary Theme" => [
      {:secondary_light, "#266ef1", "Secondary color (light mode)"},
      {:secondary_dark, "#6daafb", "Secondary color (dark mode)"},
      {:secondary_hover_light, "#175bcc", "Secondary hover (light)"},
      {:secondary_hover_dark, "#a9c9ff", "Secondary hover (dark)"},
      {:secondary_bordered_text_light, "#175bcc", "Secondary bordered text (light)"},
      {:secondary_bordered_text_dark, "#a9c9ff", "Secondary bordered text (dark)"},
      {:secondary_bordered_bg_light, "#eff4fe", "Secondary bordered background (light)"},
      {:secondary_bordered_bg_dark, "#002661", "Secondary bordered background (dark)"},
      {:secondary_indicator_light, "#1948a3", "Secondary indicator (light)"},
      {:secondary_indicator_dark, "#cddeff", "Secondary indicator (dark)"},
      {:secondary_border_light, "#1948a3", "Secondary border (light)"},
      {:secondary_border_dark, "#cddeff", "Secondary border (dark)"},
      {:secondary_gradient_indicator_dark, "#dee9fe", "Secondary gradient indicator (dark)"}
    ],
    "Success Theme" => [
      {:success_light, "#0e8345", "Success color (light mode)"},
      {:success_dark, "#06c167", "Success color (dark mode)"},
      {:success_hover_light, "#166c3b", "Success hover (light)"},
      {:success_hover_dark, "#7fd99a", "Success hover (dark)"},
      {:success_bordered_text_light, "#166c3b", "Success bordered text (light)"},
      {:success_bordered_text_dark, "#7fd99a", "Success bordered text (dark)"},
      {:success_bordered_bg_light, "#eaf6ed", "Success bordered background (light)"},
      {:success_bordered_bg_dark, "#002f14", "Success bordered background (dark)"},
      {:success_indicator_light, "#047857", "Success indicator (light)"},
      {:success_indicator_alt_light, "#0d572d", "Success indicator alt (light)"},
      {:success_indicator_dark, "#b1eac2", "Success indicator (dark)"},
      {:success_border_light, "#0d572d", "Success border (light)"},
      {:success_border_dark, "#b1eac2", "Success border (dark)"},
      {:success_gradient_indicator_dark, "#d3efda", "Success gradient indicator (dark)"}
    ],
    "Warning Theme" => [
      {:warning_light, "#ca8d01", "Warning color (light mode)"},
      {:warning_dark, "#fdc034", "Warning color (dark mode)"},
      {:warning_hover_light, "#976a01", "Warning hover (light)"},
      {:warning_hover_dark, "#fdd067", "Warning hover (dark)"},
      {:warning_bordered_text_light, "#976a01", "Warning bordered text (light)"},
      {:warning_bordered_text_dark, "#fdd067", "Warning bordered text (dark)"},
      {:warning_bordered_bg_light, "#fff7e6", "Warning bordered background (light)"},
      {:warning_bordered_bg_dark, "#322300", "Warning bordered background (dark)"},
      {:warning_indicator_light, "#ff8b08", "Warning indicator (light)"},
      {:warning_indicator_alt_light, "#654600", "Warning indicator alt (light)"},
      {:warning_indicator_dark, "#fedf99", "Warning indicator (dark)"},
      {:warning_border_light, "#654600", "Warning border (light)"},
      {:warning_border_dark, "#fedf99", "Warning border (dark)"},
      {:warning_gradient_indicator_dark, "#feefcc", "Warning gradient indicator (dark)"}
    ],
    "Danger Theme" => [
      {:danger_light, "#de1135", "Danger color (light mode)"},
      {:danger_dark, "#fc7f79", "Danger color (dark mode)"},
      {:danger_hover_light, "#bb032a", "Danger hover (light)"},
      {:danger_hover_dark, "#ffb2ab", "Danger hover (dark)"},
      {:danger_bordered_text_light, "#bb032a", "Danger bordered text (light)"},
      {:danger_bordered_text_dark, "#ffb2ab", "Danger bordered text (dark)"},
      {:danger_bordered_bg_light, "#fff0ee", "Danger bordered background (light)"},
      {:danger_bordered_bg_dark, "#520810", "Danger bordered background (dark)"},
      {:danger_indicator_light, "#e73b3b", "Danger indicator (light)"},
      {:danger_indicator_alt_light, "#950f22", "Danger indicator alt (light)"},
      {:danger_indicator_dark, "#ffd2cd", "Danger indicator (dark)"},
      {:danger_border_light, "#950f22", "Danger border (light)"},
      {:danger_border_dark, "#ffd2cd", "Danger border (dark)"},
      {:danger_gradient_indicator_dark, "#ffe1de", "Danger gradient indicator (dark)"}
    ],
    "Info Theme" => [
      {:info_light, "#0b84ba", "Info color (light mode)"},
      {:info_dark, "#3eb7ed", "Info color (dark mode)"},
      {:info_hover_light, "#08638c", "Info hover (light)"},
      {:info_hover_dark, "#6ec9f2", "Info hover (dark)"},
      {:info_bordered_text_light, "#0b84ba", "Info bordered text (light)"},
      {:info_bordered_text_dark, "#6ec9f2", "Info bordered text (dark)"},
      {:info_bordered_bg_light, "#e7f6fd", "Info bordered background (light)"},
      {:info_bordered_bg_dark, "#03212f", "Info bordered background (dark)"},
      {:info_indicator_light, "#004fc4", "Info indicator (light)"},
      {:info_indicator_alt_light, "#06425d", "Info indicator alt (light)"},
      {:info_indicator_dark, "#9fdbf6", "Info indicator (dark)"},
      {:info_border_light, "#06425d", "Info border (light)"},
      {:info_border_dark, "#9fdbf6", "Info border (dark)"},
      {:info_gradient_indicator_dark, "#cfedfb", "Info gradient indicator (dark)"}
    ],
    "Misc Theme" => [
      {:misc_light, "#8750c5", "Misc/purple color (light mode)"},
      {:misc_dark, "#ba83f9", "Misc/purple color (dark mode)"},
      {:misc_hover_light, "#653c94", "Misc hover (light)"},
      {:misc_hover_dark, "#cba2fa", "Misc hover (dark)"},
      {:misc_bordered_text_light, "#653c94", "Misc bordered text (light)"},
      {:misc_bordered_text_dark, "#cba2fa", "Misc bordered text (dark)"},
      {:misc_bordered_bg_light, "#f6f0fe", "Misc bordered background (light)"},
      {:misc_bordered_bg_dark, "#221431", "Misc bordered background (dark)"},
      {:misc_indicator_light, "#52059c", "Misc indicator (light)"},
      {:misc_indicator_alt_light, "#442863", "Misc indicator alt (light)"},
      {:misc_indicator_dark, "#ddc1fc", "Misc indicator (dark)"},
      {:misc_border_light, "#442863", "Misc border (light)"},
      {:misc_border_dark, "#ddc1fc", "Misc border (dark)"},
      {:misc_gradient_indicator_dark, "#eee0fd", "Misc gradient indicator (dark)"}
    ],
    "Dawn Theme" => [
      {:dawn_light, "#a86438", "Dawn/brown color (light mode)"},
      {:dawn_dark, "#db976b", "Dawn/brown color (dark mode)"},
      {:dawn_hover_light, "#7e4b2a", "Dawn hover (light)"},
      {:dawn_hover_dark, "#e4b190", "Dawn hover (dark)"},
      {:dawn_bordered_text_light, "#7e4b2a", "Dawn bordered text (light)"},
      {:dawn_bordered_text_dark, "#e4b190", "Dawn bordered text (dark)"},
      {:dawn_bordered_bg_light, "#fbf2ed", "Dawn bordered background (light)"},
      {:dawn_bordered_bg_dark, "#2a190e", "Dawn bordered background (dark)"},
      {:dawn_indicator_light, "#4d4137", "Dawn indicator (light)"},
      {:dawn_indicator_alt_light, "#54321c", "Dawn indicator alt (light)"},
      {:dawn_indicator_dark, "#edcbb5", "Dawn indicator (dark)"},
      {:dawn_border_light, "#54321c", "Dawn border (light)"},
      {:dawn_border_dark, "#edcbb5", "Dawn border (dark)"},
      {:dawn_gradient_indicator_dark, "#f6e5da", "Dawn gradient indicator (dark)"}
    ],
    "Silver Theme" => [
      {:silver_light, "#868686", "Silver color (light mode)"},
      {:silver_dark, "#a6a6a6", "Silver color (dark mode)"},
      {:silver_hover_light, "#727272", "Silver hover (light)"},
      {:silver_hover_dark, "#bbbbbb", "Silver hover (dark)"},
      {:silver_hover_bordered_light, "#E8E8E8", "Silver bordered hover (light)"},
      {:silver_hover_bordered_dark, "#5E5E5E", "Silver bordered hover (dark)"},
      {:silver_bordered_text_light, "#727272", "Silver bordered text (light)"},
      {:silver_bordered_text_dark, "#bbbbbb", "Silver bordered text (dark)"},
      {:silver_bordered_bg_light, "#f3f3f3", "Silver bordered background (light)"},
      {:silver_bordered_bg_dark, "#4b4b4b", "Silver bordered background (dark)"},
      {:silver_indicator_light, "#707483", "Silver indicator (light)"},
      {:silver_indicator_alt_light, "#5e5e5e", "Silver indicator alt (light)"},
      {:silver_indicator_dark, "#dddddd", "Silver indicator (dark)"},
      {:silver_border_light, "#5e5e5e", "Silver border (light)"},
      {:silver_border_dark, "#dddddd", "Silver border (dark)"}
    ],
    "Borders & States" => [
      {:bordered_white_border, "#dddddd", "White variant border"},
      {:bordered_dark_bg, "#282828", "Dark variant bordered background"},
      {:bordered_dark_border, "#727272", "Dark variant border"},
      {:disabled_bg_light, "#f3f3f3", "Disabled background (light)"},
      {:disabled_bg_dark, "#4b4b4b", "Disabled background (dark)"},
      {:disabled_text_light, "#bbbbbb", "Disabled text (light)"},
      {:disabled_text_dark, "#868686", "Disabled text (dark)"}
    ],
    "Shadows" => [
      {:shadow_natural, "rgba(134, 134, 134, 0.5)", "Natural shadow color"},
      {:shadow_primary, "rgba(0, 149, 164, 0.5)", "Primary shadow color"},
      {:shadow_secondary, "rgba(6, 139, 238, 0.5)", "Secondary shadow color"},
      {:shadow_success, "rgba(0, 154, 81, 0.5)", "Success shadow color"},
      {:shadow_warning, "rgba(252, 176, 1, 0.5)", "Warning shadow color"},
      {:shadow_danger, "rgba(248, 52, 70, 0.5)", "Danger shadow color"},
      {:shadow_info, "rgba(14, 165, 233, 0.5)", "Info shadow color"},
      {:shadow_misc, "rgba(169, 100, 247, 0.5)", "Misc shadow color"},
      {:shadow_dawn, "rgba(210, 125, 70, 0.5)", "Dawn shadow color"},
      {:shadow_silver, "rgba(134, 134, 134, 0.5)", "Silver shadow color"}
    ],
    "Gradients" => [
      {:gradient_natural_from_light, "#282828", "Natural gradient start (light)"},
      {:gradient_natural_to_light, "#727272", "Natural gradient end (light)"},
      {:gradient_natural_from_dark, "#a6a6a6", "Natural gradient start (dark)"},
      {:gradient_primary_from_light, "#016974", "Primary gradient start (light)"},
      {:gradient_primary_to_light, "#01b8ca", "Primary gradient end (light)"},
      {:gradient_primary_from_dark, "#01b8ca", "Primary gradient start (dark)"},
      {:gradient_primary_to_dark, "#b0e7ef", "Primary gradient end (dark)"},
      {:gradient_secondary_from_light, "#175bcc", "Secondary gradient start (light)"},
      {:gradient_secondary_to_light, "#6daafb", "Secondary gradient end (light)"},
      {:gradient_secondary_from_dark, "#6daafb", "Secondary gradient start (dark)"},
      {:gradient_secondary_to_dark, "#cddeff", "Secondary gradient end (dark)"},
      {:gradient_success_from_light, "#166c3b", "Success gradient start (light)"},
      {:gradient_success_to_light, "#06c167", "Success gradient end (light)"},
      {:gradient_success_from_dark, "#06c167", "Success gradient start (dark)"},
      {:gradient_success_to_dark, "#b1eac2", "Success gradient end (dark)"},
      {:gradient_warning_from_light, "#976a01", "Warning gradient start (light)"},
      {:gradient_warning_to_light, "#fdc034", "Warning gradient end (light)"},
      {:gradient_warning_from_dark, "#fdc034", "Warning gradient start (dark)"},
      {:gradient_warning_to_dark, "#fedf99", "Warning gradient end (dark)"},
      {:gradient_danger_from_light, "#bb032a", "Danger gradient start (light)"},
      {:gradient_danger_to_light, "#fc7f79", "Danger gradient end (light)"},
      {:gradient_danger_from_dark, "#fc7f79", "Danger gradient start (dark)"},
      {:gradient_danger_to_dark, "#ffd2cd", "Danger gradient end (dark)"},
      {:gradient_info_from_light, "#08638c", "Info gradient start (light)"},
      {:gradient_info_to_light, "#3eb7ed", "Info gradient end (light)"},
      {:gradient_info_from_dark, "#3eb7ed", "Info gradient start (dark)"},
      {:gradient_info_to_dark, "#9fdbf6", "Info gradient end (dark)"},
      {:gradient_misc_from_light, "#653c94", "Misc gradient start (light)"},
      {:gradient_misc_to_light, "#ba83f9", "Misc gradient end (light)"},
      {:gradient_misc_from_dark, "#ba83f9", "Misc gradient start (dark)"},
      {:gradient_misc_to_dark, "#ddc1fc", "Misc gradient end (dark)"},
      {:gradient_dawn_from_light, "#7e4b2a", "Dawn gradient start (light)"},
      {:gradient_dawn_to_light, "#db976b", "Dawn gradient end (light)"},
      {:gradient_dawn_from_dark, "#db976b", "Dawn gradient start (dark)"},
      {:gradient_dawn_to_dark, "#edcbb5", "Dawn gradient end (dark)"},
      {:gradient_silver_from_light, "#5e5e5e", "Silver gradient start (light)"},
      {:gradient_silver_to_light, "#a6a6a6", "Silver gradient end (light)"},
      {:gradient_silver_from_dark, "#868686", "Silver gradient start (dark)"},
      {:gradient_silver_to_dark, "#bbbbbb", "Silver gradient end (dark)"}
    ],
    "Form Elements" => [
      {:base_form_border_light, "#8b8b8d", "Form border (light)"},
      {:base_form_border_dark, "#818182", "Form border (dark)"},
      {:base_form_focus_dark, "#696969", "Form focus (dark)"},
      {:form_white_text, "#3e3e3e", "Form white theme text"},
      {:form_white_focus, "#dadada", "Form white theme focus"}
    ],
    "Checkbox Colors" => [
      {:checkbox_unchecked_dark, "#333333", "Checkbox unchecked (dark)"},
      {:checkbox_white_checked, "#ede8e8", "White checkbox checked"},
      {:checkbox_dark_checked, "#616060", "Dark checkbox checked"},
      {:checkbox_primary_checked, "#0095a4", "Primary checkbox checked"},
      {:checkbox_secondary_checked, "#068bee", "Secondary checkbox checked"},
      {:checkbox_success_checked, "#009a51", "Success checkbox checked"},
      {:checkbox_warning_checked, "#fcb001", "Warning checkbox checked"},
      {:checkbox_danger_checked, "#f83446", "Danger checkbox checked"},
      {:checkbox_info_checked, "#0ea5e9", "Info checkbox checked"},
      {:checkbox_misc_checked, "#a964f7", "Misc checkbox checked"},
      {:checkbox_dawn_checked, "#d27d46", "Dawn checkbox checked"},
      {:checkbox_silver_checked, "#a6a6a6", "Silver checkbox checked"}
    ],
    "Stepper Colors" => [
      {:stepper_loading_icon_fill, "#2563eb", "Stepper loading icon fill"},
      {:stepper_current_step_text_light, "#2563eb", "Current step text (light)"},
      {:stepper_current_step_text_dark, "#1971c2", "Current step text (dark)"},
      {:stepper_current_step_border_light, "#2563eb", "Current step border (light)"},
      {:stepper_current_step_border_dark, "#1971c2", "Current step border (dark)"},
      {:stepper_completed_step_bg_light, "#14b8a6", "Completed step background (light)"},
      {:stepper_completed_step_bg_dark, "#099268", "Completed step background (dark)"},
      {:stepper_completed_step_border_light, "#14b8a6", "Completed step border (light)"},
      {:stepper_completed_step_border_dark, "#099268", "Completed step border (dark)"},
      {:stepper_canceled_step_bg_light, "#fa5252", "Canceled step background (light)"},
      {:stepper_canceled_step_bg_dark, "#e03131", "Canceled step background (dark)"},
      {:stepper_canceled_step_border_light, "#fa5252", "Canceled step border (light)"},
      {:stepper_canceled_step_border_dark, "#e03131", "Canceled step border (dark)"},
      {:stepper_separator_completed_border_light, "#14b8a6",
       "Separator completed border (light)"},
      {:stepper_separator_completed_border_dark, "#099268", "Separator completed border (dark)"}
    ]
  }

  # Order for display
  @category_order [
    "Base Colors",
    "Default Colors",
    "Natural Theme",
    "Primary Theme",
    "Secondary Theme",
    "Success Theme",
    "Warning Theme",
    "Danger Theme",
    "Info Theme",
    "Misc Theme",
    "Dawn Theme",
    "Silver Theme",
    "Borders & States",
    "Shadows",
    "Gradients",
    "Form Elements",
    "Checkbox Colors",
    "Stepper Colors"
  ]

  @impl true
  def read(_params, frame) do
    content = format_css_variables()

    response =
      Response.resource()
      |> Response.text(content)

    {:reply, response, frame}
  end

  @doc """
  Returns all CSS variable names as a flat list.
  """
  def all_variable_names do
    @css_variables
    |> Enum.flat_map(fn {_category, variables} ->
      Enum.map(variables, fn {name, _default, _desc} -> name end)
    end)
  end

  @doc """
  Returns the total count of CSS variables.
  """
  def variable_count do
    @css_variables
    |> Enum.map(fn {_category, variables} -> length(variables) end)
    |> Enum.sum()
  end

  defp format_css_variables do
    total = variable_count()

    categories =
      @category_order
      |> Enum.map(fn category ->
        variables = Map.get(@css_variables, category, [])

        vars =
          variables
          |> Enum.map(fn {name, default, desc} ->
            "| `#{name}` | `#{default}` | #{desc} |"
          end)
          |> Enum.join("\n")

        """
        ### #{category}

        | Variable | Default | Description |
        |----------|---------|-------------|
        #{vars}
        """
      end)
      |> Enum.join("\n")

    """
    # Mishka Chelekom CSS Variables

    **Total: #{total} customizable CSS variables**

    These CSS variables can be overridden in `priv/mishka_chelekom/config.exs`.
    By default, all values are **commented out** and use the default colors shown below.
    Uncomment and change any value to customize your design system.

    > **Note:** Variable names use underscores in config (e.g., `primary_light`)
    > which map to CSS variables with dashes (e.g., `--primary-light`).

    ---

    ## How to Override

    1. Initialize the config file (if not exists):

    ```bash
    mix mishka.ui.css.config --init
    ```

    2. Edit `priv/mishka_chelekom/config.exs`:

    ```elixir
    config :mishka_chelekom,
      css_overrides: %{
        # Uncomment and change values to customize
        primary_light: "#2563eb",
        primary_dark: "#3b82f6",
        danger_light: "#dc2626",
        danger_dark: "#ef4444"
      }
    ```

    3. Regenerate CSS:

    ```bash
    mix mishka.ui.css.config --regenerate
    ```

    ---

    ## Available Variables by Category

    #{categories}

    ---

    ## Related MCP Tools

    - `list_colors` - See component color options (primary, danger, etc.)
    - `update_config(setting: "css_override", variable: "...", value: "...")` - Generate config code
    - `get_config` - View current config file

    ---

    📖 Docs: https://mishka.tools/chelekom/docs/cli
    """
  end
end
