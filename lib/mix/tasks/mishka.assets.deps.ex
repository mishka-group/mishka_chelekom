defmodule Mix.Tasks.Mishka.Assets.Deps.Docs do
  @moduledoc false

  @spec short_doc() :: String.t()
  def short_doc do
    "A short description of your task"
  end

  @spec example() :: String.t()
  def example do
    "mix mishka.assets.deps --example arg"
  end

  @spec long_doc() :: String.t()
  def long_doc do
    """
    #{short_doc()}

    Longer explanation of your task

    ## Example

    ```sh
    #{example()}
    ```

    ## Options

    * `--example-option` or `-e` - Docs for your option
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
        schema: [bun: :boolean, npm: :boolean, yarn: :boolean, sub: :boolean, dev: :boolean],
        defaults: [],
        aliases: [],
        required: []
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      %Igniter.Mix.Task.Args{positional: %{deps: deps}, argv: argv} = igniter.args
      options = options!(argv)
      package_manager = Enum.find(@pkgs, &(Keyword.get(options, &1) == true))

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
      |> check_package_manager(package_manager)
      |> ensure_package_json_exists()
      |> update_package_json_deps(String.split(deps, ","), options)
    end

    def check_package_manager(igniter, manager) when manager in @pkgs do
      case System.find_executable(Atom.to_string(manager)) do
        nil ->
          {:error,
           "#{manager} not found. Please install it or let us to use binary bun that does not need"}

        path ->
          {:ok, path}
      end

      igniter
    end

    def check_package_manager(igniter, nil) do
      {:error, "No package manager specified"}
      igniter
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
