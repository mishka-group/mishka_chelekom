defmodule Mix.Tasks.Mishka.Ui.Gen.Headless do
  use Igniter.Mix.Task

  alias Igniter.Project.Application, as: IAPP
  alias MishkaChelekom.Config
  alias MishkaChelekom.Generators.{Assets, Core}

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
  * `--no-save` - Use prefixes without saving them to config
  * `--no-npm` - Write everything but skip installing the component's npm packages
  * `--lib` - For components with several engines, which external library to use (e.g. `--lib tiptap`)
  * `--yes` - Apply without prompts
  """

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      example: @example,
      positional: [:component],
      group: :mishka_chelekom,
      schema: [
        module: :string,
        component_prefix: :string,
        module_prefix: :string,
        sub: :boolean,
        no_save: :boolean,
        no_npm: :boolean,
        lib: :string
      ],
      aliases: [m: :module]
    }
  end

  def supports_umbrella?(), do: false

  def igniter(igniter) do
    Application.ensure_all_started(:owl)
    %Igniter.Mix.Task.Args{positional: %{component: component}, options: options} = igniter.args

    print_banner(options)

    tty? = IO.ANSI.enabled?()
    spin? = !options[:sub] and Mix.env() != :test and tty?
    if spin?, do: Owl.Spinner.start(id: :my_spinner, labels: [processing: "Please wait..."])

    final =
      igniter
      |> Igniter.assign(:mishka_user_config, Config.load_user_config(igniter))
      |> Core.check_dependencies()
      |> resolve_template(component)
      |> validate_lib()
      |> compute_location()
      |> build_eex_assigns()
      |> write_component()
      |> wire_scripts()
      |> maybe_setup_css()
      |> maybe_save_prefixes()

    if spin? do
      if Map.get(final, :issues, []) == [],
        do: Owl.Spinner.stop(id: :my_spinner, resolution: :ok, label: "Done"),
        else: Owl.Spinner.stop(id: :my_spinner, resolution: :error, label: "Error")
    end

    final
  end

  defp print_banner(options) do
    if !options[:sub] and Mix.env() != :test, do: Core.banner(IO.ANSI.cyan(), "Headless")
    :ok
  end

  defp resolve_template(igniter, component) do
    case Core.fetch_catalog(igniter, component, :headless) do
      {:ok, template} ->
        igniter
        |> Igniter.assign(:component_name, template.component)
        |> Igniter.assign(:template_path, template.path)
        |> Igniter.assign(:template_config, template.config)

      {:error, {:not_found, _path}} ->
        Igniter.add_issue(
          igniter,
          "Headless component #{inspect(component)} not found in priv/headless/. " <>
            "Run `mix mishka.ui.gen.headless` with a valid name."
        )

      {:error, {:bad_catalog, reason, _config_path}} ->
        Igniter.add_issue(igniter, "Invalid headless catalog for #{component}: #{reason}")
    end
  end

  defp validate_lib(%{assigns: %{template_config: config}} = igniter) do
    requested = igniter.args.options[:lib]
    known = Assets.lib_names(config)

    cond do
      is_nil(requested) ->
        igniter

      known == [] ->
        Igniter.add_issue(
          igniter,
          "--lib was given but #{igniter.assigns.component_name} has a single engine."
        )

      requested in known ->
        igniter

      true ->
        Igniter.add_issue(
          igniter,
          "Unknown --lib #{inspect(requested)}. #{igniter.assigns.component_name} supports: " <>
            Enum.join(known, ", ")
        )
    end
  end

  defp validate_lib(igniter), do: igniter

  defp compute_location(%{assigns: %{component_name: _}} = igniter) do
    options = igniter.args.options
    component = igniter.assigns.component_name
    web_dir = "#{IAPP.app_name(igniter)}_web"

    module_prefix =
      options[:module_prefix] || get_in(igniter.assigns, [:mishka_user_config, :module_prefix])

    name_part =
      if module_prefix && module_prefix != "" do
        "#{module_prefix}#{component}"
      else
        component
      end

    module =
      case options[:module] do
        nil -> Core.module_atom("#{web_dir}.components.headless.#{name_part}")
        custom -> Core.module_atom(custom)
      end

    location = "lib/#{web_dir}/components/headless/#{name_part}.ex"

    igniter
    |> Core.track_generated_file(location)
    |> Igniter.assign(:component_module, module)
    |> Igniter.assign(:proper_location, location)
  end

  defp compute_location(igniter), do: igniter

  defp build_eex_assigns(%{assigns: %{component_module: _}} = igniter) do
    options = igniter.args.options
    config = igniter.assigns.template_config

    component_prefix =
      options[:component_prefix] ||
        get_in(igniter.assigns, [:mishka_user_config, :component_prefix])

    assigns =
      Core.eex_assigns(igniter, igniter.assigns.component_module, config,
        component_prefix: component_prefix,
        module_prefix: options[:module_prefix] || ""
      )

    Igniter.assign(igniter, :eex_assigns, assigns)
  end

  defp build_eex_assigns(igniter), do: igniter

  defp write_component(%{assigns: %{eex_assigns: _}} = igniter) do
    Igniter.copy_template(
      igniter,
      igniter.assigns.template_path,
      igniter.assigns.proper_location,
      igniter.assigns.eex_assigns,
      on_exists: :overwrite
    )
  end

  defp write_component(igniter), do: igniter

  defp wire_scripts(%{assigns: %{eex_assigns: _}} = igniter),
    do: Assets.wire_scripts(igniter, igniter.assigns.template_config, igniter.args.options)

  defp wire_scripts(igniter), do: igniter

  defp maybe_setup_css(igniter), do: Assets.setup_headless_css(igniter, igniter.args.options)

  defp maybe_save_prefixes(igniter), do: Core.maybe_save_prefixes(igniter, igniter.args.options)
end
