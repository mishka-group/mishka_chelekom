defmodule Mix.Tasks.Mishka.Ui.Gen.Headless.Components do
  use Igniter.Mix.Task

  alias MishkaChelekom.Config
  alias MishkaChelekom.Generators.{Assets, Core, ImportMacro}

  @example "mix mishka.ui.gen.headless.components dialog,tabs"
  @shortdoc "Generate multiple (or all) headless components at once"
  @moduledoc """
  #{@shortdoc}

  Pass a comma-separated list of headless component names, or omit it (or pass `all`) to
  generate every component in `priv/headless/`.

  ## Example

  ```bash
  #{@example}
  mix mishka.ui.gen.headless.components       # all of them
  ```

  ## Options

  * `--exclude` - Comma-separated names to skip
  * `--component-prefix` - Prefix for public function names
  * `--module-prefix` - Prefix for module names
  * `--no-save` - Use prefixes without saving them to config
  * `--import` or `-i` - Generates `<App>Web.Components.MishkaHeadlessComponents`, a `use` macro
    importing the generated headless modules (separate from the styled `MishkaComponents`)
  * `--helpers` - Also imports each component's helper functions in that macro
  * `--global` or `-g` - Adds `use MishkaHeadlessComponents` to `html_helpers/0`, so headless
    components work in every view without explicit imports
  * `--with-npm` - Also generate components that install npm packages (skipped by default)
  """

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      example: @example,
      positional: [{:components, optional: true}],
      group: :mishka_chelekom,
      composes: ["mishka.ui.gen.headless"],
      schema: [
        exclude: :csv,
        import: :boolean,
        helpers: :boolean,
        global: :boolean,
        component_prefix: :string,
        module_prefix: :string,
        no_save: :boolean,
        no_npm: :boolean,
        with_npm: :boolean
      ],
      aliases: [i: :import, g: :global, e: :exclude]
    }
  end

  def supports_umbrella?, do: false

  def igniter(igniter) do
    Application.ensure_all_started(:owl)
    %Igniter.Mix.Task.Args{positional: %{components: components}, options: options} = igniter.args

    print_banner()
    user_config = Config.load_user_config(igniter)

    tty? = IO.ANSI.enabled?()
    if tty?, do: Owl.Spinner.start(id: :my_spinner, labels: [processing: "Please wait..."])

    list =
      Core.resolve_components(igniter, components, :headless, user_config, options[:exclude],
        with_npm: options[:with_npm]
      )

    child_args =
      ["--sub", "--yes"]
      |> Core.append_arg("--component-prefix", options[:component_prefix])
      |> Core.append_arg("--module-prefix", options[:module_prefix])
      |> then(&if(options[:no_npm], do: &1 ++ ["--no-npm"], else: &1))

    igniter =
      igniter
      |> Igniter.assign(:mishka_user_config, user_config)
      |> Core.fan_out("mishka.ui.gen.headless", list, child_args)
      |> ImportMacro.create(list,
        layer: :headless,
        import: options[:import],
        helpers: options[:helpers],
        global: options[:global],
        component_prefix: options[:component_prefix],
        module_prefix: options[:module_prefix]
      )
      |> Assets.setup_headless_css([])
      |> Core.maybe_save_prefixes(options)

    Core.stop_spinner(igniter, tty?)
  end

  defp print_banner, do: Core.banner(IO.ANSI.blue(), "Headless")
end
