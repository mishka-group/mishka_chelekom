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
      Path.join(Application.app_dir(:mishka_chelekom, ["priv", "templates"]), "#{component}.eex")

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
        {:error, :no_component, "error_msg", igniter}
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
          Module.concat([
            Igniter.Libs.Phoenix.web_module(template.igniter),
            "components",
            (!is_nil(custom_module) && atom_to_module(custom_module, :last)) || component
          ])
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

    new_assign = options |> Keyword.take(template_config[:args]) |> Keyword.merge(assign)

    # TODO: what we should do when a component needs some another component

    igniter = optional_components(igniter, template_config)

    {igniter, template_path, proper_location, new_assign}
  end

  def create_update_component({:error, _, msg, igniter}), do: Igniter.add_issue(igniter, msg)

  def create_update_component({igniter, template_path, proper_location, assign}) do
    igniter
    |> Igniter.copy_template(template_path, proper_location, assign, on_exists: :overwrite)
  end

  defp re_dir(template, custom_module) do
    if Igniter.Util.IO.yes?("Do you want to continue?") do
      # TODO: create the directory
      converted_components_path(template, custom_module)
    else
      {:error, :no_dir, "error_msg", template.igniter}
    end
  end

  defp optional_components(igniter, template_config) do
    if Keyword.get(template_config, :optional, []) != [] do
      igniter
      |> Igniter.add_warning(
        """
          Some other optional components are suggested for this component. You can create them separately.
          Note that if you use custom module names and their names are different each time,
          you may need to manually change the components.

          Components: #{Enum.join(template_config[:optional], " - ")}

          You can run:
              #{Enum.map(template_config[:optional], &"\n   * mix mishka.ui.component #{&1}\n")}
        """
        |> String.trim()
      )
    else
      igniter
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
