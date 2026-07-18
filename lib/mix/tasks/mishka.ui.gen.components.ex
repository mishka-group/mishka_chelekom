defmodule Mix.Tasks.Mishka.Ui.Gen.Components do
  use Igniter.Mix.Task

  alias MishkaChelekom.Config
  alias MishkaChelekom.Generators.{Assets, Core, ImportMacro}

  @example "mix mishka.ui.gen.components component1,component2"
  @shortdoc "A Mix Task for generating and configuring multi components of Phoenix"
  @moduledoc """
  #{@shortdoc}

  A Mix Task for generating and configuring multi components of Phoenix

  > This task does not do any additional work compared to the `mix mishka.ui.gen.component` task,
  > it just creates all the components in one place. For this purpose, all components
  > are created with default arguments.

  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * `--import` - Generates import file
  * `--helpers` - Specifies helper functions of each component in import file
  * `--global` - Makes components accessible throughout the project without explicit imports
  * `--exclude` - Comma-separated list of components to exclude (e.g., `--exclude alert,badge`)
  * `--component-prefix` - Prefix for all component function names (e.g., `--component-prefix mishka_`)
  * `--module-prefix` - Prefix for module names (e.g., `--module-prefix mishka_` makes Chat become MishkaChat)
  * `--no-save` - Use prefixes without saving them to config file
  * `--yes` - Makes directly without questions
  """

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      # dependencies to add
      adds_deps: [],
      # dependencies to add and call their associated installers, if they exist
      installs: [],
      # An example invocation
      example: @example,
      # Accept additional arguments that are not in your schema
      # Does not guarantee that, when composed, the only options you get are the ones you define
      extra_args?: false,
      # A list of environments that this should be installed in, only relevant if this is an installer.
      only: nil,
      # a list of positional arguments, i.e `[:file]`
      positional: [{:components, optional: true}],
      group: :mishka_chelekom,
      # Other tasks your task composes using `Igniter.compose_task`, passing in the CLI argv
      # This ensures your option schema includes options from nested tasks
      composes: ["mishka.ui.gen.component"],
      # `OptionParser` schema
      schema: [
        import: :boolean,
        helpers: :boolean,
        global: :boolean,
        exclude: :csv,
        component_prefix: :string,
        module_prefix: :string,
        no_save: :boolean,
        no_npm: :boolean,
        sub: :boolean
      ],
      # CLI aliases
      aliases: [i: :import, g: :global, e: :exclude]
    }
  end

  def igniter(igniter) do
    # Based on https://github.com/fuelen/owl/issues/27
    Application.ensure_all_started(:owl)
    %Igniter.Mix.Task.Args{positional: %{components: components}, options: options} = igniter.args

    print_banner(options)
    user_config = Config.load_user_config(igniter)
    print_exclusions(user_config, options)
    print_filters(user_config)

    tty? = IO.ANSI.enabled?()
    if tty?, do: Owl.Spinner.start(id: :my_spinner, labels: [processing: "Please wait..."])

    list = Core.resolve_components(igniter, components, :styled, user_config, options[:exclude])

    child_args =
      ["--no-deps", "--sub", "--yes"]
      |> Core.append_arg("--component-prefix", options[:component_prefix])
      |> Core.append_arg("--module-prefix", options[:module_prefix])
      |> then(&if(options[:no_npm], do: &1 ++ ["--no-npm"], else: &1))

    igniter =
      igniter
      |> Igniter.assign(:mishka_user_config, user_config)
      |> Core.fan_out("mishka.ui.gen.component", list, child_args)
      |> ImportMacro.create(list,
        import: options[:import],
        helpers: options[:helpers],
        global: options[:global],
        component_prefix: options[:component_prefix],
        module_prefix: options[:module_prefix]
      )
      |> Assets.setup_styled_css([])
      |> Core.maybe_save_prefixes(options)

    if tty? do
      if Map.get(igniter, :issues, []) == [],
        do: Owl.Spinner.stop(id: :my_spinner, resolution: :ok, label: "Done"),
        else: Owl.Spinner.stop(id: :my_spinner, resolution: :error, label: "Error")
    end

    igniter
  end

  defp print_banner(options) do
    if !options[:sub] and Mix.env() != :test, do: Core.banner(IO.ANSI.red(), "Components")
    :ok
  end

  defp print_exclusions(user_config, options) do
    all_excluded =
      Enum.uniq((user_config[:exclude_components] || []) ++ (options[:exclude] || []))

    if all_excluded != [] do
      IO.puts(
        "\n#{IO.ANSI.yellow()}Excluding components: #{inspect(all_excluded)}#{IO.ANSI.reset()}"
      )
    end
  end

  defp print_filters(user_config) do
    filter_info =
      []
      |> maybe_add_filter("Colors", user_config[:component_colors])
      |> maybe_add_filter("Variants", user_config[:component_variants])
      |> maybe_add_filter("Sizes", user_config[:component_sizes])
      |> maybe_add_filter("Rounded", user_config[:component_rounded])
      |> maybe_add_filter("Padding", user_config[:component_padding])
      |> maybe_add_filter("Space", user_config[:component_space])

    if filter_info != [] do
      IO.puts("#{IO.ANSI.cyan()}Component filters from config:#{IO.ANSI.reset()}")

      Enum.each(filter_info, fn info ->
        IO.puts("  #{IO.ANSI.cyan()}• #{info}#{IO.ANSI.reset()}")
      end)
    end
  end

  defp maybe_add_filter(list, _label, nil), do: list
  defp maybe_add_filter(list, _label, []), do: list
  defp maybe_add_filter(list, label, values), do: list ++ ["#{label}: #{inspect(values)}"]
end
