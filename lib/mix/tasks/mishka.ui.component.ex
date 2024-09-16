defmodule Mix.Tasks.Mishka.Ui.Component do
  use Igniter.Mix.Task

  @example "mix mishka.ui.component component --example arg"

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

    # extract options according to `schema` and `aliases` above
    options = options!(argv)

    # Do your work here and return an updated igniter
    part_module_name = Igniter.Code.Module.parse(Keyword.get(options, :module, component))

    module_place =
      Igniter.Project.Module.proper_location(
        igniter,
        part_module_name,
        {:source_folder, "component"}
      )

    assign = [module: String.capitalize(component)]

    igniter
    |> Igniter.copy_template(template_path, module_place, assign, on_exists: :overwrite)

    # |> Igniter.add_warning("mix mishka.ui.component is not yet implemented")
  end
end
