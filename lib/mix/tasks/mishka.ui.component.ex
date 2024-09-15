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
        module_name: :string,
        padding: :string,
        space: :string
      ],
      # CLI aliases
      aliases: [v: :variant, c: :color, s: :size, m: :module_name, p: :padding, sp: :space]
    }
  end

  def igniter(igniter, argv) do
    # extract positional arguments according to `positional` above
    {_arguments, argv} = positional_args!(argv)
    # extract options according to `schema` and `aliases` above
    _options = options!(argv)
    # Do your work here and return an updated igniter
    IO.inspect(argv)

    igniter
    |> Igniter.add_warning("mix mishka.ui.component is not yet implemented")
  end
end
