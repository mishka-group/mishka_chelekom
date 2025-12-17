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

      mix mishka.ui.uninstall accordion
      mix mishka.ui.uninstall accordion,button,alert
      mix mishka.ui.uninstall --all
      mix mishka.ui.uninstall accordion --dry-run
      mix mishka.ui.uninstall accordion --yes
      mix mishka.ui.uninstall --all --include-css --include-config --yes

  ## Options

  * `--all` or `-a` - Remove all installed Mishka components
  * `--dry-run` or `-d` - Preview what would be removed without making changes
  * `--yes` or `-y` - Skip confirmation prompts
  * `--include-css` - Also remove CSS files (only with --all)
  * `--include-config` - Also remove the config file (only with --all)
  * `--keep-js` - Keep JavaScript files even if no components use them
  * `--verbose` or `-V` - Show detailed output of all operations
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
        include_css: :boolean,
        include_config: :boolean,
        keep_js: :boolean,
        verbose: :boolean
      ],
      aliases: [a: :all, d: :dry_run, V: :verbose]
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
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    web_parts = Module.split(web_module)
    user_config = igniter.assigns.user_config
    module_prefix = user_config[:module_prefix]
    known = get_known_component_names(igniter)

    {igniter, modules} =
      Igniter.Project.Module.find_all_matching_modules(igniter, fn module, _zipper ->
        mishka_component?(module, web_parts, module_prefix, known)
      end)

    components =
      modules
      |> Enum.map(&extract_component_name(&1, web_parts, module_prefix))
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    Igniter.assign(igniter, :components, components)
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

  defp get_known_component_names(igniter) do
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

  defp list_component_files(path),
    do: if(File.dir?(path), do: Path.wildcard(Path.join(path, "*.exs")), else: [])

  defp component_source?(source, paths) do
    path = Rewrite.Source.get(source, :path)
    String.ends_with?(path, ".exs") and Enum.any?(paths, &String.starts_with?(path, &1))
  end

  defp process_uninstall(igniter) do
    igniter
    |> build_removal_plan()
    |> maybe_show_plan()
    |> execute_or_cancel()
  end

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
  defp should_proceed?(%{yes: true}), do: true
  defp should_proceed?(_), do: Mix.env() == :test or confirm_removal()

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

    configs = Map.new(components, &{&1, get_component_config(igniter, &1)})
    {igniter, all_installed} = get_all_installed(igniter)
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
      configs: configs,
      js_to_remove: js_to_remove,
      js_preserved: js_to_consider -- js_to_remove,
      js_modules_to_remove: extract_js_modules(configs, js_to_remove),
      remaining: remaining,
      warnings: find_dependency_warnings(igniter, remaining, components),
      web_module: web_module,
      module_prefix: module_prefix
    }

    Igniter.assign(igniter, :plan, plan)
  end

  defp get_all_installed(igniter) do
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    web_parts = Module.split(web_module)
    user_config = igniter.assigns.user_config
    module_prefix = user_config[:module_prefix]
    known = get_known_component_names(igniter)

    {igniter, modules} =
      Igniter.Project.Module.find_all_matching_modules(igniter, fn module, _zipper ->
        mishka_component?(module, web_parts, module_prefix, known)
      end)

    components =
      modules
      |> Enum.map(&extract_component_name(&1, web_parts, module_prefix))
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    {igniter, components}
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
    print_js_section("JavaScript files to remove:", plan.js_to_remove, IO.ANSI.red())
    print_js_section("JavaScript files preserved:", plan.js_preserved, IO.ANSI.green())
    print_warnings(plan.warnings)
    print_remaining(plan.remaining)

    IO.puts("")
  end

  defp print_component_status({component, path, exists?, module}) do
    status = if exists?, do: IO.ANSI.green() <> "✓", else: IO.ANSI.red() <> "✗ (not found)"
    IO.puts("  #{status} #{component}#{IO.ANSI.reset()} - #{path || "unknown"}")
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
      "\n#{IO.ANSI.yellow()}#{IO.ANSI.bright()}⚠ Warning: Components depend on removed items:#{IO.ANSI.reset()}"
    )

    Enum.each(warnings, fn {component, deps} ->
      IO.puts("  #{IO.ANSI.yellow()}• #{component} → #{Enum.join(deps, ", ")}#{IO.ANSI.reset()}")
    end)
  end

  defp print_remaining([]), do: :ok

  defp print_remaining(components) do
    IO.puts("\n#{IO.ANSI.bright()}Remaining components:#{IO.ANSI.reset()}")
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

  defp do_update_import_macro(igniter, path, %{remaining: []}, _, _),
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

  defp maybe_remove_css(%{assigns: %{opts: %{all: false}}} = igniter), do: igniter
  defp maybe_remove_css(%{assigns: %{opts: %{include_css: false}}} = igniter), do: igniter
  defp maybe_remove_css(%{assigns: %{plan: %{remaining: r}}} = igniter) when r != [], do: igniter

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

  defp maybe_remove_config(%{assigns: %{opts: %{all: false}}} = igniter), do: igniter
  defp maybe_remove_config(%{assigns: %{opts: %{include_config: false}}} = igniter), do: igniter

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

    stats = %{
      removed: length(plan.component_files),
      js_removed: length(plan.js_to_remove),
      preserved: if(plan.js_preserved != [], do: "\nJS preserved: #{length(plan.js_preserved)}"),
      css: if(opts.all && opts.include_css && plan.remaining == [], do: "\nCSS removed"),
      config: if(opts.all && opts.include_config, do: "\nConfig removed"),
      remaining: if(plan.remaining != [], do: "\nRemaining: #{length(plan.remaining)}")
    }

    Igniter.add_notice(igniter, """
    Uninstall complete!

    Components removed: #{stats.removed}
    JS files removed: #{stats.js_removed}#{stats.preserved}#{stats.css}#{stats.config}#{stats.remaining}

    #{if plan.remaining == [], do: "All Mishka components removed.", else: "Run --all to remove everything."}
    """)
  end

  defp verbose_log(%{assigns: %{opts: %{verbose: true}}}, msg) do
    if Mix.env() != :test, do: IO.puts(msg)
  end

  defp verbose_log(_, _), do: :ok

  def supports_umbrella?(), do: false
end
