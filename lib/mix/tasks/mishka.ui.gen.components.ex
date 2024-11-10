defmodule Mix.Tasks.Mishka.Ui.Gen.Components do
  alias Mix.Tasks.Mishka.Ui.Gen.Component
  use Igniter.Mix.Task
  alias Igniter.Project.Application, as: IAPP

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
      schema: [import: :boolean, helpers: :boolean],
      # CLI aliases
      aliases: [i: :import, h: :helpers]
    }
  end

  def igniter(igniter, argv) do
    # Based on https://github.com/fuelen/owl/issues/27
    Application.ensure_all_started(:owl)
    # extract positional arguments according to `positional` above
    {%{components: components}, argv} = positional_args!(argv)

    options = options!(argv)

    msg =
      """
            .-.
           /'v'\\
          (/   \\)
          =="="==
        Mishka.tools
      """

    IO.puts(IO.ANSI.red() <> String.trim_trailing(msg) <> IO.ANSI.reset())

    components = String.split(components || "", ",", trim: true)

    Owl.Spinner.start(id: :my_spinner, labels: [processing: "Please wait..."])

    list =
      if components == [] or Enum.member?(components, "all"),
        do: get_all_components_names(igniter),
        else: components

    igniter =
      Enum.reduce(list, igniter, fn item, acc ->
        acc
        |> Igniter.compose_task("mishka.ui.gen.component", [item, "--no-deps", "--sub", "--yes"])
      end)
      |> create_import_macro(list, options[:import], options[:helpers])

    if Map.get(igniter, :issues, []) == [],
      do: Owl.Spinner.stop(id: :my_spinner, resolution: :ok, label: "Done"),
      else: Owl.Spinner.stop(id: :my_spinner, resolution: :error, label: "Error")

    igniter
  end

  defp create_import_macro(igniter, list, import_status, helpers_status) do
    igniter =
      if import_status and Map.get(igniter, :issues, []) == [] do
        web_module = Igniter.Libs.Phoenix.web_module(igniter)

        proper_location =
          Module.concat([web_module, "components", "mishka_components"])
          |> then(&Igniter.Project.Module.proper_location(igniter, &1))

        module_name =
          Component.atom_to_module(
            Macro.underscore(web_module) <> ".components.mishka_components"
          )

        igniter
        |> Igniter.create_new_file(
          proper_location,
          """
          defmodule #{module_name} do
            defmacro __using__(_) do
              quote do
                #{Enum.map(create_import_string(list, web_module, igniter, helpers_status), fn item -> "#{item}\n" end)}
              end
            end
          end
          """,
          on_exists: :overwrite
        )
      else
        igniter
      end

    igniter
  end

  defp create_import_string(list, web_module, igniter, helpers?) do
    if Map.get(igniter, :issues, []) == [] do
      children = fn component ->
        config = Component.get_component_template(igniter, component).config[:args]

        Keyword.get(config, :only, [])
        |> List.flatten()
        |> Enum.map(&{String.to_atom(&1), 1})
        |> Keyword.merge(if helpers?, do: Keyword.get(config, :helpers, []), else: [])
        |> Enum.map_join(", ", fn {key, value} -> "#{key}: #{value}" end)
      end

      Enum.map(list, fn item ->
        child_imports = children.(item)
        item = Component.component_to_atom(item)

        if child_imports != "" do
          "import #{inspect(web_module)}.Components.#{Component.atom_to_module("#{item}")}, only: [#{child_imports}]"
        else
          "import #{inspect(web_module)}.Components.#{Component.atom_to_module("#{item}")}"
        end
      end)
    else
      igniter
    end
  end

  defp get_all_components_names(igniter) do
    [
      Application.app_dir(:mishka_chelekom, ["priv", "templates", "components"]),
      IAPP.priv_dir(igniter, ["mishka_chelekom", "components"]),
      IAPP.priv_dir(igniter, ["mishka_chelekom", "templates"]),
      IAPP.priv_dir(igniter, ["mishka_chelekom", "presets"])
    ]
    |> Enum.flat_map(&Path.wildcard(Path.join(&1, "*.eex")))
    |> Enum.map(&Path.basename(&1, ".eex"))
    |> Enum.uniq()
  end
end
