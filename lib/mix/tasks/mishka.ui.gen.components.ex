defmodule Mix.Tasks.Mishka.Ui.Gen.Components do
  alias Mix.Tasks.Mishka.Ui.Gen.Component
  use Igniter.Mix.Task
  alias Igniter.Project.Application, as: IAPP
  alias MishkaChelekom.Config

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
  * `--exclude` - Comma-separated list of components to exclude (e.g., `--exclude alert,badge`)
  * `--component-prefix` - Prefix for all component function names (e.g., `--component-prefix mishka_`)
  * `--module-prefix` - Prefix for module names (e.g., `--module-prefix mishka_` makes Chat become MishkaChat)
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
      positional: [{:components, optional: true}],
      # Other tasks your task composes using `Igniter.compose_task`, passing in the CLI argv
      # This ensures your option schema includes options from nested tasks
      composes: ["mishka.ui.gen.component"],
      # `OptionParser` schema
      schema: [
        import: :boolean,
        helpers: :boolean,
        global: :boolean,
        exclude: :csv,
        component_prefix: :string,
        module_prefix: :string,
        no_save: :boolean
      ],
      # CLI aliases
      aliases: [i: :import, h: :helpers, g: :global, e: :exclude]
    }
  end

  def igniter(igniter) do
    # Based on https://github.com/fuelen/owl/issues/27
    Application.ensure_all_started(:owl)
    # extract positional arguments according to `positional` above
    %Igniter.Mix.Task.Args{positional: %{components: components}} = igniter.args

    options = igniter.args.options

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

    user_config = Config.load_user_config(igniter)

    # Display exclusions and color filtering info before starting spinner
    config_excluded = user_config[:exclude_components] || []
    cli_excluded = options[:exclude] || []
    all_excluded = Enum.uniq(config_excluded ++ cli_excluded)

    if all_excluded != [] do
      IO.puts(
        "\n#{IO.ANSI.yellow()}Excluding components: #{inspect(all_excluded)}#{IO.ANSI.reset()}"
      )
    end

    # Display all configured filters
    filter_info =
      []
      |> maybe_add_filter("Colors", user_config[:component_colors])
      |> maybe_add_filter("Variants", user_config[:component_variants])
      |> maybe_add_filter("Sizes", user_config[:component_sizes])
      |> maybe_add_filter("Rounded", user_config[:component_rounded])
      |> maybe_add_filter("Padding", user_config[:component_padding])
      |> maybe_add_filter("Space", user_config[:component_space])

    if filter_info != [] do
      IO.puts("#{IO.ANSI.cyan()}Component filters from config:#{IO.ANSI.reset()}")

      Enum.each(filter_info, fn info ->
        IO.puts("  #{IO.ANSI.cyan()}• #{info}#{IO.ANSI.reset()}")
      end)
    end

    Owl.Spinner.start(id: :my_spinner, labels: [processing: "Please wait..."])

    list =
      if components == [] or Enum.member?(components, "all"),
        do:
          get_all_components_names(igniter)
          |> filter_excluded_components(user_config, options[:exclude]),
        else: components |> filter_excluded_components(user_config, options[:exclude])

    igniter =
      igniter
      |> Igniter.assign(%{mishka_user_config: user_config})
      |> then(fn ig ->
        # Build component args with optional prefixes
        component_args =
          ["--no-deps", "--sub", "--yes"] ++
            if(options[:component_prefix],
              do: ["--component-prefix", options[:component_prefix]],
              else: []
            ) ++
            if(options[:module_prefix],
              do: ["--module-prefix", options[:module_prefix]],
              else: []
            )

        Enum.reduce(list, ig, fn item, acc ->
          acc
          |> Igniter.compose_task("mishka.ui.gen.component", [item] ++ component_args)
        end)
      end)
      |> create_import_macro(
        list,
        options[:import] || false,
        options[:helpers],
        options[:global],
        options[:component_prefix],
        options[:module_prefix]
      )
      |> Component.setup_css_files([])
      |> maybe_update_config_prefixes(options)

    if Map.get(igniter, :issues, []) == [],
      do: Owl.Spinner.stop(id: :my_spinner, resolution: :ok, label: "Done"),
      else: Owl.Spinner.stop(id: :my_spinner, resolution: :error, label: "Error")

    igniter
  end

  defp new_phoenix(igniter, true) do
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    module_name = Module.concat(web_module, "Layouts")

    case Igniter.Project.Module.find_module(igniter, module_name) do
      {:ok, {_igniter, _source, zipper}} ->
        case Sourceror.Zipper.find(zipper, fn node ->
               match?({:def, _, [{:flash_group, _, [_]}, _]}, node)
             end) do
          nil -> {igniter, false}
          _function_zipper -> {igniter, true}
        end

      {:error, _igniter} ->
        {igniter, false}
    end
  end

  defp new_phoenix(igniter, _), do: {igniter, false}

  defp create_import_macro(
         igniter,
         list,
         import_status,
         helpers_status,
         global,
         component_prefix,
         module_prefix
       ) do
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
                #{Enum.map(create_import_string(list, web_module, igniter, helpers_status, global, component_prefix, module_prefix), fn item -> "#{item}\n" end)}
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

  defp create_import_string(
         list,
         web_module,
         igniter,
         helpers?,
         global,
         cli_component_prefix,
         cli_module_prefix
       ) do
    {igniter, new_phoenix?} = new_phoenix(igniter, global)
    user_config = igniter.assigns[:mishka_user_config] || Config.load_user_config(igniter)
    component_prefix = cli_component_prefix || user_config[:component_prefix]
    module_prefix = cli_module_prefix || user_config[:module_prefix]

    if Map.get(igniter, :issues, []) == [] do
      children = fn component ->
        config = Component.get_component_template(igniter, component).config[:args]

        component_functions =
          Keyword.get(config, :only, [])
          |> List.flatten()
          |> then(fn list ->
            if component == "alert" and new_phoenix?,
              do: Enum.reject(list, &(&1 == "flash_group")),
              else: list
          end)
          |> Enum.map(fn name ->
            if component_prefix && component_prefix != "" && name != "error",
              do: "#{component_prefix}#{name}",
              else: name
          end)
          |> Enum.map(&{String.to_atom(&1), 1})

        helper_functions = if helpers?, do: Keyword.get(config, :helpers, []), else: []

        component_functions
        |> Keyword.merge(helper_functions)
        |> Enum.map_join(", ", fn {key, value} -> "#{key}: #{value}" end)
      end

      Enum.map(list, fn item ->
        child_imports = children.(item)

        # Apply module prefix to the module name
        prefixed_item =
          if module_prefix && module_prefix != "" do
            "#{module_prefix}#{item}"
          else
            item
          end

        prefixed_item = Component.component_to_atom(prefixed_item)

        if child_imports != "" do
          "import #{inspect(web_module)}.Components.#{Component.atom_to_module("#{prefixed_item}")}, only: [#{child_imports}]"
        else
          "import #{inspect(web_module)}.Components.#{Component.atom_to_module("#{prefixed_item}")}"
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

  defp maybe_add_filter(list, _label, nil), do: list
  defp maybe_add_filter(list, _label, []), do: list

  defp maybe_add_filter(list, label, values) do
    list ++ ["#{label}: #{inspect(values)}"]
  end

  defp filter_excluded_components(components, _user_config, _cli_exclude) when components == [],
    do: components

  defp filter_excluded_components(components, user_config, cli_exclude) do
    config_excluded = user_config[:exclude_components] || []
    all_excluded = Enum.uniq(config_excluded ++ (cli_exclude || []))

    if all_excluded != [] do
      Enum.reject(components, &Enum.member?(all_excluded, &1))
    else
      components
    end
  end

  defp maybe_update_config_prefixes(igniter, options) do
    if options[:no_save] do
      igniter
    else
      igniter
      |> maybe_update_component_prefix(options[:component_prefix])
      |> maybe_update_module_prefix(options[:module_prefix])
    end
  end

  defp maybe_update_component_prefix(igniter, nil), do: igniter

  defp maybe_update_component_prefix(igniter, component_prefix) do
    Config.update_component_prefix(igniter, component_prefix)
  end

  defp maybe_update_module_prefix(igniter, nil), do: igniter

  defp maybe_update_module_prefix(igniter, module_prefix) do
    Config.update_module_prefix(igniter, module_prefix)
  end
end
