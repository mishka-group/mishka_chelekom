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
  alias MishkaChelekom.Config
  alias MishkaChelekom.SimpleCSSUtilities

  @doc """
  Copies a component's JS engine files into `assets/vendor/` and wires their imports/hooks into
  `mishka_components.js` and `app.js`. No-op when the catalog declares no `:scripts`.
  """
  @spec wire_scripts(Igniter.t(), keyword()) :: Igniter.t()
  def wire_scripts(igniter, config) do
    if Keyword.get(config, :scripts, []) != [] do
      igniter
      |> check_package_json(config)
      |> update_js_files(config)
    else
      igniter
    end
  end

  defp check_package_json(igniter, _) do
    # TODO: for now we have no plan for it, it needs some way to handle npm, \
    # bun or etc and create init files like
    # TODO: package.json. why we need this? for example, add DOMPurify \
    # to sanitizer client side input or adding js project
    igniter
  end

  defp update_js_files(igniter, template_config) do
    files = Keyword.get(template_config, :scripts) |> Enum.filter(&(&1.type == "file"))

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
            caller_js =
              case File.read("assets/vendor/mishka_components.js") do
                {:ok, content} ->
                  content

                _ ->
                  File.read!(Core.lib_priv("assets/js/mishka_components.js"))
              end

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

      case File.read(app_js) do
        {:ok, content} ->
          igniter
          |> Igniter.create_or_update_file(app_js, content, fn source ->
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
                Igniter.add_issue(igniter, "#{inspect(error)}")
            end
          end)

        _ ->
          msg = """
          Note:
          Unfortunately, we couldn't find the assets/js/app.js file in your project path.
          """

          Igniter.add_issue(igniter, msg)
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
