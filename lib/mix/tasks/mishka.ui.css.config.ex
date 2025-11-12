defmodule Mix.Tasks.Mishka.Ui.Css.Config do
  use Igniter.Mix.Task
  alias MishkaChelekom.CSSConfig

  @example "mix mishka.ui.css.config --init"
  @shortdoc "Manages CSS configuration for Mishka Chelekom components"
  @moduledoc """
  #{@shortdoc}

  This task helps you manage CSS customization for Mishka components.
  You can create a configuration file, validate it, or regenerate CSS with your overrides.

  ## Examples

  Initialize a configuration file:
  ```bash
  mix mishka.ui.css.config --init
  ```

  Force overwrite existing configuration with sample:
  ```bash
  mix mishka.ui.css.config --init --force
  ```

  Regenerate CSS with current configuration:
  ```bash
  mix mishka.ui.css.config --regenerate
  ```

  Validate your configuration:
  ```bash
  mix mishka.ui.css.config --validate
  ```

  ## Options

  * `--init` - Creates a sample configuration file
  * `--force` - Force overwrite existing configuration file (use with --init)
  * `--regenerate` - Regenerates CSS files with current configuration
  * `--validate` - Validates the current configuration
  * `--show` - Shows the current configuration
  """

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      adds_deps: [],
      installs: [],
      example: @example,
      extra_args?: false,
      only: nil,
      positional: [],
      composes: [],
      schema: [
        init: :boolean,
        force: :boolean,
        regenerate: :boolean,
        validate: :boolean,
        show: :boolean
      ],
      aliases: [
        i: :init,
        f: :force,
        r: :regenerate,
        v: :validate,
        s: :show
      ]
    }
  end

  def igniter(igniter) do
    options = igniter.args.options

    cond do
      options[:init] ->
        init_config(igniter)

      options[:regenerate] ->
        regenerate_css(igniter)

      options[:validate] ->
        validate_config(igniter)

      options[:show] ->
        show_config(igniter)

      true ->
        igniter
        |> Igniter.add_warning("""
        Please specify an action:

        --init       Create a sample configuration file
        --init --force  Force overwrite existing configuration
        --regenerate Regenerate CSS with your configuration
        --validate   Validate your configuration
        --show       Display current configuration

        Example: mix mishka.ui.css.config --init
        """)
    end
  end

  defp init_config(igniter) do
    {igniter, config_path, content} = CSSConfig.create_sample_config(igniter)
    options = igniter.args.options
    force = Keyword.get(options, :force, false)

    # Check if file already exists in the igniter's sources
    existing_source = igniter.rewrite.sources[config_path]
    file_exists = existing_source != nil || File.exists?(config_path)

    cond do
      file_exists && !force ->
        igniter
        |> Igniter.add_notice("""
        Configuration file already exists at:
        #{config_path}

        You can edit this file to customize CSS variables.
        To overwrite with a fresh sample, use: mix mishka.ui.css.config --init --force
        """)

      file_exists && force ->
        igniter
        |> Igniter.create_or_update_file(config_path, content, fn source ->
          Rewrite.Source.update(source, :content, content)
        end)
        |> Igniter.add_notice("""
        Configuration file overwritten at:
        #{config_path}

        Previous configuration has been replaced.
        You can now customize CSS variables by editing this file.
        Run `mix mishka.ui.css.config --regenerate` after making changes.
        """)

      true ->
        igniter
        |> Igniter.create_or_update_file(config_path, content, fn source ->
          Rewrite.Source.update(source, :content, content)
        end)
        |> Igniter.add_notice("""
        Created configuration file at:
        #{config_path}

        You can now customize CSS variables by editing this file.
        Run `mix mishka.ui.css.config --regenerate` after making changes.
        """)
    end
  end

  defp regenerate_css(igniter) do
    vendor_css_path = "assets/vendor/mishka_chelekom.css"

    # Generate CSS with user configuration
    css_content = CSSConfig.generate_css_content(igniter)

    igniter
    |> Igniter.create_or_update_file(vendor_css_path, css_content, fn source ->
      Rewrite.Source.update(source, :content, css_content)
    end)
    |> Igniter.add_notice("""
    CSS file regenerated with your configuration.

    Updated file:
    - #{vendor_css_path}

    Your customizations have been applied.
    """)
  end

  defp validate_config(igniter) do
    config = CSSConfig.load_user_config(igniter)
    config_path = Path.join(["priv", "mishka_chelekom", "config.exs"])

    issues = validate_configuration(config)

    if issues == [] do
      igniter
      |> Igniter.add_notice("""
      Configuration is valid! ✓

      Configuration file: #{config_path}
      Strategy: #{config.css_merge_strategy}
      CSS overrides: #{map_size(config.css_overrides)} variables
      #{if config.custom_css_path, do: "Custom CSS: #{config.custom_css_path}", else: ""}
      """)
    else
      igniter
      |> Igniter.add_issue("""
      Configuration validation failed:

      #{Enum.join(issues, "\n")}
      """)
    end
  end

  defp validate_configuration(config) do
    []
    |> validate_merge_strategy(config)
    |> validate_custom_css_path(config)
    |> validate_css_overrides(config)
    |> validate_component_lists(config)
  end

  defp validate_merge_strategy(issues, %{css_merge_strategy: strategy})
       when strategy in [:merge, :replace],
       do: issues

  defp validate_merge_strategy(issues, %{css_merge_strategy: strategy}) do
    [
      "Invalid css_merge_strategy: #{inspect(strategy)}. Must be :merge or :replace"
      | issues
    ]
  end

  defp validate_custom_css_path(issues, %{css_merge_strategy: :replace, custom_css_path: nil}) do
    ["When using :replace strategy, custom_css_path must be provided" | issues]
  end

  defp validate_custom_css_path(issues, %{custom_css_path: path}) when is_binary(path) do
    if File.exists?(path) do
      issues
    else
      ["Custom CSS file not found: #{path}" | issues]
    end
  end

  defp validate_custom_css_path(issues, _config), do: issues

  defp validate_css_overrides(issues, %{css_overrides: overrides}) when is_map(overrides) do
    Enum.reduce(overrides, issues, fn
      {_key, value}, acc when is_binary(value) ->
        acc

      {key, value}, acc ->
        ["CSS override '#{key}' must be a string, got: #{inspect(value)}" | acc]
    end)
  end

  defp validate_css_overrides(issues, _config), do: issues

  defp validate_component_lists(issues, config) do
    component_fields = [
      {:exclude_components, "Excluded components"},
      {:component_colors, "Component colors"},
      {:component_variants, "Component variants"},
      {:component_sizes, "Component sizes"},
      {:component_rounded, "Component rounded"},
      {:component_padding, "Component padding"},
      {:component_space, "Component space"},
      {:component_prefix, "Function prefix"}
    ]

    Enum.reduce(component_fields, issues, fn {field, label}, acc ->
      validate_list_field(acc, Map.get(config, field), field, label)
    end)
  end

  defp validate_list_field(issues, values, _field, label) when is_list(values) do
    if Enum.all?(values, &is_binary/1) do
      issues
    else
      invalid_values =
        values
        |> Enum.reject(&is_binary/1)
        |> Enum.map(&inspect/1)
        |> Enum.join(", ")

      ["#{label} must contain only strings. Invalid values: #{invalid_values}" | issues]
    end
  end

  defp validate_list_field(issues, nil, _field, _label), do: issues

  defp validate_list_field(issues, value, _field, label) do
    ["#{label} must be a list, got: #{inspect(value)}" | issues]
  end

  defp show_config(igniter) do
    config = CSSConfig.load_user_config(igniter)
    config_path = Path.join(["priv", "mishka_chelekom", "config.exs"])

    overrides_display =
      if map_size(config.css_overrides) > 0 do
        config.css_overrides
        |> Enum.map(fn {k, v} -> "* #{k}: #{inspect(v)}" end)
        |> Enum.join("\n")
      else
        "* (none)"
      end

    # Format component filters display
    component_filters = [
      {"Excluded components", config.exclude_components},
      {"Component colors", config.component_colors},
      {"Component variants", config.component_variants},
      {"Component sizes", config.component_sizes},
      {"Component rounded", config.component_rounded},
      {"Component padding", config.component_padding},
      {"Component space", config.component_space},
      {"Function prefix", config.component_prefix}
    ]

    filters_display =
      component_filters
      |> Enum.map(fn {label, values} ->
        dif = if(label == "Excluded components", do: "(none)", else: "(all)")
        value_str = if values == [], do: dif, else: inspect(values)
        "* #{label}: #{value_str}"
      end)
      |> Enum.join("\n")

    igniter
    |> Igniter.add_notice("""
    Current Mishka CSS Configuration: #{if File.exists?(config_path), do: config_path, else: "(not created)"}

    ### CSS Configuration

    Strategy: #{config.css_merge_strategy}
    Custom CSS path: #{config.custom_css_path || "(not set)"}

    ----------------------------------------
    ### Component Filters

    #{filters_display}

    ----------------------------------------
    ### CSS Variable Overrides

    #{overrides_display}

    ----------------------------------------

    To modify, edit: #{config_path}
    Then run: mix mishka.ui.css.config --regenerate
    """)
  end
end
