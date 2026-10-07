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

  # What each variable is for, by category. The names and their defaults are read from
  # Chelekom's stylesheet (`MishkaChelekom.Config.default_variables/0`); a variable it declares
  # that is not described here is listed under "Other" rather than left out.
  @css_variables %{
    "Opacity" => [
      {:opacity_base, "Step the `data-opacity` levels are counted in"},
      {:overlay_opacity, "Overlay opacity, set per `data-opacity` level"}
    ],
    "Base Colors" => [
      {:base_border_light, "Light mode border color"},
      {:base_border_dark, "Dark mode border color"},
      {:base_text_light, "Light mode text color"},
      {:base_text_dark, "Dark mode text color"},
      {:base_bg_dark, "Dark mode background"},
      {:base_hover_light, "Light mode hover background"},
      {:base_hover_dark, "Dark mode hover background"},
      {:base_disabled_bg_light, "Light mode disabled background"},
      {:base_text_hover_light, "Light mode text hover"},
      {:base_text_hover_dark, "Dark mode text hover"},
      {:base_disabled_bg_dark, "Dark mode disabled background"},
      {:base_disabled_text_light, "Light mode disabled text"},
      {:base_disabled_text_dark, "Dark mode disabled text"},
      {:base_disabled_border_light, "Light mode disabled border"},
      {:base_disabled_border_dark, "Dark mode disabled border"},
      {:base_tab_bg_light, "Light mode tab background"}
    ],
    "Default Colors" => [
      {:default_dark_bg, "Default dark background"},
      {:default_light_gray, "Default light gray"},
      {:default_gray, "Default gray"},
      {:ring_dark, "Dark ring color"},
      {:default_device_dark, "Device mockup dark color"},
      {:range_light_gray, "Range slider light gray"}
    ],
    "Natural Theme" => [
      {:natural_light, "Natural gray (light mode)"},
      {:natural_dark, "Natural gray (dark mode)"},
      {:natural_hover_light, "Natural hover (light)"},
      {:natural_hover_dark, "Natural hover (dark)"},
      {:natural_bordered_hover_light, "Natural bordered hover (light)"},
      {:natural_bordered_hover_dark, "Natural bordered hover (dark)"},
      {:natural_bg_light, "Natural background (light)"},
      {:natural_bg_dark, "Natural background (dark)"},
      {:natural_border_light, "Natural border (light)"},
      {:natural_border_dark, "Natural border (dark)"},
      {:natural_bordered_text_light, "Natural bordered text (light)"},
      {:natural_bordered_text_dark, "Natural bordered text (dark)"},
      {:natural_bordered_bg_light, "Natural bordered background (light)"},
      {:natural_bordered_bg_dark, "Natural bordered background (dark)"},
      {:natural_disabled_light, "Natural disabled (light)"},
      {:natural_disabled_dark, "Natural disabled (dark)"}
    ],
    "Primary Theme" => [
      {:primary_light, "Primary color (light mode)"},
      {:primary_dark, "Primary color (dark mode)"},
      {:primary_hover_light, "Primary hover (light)"},
      {:primary_hover_dark, "Primary hover (dark)"},
      {:primary_bordered_text_light, "Primary bordered text (light)"},
      {:primary_bordered_text_dark, "Primary bordered text (dark)"},
      {:primary_bordered_bg_light, "Primary bordered background (light)"},
      {:primary_bordered_bg_dark, "Primary bordered background (dark)"},
      {:primary_indicator_light, "Primary indicator (light)"},
      {:primary_indicator_dark, "Primary indicator (dark)"},
      {:primary_border_light, "Primary border (light)"},
      {:primary_border_dark, "Primary border (dark)"},
      {:primary_gradient_indicator_dark, "Primary gradient indicator (dark)"}
    ],
    "Secondary Theme" => [
      {:secondary_light, "Secondary color (light mode)"},
      {:secondary_dark, "Secondary color (dark mode)"},
      {:secondary_hover_light, "Secondary hover (light)"},
      {:secondary_hover_dark, "Secondary hover (dark)"},
      {:secondary_bordered_text_light, "Secondary bordered text (light)"},
      {:secondary_bordered_text_dark, "Secondary bordered text (dark)"},
      {:secondary_bordered_bg_light, "Secondary bordered background (light)"},
      {:secondary_bordered_bg_dark, "Secondary bordered background (dark)"},
      {:secondary_indicator_light, "Secondary indicator (light)"},
      {:secondary_indicator_dark, "Secondary indicator (dark)"},
      {:secondary_border_light, "Secondary border (light)"},
      {:secondary_border_dark, "Secondary border (dark)"},
      {:secondary_gradient_indicator_dark, "Secondary gradient indicator (dark)"}
    ],
    "Success Theme" => [
      {:success_light, "Success color (light mode)"},
      {:success_dark, "Success color (dark mode)"},
      {:success_hover_light, "Success hover (light)"},
      {:success_hover_dark, "Success hover (dark)"},
      {:success_bordered_text_light, "Success bordered text (light)"},
      {:success_bordered_text_dark, "Success bordered text (dark)"},
      {:success_bordered_bg_light, "Success bordered background (light)"},
      {:success_bordered_bg_dark, "Success bordered background (dark)"},
      {:success_indicator_light, "Success indicator (light)"},
      {:success_indicator_alt_light, "Success indicator alt (light)"},
      {:success_indicator_dark, "Success indicator (dark)"},
      {:success_border_light, "Success border (light)"},
      {:success_border_dark, "Success border (dark)"},
      {:success_gradient_indicator_dark, "Success gradient indicator (dark)"}
    ],
    "Warning Theme" => [
      {:warning_light, "Warning color (light mode)"},
      {:warning_dark, "Warning color (dark mode)"},
      {:warning_hover_light, "Warning hover (light)"},
      {:warning_hover_dark, "Warning hover (dark)"},
      {:warning_bordered_text_light, "Warning bordered text (light)"},
      {:warning_bordered_text_dark, "Warning bordered text (dark)"},
      {:warning_bordered_bg_light, "Warning bordered background (light)"},
      {:warning_bordered_bg_dark, "Warning bordered background (dark)"},
      {:warning_indicator_light, "Warning indicator (light)"},
      {:warning_indicator_alt_light, "Warning indicator alt (light)"},
      {:warning_indicator_dark, "Warning indicator (dark)"},
      {:warning_border_light, "Warning border (light)"},
      {:warning_border_dark, "Warning border (dark)"},
      {:warning_gradient_indicator_dark, "Warning gradient indicator (dark)"}
    ],
    "Danger Theme" => [
      {:danger_light, "Danger color (light mode)"},
      {:danger_dark, "Danger color (dark mode)"},
      {:danger_hover_light, "Danger hover (light)"},
      {:danger_hover_dark, "Danger hover (dark)"},
      {:danger_bordered_text_light, "Danger bordered text (light)"},
      {:danger_bordered_text_dark, "Danger bordered text (dark)"},
      {:danger_bordered_bg_light, "Danger bordered background (light)"},
      {:danger_bordered_bg_dark, "Danger bordered background (dark)"},
      {:danger_indicator_light, "Danger indicator (light)"},
      {:danger_indicator_alt_light, "Danger indicator alt (light)"},
      {:danger_indicator_dark, "Danger indicator (dark)"},
      {:danger_border_light, "Danger border (light)"},
      {:danger_border_dark, "Danger border (dark)"},
      {:danger_gradient_indicator_dark, "Danger gradient indicator (dark)"}
    ],
    "Info Theme" => [
      {:info_light, "Info color (light mode)"},
      {:info_dark, "Info color (dark mode)"},
      {:info_hover_light, "Info hover (light)"},
      {:info_hover_dark, "Info hover (dark)"},
      {:info_bordered_text_light, "Info bordered text (light)"},
      {:info_bordered_text_dark, "Info bordered text (dark)"},
      {:info_bordered_bg_light, "Info bordered background (light)"},
      {:info_bordered_bg_dark, "Info bordered background (dark)"},
      {:info_indicator_light, "Info indicator (light)"},
      {:info_indicator_alt_light, "Info indicator alt (light)"},
      {:info_indicator_dark, "Info indicator (dark)"},
      {:info_border_light, "Info border (light)"},
      {:info_border_dark, "Info border (dark)"},
      {:info_gradient_indicator_dark, "Info gradient indicator (dark)"}
    ],
    "Misc Theme" => [
      {:misc_light, "Misc/purple color (light mode)"},
      {:misc_dark, "Misc/purple color (dark mode)"},
      {:misc_hover_light, "Misc hover (light)"},
      {:misc_hover_dark, "Misc hover (dark)"},
      {:misc_bordered_text_light, "Misc bordered text (light)"},
      {:misc_bordered_text_dark, "Misc bordered text (dark)"},
      {:misc_bordered_bg_light, "Misc bordered background (light)"},
      {:misc_bordered_bg_dark, "Misc bordered background (dark)"},
      {:misc_indicator_light, "Misc indicator (light)"},
      {:misc_indicator_alt_light, "Misc indicator alt (light)"},
      {:misc_indicator_dark, "Misc indicator (dark)"},
      {:misc_border_light, "Misc border (light)"},
      {:misc_border_dark, "Misc border (dark)"},
      {:misc_gradient_indicator_dark, "Misc gradient indicator (dark)"}
    ],
    "Dawn Theme" => [
      {:dawn_light, "Dawn/brown color (light mode)"},
      {:dawn_dark, "Dawn/brown color (dark mode)"},
      {:dawn_hover_light, "Dawn hover (light)"},
      {:dawn_hover_dark, "Dawn hover (dark)"},
      {:dawn_bordered_text_light, "Dawn bordered text (light)"},
      {:dawn_bordered_text_dark, "Dawn bordered text (dark)"},
      {:dawn_bordered_bg_light, "Dawn bordered background (light)"},
      {:dawn_bordered_bg_dark, "Dawn bordered background (dark)"},
      {:dawn_indicator_light, "Dawn indicator (light)"},
      {:dawn_indicator_alt_light, "Dawn indicator alt (light)"},
      {:dawn_indicator_dark, "Dawn indicator (dark)"},
      {:dawn_border_light, "Dawn border (light)"},
      {:dawn_border_dark, "Dawn border (dark)"},
      {:dawn_gradient_indicator_dark, "Dawn gradient indicator (dark)"}
    ],
    "Silver Theme" => [
      {:silver_light, "Silver color (light mode)"},
      {:silver_dark, "Silver color (dark mode)"},
      {:silver_hover_light, "Silver hover (light)"},
      {:silver_hover_dark, "Silver hover (dark)"},
      {:silver_hover_bordered_light, "Silver bordered hover (light)"},
      {:silver_hover_bordered_dark, "Silver bordered hover (dark)"},
      {:silver_bordered_text_light, "Silver bordered text (light)"},
      {:silver_bordered_text_dark, "Silver bordered text (dark)"},
      {:silver_bordered_bg_light, "Silver bordered background (light)"},
      {:silver_bordered_bg_dark, "Silver bordered background (dark)"},
      {:silver_indicator_light, "Silver indicator (light)"},
      {:silver_indicator_alt_light, "Silver indicator alt (light)"},
      {:silver_indicator_dark, "Silver indicator (dark)"},
      {:silver_border_light, "Silver border (light)"},
      {:silver_border_dark, "Silver border (dark)"}
    ],
    "Borders & States" => [
      {:bordered_white_border, "White variant border"},
      {:bordered_dark_bg, "Dark variant bordered background"},
      {:bordered_dark_border, "Dark variant border"},
      {:disabled_bg_light, "Disabled background (light)"},
      {:disabled_bg_dark, "Disabled background (dark)"},
      {:disabled_text_light, "Disabled text (light)"},
      {:disabled_text_dark, "Disabled text (dark)"}
    ],
    "Shadows" => [
      {:shadow_natural, "Natural shadow color"},
      {:shadow_primary, "Primary shadow color"},
      {:shadow_secondary, "Secondary shadow color"},
      {:shadow_success, "Success shadow color"},
      {:shadow_warning, "Warning shadow color"},
      {:shadow_danger, "Danger shadow color"},
      {:shadow_info, "Info shadow color"},
      {:shadow_misc, "Misc shadow color"},
      {:shadow_dawn, "Dawn shadow color"},
      {:shadow_silver, "Silver shadow color"}
    ],
    "Gradients" => [
      {:gradient_natural_from_light, "Natural gradient start (light)"},
      {:gradient_natural_to_light, "Natural gradient end (light)"},
      {:gradient_natural_from_dark, "Natural gradient start (dark)"},
      {:gradient_primary_from_light, "Primary gradient start (light)"},
      {:gradient_primary_to_light, "Primary gradient end (light)"},
      {:gradient_primary_from_dark, "Primary gradient start (dark)"},
      {:gradient_primary_to_dark, "Primary gradient end (dark)"},
      {:gradient_secondary_from_light, "Secondary gradient start (light)"},
      {:gradient_secondary_to_light, "Secondary gradient end (light)"},
      {:gradient_secondary_from_dark, "Secondary gradient start (dark)"},
      {:gradient_secondary_to_dark, "Secondary gradient end (dark)"},
      {:gradient_success_from_light, "Success gradient start (light)"},
      {:gradient_success_to_light, "Success gradient end (light)"},
      {:gradient_success_from_dark, "Success gradient start (dark)"},
      {:gradient_success_to_dark, "Success gradient end (dark)"},
      {:gradient_warning_from_light, "Warning gradient start (light)"},
      {:gradient_warning_to_light, "Warning gradient end (light)"},
      {:gradient_warning_from_dark, "Warning gradient start (dark)"},
      {:gradient_warning_to_dark, "Warning gradient end (dark)"},
      {:gradient_danger_from_light, "Danger gradient start (light)"},
      {:gradient_danger_to_light, "Danger gradient end (light)"},
      {:gradient_danger_from_dark, "Danger gradient start (dark)"},
      {:gradient_danger_to_dark, "Danger gradient end (dark)"},
      {:gradient_info_from_light, "Info gradient start (light)"},
      {:gradient_info_to_light, "Info gradient end (light)"},
      {:gradient_info_from_dark, "Info gradient start (dark)"},
      {:gradient_info_to_dark, "Info gradient end (dark)"},
      {:gradient_misc_from_light, "Misc gradient start (light)"},
      {:gradient_misc_to_light, "Misc gradient end (light)"},
      {:gradient_misc_from_dark, "Misc gradient start (dark)"},
      {:gradient_misc_to_dark, "Misc gradient end (dark)"},
      {:gradient_dawn_from_light, "Dawn gradient start (light)"},
      {:gradient_dawn_to_light, "Dawn gradient end (light)"},
      {:gradient_dawn_from_dark, "Dawn gradient start (dark)"},
      {:gradient_dawn_to_dark, "Dawn gradient end (dark)"},
      {:gradient_silver_from_light, "Silver gradient start (light)"},
      {:gradient_silver_to_light, "Silver gradient end (light)"},
      {:gradient_silver_from_dark, "Silver gradient start (dark)"},
      {:gradient_silver_to_dark, "Silver gradient end (dark)"}
    ],
    "Form Elements" => [
      {:base_form_border_light, "Form border (light)"},
      {:base_form_border_dark, "Form border (dark)"},
      {:base_form_focus_dark, "Form focus (dark)"},
      {:form_white_text, "Form white theme text"},
      {:form_white_focus, "Form white theme focus"}
    ],
    "Checkbox Colors" => [
      {:checkbox_unchecked_dark, "Checkbox unchecked (dark)"},
      {:checkbox_white_checked, "White checkbox checked"},
      {:checkbox_dark_checked, "Dark checkbox checked"},
      {:checkbox_primary_checked, "Primary checkbox checked"},
      {:checkbox_secondary_checked, "Secondary checkbox checked"},
      {:checkbox_success_checked, "Success checkbox checked"},
      {:checkbox_warning_checked, "Warning checkbox checked"},
      {:checkbox_danger_checked, "Danger checkbox checked"},
      {:checkbox_info_checked, "Info checkbox checked"},
      {:checkbox_misc_checked, "Misc checkbox checked"},
      {:checkbox_dawn_checked, "Dawn checkbox checked"},
      {:checkbox_silver_checked, "Silver checkbox checked"}
    ],
    "Stepper Colors" => [
      {:stepper_loading_icon_fill, "Stepper loading icon fill"},
      {:stepper_current_step_text_light, "Current step text (light)"},
      {:stepper_current_step_text_dark, "Current step text (dark)"},
      {:stepper_current_step_border_light, "Current step border (light)"},
      {:stepper_current_step_border_dark, "Current step border (dark)"},
      {:stepper_completed_step_bg_light, "Completed step background (light)"},
      {:stepper_completed_step_bg_dark, "Completed step background (dark)"},
      {:stepper_completed_step_border_light, "Completed step border (light)"},
      {:stepper_completed_step_border_dark, "Completed step border (dark)"},
      {:stepper_canceled_step_bg_light, "Canceled step background (light)"},
      {:stepper_canceled_step_bg_dark, "Canceled step background (dark)"},
      {:stepper_canceled_step_border_light, "Canceled step border (light)"},
      {:stepper_canceled_step_border_dark, "Canceled step border (dark)"},
      {:stepper_separator_completed_border_light, "Separator completed border (light)"},
      {:stepper_separator_completed_border_dark, "Separator completed border (dark)"}
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
    "Stepper Colors",
    "Opacity"
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
  Every CSS variable Chelekom's stylesheet declares on `:root`, as `config.exs` names it.
  """
  def all_variable_names, do: Enum.map(variables(), &elem(&1, 0))

  @doc """
  Returns the total count of CSS variables.
  """
  def variable_count, do: length(variables())

  @doc """
  The names `@css_variables` describes, for checking them against the stylesheet.
  """
  def described_variable_names do
    Enum.flat_map(@css_variables, fn {_category, variables} ->
      Enum.map(variables, &elem(&1, 0))
    end)
  end

  defp variables do
    Enum.map(MishkaChelekom.Config.default_variables(), fn {"--" <> name, default} ->
      {String.to_atom(String.replace(name, "-", "_")), default}
    end)
  end

  defp format_css_variables do
    defaults = Map.new(variables())
    described = MapSet.new(described_variable_names())

    other =
      for {name, _default} <- variables(), name not in described, do: {name, "Not described yet"}

    sections =
      Enum.map(@category_order, &{&1, Map.get(@css_variables, &1, [])}) ++
        if(other == [], do: [], else: [{"Other", other}])

    total = map_size(defaults)

    categories =
      sections
      |> Enum.map(fn {category, variables} ->
        vars =
          variables
          |> Enum.filter(fn {name, _desc} -> Map.has_key?(defaults, name) end)
          |> Enum.map(fn {name, desc} ->
            "| `#{name}` | `#{Map.fetch!(defaults, name)}` | #{desc} |"
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
