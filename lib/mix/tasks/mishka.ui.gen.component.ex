defmodule Mix.Tasks.Mishka.Ui.Gen.Component do
  use Igniter.Mix.Task

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
  * `--no-sub-config` - Creates dependent components with default settings
  * `--module` or `-m` - Specifies a custom name for the component module
  * `--sub` - Specifies this task is a sub task
  * `--no-deps` - Specifies this task is created without sub task
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
      # Other tasks your task composes using `Igniter.compose_task`, passing in the CLI argv
      # This ensures your option schema includes options from nested tasks
      composes: [],
      # `OptionParser` schema
      schema: [
        variant: :string,
        color: :string,
        size: :string,
        module: :string,
        padding: :string,
        space: :string,
        type: :string,
        sub: :boolean,
        no_deps: :boolean,
        no_sub_config: :boolean
      ],
      # CLI aliases
      aliases: [v: :variant, c: :color, s: :size, m: :module, p: :padding, sp: :space, t: :type]
    }
  end

  def igniter(igniter, argv) do
    # extract positional arguments according to `positional` above
    {%{component: component}, argv} = positional_args!(argv)

    options = options!(argv)

    if !options[:sub] do
      msg =
        """
              .-.
             /'v'\\
            (/   \\)
            =="="==
          Mishka.life
        """

      IO.puts(IO.ANSI.green() <> String.trim_trailing(msg) <> IO.ANSI.reset())
    end

    igniter
    |> get_component_template(component)
    |> converted_components_path(Keyword.get(options, :module))
    |> update_eex_assign(options)
    |> create_update_component()
  end

  def supports_umbrella?(), do: false

  defp get_component_template(igniter, component) do
    component = String.replace(component, " ", "") |> Macro.underscore()

    template_path =
      Path.join(
        Application.app_dir(:mishka_chelekom, ["priv", "templates", "components"]),
        "#{component}.eex"
      )

    template_config_path = Path.rootname(template_path) <> ".exs"

    {File.exists?(template_path), File.exists?(template_config_path)}
    |> case do
      {true, true} ->
        %{
          igniter: igniter,
          component: component,
          path: template_path,
          config: Config.Reader.read!(template_config_path)[String.to_atom(component)]
        }

      _ ->
        msg = """
        The component you requested does not exist or you wrote its name incorrectly.
        Please read the site documentation.
        """

        {:error, :no_component, msg, igniter}
    end
  end

  defp converted_components_path({:error, _, _, _igniter} = error, _), do: error

  defp converted_components_path(template, custom_module) do
    web_module = Macro.underscore(Igniter.Libs.Phoenix.web_module(template.igniter))

    Path.join("lib", web_module <> "/components")
    |> File.dir?()
    |> case do
      false ->
        re_dir(template, custom_module)

      true ->
        component =
          atom_to_module(custom_module || web_module <> ".components.#{template.component}")

        proper_location =
          if is_nil(custom_module) do
            Module.concat([component])
          else
            Module.concat([
              Igniter.Libs.Phoenix.web_module(template.igniter),
              "components",
              atom_to_module(custom_module, :last)
            ])
          end
          |> then(&Igniter.Project.Module.proper_location(template.igniter, &1))

        new_igniter =
          if !is_nil(custom_module) do
            template.igniter
            |> Igniter.Project.IgniterConfig.dont_move_file_pattern(~r/#{proper_location}/)
            |> Igniter.compose_task("igniter.add_extension", ["phoenix"])
          else
            template.igniter
          end

        {new_igniter, proper_location, [module: component], template.path, template.config}
    end
  end

  defp update_eex_assign({:error, _, _, _igniter} = error, _), do: error

  defp update_eex_assign(
         {igniter, proper_location, assign, template_path, template_config},
         options
       ) do
    new_assign =
      options |> Keyword.take(Keyword.keys(template_config[:args])) |> Keyword.merge(assign)

    user_bad_args =
      Enum.map(new_assign, fn {key, value} ->
        case template_config[:args][key] do
          args when is_list(args) ->
            user_values =
              String.split(value, ",", trim: true)
              |> Enum.all?(&(&1 in args))

            if !user_values, do: {key, args}, else: nil

          _ ->
            nil
        end
      end)
      |> Enum.reject(&is_nil(&1))

    if length(user_bad_args) > 0 do
      msg = """
      Unfortunately, the arguments you sent were incorrect. You can only send the following options for
      each of the following arguments

      #{Enum.map(user_bad_args, fn {key, value} -> "* #{String.capitalize("#{key}")}: #{Enum.join(value, " - ")}\n" end)}
      """

      {:error, :bad_args, msg, igniter}
    else
      {igniter, template_path, template_config, proper_location, new_assign, options}
    end
  end

  # TODO: for another version
  defp re_dir(template, _custom_module) do
    # if Igniter.Util.IO.yes?("Do you want to continue?") do
    #   # TODO: create the directory
    #   converted_components_path(template, custom_module)
    # else
    #   {:error, :no_dir, "error_msg", template.igniter}
    # end
    msg = """
    You should have the path to the components folder in your Phoenix Framework web directory.
    Otherwise, the operation will stop.
    """

    {:error, :no_dir, msg, template.igniter}
  end

  defp create_update_component({:error, _, msg, igniter}), do: Igniter.add_issue(igniter, msg)

  defp create_update_component(
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
      igniter
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
    if Keyword.get(template_config, :necessary, []) != [] and Igniter.changed?(igniter) do
      if template_config[:necessary] != [] and !options[:sub] and !options[:yes] and
           !options[:no_sub_config] do
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

      if template_config[:necessary] != [] and !options[:yes] and !options[:no_sub_config] do
        IO.puts(
          "#{IO.ANSI.yellow() <> "#{Enum.map(template_config[:necessary], &"\n   * mix mishka.ui.gen.component #{&1}\n")}" <> IO.ANSI.reset()}"
        )
      end

      if template_config[:necessary] != [] and !options[:sub] and !options[:yes] and
           !options[:no_sub_config] do
        Mix.Shell.IO.error("""

        In this section you can set your custom args for each dependent component.
        If you press the enter key, you have selected the default settings
        """)
      end

      Enum.reduce(template_config[:necessary], {[], igniter}, fn item, {module_coms, acc} ->
        commands =
          if !options[:yes] and !options[:no_sub_config] do
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

        templ_options = options!(args)

        component_acc =
          if !is_nil(templ_options[:module]) do
            [{item, atom_to_module(templ_options[:module])}]
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

  defp atom_to_module(field) do
    field
    |> String.split(".", trim: true)
    |> Enum.map(&Macro.camelize/1)
    |> Enum.join(".")
    |> String.to_atom()
  end

  defp atom_to_module(field, :last) do
    field
    |> String.split(".", trim: true)
    |> List.last()
    |> Macro.camelize()
    |> String.to_atom()
  end
end