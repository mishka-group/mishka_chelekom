defmodule MishkaChelekom.Generators.Core do
  @moduledoc """
  Shared generator plumbing used by the styled (`mix mishka.ui.gen.component(s)`) and
  headless (`mix mishka.ui.gen.headless(.components)`) tasks.

  This is the reusable foundation the mix tasks build on: library `priv/` resolution,
  catalog discovery/validation, component naming, the EEx assign skeleton, generated-file
  tracking and prefix persistence. Each mix task stays a thin front-end over these helpers.

  Larger, more specialized concerns live in sibling modules of the same namespace:
  `MishkaChelekom.Generators.Preflight`, `.Assets`, `.Multi` and `.ImportMacro`.
  """

  alias Igniter.Project.Application, as: IAPP
  alias MishkaChelekom.Config

  @phoenix_min "1.8.0"
  @tailwind_min "4.0.0"

  @banner """
        .-.
       /'v'\\
      (/   \\)
      =="="==
    Mishka.tools
  """

  @doc """
  Returns the absolute path to the library's `priv/` directory.

  Prefers `:code.priv_dir(:mishka_chelekom)` (works for hex deps, path deps, and umbrellas),
  falling back to the legacy `"deps/mishka_chelekom/priv"` string only if the app priv dir
  is unavailable.
  """
  @spec lib_priv_dir() :: String.t()
  def lib_priv_dir do
    case :code.priv_dir(:mishka_chelekom) do
      {:error, _} ->
        "deps/mishka_chelekom/priv"

      dir ->
        dir = to_string(dir)
        if File.dir?(dir), do: dir, else: "deps/mishka_chelekom/priv"
    end
  end

  @doc """
  Joins a sub-path onto the library `priv/` dir.

      iex> MishkaChelekom.Generators.Core.lib_priv("components/button.eex")
  """
  @spec lib_priv(String.t()) :: String.t()
  def lib_priv(sub), do: Path.join(lib_priv_dir(), sub)

  @doc """
  The catalog template directory for a layer.

    * `:styled`   → `priv/components`
    * `:headless` → `priv/headless`
  """
  @spec template_dir(:styled | :headless) :: String.t()
  def template_dir(:styled), do: lib_priv("components")
  def template_dir(:headless), do: lib_priv("headless")

  @doc """
  Validates that a loaded catalog config has the minimal expected shape, returning
  `{:ok, config}` or `{:error, reason}`.
  """
  @spec validate_catalog(term()) :: {:ok, keyword()} | {:error, String.t()}
  def validate_catalog(config) when is_list(config) do
    cond do
      !Keyword.keyword?(config) ->
        {:error, "catalog config must be a keyword list"}

      !is_binary(config[:name]) ->
        {:error, "catalog is missing a string :name"}

      config[:args] != nil and !Keyword.keyword?(config[:args]) ->
        {:error, ":args must be a keyword list of dimension => allowed-values"}

      true ->
        {:ok, config}
    end
  end

  def validate_catalog(_), do: {:error, "catalog config must be a keyword list"}

  @doc """
  Resolves a component's `.eex` template and sibling `.exs` catalog, reads and validates it.

  Returns `{:ok, %{component, path, config}}` (the underscored name, the template path and the
  validated catalog) or a structured error the caller turns into a user-facing message:

    * `{:error, {:not_found, path}}`
    * `{:error, {:bad_catalog, reason, config_path}}`

  For `:styled`, names prefixed `component_`/`preset_`/`template_` resolve against the host
  app's `priv/mishka_chelekom/{components,presets,templates}`; everything else (and all
  `:headless` names) resolves against the library `priv/`.
  """
  @spec fetch_catalog(Igniter.t(), String.t(), :styled | :headless) ::
          {:ok, %{component: String.t(), path: String.t(), config: keyword()}}
          | {:error, {:not_found, String.t()} | {:bad_catalog, String.t(), String.t()}}
  def fetch_catalog(igniter, component, layer) do
    component = component |> String.replace(" ", "") |> Macro.underscore()
    path = catalog_path(igniter, component, layer)
    config_path = Path.rootname(path) <> ".exs"

    case {File.exists?(path), File.exists?(config_path)} do
      {true, true} ->
        config = Elixir.Config.Reader.read!(config_path)[component_atom(component)]

        case validate_catalog(config) do
          {:ok, config} -> {:ok, %{component: component, path: path, config: config}}
          {:error, reason} -> {:error, {:bad_catalog, reason, config_path}}
        end

      _ ->
        {:error, {:not_found, path}}
    end
  end

  defp catalog_path(igniter, component, :styled) do
    cond do
      String.starts_with?(component, "component_") ->
        Path.join(IAPP.priv_dir(igniter, ["mishka_chelekom", "components"]), "#{component}.eex")

      String.starts_with?(component, "preset_") ->
        Path.join(IAPP.priv_dir(igniter, ["mishka_chelekom", "presets"]), "#{component}.eex")

      String.starts_with?(component, "template_") ->
        Path.join(IAPP.priv_dir(igniter, ["mishka_chelekom", "templates"]), "#{component}.eex")

      true ->
        lib_priv("components/#{component}.eex")
    end
  end

  defp catalog_path(_igniter, component, :headless), do: lib_priv("headless/#{component}.eex")

  @doc """
  Every available component name for a layer (sorted, unique basenames of the `.eex` files).

  `:styled` also discovers host-app custom templates under
  `priv/mishka_chelekom/{components,templates,presets}`.
  """
  @spec all_component_names(Igniter.t(), :styled | :headless) :: [String.t()]
  def all_component_names(igniter, :styled) do
    [
      template_dir(:styled),
      IAPP.priv_dir(igniter, ["mishka_chelekom", "components"]),
      IAPP.priv_dir(igniter, ["mishka_chelekom", "templates"]),
      IAPP.priv_dir(igniter, ["mishka_chelekom", "presets"])
    ]
    |> Enum.flat_map(&Path.wildcard(Path.join(&1, "*.eex")))
    |> Enum.map(&Path.basename(&1, ".eex"))
    |> Enum.uniq()
    |> Enum.sort()
  end

  def all_component_names(_igniter, :headless) do
    template_dir(:headless)
    |> Path.join("*.eex")
    |> Path.wildcard()
    |> Enum.map(&Path.basename(&1, ".eex"))
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Builds the EEx assigns shared by both layers: nil-fills every declared catalog arg, then
  merges `:module`, `:web_module`, `:component_prefix` and `:module_prefix_camel`.

  `opts`:

    * `:values` - already-validated arg values to seed (styled); defaults to `[]` (headless)
    * `:component_prefix` - resolved public-function prefix (or `nil`)
    * `:module_prefix` - resolved module-name prefix used to derive `module_prefix_camel`
  """
  @spec eex_assigns(Igniter.t(), module(), keyword(), keyword()) :: keyword()
  def eex_assigns(igniter, component_module, config, opts \\ []) do
    values = Keyword.get(opts, :values, [])

    (config[:args] || [])
    |> Keyword.keys()
    |> Enum.reduce(values, fn key, acc ->
      if Keyword.has_key?(acc, key), do: acc, else: Keyword.put(acc, key, nil)
    end)
    |> Enum.map(fn
      {key, value} when value == [] -> {key, nil}
      {key, value} -> {key, value}
    end)
    |> Keyword.merge(
      module: component_module,
      web_module: Igniter.Libs.Phoenix.web_module(igniter),
      component_prefix: opts[:component_prefix],
      module_prefix_camel: camelize_prefix(opts[:module_prefix])
    )
  end

  defp camelize_prefix(prefix) when is_binary(prefix) and prefix != "",
    do: prefix |> String.trim_trailing("_") |> Macro.camelize()

  defp camelize_prefix(_), do: ""

  @doc """
  Records a generated file in `igniter_exs[:dont_move_files]` so Igniter does not relocate it.
  """
  @spec track_generated_file(Igniter.t(), String.t()) :: Igniter.t()
  def track_generated_file(igniter, location) do
    Igniter.update_assign(igniter, :igniter_exs, [dont_move_files: [location]], fn igniter_exs ->
      Keyword.update(igniter_exs, :dont_move_files, [location], &[location | &1])
    end)
  end

  @doc """
  Persists `--component-prefix`/`--module-prefix` to the user config unless this is a sub
  generation (`--sub`) or saving is disabled (`--no-save`).
  """
  @spec maybe_save_prefixes(Igniter.t(), keyword()) :: Igniter.t()
  def maybe_save_prefixes(igniter, options) do
    if options[:sub] || options[:no_save] do
      igniter
    else
      igniter
      |> save_prefix(options[:component_prefix], &Config.update_component_prefix/2)
      |> save_prefix(options[:module_prefix], &Config.update_module_prefix/2)
    end
  end

  defp save_prefix(igniter, nil, _fun), do: igniter
  defp save_prefix(igniter, prefix, fun), do: fun.(igniter, prefix)

  @doc """
  Creates the sample `priv/mishka_chelekom/config.exs` if it does not exist yet (idempotent).

  Shared by the styled and headless setup so both layers handle the config file the same way.
  """
  @spec ensure_user_config(Igniter.t()) :: Igniter.t()
  def ensure_user_config(igniter) do
    config_path = Path.join(["priv", "mishka_chelekom", "config.exs"])

    if File.exists?(config_path) do
      igniter
    else
      {igniter, path, content} = Config.create_sample_config(igniter)

      igniter
      |> Igniter.create_or_update_file(path, content, fn source ->
        Rewrite.Source.update(source, :content, content)
      end)
      |> Igniter.add_notice("""
      Created a sample configuration file at #{path}

      This configuration file allows you to customize Mishka Chelekom globally:

      Component Control:
      - exclude_components: Exclude specific components from generation
      - component_colors: Limit which color variants are generated
      - component_variants: Limit which variant options are generated
      - component_sizes: Limit which size options are generated
      - component_rounded: Limit which rounded options are generated
      - component_padding: Limit which padding options are generated
      - component_space: Limit which space options are generated
      - component_prefix: Prefix public functions

      CSS Customization:
      - css_overrides: Override specific CSS variables
      - custom_css_path: Use a completely custom CSS file
      - css_merge_strategy: Choose between merging or replacing CSS

      Your customizations will be applied when generating components.
      """)
    end
  end

  @doc """
  Converts a CSV string or list of values into a trimmed list of strings.
  """
  @spec convert_options(nil | String.t() | [String.t()]) :: nil | [String.t()]
  def convert_options(nil), do: nil

  def convert_options(value) when is_binary(value),
    do: String.trim(value) |> String.split(",") |> Enum.map(&String.trim/1)

  def convert_options(value), do: Enum.map(value, &String.trim/1)

  @doc """
  Turns a dotted, lower-case string into a module atom (`"a_b.c" -> :"AB.C"`).
  """
  @spec module_atom(String.t()) :: atom()
  def module_atom(field) do
    field
    |> String.split(".", trim: true)
    |> Enum.map(&Macro.camelize/1)
    |> Enum.join(".")
    |> String.to_atom()
  end

  @doc """
  Like `module_atom/1` but keeps only the last segment (`"a.b.c" -> :C`).
  """
  @spec module_atom(String.t(), :last) :: atom()
  def module_atom(field, :last) do
    field
    |> String.split(".", trim: true)
    |> List.last()
    |> Macro.camelize()
    |> String.to_atom()
  end

  @doc """
  Turns a component name string into an atom (used to index a catalog `.exs`).
  """
  @spec component_atom(String.t()) :: atom()
  def component_atom(component_str), do: String.to_atom(component_str)

  @doc """
  Prints the Mishka owl banner in `color`, optionally with a `subtitle` line beneath it.
  """
  @spec banner(String.t(), String.t() | nil) :: :ok
  def banner(color, subtitle \\ nil) do
    art = String.trim_trailing(@banner)
    art = if subtitle, do: art <> "\n" <> center_subtitle(art, subtitle), else: art
    IO.puts(color <> art <> IO.ANSI.reset())
  end

  defp center_subtitle(art, subtitle) do
    width =
      art
      |> String.split("\n")
      |> Enum.map(&String.length/1)
      |> Enum.max()

    pad = max(0, div(width - String.length(subtitle), 2))
    String.duplicate(" ", pad) <> subtitle
  end

  # ---- Dependency preflight -----------------------------------------------------------

  @doc """
  Verifies Phoenix >= #{@phoenix_min} and Tailwind >= #{@tailwind_min}, adding an issue per
  problem found. Returns the (possibly annotated) igniter.
  """
  @spec check_dependencies(Igniter.t()) :: Igniter.t()
  def check_dependencies(igniter) do
    case Igniter.Project.Deps.get_dep(igniter, :phoenix) do
      {:ok, nil} ->
        Igniter.add_issue(igniter, """
        Phoenix is not installed in your project.
        Mishka Chelekom requires Phoenix #{@phoenix_min} or higher.
        Please add {:phoenix, "~> 1.8"} to your dependencies.
        """)

      {:ok, dep} ->
        version_req =
          case {is_binary(dep), Regex.run(~r/"([^"]+)"/, dep)} do
            {true, [_, version]} -> version
            _ -> nil
          end

        if version_req && !valid_version?(version_req, @phoenix_min, fn _ -> true end) do
          Igniter.add_issue(igniter, """
          Phoenix version requirement #{inspect(version_req)} is not compatible.
          Mishka Chelekom requires Phoenix #{@phoenix_min} or higher.
          Please update your Phoenix dependency to "~> 1.8" or higher.
          """)
        else
          igniter
        end

      {:error, _} ->
        igniter
    end
    |> check_tailwind()
  end

  defp check_tailwind(igniter) do
    if Igniter.Project.Config.configures_key?(igniter, "config.exs", :tailwind, :version) do
      version =
        igniter
        |> Igniter.Project.Application.config_path()
        |> then(&Path.join(Path.dirname(&1), "config.exs"))
        |> then(&Elixir.Config.Reader.read!(&1, env: :dev)[:tailwind])
        |> Keyword.get(:version)

      if version && !valid_version?(version, @tailwind_min, &tailwind_major_ok?/1) do
        Igniter.add_issue(igniter, """
        Tailwind version #{inspect(version)} is not compatible.
        Mishka Chelekom requires Tailwind CSS 4.0 or higher.
        Please update your Tailwind configuration to use version "4.0.0" or higher.
        """)
      else
        igniter
      end
    else
      Igniter.add_issue(igniter, """
      Tailwind version is not specified in your configuration.
      Mishka Chelekom requires Tailwind CSS 4.0 or higher.
      Please add version to your Tailwind configuration:

      config :tailwind, version: "4.0.0"
      """)
    end
  end

  # Strips requirement operators (`~> >= …`) and any pre-release suffix, then compares against
  # `min`. When the version can't be parsed, `on_unparseable` decides (Phoenix assumes a git
  # dep is fine; Tailwind falls back to a major-version check).
  defp valid_version?(version, min, on_unparseable) when is_binary(version) do
    base =
      version
      |> String.replace(~r/^[~>=< ]+/, "")
      |> String.split("-")
      |> List.first()
      |> String.trim()

    case Version.parse(base) do
      {:ok, parsed} -> Version.compare(parsed, Version.parse!(min)) != :lt
      :error -> on_unparseable.(version)
    end
  end

  defp valid_version?(_version, _min, _on_unparseable), do: true

  defp tailwind_major_ok?(version),
    do: String.starts_with?(version, ["4.", "5.", "6.", "7.", "8.", "9."])

  # ---- Fan-out for the plural tasks ---------------------------------------------------

  @doc """
  Resolves the component list to generate for a plural task.

  An empty request (or one containing `"all"`) expands to every component of `layer`; otherwise
  the requested names are used. Names in the user config `:exclude_components` or `cli_exclude`
  are removed.
  """
  @spec resolve_components(
          Igniter.t(),
          String.t() | nil,
          :styled | :headless,
          map(),
          [String.t()] | nil
        ) :: [String.t()]
  def resolve_components(igniter, requested_csv, layer, user_config, cli_exclude) do
    requested = String.split(requested_csv || "", ",", trim: true)

    list =
      if requested == [] or "all" in requested,
        do: all_component_names(igniter, layer),
        else: requested

    excluded = Enum.uniq((user_config[:exclude_components] || []) ++ (cli_exclude || []))
    Enum.reject(list, &(&1 in excluded))
  end

  @doc """
  Composes `task` once per component in `list`, prepending each name to `extra_args`.
  """
  @spec fan_out(Igniter.t(), String.t(), [String.t()], [String.t()]) :: Igniter.t()
  def fan_out(igniter, task, list, extra_args) do
    Enum.reduce(list, igniter, fn name, acc ->
      Igniter.compose_task(acc, task, [name | extra_args])
    end)
  end

  @doc """
  Appends `[flag, value]` to `args` when `value` is present (not `nil`/empty).
  """
  @spec append_arg([String.t()], String.t(), String.t() | nil) :: [String.t()]
  def append_arg(args, _flag, nil), do: args
  def append_arg(args, _flag, ""), do: args
  def append_arg(args, flag, value), do: args ++ [flag, value]
end
