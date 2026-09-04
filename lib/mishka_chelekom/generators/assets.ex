defmodule MishkaChelekom.Generators.Assets do
  @moduledoc """
  Vendor asset wiring shared by the generator tasks: copying component JS engines into
  `assets/vendor/`, wiring them into `mishka_components.js` + `app.js`, and installing the
  styled / headless stylesheets with their `app.css` imports.
  """

  alias Igniter.Project.Application, as: IAPP
  alias IgniterJs.Parsers.Javascript.Parser, as: JsParser
  alias IgniterJs.Parsers.Javascript.Formatter, as: JsFormatter
  alias MishkaChelekom.Generators.Core
  alias MishkaChelekom.Generators.Npm
  alias MishkaChelekom.Config
  alias MishkaChelekom.SimpleCSSUtilities

  @doc """
  Copies a component's JS engine files into `assets/vendor/`, wires their imports/hooks into
  `mishka_components.js` and `app.js`, and installs any npm packages the catalog declares.

  No-op when the catalog declares neither `:scripts` nor `:npm`. `options` carries the generator's
  CLI flags (`--no-npm`, `--npm`/`--bun`/`--yarn`/`--mix-bun`); it is threaded explicitly rather
  than read from `igniter.args`, because `compose_task/3` restores `:args` on the way out and the
  batch generators run children with different flags than the parent.
  """
  @spec wire_scripts(Igniter.t(), keyword(), keyword()) :: Igniter.t()
  def wire_scripts(igniter, config, options \\ []) do
    lib = resolve_lib(config, options)
    scripts = scripts(config, lib)
    npm = npm_packages(config, lib)

    if scripts == [] and npm == [] do
      igniter
    else
      igniter
      |> check_package_json(npm, options)
      |> prune_other_libs(config, lib, options)
      |> update_js_files(config, scripts)
      |> copy_user_files(config)
    end
  end

  @doc """
  The `:libs` entry this run should install: the `--lib` choice, else the one marked `default: true`.

  Returns `nil` for a component with no `:libs` (the common case — its top-level `:scripts` and
  `:npm` are used directly).
  """
  @spec resolve_lib(keyword(), keyword()) :: {atom(), keyword()} | nil
  def resolve_lib(config, options \\ []) do
    libs = Keyword.get(config, :libs, [])
    requested = options[:lib]

    cond do
      libs == [] ->
        nil

      is_binary(requested) ->
        Enum.find(libs, fn {name, _} -> Atom.to_string(name) == requested end)

      true ->
        Enum.find(libs, List.first(libs), fn {_name, lib} -> Keyword.get(lib, :default, false) end)
    end
  end

  @doc "Known `:libs` names, for error messages and validation."
  @spec lib_names(keyword()) :: [String.t()]
  def lib_names(config) do
    config |> Keyword.get(:libs, []) |> Enum.map(fn {name, _} -> Atom.to_string(name) end)
  end

  @doc "The scripts to install: the chosen lib's, else the catalog's top-level ones."
  @spec scripts(keyword(), {atom(), keyword()} | nil) :: [map()]
  def scripts(config, nil), do: Keyword.get(config, :scripts, [])

  def scripts(config, {_name, lib}) do
    case Keyword.get(lib, :scripts, []) do
      [] -> Keyword.get(config, :scripts, [])
      scripts -> scripts
    end
  end

  # Files the component needs but the DEVELOPER owns: written once, never touched again, so
  # configuration survives regeneration. The engine beside them is regenerated every time, which is
  # exactly why user config cannot live in it.
  defp copy_user_files(igniter, config) do
    config
    |> Keyword.get(:user_files, [])
    |> Enum.reduce(igniter, fn item, acc ->
      source = Core.lib_priv("assets/js/#{item.file}")

      if File.exists?(source) do
        Igniter.create_new_file(acc, "assets/vendor/#{item.file}", File.read!(source),
          on_exists: :skip
        )
      else
        Igniter.add_issue(acc, "The user file #{item.file} does not exist in the library.")
      end
    end)
  end

  @doc """
  The npm packages a catalog declares, as `"name@version"` strings.

  Reads the top-level `:npm` key, falling back to the default entry of `:libs` (the multi-engine
  shape, where each library pins its own packages but they all share one hook name).
  """
  @spec npm_packages(keyword(), {atom(), keyword()} | nil) :: [String.t()]
  def npm_packages(config, lib \\ :__default__)

  def npm_packages(config, :__default__), do: npm_packages(config, resolve_lib(config, []))

  def npm_packages(config, nil), do: config |> Keyword.get(:npm, []) |> to_dep_strings()

  def npm_packages(config, {_name, lib}) do
    case Keyword.get(lib, :npm, []) do
      [] -> npm_packages(config, nil)
      npm -> to_dep_strings(npm)
    end
  end

  defp to_dep_strings(deps) do
    Enum.map(deps, fn
      %{name: name, version: version} -> "#{name}@#{version}"
      %{name: name} -> name
      dep when is_binary(dep) -> dep
    end)
  end

  # Switching engines must not strand the previous one's packages in package.json. Every other
  # lib's packages are pruned — but only the ones still pinned at exactly the version we wrote, so
  # a package the project also uses (or re-pinned) is never touched.
  defp prune_other_libs(igniter, _config, nil, _options), do: igniter

  defp prune_other_libs(igniter, config, {chosen, _}, options) do
    keep = config |> npm_packages(resolve_lib(config, [])) |> MapSet.new()

    chosen_deps =
      config |> Keyword.get(:libs, []) |> Keyword.get(chosen, []) |> Keyword.get(:npm, [])

    keep = MapSet.union(keep, MapSet.new(to_dep_strings(chosen_deps)))

    others =
      config
      |> Keyword.get(:libs, [])
      |> Enum.reject(fn {name, _} -> name == chosen end)
      |> Enum.flat_map(fn {_name, lib} -> to_dep_strings(Keyword.get(lib, :npm, [])) end)
      |> Enum.uniq()
      |> Enum.reject(&MapSet.member?(keep, &1))

    Npm.prune(igniter, others, options)
  end

  # Installs the catalog's npm packages and makes the project able to BUILD with them: the
  # dependency itself is useless if `mix assets.deploy` in CI/Docker bundles before installing,
  # or if `assets/node_modules` lands in the user's next commit.
  defp check_package_json(igniter, [], _options), do: igniter

  defp check_package_json(igniter, npm, options) do
    if Igniter.exists?(igniter, "assets/js/app.js") do
      igniter
      |> Npm.install(npm, options)
      |> ignore_node_modules()
      |> wire_install_aliases()
    else
      Igniter.add_notice(igniter, """
      Note:
      This component needs the npm packages #{Enum.join(npm, ", ")}, but no assets/js/app.js was
      found — skipping the install because this project has no JS build pipeline.
      """)
    end
  end

  # Stock Phoenix 1.8 does NOT gitignore assets/node_modules (it ships no node_modules pipeline),
  # so without this the user's first `git status` after generating shows thousands of files.
  defp ignore_node_modules(igniter) do
    entry = "/assets/node_modules/"

    Igniter.create_or_update_file(igniter, ".gitignore", "#{entry}\n", fn source ->
      content = Rewrite.Source.get(source, :content)

      if String.contains?(content, entry) do
        source
      else
        Rewrite.Source.update(
          source,
          :content,
          String.trim_trailing(content) <>
            "\n\n# JS dependencies of generated components\n#{entry}\n"
        )
      end
    end)
  end

  # `mix assets.deploy` runs esbuild, which fails with `Could not resolve "<pkg>"` unless the
  # packages are installed first — and Phoenix's release Dockerfile both installs no Node and
  # .dockerignores assets/node_modules, so committing them does not help. Prepend (never append)
  # so the install happens before esbuild/tailwind in the same alias.
  defp wire_install_aliases(igniter) do
    # `add_alias/4` is not idempotent for our purposes: on an alias it already wired it either
    # duplicates the entry (existing list) or rewrites a bare string into a list — both show up as
    # a mix.exs diff on every regeneration. The task name is ours, so its presence means we ran.
    if mix_exs_wires_install?(igniter) do
      igniter
    else
      Enum.reduce(["assets.setup", "assets.build", "assets.deploy"], igniter, fn alias_name,
                                                                                 acc ->
        Igniter.Project.TaskAliases.add_alias(acc, alias_name, "mishka.assets.install",
          if_exists: :prepend
        )
      end)
    end
  end

  defp mix_exs_wires_install?(igniter) do
    content =
      case igniter.rewrite.sources["mix.exs"] do
        nil -> File.read("mix.exs")
        source -> {:ok, Rewrite.Source.get(source, :content)}
      end

    match?({:ok, _}, content) and String.contains?(elem(content, 1), "mishka.assets.install")
  end

  defp update_js_files(igniter, _template_config, scripts) do
    files = Enum.filter(scripts, &(&1.type == "file"))

    if files != [] do
      igniter =
        Enum.reduce(files, igniter, fn item, acc ->
          core_path = Core.lib_priv("assets/js/#{item.file}")

          mishka_user_priv_path =
            Path.join(
              IAPP.priv_dir(igniter, ["mishka_chelekom", "javascripts"]),
              "#{item.file}"
            )

          # Priority is given to Core assets.
          content =
            cond do
              File.exists?(core_path) -> File.read!(core_path)
              File.exists?(mishka_user_priv_path) -> File.read!(mishka_user_priv_path)
              true -> nil
            end

          # The INSTALLED name may differ from the source name (`as:`), so two engines for the
          # same component land on one file — switching engines then overwrites instead of leaving
          # a stale file that still imports the packages we just removed.
          installed = Map.get(item, :as, item.file)

          if !is_nil(content) do
            # `create_or_update_file/4` only uses this when the file is absent, and it reads an
            # existing one through the rewrite — so never touch the real filesystem here, or the
            # whole wiring step becomes untestable (and wrong under `Igniter.Test`).
            caller_js = File.read!(Core.lib_priv("assets/js/mishka_components.js"))

            acc
            |> Igniter.create_or_update_file("assets/vendor/#{installed}", content, fn source ->
              Rewrite.Source.update(source, :content, content)
            end)
            |> Igniter.create_or_update_file(
              "assets/vendor/mishka_components.js",
              caller_js,
              fn source ->
                with original_content <- Rewrite.Source.get(source, :content),
                     {:ok, _, imported} <-
                       JsParser.insert_imports(original_content, "#{item.imports}"),
                     {:ok, _, extended} <-
                       JsParser.extend_var_object_by_object_names(
                         imported,
                         "Components",
                         "#{item.module}"
                       ),
                     {:ok, _, formatted} <- JsFormatter.format(extended) do
                  Rewrite.Source.update(source, :content, formatted)
                else
                  {:error, _, error} ->
                    msg = """
                    Note:
                    When you see this error, it means there is a syntax issue in the part you are trying to import.
                    Please review the relevant file again.

                    Full Erros: "#{inspect(error)}"
                    """

                    Rewrite.Source.add_issue(source, msg)
                end
              end
            )
          else
            acc
            |> Igniter.add_issue("The requested JavaScript file does not exist.")
          end
        end)

      app_js = "assets/js/app.js"

      # Read through Igniter, never `File.read/1`: the rewrite is the source of truth, so this
      # works under `Igniter.Test` (where the project is virtual) and picks up an app.js that an
      # earlier step in the same run created.
      if Igniter.exists?(igniter, app_js) do
        Igniter.update_file(igniter, app_js, fn source ->
          imports = """
          import MishkaComponents from "../vendor/mishka_components.js";
          """

          with original_content <- Rewrite.Source.get(source, :content),
               {:ok, _, imported} <- JsParser.insert_imports(original_content, imports),
               {:ok, _, output} <- JsParser.extend_hook_object(imported, "...MishkaComponents"),
               {:ok, _, formatted} <- JsFormatter.format(output) do
            Rewrite.Source.update(source, :content, formatted)
          else
            {:error, _, error} ->
              Rewrite.Source.add_issue(source, "#{inspect(error)}")
          end
        end)
      else
        Igniter.add_notice(igniter, """
        Note:
        Unfortunately, we couldn't find the assets/js/app.js file in your project path.
        Register the hooks yourself:

            import MishkaComponents from "../vendor/mishka_components.js";
            // ...then spread ...MishkaComponents into your LiveSocket hooks
        """)
      end
    else
      igniter
    end
  end

  @doc """
  Installs the styled `mishka_chelekom.css` vendor stylesheet and the theme `@import` into
  `app.css`. No-op for sub generations (`--sub`).
  """
  @spec setup_styled_css(Igniter.t(), keyword()) :: Igniter.t()
  def setup_styled_css(igniter, options \\ []) do
    if options[:sub] do
      igniter
    else
      igniter
      |> Core.ensure_user_config()
      |> create_mishka_css("assets/vendor/mishka_chelekom.css")
      |> import_and_setup_theme("assets/css/app.css")
    end
  end

  defp create_mishka_css(igniter, vendor_css_path) do
    mishka_css_content = Config.generate_css_content(igniter)

    Igniter.create_or_update_file(igniter, vendor_css_path, mishka_css_content, fn source ->
      Rewrite.Source.update(source, :content, mishka_css_content)
    end)
  end

  defp import_and_setup_theme(igniter, app_css_path) do
    theme_path = Core.lib_priv("assets/css/theme.css")

    with {:ok, css_content} <- File.read(app_css_path),
         {:ok, theme_content} <- SimpleCSSUtilities.read_theme_content(theme_path),
         {:ok, updated_content} <-
           SimpleCSSUtilities.add_import_and_theme(
             css_content,
             "../vendor/mishka_chelekom.css",
             theme_content
           ) do
      igniter
      |> Igniter.create_or_update_file(app_css_path, updated_content, fn source ->
        Rewrite.Source.update(source, :content, updated_content)
      end)
    else
      {:error, :enoent} ->
        Igniter.add_issue(igniter, """
        The app.css file does not exist at #{app_css_path}.
        Please ensure your Phoenix application has been properly set up with assets.
        """)

      {:error, reason} ->
        Igniter.add_issue(igniter, "Error processing CSS file: #{inspect(reason)}")
    end
  end

  @doc """
  Installs the functional (color-free) headless base stylesheet and imports it once into
  `app.css`. No-op for sub generations (`--sub`).
  """
  @spec setup_headless_css(Igniter.t(), keyword()) :: Igniter.t()
  def setup_headless_css(igniter, options \\ []) do
    if options[:sub] do
      igniter
    else
      css = File.read!(Core.lib_priv("assets/css/mishka_chelekom_headless.css"))

      igniter
      |> Core.ensure_user_config()
      |> Igniter.create_or_update_file(
        "assets/vendor/mishka_chelekom_headless.css",
        css,
        &Rewrite.Source.update(&1, :content, css)
      )
      |> add_vendor_import("assets/css/app.css", "../vendor/mishka_chelekom_headless.css")
    end
  end

  @skins ~w(daisyui)

  @doc "The skin names `--skin` accepts."
  @spec skins() :: [String.t()]
  def skins, do: @skins

  @doc """
  Appends one component's design-system skin into `assets/vendor/mishka_chelekom_headless_<skin>.css`
  and imports that file into `app.css`.

  A skin is presentation only — color, spacing, sizing and transitions painted onto the
  `chelekom-<comp>__<part>` classes and `data-*` state the headless component already emits. It never
  changes markup, ARIA or behavior. Each component owns a delimited block in the stylesheet, so
  regenerating a component rewrites its block in place instead of duplicating it.

  `options[:skin_prefix]` is normally unnecessary: the prefix is read out of the design system's own
  `@plugin` block in `app.css`, so `@plugin "daisyui" { prefix: "d-"; }` produces a `d-`-prefixed
  skin with no flag at all. Pass it to override what is found there.

  `options[:skin_scope]` nests the whole skin under a selector, so it paints only inside that
  subtree (e.g. `--skin-scope "[data-skin=daisyui]"`). Without it a skin paints every instance of
  the component in the app, which is usually what you want.
  """
  @spec setup_headless_skin(Igniter.t(), String.t(), keyword()) :: Igniter.t()
  def setup_headless_skin(igniter, component, options \\ []) do
    skin = options[:skin]

    cond do
      is_nil(skin) or skin == "none" ->
        igniter

      skin not in @skins ->
        Igniter.add_issue(igniter, unknown_skin_message(skin))

      true ->
        prefix = options[:skin_prefix] || detect_prefix(skin)
        install_skin(igniter, component, skin, prefix, options[:skin_scope])
    end
  end

  @doc """
  The prefix the app loads `skin`'s Tailwind plugin with, read from its `@plugin` block in
  `app.css`; `""` when it is loaded unprefixed, absent, or unreadable.

  A skin `@apply`s the design system's own class names, so it has to spell them the way the
  consuming build does — `@apply collapse` simply fails to compile in a project whose daisyUI is
  loaded as `@plugin "daisyui" { prefix: "d-"; }`. Asking the stylesheet beats asking the user.
  """
  @spec detect_prefix(String.t(), Path.t()) :: String.t()
  def detect_prefix(skin, app_css \\ "assets/css/app.css") do
    with {:ok, source} <- File.read(app_css),
         {:ok, [_ | _] = rules} <- plugin_rules(source, skin),
         {_, raw} <- Enum.find_value(rules, &List.keyfind(&1.declarations, "prefix", 0)) do
      raw |> String.trim() |> String.trim(~s|"|) |> String.trim(~s|'|)
    else
      _ -> ""
    end
  end

  # A plugin is named either by the package (`"daisyui"`) or by a vendored file
  # (`"../vendor/daisyui.js"`), so match on the target containing the skin's name rather than
  # equalling it. `get_at_rules/4` with no `matching` returns every `@plugin`; we pick ours.
  defp plugin_rules(source, skin) do
    case IgniterCss.get_at_rules(source, "plugin") do
      {:ok, rules} ->
        {:ok, Enum.filter(rules, &String.contains?(&1.target || "", skin))}

      other ->
        other
    end
  end

  defp unknown_skin_message(skin) do
    "Unknown --skin #{inspect(skin)}. Available: #{Enum.join(@skins, ", ")}."
  end

  defp install_skin(igniter, component, skin, prefix, scope) do
    fragment = Core.lib_priv("headless/skins/#{skin}/#{component}.css.eex")

    if File.exists?(fragment) do
      css = fragment |> EEx.eval_file(assigns: [d: prefix]) |> wrap_css(scope)
      vendor = "assets/vendor/mishka_chelekom_headless_#{skin}.css"

      igniter
      |> Igniter.create_or_update_file(
        vendor,
        skin_header(skin) <> put_skin_block("", component, css),
        fn source ->
          content = Rewrite.Source.get(source, :content)
          Rewrite.Source.update(source, :content, put_skin_block(content, component, css))
        end
      )
      |> add_vendor_import("assets/css/app.css", "../vendor/mishka_chelekom_headless_#{skin}.css")
      |> warn_missing_plugin(skin)
    else
      igniter
      |> drop_skin_block(component, skin)
      |> Igniter.add_notice(
        "No #{skin} skin for #{component} yet — generated unstyled. " <>
          "Style it with the `chelekom-#{component}__*` classes and its `data-*` state."
      )
    end
  end

  # The skin fragment is the source of truth. When one is deleted — a component whose styling has
  # moved into markup — its block has to leave the vendored stylesheet too, or regeneration keeps
  # serving CSS no source can explain and the file never shrinks.
  defp drop_skin_block(igniter, component, skin) do
    vendor = "assets/vendor/mishka_chelekom_headless_#{skin}.css"

    if Igniter.exists?(igniter, vendor) do
      Igniter.update_file(igniter, vendor, fn source ->
        content = Rewrite.Source.get(source, :content)
        Rewrite.Source.update(source, :content, delete_skin_block(content, component))
      end)
    else
      igniter
    end
  end

  defp delete_skin_block(content, component) do
    pattern =
      ~r/\n*#{Regex.escape("/* >>> #{component} */")}.*?#{Regex.escape("/* <<< #{component} */")}\n?/s

    content
    |> then(&Regex.replace(pattern, &1, ""))
    |> String.trim_trailing()
    |> Kernel.<>("\n")
  end

  # A skin is a default, not an override: `@layer components` puts it below Tailwind's utilities
  # AND below the design system's own classes (daisyUI emits into `utilities`), so the per-part
  # class attributes and the system's own modifiers still win. An optional scope nests inside it.
  # CSS nesting does the scoping — no selector rewriting, so an unparsed fragment stays intact.
  defp wrap_css(css, scope) do
    css
    |> String.trim_trailing()
    |> then(&if(scope in [nil, ""], do: &1, else: "#{scope} {\n#{indent(&1)}\n}"))
    |> then(&"@layer components {\n#{indent(&1)}\n}\n")
  end

  defp indent(css), do: String.replace(css, ~r/^(?!$)/m, "  ")

  defp skin_header(skin) do
    """
    /* Mishka Chelekom — headless #{skin} skin.
     *
     * PRESENTATION ONLY: color, spacing, sizing and transitions painted onto the classes and
     * `data-*` state the headless components already emit. Behavior, markup and ARIA are
     * untouched. Generated per component by `mix mishka.ui.gen.headless <name> --skin #{skin}`;
     * each block below is rewritten in place on regeneration.
     */

    """
  end

  # One `/* >>> name */ … /* <<< name */` block per component: replaced when present, appended when not.
  defp put_skin_block(content, component, css) do
    open = "/* >>> #{component} */"
    close = "/* <<< #{component} */"
    block = "#{open}\n#{String.trim_trailing(css)}\n#{close}\n"

    pattern = ~r/#{Regex.escape(open)}.*?#{Regex.escape(close)}\n?/s

    if Regex.match?(pattern, content) do
      Regex.replace(pattern, content, block)
    else
      String.trim_trailing(content) <> "\n\n" <> block
    end
  end

  # Asked of the parsed stylesheet, not of its bytes: the skin's own `@import` line contains the
  # design system's name, so a substring check answers "yes, it's loaded" for a project that has
  # only ever imported our stylesheet — exactly the project that needs the notice.
  defp warn_missing_plugin(igniter, skin) do
    with {:ok, source} <- File.read("assets/css/app.css"),
         {:ok, [_ | _]} <- plugin_rules(source, skin) do
      igniter
    else
      _ -> Igniter.add_notice(igniter, missing_plugin_message(skin))
    end
  end

  defp missing_plugin_message(skin) do
    """
    The #{skin} skin needs #{skin} itself loaded in assets/css/app.css, e.g.

        @plugin "#{skin}";

    The prefix is read back out of that block, so a prefixed plugin needs no extra flag.
    """
  end

  # Idempotently adds a vendor `@import` to app.css. `IgniterCss` parses the file rather than
  # pattern-matching it, so the import lands after the at-rule prologue, comments survive, a second
  # run is a no-op, and — because the codemod goes through Igniter — the change is visible to the
  # diff preview and to tests instead of being written behind Igniter's back.
  defp add_vendor_import(igniter, app_css, import_path) do
    if File.exists?(app_css) or igniter.rewrite.sources[app_css] do
      IgniterCss.Codemods.add_import(igniter, app_css, import_path)
    else
      Igniter.add_notice(
        igniter,
        "Could not find #{app_css} — add `@import \"#{import_path}\";` manually."
      )
    end
  end
end
