defmodule Mix.Tasks.Mishka.Assets.Deps.Docs do
  @moduledoc false

  @spec short_doc() :: String.t()
  def short_doc do
    "A Mix Task for installing and configuring JS dependencies for Phoenix"
  end

  @spec example() :: String.t()
  def example do
    "mix mishka.assets.deps deps --example"
  end

  @spec long_doc() :: String.t()
  def long_doc do
    """
    #{short_doc()}

    ## Example

    ```sh
    #{example()}
    ```

    ## Options

    * `--bun` - Specifies Bun as package manager to install dependencies
    * `--mix-bun` - Specifies Bun hex package/binary as package manager to install dependencies
    * `--npm` - Specifies npm as package manager to install dependencies
    * `--yarn` - Specifies yarn as package manager to install dependencies
    * `--dev` - Specifies the dependencies you want to install in devDependencies
    * `--remove` - Removes the specified dependencies instead of installing them
    * `--yes` - Makes directly without questions
    """
  end
end

if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.Mishka.Assets.Deps do
    @shortdoc "#{__MODULE__.Docs.short_doc()}"
    @moduledoc __MODULE__.Docs.long_doc()
    use Igniter.Mix.Task

    alias MishkaChelekom.Generators.Core
    alias MishkaChelekom.Generators.Npm

    @impl Igniter.Mix.Task
    def info(_argv, _composing_task) do
      %Igniter.Mix.Task.Info{
        group: :mishka_chelekom,
        adds_deps: [],
        installs: [],
        example: __MODULE__.Docs.example(),
        only: nil,
        positional: [:deps],
        composes: [],
        schema: [
          bun: :boolean,
          npm: :boolean,
          yarn: :boolean,
          mix_bun: :boolean,
          test: :boolean,
          dev: :boolean,
          remove: :boolean
        ],
        defaults: [],
        aliases: [],
        required: []
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      Application.ensure_all_started(:owl)
      %Igniter.Mix.Task.Args{positional: %{deps: deps}} = igniter.args
      options = igniter.args.options

      package_manager = Npm.detect(options)

      if !options[:test], do: Core.banner(IO.ANSI.light_yellow(), "Assets")

      tty? = IO.ANSI.enabled?()
      spin? = !options[:test] and tty?
      if spin?, do: Owl.Spinner.start(id: :my_spinner, labels: [processing: "Please wait..."])

      final =
        igniter
        |> Npm.ensure_package_json_exists()
        |> handle_deps(String.split(deps, ","), options)
        |> Npm.check_package_manager(package_manager)
        |> Npm.run_command(options)

      if spin? do
        if Map.get(final, :issues, []) == [],
          do: Owl.Spinner.stop(id: :my_spinner, resolution: :ok, label: "Done"),
          else: Owl.Spinner.stop(id: :my_spinner, resolution: :error, label: "Error")
      end

      final
    end

    defp handle_deps(igniter, deps, options) do
      if options[:remove] do
        Npm.remove_deps(igniter, deps, options)
      else
        Npm.add_deps(igniter, deps, options)
      end
    end

    # Kept as thin delegations: these were this task's public API before the shared
    # MishkaChelekom.Generators.Npm module existed, and other call sites may rely on them.
    defdelegate ensure_package_json_exists(igniter), to: Npm
    defdelegate update_package_json_deps(igniter, deps, options \\ []), to: Npm, as: :add_deps
    defdelegate remove_package_json_deps(igniter, deps, options \\ []), to: Npm, as: :remove_deps
    defdelegate check_package_manager(igniter, manager), to: Npm
    defdelegate run_command(igniter, options), to: Npm
  end
else
  defmodule Mix.Tasks.Mishka.Assets.Deps.Install do
    @shortdoc "#{__MODULE__.Docs.short_doc()} | Install `igniter` to use"

    @moduledoc __MODULE__.Docs.long_doc()

    use Mix.Task

    @impl Mix.Task
    def run(_argv) do
      Mix.shell().error("""
      The task 'mishka.assets.deps' requires igniter. Please install igniter and try again.

      For more information, see: https://hexdocs.pm/igniter/readme.html#installation
      """)

      exit({:shutdown, 1})
    end
  end
end
