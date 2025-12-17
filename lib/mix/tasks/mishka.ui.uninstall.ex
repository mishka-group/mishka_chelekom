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
      aliases: [
        a: :all,
        d: :dry_run,
        y: :yes,
        V: :verbose
      ]
    }
  end

  def igniter(igniter) do
    options = igniter.args.options
    %Igniter.Mix.Task.Args{positional: %{components: components_arg}} = igniter.args

    if !options[:dry_run] and Mix.env() != :test do
      print_banner()
    end

    user_config = Config.load_user_config(igniter)
    igniter = Igniter.assign(igniter, %{mishka_user_config: user_config})

    {igniter, components_to_remove} =
      cond do
        options[:all] ->
          find_all_installed_components(igniter, user_config)

        is_binary(components_arg) and components_arg != "" ->
          components = String.split(components_arg, ",", trim: true)
          {igniter, components}

        true ->
          {Igniter.add_issue(igniter, """
           Please specify components to uninstall or use --all flag.

           Examples:
             mix mishka.ui.uninstall accordion
             mix mishka.ui.uninstall accordion,button,alert
             mix mishka.ui.uninstall --all
           """), []}
      end

    if components_to_remove == [] and Map.get(igniter, :issues, []) == [] do
      Igniter.add_notice(igniter, "No Mishka components found to uninstall.")
    else
      if Map.get(igniter, :issues, []) != [] do
        igniter
      else
        process_uninstall(igniter, components_to_remove, user_config, options)
      end
    end
  end

  defp print_banner do
    msg =
      """
            .-.
           /'v'\\
          (/   \\)
          =="="==
        Mishka.tools
         Uninstall
      """

    IO.puts(IO.ANSI.magenta() <> String.trim_trailing(msg) <> IO.ANSI.reset())
  end

  defp find_all_installed_components(igniter, user_config) do
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    module_prefix = user_config[:module_prefix]
    known_components = get_all_known_component_names(igniter)

    {igniter, matching_modules} =
      Igniter.Project.Module.find_all_matching_modules(igniter, fn module_name, _zipper ->
        module_parts = Module.split(module_name)
        web_parts = Module.split(web_module)

        case module_parts do
          parts when length(parts) > length(web_parts) ->
            if List.starts_with?(parts, web_parts) do
              remaining = Enum.drop(parts, length(web_parts))

              case remaining do
                ["Components", component_module_name | _] ->
                  component_file_name = Macro.underscore(component_module_name)

                  base_name =
                    if module_prefix && module_prefix != "" do
                      String.trim_leading(component_file_name, module_prefix)
                    else
                      component_file_name
                    end

                  base_name in known_components

                _ ->
                  false
              end
            else
              false
            end

          _ ->
            false
        end
      end)

    installed_components =
      matching_modules
      |> Enum.map(fn module_name ->
        module_parts = Module.split(module_name)
        web_parts = Module.split(web_module)
        remaining = Enum.drop(module_parts, length(web_parts))

        case remaining do
          ["Components", component_module_name | _] ->
            component_file_name = Macro.underscore(component_module_name)

            if module_prefix && module_prefix != "" do
              String.trim_leading(component_file_name, module_prefix)
            else
              component_file_name
            end

          _ ->
            nil
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    igniter = Igniter.assign(igniter, :mishka_component_modules, matching_modules)
    {igniter, installed_components}
  end

  defp get_all_known_component_names(igniter) do
    search_paths = [
      "deps/mishka_chelekom/priv/components",
      IAPP.priv_dir(igniter, ["mishka_chelekom", "components"]),
      IAPP.priv_dir(igniter, ["mishka_chelekom", "templates"]),
      IAPP.priv_dir(igniter, ["mishka_chelekom", "presets"])
    ]

    real_components =
      search_paths
      |> Enum.flat_map(fn path ->
        if File.dir?(path) do
          path |> Path.join("*.exs") |> Path.wildcard() |> Enum.map(&Path.basename(&1, ".exs"))
        else
          []
        end
      end)

    virtual_components =
      igniter.rewrite
      |> Rewrite.sources()
      |> Enum.filter(fn source ->
        path = Rewrite.Source.get(source, :path)

        String.ends_with?(path, ".exs") and
          Enum.any?(search_paths, &String.starts_with?(path, &1))
      end)
      |> Enum.map(fn source ->
        source |> Rewrite.Source.get(:path) |> Path.basename(".exs")
      end)

    Enum.uniq(real_components ++ virtual_components)
  end

  defp process_uninstall(igniter, components_to_remove, user_config, options) do
    opts = %{
      verbose: options[:verbose] == true,
      dry_run: options[:dry_run] == true,
      yes: options[:yes] == true,
      all: options[:all] == true,
      keep_js: options[:keep_js] == true,
      include_css: options[:include_css] == true,
      include_config: options[:include_config] == true
    }

    {igniter, removal_plan} = build_removal_plan(igniter, components_to_remove, user_config)

    if (opts.dry_run or opts.verbose or not opts.yes) and Mix.env() != :test do
      show_removal_plan(removal_plan, opts.dry_run)
    end

    proceed? =
      cond do
        opts.dry_run -> false
        opts.yes -> true
        Mix.env() == :test -> true
        true -> confirm_removal()
      end

    if proceed? do
      igniter
      |> remove_component_files(removal_plan, user_config, opts)
      |> remove_js_files(removal_plan, opts)
      |> update_mishka_components_js(removal_plan, opts)
      |> maybe_remove_mishka_components_js(removal_plan, opts)
      |> update_app_js(removal_plan, opts)
      |> update_import_macro(removal_plan, user_config, opts)
      |> maybe_cleanup_global_import(removal_plan, opts)
      |> maybe_remove_css(removal_plan, opts)
      |> maybe_remove_config(opts)
      |> add_completion_notice(removal_plan, opts)
    else
      if opts.dry_run do
        Igniter.add_notice(igniter, """

        Dry-run complete. No files were modified.
        Run without --dry-run to perform the actual uninstall.
        """)
      else
        Igniter.add_notice(igniter, "Uninstall cancelled.")
      end
    end
  end

  defp build_removal_plan(igniter, components_to_remove, user_config) do
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    module_prefix = user_config[:module_prefix]

    component_configs =
      components_to_remove
      |> Enum.map(fn component -> {component, get_component_config(igniter, component)} end)
      |> Enum.into(%{})

    js_files_to_consider =
      component_configs
      |> Enum.flat_map(fn {_component, config} ->
        if config do
          config
          |> Keyword.get(:scripts, [])
          |> Enum.filter(&(&1.type == "file"))
          |> Enum.map(& &1.file)
        else
          []
        end
      end)
      |> Enum.uniq()

    {igniter, all_installed} = find_all_installed_components(igniter, user_config)
    remaining_components = all_installed -- components_to_remove

    js_files_still_needed =
      remaining_components
      |> Enum.flat_map(fn component ->
        config = get_component_config(igniter, component)

        if config do
          config
          |> Keyword.get(:scripts, [])
          |> Enum.filter(&(&1.type == "file"))
          |> Enum.map(& &1.file)
        else
          []
        end
      end)
      |> Enum.uniq()

    js_files_to_remove = js_files_to_consider -- js_files_still_needed

    js_modules_to_remove =
      component_configs
      |> Enum.flat_map(fn {_component, config} ->
        if config do
          config
          |> Keyword.get(:scripts, [])
          |> Enum.filter(&(&1.type == "file" && &1.file in js_files_to_remove))
          |> Enum.map(&{&1.module, &1.imports, &1.file})
        else
          []
        end
      end)
      |> Enum.uniq()

    {igniter, component_files} =
      Enum.reduce(components_to_remove, {igniter, []}, fn component, {acc_igniter, acc_files} ->
        module_name = build_component_module_name(web_module, component, module_prefix)

        case Igniter.Project.Module.find_module(acc_igniter, module_name) do
          {:ok, {updated_igniter, source, _zipper}} ->
            path = Rewrite.Source.get(source, :path)
            {updated_igniter, [{component, path, true, module_name} | acc_files]}

          {:error, updated_igniter} ->
            expected_path = Igniter.Project.Module.proper_location(acc_igniter, module_name)
            {updated_igniter, [{component, expected_path, false, module_name} | acc_files]}
        end
      end)

    component_files = Enum.reverse(component_files)

    dependency_warnings =
      remaining_components
      |> Enum.flat_map(fn remaining_component ->
        config = get_component_config(igniter, remaining_component)

        if config do
          necessary = Keyword.get(config, :necessary, [])
          affected = Enum.filter(necessary, &(&1 in components_to_remove))
          if affected != [], do: [{remaining_component, affected}], else: []
        else
          []
        end
      end)

    plan = %{
      components: components_to_remove,
      component_files: component_files,
      component_configs: component_configs,
      js_files_to_remove: js_files_to_remove,
      js_files_preserved: js_files_to_consider -- js_files_to_remove,
      js_modules_to_remove: js_modules_to_remove,
      remaining_components: remaining_components,
      dependency_warnings: dependency_warnings,
      web_module: web_module,
      module_prefix: module_prefix
    }

    {igniter, plan}
  end

  defp build_component_module_name(web_module, component, module_prefix) do
    alias Mix.Tasks.Mishka.Ui.Gen.Component, as: GenComponent

    prefixed_name =
      if module_prefix && module_prefix != "" do
        "#{module_prefix}#{component}"
      else
        component
      end

    module_suffix = GenComponent.atom_to_module(prefixed_name)
    Module.concat([web_module, "Components", module_suffix])
  end

  defp get_component_config(igniter, component) do
    template_config_paths = [
      "deps/mishka_chelekom/priv/components/#{component}.exs",
      Path.join(IAPP.priv_dir(igniter, ["mishka_chelekom", "components"]), "#{component}.exs"),
      Path.join(IAPP.priv_dir(igniter, ["mishka_chelekom", "templates"]), "#{component}.exs"),
      Path.join(IAPP.priv_dir(igniter, ["mishka_chelekom", "presets"]), "#{component}.exs")
    ]

    Enum.find_value(template_config_paths, fn path ->
      cond do
        Igniter.exists?(igniter, path) ->
          try do
            case Rewrite.source(igniter.rewrite, path) do
              {:ok, source} ->
                content = Rewrite.Source.get(source, :content)
                {config, _} = Code.eval_string(content)
                Keyword.get(config, String.to_atom(component))

              {:error, _} ->
                nil
            end
          rescue
            _ -> nil
          end

        File.exists?(path) ->
          try do
            config = Elixir.Config.Reader.read!(path)
            Keyword.get(config, String.to_atom(component))
          rescue
            _ -> nil
          end

        true ->
          nil
      end
    end)
  end

  defp show_removal_plan(plan, dry_run) do
    if dry_run do
      IO.puts("\n#{IO.ANSI.cyan()}=== DRY RUN - Removal Plan ===#{IO.ANSI.reset()}\n")
    else
      IO.puts("\n#{IO.ANSI.yellow()}=== Removal Plan ===#{IO.ANSI.reset()}\n")
    end

    IO.puts("#{IO.ANSI.bright()}Components to remove:#{IO.ANSI.reset()}")

    Enum.each(plan.component_files, fn {component, path, exists?, module_name} ->
      status = if exists?, do: IO.ANSI.green() <> "✓", else: IO.ANSI.red() <> "✗ (not found)"
      IO.puts("  #{status} #{component}#{IO.ANSI.reset()} - #{path || "unknown location"}")
      IO.puts("    Module: #{inspect(module_name)}")
    end)

    if plan.js_files_to_remove != [] do
      IO.puts("\n#{IO.ANSI.bright()}JavaScript files to remove:#{IO.ANSI.reset()}")

      Enum.each(plan.js_files_to_remove, fn file ->
        IO.puts("  #{IO.ANSI.red()}• assets/vendor/#{file}#{IO.ANSI.reset()}")
      end)
    end

    if plan.js_files_preserved != [] do
      IO.puts(
        "\n#{IO.ANSI.bright()}JavaScript files preserved (used by other components):#{IO.ANSI.reset()}"
      )

      Enum.each(plan.js_files_preserved, fn file ->
        IO.puts("  #{IO.ANSI.green()}• assets/vendor/#{file}#{IO.ANSI.reset()}")
      end)
    end

    if plan.dependency_warnings != [] do
      IO.puts(
        "\n#{IO.ANSI.yellow()}#{IO.ANSI.bright()}⚠ Warning: The following components depend on components being removed:#{IO.ANSI.reset()}"
      )

      Enum.each(plan.dependency_warnings, fn {component, deps} ->
        IO.puts(
          "  #{IO.ANSI.yellow()}• #{component} depends on: #{Enum.join(deps, ", ")}#{IO.ANSI.reset()}"
        )
      end)

      IO.puts(
        "  #{IO.ANSI.yellow()}These components may not work correctly after removal.#{IO.ANSI.reset()}"
      )
    end

    if plan.remaining_components != [] do
      IO.puts("\n#{IO.ANSI.bright()}Components that will remain installed:#{IO.ANSI.reset()}")

      IO.puts(
        "  #{IO.ANSI.cyan()}#{Enum.join(plan.remaining_components, ", ")}#{IO.ANSI.reset()}"
      )
    end

    IO.puts("")
  end

  defp confirm_removal do
    IO.puts(
      "#{IO.ANSI.yellow()}Are you sure you want to proceed with the uninstall?#{IO.ANSI.reset()}"
    )

    response =
      IO.gets("Type 'yes' to confirm: ")
      |> String.trim()
      |> String.downcase()

    response in ["yes", "y"]
  end

  defp remove_component_files(igniter, plan, _user_config, opts) do
    Enum.reduce(plan.component_files, igniter, fn {_component, path, exists?, module_name}, acc ->
      if exists? and path != nil do
        if opts.verbose and Mix.env() != :test do
          IO.puts("  Removing: #{path} (#{inspect(module_name)})")
        end

        Igniter.rm(acc, path)
      else
        if opts.verbose and Mix.env() != :test do
          display_path = path || "unknown location"
          IO.puts("  Skipping (not found): #{display_path} (#{inspect(module_name)})")
        end

        acc
      end
    end)
  end

  defp remove_js_files(igniter, plan, opts) do
    if opts.keep_js do
      igniter
    else
      Enum.reduce(plan.js_files_to_remove, igniter, fn file, acc ->
        path = "assets/vendor/#{file}"

        if Igniter.exists?(acc, path) do
          if opts.verbose and Mix.env() != :test do
            IO.puts("  Removing JS: #{path}")
          end

          Igniter.rm(acc, path)
        else
          acc
        end
      end)
    end
  end

  defp update_mishka_components_js(igniter, plan, opts) do
    if opts.keep_js or plan.js_modules_to_remove == [] do
      igniter
    else
      mishka_components_path = "assets/vendor/mishka_components.js"

      if Igniter.exists?(igniter, mishka_components_path) do
        if opts.verbose and Mix.env() != :test do
          IO.puts("  Updating: #{mishka_components_path}")
        end

        igniter
        |> Igniter.update_file(mishka_components_path, fn source ->
          content = Rewrite.Source.get(source, :content)
          updated_content = remove_js_modules_from_content(content, plan.js_modules_to_remove)

          case JsFormatter.format(updated_content) do
            {:ok, _, formatted} ->
              Rewrite.Source.update(source, :content, formatted)

            _ ->
              Rewrite.Source.update(source, :content, updated_content)
          end
        end)
      else
        igniter
      end
    end
  end

  defp remove_js_modules_from_content(content, modules_to_remove) do
    Enum.reduce(modules_to_remove, content, fn {module_name, _import_statement, _file}, acc ->
      acc =
        case JsParser.remove_imports(acc, module_name, :content) do
          {:ok, _, updated} -> updated
          _ -> acc
        end

      acc =
        case JsParser.remove_objects_from_hooks(acc, [module_name], :content) do
          {:ok, _, updated} -> updated
          _ -> acc
        end

      acc
      |> String.replace(~r/\s*\.\.\.#{module_name}\s*,?/, "")
      |> String.replace(~r/,(\s*})/, "\\1")
      |> String.replace(~r/{\s*,/, "{")
      |> String.replace(~r/\n{3,}/, "\n\n")
    end)
  end

  defp update_app_js(igniter, plan, opts) do
    if plan.remaining_components == [] and not opts.keep_js do
      app_js_path = "assets/js/app.js"

      if Igniter.exists?(igniter, app_js_path) do
        if opts.verbose and Mix.env() != :test do
          IO.puts("  Cleaning up: #{app_js_path}")
        end

        igniter
        |> Igniter.update_file(app_js_path, fn source ->
          content = Rewrite.Source.get(source, :content)

          content =
            case JsParser.remove_imports(content, "MishkaComponents", :content) do
              {:ok, _, updated} -> updated
              _ -> content
            end

          content =
            case JsParser.remove_objects_from_hooks(content, ["MishkaComponents"], :content) do
              {:ok, _, updated} -> updated
              _ -> content
            end

          updated_content =
            content
            |> String.replace(~r/\s*\.\.\.MishkaComponents\s*,?/, "")
            |> String.replace(~r/,(\s*})/, "\\1")
            |> String.replace(~r/{\s*,/, "{")

          case JsFormatter.format(updated_content) do
            {:ok, _, formatted} ->
              Rewrite.Source.update(source, :content, formatted)

            _ ->
              Rewrite.Source.update(source, :content, updated_content)
          end
        end)
      else
        igniter
      end
    else
      igniter
    end
  end

  defp update_import_macro(igniter, plan, user_config, opts) do
    web_module = Igniter.Libs.Phoenix.web_module(igniter)
    module_prefix = user_config[:module_prefix]

    mishka_components_path =
      Module.concat([web_module, "components", "mishka_components"])
      |> then(&Igniter.Project.Module.proper_location(igniter, &1))

    if Igniter.exists?(igniter, mishka_components_path) do
      if opts.verbose and Mix.env() != :test do
        IO.puts("  Updating import macro: #{mishka_components_path}")
      end

      if plan.remaining_components == [] do
        Igniter.rm(igniter, mishka_components_path)
      else
        igniter
        |> Igniter.update_file(mishka_components_path, fn source ->
          content = Rewrite.Source.get(source, :content)

          updated_content =
            Enum.reduce(plan.components, content, fn component, acc ->
              prefixed_component =
                if module_prefix && module_prefix != "" do
                  "#{module_prefix}#{component}"
                else
                  component
                end

              module_name =
                prefixed_component
                |> String.split("_")
                |> Enum.map(&String.capitalize/1)
                |> Enum.join()

              acc
              |> String.replace(
                ~r/\s*import\s+#{inspect(web_module)}\.Components\.#{module_name}[^\n]*\n/,
                "\n"
              )
              |> String.replace(~r/\n{3,}/, "\n\n")
            end)

          Rewrite.Source.update(source, :content, updated_content)
        end)
      end
    else
      igniter
    end
  end

  defp maybe_remove_mishka_components_js(igniter, plan, opts) do
    if plan.remaining_components == [] and not opts.keep_js do
      mishka_components_path = "assets/vendor/mishka_components.js"

      if Igniter.exists?(igniter, mishka_components_path) do
        if opts.verbose and Mix.env() != :test do
          IO.puts("  Removing: #{mishka_components_path}")
        end

        Igniter.rm(igniter, mishka_components_path)
      else
        igniter
      end
    else
      igniter
    end
  end

  defp maybe_cleanup_global_import(igniter, plan, _opts) do
    if plan.remaining_components == [] do
      web_module_name = Igniter.Libs.Phoenix.web_module(igniter)

      case Igniter.Project.Module.find_and_update_module(igniter, web_module_name, fn zipper ->
             case Igniter.Code.Function.move_to_defp(zipper, :html_helpers, 0) do
               {:ok, zipper} ->
                 new_node =
                   case zipper.node do
                     {:quote, meta, [[{block_meta, {:__block__, block_inner_meta, args}}]]} ->
                       filtered_args =
                         Enum.reject(args, fn
                           {:use, _, [{:__aliases__, _, [module_name]}]}
                           when is_atom(module_name) ->
                             atom_name = Atom.to_string(module_name)
                             String.contains?(atom_name, "MishkaComponents")

                           _ ->
                             false
                         end)

                       {:quote, meta,
                        [[{block_meta, {:__block__, block_inner_meta, filtered_args}}]]}

                     other ->
                       other
                   end

                 {:ok, Igniter.Code.Common.replace_code(zipper, new_node)}

               :error ->
                 {:ok, zipper}
             end
           end) do
        {:ok, updated_igniter} -> updated_igniter
        {:error, error_igniter} -> error_igniter
      end
    else
      igniter
    end
  end

  defp maybe_remove_css(igniter, plan, opts) do
    if opts.all and opts.include_css and plan.remaining_components == [] do
      css_files = ["assets/vendor/mishka_chelekom.css"]

      Enum.reduce(css_files, igniter, fn path, acc ->
        if Igniter.exists?(acc, path) do
          if opts.verbose and Mix.env() != :test do
            IO.puts("  Removing CSS: #{path}")
          end

          acc
          |> Igniter.rm(path)
          |> maybe_clean_app_css()
        else
          acc
        end
      end)
    else
      igniter
    end
  end

  defp maybe_clean_app_css(igniter) do
    app_css_path = "assets/css/app.css"

    if Igniter.exists?(igniter, app_css_path) do
      igniter
      |> Igniter.update_file(app_css_path, fn source ->
        content = Rewrite.Source.get(source, :content)

        updated_content =
          content
          |> String.replace(~r/@import\s+["']\.\.\/vendor\/mishka_chelekom\.css["'];?\n?/, "")

        Rewrite.Source.update(source, :content, updated_content)
      end)
    else
      igniter
    end
  end

  defp maybe_remove_config(igniter, opts) do
    if opts.all and opts.include_config do
      config_path = "priv/mishka_chelekom/config.exs"

      if Igniter.exists?(igniter, config_path) do
        if opts.verbose and Mix.env() != :test do
          IO.puts("  Removing config: #{config_path}")
        end

        igniter
        |> Igniter.rm(config_path)
        |> maybe_remove_empty_priv_dir()
      else
        igniter
      end
    else
      igniter
    end
  end

  defp maybe_remove_empty_priv_dir(igniter) do
    dir_path = "priv/mishka_chelekom"

    if File.dir?(dir_path) do
      case File.ls(dir_path) do
        {:ok, []} ->
          File.rmdir(dir_path)
          igniter

        _ ->
          igniter
      end
    else
      igniter
    end
  end

  defp add_completion_notice(igniter, plan, opts) do
    removed_count = length(plan.component_files)
    js_removed_count = length(plan.js_files_to_remove)
    js_preserved_count = length(plan.js_files_preserved)

    preserved_msg =
      if js_preserved_count > 0 do
        "\nJavaScript files preserved (still in use): #{js_preserved_count}"
      else
        ""
      end

    css_msg =
      if opts.all and opts.include_css and plan.remaining_components == [] do
        "\nCSS files removed"
      else
        ""
      end

    config_msg =
      if opts.all and opts.include_config do
        "\nConfiguration file removed"
      else
        ""
      end

    remaining_msg =
      if plan.remaining_components != [] do
        "\nRemaining installed components: #{length(plan.remaining_components)}"
      else
        ""
      end

    completion_text =
      if plan.remaining_components == [] do
        "All Mishka components have been removed from your project."
      else
        "Some components remain installed. Run 'mix mishka.ui.uninstall --all' to remove everything."
      end

    igniter
    |> Igniter.add_notice("""
    Uninstall complete!

    Components removed: #{removed_count}
    JavaScript files removed: #{js_removed_count}#{preserved_msg}#{css_msg}#{config_msg}#{remaining_msg}

    #{completion_text}
    """)
  end

  def supports_umbrella?(), do: false
end
