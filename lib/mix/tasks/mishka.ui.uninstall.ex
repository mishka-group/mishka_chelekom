defmodule Mix.Tasks.Mishka.Ui.Uninstall do
  use Igniter.Mix.Task
  alias IgniterJs.Parsers.Javascript.Parser, as: JsParser
  alias IgniterJs.Parsers.Javascript.Formatter, as: JsFormatter
  alias Mix.Tasks.Mishka.Ui.Gen.Component, as: GenComponent
  alias MishkaChelekom.Config

  @example "mix mishka.ui.uninstall accordion"
  @shortdoc "A Mix Task for uninstalling Mishka Chelekom components"
  @moduledoc """
  #{@shortdoc}

  This task safely removes components while handling shared dependencies like JavaScript hooks.
  When multiple components share the same JS hook, it will only be removed when the last
  component using it is uninstalled.

  > This task respects module_prefix configuration and cleans up import macro files,
  > CSS files, and config files when using the appropriate flags.

  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * `--all` or `-a` - Remove all installed Mishka components
  * `--dry-run` or `-d` - Preview what would be removed without making changes
  * `--yes` - Skip confirmation prompts
  * `--force` or `-f` - Force removal even if other components depend on it
  * `--include-css` - Also remove CSS files (only with --all)
  * `--include-config` - Also remove the config file (only with --all)
  * `--keep-js` - Keep JavaScript files even if no components use them
  * `--verbose` or `-V` - Show detailed output of all operations
  """

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      adds_deps: [],
      installs: [],
      example: @example,
      extra_args?: false,
      only: nil,
      positional: [{:components, optional: true}],
      composes: [],
      schema: [
        all: :boolean,
        dry_run: :boolean,
        force: :boolean,
        include_css: :boolean,
        include_config: :boolean,
        keep_js: :boolean,
        verbose: :boolean
      ],
      aliases: [a: :all, d: :dry_run, f: :force, V: :verbose]
    }
  end

  def igniter(igniter) do
    %{options: options, positional: %{components: components_arg}} = igniter.args

    igniter
    |> Igniter.assign(:opts, build_opts(options))
    |> Igniter.assign(:user_config, Config.load_user_config(igniter))
    |> tap(fn _ -> if !options[:dry_run] && Mix.env() != :test, do: print_banner() end)
    |> parse_components(components_arg)
    |> handle_uninstall()
  end

  defp build_opts(options) do
    %{
      verbose: options[:verbose] == true,
      dry_run: options[:dry_run] == true,
      yes: options[:yes] == true,
      force: options[:force] == true,
      all: options[:all] == true,
      keep_js: options[:keep_js] == true,
      include_css: options[:include_css] == true,
      include_config: options[:include_config] == true
    }
  end

  defp parse_components(%{assigns: %{opts: %{all: true}}} = igniter, _arg),
    do: find_all_installed_components(igniter)

  defp parse_components(igniter, arg) when is_binary(arg) and arg != "",
    do: Igniter.assign(igniter, :components, String.split(arg, ",", trim: true))

  defp parse_components(igniter, _arg) do
    Igniter.add_issue(igniter, """
    Please specify components to uninstall or use --all flag.

    Examples:
      mix mishka.ui.uninstall accordion
      mix mishka.ui.uninstall accordion,button,alert
      mix mishka.ui.uninstall --all
    """)
  end

  defp handle_uninstall(%{issues: issues} = igniter) when issues != [], do: igniter

  defp handle_uninstall(%{assigns: %{components: []}} = igniter),
    do: Igniter.add_notice(igniter, "No Mishka components found to uninstall.")

  defp handle_uninstall(%{assigns: %{components: nil}} = igniter), do: igniter

  defp handle_uninstall(igniter), do: process_uninstall(igniter)

  defp print_banner do
    """
          .-.
         /'v'\\
        (/   \\)
        =="="==
      Mishka.tools
       Uninstall
    """
    |> String.trim_trailing()
    |> then(&IO.puts(IO.ANSI.magenta() <> &1 <> IO.ANSI.reset()))
  end

  defp find_all_installed_components(igniter) do
    Igniter.assign(igniter, :components, list_installed_components(igniter))
  end

  defp list_installed_components(igniter) do
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    module_prefix = igniter.assigns.user_config[:module_prefix]
    known = get_known_component_names()
    components_dir = get_components_dir(igniter, web_module)

    real_files =
      components_dir
      |> Path.join("*.ex")
      |> Path.wildcard()

    virtual_files =
      igniter.rewrite
      |> Rewrite.sources()
      |> Enum.map(&Rewrite.Source.get(&1, :path))
      |> Enum.filter(&String.starts_with?(&1, components_dir))
      |> Enum.filter(&String.ends_with?(&1, ".ex"))

    (real_files ++ virtual_files)
    |> Enum.uniq()
    |> Enum.map(&Path.basename(&1, ".ex"))
    |> Enum.map(&Macro.underscore/1)
    |> Enum.map(&strip_prefix(&1, module_prefix))
    |> Enum.filter(&(&1 in known))
    |> Enum.uniq()
  end

  defp strip_prefix(name, prefix) when is_binary(prefix) and prefix != "",
    do: String.trim_leading(name, prefix)

  defp strip_prefix(name, _), do: name

  defp get_known_component_names do
    config_paths()
    |> Enum.flat_map(&Path.wildcard(Path.join(&1, "*.exs")))
    |> Enum.map(&Path.basename(&1, ".exs"))
    |> Enum.uniq()
  end

  defp process_uninstall(igniter) do
    igniter
    |> build_removal_plan()
    |> handle_dependencies()
    |> maybe_show_plan()
    |> execute_or_cancel()
  end

  defp handle_dependencies(%{issues: issues} = igniter) when issues != [], do: igniter

  defp handle_dependencies(igniter) do
    %{opts: opts, plan: plan} = igniter.assigns
    dependent_components = Enum.map(plan.warnings, fn {comp, _} -> comp end)

    cond do
      dependent_components == [] ->
        igniter

      opts.force ->
        igniter

      opts.dry_run ->
        igniter

      opts.yes ->
        Igniter.add_issue(igniter, """
        Cannot remove components: other components depend on them.

        The following components would break:
        #{format_dependency_list(plan.warnings)}

        Options:
          - Use --force to remove anyway
          - Also remove the dependent components: #{Enum.join(dependent_components, ",")}
        """)

      Mix.env() != :test ->
        ask_cascade_removal(igniter, dependent_components)

      true ->
        igniter
    end
  end

  defp ask_cascade_removal(igniter, dependent_components) do
    Application.ensure_all_started(:owl)

    IO.puts("\n#{IO.ANSI.yellow()}#{IO.ANSI.bright()}⚠ Dependency Warning#{IO.ANSI.reset()}")
    IO.puts("These components depend on what you're removing:\n")

    Enum.each(igniter.assigns.plan.warnings, fn {comp, deps} ->
      IO.puts("  #{IO.ANSI.yellow()}• #{comp}#{IO.ANSI.reset()} uses: #{Enum.join(deps, ", ")}")
    end)

    IO.puts("")

    {_, choice} =
      Owl.IO.select(
        [
          {"Also remove the #{length(dependent_components)} components listed above", :cascade},
          {"Continue anyway (may cause errors)", :continue},
          {"Cancel", :cancel}
        ],
        label: "What would you like to do?",
        render_as: fn {label, _} -> label end
      )

    apply_cascade_choice(igniter, choice, dependent_components)
  end

  def apply_cascade_choice(igniter, :cascade, dependent_components) do
    new_components = Enum.uniq(igniter.assigns.components ++ dependent_components)

    igniter
    |> Igniter.assign(:components, new_components)
    |> build_removal_plan()
    |> handle_dependencies()
  end

  def apply_cascade_choice(igniter, :continue, _dependent_components), do: igniter

  def apply_cascade_choice(igniter, :cancel, _dependent_components) do
    Igniter.add_issue(igniter, "Operation cancelled by user.")
  end

  defp format_dependency_list(warnings) do
    Enum.map_join(warnings, "\n", fn {comp, deps} ->
      "  • #{comp} depends on: #{Enum.join(deps, ", ")}"
    end)
  end

  defp maybe_show_plan(%{issues: issues} = igniter) when issues != [], do: igniter

  defp maybe_show_plan(igniter) do
    %{opts: opts, plan: plan} = igniter.assigns

    if should_show_plan?(opts) do
      show_removal_plan(plan, opts.dry_run)
    end

    igniter
  end

  defp should_show_plan?(%{dry_run: true}), do: Mix.env() != :test
  defp should_show_plan?(%{verbose: true}), do: Mix.env() != :test
  defp should_show_plan?(%{yes: false}), do: Mix.env() != :test
  defp should_show_plan?(_), do: false

  defp execute_or_cancel(%{issues: issues} = igniter) when issues != [], do: igniter

  defp execute_or_cancel(igniter) do
    if should_proceed?(igniter.assigns.opts) do
      igniter
      |> remove_component_files()
      |> remove_js_files()
      |> update_mishka_components_js()
      |> maybe_remove_mishka_components_js()
      |> update_app_js()
      |> update_import_macro()
      |> maybe_cleanup_global_import()
      |> maybe_remove_css()
      |> maybe_remove_config()
      |> add_completion_notice()
    else
      add_cancel_notice(igniter)
    end
  end

  defp should_proceed?(%{dry_run: true}), do: false
  defp should_proceed?(_), do: true

  defp add_cancel_notice(%{assigns: %{opts: %{dry_run: true}}} = igniter) do
    Igniter.add_notice(igniter, """

    Dry-run complete. No files were modified.
    Run without --dry-run to perform the actual uninstall.
    """)
  end

  defp add_cancel_notice(igniter), do: Igniter.add_notice(igniter, "Uninstall cancelled.")

  defp build_removal_plan(igniter) do
    %{components: components, user_config: user_config} = igniter.assigns
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    module_prefix = user_config[:module_prefix]

    all_configs = load_all_configs()
    all_installed = list_installed_components(igniter)
    remaining = all_installed -- components

    configs_to_remove = Map.new(components, &{&1, Map.get(all_configs, &1)})
    configs_remaining = Map.new(remaining, &{&1, Map.get(all_configs, &1)})

    js_to_consider = extract_js_files(configs_to_remove)
    js_still_needed = extract_js_files(configs_remaining)
    js_to_remove = js_to_consider -- js_still_needed

    {igniter, component_files} =
      resolve_component_files(igniter, components, web_module, module_prefix)

    plan = %{
      components: components,
      component_files: component_files,
      configs: configs_to_remove,
      js_to_remove: js_to_remove,
      js_preserved: js_to_consider -- js_to_remove,
      js_modules_to_remove: extract_js_modules(configs_to_remove, js_to_remove),
      remaining: remaining,
      warnings: find_dependency_warnings(configs_remaining, components),
      web_module: web_module,
      module_prefix: module_prefix
    }

    Igniter.assign(igniter, :plan, plan)
  end

  defp load_all_configs do
    config_paths()
    |> Enum.flat_map(&Path.wildcard(Path.join(&1, "*.exs")))
    |> Enum.reduce(%{}, fn path, acc ->
      component = Path.basename(path, ".exs")

      case read_config_file(path, component) do
        nil -> acc
        config -> Map.put(acc, component, config)
      end
    end)
  end

  defp config_paths do
    ["deps/mishka_chelekom/priv/components", "priv/components"]
    |> Enum.filter(&File.dir?/1)
  end

  defp read_config_file(path, component) do
    config = Elixir.Config.Reader.read!(path)
    Keyword.get(config, String.to_atom(component))
  rescue
    _ -> nil
  end

  defp get_components_dir(igniter, web_module) do
    [web_module, "Components", "Placeholder"]
    |> Module.concat()
    |> then(&Igniter.Project.Module.proper_location(igniter, &1))
    |> Path.dirname()
  end

  defp extract_js_files(configs) do
    configs
    |> Enum.flat_map(fn {_, config} -> get_script_files(config) end)
    |> Enum.uniq()
  end

  defp get_script_files(nil), do: []

  defp get_script_files(config) do
    config
    |> Keyword.get(:scripts, [])
    |> Enum.filter(&(&1.type == "file"))
    |> Enum.map(& &1.file)
  end

  defp extract_js_modules(configs, js_to_remove) do
    configs
    |> Enum.flat_map(fn {_, config} ->
      (config || [])
      |> Keyword.get(:scripts, [])
      |> Enum.filter(&(&1.type == "file" and &1.file in js_to_remove))
      |> Enum.map(&{&1.module, &1.imports, &1.file})
    end)
    |> Enum.uniq()
  end

  defp resolve_component_files(igniter, components, web_module, module_prefix) do
    Enum.reduce(components, {igniter, []}, fn component, {ig, files} ->
      module = build_module_name(web_module, component, module_prefix)

      case Igniter.Project.Module.find_module(ig, module) do
        {:ok, {ig, source, _}} ->
          {ig, [{component, Rewrite.Source.get(source, :path), true, module} | files]}

        {:error, ig} ->
          path = Igniter.Project.Module.proper_location(ig, module)
          {ig, [{component, path, false, module} | files]}
      end
    end)
    |> then(fn {ig, files} -> {ig, Enum.reverse(files)} end)
  end

  defp find_dependency_warnings(configs_remaining, removing) do
    Enum.flat_map(configs_remaining, fn {component, config} ->
      case config do
        nil ->
          []

        config ->
          affected = config |> Keyword.get(:necessary, []) |> Enum.filter(&(&1 in removing))
          if affected != [], do: [{component, affected}], else: []
      end
    end)
  end

  defp build_module_name(web_module, component, prefix) do
    name = if prefix && prefix != "", do: "#{prefix}#{component}", else: component
    Module.concat([web_module, "Components", GenComponent.atom_to_module(name)])
  end

  defp show_removal_plan(plan, dry_run) do
    if dry_run do
      IO.puts("\n#{IO.ANSI.cyan()}[DRY RUN]#{IO.ANSI.reset()}")
    end

    IO.puts("\n#{IO.ANSI.bright()}Components to remove:#{IO.ANSI.reset()}")
    Enum.each(plan.component_files, &print_component_status/1)

    print_js_section("JavaScript files to remove:", plan.js_to_remove, IO.ANSI.red())
    print_js_section("JavaScript files preserved:", plan.js_preserved, IO.ANSI.green())
    print_warnings(plan.warnings)
    IO.puts("")
  end

  defp print_component_status({component, path, exists?, _module}) do
    status = if exists?, do: IO.ANSI.green() <> "✓", else: IO.ANSI.red() <> "✗ (not found)"
    IO.puts("  #{status} #{component}#{IO.ANSI.reset()} - #{path || "unknown"}")
  end

  defp print_js_section(_, [], _), do: :ok

  defp print_js_section(title, files, color) do
    IO.puts("\n#{IO.ANSI.bright()}#{title}#{IO.ANSI.reset()}")
    Enum.each(files, &IO.puts("  #{color}• assets/vendor/#{&1}#{IO.ANSI.reset()}"))
  end

  defp print_warnings([]), do: :ok

  defp print_warnings(warnings) do
    IO.puts(
      "\n#{IO.ANSI.yellow()}#{IO.ANSI.bright()}⚠ Warning: These components depend on what you're removing:#{IO.ANSI.reset()}"
    )

    Enum.each(warnings, fn {component, deps} ->
      IO.puts(
        "  #{IO.ANSI.yellow()}• #{component}#{IO.ANSI.reset()} uses: #{Enum.join(deps, ", ")}"
      )
    end)
  end

  defp remove_component_files(igniter) do
    Enum.reduce(igniter.assigns.plan.component_files, igniter, &do_remove_component/2)
  end

  defp do_remove_component({_, path, true, module}, igniter) when not is_nil(path) do
    verbose_log(igniter, "  Removing: #{path} (#{inspect(module)})")
    Igniter.rm(igniter, path)
  end

  defp do_remove_component({_, path, false, module}, igniter) do
    verbose_log(igniter, "  Skipping (not found): #{path || "unknown"} (#{inspect(module)})")
    igniter
  end

  defp remove_js_files(%{assigns: %{opts: %{keep_js: true}}} = igniter), do: igniter

  defp remove_js_files(igniter) do
    Enum.reduce(igniter.assigns.plan.js_to_remove, igniter, fn file, acc ->
      path = "assets/vendor/#{file}"

      if Igniter.exists?(acc, path) do
        verbose_log(acc, "  Removing JS: #{path}")
        Igniter.rm(acc, path)
      else
        acc
      end
    end)
  end

  defp update_mishka_components_js(%{assigns: %{opts: %{keep_js: true}}} = igniter), do: igniter

  defp update_mishka_components_js(%{assigns: %{plan: %{js_modules_to_remove: []}}} = igniter),
    do: igniter

  defp update_mishka_components_js(igniter) do
    path = "assets/vendor/mishka_components.js"

    if Igniter.exists?(igniter, path) do
      verbose_log(igniter, "  Updating: #{path}")
      modules = Enum.map(igniter.assigns.plan.js_modules_to_remove, fn {m, _, _} -> m end)
      update_js_file(igniter, path, &remove_modules_from_js(&1, modules))
    else
      igniter
    end
  end

  defp remove_modules_from_js(content, modules) do
    Enum.reduce(modules, content, fn module, acc ->
      acc
      |> then(&with_js_result(JsParser.remove_imports(&1, module, :content), &1))
      |> then(&with_js_result(JsParser.remove_objects_from_hooks(&1, [module], :content), &1))
    end)
  end

  defp with_js_result({:ok, _, updated}, _), do: updated
  defp with_js_result(_, fallback), do: fallback

  defp update_app_js(%{assigns: %{plan: %{remaining: r}}} = igniter) when r != [], do: igniter
  defp update_app_js(%{assigns: %{opts: %{keep_js: true}}} = igniter), do: igniter

  defp update_app_js(igniter) do
    path = "assets/js/app.js"

    if Igniter.exists?(igniter, path) do
      verbose_log(igniter, "  Cleaning up: #{path}")
      update_js_file(igniter, path, &remove_modules_from_js(&1, ["MishkaComponents"]))
    else
      igniter
    end
  end

  defp maybe_remove_mishka_components_js(%{assigns: %{plan: %{remaining: r}}} = igniter)
       when r != [],
       do: igniter

  defp maybe_remove_mishka_components_js(%{assigns: %{opts: %{keep_js: true}}} = igniter),
    do: igniter

  defp maybe_remove_mishka_components_js(igniter) do
    path = "assets/vendor/mishka_components.js"

    if Igniter.exists?(igniter, path) do
      verbose_log(igniter, "  Removing: #{path}")
      Igniter.rm(igniter, path)
    else
      igniter
    end
  end

  defp update_js_file(igniter, path, transform_fn) do
    Igniter.update_file(igniter, path, fn source ->
      content = source |> Rewrite.Source.get(:content) |> transform_fn.()

      case JsFormatter.format(content) do
        {:ok, _, formatted} -> Rewrite.Source.update(source, :content, formatted)
        _ -> Rewrite.Source.update(source, :content, content)
      end
    end)
  end

  defp update_import_macro(igniter) do
    %{plan: plan, user_config: user_config} = igniter.assigns
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    path = get_mishka_components_path(igniter, web_module)

    if Igniter.exists?(igniter, path) do
      verbose_log(igniter, "  Updating import macro: #{path}")
      do_update_import_macro(igniter, path, plan, user_config[:module_prefix], web_module)
    else
      igniter
    end
  end

  defp get_mishka_components_path(igniter, web_module) do
    Module.concat([web_module, "Components", "MishkaComponents"])
    |> then(&Igniter.Project.Module.proper_location(igniter, &1))
  end

  defp do_update_import_macro(igniter, path, %{remaining: []}, _, _) do
    Igniter.rm(igniter, path)
  end

  defp do_update_import_macro(igniter, _path, plan, module_prefix, web_module) do
    modules_to_remove =
      Enum.map(plan.components, fn component ->
        build_module_name(web_module, component, module_prefix)
      end)

    Igniter.Project.Module.find_and_update_module!(
      igniter,
      Module.concat([web_module, "Components", "MishkaComponents"]),
      fn zipper ->
        remove_imports_from_using(zipper, modules_to_remove)
      end
    )
  end

  defp remove_imports_from_using(zipper, modules_to_remove) do
    # Find the quote block inside __using__ macro
    case find_quote_block(zipper) do
      {:ok, quote_zipper} ->
        new_zipper = remove_import_nodes(quote_zipper, modules_to_remove)
        {:ok, new_zipper}

      :error ->
        {:ok, zipper}
    end
  end

  defp find_quote_block(zipper) do
    # Search for the quote block in the AST
    case Sourceror.Zipper.find(zipper, fn node ->
           match?({:quote, _, [[{_, {:__block__, _, _}}]]}, node)
         end) do
      nil -> :error
      found -> {:ok, found}
    end
  end

  defp remove_import_nodes(zipper, modules_to_remove) do
    # Filter out import statements that match our modules
    case zipper.node do
      {:quote, quote_meta, [[{block_key, {:__block__, block_meta, statements}}]]} ->
        filtered_statements =
          Enum.reject(statements, fn
            {:import, _, [{:__aliases__, _, module_parts} | _]} ->
              module = Module.concat(module_parts)
              module in modules_to_remove

            {:import, _, [{:__MODULE__, _, _}, {:__aliases__, _, module_parts} | _]} ->
              module = Module.concat(module_parts)
              module in modules_to_remove

            _ ->
              false
          end)

        new_node =
          {:quote, quote_meta, [[{block_key, {:__block__, block_meta, filtered_statements}}]]}

        Igniter.Code.Common.replace_code(zipper, new_node)

      _ ->
        zipper
    end
  end

  defp maybe_cleanup_global_import(%{assigns: %{plan: %{remaining: r}}} = igniter)
       when r != [],
       do: igniter

  defp maybe_cleanup_global_import(igniter) do
    web_module = Igniter.Libs.Phoenix.web_module(igniter)

    case Igniter.Project.Module.find_and_update_module(
           igniter,
           web_module,
           &cleanup_html_helpers/1
         ) do
      {:ok, ig} -> ig
      {:error, ig} -> ig
    end
  end

  defp cleanup_html_helpers(zipper) do
    case Igniter.Code.Function.move_to_defp(zipper, :html_helpers, 0) do
      {:ok, z} -> {:ok, Igniter.Code.Common.replace_code(z, filter_mishka_use(z.node))}
      :error -> {:ok, zipper}
    end
  end

  # Check if the last part of the module path is MishkaComponents
  # e.g., ChelePrefixWeb.Components.MishkaComponents ->
  # [:ChelePrefixWeb, :Components, :MishkaComponents]
  defp filter_mishka_use({:quote, meta, [[{block_meta, {:__block__, inner_meta, args}}]]}) do
    filtered =
      Enum.reject(args, fn
        {:use, _, [{:__aliases__, _, module_parts}]} when is_list(module_parts) ->
          case List.last(module_parts) do
            name when is_atom(name) ->
              Atom.to_string(name) |> String.contains?("MishkaComponents")

            _ ->
              false
          end

        _ ->
          false
      end)

    {:quote, meta, [[{block_meta, {:__block__, inner_meta, filtered}}]]}
  end

  defp filter_mishka_use(other), do: other

  defp maybe_remove_css(%{assigns: %{plan: %{remaining: r}}} = igniter) when r != [], do: igniter

  defp maybe_remove_css(%{assigns: %{opts: %{all: false, include_css: false}}} = igniter),
    do: igniter

  defp maybe_remove_css(igniter) do
    path = "assets/vendor/mishka_chelekom.css"

    if Igniter.exists?(igniter, path) do
      verbose_log(igniter, "  Removing CSS: #{path}")
      igniter |> Igniter.rm(path) |> clean_app_css()
    else
      igniter
    end
  end

  defp clean_app_css(igniter) do
    path = "assets/css/app.css"

    if Igniter.exists?(igniter, path) do
      Igniter.update_file(igniter, path, fn source ->
        content =
          source
          |> Rewrite.Source.get(:content)
          |> String.replace(~r/@import\s+["']\.\.\/vendor\/mishka_chelekom\.css["'];?\n?/, "")

        Rewrite.Source.update(source, :content, content)
      end)
    else
      igniter
    end
  end

  defp maybe_remove_config(%{assigns: %{plan: %{remaining: r}}} = igniter) when r != [],
    do: igniter

  defp maybe_remove_config(%{assigns: %{opts: %{all: false, include_config: false}}} = igniter),
    do: igniter

  defp maybe_remove_config(igniter) do
    path = "priv/mishka_chelekom/config.exs"

    if Igniter.exists?(igniter, path) do
      verbose_log(igniter, "  Removing config: #{path}")
      igniter |> Igniter.rm(path) |> remove_empty_priv_dir()
    else
      igniter
    end
  end

  defp remove_empty_priv_dir(igniter) do
    dir = "priv/mishka_chelekom"

    with true <- File.dir?(dir),
         {:ok, []} <- File.ls(dir) do
      File.rmdir(dir)
    end

    igniter
  end

  defp add_completion_notice(igniter) do
    %{plan: plan, opts: opts} = igniter.assigns
    all_removed = plan.remaining == []

    stats = %{
      removed: length(plan.component_files),
      js_removed: length(plan.js_to_remove),
      preserved: if(plan.js_preserved != [], do: "\nJS preserved: #{length(plan.js_preserved)}"),
      css: if(all_removed && (opts.all || opts.include_css), do: "\nCSS removed"),
      config: if(all_removed && (opts.all || opts.include_config), do: "\nConfig removed"),
      remaining: if(!all_removed, do: "\nRemaining: #{length(plan.remaining)}")
    }

    Igniter.add_notice(igniter, """
    Uninstall complete!

    Components removed: #{stats.removed}
    JS files removed: #{stats.js_removed}#{stats.preserved}#{stats.css}#{stats.config}#{stats.remaining}

    #{if all_removed, do: "All Mishka components removed.", else: "Run --all to remove everything."}
    """)
  end

  defp verbose_log(%{assigns: %{opts: %{verbose: true}}}, msg) do
    if Mix.env() != :test, do: IO.puts(msg)
  end

  defp verbose_log(_, _), do: :ok

  def supports_umbrella?(), do: false
end
