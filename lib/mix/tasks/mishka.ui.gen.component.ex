defmodule Mix.Tasks.Mishka.Ui.Gen.Component do
  use Igniter.Mix.Task
  alias Igniter.Project.Application, as: IAPP
  alias MishkaChelekom.Config
  alias MishkaChelekom.Generators.{Assets, Core}

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
  * `--rounded` or `-r` - Specifies component rounded
  * `--module` or `-m` - Specifies a custom name for the component module
  * `--component-prefix` - Prefix for the public function name
  * `--module-prefix` - Prefix for module names (e.g., `mishka_` makes Chat become MishkaChat)
  * `--no-sub-config` - Creates dependent components with default settings
  * `--sub` - Specifies this task is a sub task
  * `--no-deps` - Specifies this task is created without sub task
  * `--no-save` - Use prefixes without saving them to config file
  * `--no-npm` - Write everything but skip installing the component's npm packages
  * `--yes` - Makes directly without questions
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
      group: :mishka_chelekom,
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
        no_save: :boolean,
        no_npm: :boolean
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

  def supports_umbrella?(), do: false

  def igniter(igniter) do
    Application.ensure_all_started(:owl)
    %Igniter.Mix.Task.Args{positional: %{component: component}, options: options} = igniter.args

    print_banner(options)

    tty? = IO.ANSI.enabled?()
    spin? = !options[:sub] and Mix.env() != :test and tty?
    if spin?, do: Owl.Spinner.start(id: :my_spinner, labels: [processing: "Please wait..."])

    final =
      igniter
      |> Igniter.assign(:mishka_user_config, Config.load_user_config(igniter))
      |> Core.check_dependencies()
      |> resolve_template(component)
      |> compute_location()
      |> build_eex_assigns()
      |> write_component()
      |> wire_scripts()
      |> maybe_setup_css()
      |> maybe_save_prefixes()

    if spin? do
      if Map.get(final, :issues, []) == [],
        do: Owl.Spinner.stop(id: :my_spinner, resolution: :ok, label: "Done"),
        else: Owl.Spinner.stop(id: :my_spinner, resolution: :error, label: "Error")
    end

    final
  end

  defp print_banner(options) do
    if !options[:sub] and Mix.env() != :test, do: Core.banner(IO.ANSI.green(), "Component")
    :ok
  end

  defp resolve_template(igniter, component) do
    case Core.fetch_catalog(igniter, component, :styled) do
      {:ok, template} ->
        igniter
        |> Igniter.assign(:component_name, template.component)
        |> Igniter.assign(:template_path, template.path)
        |> Igniter.assign(:template_config, template.config)

      {:error, {:not_found, _path}} ->
        Igniter.add_issue(igniter, """
        The component you requested does not exist or you wrote its name incorrectly.
        Please read the site documentation.
        """)

      {:error, {:bad_catalog, reason, config_path}} ->
        Igniter.add_issue(igniter, """
        The catalog metadata for component #{inspect(component)} is invalid: #{reason}.
        Please check #{config_path}.
        """)
    end
  end

  defp compute_location(%{assigns: %{component_name: _}} = igniter) do
    options = igniter.args.options
    component = igniter.assigns.component_name
    custom_module = options[:module]
    web_module = "#{IAPP.app_name(igniter)}" <> "_web"

    if File.dir?(Path.join("lib", web_module <> "/components")) do
      user_config = igniter.assigns[:mishka_user_config] || %{}
      module_prefix = options[:module_prefix] || user_config[:module_prefix]

      {prefixed_component, prefixed_module_part} =
        if module_prefix && module_prefix != "" do
          prefixed = "#{module_prefix}#{component}"
          {prefixed, prefixed}
        else
          {component, component}
        end

      component_module =
        Core.module_atom(
          custom_module ||
            web_module <> ".components.#{Core.component_atom(prefixed_module_part)}"
        )

      proper_location = "lib/#{web_module}/components/#{prefixed_component}.ex"

      igniter
      |> Core.track_generated_file(proper_location)
      |> Igniter.assign(:component_module, component_module)
      |> Igniter.assign(:proper_location, proper_location)
    else
      re_dir(igniter, web_module)
    end
  end

  defp compute_location(igniter), do: igniter

  defp build_eex_assigns(%{assigns: %{component_module: _}} = igniter) do
    config = igniter.assigns.template_config
    options = apply_component_filters(igniter, igniter.args.options, config)

    case validate_args(options, config) do
      {[], values} ->
        user_config = igniter.assigns[:mishka_user_config] || %{}

        assigns =
          Core.eex_assigns(igniter, igniter.assigns.component_module, config,
            values: values,
            component_prefix: options[:component_prefix],
            module_prefix: options[:module_prefix] || user_config[:module_prefix]
          )

        Igniter.assign(igniter, :eex_assigns, assigns)

      {bad_args, _values} ->
        Igniter.add_issue(igniter, bad_args_message(bad_args))
    end
  end

  defp build_eex_assigns(igniter), do: igniter

  defp validate_args(options, config) do
    options
    |> Keyword.take(Keyword.keys(config[:args]))
    |> Enum.reduce({[], []}, fn {key, value}, {bad_acc, data_acc} ->
      case config[:args][key] do
        args when is_list(args) ->
          splited_args = Core.convert_options(value)

          if !Enum.all?(splited_args, &(&1 in args)) do
            {[{key, args} | bad_acc], data_acc}
          else
            {bad_acc, [{key, splited_args} | data_acc]}
          end

        _ ->
          {bad_acc, [{key, value} | data_acc]}
      end
    end)
  end

  defp bad_args_message(bad_args) do
    """
    Unfortunately, the arguments you sent were incorrect. You can only send the following options for
    each of the following arguments

    #{Enum.map(bad_args, fn {key, value} -> "* #{String.capitalize("#{key}")}: #{Enum.join(value, " - ")}\n" end)}
    """
  end

  defp re_dir(igniter, web_module) do
    Igniter.add_issue(igniter, """
    Note:
    You should have the path to the components folder in your Phoenix Framework web directory.
    Otherwise, the operation will stop.

    Note:
    If you believe your project path is correct or you are certain that the path belongs to a
    project created with Phoenix, check the following path. It is possible that your naming convention does
    not align with Elixir's naming style.

    Is your web path (#{inspect(web_module)})!? but we found this (#{inspect(IAPP.app_name(igniter)) <> "_web"})!!
    """)
  end

  defp write_component(%{assigns: %{eex_assigns: _}} = igniter) do
    igniter =
      Igniter.copy_template(
        igniter,
        igniter.assigns.template_path,
        igniter.assigns.proper_location,
        igniter.assigns.eex_assigns,
        on_exists: :overwrite
      )

    if is_nil(igniter.args.options[:no_deps]) do
      igniter
      |> optional_components()
      |> necessary_components()
    else
      igniter
    end
  end

  defp write_component(igniter), do: igniter

  defp optional_components(igniter) do
    template_config = igniter.assigns.template_config

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

  defp necessary_components(igniter) do
    options = igniter.args.options
    template_config = igniter.assigns.template_config
    template_path = igniter.assigns.template_path
    proper_location = igniter.assigns.proper_location
    assign = igniter.assigns.eex_assigns

    if Keyword.get(template_config, :necessary, []) != [] and Igniter.changed?(igniter) do
      interactive? =
        !options[:sub] and !options[:yes] and !options[:no_sub_config] and Mix.env() != :test

      prompt? = !options[:yes] and !options[:no_sub_config] and Mix.env() != :test

      if interactive? do
        IO.puts("#{IO.ANSI.bright() <> "Note:\n" <> IO.ANSI.reset()}")

        msg = """
        This component is dependent on other components, so it is necessary to build other
        items along with this component.

        Note: If you have used custom names for your dependent modules, this script will not be able to find them,
        so it will think that they have not been created.

        Components: #{Enum.join(template_config[:necessary], " - ")}
        """

        Mix.Shell.IO.info(IO.ANSI.cyan() <> String.trim_trailing(msg) <> IO.ANSI.reset())

        msg =
          "\nNote: \nIf approved, dependent components will be created without restrictions and you can change them manually."

        IO.puts("#{IO.ANSI.blue() <> msg <> IO.ANSI.reset()}")

        IO.puts(
          "#{IO.ANSI.cyan() <> "\nYou can run before generating this component:" <> IO.ANSI.reset()}"
        )
      end

      if prompt? do
        IO.puts(
          "#{IO.ANSI.yellow() <> "#{Enum.map(template_config[:necessary], &"\n   * mix mishka.ui.gen.component #{&1}\n")}" <> IO.ANSI.reset()}"
        )
      end

      if interactive? do
        Mix.Shell.IO.error("""

        In this section you can set your custom args for each dependent component.
        If you press the enter key, you have selected the default settings
        """)
      end

      template_config[:necessary]
      |> Enum.reduce({[], igniter}, fn item, {module_coms, acc} ->
        commands =
          if prompt? do
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

        component_acc =
          if !is_nil(options[:module]) do
            [{item, Core.module_atom(options[:module])}]
          else
            []
          end

        {module_coms ++ component_acc, Igniter.compose_task(acc, "mishka.ui.gen.component", args)}
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
  end

  # Apply filters for all component attributes from config
  defp apply_component_filters(igniter, options, template_config) do
    config = igniter.assigns.mishka_user_config

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
    if Keyword.get(options, option_key) != [] do
      options
    else
      configured_values = config[config_key] || []
      available_values = template_config[:args][option_key] || []

      case {configured_values, available_values} do
        {[], _} ->
          options

        {_, []} ->
          options

        {config_values, component_values} ->
          valid_values = Enum.filter(config_values, &(&1 in component_values))

          if valid_values != [] do
            Keyword.put(options, option_key, valid_values)
          else
            options
          end
      end
    end
  end

  defp wire_scripts(%{assigns: %{eex_assigns: _}} = igniter),
    do: Assets.wire_scripts(igniter, igniter.assigns.template_config, igniter.args.options)

  defp wire_scripts(igniter), do: igniter

  defp maybe_setup_css(igniter), do: Assets.setup_styled_css(igniter, igniter.args.options)

  defp maybe_save_prefixes(igniter), do: Core.maybe_save_prefixes(igniter, igniter.args.options)
end
