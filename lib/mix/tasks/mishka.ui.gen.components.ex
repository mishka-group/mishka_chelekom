defmodule Mix.Tasks.Mishka.Ui.Gen.Components do
  alias Mix.Tasks.Mishka.Ui.Gen.Component
  use Igniter.Mix.Task
  alias Igniter.Project.Application, as: IAPP

  @example "mix mishka.ui.gen.components component1,component2"
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

  * `--import` - Generates import file
  * `--helpers` - Specifies helper functions of each component in import file
  * `--global` - Makes components accessible throughout the project without explicit imports
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
      schema: [import: :boolean, helpers: :boolean, global: :boolean],
      # CLI aliases
      aliases: [i: :import, h: :helpers, g: :global]
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
      |> create_import_macro(list, options[:import] || false, options[:helpers], options[:global])

    if Map.get(igniter, :issues, []) == [],
      do: Owl.Spinner.stop(id: :my_spinner, resolution: :ok, label: "Done"),
      else: Owl.Spinner.stop(id: :my_spinner, resolution: :error, label: "Error")

    igniter
  end

  defp create_import_macro(igniter, list, import_status, helpers_status, global) do
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
        |> globalize_components(module_name, global)
      else
        igniter
      end

    igniter
  end

  defp globalize_components(igniter, import_module, true) do
    web_module_name = Igniter.Libs.Phoenix.web_module(igniter)

    core_components_module =
      (Module.split(web_module_name) |> Enum.map(&String.to_atom/1)) ++ [:CoreComponents]

    igniter
    |> Igniter.Project.Module.find_and_update_module!(web_module_name, fn zipper ->
      case Igniter.Code.Function.move_to_defp(zipper, :html_helpers, 0) do
        {:ok, zipper} ->
          if !has_use?(zipper, import_module) do
            new_node =
              case zipper.node do
                {:quote, _, [[{_, {:__block__, _, _args}}]]} = zip ->
                  Macro.prewalk(zip, fn
                    {:import, meta,
                     [
                       {:__aliases__, alias_meta, ^core_components_module}
                     ]} ->
                      {:use, meta, [{:__aliases__, alias_meta, [import_module]}]}

                    other ->
                      other
                  end)

                zip ->
                  zip
              end

            new_zipper = Igniter.Code.Common.replace_code(zipper, new_node)

            if has_use?(new_zipper, import_module) do
              {:ok, new_zipper}
            else
              new_node =
                case zipper.node do
                  {:quote, meta, [[{block_meta, {:__block__, block_inner_meta, args}}]]} ->
                    {:quote, meta,
                     [
                       [
                         {block_meta,
                          {:__block__, block_inner_meta,
                           args ++ [{:use, [], [{:__aliases__, [], [import_module]}]}]}}
                       ]
                     ]}

                  zip ->
                    zip
                end

              {:ok, Igniter.Code.Common.replace_code(zipper, new_node)}
            end
          else
            {:ok, zipper}
          end

        :error ->
          {:ok, zipper}
      end
    end)
  end

  defp globalize_components(igniter, _import_module, _global) do
    igniter
  end

  defp has_use?(new_zipper, import_module) do
    with {:ok, zipper} <- Igniter.Code.Common.move_to_do_block(new_zipper),
         {:ok, zipper} <-
           Igniter.Code.Function.move_to_function_call_in_current_scope(
             zipper,
             :use,
             1
           ) do
      Igniter.Code.Function.argument_equals?(zipper, 0, Module.concat([import_module]))
    else
      _ -> false
    end
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
      "deps/mishka_chelekom/priv/components",
      IAPP.priv_dir(igniter, ["mishka_chelekom", "components"]),
      IAPP.priv_dir(igniter, ["mishka_chelekom", "templates"]),
      IAPP.priv_dir(igniter, ["mishka_chelekom", "presets"])
    ]
    |> Enum.flat_map(&Path.wildcard(Path.join(&1, "*.eex")))
    |> Enum.map(&Path.basename(&1, ".eex"))
    |> Enum.uniq()
  end
end
