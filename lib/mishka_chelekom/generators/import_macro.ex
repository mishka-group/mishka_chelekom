defmodule MishkaChelekom.Generators.ImportMacro do
  @moduledoc """
  Generates the `<App>Web.Components.MishkaComponents` import macro for the styled batch task
  (`mix mishka.ui.gen.components --import`) and, with `--global`, wires it into the web module's
  `html_helpers/0` in place of the default `CoreComponents` import.
  """

  alias MishkaChelekom.Generators.Core
  alias MishkaChelekom.Config

  @doc """
  Creates the import-macro module for `list` of components when `opts[:import]` is set and the
  igniter is issue-free. `opts`: `:import`, `:helpers`, `:global`, `:component_prefix`,
  `:module_prefix`.
  """
  @spec create(Igniter.t(), [String.t()], keyword()) :: Igniter.t()
  def create(igniter, list, opts) do
    if opts[:import] && Map.get(igniter, :issues, []) == [] do
      web_module = Igniter.Libs.Phoenix.web_module(igniter)

      proper_location =
        Module.concat([web_module, "components", "mishka_components"])
        |> then(&Igniter.Project.Module.proper_location(igniter, &1))

      module_name =
        Core.module_atom(Macro.underscore(web_module) <> ".components.mishka_components")

      imports = create_import_string(list, web_module, igniter, opts)

      igniter
      |> Igniter.create_new_file(
        proper_location,
        """
        defmodule #{module_name} do
          defmacro __using__(_) do
            quote do
              #{Enum.map(imports, fn item -> "#{item}\n" end)}
            end
          end
        end
        """,
        on_exists: :overwrite
      )
      |> globalize_components(module_name, opts[:global])
    else
      igniter
    end
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

  defp create_import_string(list, web_module, igniter, opts) do
    {igniter, new_phoenix?} = new_phoenix(igniter, opts[:global])
    user_config = igniter.assigns[:mishka_user_config] || Config.load_user_config(igniter)
    component_prefix = opts[:component_prefix] || user_config[:component_prefix]
    module_prefix = opts[:module_prefix] || user_config[:module_prefix]
    helpers? = opts[:helpers]

    if Map.get(igniter, :issues, []) == [] do
      children = fn component ->
        config =
          case Core.fetch_catalog(igniter, component, :styled) do
            {:ok, template} -> template.config[:args]
            {:error, _} -> []
          end

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

        prefixed_item =
          if module_prefix && module_prefix != "" do
            "#{module_prefix}#{item}"
          else
            item
          end

        prefixed_item = Core.component_atom(prefixed_item)

        if child_imports != "" do
          "import #{inspect(web_module)}.Components.#{Core.module_atom("#{prefixed_item}")}, only: [#{child_imports}]"
        else
          "import #{inspect(web_module)}.Components.#{Core.module_atom("#{prefixed_item}")}"
        end
      end)
    else
      igniter
    end
  end
end
