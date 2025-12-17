defmodule Mix.Tasks.Mishka.Ui.Uninstall do
  @moduledoc """
  A Mix Task for uninstalling Mishka Chelekom components from a Phoenix project.

  This task safely removes components while handling shared dependencies like JavaScript hooks.
  When multiple components share the same JS hook, it will only be removed when the last
  component using it is uninstalled.

  ## Features

  - Remove single component or all components at once
  - Smart JS hook management (preserves shared hooks)
  - Respects module_prefix configuration
  - Cleans up import macro file (MishkaComponents)
  - Optional CSS cleanup
  - Dry-run mode for safe preview
  - Interactive confirmation or force mode

  ## Examples

  Remove a single component:
  ```bash
  mix mishka.ui.uninstall accordion
  ```

  Remove multiple components:
  ```bash
  mix mishka.ui.uninstall accordion,button,alert
  ```

  Remove all installed components:
  ```bash
  mix mishka.ui.uninstall --all
  ```

  Preview what would be removed (dry-run):
  ```bash
  mix mishka.ui.uninstall accordion --dry-run
  ```

  Force removal without confirmation:
  ```bash
  mix mishka.ui.uninstall accordion --yes
  ```

  Remove component and its CSS (only when removing all):
  ```bash
  mix mishka.ui.uninstall --all --include-css
  ```

  ## Options

  * `--all` or `-a` - Remove all installed Mishka components
  * `--dry-run` or `-d` - Preview what would be removed without making changes
  * `--yes` or `-y` - Skip confirmation prompts
  * `--include-css` - Also remove CSS files (only with --all)
  * `--include-config` - Also remove the config file (only with --all)
  * `--keep-js` - Keep JavaScript files even if no components use them
  * `--verbose` or `-V` - Show detailed output of all operations

  ## Notes

  - JavaScript hooks are only removed when no other installed component uses them
  - The import macro file (MishkaComponents) is updated to remove deleted component imports
  - Component dependencies are NOT automatically removed (e.g., removing accordion won't remove icon)
  """

  use Igniter.Mix.Task
  alias Igniter.Project.Application, as: IAPP
  alias IgniterJs.Parsers.Javascript.Parser, as: JsParser
  alias IgniterJs.Parsers.Javascript.Formatter, as: JsFormatter
  alias Mix.Tasks.Mishka.Ui.Gen.Component, as: GenComponent
  alias MishkaChelekom.Config

  @example "mix mishka.ui.uninstall accordion"
  @shortdoc "Uninstall Mishka Chelekom components from your Phoenix project"

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
        yes: :boolean,
        include_css: :boolean,
        include_config: :boolean,
        keep_js: :boolean,
        verbose: :boolean
      ],
      aliases: [a: :all, d: :dry_run, y: :yes, V: :verbose]
    }
  end

  def igniter(igniter) do
    %{options: options, positional: %{components: components_arg}} = igniter.args
    opts = build_opts(options)

    if !opts.dry_run && Mix.env() != :test, do: print_banner()

    user_config = Config.load_user_config(igniter)
    igniter = Igniter.assign(igniter, %{mishka_user_config: user_config})

    igniter
    |> parse_components(components_arg, opts, user_config)
    |> handle_uninstall(user_config, opts)
  end

  defp build_opts(options) do
    %{
      verbose: options[:verbose] == true,
      dry_run: options[:dry_run] == true,
      yes: options[:yes] == true,
      all: options[:all] == true,
      keep_js: options[:keep_js] == true,
      include_css: options[:include_css] == true,
      include_config: options[:include_config] == true
    }
  end

  defp parse_components(igniter, _arg, %{all: true}, user_config),
    do: find_all_installed_components(igniter, user_config)

  defp parse_components(igniter, arg, _opts, _config) when is_binary(arg) and arg != "",
    do: {igniter, String.split(arg, ",", trim: true)}

  defp parse_components(igniter, _arg, _opts, _config) do
    {Igniter.add_issue(igniter, """
     Please specify components to uninstall or use --all flag.

     Examples:
       mix mishka.ui.uninstall accordion
       mix mishka.ui.uninstall accordion,button,alert
       mix mishka.ui.uninstall --all
     """), []}
  end

  defp handle_uninstall({%{issues: issues} = igniter, _}, _, _) when issues != [], do: igniter

  defp handle_uninstall({igniter, []}, _, _),
    do: Igniter.add_notice(igniter, "No Mishka components found to uninstall.")

  defp handle_uninstall({igniter, components}, user_config, opts),
    do: process_uninstall(igniter, components, user_config, opts)

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

  defp find_all_installed_components(igniter, user_config) do
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    web_parts = Module.split(web_module)
    module_prefix = user_config[:module_prefix]
    known = get_all_known_component_names(igniter)

    {igniter, modules} =
      Igniter.Project.Module.find_all_matching_modules(igniter, fn module, _zipper ->
        mishka_component?(module, web_parts, module_prefix, known)
      end)

    components =
      modules
      |> Enum.map(&extract_component_name(&1, web_parts, module_prefix))
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    {Igniter.assign(igniter, :mishka_component_modules, modules), components}
  end

  defp mishka_component?(module, web_parts, module_prefix, known) do
    parts = Module.split(module)

    with true <- length(parts) > length(web_parts),
         true <- List.starts_with?(parts, web_parts),
         ["Components", name | _] <- Enum.drop(parts, length(web_parts)) do
      name |> Macro.underscore() |> strip_prefix(module_prefix) |> then(&(&1 in known))
    else
      _ -> false
    end
  end

  defp extract_component_name(module, web_parts, module_prefix) do
    case module |> Module.split() |> Enum.drop(length(web_parts)) do
      ["Components", name | _] -> name |> Macro.underscore() |> strip_prefix(module_prefix)
      _ -> nil
    end
  end

  defp strip_prefix(name, prefix) when is_binary(prefix) and prefix != "",
    do: String.trim_leading(name, prefix)

  defp strip_prefix(name, _), do: name

  defp get_all_known_component_names(igniter) do
    paths = component_search_paths(igniter)

    real =
      paths
      |> Enum.flat_map(&list_component_files/1)
      |> Enum.map(&Path.basename(&1, ".exs"))

    virtual =
      igniter.rewrite
      |> Rewrite.sources()
      |> Enum.filter(&component_source?(&1, paths))
      |> Enum.map(&(&1 |> Rewrite.Source.get(:path) |> Path.basename(".exs")))

    Enum.uniq(real ++ virtual)
  end

  defp component_search_paths(igniter) do
    [
      "deps/mishka_chelekom/priv/components",
      IAPP.priv_dir(igniter, ["mishka_chelekom", "components"]),
      IAPP.priv_dir(igniter, ["mishka_chelekom", "templates"]),
      IAPP.priv_dir(igniter, ["mishka_chelekom", "presets"])
    ]
  end

  defp list_component_files(path) do
    if File.dir?(path), do: Path.wildcard(Path.join(path, "*.exs")), else: []
  end

  defp component_source?(source, paths) do
    path = Rewrite.Source.get(source, :path)
    String.ends_with?(path, ".exs") and Enum.any?(paths, &String.starts_with?(path, &1))
  end

  defp process_uninstall(igniter, components, user_config, opts) do
    {igniter, plan} = build_removal_plan(igniter, components, user_config)

    if should_show_plan?(opts), do: show_removal_plan(plan, opts.dry_run)

    if should_proceed?(opts) do
      igniter
      |> remove_component_files(plan, opts)
      |> remove_js_files(plan, opts)
      |> update_mishka_components_js(plan, opts)
      |> maybe_remove_mishka_components_js(plan, opts)
      |> update_app_js(plan, opts)
      |> update_import_macro(plan, user_config, opts)
      |> maybe_cleanup_global_import(plan)
      |> maybe_remove_css(plan, opts)
      |> maybe_remove_config(opts)
      |> add_completion_notice(plan, opts)
    else
      add_cancel_notice(igniter, opts)
    end
  end

  defp should_show_plan?(%{dry_run: true}), do: Mix.env() != :test
  defp should_show_plan?(%{verbose: true}), do: Mix.env() != :test
  defp should_show_plan?(%{yes: false}), do: Mix.env() != :test
  defp should_show_plan?(_), do: false

  defp should_proceed?(%{dry_run: true}), do: false
  defp should_proceed?(%{yes: true}), do: true
  defp should_proceed?(_), do: Mix.env() == :test or confirm_removal()

  defp add_cancel_notice(igniter, %{dry_run: true}) do
    Igniter.add_notice(igniter, """

    Dry-run complete. No files were modified.
    Run without --dry-run to perform the actual uninstall.
    """)
  end

  defp add_cancel_notice(igniter, _), do: Igniter.add_notice(igniter, "Uninstall cancelled.")

  defp build_removal_plan(igniter, components, user_config) do
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    module_prefix = user_config[:module_prefix]

    configs = Map.new(components, &{&1, get_component_config(igniter, &1)})
    {igniter, all_installed} = find_all_installed_components(igniter, user_config)
    remaining = all_installed -- components

    js_to_consider = extract_js_files(configs)

    js_still_needed =
      remaining |> Map.new(&{&1, get_component_config(igniter, &1)}) |> extract_js_files()

    js_to_remove = js_to_consider -- js_still_needed

    {igniter, component_files} =
      resolve_component_files(igniter, components, web_module, module_prefix)

    plan = %{
      components: components,
      component_files: component_files,
      component_configs: configs,
      js_files_to_remove: js_to_remove,
      js_files_preserved: js_to_consider -- js_to_remove,
      js_modules_to_remove: extract_js_modules(configs, js_to_remove),
      remaining_components: remaining,
      dependency_warnings: find_dependency_warnings(igniter, remaining, components),
      web_module: web_module,
      module_prefix: module_prefix
    }

    {igniter, plan}
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

  defp find_dependency_warnings(igniter, remaining, removing) do
    Enum.flat_map(remaining, fn component ->
      case get_component_config(igniter, component) do
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

  defp get_component_config(igniter, component) do
    component_search_paths(igniter)
    |> Enum.map(&Path.join(&1, "#{component}.exs"))
    |> Enum.find_value(&read_config(igniter, &1, component))
  end

  defp read_config(igniter, path, component) do
    cond do
      Igniter.exists?(igniter, path) -> read_virtual_config(igniter, path, component)
      File.exists?(path) -> read_file_config(path, component)
      true -> nil
    end
  end

  defp read_virtual_config(igniter, path, component) do
    case Rewrite.source(igniter.rewrite, path) do
      {:ok, source} ->
        content = Rewrite.Source.get(source, :content)
        {config, _} = Code.eval_string(content)
        Keyword.get(config, String.to_atom(component))

      _ ->
        nil
    end
  rescue
    _ -> nil
  end

  defp read_file_config(path, component) do
    config = Elixir.Config.Reader.read!(path)
    Keyword.get(config, String.to_atom(component))
  rescue
    _ -> nil
  end

  defp show_removal_plan(plan, dry_run) do
    header = if dry_run, do: "=== DRY RUN - Removal Plan ===", else: "=== Removal Plan ==="
    color = if dry_run, do: IO.ANSI.cyan(), else: IO.ANSI.yellow()

    IO.puts("\n#{color}#{header}#{IO.ANSI.reset()}\n")
    IO.puts("#{IO.ANSI.bright()}Components to remove:#{IO.ANSI.reset()}")

    Enum.each(plan.component_files, &print_component_status/1)

    print_js_section("JavaScript files to remove:", plan.js_files_to_remove, IO.ANSI.red())

    print_js_section(
      "JavaScript files preserved (used by other components):",
      plan.js_files_preserved,
      IO.ANSI.green()
    )

    print_warnings(plan.dependency_warnings)
    print_remaining(plan.remaining_components)

    IO.puts("")
  end

  defp print_component_status({component, path, exists?, module}) do
    status = if exists?, do: IO.ANSI.green() <> "✓", else: IO.ANSI.red() <> "✗ (not found)"
    IO.puts("  #{status} #{component}#{IO.ANSI.reset()} - #{path || "unknown location"}")
    IO.puts("    Module: #{inspect(module)}")
  end

  defp print_js_section(_, [], _), do: :ok

  defp print_js_section(title, files, color) do
    IO.puts("\n#{IO.ANSI.bright()}#{title}#{IO.ANSI.reset()}")
    Enum.each(files, &IO.puts("  #{color}• assets/vendor/#{&1}#{IO.ANSI.reset()}"))
  end

  defp print_warnings([]), do: :ok

  defp print_warnings(warnings) do
    IO.puts(
      "\n#{IO.ANSI.yellow()}#{IO.ANSI.bright()}⚠ Warning: The following components depend on components being removed:#{IO.ANSI.reset()}"
    )

    Enum.each(warnings, fn {component, deps} ->
      IO.puts(
        "  #{IO.ANSI.yellow()}• #{component} depends on: #{Enum.join(deps, ", ")}#{IO.ANSI.reset()}"
      )
    end)

    IO.puts(
      "  #{IO.ANSI.yellow()}These components may not work correctly after removal.#{IO.ANSI.reset()}"
    )
  end

  defp print_remaining([]), do: :ok

  defp print_remaining(components) do
    IO.puts("\n#{IO.ANSI.bright()}Components that will remain installed:#{IO.ANSI.reset()}")
    IO.puts("  #{IO.ANSI.cyan()}#{Enum.join(components, ", ")}#{IO.ANSI.reset()}")
  end

  defp confirm_removal do
    IO.puts(
      "#{IO.ANSI.yellow()}Are you sure you want to proceed with the uninstall?#{IO.ANSI.reset()}"
    )

    "Type 'yes' to confirm: "
    |> IO.gets()
    |> String.trim()
    |> String.downcase()
    |> then(&(&1 in ["yes", "y"]))
  end

  defp remove_component_files(igniter, plan, opts) do
    Enum.reduce(plan.component_files, igniter, fn file_info, acc ->
      do_remove_component(acc, file_info, opts)
    end)
  end

  defp do_remove_component(igniter, {_, path, true, module}, opts) when not is_nil(path) do
    verbose_log(opts, "  Removing: #{path} (#{inspect(module)})")
    Igniter.rm(igniter, path)
  end

  defp do_remove_component(igniter, {_, path, false, module}, opts) do
    verbose_log(opts, "  Skipping (not found): #{path || "unknown"} (#{inspect(module)})")
    igniter
  end

  defp remove_js_files(igniter, _plan, %{keep_js: true}), do: igniter

  defp remove_js_files(igniter, plan, opts) do
    Enum.reduce(plan.js_files_to_remove, igniter, fn file, acc ->
      path = "assets/vendor/#{file}"

      if Igniter.exists?(acc, path) do
        verbose_log(opts, "  Removing JS: #{path}")
        Igniter.rm(acc, path)
      else
        acc
      end
    end)
  end

  defp update_mishka_components_js(igniter, _plan, %{keep_js: true}), do: igniter
  defp update_mishka_components_js(igniter, %{js_modules_to_remove: []}, _opts), do: igniter

  defp update_mishka_components_js(igniter, plan, opts) do
    path = "assets/vendor/mishka_components.js"

    if Igniter.exists?(igniter, path) do
      verbose_log(opts, "  Updating: #{path}")
      update_js_file(igniter, path, &remove_js_modules(&1, plan.js_modules_to_remove))
    else
      igniter
    end
  end

  defp remove_js_modules(content, modules) do
    modules
    |> Enum.map(fn {module, _, _} -> module end)
    |> Enum.reduce(content, &remove_module_from_js/2)
  end

  defp remove_module_from_js(module, content) do
    content
    |> then(&with_js_result(JsParser.remove_imports(&1, module, :content), &1))
    |> then(&with_js_result(JsParser.remove_objects_from_hooks(&1, [module], :content), &1))
  end

  defp with_js_result({:ok, _, updated}, _fallback), do: updated
  defp with_js_result(_, fallback), do: fallback

  defp update_app_js(igniter, %{remaining_components: remaining}, _opts) when remaining != [],
    do: igniter

  defp update_app_js(igniter, _plan, %{keep_js: true}), do: igniter

  defp update_app_js(igniter, _plan, opts) do
    path = "assets/js/app.js"

    if Igniter.exists?(igniter, path) do
      verbose_log(opts, "  Cleaning up: #{path}")
      update_js_file(igniter, path, &remove_module_from_js("MishkaComponents", &1))
    else
      igniter
    end
  end

  defp maybe_remove_mishka_components_js(igniter, %{remaining_components: remaining}, _)
       when remaining != [],
       do: igniter

  defp maybe_remove_mishka_components_js(igniter, _plan, %{keep_js: true}), do: igniter

  defp maybe_remove_mishka_components_js(igniter, _plan, opts) do
    path = "assets/vendor/mishka_components.js"

    if Igniter.exists?(igniter, path) do
      verbose_log(opts, "  Removing: #{path}")
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

  defp update_import_macro(igniter, plan, user_config, opts) do
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    path = get_mishka_components_path(igniter, web_module)

    if Igniter.exists?(igniter, path) do
      verbose_log(opts, "  Updating import macro: #{path}")
      do_update_import_macro(igniter, path, plan, user_config[:module_prefix], web_module)
    else
      igniter
    end
  end

  defp get_mishka_components_path(igniter, web_module) do
    Module.concat([web_module, "Components", "MishkaComponents"])
    |> then(&Igniter.Project.Module.proper_location(igniter, &1))
  end

  defp do_update_import_macro(igniter, path, %{remaining_components: []}, _, _),
    do: Igniter.rm(igniter, path)

  defp do_update_import_macro(igniter, path, plan, module_prefix, web_module) do
    Igniter.update_file(igniter, path, fn source ->
      content =
        Enum.reduce(plan.components, Rewrite.Source.get(source, :content), fn component, acc ->
          remove_component_import(acc, component, module_prefix, web_module)
        end)

      Rewrite.Source.update(source, :content, content)
    end)
  end

  defp remove_component_import(content, component, prefix, web_module) do
    name = if prefix && prefix != "", do: "#{prefix}#{component}", else: component

    module =
      name
      |> String.split("_")
      |> Enum.map(&String.capitalize/1)
      |> Enum.join()

    content
    |> String.replace(~r/\s*import\s+#{inspect(web_module)}\.Components\.#{module}[^\n]*\n/, "\n")
    |> String.replace(~r/\n{3,}/, "\n\n")
  end

  defp maybe_cleanup_global_import(igniter, %{remaining_components: remaining})
       when remaining != [],
       do: igniter

  defp maybe_cleanup_global_import(igniter, _plan) do
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

  defp filter_mishka_use({:quote, meta, [[{block_meta, {:__block__, inner_meta, args}}]]}) do
    filtered =
      Enum.reject(args, fn
        {:use, _, [{:__aliases__, _, [name]}]} when is_atom(name) ->
          name |> Atom.to_string() |> String.contains?("MishkaComponents")

        _ ->
          false
      end)

    {:quote, meta, [[{block_meta, {:__block__, inner_meta, filtered}}]]}
  end

  defp filter_mishka_use(other), do: other

  defp maybe_remove_css(igniter, _, %{all: false}), do: igniter
  defp maybe_remove_css(igniter, _, %{include_css: false}), do: igniter
  defp maybe_remove_css(igniter, %{remaining_components: r}, _) when r != [], do: igniter

  defp maybe_remove_css(igniter, _plan, opts) do
    path = "assets/vendor/mishka_chelekom.css"

    if Igniter.exists?(igniter, path) do
      verbose_log(opts, "  Removing CSS: #{path}")
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

  defp maybe_remove_config(igniter, %{all: false}), do: igniter
  defp maybe_remove_config(igniter, %{include_config: false}), do: igniter

  defp maybe_remove_config(igniter, opts) do
    path = "priv/mishka_chelekom/config.exs"

    if Igniter.exists?(igniter, path) do
      verbose_log(opts, "  Removing config: #{path}")
      igniter |> Igniter.rm(path) |> remove_empty_priv_dir()
    else
      igniter
    end
  end

  defp remove_empty_priv_dir(igniter) do
    dir = "priv/mishka_chelekom"

    with true <- File.dir?(dir), {:ok, []} <- File.ls(dir) do
      File.rmdir(dir)
    end

    igniter
  end

  defp add_completion_notice(igniter, plan, opts) do
    stats = build_stats(plan, opts)

    Igniter.add_notice(igniter, """
    Uninstall complete!

    Components removed: #{stats.removed}
    JavaScript files removed: #{stats.js_removed}#{stats.preserved}#{stats.css}#{stats.config}#{stats.remaining}

    #{stats.completion}
    """)
  end

  defp build_stats(plan, opts) do
    %{
      removed: length(plan.component_files),
      js_removed: length(plan.js_files_to_remove),
      preserved: stat_line(plan.js_files_preserved, "JavaScript files preserved (still in use)"),
      css:
        stat_flag(
          opts.all and opts.include_css and plan.remaining_components == [],
          "CSS files removed"
        ),
      config: stat_flag(opts.all and opts.include_config, "Configuration file removed"),
      remaining: stat_line(plan.remaining_components, "Remaining installed components"),
      completion: completion_text(plan.remaining_components)
    }
  end

  defp stat_line([], _), do: ""
  defp stat_line(list, label), do: "\n#{label}: #{length(list)}"

  defp stat_flag(true, label), do: "\n#{label}"
  defp stat_flag(false, _), do: ""

  defp completion_text([]),
    do: "All Mishka components have been removed from your project."

  defp completion_text(_),
    do:
      "Some components remain installed. Run 'mix mishka.ui.uninstall --all' to remove everything."

  defp verbose_log(%{verbose: true}, msg), do: if(Mix.env() != :test, do: IO.puts(msg))
  defp verbose_log(_, _), do: :ok

  def supports_umbrella?(), do: false
end
