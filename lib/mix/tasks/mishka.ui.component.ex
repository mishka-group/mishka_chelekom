defmodule Mix.Tasks.Mishka.Ui.Component do
  use Igniter.Mix.Task

  @example "mix mishka.ui.component component --example arg"
  # @components_path_pattern ~r/lib\/mishka_chelekom_web\/components/
  @shortdoc "A Mix Task for generating and configuring Phoenix components"
  @moduledoc """
  #{@shortdoc}

  Longer explanation of your task

  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * `--module_name` or `-m` - Docs for your option
  * `--variant` or `-v` - Docs for your option
  * `--color` or `-c` - Docs for your option
  * `--size` or `-s` - Docs for your option
  * `--padding` or `-p` - Docs for your option
  * `--space` or `-sp` - Docs for your option
  * `--type` or `-t` - Docs for your option
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
        type: :string
      ],
      # CLI aliases
      aliases: [v: :variant, c: :color, s: :size, m: :module, p: :padding, sp: :space, t: :type]
    }
  end

  def igniter(igniter, argv) do
    # extract positional arguments according to `positional` above
    {%{component: component}, argv} = positional_args!(argv)

    template_path =
      Application.app_dir(:mishka_chelekom, ["priv", "templates"])
      |> Path.join("#{component}.eex")

    """
       ,_,
      {o,o}
      /)  )
    ---"-"--
    """
    |> String.trim_trailing()
    |> IO.puts()

    # extract options according to `schema` and `aliases` above
    options = options!(argv)

    # Mix.shell().prompt("What's your name?")
    # name = Mix.Shell.IO.prompt("What's your name?")
    # Mix.shell().info("Hello, #{name}!")
    # Mix.Shell.IO.error("That's not a valid age! Please enter a number.")
    converted_components_path(igniter, component, Keyword.get(options, :module))
    |> case do
      {:ok, igniter, proper_location, assign} ->
        igniter
        |> Igniter.copy_template(template_path, proper_location, assign, on_exists: :overwrite)

      {:error, _} ->
        false
    end
  end

  def supports_umbrella?(), do: false

  # defp get_component_template(_igniter, component) do
  #   # TODO: check the component eex file exist or not
  #   # TODO: check the yaml file exist or not
  #   # TODO: get map of component yaml
  #   # TODO: if we have error it should prevent the code and return error
  #   # TODO: return {template_path, yaml_args}
  #   component
  # end

  # defp update_eex_assign(options, _source_args) do
  #   # TODO: create module name based on user inout
  #   # TODO: create list of all args event it is not be used in the eex file
  #   options
  # end

  defp converted_components_path(igniter, component, custom_module) do
    web_module = Macro.underscore(Igniter.Libs.Phoenix.web_module(igniter))

    Path.join("lib", web_module <> "/components")
    |> File.dir?()
    |> case do
      false ->
        re_dir(igniter, component, custom_module)

      true ->
        component = atom_to_module(custom_module || web_module <> ".components.#{component}")

        proper_location =
          Module.concat([
            Igniter.Libs.Phoenix.web_module(igniter),
            "components",
            (!is_nil(custom_module) && atom_to_module(custom_module, :last)) || component
          ])
          |> then(&Igniter.Project.Module.proper_location(igniter, &1))

        new_igniter =
          if !is_nil(custom_module) do
            igniter
            |> Igniter.Project.IgniterConfig.dont_move_file_pattern(~r/#{proper_location}/)
            |> Igniter.compose_task("igniter.add_extension", ["phoenix"])
          else
            igniter
          end

        {:ok, new_igniter, proper_location, [module: component]}
    end
  end

  defp re_dir(igniter, component, custom_module) do
    if Igniter.Util.IO.yes?("Do you want to continue?") do
      # TODO: create the directory
      converted_components_path(igniter, component, custom_module)
    else
      {:error, :no_dir, "error_msg"}
    end
  end

  def atom_to_module(field) do
    field
    |> String.split(".", trim: true)
    |> Enum.map(&Macro.camelize/1)
    |> Enum.join(".")
    |> String.to_atom()
  end

  def atom_to_module(field, :last) do
    field
    |> String.split(".", trim: true)
    |> List.last()
    |> Macro.camelize()
    |> String.to_atom()
  end
end
