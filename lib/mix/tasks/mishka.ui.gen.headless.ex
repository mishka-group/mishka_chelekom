defmodule Mix.Tasks.Mishka.Ui.Gen.Headless do
  use Igniter.Mix.Task

  alias Mix.Tasks.Mishka.Ui.Gen.Component
  alias MishkaChelekom.Generators.Core
  alias MishkaChelekom.Config
  alias Igniter.Project.Application, as: IAPP

  @example "mix mishka.ui.gen.headless dialog"
  @shortdoc "Generate an unstyled (headless) Phoenix component: ARIA + slots + behavior hook"
  @moduledoc """
  #{@shortdoc}

  Headless components ship **no opinionated styling** — only semantic markup, full WAI-ARIA
  wiring, named slots (anatomy "parts"), structural base classes (`chelekom-<comp>__<part>`),
  CSS custom properties, and `data-*` paired-presence state (`data-open`/`data-closed`,
  `data-highlighted`, …). Behavior is delegated to the shared JS engines.

  Output goes to `lib/<app>_web/components/headless/<name>.ex` (module
  `<App>Web.Components.Headless.<Name>`), so styled and headless components coexist.

  Templates live in `priv/headless/<name>.eex` (+ `<name>.exs` catalog). There are **no**
  `--color/--variant/--size/--padding` options — they are meaningless for headless.

  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * `--module` or `-m` - Custom module name for the component
  * `--component-prefix` - Prefix for the public function name
  * `--module-prefix` - Prefix for the module name
  * `--sub` - Marks this as a dependency sub-generation
  * `--no-deps` - Do not generate dependent components
  * `--no-save` - Use prefixes without saving them to config
  * `--yes` - Apply without prompts
  """

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      example: @example,
      positional: [:component],
      schema: [
        module: :string,
        component_prefix: :string,
        module_prefix: :string,
        sub: :boolean,
        no_deps: :boolean,
        no_save: :boolean
      ],
      aliases: [m: :module]
    }
  end

  def supports_umbrella?(), do: false

  def igniter(igniter) do
    %Igniter.Mix.Task.Args{positional: %{component: component}} = igniter.args
    options = igniter.args.options

    if !options[:sub] and Mix.env() != :test do
      IO.puts(IO.ANSI.cyan() <> "Mishka Chelekom · headless" <> IO.ANSI.reset())
    end

    user_config = Config.load_user_config(igniter)

    igniter
    |> Igniter.assign(%{mishka_user_config: user_config})
    |> Component.check_dependencies_versions()
    |> resolve_template(component)
    |> compute_output(options)
    |> build_assigns(options)
    |> write_component(options)
    |> wire_scripts()
    |> setup_headless_css(options)
  end

  # --- pipeline -----------------------------------------------------------------------

  defp resolve_template(igniter, component) do
    component = component |> String.replace(" ", "") |> Macro.underscore()
    path = Core.lib_priv("headless/#{component}.eex")
    config_path = Path.rootname(path) <> ".exs"

    case {File.exists?(path), File.exists?(config_path)} do
      {true, true} ->
        config =
          Elixir.Config.Reader.read!(config_path)[Component.component_to_atom(component)]

        case Core.validate_catalog(config) do
          {:ok, config} ->
            %{igniter: igniter, component: component, path: path, config: config}

          {:error, reason} ->
            {:error, "Invalid headless catalog for #{component}: #{reason}", igniter}
        end

      _ ->
        {:error,
         "Headless component #{inspect(component)} not found in priv/headless/. " <>
           "Run `mix mishka.ui.gen.headless` with a valid name.", igniter}
    end
  end

  defp compute_output({:error, _, _} = error, _options), do: error

  defp compute_output(%{igniter: igniter} = template, options) do
    web_dir = "#{IAPP.app_name(igniter)}_web"

    module_prefix =
      Keyword.get(options, :module_prefix) ||
        get_in(igniter.assigns, [:mishka_user_config, :module_prefix])

    name_part =
      if module_prefix && module_prefix != "" do
        "#{module_prefix}#{template.component}"
      else
        template.component
      end

    # Build the module atom the same way the styled task does (String.to_atom of a dotted
    # CamelCase string) so `<%= @module %>` renders a clean `defmodule` without the Elixir. prefix.
    module =
      case Keyword.get(options, :module) do
        nil -> Component.atom_to_module("#{web_dir}.components.headless.#{name_part}")
        custom -> Component.atom_to_module(custom)
      end

    location = "lib/#{web_dir}/components/headless/#{name_part}.ex"

    igniter =
      Map.update!(igniter, :assigns, fn assigns ->
        assigns
        |> Map.put_new(:igniter_exs, [])
        |> Map.update!(:igniter_exs, fn exs ->
          Keyword.update(exs, :dont_move_files, [location], &[location | &1])
        end)
      end)

    Map.merge(template, %{igniter: igniter, module: module, location: location})
  end

  defp build_assigns({:error, _, _} = error, _options), do: error

  defp build_assigns(%{config: config} = template, options) do
    component_prefix =
      Keyword.get(options, :component_prefix) ||
        get_in(template.igniter.assigns, [:mishka_user_config, :component_prefix])

    module_prefix = Keyword.get(options, :module_prefix) || ""

    module_prefix_camel =
      if module_prefix != "", do: module_prefix |> String.trim_trailing("_") |> Macro.camelize(), else: ""

    # Nil-fill any declared catalog args so templates never hit "undefined variable".
    arg_assigns =
      (config[:args] || [])
      |> Keyword.keys()
      |> Enum.map(&{&1, nil})

    assigns =
      arg_assigns
      |> Keyword.merge(
        module: template.module,
        web_module: Igniter.Libs.Phoenix.web_module(template.igniter),
        component_prefix: component_prefix,
        module_prefix_camel: module_prefix_camel
      )

    Map.put(template, :assigns, assigns)
  end

  defp write_component({:error, msg, igniter}, _options), do: Igniter.add_issue(igniter, msg)

  defp write_component(%{igniter: igniter} = template, _options) do
    igniter =
      Igniter.copy_template(igniter, template.path, template.location, template.assigns,
        on_exists: :overwrite
      )

    {igniter, template.config}
  end

  defp wire_scripts({igniter, config}) do
    Component.create_or_update_scripts({igniter, config})
  end

  defp wire_scripts(%Igniter{} = igniter), do: igniter

  # Install the functional (color-free) headless base stylesheet and import it once.
  defp setup_headless_css(%Igniter{} = igniter, options) do
    if options[:sub] do
      igniter
    else
      css = File.read!(Core.lib_priv("assets/css/chelekom_headless.css"))

      igniter
      |> Igniter.create_or_update_file(
        "assets/vendor/chelekom_headless.css",
        css,
        &Rewrite.Source.update(&1, :content, css)
      )
      |> ensure_css_import()
    end
  end

  defp ensure_css_import(igniter) do
    app_css = "assets/css/app.css"
    import_line = ~s|@import "../vendor/chelekom_headless.css";|

    case File.read(app_css) do
      {:ok, content} ->
        if String.contains?(content, "chelekom_headless.css") do
          igniter
        else
          updated = import_line <> "\n" <> content

          Igniter.create_or_update_file(
            igniter,
            app_css,
            updated,
            &Rewrite.Source.update(&1, :content, updated)
          )
        end

      _ ->
        Igniter.add_notice(
          igniter,
          "Could not find assets/css/app.css — add `@import \"../vendor/chelekom_headless.css\";` manually."
        )
    end
  end
end
