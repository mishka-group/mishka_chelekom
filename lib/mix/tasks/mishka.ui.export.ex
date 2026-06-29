defmodule Mix.Tasks.Mishka.Ui.Export do
  @example "mix mishka.ui.export --example arg"

  @shortdoc "A Mix Task for generating a JSON file from a directory of components"

  @moduledoc """
  #{@shortdoc}

  This Mix Task helps you generate a JSON file from the files in a directory,
  enabling you to use it with `mix mishka.ui.add` or share it in the community version.

  Keep in mind that for each component, you must have both `.eex` and `.exs` files according to the
  documentation of the [Mishka Chelekom](https://github.com/mishka-group/mishka_chelekom) library.
  Otherwise, you will need to create the necessary files manually.
  It’s recommended to review the Core components and follow their structure as a guide.

  If you prefer to perform the process manually, simply add the relevant option to your command to
  generate a template file. You can then customize it based on your specific requirements.

  **Note**:

  > Use `--base64` option to convert the file content to Base64 if you're using special Erlang
  characters that do not retain their original form when converted back to the original file.

  **Note**:

  It is important to note that to place each file in its designated section and specify its type,
  you must use the following naming convention:

  For example, if your file is a `component`, you need to have two files:

  - `component_something.exs`
  - `component_something.eex`

  Similarly, for other file types like `preset` and `template`, you should follow the same
  naming pattern as above. For instance:

  - `template_something.exs`
  - `template_something.eex`

  All files within the directory do not need to have the same name. However,
  they must start with the section name where they are intended to be placed, such as
  `component`, `preset`, or `template`. Additionally, each file must have both the
  `exs` and `eex` formats.

  > **Note**: Since JavaScript files do not require configuration, you only need to
  place the file in the directory. For example: `something.js`

  ### What Should the Configuration of Each Component Look Like?
  If you take a look at the example configuration below, you'll notice that the component
  file name matches the key name in the list, which also matches the configuration name.
  This ensures consistency and makes it easier to work with the component configuration.

  **File name**: `component_accordion.eex` and `component_accordion.exs`
  ```elixir
  [
    component_accordion: [
      name: "component_accordion",
      args: [...]
      ...
    ]
  ]
  ```

  **Note:** you can name this like `preset_accordion` or `template_accordion` too.

  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * `--base64` or `-b` - Converts component content to Base64
  * `--name` or `-n` - Defines a name for JSON file, if it is not set default is template.json
  * `--org` or `-o` - It is only for structuring the file and has no effect on your export.
  * `--template` or `-t` - Creates a default JSON file for manual processing steps.
  """

  use Igniter.Mix.Task

  alias MishkaChelekom.Generators.Core

  @default_json_template """
  {
    "name": "something-new",
    "type": "preset",
    "files": [
      {
        "type": "component",
        "content": "",
        "name": "last_message",
        "from": "https://mishka.tools/example/template.json",
        "args": {
          "variant": [],
          "color": [],
          "size": [],
          "padding": [],
          "space": [],
          "type": [],
          "rounded": [],
          "only": [],
          "module": ""
        },
        "optional": [],
        "necessary": []
      }
    ]
  }
  """

  @impl Igniter.Mix.Task
  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      # Groups allow for overlapping arguments for tasks by the same author
      # See the generators guide for more.
      group: :mishka_chelekom,
      # dependencies to add
      adds_deps: [],
      # dependencies to add and call their associated installers, if they exist
      installs: [],
      # An example invocation
      example: @example,
      # a list of positional arguments, i.e `[:file]`
      positional: [:dir],
      # Other tasks your task composes using `Igniter.compose_task`, passing in the CLI argv
      # This ensures your option schema includes options from nested tasks
      composes: [],
      # `OptionParser` schema
      schema: [
        base64: :boolean,
        template: :boolean,
        name: :string,
        org: :string,
        test: :boolean,
        cms: :boolean,
        bundle_name: :string,
        bundle_version: :string
      ],
      # Default values for the options in the `schema`
      defaults: [],
      # CLI aliases
      aliases: [b: :base64, t: :template, n: :name, o: :org],
      # A list of options in the schema that are required
      required: []
    }
  end

  @impl Igniter.Mix.Task
  def igniter(igniter) do
    # extract positional arguments according to `positional` above
    %Igniter.Mix.Task.Args{positional: %{dir: dir}} = igniter.args

    options = igniter.args.options

    if !options[:test], do: Core.banner(IO.ANSI.yellow())

    name = Keyword.get(options, :name, "template")
    org = Keyword.get(options, :org, "component")

    org =
      if org not in ["component", "preset", "template", "javascript"], do: "component", else: org

    igniter =
      if !File.dir?(dir),
        do: Igniter.add_issue(igniter, "The entered directory does not exist."),
        else: igniter

    base64 = Keyword.get(options, :base64, false)
    # If user selects --template, it just creates a default JSON template
    cond do
      Keyword.get(options, :template, false) ->
        Igniter.create_new_file(igniter, dir <> "/#{name}.json", @default_json_template,
          on_exists: :overwrite
        )

      Keyword.get(options, :cms, false) ->
        igniter
        |> Igniter.assign(%{cli_args: options, cli_dir: dir})
        |> check_dir_files()
        |> create_cms_bundle(name, options, base64)

      true ->
        igniter
        |> Igniter.assign(%{cli_args: options, cli_dir: dir})
        |> check_dir_files()
        |> create_elixir_files_config(base64)
        |> create_asset_files_config(base64)
        |> create_json_file(name, org)
    end
  end

  # --cms output (mishka.ui_kit.bundle.v3)
  #
  # The exporter does ALL the work. Each entry in `components` is the
  # exact shape `Ash.create!(MishkaCmsCore.Runtime.Component, params)`
  # accepts on the MishkaCMS side. The installer there is a trivial
  # decode + bulk_create.

  defp create_cms_bundle(igniter, name, options, base64) do
    cli_files = Map.get(igniter.assigns, :cli_files, false)

    if cli_files do
      bundle_name = Keyword.get(options, :bundle_name, name)
      bundle_version = Keyword.get(options, :bundle_version, "0.0.1")

      pairs =
        cli_files
        |> Enum.filter(&(Path.extname(&1) == ".eex"))
        |> Enum.map(fn eex_path ->
          exs_path = String.replace_suffix(eex_path, ".eex", ".exs")
          {exs_path, eex_path}
        end)

      try do
        # First pass: harvest every public-function name across the whole
        # directory so cross-file sibling refs (e.g. `tabs.eex` calling
        # `<.scroll_area/>` from `scroll_area.eex`) get rewritten in
        # pass 2.
        kit_wide_siblings =
          pairs
          |> Enum.flat_map(fn {exs_path, eex_path} ->
            case MishkaChelekom.CmsBundleExporter.list_public_defs(
                   File.read!(exs_path),
                   File.read!(eex_path)
                 ) do
              {:ok, names} -> names
              _ -> []
            end
          end)
          |> MapSet.new()

        {component_results, skipped} =
          pairs
          |> Enum.map(fn {exs_path, eex_path} ->
            exs_source = File.read!(exs_path)
            eex_source = File.read!(eex_path)

            case MishkaChelekom.CmsBundleExporter.convert(
                   exs_source,
                   eex_source,
                   bundle_name,
                   bundle_version,
                   base64: base64,
                   extra_siblings: kit_wide_siblings
                 ) do
              {:ok, %{components: cs, scripts: ss}} ->
                {:ok, {cs, ss, exs_path}}

              {:error, reason} ->
                {:skip, {Path.basename(exs_path, ".exs"), inspect(reason)}}
            end
          end)
          |> Enum.split_with(&match?({:ok, _}, &1))

        component_results = Enum.map(component_results, fn {:ok, t} -> t end)

        components =
          Enum.flat_map(component_results, fn {cs, _ss, _path} -> cs end)

        js_hooks =
          component_results
          |> Enum.flat_map(fn {_cs, ss, exs_path} ->
            Enum.map(ss, fn s -> {s, Path.dirname(exs_path)} end)
          end)
          |> aggregate_js_hooks(bundle_name, bundle_version, base64)

        # Rewrite `phx-hook="<HookModule>"` → `phx-hook="Global<HookModule>"`
        # in every emitted component, using the PascalCase module names
        # preserved in `extra.module` of each js_hook entry. The bundle
        # is shipped global; MishkaCMS keys global hooks under that
        # exact prefix at runtime.
        hook_modules =
          js_hooks
          |> Enum.map(fn h -> get_in(h, ["extra", "module"]) end)
          |> Enum.reject(&is_nil/1)
          |> Enum.uniq()

        components = prefix_phx_hooks(components, hook_modules)

        # Populate per-component `examples[]` by extracting real
        # invocations from `priv/demos/<comp>_live.html.heex` showcase
        # files (vendored under chelekom). Each example is a
        # ready-to-render runtime HEEx snippet (`<.component
        # component_name="<kit>-X" site={assigns[:site]} … />`) plus the
        # initial-render assigns map harvested from the demo's
        # companion `_live.ex` `mount/3`. CMS consumers read this
        # array straight from the bundle JSON to drive their demo
        # harness — no chelekom code required at consumer time.
        demos_dir = Path.join([Path.dirname(igniter.assigns.cli_dir), "demos"])

        kit_component_set =
          MapSet.new(components, fn c -> c["extra"]["function"] end) |> MapSet.delete(nil)

        components =
          components
          |> populate_examples(demos_dir, kit_component_set, bundle_name)

        # Theme + base CSS files ship from `priv/assets/css/`. Combine
        # them into one global `:theme` Stylesheet entry — the runtime
        # CMS inlines this into shared_base CSS BEFORE Tailwind runs, so
        # custom color tokens like `bg-primary-light` resolve.
        stylesheets =
          aggregate_stylesheets(igniter.assigns.cli_dir, bundle_name, bundle_version)

        skipped_names = Enum.map(skipped, fn {:skip, {n, _}} -> n end)

        bundle = %{
          "$schema" => "mishka.ui_kit.bundle.v3",
          "name" => bundle_name,
          "version" => bundle_version,
          "components" => components,
          "js_hooks" => js_hooks,
          "stylesheets" => stylesheets
        }

        json = Jason.encode!(bundle, pretty: true)

        igniter =
          Igniter.create_new_file(
            igniter,
            igniter.assigns.cli_dir <> "/#{name}.json",
            json,
            on_exists: :overwrite
          )

        if skipped_names == [] do
          igniter
        else
          Igniter.add_notice(
            igniter,
            "Skipped #{length(skipped_names)} component(s) due to parse failure: " <>
              Enum.join(skipped_names, ", ")
          )
        end
      rescue
        e ->
          Igniter.add_issue(igniter, "CMS bundle export failed: #{Exception.message(e)}")
      end
    else
      igniter
    end
  end

  # Aggregate `.exs` `scripts:` entries (plus their colocated `.js`
  # files) into bundle-level `js_hooks`. Each emitted entry is in v3
  # final shape — direct create-params for `Runtime.JsHook`.
  defp aggregate_js_hooks(script_dir_pairs, kit_name, kit_version, base64?) do
    script_dir_pairs
    |> Enum.uniq_by(fn {s, _dir} -> s[:module] || s["module"] end)
    |> Enum.map(fn {s, dir} ->
      pascal_name = stringify_script_field(s, :module)
      # MishkaCMS stores hook rows in DB by lowercase kebab name and
      # rebuilds the live hook key at boot via
      # `JavaScriptCompiler.format_hook_name/2`:
      #
      #   "gallery-filter" -> split("-") |> capitalize |> join -> "GalleryFilter"
      #   global rows     -> "Global" <> base
      #   site rows       -> "<PascalSiteName>" <> base
      #
      # Chelekom's source uses the bare `phx-hook="GalleryFilter"`. To
      # round-trip cleanly through that pipeline we ship the kebab form
      # in `name` and rewrite component templates to the install-target
      # prefix in `prefix_phx_hooks/2` (mix-task-level pass).
      hook_name = pascal_to_kebab(pascal_name)
      file_name = stringify_script_field(s, :file)
      raw_content = find_js_content(dir, file_name) || ""

      content =
        if base64? and raw_content != "",
          do: "base64:" <> Base.encode64(raw_content),
          else: raw_content

      %{
        "name" => hook_name,
        "site_id" => nil,
        "format" => "js",
        "priority" => 50,
        "active" => true,
        "permissions" => [],
        "content" => content,
        "extra" => %{
          "ui_kit" => kit_name,
          "ui_kit_version" => kit_version,
          "module" => pascal_name
        }
      }
    end)
  end

  defp stringify_script_field(s, key) do
    s |> Map.get(key, Map.get(s, to_string(key), "")) |> to_string()
  end

  # Convert PascalCase identifier (e.g. "GalleryFilter") to kebab-case
  # ("gallery-filter"). Single-word names ("Carousel") become bare
  # lowercase ("carousel"). Splits on capital-letter boundaries.
  defp pascal_to_kebab(""), do: ""

  defp pascal_to_kebab(name) when is_binary(name) do
    name
    |> String.replace(~r/([a-z0-9])([A-Z])/, "\\1-\\2")
    |> String.replace(~r/([A-Z]+)([A-Z][a-z])/, "\\1-\\2")
    |> String.downcase()
  end

  # Rewrite every `phx-hook="<HookModule>"` reference in component
  # templates/bodies/helpers/clauses to `phx-hook="Global<HookModule>"`.
  # The bundle ships globally (site_id: null on every js_hook row), and
  # MishkaCMS's runtime JS bundler keys global hooks under
  # `Global<PascalCase>`. Doing this rewrite at the converter is the
  # last step needed to keep the bundle install-and-go.
  #
  # `hook_modules` is the set of PascalCase hook module names from the
  # bundle's js_hooks (e.g. ~w[Carousel Clipboard GalleryFilter]). We
  # only rewrite refs that match one of these — host-app or third-party
  # phx-hook attributes are left alone.
  defp prefix_phx_hooks(components, hook_modules) when hook_modules == [] or hook_modules == nil,
    do: components

  defp prefix_phx_hooks(components, hook_modules) do
    Enum.map(components, fn c ->
      c
      |> update_in(["template"], &rewrite_phx_hooks(&1, hook_modules))
      |> update_in(["body"], &rewrite_phx_hooks(&1, hook_modules))
      |> update_in(["helpers"], fn helpers ->
        Enum.map(helpers || [], fn h ->
          Map.update(h, "code", h["code"], &rewrite_phx_hooks(&1, hook_modules))
        end)
      end)
      |> update_in(["extra", "clauses"], fn clauses ->
        case clauses do
          nil ->
            nil

          list when is_list(list) ->
            Enum.map(list, fn cl ->
              cl
              |> Map.update("template", cl["template"], &rewrite_phx_hooks(&1, hook_modules))
              |> Map.update("body", cl["body"], &rewrite_phx_hooks(&1, hook_modules))
            end)
        end
      end)
    end)
  end

  defp rewrite_phx_hooks(nil, _), do: nil
  defp rewrite_phx_hooks("", _), do: ""

  defp rewrite_phx_hooks(text, hook_modules) when is_binary(text) do
    Enum.reduce(hook_modules, text, fn module_name, acc ->
      String.replace(
        acc,
        ~s(phx-hook="#{module_name}"),
        ~s(phx-hook="Global#{module_name}")
      )
    end)
  end

  defp rewrite_phx_hooks(other, _), do: other

  # Read Chelekom's two-file theme (CSS variables on :root + the @theme
  # block mapping --color-* to those variables) and emit ONE Stylesheet
  # entry of kind=:theme. The MishkaCMS installer drops this row into
  # the DB; TailwindCompiler inlines it into shared_base CSS BEFORE the
  # `@import "tailwindcss"` directive, which is the order Tailwind v4
  # requires for `@theme` declarations.
  #
  # Files come from `priv/assets/css/` relative to the component dir
  # (`priv/components/`). Both files are joined with a clear comment
  # boundary so the output is debuggable in the compiled CSS.
  defp aggregate_stylesheets(component_dir, kit_name, kit_version) do
    css_dir = Path.join([Path.dirname(component_dir), "assets", "css"])
    chelekom_path = Path.join(css_dir, "mishka_chelekom.css")
    theme_path = Path.join(css_dir, "theme.css")

    parts =
      [
        {"mishka_chelekom.css", File.read(chelekom_path)},
        {"theme.css", File.read(theme_path)}
      ]
      |> Enum.flat_map(fn
        {name, {:ok, content}} -> [{name, content}]
        _ -> []
      end)

    case parts do
      [] ->
        []

      _ ->
        content =
          parts
          |> Enum.map_join("\n\n", fn {name, body} ->
            "/* === #{name} === */\n#{body}"
          end)

        [
          %{
            "name" => "#{kit_name}-theme",
            "site_id" => nil,
            "format" => "css",
            "kind" => "theme",
            "priority" => 50,
            "active" => true,
            "permissions" => [],
            "content" => content,
            "description" => "#{kit_name} theme — CSS variables and @theme color tokens",
            "extra" => %{
              "ui_kit" => kit_name,
              "ui_kit_version" => kit_version
            }
          }
        ]
    end
  end

  # Try a few candidate locations for the JS file referenced by a
  # `.exs` `scripts:` entry. Chelekom puts hooks under
  # `priv/assets/js/` (not next to the components), but other UI kits
  # may colocate or use different conventions. Returns the file content
  # or `nil` if no candidate is found.
  defp find_js_content(component_dir, file_name) do
    candidates = [
      Path.join(component_dir, file_name),
      Path.join([component_dir, "..", "assets", "js", file_name]),
      Path.join([component_dir, "..", "..", "priv", "assets", "js", file_name]),
      Path.join([Path.dirname(component_dir), "assets", "js", file_name])
    ]

    Enum.find_value(candidates, fn path ->
      case File.read(path) do
        {:ok, raw} -> raw
        _ -> nil
      end
    end)
  end

  defp check_dir_files(igniter) do
    with {:ls, {:ok, files}} <- {:ls, File.ls(igniter.assigns.cli_dir)},
         files_list <- Enum.map(files, &Path.join(igniter.assigns.cli_dir, &1)),
         components <- Enum.filter(files_list, &(Path.extname(&1) in [".exs", ".eex"])),
         {:validate_files, {:ok, _}} <- {:validate_files, validate_files(components)},
         js_files <- Enum.filter(files_list, &(Path.extname(&1) == ".js")) do
      # We could put the data instead of file path, but they were not clear to read
      igniter
      |> Igniter.assign(%{cli_files: components ++ js_files})
    else
      {:ls, {:error, errors}} ->
        igniter
        |> Igniter.add_issue("There is a problem with the directory. Errors: #{inspect(errors)}")

      {:validate_files, {:error, errors}} ->
        msg = """
        There are one or more problems with the file list.

        #{Enum.map(errors, fn {msg, value} -> "* #{"#{msg}"}: #{value}\n" end)}
        """

        Igniter.add_issue(igniter, msg)
    end
  end

  defp create_elixir_files_config(igniter, base64) do
    # Check the `:cli_files` exist or not, it helps to skip File.read!
    cli_files = Map.get(igniter.assigns, :cli_files, false)

    if cli_files do
      configs =
        Enum.filter(cli_files, &(Path.extname(&1) in [".eex"]))
        |> Enum.reduce([], fn item, acc ->
          content = File.read!(item)
          content = if base64, do: content |> Base.encode64(), else: content
          file_name = item |> Path.basename() |> Path.rootname()
          file_name_type = List.first(String.split(file_name, "_"))

          file_name_type =
            if file_name_type in ["component", "preset", "template"],
              do: file_name_type,
              else: "component"

          {_name, config} =
            Config.Reader.read!("#{String.replace_suffix(item, ".eex", ".exs")}")
            |> List.first()

          converted =
            %{
              type: file_name_type,
              name: config[:name],
              content: content,
              args:
                Enum.into(config[:args] || [], %{})
                |> Map.merge(%{helpers: Enum.into(config[:args][:helpers] || [], %{})}),
              optional: config[:optional] || [],
              necessary: config[:necessary] || [],
              scripts: config[:scripts] || []
            }

          [converted | acc]
        end)

      igniter
      |> Igniter.assign(%{cli_configs: configs})
    else
      igniter
    end
  rescue
    _ ->
      msg =
        "This error occurs when there is a problem with your .exs file configuration or the files cannot be accessed."

      Igniter.add_issue(igniter, msg)
  end

  defp create_asset_files_config(igniter, base64) do
    cli_files = Map.get(igniter.assigns, :cli_files, false)
    cli_configs = Map.get(igniter.assigns, :cli_configs, [])

    if cli_files do
      configs =
        Enum.filter(cli_files, &(Path.extname(&1) in [".js"]))
        |> Enum.reduce([], fn item, acc ->
          content = File.read!(item)
          content = if base64, do: content |> Base.encode64(), else: content
          file_name = item |> Path.basename() |> Path.rootname()
          [%{type: "javascript", name: file_name, content: content} | acc]
        end)

      igniter
      |> Igniter.assign(%{cli_configs: cli_configs ++ configs})
    else
      igniter
    end
  rescue
    _ ->
      msg =
        "This error occurs when there is a problem with your asset file or the files cannot be accessed."

      Igniter.add_issue(igniter, msg)
  end

  if Code.ensure_loaded?(JSON) do
    defp encode_json!(data), do: JSON.encode!(data)
  else
    defp encode_json!(data), do: Jason.encode!(data)
  end

  defp create_json_file(igniter, name, org) do
    dir = igniter.assigns.cli_dir

    case Map.get(igniter.assigns, :cli_configs, []) do
      [] ->
        Igniter.add_issue(igniter, "There is no file to output from.")

      data ->
        # Hard coded skipped org type
        new_data = %{name: name, type: org, files: data} |> encode_json!()

        igniter
        |> Igniter.create_new_file(dir <> "/#{name}.json", new_data, on_exists: :overwrite)
    end
  end

  def validate_files([]), do: {:error, :validate_files, "Empty directory"}

  def validate_files(components) do
    Enum.reduce(components, {:ok, []}, fn file, {status, errors} ->
      ext = Path.extname(file)

      cond do
        ext not in [".exs", ".eex"] ->
          {:error, [{"Invalid extension", file} | errors]}

        # The next two patterns are very easy to read. Refactor them when the goal is
        # not just to reduce code but also to make it simple.
        ext == ".exs" ->
          eex_file = Path.rootname(file) <> ".eex"

          if eex_file in components,
            do: {status, errors},
            else: {:error, [{".eex missing", eex_file} | errors]}

        ext == ".eex" ->
          exs_file = Path.rootname(file) <> ".exs"

          if exs_file in components,
            do: {status, errors},
            else: {:error, [{".exs missing", exs_file} | errors]}

        true ->
          {status, errors}
      end
    end)
  end

  # Walk `<demos_dir>/*_live.html.heex`. For each demo, run the
  # `HeexTagExtractor` to collect every top-level chelekom invocation,
  # rewrite via `HeexTagRewriter` to the runtime `<.component>` form,
  # and harvest the demo's companion `_live.ex` `mount/3` assigns.
  # Group by component name and attach to the matching bundle component
  # under `examples[]`.
  #
  # Skips silently when `demos_dir` doesn't exist — kit author opted
  # out of demo verification (the bundle still ships, just with empty
  # examples arrays).
  @doc false
  def populate_examples(components, demos_dir, kit_component_set, kit_name) do
    if File.dir?(demos_dir) do
      examples_by_component = collect_demo_examples(demos_dir, kit_component_set, kit_name)

      Enum.map(components, fn c ->
        page = Path.join(demos_dir, "#{c["extra"]["component"]}_live.html.heex")
        fn_name = c["extra"]["function"]

        sources =
          if File.exists?(page),
            do: examples_from_page(page, fn_name, kit_component_set, kit_name),
            else: []

        demo_examples = Map.get(examples_by_component, fn_name, [])
        new_extra = Map.put(c["extra"] || %{}, "demo_examples", demo_examples)

        c
        |> Map.put("examples", build_example_strings(sources))
        |> Map.put("extra", new_extra)
      end)
    else
      components
    end
  end

  # Harvest every chelekom invocation across all demo pages (with the companion `_live.ex` `mount/3`
  # assigns), rewritten to the runtime `<.component …/>` form, grouped by component function name.
  # Each entry is a MAP the `DemoHarness` renders directly; see `extra.demo_examples` above.
  defp collect_demo_examples(demos_dir, kit_component_set, kit_name) do
    demos_dir
    |> Path.join("*_live.html.heex")
    |> Path.wildcard()
    |> Enum.flat_map(fn heex_path ->
      ex_path =
        Path.join(Path.dirname(heex_path), Path.basename(heex_path, ".html.heex") <> ".ex")

      {assigns, _skipped} = MishkaChelekom.DemoAssignsExtractor.extract_from_file(ex_path)

      heex_path
      |> File.read!()
      |> MishkaChelekom.CmsBundle.Heex.extract(kit_component_set)
      |> Enum.map(fn ext ->
        translated =
          ext.source
          |> MishkaChelekom.CmsBundle.Heex.rewrite(kit_component_set, kit_name)
          |> strip_route_sigils()

        %{
          "component" => ext.component,
          "source" => translated,
          "raw_source" => ext.source,
          "line" => ext.line,
          "file" => Path.basename(heex_path),
          "assigns" => stringify_assign_keys(assigns)
        }
      end)
    end)
    |> Enum.group_by(& &1["component"])
  end

  # Bundle JSON keys are strings; convert atom-keyed assigns map for safe JSON serialization. Atom
  # values stay as atoms (Jason encodes them as strings; the CMS converts back via
  # `String.to_existing_atom/1` only for whitelisted keys).
  defp stringify_assign_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {to_string(k), stringify_terms(v)} end)
  end

  defp stringify_terms(%{} = m) when not is_struct(m), do: stringify_assign_keys(m)
  defp stringify_terms(list) when is_list(list), do: Enum.map(list, &stringify_terms/1)

  defp stringify_terms(t) when is_tuple(t),
    do: t |> Tuple.to_list() |> Enum.map(&stringify_terms/1)

  defp stringify_terms(other), do: other

  # Extract THIS function's top-level invocations from its own docs page, rewritten to the runtime
  # `<.component component_name="<kit>-X" …/>` form. The FULL kit set drives extract+rewrite (so a
  # nested `<.icon/>` inside a button example is rewritten too), but only invocations of `fn_name`
  # are kept. Returns a list of HEEx source strings.
  defp examples_from_page(page, fn_name, kit_component_set, kit_name) do
    page
    |> File.read!()
    |> MishkaChelekom.CmsBundle.Heex.extract(kit_component_set)
    |> Enum.filter(fn ext -> to_string(ext.component) == to_string(fn_name) end)
    |> Enum.map(fn ext ->
      ext.source
      |> MishkaChelekom.CmsBundle.Heex.rewrite(kit_component_set, kit_name)
      |> strip_route_sigils()
    end)
  end

  # At least 4–5 good examples per component is plenty.
  @max_examples 5

  # Turn the harvested invocation sources into a deduped list of clean, self-contained, renderable
  # HEEx strings for the `examples` field: normalize `site` to `"Global"`, drop wrapper `:if`, collapse
  # whitespace to single lines, and KEEP ONLY snippets whose every `{…}` interpolation is a safe
  # literal (so the consumer always renders them with empty assigns).
  @doc false
  def build_example_strings(sources) do
    sources
    |> Enum.map(&normalize_example_source/1)
    |> Enum.filter(&self_contained_example?/1)
    |> Enum.uniq()
    |> Enum.take(@max_examples)
  end

  @doc false
  def normalize_example_source(source) when is_binary(source) do
    source
    |> String.replace("site={assigns[:site]}", ~s(site="Global"))
    |> String.replace("site={@site}", ~s(site="Global"))
    |> String.replace("site={assigns.site}", ~s(site="Global"))
    |> strip_if_attrs()
    |> collapse_whitespace()
    |> String.trim()
  end

  def normalize_example_source(_), do: ""

  # Drop wrapper conditionals like `<div :if={true}>` left over from interactive demos.
  defp strip_if_attrs(source), do: Regex.replace(~r/\s*:if=\{[^}]*\}/, source, "")

  # Demo HEEx is heavily indented; collapse runs of whitespace so each example is one tidy line
  # (whitespace between tags/attrs is insignificant in HEEx).
  defp collapse_whitespace(source), do: Regex.replace(~r/\s+/, source, " ")

  # True when every brace-balanced `{…}` expression in the snippet is a safe literal. Reuses the
  # quote-aware `take_balanced_expr/3` so a `}` inside a string doesn't fool the scan.
  @doc false
  def self_contained_example?(""), do: false
  def self_contained_example?(source), do: all_exprs_literal?(source)

  defp all_exprs_literal?(""), do: true

  defp all_exprs_literal?("{" <> rest) do
    case take_balanced_expr(rest, 1, []) do
      {:ok, expr_iodata, rest_after} ->
        literal_expr?(IO.iodata_to_binary(expr_iodata)) and all_exprs_literal?(rest_after)

      :unbalanced ->
        false
    end
  end

  defp all_exprs_literal?(<<_char::utf8, rest::binary>>), do: all_exprs_literal?(rest)

  defp literal_expr?(inner) do
    inner = String.trim(inner)

    Regex.match?(~r/^"[^"]*"$/, inner) or
      Regex.match?(~r/^-?\d+(\.\d+)?$/, inner) or
      inner in ["true", "false", "nil"] or
      Regex.match?(~r/^:[a-z_][a-zA-Z0-9_]*$/, inner)
  end

  # Replace `~p"/some/path"` route sigils with the literal path string.
  # Demos lean heavily on `Phoenix.VerifiedRoutes`, but the consumer
  # (CMS test harness) doesn't carry router context. Translating the
  # sigil to a plain string preserves the URL semantics for navigation
  # attributes (`href`, `navigate`, `patch`) without requiring the
  # consumer to import VerifiedRoutes.
  #
  # ## Implementation
  #
  # Hybrid: a brace-balanced HEEx scanner identifies each `{...}`
  # expression span, then `Sourceror.parse_string/1` parses the inner
  # Elixir, `Macro.prewalk/2` replaces every `:sigil_p` AST node with
  # its literal path string, and `Sourceror.to_string/1` re-emits the
  # Elixir source. The transformed expression is spliced back into
  # the HEEx text.
  #
  # This handles heredoc `~p"""…"""`, escaped quotes, sigils nested
  # inside other expressions (`if cond, do: ~p"/a", else: ~p"/b"`),
  # and string interpolation around the sigil — none of which the
  # prior char-by-char scanner handled correctly.
  defp strip_route_sigils(text) when is_binary(text) do
    walk_strip(text, [])
    |> IO.iodata_to_binary()
  end

  defp walk_strip("", acc), do: Enum.reverse(acc)

  # Skip EEx blocks — they're Elixir code but with their own sentinels;
  # we don't need to rewrite them (chelekom demos use `<%= … %>` for
  # docs scaffolding, not for runtime route helpers).
  defp walk_strip("<%!" <> rest, acc), do: copy_until_delim(rest, "%>", "<%!", acc)
  defp walk_strip("<%=" <> rest, acc), do: copy_until_delim(rest, "%>", "<%=", acc)
  defp walk_strip("<%" <> rest, acc), do: copy_until_delim(rest, "%>", "<%", acc)

  # `<!-- … -->` and attribute-string regions don't carry `~p` in
  # practice. Scanning into them would require quote-state tracking
  # that the brace-balance pass already gets right (curly braces inside
  # an HTML attr string don't count as expression boundaries because
  # we only enter expression-mode on `{` while `:text`-state).

  # `{…}` HEEx expression — parse + transform + emit. We do brace-
  # balanced extraction (track depth so `{%{a: {b, c}}}` returns the
  # whole inner text).
  defp walk_strip("{" <> rest, acc) do
    case take_balanced_expr(rest, 1, []) do
      {:ok, expr_iodata, rest_after} ->
        original = IO.iodata_to_binary(expr_iodata)
        rewritten = transform_expr(original)
        walk_strip(rest_after, ["}", rewritten, "{" | acc])

      :unbalanced ->
        # Malformed input — fall through to char-by-char copy.
        walk_strip(rest, ["{" | acc])
    end
  end

  defp walk_strip(<<char::utf8, rest::binary>>, acc) do
    walk_strip(rest, [<<char::utf8>> | acc])
  end

  defp copy_until_delim(rest, delim, prefix, acc) do
    case :binary.split(rest, delim) do
      [block, after_block] -> walk_strip(after_block, [delim, block, prefix | acc])
      [_unsplit] -> walk_strip("", [rest, prefix | acc])
    end
  end

  defp take_balanced_expr("", _depth, _acc), do: :unbalanced

  # Honor double / single quoted string boundaries inside the
  # expression so a literal `}` inside a string doesn't confuse the
  # depth counter.
  defp take_balanced_expr("\\" <> <<char::utf8, rest::binary>>, depth, acc) do
    take_balanced_expr(rest, depth, [<<char::utf8>>, "\\" | acc])
  end

  defp take_balanced_expr("\"" <> rest, depth, acc) do
    {str, after_str} = take_until_unescaped(rest, "\"", [])
    take_balanced_expr(after_str, depth, ["\"", str, "\"" | acc])
  end

  defp take_balanced_expr("'" <> rest, depth, acc) do
    {str, after_str} = take_until_unescaped(rest, "'", [])
    take_balanced_expr(after_str, depth, ["'", str, "'" | acc])
  end

  defp take_balanced_expr("{" <> rest, depth, acc) do
    take_balanced_expr(rest, depth + 1, ["{" | acc])
  end

  defp take_balanced_expr("}" <> rest, 1, acc) do
    {:ok, Enum.reverse(acc), rest}
  end

  defp take_balanced_expr("}" <> rest, depth, acc) do
    take_balanced_expr(rest, depth - 1, ["}" | acc])
  end

  defp take_balanced_expr(<<char::utf8, rest::binary>>, depth, acc) do
    take_balanced_expr(rest, depth, [<<char::utf8>> | acc])
  end

  defp take_until_unescaped("", _delim, acc),
    do: {Enum.reverse(acc) |> IO.iodata_to_binary(), ""}

  defp take_until_unescaped("\\" <> <<char::utf8, rest::binary>>, delim, acc),
    do: take_until_unescaped(rest, delim, [<<char::utf8>>, "\\" | acc])

  defp take_until_unescaped(<<delim::utf8, rest::binary>>, <<delim::utf8>>, acc),
    do: {Enum.reverse(acc) |> IO.iodata_to_binary(), rest}

  defp take_until_unescaped(<<char::utf8, rest::binary>>, delim, acc),
    do: take_until_unescaped(rest, delim, [<<char::utf8>> | acc])

  # Parse one Elixir expression with Sourceror, walk its AST replacing
  # every `~p"…"` (or heredoc / interpolated variant) with the literal
  # path string, re-emit. Returns the original text on parse failure
  # so we never corrupt input we can't understand.
  defp transform_expr(code) when is_binary(code) do
    case Sourceror.parse_string(code) do
      {:ok, ast} ->
        new_ast =
          Macro.prewalk(ast, fn
            # `~p"/path"` — the sigil's first arg is `{:<<>>, _, [path_string]}`
            # when the path has no interpolation. We only inline the
            # path when it's a single literal string; interpolated
            # paths (`~p"/posts/#{id}"`) are left as-is because we
            # can't know the value at export time.
            {:sigil_p, _meta, [{:<<>>, _, [path]}, _modifiers]} when is_binary(path) ->
              path

            other ->
              other
          end)

        if new_ast == ast do
          # No `~p` to replace — return original to preserve formatting.
          code
        else
          Sourceror.to_string(new_ast)
        end

      {:error, _reason} ->
        code
    end
  rescue
    _ -> code
  end
end
