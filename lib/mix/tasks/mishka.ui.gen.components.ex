defmodule Mix.Tasks.Mishka.Ui.Gen.Components do
  use Igniter.Mix.Task

  @example "mix mishka.ui.gen.components component1, component1"
  @shortdoc "A Mix Task for generating and configuring multi components of Phoenix"
  @moduledoc """
  #{@shortdoc}

  A Mix Task for generating and configuring multi components of Phoenix

  > This task does not do any additional work compared to the `mix mishka.ui.gen.component` task,
  > it just creates all the components in one place. For this purpose, all components
  > are created with default arguments.

  ## Example

  ```bash
  #{@example}
  ```

  ## Options

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
      positional: [{:components, optional: true}],
      # Other tasks your task composes using `Igniter.compose_task`, passing in the CLI argv
      # This ensures your option schema includes options from nested tasks
      composes: ["mishka.ui.gen.component"],
      # `OptionParser` schema
      schema: [],
      # CLI aliases
      aliases: []
    }
  end

  def igniter(igniter, argv) do
    # extract positional arguments according to `positional` above
    {%{components: components}, _rgs} = positional_args!(argv)

    msg =
      """
            .-.
           /'v'\\
          (/   \\)
          =="="==
        Mishka.life
      """

    IO.puts(IO.ANSI.red() <> String.trim_trailing(msg) <> IO.ANSI.reset())

    components = String.split(components || "", ",", trim: true)

    list =
      if components == [] or Enum.member?(components, "all"),
        do: get_all_components_names(),
        else: components

    igniter =
      Enum.reduce(list, igniter, fn item, acc ->
        acc
        |> Igniter.compose_task("mishka.ui.gen.component", [item, "--no-deps", "--sub", "--yes"])
      end)

    igniter
  end

  defp get_all_components_names() do
    Application.app_dir(:mishka_chelekom, ["priv", "templates", "components"])
    |> Path.join("*.eex")
    |> Path.wildcard()
    |> Enum.map(&Path.basename(&1, ".eex"))
    |> Enum.uniq()
  end
end
