defmodule Mix.Tasks.Mishka.Ui.Uninstall do
  use Igniter.Mix.Task
  alias IgniterJs.Parsers.Javascript.Parser, as: JsParser
  alias IgniterJs.Parsers.Javascript.Formatter, as: JsFormatter
  alias MishkaChelekom.Generators.Core
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

  * `--all` or `-a` - Remove all installed Mishka components. Without `--headless` this
    removes **both** styled and headless components; combine with `--headless` to remove
    only headless ones.
  * `--headless` - Target headless components (`lib/<app>_web/components/headless/`) instead
    of styled ones, e.g. `mix mishka.ui.uninstall accordion --headless`.
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
      group: :mishka_chelekom,
      composes: [],
      schema: [
        all: :boolean,
        include_npm: :boolean,
        headless: :boolean,
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

    tty? = IO.ANSI.enabled?()

    if !options[:dry_run] && Mix.env() != :test && tty? do
      Application.ensure_all_started(:owl)
      print_banner()
      Owl.Spinner.start(id: :uninstall_spinner, labels: [processing: "Processing uninstall..."])
    end

    result =
      igniter
      |> Igniter.assign(:opts, build_opts(options))
      |> Igniter.assign(:user_config, Config.load_user_config(igniter))
      |> parse_components(components_arg)
      |> handle_uninstall()

    if !options[:dry_run] && Mix.env() != :test && tty? do
      if Map.get(result, :issues, []) == [],
        do: Owl.Spinner.stop(id: :uninstall_spinner, resolution: :ok, label: "Done"),
        else: Owl.Spinner.stop(id: :uninstall_spinner, resolution: :error, label: "Error")
    end

    result
  end

  defp build_opts(options) do
    %{
      verbose: options[:verbose] == true,
      dry_run: options[:dry_run] == true,
      yes: options[:yes] == true,
      force: options[:force] == true,
      all: options[:all] == true,
      headless: options[:headless] == true,
      keep_js: options[:keep_js] == true,
      include_css: options[:include_css] == true,
      include_config: options[:include_config] == true
    }
  end

  # `--all` gathers every installed component. Without `--headless` that spans both
  # styled and headless; with it, only headless.
  defp parse_components(%{assigns: %{opts: %{all: true} = opts}} = igniter, _arg) do
    kinds = if opts.headless, do: [:headless], else: [:styled, :headless]
    components = Enum.flat_map(kinds, &list_installed_components(igniter, &1))
    Igniter.assign(igniter, :components, components)
  end

  # Named components are tagged with the kind chosen by `--headless`.
  defp parse_components(%{assigns: %{opts: opts}} = igniter, arg)
       when is_binary(arg) and arg != "" do
    kind = if opts.headless, do: :headless, else: :styled
    components = arg |> String.split(",", trim: true) |> Enum.map(&{&1, kind})
    Igniter.assign(igniter, :components, components)
  end

  defp parse_components(igniter, _arg) do
    Igniter.add_issue(igniter, """
    Please specify components to uninstall or use --all flag.

    Examples:
      mix mishka.ui.uninstall accordion
      mix mishka.ui.uninstall accordion,button,alert
      mix mishka.ui.uninstall accordion --headless
      mix mishka.ui.uninstall --all
    """)
  end

  defp handle_uninstall(%{issues: issues} = igniter) when issues != [], do: igniter

  defp handle_uninstall(%{assigns: %{components: []}} = igniter),
    do: Igniter.add_notice(igniter, "No Mishka components found to uninstall.")

  defp handle_uninstall(%{assigns: %{components: nil}} = igniter), do: igniter

  defp handle_uninstall(igniter), do: process_uninstall(igniter)

  defp print_banner, do: Core.banner(IO.ANSI.magenta(), "Uninstall")

  defp all_installed_components(igniter) do
    Enum.flat_map([:styled, :headless], &list_installed_components(igniter, &1))
  end

  defp list_installed_components(igniter, kind) do
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    module_prefix = igniter.assigns.user_config[:module_prefix]
    known = get_known_component_names(kind)
    components_dir = get_components_dir(igniter, web_module, kind)

    real_files =
      components_dir
      |> Path.join("*.ex")
      |> Path.wildcard()

    # `Path.dirname/1 == components_dir` keeps the scan single-level, so the styled
    # directory doesn't sweep up files living under its `headless/` subfolder.
    virtual_files =
      igniter.rewrite
      |> Rewrite.sources()
      |> Enum.map(&Rewrite.Source.get(&1, :path))
      |> Enum.filter(&(Path.dirname(&1) == components_dir))
      |> Enum.filter(&String.ends_with?(&1, ".ex"))

    (real_files ++ virtual_files)
    |> Enum.uniq()
    |> Enum.map(&Path.basename(&1, ".ex"))
    |> Enum.map(&Macro.underscore/1)
    |> Enum.map(&strip_prefix(&1, module_prefix))
    |> Enum.filter(&(&1 in known))
    |> Enum.uniq()
    |> Enum.map(&{&1, kind})
  end

  defp strip_prefix(name, prefix) when is_binary(prefix) and prefix != "",
    do: String.trim_leading(name, prefix)

  defp strip_prefix(name, _), do: name

  defp get_known_component_names(kind) do
    config_paths(kind)
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
          - Also remove the dependent components: #{Enum.map_join(dependent_components, ",", &label/1)}
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
      IO.puts(
        "  #{IO.ANSI.yellow()}• #{label(comp)}#{IO.ANSI.reset()} uses: #{Enum.join(deps, ", ")}"
      )
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
      "  • #{label(comp)} depends on: #{Enum.join(deps, ", ")}"
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
      |> remove_npm_deps()
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

  defp add_cancel_notice(igniter) do
    Igniter.add_notice(igniter, """

    Dry-run complete. No files were modified.
    Run without --dry-run to perform the actual uninstall.
    """)
  end

  defp build_removal_plan(igniter) do
    %{components: components, user_config: user_config} = igniter.assigns
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    module_prefix = user_config[:module_prefix]

    all_configs = load_all_configs()
    # Everything installed across both kinds — so JS/CSS/config shared by a component of
    # the *other* kind is preserved even when this run only targets one kind.
    all_installed = all_installed_components(igniter)
    remaining = all_installed -- components

    configs_to_remove = Map.new(components, &{&1, Map.get(all_configs, &1)})
    configs_remaining = Map.new(remaining, &{&1, Map.get(all_configs, &1)})

    js_to_consider = extract_js_files(configs_to_remove)
    js_still_needed = extract_js_files(configs_remaining)
    js_to_remove = js_to_consider -- js_still_needed

    # Same refcount for npm packages — but assets/package.json is the USER's file, so a package is
    # only ever removed when no remaining component declares it AND the pinned version still
    # matches ours (see removable_npm/1).
    npm_to_consider = extract_npm_deps(configs_to_remove)
    npm_to_remove = npm_to_consider -- extract_npm_deps(configs_remaining)

    {igniter, component_files} =
      resolve_component_files(igniter, components, web_module, module_prefix)

    plan = %{
      components: components,
      component_files: component_files,
      configs: configs_to_remove,
      js_to_remove: js_to_remove,
      js_preserved: js_to_consider -- js_to_remove,
      js_modules_to_remove: extract_js_modules(configs_to_remove, js_to_remove),
      npm_to_remove: npm_to_remove,
      npm_preserved: npm_to_consider -- npm_to_remove,
      remaining: remaining,
      warnings: find_dependency_warnings(configs_remaining, components),
      web_module: web_module,
      module_prefix: module_prefix
    }

    Igniter.assign(igniter, :plan, plan)
  end

  defp load_all_configs do
    Enum.reduce([:styled, :headless], %{}, fn kind, acc ->
      config_paths(kind)
      |> Enum.flat_map(&Path.wildcard(Path.join(&1, "*.exs")))
      |> Enum.reduce(acc, fn path, acc2 ->
        component = Path.basename(path, ".exs")

        case read_config_file(path, component) do
          nil -> acc2
          config -> Map.put(acc2, {component, kind}, config)
        end
      end)
    end)
  end

  # `Core.lib_priv/1` resolves the library catalogs via `:code.priv_dir/1`, which works for
  # hex deps, path deps, and umbrellas — the bare `deps/mishka_chelekom/priv/*` string only
  # works for a vanilla hex install. `priv/*` picks up host-app custom catalogs.
  defp config_paths(:headless) do
    ["deps/mishka_chelekom/priv/headless", Core.lib_priv("headless"), "priv/headless"]
    |> Enum.filter(&File.dir?/1)
    |> Enum.uniq()
  end

  defp config_paths(_styled) do
    ["deps/mishka_chelekom/priv/components", Core.lib_priv("components"), "priv/components"]
    |> Enum.filter(&File.dir?/1)
    |> Enum.uniq()
  end

  defp read_config_file(path, component) do
    config = Elixir.Config.Reader.read!(path)
    Keyword.get(config, String.to_atom(component))
  rescue
    _ -> nil
  end

  defp get_components_dir(igniter, web_module, kind) do
    base =
      [web_module, "Components", "Placeholder"]
      |> Module.concat()
      |> then(&Igniter.Project.Module.proper_location(igniter, &1))
      |> Path.dirname()

    case kind do
      :headless -> Path.join(base, "headless")
      _ -> base
    end
  end

  defp extract_npm_deps(configs) do
    configs
    |> Enum.flat_map(fn
      {_, nil} -> []
      {_, config} -> Keyword.get(config, :npm, [])
    end)
    |> Enum.map(&{&1.name, &1.version})
    |> Enum.uniq()
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
    Enum.reduce(components, {igniter, []}, fn {name, kind} = component, {ig, files} ->
      module = build_module_name(web_module, name, module_prefix, kind)

      case Igniter.Project.Module.find_module(ig, module) do
        {:ok, {ig, source, _}} ->
          {ig, [{label(component), Rewrite.Source.get(source, :path), true, module} | files]}

        {:error, ig} ->
          path = Igniter.Project.Module.proper_location(ig, module)
          {ig, [{label(component), path, false, module} | files]}
      end
    end)
    |> then(fn {ig, files} -> {ig, Enum.reverse(files)} end)
  end

  defp find_dependency_warnings(configs_remaining, removing) do
    # A component's `:necessary` deps only reference components of its OWN kind, so match
    # removed names per-kind — otherwise a name collision (styled vs headless "scroll_area")
    # raises a false "styled tabs depends on the removed headless scroll_area" warning.
    removed_by_kind =
      Enum.group_by(removing, fn {_name, kind} -> kind end, fn {name, _kind} -> name end)

    Enum.flat_map(configs_remaining, fn {{_name, kind} = component, config} ->
      removed_names = Map.get(removed_by_kind, kind, [])

      case config do
        nil ->
          []

        config ->
          affected =
            config |> Keyword.get(:necessary, []) |> Enum.filter(&(&1 in removed_names))

          if affected != [], do: [{component, affected}], else: []
      end
    end)
  end

  defp build_module_name(web_module, component, prefix, kind) do
    name = if prefix && prefix != "", do: "#{prefix}#{component}", else: component

    segments =
      case kind do
        :headless -> [web_module, "Components", "Headless", Core.module_atom(name)]
        _ -> [web_module, "Components", Core.module_atom(name)]
      end

    Module.concat(segments)
  end

  # Human label for a `{name, kind}` target — headless ones are tagged so the plan/output
  # can't be confused with a same-named styled component.
  defp label({name, :headless}), do: "#{name} (headless)"
  defp label({name, _}), do: name

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
        "  #{IO.ANSI.yellow()}• #{label(component)}#{IO.ANSI.reset()} uses: #{Enum.join(deps, ", ")}"
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

  # assets/package.json belongs to the user: they may have added the same package themselves, or
  # pinned a different version deliberately. So a package is removed only when this run drops the
  # last component declaring it AND the manifest still holds exactly the version we pinned —
  # anything else is reported, never touched. Opt in with --include-npm.
  defp remove_npm_deps(igniter) do
    plan = igniter.assigns.plan
    candidates = Map.get(plan, :npm_to_remove, [])

    cond do
      candidates == [] ->
        igniter

      !igniter.args.options[:include_npm] ->
        Igniter.add_notice(igniter, """
        These npm packages are no longer used by any installed component:

            #{candidates |> Enum.map(fn {name, version} -> "#{name}@#{version}" end) |> Enum.join(", ")}

        They were left in assets/package.json. Remove them with --include-npm, or by hand.
        """)

      true ->
        {removable, kept} = Enum.split_with(candidates, &pinned_by_us?(igniter, &1))

        igniter
        |> maybe_report_kept(kept)
        |> maybe_remove_npm(removable)
    end
  end

  defp maybe_report_kept(igniter, []), do: igniter

  defp maybe_report_kept(igniter, kept) do
    Igniter.add_notice(igniter, """
    Left these in assets/package.json — the pinned version no longer matches the one this
    component declared, so the project depends on them for another reason:

        #{kept |> Enum.map(fn {name, version} -> "#{name} (expected #{version})" end) |> Enum.join(", ")}
    """)
  end

  defp maybe_remove_npm(igniter, []), do: igniter

  defp maybe_remove_npm(igniter, removable) do
    MishkaChelekom.Generators.Npm.remove_deps(igniter, Enum.map(removable, &elem(&1, 0)))
    |> MishkaChelekom.Generators.Npm.run_command(remove: true)
  end

  # Read through the rewrite, not File.read/1: the manifest may have been staged earlier in this
  # same run, and under Igniter.Test there is no real file at all.
  defp pinned_by_us?(igniter, {name, version}) do
    content =
      case igniter.rewrite.sources["assets/package.json"] do
        nil -> File.read("assets/package.json")
        source -> {:ok, Rewrite.Source.get(source, :content)}
      end

    with {:ok, raw} <- content,
         {:ok, json} <- Jason.decode(raw) do
      get_in(json, ["dependencies", name]) == version
    else
      _ -> false
    end
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

      Igniter.update_file(igniter, path, fn source ->
        content = Rewrite.Source.get(source, :content)

        import_statement = ~s(import MishkaComponents from "../vendor/mishka_components.js")

        content =
          case JsParser.remove_imports(content, import_statement, :content) do
            {:ok, _, updated} -> updated
            _ -> content
          end

        content =
          case JsParser.remove_objects_from_hooks(content, "...MishkaComponents", :content) do
            {:ok, _, updated} -> updated
            _ -> content
          end

        case JsFormatter.format(content) do
          {:ok, _, formatted} -> Rewrite.Source.update(source, :content, formatted)
          _ -> Rewrite.Source.update(source, :content, content)
        end
      end)
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
      Enum.map(plan.components, fn {name, kind} ->
        build_module_name(web_module, name, module_prefix, kind)
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
    case find_quote_block(zipper) do
      {:ok, quote_zipper} ->
        new_zipper = remove_import_nodes(quote_zipper, modules_to_remove)
        {:ok, new_zipper}

      :error ->
        {:ok, zipper}
    end
  end

  defp find_quote_block(zipper) do
    case Sourceror.Zipper.find(zipper, fn node ->
           match?({:quote, _, [[{_, {:__block__, _, _}}]]}, node)
         end) do
      nil -> :error
      found -> {:ok, found}
    end
  end

  defp remove_import_nodes(zipper, modules_to_remove) do
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

    core_components_module =
      (Module.split(web_module) |> Enum.map(&String.to_atom/1)) ++ [:CoreComponents]

    case Igniter.Project.Module.find_and_update_module(
           igniter,
           web_module,
           fn zipper ->
             cleanup_html_helpers(zipper, core_components_module)
           end
         ) do
      {:ok, ig} -> ig
      {:error, ig} -> ig
    end
  end

  defp cleanup_html_helpers(zipper, core_components_module) do
    case Igniter.Code.Function.move_to_defp(zipper, :html_helpers, 0) do
      {:ok, zipper} ->
        has_core_import? = has_core_components_import?(zipper, core_components_module)

        new_node =
          case zipper.node do
            {:quote, _, [[{_, {:__block__, _, _}}]]} = node ->
              Macro.prewalk(node, fn
                {:use, meta, [{:__aliases__, alias_meta, module_parts}]}
                when is_list(module_parts) ->
                  case List.last(module_parts) do
                    name when is_atom(name) ->
                      if Atom.to_string(name) |> String.contains?("MishkaComponents") do
                        if has_core_import? do
                          {:__mishka_remove__, [], []}
                        else
                          {:import, meta, [{:__aliases__, alias_meta, core_components_module}]}
                        end
                      else
                        {:use, meta, [{:__aliases__, alias_meta, module_parts}]}
                      end

                    _ ->
                      {:use, meta, [{:__aliases__, alias_meta, module_parts}]}
                  end

                other ->
                  other
              end)
              |> remove_marker_nodes()

            other ->
              other
          end

        {:ok, Igniter.Code.Common.replace_code(zipper, new_node)}

      :error ->
        {:ok, zipper}
    end
  end

  defp has_core_components_import?(zipper, core_components_module) do
    case zipper.node do
      {:quote, _, [[{_, {:__block__, _, args}}]]} ->
        Enum.any?(args, fn
          {:import, _, [{:__aliases__, _, ^core_components_module}]} -> true
          {:import, _, [{:__aliases__, _, ^core_components_module}, _opts]} -> true
          _ -> false
        end)

      _ ->
        false
    end
  end

  defp remove_marker_nodes({:quote, meta, [[{block_meta, {:__block__, inner_meta, args}}]]}) do
    filtered = Enum.reject(args, &match?({:__mishka_remove__, _, _}, &1))
    {:quote, meta, [[{block_meta, {:__block__, inner_meta, filtered}}]]}
  end

  defp remove_marker_nodes(other), do: other

  defp maybe_remove_css(%{assigns: %{opts: %{all: false, include_css: false}}} = igniter),
    do: igniter

  defp maybe_remove_css(igniter) do
    %{plan: %{remaining: remaining, components: removed}} = igniter.assigns

    igniter
    |> maybe_remove_kind_css(:styled, "mishka_chelekom.css", removed, remaining)
    |> maybe_remove_kind_css(:headless, "mishka_chelekom_headless.css", removed, remaining)
  end

  # Remove a kind's vendored stylesheet only when this run removes that kind AND no
  # component of that kind is left installed (the two kinds ship separate stylesheets).
  defp maybe_remove_kind_css(igniter, kind, file, removed, remaining) do
    removing_kind? = Enum.any?(removed, fn {_n, k} -> k == kind end)
    kind_remains? = Enum.any?(remaining, fn {_n, k} -> k == kind end)
    path = "assets/vendor/#{file}"

    if removing_kind? and not kind_remains? and Igniter.exists?(igniter, path) do
      verbose_log(igniter, "  Removing CSS: #{path}")
      igniter |> Igniter.rm(path) |> clean_app_css(file, kind)
    else
      igniter
    end
  end

  defp clean_app_css(igniter, file, kind) do
    path = "assets/css/app.css"

    if Igniter.exists?(igniter, path) do
      Igniter.update_file(igniter, path, fn source ->
        content =
          source
          |> Rewrite.Source.get(:content)
          # Remove the @import for this vendored stylesheet
          |> String.replace(~r/@import\s+["']\.\.\/vendor\/#{Regex.escape(file)}["'];?\n?/, "")
          |> remove_theme_block(kind)
          # Clean up multiple blank lines
          |> String.replace(~r/\n{3,}/, "\n\n")
          |> String.trim()
          |> Kernel.<>("\n")

        Rewrite.Source.update(source, :content, content)
      end)
    else
      igniter
    end
  end

  # The `@theme` block is only injected by the styled stylesheet install.
  defp remove_theme_block(content, :styled),
    do: String.replace(content, ~r/\n*@theme\s*\{[^}]*\}\n*/s, "\n")

  defp remove_theme_block(content, _), do: content

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
