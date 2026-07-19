defmodule MishkaChelekom.Generators.Npm do
  @moduledoc """
  JS package-dependency handling shared by `mix mishka.assets.deps` and the component generators.

  Owns `assets/package.json`: creating it, merging or removing pinned dependencies, choosing a
  package manager (bun/npm/yarn on `PATH`, preferring bun; else the `{:bun, ...}` hex binary,
  which needs no system Node) and queueing the actual install.

  Generators call `install/3` **directly** rather than composing `mix mishka.assets.deps`: both
  that task and the generators drive an `Owl.Spinner` registered under `id: :my_spinner`, so
  composing makes the inner task stop the outer task's spinner and the outer `stop` then exits
  `:noproc` after the files are already written. Calling the functions keeps every change in the
  same `Igniter.t()` (one reviewable diff) with no spinner, flag-namespace or task-queue coupling.
  """

  @package_json "assets/package.json"

  # Preference order when several are installed. Bun first, deliberately: it is what this library
  # recommends (see the notice in add_final_notice/2), it is dramatically faster, and it is the
  # same runtime as the {:bun, ...} hex fallback used when the machine has no package manager at
  # all — so the tool that installs is the same one whether or not the developer has Node.
  # An explicit --npm / --bun / --yarn always wins over this.
  @pkgs [:bun, :npm, :yarn]

  @doc "Path of the managed manifest, relative to the project root."
  @spec package_json_path() :: String.t()
  def package_json_path, do: @package_json

  @doc "Package managers we know how to drive, in preference order."
  @spec package_managers() :: [atom()]
  def package_managers, do: @pkgs

  @doc """
  Resolves the package manager for this run: an explicit `--npm`/`--bun`/`--yarn` flag wins,
  `--mix-bun` forces the hex binary (`nil`), otherwise the first of #{inspect(@pkgs)} on `PATH`.
  Returns `nil` when none is available, which `check_package_manager/2` turns into the hex-bun path.
  """
  @spec detect(keyword()) :: atom() | nil
  def detect(options \\ []) do
    cond do
      options[:bun] -> :bun
      options[:npm] -> :npm
      options[:yarn] -> :yarn
      options[:mix_bun] -> nil
      true -> Enum.find(@pkgs, &(!is_nil(System.find_executable(Atom.to_string(&1)))))
    end
  end

  @doc """
  Full install pipeline: ensure the manifest exists, merge the deps, pick a package manager and
  queue the install. `deps` is a list of `"name@version"` strings or `%{name:, version:}` maps.

  Every stage after the merge is gated on `assets/package.json` having actually changed, so a
  component whose packages are already pinned queues nothing.
  """
  @spec install(Igniter.t(), [String.t() | map()], keyword()) :: Igniter.t()
  def install(igniter, deps, options \\ [])
  def install(igniter, [], _options), do: igniter

  def install(igniter, deps, options) do
    igniter
    |> ensure_package_json_exists()
    |> add_deps(deps, options)
    |> check_package_manager(detect(options))
    |> run_command(options)
  end

  @doc "Creates `assets/package.json` when the project has none."
  @spec ensure_package_json_exists(Igniter.t()) :: Igniter.t()
  def ensure_package_json_exists(igniter) do
    if Igniter.exists?(igniter, @package_json) do
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
      |> Igniter.create_new_file(@package_json, default_package_json)
      |> Igniter.add_notice("""
      Created package.json in assets directory.
      You may want to customize the name, description, and etc for your project.
      """)
    end
  end

  @doc """
  Merges dependencies into `assets/package.json` (`devDependencies` with `--dev`).

  Warns before overwriting a dependency the project already pins at a different version — the
  manifest belongs to the user, so a silent downgrade is never acceptable.
  """
  @spec add_deps(Igniter.t(), [String.t() | map()], keyword()) :: Igniter.t()
  def add_deps(igniter, deps, options \\ []) do
    parsed_deps = parse_deps(deps)
    deps_key = if options[:dev], do: "devDependencies", else: "dependencies"

    igniter
    |> warn_on_version_conflicts(parsed_deps, deps_key)
    |> Igniter.update_file(@package_json, fn source ->
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
          Rewrite.Source.add_issue(
            source,
            "Failed to parse package.json. Ensure it contains valid JSON."
          )
      end
    end)
  end

  @doc """
  Removes only those `deps` the manifest still pins at exactly the version given — packages we
  wrote and nobody has changed since.

  Used when switching a component's engine: the previous engine's packages must not be stranded,
  but a package the project also depends on (or deliberately re-pinned) is left alone.
  """
  @spec prune(Igniter.t(), [String.t()], keyword()) :: Igniter.t()
  def prune(igniter, [], _options), do: igniter

  def prune(igniter, deps, options) do
    ours =
      deps
      |> parse_deps()
      |> Enum.filter(fn {name, version} -> pinned?(igniter, name, version) end)
      |> Enum.map(fn {name, _version} -> name end)

    if ours == [] do
      igniter
    else
      igniter
      |> Igniter.add_notice("""
      Removed #{Enum.join(ours, ", ")} from #{@package_json} — the engine that needed them was
      replaced. Anything you had re-pinned yourself was left untouched.
      """)
      |> remove_deps(ours, options)
      |> run_command(Keyword.put(options, :remove, true))
    end
  end

  defp pinned?(igniter, name, version) do
    with {:ok, raw} <- read_manifest(igniter),
         {:ok, json} <- Jason.decode(raw) do
      get_in(json, ["dependencies", name]) == version
    else
      _ -> false
    end
  end

  @doc "Removes dependencies from `assets/package.json` and records them for the uninstall command."
  @spec remove_deps(Igniter.t(), [String.t() | map()], keyword()) :: Igniter.t()
  def remove_deps(igniter, deps, options \\ []) do
    deps_to_remove = deps |> parse_deps() |> Enum.map(&elem(&1, 0))
    deps_key = if options[:dev], do: "devDependencies", else: "dependencies"

    igniter
    |> Igniter.assign(:deps_to_remove, deps_to_remove)
    |> Igniter.update_file(@package_json, fn source ->
      original_content = Rewrite.Source.get(source, :content)

      case Jason.decode(original_content) do
        {:ok, json} ->
          {_removed, remaining} = Map.get(json, deps_key, %{}) |> Map.split(deps_to_remove)

          formatted =
            json
            |> Map.put(deps_key, remaining)
            |> Jason.encode!(pretty: true)
            |> Kernel.<>("\n")

          Rewrite.Source.update(source, :content, formatted)

        {:error, _} ->
          Rewrite.Source.add_issue(
            source,
            "Failed to parse package.json. Ensure it contains valid JSON."
          )
      end
    end)
  end

  @doc """
  Records which package manager to drive. With none available, adds the `{:bun, ...}` hex package
  (a self-contained binary — no system Node) and its config.

  Gated on `assets/package.json` specifically: a bare `Igniter.has_changes?/1` is true for *any*
  pending change, so when called from a generator that just wrote a component it would add `:bun`
  to the project's `mix.exs` on every single generation.
  """
  @spec check_package_manager(Igniter.t(), atom() | nil) :: Igniter.t()
  def check_package_manager(igniter, manager) when manager in @pkgs do
    if manifest_changed?(igniter) do
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
          Igniter.assign(igniter, :package_manager, manager)
      end
    else
      igniter
    end
  end

  def check_package_manager(igniter, nil) do
    if manifest_changed?(igniter) do
      install_config_ast =
        quote do
          [args: ["install"], cd: Path.expand("../assets", __DIR__)]
        end

      uninstall_config_ast =
        quote do
          [args: ["remove"], cd: Path.expand("../assets", __DIR__)]
        end

      dep_ast =
        quote do
          [runtime: Mix.env() == :dev]
        end

      igniter =
        Igniter.add_warning(igniter, """
        No package manager found. We can install bun as a mix dependency.
        This will add {:bun, "~> 1.0"} to your mix.exs and make bun available.
        """)

      case Igniter.Project.Deps.get_dep(igniter, :bun) do
        {:ok, dep} when not is_nil(dep) ->
          igniter

        _ ->
          Igniter.Project.Deps.add_dep(igniter, {:bun, "~> 1.0", dep_ast})
      end
      |> Igniter.Project.Config.configure_new("config.exs", :bun, [:version], "1.2.14")
      |> Igniter.Project.Config.configure_new(
        "config.exs",
        :bun,
        [:install],
        {:code, install_config_ast}
      )
      |> Igniter.Project.Config.configure_new(
        "config.exs",
        :bun,
        [:uninstall],
        {:code, uninstall_config_ast}
      )
      |> Igniter.assign(:package_manager, :bun)
      |> Igniter.assign(:package_manager_type, "mix")
    else
      igniter
    end
  end

  @doc """
  Queues `mix mishka.assets.install` for the resolved package manager.

  Skipped entirely when the manifest is unchanged or `--no-npm` was given — an empty task queue
  matters, because Igniter shells out to `mix deps.get` before running any queued task.
  """
  @spec run_command(Igniter.t(), keyword()) :: Igniter.t()
  def run_command(igniter, options) do
    cond do
      options[:no_npm] ->
        Igniter.add_notice(igniter, """
        Skipped installing the JS dependencies (--no-npm).
        Run them yourself from the assets directory before building:

            cd assets && npm install
        """)

      manifest_changed?(igniter) ->
        package_manager = Map.get(igniter.assigns, :package_manager, :npm)
        pkg_type = Map.get(igniter.assigns, :package_manager_type, "pkg")

        command = if options[:remove], do: "remove", else: "install"

        task_args =
          if options[:remove] do
            deps_to_remove = Map.get(igniter.assigns, :deps_to_remove, [])
            [Atom.to_string(package_manager), pkg_type, command | deps_to_remove]
          else
            [Atom.to_string(package_manager), pkg_type, command]
          end

        igniter
        |> Igniter.add_task("mishka.assets.install", task_args)
        |> add_final_notice(options)

      true ->
        igniter
    end
  end

  @doc "Splits `\"name@version\"` (including scoped names) into `{name, version}` pairs."
  @spec parse_deps([String.t() | map()]) :: [{String.t(), String.t()}]
  def parse_deps(deps) when is_list(deps) do
    Enum.map(deps, fn
      %{name: name, version: version} ->
        {name, version}

      %{"name" => name, "version" => version} ->
        {name, version}

      dep when is_binary(dep) ->
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

  defp manifest_changed?(igniter), do: Igniter.has_changes?(igniter, [@package_json])

  defp warn_on_version_conflicts(igniter, parsed_deps, deps_key) do
    with true <- Igniter.exists?(igniter, @package_json),
         {:ok, content} <- read_manifest(igniter),
         {:ok, json} <- Jason.decode(content) do
      existing = Map.get(json, deps_key, %{})

      Enum.reduce(parsed_deps, igniter, fn {name, version}, acc ->
        case Map.get(existing, name) do
          nil ->
            acc

          ^version ->
            acc

          other ->
            Igniter.add_warning(acc, """
            #{name} is already pinned to "#{other}" in #{@package_json}; overwriting with "#{version}".
            If your project needs "#{other}", pin it again after this generation.
            """)
        end
      end)
    else
      _ -> igniter
    end
  end

  defp read_manifest(igniter) do
    case igniter.rewrite.sources[@package_json] do
      nil -> File.read(@package_json)
      source -> {:ok, Rewrite.Source.get(source, :content)}
    end
  end

  defp add_final_notice(igniter, options) do
    if options[:remove] do
      Igniter.add_notice(
        igniter,
        IO.ANSI.green() <>
          """
          Dependencies have been removed from package.json.
          The package manager will update the lockfile and node_modules accordingly.
          """ <> IO.ANSI.reset()
      )
    else
      Igniter.add_notice(
        igniter,
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
    end
  end
end
