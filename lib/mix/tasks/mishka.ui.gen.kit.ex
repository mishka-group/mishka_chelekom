defmodule Mix.Tasks.Mishka.Ui.Gen.Kit do
  use Igniter.Mix.Task

  alias MishkaChelekom.Generators.Core

  @example "mix mishka.ui.gen.kit"
  @shortdoc "Vendor the Mishka Chelekom Kit engine into your app (no runtime dependency)"
  @moduledoc """
  #{@shortdoc}

  The Kit (`customize`/`from` Spark DSL) is **not** a copied component — it's a live macro whose
  wrappers call `MishkaChelekom.Kit.Runtime` at render time and whose `use` runs Spark transformers
  at compile time. So, unlike generated components, it can't ride along on a `only: :dev,
  runtime: false` install of `mishka_chelekom`: the engine has to exist in every build that compiles
  or runs your app, prod included.

  This task **vendors the engine into your app** under your own namespace (default `<App>.Kit`), so
  it becomes your code with no `mishka_chelekom` dependency at compile or run time:

    * the 10 engine modules are copied and namespace-rewritten `MishkaChelekom.Kit` → `<App>.Kit`;
    * the catalog (used only for compile-time "did you mean?" validation) is regenerated as a
      **self-contained snapshot** of the current component names — it no longer reads
      `mishka_chelekom`'s `priv/`, so a prod build with no chelekom dep still compiles;
    * `{:spark, "~> 2.7"}` — the only real dependency the engine needs — is added to `mix.exs` for
      you via Igniter (`Igniter.Project.Deps.add_dep/3`); you never edit `mix.exs` by hand;
    * a starter `<App>.Kit.Customizations` module is scaffolded **inside the kit folder** (skipped
      if it already exists), where you write your `customize` blocks.

  Everything lands under one folder — `lib/<app>/kit/` — the vendored engine and your
  customizations together.

  After this the task has already added `spark`; the only manual edit is flipping `mishka_chelekom`
  to a dev-only generator, leaving `mix.exs` like:

      {:mishka_chelekom, "~> 0.0.9", only: :dev, runtime: false},   # you flip this to dev-only
      {:spark, "~> 2.7"}                                            # added for you by this task

  and write your customizations against the vendored engine:

      defmodule MyApp.Kit.Customizations do
        use MyApp.Kit                       # the vendored engine, not MishkaChelekom.Kit

        components MyAppWeb.Components       # where your components live

        customize :button do
          color :brand, "bg-brand-500! text-white!"
          default color: :brand
        end
      end

  Re-run the task any time to refresh the vendored engine and the catalog snapshot after adding
  components.

  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * `--module` or `-m` - Base module for the vendored engine (default `<App>.Kit`)
  * `--no-deps` - Do not add `{:spark, "~> 2.7"}` to `mix.exs`
  * `--no-starter` - Do not scaffold the `<App>.Kit.Customizations` starter module
  * `--yes` - Apply without prompts
  """

  # The engine source, embedded at chelekom compile time so the task carries the code as data —
  # no runtime lookup into the dep's (unshipped) `lib/` source. `catalog.ex` is intentionally
  # excluded: it is regenerated as a self-contained snapshot (see `build_catalog/3`).
  @kit_src Path.expand("../../mishka_chelekom/kit", __DIR__)

  @engine_files ~w(
    kit.ex
    dsl.ex
    runtime.ex
    info.ex
    entities/customize.ex
    entities/part.ex
    entities/rule.ex
    transformers/generate.ex
    verifiers/catalog.ex
    verifiers/rules.ex
  )

  for rel <- @engine_files do
    @external_resource Path.join(@kit_src, rel)
  end

  @embedded (for rel <- @engine_files, into: %{} do
               {rel, File.read!(Path.join(@kit_src, rel))}
             end)

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      example: @example,
      positional: [],
      group: :mishka_chelekom,
      schema: [
        module: :string,
        no_deps: :boolean,
        no_starter: :boolean
      ],
      aliases: [m: :module]
    }
  end

  def supports_umbrella?(), do: false

  def igniter(igniter) do
    Application.ensure_all_started(:owl)
    if Mix.env() != :test, do: Core.banner(IO.ANSI.magenta(), "Kit")

    tty? = IO.ANSI.enabled?()
    spin? = Mix.env() != :test and tty?
    if spin?, do: Owl.Spinner.start(id: :my_spinner, labels: [processing: "Please wait..."])

    final =
      igniter
      |> assign_targets()
      |> vendor_engine()
      |> vendor_catalog()
      |> maybe_add_spark()
      |> maybe_starter()
      |> notify()

    if spin? do
      if Map.get(final, :issues, []) == [],
        do: Owl.Spinner.stop(id: :my_spinner, resolution: :ok, label: "Done"),
        else: Owl.Spinner.stop(id: :my_spinner, resolution: :error, label: "Error")
    end

    final
  end

  # Resolve the target namespace/paths once and stash them in assigns, so every stage below is a
  # single-arg `igniter -> igniter` step (mirrors `mishka.ui.gen.headless`'s `compute_location`).
  defp assign_targets(igniter) do
    app = Macro.camelize(to_string(Igniter.Project.Application.app_name(igniter)))
    base = igniter.args.options[:module] || "#{app}.Kit"

    igniter
    |> Igniter.assign(:kit_base, base)
    |> Igniter.assign(:kit_dir, kit_dir(base))
    |> Igniter.assign(:kit_web, "#{app}Web")
  end

  # --- engine vendoring ------------------------------------------------------------------

  defp vendor_engine(igniter) do
    %{kit_base: base, kit_dir: dir} = igniter.assigns

    Enum.reduce(@engine_files, igniter, fn rel, acc ->
      dest = Path.join(dir, rel)
      content = String.replace(@embedded[rel], "MishkaChelekom.Kit", base)

      acc
      |> Core.track_generated_file(dest)
      |> Igniter.create_new_file(dest, content, on_exists: :overwrite)
    end)
  end

  # The vendored catalog is a frozen snapshot of the live component names, so it needs neither
  # `mishka_chelekom` nor its `priv/` at the consumer's compile/run time.
  defp vendor_catalog(igniter) do
    %{kit_base: base, kit_dir: dir} = igniter.assigns
    dest = Path.join(dir, "catalog.ex")

    styled = MishkaChelekom.Kit.Catalog.names(:styled)
    headless = MishkaChelekom.Kit.Catalog.names(:headless)

    igniter
    |> Core.track_generated_file(dest)
    |> Igniter.create_new_file(dest, build_catalog(base, styled, headless), on_exists: :overwrite)
  end

  defp build_catalog(base, styled, headless) do
    """
    defmodule #{base}.Catalog do
      @moduledoc \"\"\"
      Self-contained snapshot of the Mishka component catalog, baked in by `mix mishka.ui.gen.kit`
      so the vendored Kit validates `from:` at compile time without a `mishka_chelekom` dependency.
      Styled names came from `priv/components/*.exs`, headless from `priv/headless/*.exs`.
      Re-run `mix mishka.ui.gen.kit` to refresh after adding components.
      \"\"\"

      @styled ~w(#{Enum.join(styled, " ")})a
      @headless ~w(#{Enum.join(headless, " ")})a

      @doc "Known component names for a kind (`:styled` | `:headless`)."
      def names(:headless), do: @headless
      def names(:styled), do: @styled

      @doc "Whether `name` is a real component of the given kind."
      def member?(kind, name), do: name in names(kind)

      @doc "The closest known name to `name` (for a \\"did you mean?\\" hint), or nil."
      def suggest(kind, name) do
        Enum.find(names(kind), &(String.jaro_distance(to_string(name), to_string(&1)) > 0.8))
      end
    end
    """
  end

  # --- deps + starter --------------------------------------------------------------------

  defp maybe_add_spark(igniter) do
    if igniter.args.options[:no_deps] do
      igniter
    else
      Igniter.Project.Deps.add_dep(igniter, {:spark, "~> 2.7"}, on_exists: :skip, yes?: true)
    end
  end

  defp maybe_starter(igniter) do
    %{kit_base: base, kit_dir: dir, kit_web: web} = igniter.assigns
    path = Path.join(dir, "customizations.ex")

    # Guard on the real filesystem: Igniter loads sources lazily, so an existing on-disk module is
    # not yet tracked and `on_exists: :skip` would still stage (and later overwrite) it with the
    # empty starter. Never touch a Kit the user already wrote.
    cond do
      igniter.args.options[:no_starter] -> igniter
      File.exists?(path) -> igniter
      true -> Igniter.create_new_file(igniter, path, starter_module(base, web), on_exists: :skip)
    end
  end

  defp notify(igniter) do
    Igniter.add_notice(igniter, next_steps(igniter.assigns.kit_base, igniter.args.options))
  end

  defp starter_module(base, web) do
    """
    defmodule #{base}.Customizations do
      @moduledoc \"\"\"
      Your Mishka Chelekom **Kit** customizations — reuse and restyle existing components without
      editing their files. Powered by the vendored `#{base}` engine (no `mishka_chelekom` runtime
      dependency). Reach a wrapper by remote call, e.g. `<#{base}.Customizations.button … />`.

      Uncomment the example below once you've generated the component you want to customize.
      \"\"\"
      use #{base}

      # Where your components live — adjust if you use custom namespaces.
      components(#{web}.Components)
      headless(#{web}.Components.Headless)

      # customize :button do
      #   color :brand, "bg-brand-500! text-white!"
      #   default color: :brand
      # end
    end
    """
  end

  defp kit_dir(base) do
    segs = base |> String.split(".", trim: true) |> Enum.map(&Macro.underscore/1)
    Path.join(["lib" | segs])
  end

  defp next_steps(base, options) do
    deps_line =
      if options[:no_deps],
        do: "1. Add `{:spark, \"~> 2.7\"}` to mix.exs yourself, then `mix deps.get`",
        else: "1. `mix deps.get` (added `{:spark, \"~> 2.7\"}` to mix.exs)"

    """
    Vendored the Mishka Chelekom Kit engine as `#{base}` — self-contained, no mishka_chelekom
    runtime dependency. Engine + your customizations both live under `#{kit_dir(base)}/`.

    Next:
      #{deps_line}
      2. Write your customizations in `#{base}.Customizations` (`use #{base}`)
      3. You can now keep the generator dev-only:
         {:mishka_chelekom, "~> 0.0.9", only: :dev, runtime: false}
    """
  end
end
