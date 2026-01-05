defmodule MishkaChelekom.MCP.Tools.ValidateConfig do
  @moduledoc """
  Validate the Mishka Chelekom configuration file.

  Checks `priv/mishka_chelekom/config.exs` for:
  - Valid syntax
  - Valid setting names
  - Valid value types
  - File existence for custom CSS paths

  ## Usage

      validate_config()
  """

  use Anubis.Server.Component, type: :tool

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.PathHelper

  schema do
    # No required parameters - validates the config file
  end

  @impl true
  def execute(_params, frame) do
    config_path = PathHelper.user_config_path()

    content =
      if File.exists?(config_path) do
        validate_config_file(config_path)
      else
        format_no_config()
      end

    response =
      Response.tool()
      |> Response.text(content)

    {:reply, response, frame}
  end

  defp validate_config_file(config_path) do
    case parse_config_safely(config_path) do
      {:ok, config} ->
        issues = validate_configuration(config, config_path)
        format_validation_result(config_path, config, issues)

      {:error, reason} ->
        format_parse_error(config_path, reason)
    end
  end

  defp parse_config_safely(config_path) do
    try do
      config = Config.Reader.read!(config_path)
      mishka_config = Keyword.get(config, :mishka_chelekom, [])
      {:ok, mishka_config}
    rescue
      e in [CompileError, SyntaxError] ->
        {:error, Exception.message(e)}

      e ->
        {:error, inspect(e)}
    end
  end

  defp validate_configuration(config, config_path) do
    []
    |> validate_merge_strategy(config)
    |> validate_custom_css_path(config, config_path)
    |> validate_css_overrides(config)
    |> validate_list_fields(config)
    |> validate_string_fields(config)
  end

  defp validate_merge_strategy(issues, config) do
    case Keyword.get(config, :css_merge_strategy) do
      nil ->
        issues

      strategy when strategy in [:merge, :replace] ->
        issues

      invalid ->
        [
          "Invalid css_merge_strategy: `#{inspect(invalid)}` (must be :merge or :replace)"
          | issues
        ]
    end
  end

  defp validate_custom_css_path(issues, config, config_path) do
    strategy = Keyword.get(config, :css_merge_strategy, :merge)
    custom_path = Keyword.get(config, :custom_css_path)

    cond do
      strategy == :replace && is_nil(custom_path) ->
        ["css_merge_strategy is :replace but custom_css_path is not set" | issues]

      is_binary(custom_path) && custom_path != "" ->
        full_path =
          if Path.type(custom_path) == :absolute do
            custom_path
          else
            # Go from priv/mishka_chelekom to project root
            config_path
            |> Path.dirname()
            |> Path.join("..")
            |> Path.join("..")
            |> Path.join(custom_path)
            |> Path.expand()
          end

        if File.exists?(full_path) do
          issues
        else
          ["Custom CSS file not found: `#{custom_path}`" | issues]
        end

      true ->
        issues
    end
  end

  defp validate_css_overrides(issues, config) do
    case Keyword.get(config, :css_overrides) do
      nil ->
        issues

      overrides when is_map(overrides) ->
        Enum.reduce(overrides, issues, fn
          {key, value}, acc when is_atom(key) and is_binary(value) ->
            acc

          {key, value}, acc ->
            ["CSS override `#{key}` must have string value, got: #{inspect(value)}" | acc]
        end)

      invalid ->
        ["css_overrides must be a map, got: #{inspect(invalid)}" | issues]
    end
  end

  defp validate_list_fields(issues, config) do
    list_fields = [
      :exclude_components,
      :component_colors,
      :component_variants,
      :component_sizes,
      :component_rounded,
      :component_padding,
      :component_space
    ]

    Enum.reduce(list_fields, issues, fn field, acc ->
      case Keyword.get(config, field) do
        nil ->
          acc

        [] ->
          acc

        list when is_list(list) ->
          if Enum.all?(list, &is_binary/1) do
            acc
          else
            invalid = list |> Enum.reject(&is_binary/1) |> Enum.map(&inspect/1) |> Enum.join(", ")
            ["#{field} must contain only strings, invalid values: #{invalid}" | acc]
          end

        invalid ->
          ["#{field} must be a list, got: #{inspect(invalid)}" | acc]
      end
    end)
  end

  defp validate_string_fields(issues, config) do
    string_fields = [:component_prefix, :module_prefix]

    Enum.reduce(string_fields, issues, fn field, acc ->
      case Keyword.get(config, field) do
        nil -> acc
        value when is_binary(value) -> acc
        invalid -> ["#{field} must be a string, got: #{inspect(invalid)}" | acc]
      end
    end)
  end

  defp format_validation_result(config_path, config, []) do
    overrides_count =
      case Keyword.get(config, :css_overrides) do
        nil -> 0
        map when is_map(map) -> map_size(map)
        _ -> 0
      end

    strategy = Keyword.get(config, :css_merge_strategy, :merge)
    component_prefix = Keyword.get(config, :component_prefix)
    module_prefix = Keyword.get(config, :module_prefix)

    filters =
      [
        :component_colors,
        :component_variants,
        :component_sizes,
        :component_rounded,
        :component_padding,
        :component_space
      ]
      |> Enum.map(fn field ->
        case Keyword.get(config, field, []) do
          [] -> nil
          list -> "#{field}: #{length(list)} values"
        end
      end)
      |> Enum.reject(&is_nil/1)

    excluded = Keyword.get(config, :exclude_components, [])

    """
    # Configuration Valid

    **File:** `#{config_path}`
    **Status:** All checks passed

    ---

    ## Summary

    | Setting | Value |
    |---------|-------|
    | CSS Strategy | #{strategy} |
    | CSS Overrides | #{overrides_count} variables |
    | Component Prefix | #{if component_prefix, do: "`#{component_prefix}`", else: "(none)"} |
    | Module Prefix | #{if module_prefix, do: "`#{module_prefix}`", else: "(none)"} |
    | Excluded Components | #{if excluded == [], do: "(none)", else: "#{length(excluded)} components"} |

    #{if filters != [], do: "### Active Filters\n\n#{Enum.map(filters, &"- #{&1}") |> Enum.join("\n")}", else: ""}

    ---

    ## Commands

    ```bash
    # Show full config
    mix mishka.ui.css.config --show

    # Regenerate CSS with overrides
    mix mishka.ui.css.config --regenerate

    # Regenerate components with filters
    mix mishka.ui.gen.components --yes
    ```
    """
  end

  defp format_validation_result(config_path, _config, issues) do
    issue_list =
      issues
      |> Enum.with_index(1)
      |> Enum.map(fn {issue, i} -> "#{i}. #{issue}" end)
      |> Enum.join("\n")

    """
    # Configuration Invalid

    **File:** `#{config_path}`
    **Status:** #{length(issues)} issue(s) found

    ---

    ## Issues

    #{issue_list}

    ---

    ## How to Fix

    Edit `#{config_path}` to correct the issues above.

    ### Example Valid Config

    ```elixir
    config :mishka_chelekom,
      # Lists must contain strings
      component_colors: ["primary", "danger", "success"],

      # Prefixes must be strings
      component_prefix: "mishka_",

      # CSS overrides must be a map with atom keys and string values
      css_overrides: %{
        primary_light: "#007f8c"
      },

      # Strategy must be :merge or :replace
      css_merge_strategy: :merge
    ```
    """
  end

  defp format_parse_error(config_path, reason) do
    """
    # Configuration Parse Error

    **File:** `#{config_path}`
    **Status:** Failed to parse

    ---

    ## Error

    ```
    #{reason}
    ```

    ---

    ## How to Fix

    1. Check for syntax errors in the config file
    2. Ensure all strings are properly quoted
    3. Ensure all maps use `%{}` syntax
    4. Ensure atoms use `:atom` syntax

    ### Reset Config

    To start fresh with a valid config:

    ```bash
    mix mishka.ui.css.config --init --force
    ```

    This will overwrite your config with a valid sample.
    """
  end

  defp format_no_config do
    """
    # No Configuration File

    **Status:** `priv/mishka_chelekom/config.exs` not found

    ---

    ## Create Config File

    ```bash
    # Create sample config
    mix mishka.ui.css.config --init
    ```

    This creates a config file with all available options commented out.

    ---

    ## Alternative

    Generate components with `--global` flag to auto-create config:

    ```bash
    mix mishka.ui.gen.components --import --helpers --global --yes
    ```
    """
  end
end
