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
    * `--yes` - Makes directly without questions
    """
  end
end

if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.Mishka.Assets.Deps do
    @shortdoc "#{__MODULE__.Docs.short_doc()}"
    @moduledoc __MODULE__.Docs.long_doc()
    @pkgs [:npm, :bun, :yarn]
    use Igniter.Mix.Task

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
          sub: :boolean,
          dev: :boolean
        ],
        defaults: [],
        aliases: [],
        required: []
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      %Igniter.Mix.Task.Args{positional: %{deps: deps}, argv: argv} = igniter.args
      options = options!(argv)
      IO.inspect(options)

      package_manager =
        cond do
          options[:bun] -> :bun
          options[:npm] -> :npm
          options[:yarn] -> :yarn
          options[:mix_bun] -> nil
          true -> Enum.find(@pkgs, &(Keyword.get(options, &1) == true))
        end

      if !options[:sub] do
        msg =
          """
                .-.
               /'v'\\
              (/   \\)
              =="="==
            Mishka.tools
          """

        IO.puts(IO.ANSI.light_yellow() <> String.trim_trailing(msg) <> IO.ANSI.reset())
      end

      igniter
      |> ensure_package_json_exists()
      |> update_package_json_deps(String.split(deps, ","), options)
      |> check_package_manager(package_manager)
      |> run_install()
    end

    def check_package_manager(igniter, manager) when manager in @pkgs do
      if Igniter.has_changes?(igniter) do
        new_igniter =
          case System.find_executable(Atom.to_string(manager)) do
            nil ->
              igniter
              |> Igniter.add_warning("""
              Note:
              #{manager} not found.
              Please install it or let us to use binary Bun that does not need to be installed.
              """)
              |> check_package_manager(nil)

            _path ->
              igniter
              |> Igniter.assign(:package_manager, manager)
          end

        new_igniter
      else
        igniter
      end
    end

    def check_package_manager(igniter, nil) do
      if Igniter.has_changes?(igniter) do
        config_ast =
          quote do
            [args: ["install"], cd: Path.expand("../assets", __DIR__)]
          end

        dep_ast =
          quote do
            [runtime: Mix.env() == :dev]
          end

        igniter =
          igniter
          |> Igniter.add_warning("""
          No package manager found. We can install bun as a mix dependency.
          This will add {:bun, "~> 1.0"} to your mix.exs and make bun available.
          """)

        case Igniter.Project.Deps.get_dep(igniter, :bun) do
          {:ok, dep} when not is_nil(dep) ->
            igniter

          _ ->
            igniter
            |> Igniter.Project.Deps.add_dep({:bun, "~> 1.0", dep_ast})
        end
        |> Igniter.Project.Config.configure_new("config.exs", :bun, [:version], "1.2.14")
        |> Igniter.Project.Config.configure_new(
          "config.exs",
          :bun,
          [:install],
          {:code, config_ast}
        )
        |> Igniter.assign(:package_manager, :bun)
        |> Igniter.assign(:package_manager_type, "mix")
      else
        igniter
      end
    end

    def ensure_package_json_exists(igniter) do
      package_json_path = "assets/package.json"

      if Igniter.exists?(igniter, package_json_path) do
        igniter
      else
        default_package_json = """
        {
          "name": "#{Igniter.Project.Application.app_name(igniter)}",
          "version": "1.0.0",
          "description": "Assets for #{Igniter.Project.Application.app_name(igniter)} Phoenix application",
          "dependencies": {},
          "devDependencies": {}
        }
        """

        igniter
        |> Igniter.create_new_file(package_json_path, default_package_json)
        |> Igniter.add_notice("""
        Created package.json in assets directory.
        You may want to customize the name, description, and etc for your project.
        """)
      end
    end

    def update_package_json_deps(igniter, deps, options \\ []) do
      package_json_path = "assets/package.json"
      parsed_deps = parse_deps(deps)
      deps_key = if options[:dev], do: "devDependencies", else: "dependencies"

      new_igniter =
        igniter
        |> Igniter.update_file(package_json_path, fn source ->
          original_content = Rewrite.Source.get(source, :content)

          case Jason.decode(original_content) do
            {:ok, json} ->
              existing_deps = Map.get(json, deps_key, %{})

              formatted =
                Enum.reduce(parsed_deps, existing_deps, fn {name, version}, acc ->
                  Map.put(acc, name, version)
                end)
                |> then(&Map.put(json, deps_key, &1))
                |> Jason.encode!(pretty: true)
                |> Kernel.<>("\n")

              Rewrite.Source.update(source, :content, formatted)

            {:error, _} ->
              source
              |> Rewrite.Source.add_issue(
                "Failed to parse package.json. Ensure it contains valid JSON."
              )
          end
        end)

      new_igniter
    end

    def run_install(igniter) do
      if Igniter.has_changes?(igniter) do
        package_manager = Map.get(igniter.assigns, :package_manager, :npm)
        pkg_type = Map.get(igniter.assigns, :package_manager_type, "pkg")

        igniter
        |> Igniter.add_task("mishka.assets.install", [Atom.to_string(package_manager), pkg_type])
        |> Igniter.add_notice(
          IO.ANSI.yellow() <>
            """
            Note:
            Unfortunately, JavaScript has developed a problematic ecosystem over several years.
            For this reason, even if we check many things, errors still occur during the download
            and installation of packages, which are very difficult to manage in scripts.

            Therefore, in case of errors, you need to manage them manually.
            However, in the past year, we've had a very good experience with Bun and highly recommend it.
            It's worth mentioning that if you're using Docker, you need to specify during build time
            that you have JS packages that need to be built.
            """ <> IO.ANSI.reset()
        )
      else
        igniter
      end
    end

    defp parse_deps(deps) when is_list(deps) do
      Enum.map(deps, fn dep ->
        case String.split(dep, "@", parts: 2) do
          [name] ->
            {name, "latest"}

          ["", scoped_rest] ->
            case String.split(scoped_rest, "@", parts: 2) do
              [scoped_name] -> {"@#{scoped_name}", "latest"}
              [scoped_name, version] -> {"@#{scoped_name}", version}
            end

          [name, version] ->
            {name, version}
        end
      end)
    end
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
