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

      entries = import_entries(list, web_module, igniter, opts)

      igniter
      |> Igniter.create_new_file(
        proper_location,
        """
        defmodule #{module_name} do
          @moduledoc \"\"\"
          `use #{module_name}` imports the generated Mishka Chelekom components.

          `mix mishka.ui.gen.components --import` rewrites this file on every run.
          \"\"\"

          defmacro __using__(_) do
            for {module, opts} <- imports() do
              quote do: import(unquote(module), unquote(opts))
            end
          end

          defp imports do
            [
              #{Enum.join(entries, ",\n")}
            ]
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
        {igniter, Sourceror.Zipper.find(zipper, &flash_group_def?/1) != nil}

      {:error, _igniter} ->
        {igniter, false}
    end
  end

  defp new_phoenix(igniter, _), do: {igniter, false}

  defp flash_group_def?(node), do: match?({:def, _, [{:flash_group, _, [_]}, _]}, node)

  defp globalize_components(igniter, import_module, true) do
    web_module_name = Igniter.Libs.Phoenix.web_module(igniter)

    core_components_module =
      (Module.split(web_module_name) |> Enum.map(&String.to_atom/1)) ++ [:CoreComponents]

    igniter
    |> Igniter.Project.Module.find_and_update_module!(web_module_name, fn zipper ->
      case Igniter.Code.Function.move_to_defp(zipper, :html_helpers, 0) do
        {:ok, zipper} -> use_import_module(zipper, import_module, core_components_module)
        :error -> {:ok, zipper}
      end
    end)
  end

  defp globalize_components(igniter, _import_module, _global) do
    igniter
  end

  # `html_helpers/0` gets `use <import_module>`: in place of the `import CoreComponents` its quote
  # has, or at the end of the quote when it has none. Nothing changes when it is already there.
  defp use_import_module(zipper, import_module, core_components_module) do
    if has_use?(zipper, import_module) do
      {:ok, zipper}
    else
      new_node = replace_core_import(zipper.node, import_module, core_components_module)
      new_zipper = Igniter.Code.Common.replace_code(zipper, new_node)

      if has_use?(new_zipper, import_module) do
        {:ok, new_zipper}
      else
        {:ok, Igniter.Code.Common.replace_code(zipper, append_use(zipper.node, import_module))}
      end
    end
  end

  defp replace_core_import(
         {:quote, _, [[{_, {:__block__, _, _args}}]]} = zip,
         import_module,
         core_components_module
       ) do
    Macro.prewalk(zip, fn
      {:import, meta, [{:__aliases__, alias_meta, ^core_components_module}]} ->
        {:use, meta, [{:__aliases__, alias_meta, [import_module]}]}

      other ->
        other
    end)
  end

  defp replace_core_import(zip, _import_module, _core_components_module), do: zip

  defp append_use(
         {:quote, meta, [[{block_meta, {:__block__, block_inner_meta, args}}]]},
         import_module
       ) do
    use_node = {:use, [], [{:__aliases__, [], [import_module]}]}
    {:quote, meta, [[{block_meta, {:__block__, block_inner_meta, args ++ [use_node]}}]]}
  end

  defp append_use(zip, _import_module), do: zip

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

  defp import_entries(list, web_module, igniter, opts) do
    {igniter, new_phoenix?} = new_phoenix(igniter, opts[:global])
    user_config = igniter.assigns[:mishka_user_config] || Config.load_user_config(igniter)

    if Map.get(igniter, :issues, []) == [] do
      ctx = %{
        igniter: igniter,
        web_module: web_module,
        new_phoenix?: new_phoenix?,
        component_prefix: opts[:component_prefix] || user_config[:component_prefix],
        module_prefix: opts[:module_prefix] || user_config[:module_prefix],
        helpers?: opts[:helpers]
      }

      Enum.map(list, &import_entry(&1, ctx))
    else
      igniter
    end
  end

  defp import_entry(item, ctx) do
    child_imports = child_imports(item, ctx)
    prefixed_item = Core.component_atom(prefixed(ctx.module_prefix, item))
    module = "#{inspect(ctx.web_module)}.Components.#{Core.module_atom("#{prefixed_item}")}"

    if child_imports != "" do
      "{#{module}, only: [#{child_imports}]}"
    else
      "{#{module}, []}"
    end
  end

  defp child_imports(component, ctx) do
    config =
      case Core.fetch_catalog(ctx.igniter, component, :styled) do
        {:ok, template} -> template.config[:args]
        {:error, _} -> []
      end

    helper_functions = if ctx.helpers?, do: Keyword.get(config, :helpers, []), else: []

    Keyword.get(config, :only, [])
    |> List.flatten()
    |> drop_flash_group(component, ctx.new_phoenix?)
    |> Enum.map(&function_name(ctx.component_prefix, &1))
    |> Enum.map(&{String.to_atom(&1), 1})
    |> Keyword.merge(helper_functions)
    |> Enum.map_join(", ", fn {key, value} -> "#{key}: #{value}" end)
  end

  # A Phoenix new enough to define `flash_group/1` in its Layouts keeps its own.
  defp drop_flash_group(list, "alert", true), do: Enum.reject(list, &(&1 == "flash_group"))
  defp drop_flash_group(list, _component, _new_phoenix?), do: list

  defp function_name(prefix, name) when prefix in [nil, false, ""] or name == "error", do: name
  defp function_name(prefix, name), do: "#{prefix}#{name}"

  defp prefixed(prefix, item) when prefix in [nil, false, ""], do: item
  defp prefixed(prefix, item), do: "#{prefix}#{item}"
end
