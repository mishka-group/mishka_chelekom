defmodule Mix.Tasks.Mishka.Ui.Gen.Component do
  use Igniter.Mix.Task
  alias Igniter.Project.Application, as: IAPP
  alias IgniterJs.Parsers.Javascript.Parser, as: JsParser
  alias IgniterJs.Parsers.Javascript.Formatter, as: JsFormatter
  alias MishkaChelekom.SimpleCSSUtilities
  alias MishkaChelekom.Config

  @example "mix mishka.ui.gen.component component --example arg"
  @shortdoc "A Mix Task for generating and configuring Phoenix components"
  @moduledoc """
  #{@shortdoc}

  This script is used in the development environment and allows you to easily add all Mishka
  components to the components directory in your Phoenix project.

  It should be noted that you can create any component with limited arguments.
  For example, put only a certain color in the button and do not put other codes in the component.

  For this reason, the main goal is to build the component and its dependencies, and approval at every stage.

  > With this method, you no longer need to add anything you don't need to your project
  > and minimize dependencies and attacks on dependencies and project maintenance.

  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * `--variant` or `-v` - Specifies component variant
  * `--color` or `-c` - Specifies component color
  * `--size` or `-s` - Specifies component size
  * `--padding` or `-p` - Specifies component padding
  * `--space` or `-sp` - Specifies component space
  * `--type` or `-t` - Specifies component type
  * `--rounded` or `-r` - Specifies component type
  * `--no-sub-config` - Creates dependent components with default settings
  * `--module` or `-m` - Specifies a custom name for the component module
  * `--sub` - Specifies this task is a sub task
  * `--no-deps` - Specifies this task is created without sub task
  * `--yes` - Makes directly without questions
  * `--module-prefix` - Prefix for module names (e.g., `mishka_` makes Chat become MishkaChat)
  * `--no-save` - Use prefixes without saving them to config file
  """

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      # dependencies to add
      adds_deps: [],
      # dependencies to add and call their associated installers, if they exist
      installs: [],
      # An example invocation
      example: @example,
      # Accept additional arguments that are not in your schema
      # Does not guarantee that, when composed, the only options you get are the ones you define
      extra_args?: false,
      # A list of environments that this should be installed in, only relevant if this is an installer.
      only: nil,
      # a list of positional arguments, i.e `[:file]`
      positional: [:component],
      # Other tasks your task composes using `Igniter.compose_task`, passing in the CLI argv
      # This ensures your option schema includes options from nested tasks
      composes: [],
      # `OptionParser` schema
      schema: [
        variant: :csv,
        color: :csv,
        size: :csv,
        module: :string,
        padding: :csv,
        space: :csv,
        type: :csv,
        rounded: :csv,
        component_prefix: :string,
        module_prefix: :string,
        sub: :boolean,
        no_deps: :boolean,
        no_sub_config: :boolean,
        no_save: :boolean
      ],
      # CLI aliases
      aliases: [
        v: :variant,
        c: :color,
        s: :size,
        m: :module,
        p: :padding,
        sp: :space,
        t: :type,
        r: :rounded
      ]
    }
  end

  def igniter(igniter) do
    # extract positional arguments according to `positional` above
    %Igniter.Mix.Task.Args{positional: %{component: component}} = igniter.args

    options = igniter.args.options

    if !options[:sub] and Mix.env() != :test do
      msg =
        """
              .-.
             /'v'\\
            (/   \\)
            =="="==
          Mishka.tools
        """

      IO.puts(IO.ANSI.green() <> String.trim_trailing(msg) <> IO.ANSI.reset())
    end

    user_config = Config.load_user_config(igniter)

    igniter
    |> Igniter.assign(%{mishka_user_config: user_config})
    |> check_dependencies_versions()
    |> get_component_template(component)
    |> converted_components_path(Keyword.get(options, :module), options)
    |> update_eex_assign(options)
    |> create_or_update_component()
    |> create_or_update_scripts()
    |> setup_css_files(options)
    |> maybe_update_config_prefix(options)
  end

  def supports_umbrella?(), do: false

  @doc false
  def check_dependencies_versions(igniter) do
    case Igniter.Project.Deps.get_dep(igniter, :phoenix) do
      {:ok, nil} ->
        igniter
        |> Igniter.add_issue("""
        Phoenix is not installed in your project.
        Mishka Chelekom requires Phoenix 1.8.0 or higher.
        Please add {:phoenix, "~> 1.8"} to your dependencies.
        """)

      {:ok, dep} ->
        version_req =
          case {is_binary(dep), Regex.run(~r/"([^"]+)"/, dep)} do
            {true, [_, version]} -> version
            _ -> nil
          end

        if version_req && !valid_phoenix_version?(version_req) do
          igniter
          |> Igniter.add_issue("""
          Phoenix version requirement #{inspect(version_req)} is not compatible.
          Mishka Chelekom requires Phoenix 1.8.0 or higher.
          Please update your Phoenix dependency to "~> 1.8" or higher.
          """)
        else
          igniter
        end

      {:error, _} ->
        igniter
    end
    |> check_tailwind_version()
  end

  defp check_tailwind_version(igniter) do
    cond do
      !Igniter.Project.Config.configures_key?(igniter, "config.exs", :tailwind, :version) ->
        igniter
        |> Igniter.add_issue("""
        Tailwind version is not specified in your configuration.
        Mishka Chelekom requires Tailwind CSS 4.0 or higher.
        Please add version to your Tailwind configuration:

        config :tailwind, version: "4.0.0"
        """)

      true ->
        version =
          igniter
          |> Igniter.Project.Application.config_path()
          |> then(&Path.join(Path.dirname(&1), "config.exs"))
          |> then(&Elixir.Config.Reader.read!(&1, env: :dev)[:tailwind])
          |> Keyword.get(:version)

        if version && !valid_tailwind_version?(version) do
          igniter
          |> Igniter.add_issue("""
          Tailwind version #{inspect(version)} is not compatible.
          Mishka Chelekom requires Tailwind CSS 4.0 or higher.
          Please update your Tailwind configuration to use version "4.0.0" or higher.
          """)
        else
          igniter
        end
    end
  end

  defp valid_phoenix_version?(requirement) when is_binary(requirement) do
    base_version =
      requirement
      |> String.replace(~r/^[~>>=<= ]+/, "")
      |> String.trim()

    case Version.parse(base_version) do
      {:ok, version} ->
        case Version.compare(version, Version.parse!("1.8.0")) do
          :lt -> false
          _ -> true
        end

      :error ->
        # If we can't parse, assume it's okay (could be git dependency, etc)
        true
    end
  end

  defp valid_phoenix_version?(_), do: true

  defp valid_tailwind_version?(version) when is_binary(version) do
    # Remove any alpha/beta/rc suffixes for comparison
    base_version = version |> String.split("-") |> List.first() |> String.trim()

    case Version.parse(base_version) do
      {:ok, version} ->
        # Check if the version is >= 4.0.0
        case Version.compare(version, Version.parse!("4.0.0")) do
          :lt -> false
          _ -> true
        end

      :error ->
        # If we can't parse, check if it starts with 4 or higher
        String.starts_with?(version, ["4.", "5.", "6.", "7.", "8.", "9."])
    end
  end

  defp valid_tailwind_version?(_), do: false

  @doc false
  def get_component_template(igniter, component) do
    component = String.replace(component, " ", "") |> Macro.underscore()

    template_path =
      cond do
        String.starts_with?(component, "component_") ->
          Path.join(IAPP.priv_dir(igniter, ["mishka_chelekom", "components"]), "#{component}.eex")

        String.starts_with?(component, "preset_") ->
          Path.join(IAPP.priv_dir(igniter, ["mishka_chelekom", "presets"]), "#{component}.eex")

        String.starts_with?(component, "template_") ->
          Path.join(IAPP.priv_dir(igniter, ["mishka_chelekom", "templates"]), "#{component}.eex")

        true ->
          "deps/mishka_chelekom/priv/components/#{component}.eex"
      end

    template_config_path = Path.rootname(template_path) <> ".exs"

    {File.exists?(template_path), File.exists?(template_config_path)}
    |> case do
      {true, true} ->
        %{
          igniter: igniter,
          component: component,
          path: template_path,
          config: Elixir.Config.Reader.read!(template_config_path)[component_to_atom(component)]
        }

      _ ->
        msg = """
        The component you requested does not exist or you wrote its name incorrectly.
        Please read the site documentation.
        """

        {:error, :no_component, msg, igniter}
    end
  end

  defp converted_components_path({:error, _, _, _igniter} = error, _, _), do: error

  defp converted_components_path(template, custom_module, options) do
    # Reset the assigns to prevent creating .igniter.exs config file to add all the paths
    web_module = "#{IAPP.app_name(template.igniter)}" <> "_web"

    Path.join("lib", web_module <> "/components")
    |> File.dir?()
    |> case do
      false ->
        re_dir(template, custom_module, web_module)

      true ->
        # Get module_prefix from CLI options or user config
        user_config = template.igniter.assigns[:mishka_user_config] || %{}
        module_prefix = Keyword.get(options, :module_prefix) || user_config[:module_prefix]

        # Apply module prefix to component name for file and module
        {prefixed_component, prefixed_module_part} =
          if module_prefix && module_prefix != "" do
            prefixed = "#{module_prefix}#{template.component}"
            {prefixed, prefixed}
          else
            {template.component, template.component}
          end

        component =
          atom_to_module(
            custom_module ||
              web_module <> ".components.#{component_to_atom(prefixed_module_part)}"
          )

        # Reset the assigns to prevent creating .igniter.exs config file to add all the paths
        proper_location = "lib/#{web_module}/components/#{prefixed_component}.ex"

        new_igniter =
          template.igniter
          |> Map.update!(:assigns, fn assigns ->
            assigns
            |> Map.put_new(:igniter_exs, [])
            |> Map.update!(:igniter_exs, fn igniter_exs ->
              Keyword.update(
                igniter_exs,
                :dont_move_files,
                [proper_location],
                &[proper_location | &1]
              )
            end)
          end)

        {new_igniter, proper_location, [module: component], template.path, template.config}
    end
  end

  defp update_eex_assign({:error, _, _, _igniter} = error, _), do: error

  defp update_eex_assign(
         {igniter, proper_location, assign, template_path, template_config},
         options
       ) do
    # Get color filtering from config if not specified in CLI
    options = maybe_apply_color_filter(igniter, options, template_config)

    {user_bad_args, new_assign} =
      options
      |> Keyword.take(Keyword.keys(template_config[:args]))
      |> Keyword.merge(assign)
      |> Enum.reduce({[], []}, fn {key, value}, {bad_acc, data_acc} ->
        case template_config[:args][key] do
          args when is_list(args) ->
            splited_args = convert_options(value)

            if !Enum.all?(splited_args, &(&1 in args)) do
              {[{key, args} | bad_acc], data_acc}
            else
              {bad_acc, [{key, splited_args} | data_acc]}
            end

          _ ->
            {bad_acc, [{key, value} | data_acc]}
        end
      end)

    if length(user_bad_args) > 0 do
      msg = """
      Unfortunately, the arguments you sent were incorrect. You can only send the following options for
      each of the following arguments

      #{Enum.map(user_bad_args, fn {key, value} -> "* #{String.capitalize("#{key}")}: #{Enum.join(value, " - ")}\n" end)}
      """

      {:error, :bad_args, msg, igniter}
    else
      # we put nil assigns keys to prevent the does not exist warning
      # Get module_prefix from CLI or user config
      user_config = igniter.assigns[:mishka_user_config] || %{}
      module_prefix = Keyword.get(options, :module_prefix) || user_config[:module_prefix]

      # Compute camelized module prefix for use in import statements
      module_prefix_camel =
        if module_prefix && module_prefix != "" do
          module_prefix |> String.trim_trailing("_") |> Macro.camelize()
        else
          ""
        end

      updated_new_assign =
        Keyword.keys(template_config[:args])
        |> Enum.reduce(new_assign, fn key, acc ->
          if Keyword.has_key?(acc, key), do: acc, else: Keyword.put(acc, key, nil)
        end)
        |> Enum.map(fn
          {key, value} when value == [] -> {key, nil}
          {key, value} -> {key, value}
        end)
        |> Keyword.merge(
          web_module: Igniter.Libs.Phoenix.web_module(igniter),
          component_prefix: Keyword.get(options, :component_prefix),
          module_prefix_camel: module_prefix_camel
        )

      {igniter, template_path, template_config, proper_location, updated_new_assign, options}
    end
  end

  defp re_dir(template, _custom_module, web_module) do
    msg = """
    Note:
    You should have the path to the components folder in your Phoenix Framework web directory.
    Otherwise, the operation will stop.

    Note:
    If you believe your project path is correct or you are certain that the path belongs to a
    project created with Phoenix, check the following path. It is possible that your naming convention does
    not align with Elixir's naming style.

    Is your web path (#{inspect(web_module)})!? but we found this (#{inspect(IAPP.app_name(template.igniter)) <> "_web"})!!
    """

    {:error, :no_dir, msg, template.igniter}
  end

  defp create_or_update_component({:error, _, msg, igniter}), do: Igniter.add_issue(igniter, msg)

  defp create_or_update_component(
         {igniter, template_path, template_config, proper_location, assign, options}
       ) do
    igniter =
      igniter
      |> Igniter.copy_template(template_path, proper_location, assign, on_exists: :overwrite)

    if is_nil(options[:no_deps]) do
      igniter
      |> optional_components(template_config)
      |> necessary_components(template_path, template_config, proper_location, options, assign)
    else
      {igniter, template_config}
    end
  end

  defp optional_components(igniter, template_config) do
    if Keyword.get(template_config, :optional, []) != [] and Igniter.changed?(igniter) do
      igniter
      |> Igniter.add_notice("""
        Some other optional components are suggested for this component. You can create them separately.
        Note that if you use custom module names and their names are different each time,
        you may need to manually change the components.

        Components: #{Enum.join(template_config[:optional], " - ")}

        You can run:
            #{Enum.map(template_config[:optional], &"\n   * mix mishka.ui.gen.component #{&1}\n")}
      """)
    else
      igniter
    end
  end

  defp necessary_components(
         igniter,
         template_path,
         template_config,
         proper_location,
         options,
         assign
       ) do
    igniter =
      if Keyword.get(template_config, :necessary, []) != [] and Igniter.changed?(igniter) do
        if template_config[:necessary] != [] and !options[:sub] and !options[:yes] and
             !options[:no_sub_config] and Mix.env() != :test do
          IO.puts("#{IO.ANSI.bright() <> "Note:\n" <> IO.ANSI.reset()}")

          msg = """
          This component is dependent on other components, so it is necessary to build other
          items along with this component.

          Note: If you have used custom names for your dependent modules, this script will not be able to find them,
          so it will think that they have not been created.

          Components: #{Enum.join(template_config[:necessary], " - ")}
          """

          if Mix.env() != :test do
            Mix.Shell.IO.info(IO.ANSI.cyan() <> String.trim_trailing(msg) <> IO.ANSI.reset())
          end

          msg =
            "\nNote: \nIf approved, dependent components will be created without restrictions and you can change them manually."

          if Mix.env() != :test do
            IO.puts("#{IO.ANSI.blue() <> msg <> IO.ANSI.reset()}")

            IO.puts(
              "#{IO.ANSI.cyan() <> "\nYou can run before generating this component:" <> IO.ANSI.reset()}"
            )
          end
        end

        if template_config[:necessary] != [] and !options[:yes] and !options[:no_sub_config] and
             Mix.env() != :test do
          IO.puts(
            "#{IO.ANSI.yellow() <> "#{Enum.map(template_config[:necessary], &"\n   * mix mishka.ui.gen.component #{&1}\n")}" <> IO.ANSI.reset()}"
          )
        end

        if template_config[:necessary] != [] and !options[:sub] and !options[:yes] and
             !options[:no_sub_config] and Mix.env() != :test do
          Mix.Shell.IO.error("""

          In this section you can set your custom args for each dependent component.
          If you press the enter key, you have selected the default settings
          """)
        end

        Enum.reduce(template_config[:necessary], {[], igniter}, fn item, {module_coms, acc} ->
          commands =
            if !options[:yes] and !options[:no_sub_config] and Mix.env() != :test do
              Mix.Shell.IO.prompt("* Component #{String.capitalize(item)}: Enter your args:")
              |> String.trim()
              |> String.split(" ", trim: true)
            else
              []
            end

          args =
            cond do
              !is_nil(options[:yes]) ->
                [item, "--sub", "--no-sub-config", "--yes"]

              !is_nil(options[:no_sub_config]) ->
                [item, "--sub", "--no-sub-config"]

              commands == [] ->
                [item, "--sub"]

              true ->
                [item, "--sub"] ++ commands
            end

          templ_options = igniter.args.options

          component_acc =
            if !is_nil(templ_options[:module]) do
              [{item, atom_to_module(templ_options[:module])}]
            else
              []
            end

          {module_coms ++ component_acc,
           Igniter.compose_task(acc, "mishka.ui.gen.component", args)}
        end)
        |> case do
          {[], igniter} ->
            igniter

          {custom_modules, igniter} ->
            new_assign =
              Enum.map(custom_modules, fn {k, v} -> {String.to_atom(k), v} end)
              |> then(&Keyword.merge(assign, &1))

            igniter
            |> Igniter.copy_template(template_path, proper_location, new_assign,
              on_exists: :overwrite
            )
        end
      else
        igniter
      end

    {igniter, template_config}
  end

  def create_or_update_scripts({igniter, template_config}) do
    if Keyword.get(template_config, :scripts, []) != [] do
      igniter
      |> check_and_update_package_json(template_config)
      |> check_and_update_js_files(template_config)
    else
      igniter
    end
  end

  def create_or_update_scripts(%Igniter{} = igniter), do: igniter

  @doc false
  def atom_to_module(field) do
    field
    |> String.split(".", trim: true)
    |> Enum.map(&Macro.camelize/1)
    |> Enum.join(".")
    |> String.to_atom()
  end

  @doc false
  def atom_to_module(field, :last) do
    field
    |> String.split(".", trim: true)
    |> List.last()
    |> Macro.camelize()
    |> String.to_atom()
  end

  def component_to_atom(component_str) do
    component_str
    |> String.to_atom()
  end

  defp check_and_update_package_json(igniter, _) do
    # TODO: for now we have no plan for it, it needs some way to handle npm, \
    # bun or etc and create init files like
    # TODO: package.json. why we need this? for example, add DOMPurify \
    # to sanitizer client side input or adding js project
    igniter
  end

  defp check_and_update_js_files(igniter, template_config) do
    files = Keyword.get(template_config, :scripts) |> Enum.filter(&(&1.type == "file"))

    if files != [] do
      igniter =
        Enum.reduce(files, igniter, fn item, acc ->
          core_path =
            "deps/mishka_chelekom/priv/assets/js/#{item.file}"

          mishka_user_priv_path =
            Path.join(
              IAPP.priv_dir(igniter, ["mishka_chelekom", "javascripts"]),
              "#{item.file}"
            )

          # Priority is given to Core assets.
          content =
            cond do
              File.exists?(core_path) -> File.read!(core_path)
              File.exists?(mishka_user_priv_path) -> File.read!(mishka_user_priv_path)
              true -> nil
            end

          if !is_nil(content) do
            caller_js =
              case File.read("assets/vendor/mishka_components.js") do
                {:ok, content} ->
                  content

                _ ->
                  File.read!("deps/mishka_chelekom/priv/assets/js/mishka_components.js")
              end

            acc
            |> Igniter.create_or_update_file("assets/vendor/#{item.file}", content, fn source ->
              Rewrite.Source.update(source, :content, content)
            end)
            |> Igniter.create_or_update_file(
              "assets/vendor/mishka_components.js",
              caller_js,
              fn source ->
                original_content = Rewrite.Source.get(source, :content)
                Rewrite.Source.update(source, :content, original_content)
              end
            )
            |> Igniter.create_or_update_file(
              "assets/vendor/mishka_components.js",
              caller_js,
              fn source ->
                with original_content <- Rewrite.Source.get(source, :content),
                     {:ok, _, imported} <-
                       JsParser.insert_imports(original_content, "#{item.imports}"),
                     {:ok, _, extended} <-
                       JsParser.extend_var_object_by_object_names(
                         imported,
                         "Components",
                         "#{item.module}"
                       ),
                     {:ok, _, formatted} <- JsFormatter.format(extended) do
                  Rewrite.Source.update(source, :content, formatted)
                else
                  {:error, _, error} ->
                    msg = """
                    Note:
                    When you see this error, it means there is a syntax issue in the part you are trying to import.
                    Please review the relevant file again.

                    Full Erros: "#{inspect(error)}"
                    """

                    Rewrite.Source.add_issue(source, msg)
                end
              end
            )
          else
            acc
            |> Igniter.add_issue("The requested JavaScript file does not exist.")
          end
        end)

      app_js = "assets/js/app.js"

      case File.read(app_js) do
        {:ok, content} ->
          igniter
          |> Igniter.create_or_update_file(app_js, content, fn source ->
            imports = """
            import MishkaComponents from "../vendor/mishka_components.js";
            """

            with original_content <- Rewrite.Source.get(source, :content),
                 {:ok, _, imported} <- JsParser.insert_imports(original_content, imports),
                 {:ok, _, output} <- JsParser.extend_hook_object(imported, "...MishkaComponents"),
                 {:ok, _, formatted} <- JsFormatter.format(output) do
              Rewrite.Source.update(source, :content, formatted)
            else
              {:error, _, error} ->
                Igniter.add_issue(igniter, "#{inspect(error)}")
            end
          end)

        _ ->
          msg = """
          Note:
          Unfortunately, we couldn't find the assets/js/app.js file in your project path.
          """

          Igniter.add_issue(igniter, msg)
      end
    else
      igniter
    end
  end

  # Apply filters for all component attributes from config
  defp maybe_apply_color_filter(igniter, options, template_config) do
    apply_component_filters(igniter, options, template_config)
  end

  defp apply_component_filters(igniter, options, template_config) do
    config = igniter.assigns.mishka_user_config

    # Define attribute mappings from config keys to option keys
    filter_mappings = [
      {:component_colors, :color},
      {:component_variants, :variant},
      {:component_sizes, :size},
      {:component_rounded, :rounded},
      {:component_padding, :padding},
      {:component_space, :space}
    ]

    options =
      Enum.reduce(filter_mappings, options, fn {config_key, option_key}, acc_options ->
        apply_single_filter(config, acc_options, template_config, config_key, option_key)
      end)

    # Handle component_prefix separately - it's a string, not a filterable list
    apply_component_prefix(config, options)
  end

  defp apply_component_prefix(config, options) do
    case Keyword.get(options, :component_prefix) do
      nil ->
        case config[:component_prefix] do
          prefix when is_binary(prefix) and prefix != "" ->
            Keyword.put(options, :component_prefix, prefix)

          _ ->
            Keyword.put(options, :component_prefix, nil)
        end

      _cli_value ->
        options
    end
  end

  defp apply_single_filter(config, options, template_config, config_key, option_key) do
    # Skip if option already specified in CLI
    if Keyword.get(options, option_key) != [] do
      options
    else
      configured_values = config[config_key] || []
      available_values = template_config[:args][option_key] || []

      case {configured_values, available_values} do
        {[], _} ->
          # No config values specified, use all
          options

        {_, []} ->
          # Component doesn't have this option
          options

        {config_values, component_values} ->
          # Filter to valid values for this component
          valid_values = Enum.filter(config_values, &(&1 in component_values))

          if valid_values != [] do
            Keyword.put(options, option_key, valid_values)
          else
            options
          end
      end
    end
  end

  def convert_options(nil), do: nil

  def convert_options(value) when is_binary(value),
    do: String.trim(value) |> String.split(",") |> Enum.map(&String.trim/1)

  def convert_options(value), do: Enum.map(value, &String.trim/1)

  @doc """
  Sets up CSS files for Mishka components.
  Can be called externally when generating multiple components.
  """
  def setup_css_files(igniter, options \\ []) do
    if !options[:sub] do
      vendor_css_path = "assets/vendor/mishka_chelekom.css"
      app_css_path = "assets/css/app.css"

      igniter
      |> create_mishka_css(vendor_css_path)
      |> import_and_setup_theme(app_css_path)
    else
      igniter
    end
  end

  @doc false
  def create_mishka_css(igniter, vendor_css_path) do
    # Generate CSS content with user overrides if they exist
    mishka_css_content = Config.generate_css_content(igniter)

    igniter
    |> Igniter.create_or_update_file(vendor_css_path, mishka_css_content, fn source ->
      Rewrite.Source.update(source, :content, mishka_css_content)
    end)
    |> maybe_create_sample_config()
  end

  @doc false
  def import_and_setup_theme(igniter, app_css_path) do
    # Always use the original theme.css without modifications
    theme_path = "deps/mishka_chelekom/priv/assets/css/theme.css"

    with {:ok, css_content} <- File.read(app_css_path),
         {:ok, theme_content} <- SimpleCSSUtilities.read_theme_content(theme_path),
         {:ok, updated_content} <-
           SimpleCSSUtilities.add_import_and_theme(
             css_content,
             "../vendor/mishka_chelekom.css",
             theme_content
           ) do
      igniter
      |> Igniter.create_or_update_file(app_css_path, updated_content, fn source ->
        Rewrite.Source.update(source, :content, updated_content)
      end)
    else
      {:error, :enoent} ->
        msg = """
        The app.css file does not exist at #{app_css_path}.
        Please ensure your Phoenix application has been properly set up with assets.
        """

        igniter
        |> Igniter.add_issue(msg)

      {:error, reason} ->
        igniter
        |> Igniter.add_issue("Error processing CSS file: #{inspect(reason)}")
    end
  end

  defp maybe_create_sample_config(igniter) do
    # Use the actual project's priv directory, not the build directory
    config_path = Path.join(["priv", "mishka_chelekom", "config.exs"])

    if !File.exists?(config_path) do
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
    else
      igniter
    end
  end

  defp maybe_update_config_prefix(igniter, options) do
    igniter
    |> maybe_update_component_prefix(options)
    |> maybe_update_module_prefix(options)
  end

  defp maybe_update_component_prefix(igniter, options) do
    case {Keyword.get(options, :component_prefix), Keyword.get(options, :sub),
          Keyword.get(options, :no_save)} do
      {nil, _, _} -> igniter
      {_prefix, true, _} -> igniter
      {_prefix, _, true} -> igniter
      {prefix, _, _} -> Config.update_component_prefix(igniter, prefix)
    end
  end

  defp maybe_update_module_prefix(igniter, options) do
    case {Keyword.get(options, :module_prefix), Keyword.get(options, :sub),
          Keyword.get(options, :no_save)} do
      {nil, _, _} -> igniter
      {_prefix, true, _} -> igniter
      {_prefix, _, true} -> igniter
      {prefix, _, _} -> Config.update_module_prefix(igniter, prefix)
    end
  end
end
