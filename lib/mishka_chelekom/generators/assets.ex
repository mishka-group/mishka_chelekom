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
    scripts = Keyword.get(config, :scripts, [])
    npm = npm_packages(config)

    if scripts == [] and npm == [] do
      igniter
    else
      igniter
      |> check_package_json(npm, options)
      |> update_js_files(config)
      |> copy_user_files(config)
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
  @spec npm_packages(keyword()) :: [String.t()]
  def npm_packages(config) do
    config
    |> Keyword.get(:npm, default_lib_npm(config))
    |> Enum.map(fn
      %{name: name, version: version} -> "#{name}@#{version}"
      %{name: name} -> name
      dep when is_binary(dep) -> dep
    end)
  end

  defp default_lib_npm(config) do
    case Keyword.get(config, :libs, []) do
      [] ->
        []

      libs ->
        {_name, lib} =
          Enum.find(libs, List.first(libs), fn {_name, lib} ->
            Keyword.get(lib, :default, false)
          end)

        Keyword.get(lib, :npm, [])
    end
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

  defp update_js_files(igniter, template_config) do
    files = Keyword.get(template_config, :scripts, []) |> Enum.filter(&(&1.type == "file"))

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

          if !is_nil(content) do
            # `create_or_update_file/4` only uses this when the file is absent, and it reads an
            # existing one through the rewrite — so never touch the real filesystem here, or the
            # whole wiring step becomes untestable (and wrong under `Igniter.Test`).
            caller_js = File.read!(Core.lib_priv("assets/js/mishka_components.js"))

            acc
            |> Igniter.create_or_update_file("assets/vendor/#{item.file}", content, fn source ->
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

  # Idempotently adds a vendor `@import` to app.css using the same parser the styled side uses
  # (regex dedup + correct Tailwind-4 ordering), so it never duplicates and never lands before
  # `@import "tailwindcss";`. Never rewrites the rest of the user's app.css.
  defp add_vendor_import(igniter, app_css, import_path) do
    case File.read(app_css) do
      {:ok, content} ->
        case SimpleCSSUtilities.add_import(content, import_path) do
          {:ok, :exists, _} ->
            igniter

          {:ok, :added, updated} ->
            Igniter.create_or_update_file(igniter, app_css, updated, fn source ->
              Rewrite.Source.update(source, :content, updated)
            end)

          {:error, _, _} ->
            Igniter.add_notice(
              igniter,
              "Could not update #{app_css} — add `@import \"#{import_path}\";` manually."
            )
        end

      _ ->
        Igniter.add_notice(
          igniter,
          "Could not find #{app_css} — add `@import \"#{import_path}\";` manually."
        )
    end
  end
end
