defmodule Mishka.GenKitTest do
  @moduledoc """
  `mix mishka.ui.gen.kit` — vendors the `MishkaChelekom.Kit` Spark engine into the app under its own
  namespace so the Kit works with **no `mishka_chelekom` runtime dependency**.

  One real end-to-end pass writes the engine to disk, compiles it standalone, and renders a wrapper
  through the vendored runtime (proving self-containment); the rest is staged in-memory via
  `Igniter.new/0` for exhaustive, non-destructive option coverage.
  """
  use ExUnit.Case, async: false
  import MishkaCliHelper
  import Phoenix.LiveViewTest
  alias Mix.Tasks.Mishka.Ui.Gen.Kit, as: Task

  @moduletag :mishka_cli

  # The engine modules the task copies verbatim (namespace-rewritten). `catalog.ex` is excluded —
  # it is regenerated as a self-contained snapshot, asserted on its own.
  @engine_rel ~w(
    kit.ex dsl.ex runtime.ex info.ex
    entities/customize.ex entities/part.ex entities/rule.ex
    transformers/generate.ex verifiers/catalog.ex verifiers/rules.ex
  )

  setup do
    Application.ensure_all_started(:owl)
    :ok
  end

  describe "real end-to-end (mirrors a real consumer)" do
    test "run the task, customize a REAL component with the vendored engine, and render it" do
      n = System.unique_integer([:positive])
      base = "Development.KitProbe#{n}"
      dir = "lib/development/kit_probe#{n}"
      probe_kit = Module.concat(["DevelopmentWeb.KitProbe#{n}"])

      on_exit(fn ->
        rm_generated(dir)

        Enum.each([probe_kit | engine_modules(base)], fn m ->
          :code.purge(m)
          :code.delete(m)
        end)
      end)

      # ── what a user runs ─────────────────────────────────────────────────────────────
      refute File.exists?(dir)
      mix!("mishka.ui.gen.kit", ["--module", base, "--no-deps", "--no-starter", "--yes"])

      # 1. files on disk, namespace rewritten, no residual chelekom references
      assert File.exists?("#{dir}/kit.ex")
      assert File.read!("#{dir}/kit.ex") =~ "defmodule #{base} do"
      refute File.read!("#{dir}/kit.ex") =~ "MishkaChelekom"

      # 2. the regenerated catalog is a self-contained snapshot (no priv_dir read)
      catalog = File.read!("#{dir}/catalog.ex")
      assert catalog =~ "defmodule #{base}.Catalog"
      refute catalog =~ "priv_dir"
      assert catalog =~ "accordion"

      # 3. the vendored engine compiles standalone — no mishka_chelekom code involved
      compile_engine!(dir)

      # ── what a user writes ───────────────────────────────────────────────────────────
      # Customize the REAL styled button; `from :button` resolves through the vendored catalog
      # convention to the app's own `DevelopmentWeb.Components.Button` — exactly like a consumer.
      Code.compile_string("""
      defmodule DevelopmentWeb.KitProbe#{n} do
        use #{base}
        components DevelopmentWeb.Components

        customize :button do
          color :brand, "bg-brand-500! text-white!"
        end
      end
      """)

      # ── what a user sees ─────────────────────────────────────────────────────────────
      # Render the wrapper as a component: the vendored Runtime layers the brand classes, then it
      # delegates to the real Button — all with zero mishka_chelekom in the code path.
      assert function_exported?(probe_kit, :button, 1)

      html =
        render_component(Function.capture(probe_kit, :button, 1), %{color: "brand", size: "small"})

      assert html =~ "bg-brand-500!", "the brand classes should render through the real component"
      assert html =~ "text-white!"
    end
  end

  describe "engine vendoring (staged)" do
    test "stages every engine module under lib/<app>/kit/, namespace-rewritten to <App>.Kit" do
      igniter = stage(Task, ["--yes"])

      for rel <- @engine_rel do
        assert staged?(igniter, "lib/development/kit/#{rel}"), "expected #{rel} to be staged"
      end

      assert staged?(igniter, "lib/development/kit/catalog.ex")

      assert staged_content(igniter, "lib/development/kit/kit.ex") =~
               "defmodule Development.Kit do"
    end

    test "no vendored file references MishkaChelekom — the engine is fully self-contained" do
      igniter = stage(Task, ["--yes"])

      for rel <- @engine_rel ++ ["catalog.ex"] do
        refute staged_content(igniter, "lib/development/kit/#{rel}") =~ "MishkaChelekom",
               "#{rel} should carry no MishkaChelekom reference"
      end
    end

    test "the wrapper delegates to the vendored Runtime, not chelekom's" do
      igniter = stage(Task, ["--yes"])
      gen = staged_content(igniter, "lib/development/kit/transformers/generate.ex")

      assert gen =~ "Development.Kit.Runtime.transform"
      refute gen =~ "MishkaChelekom"
    end

    test "the catalog is a frozen snapshot (no priv_dir) with the real component names baked in" do
      igniter = stage(Task, ["--yes"])
      cat = staged_content(igniter, "lib/development/kit/catalog.ex")

      refute cat =~ "priv_dir"
      assert cat =~ "@styled ~w("
      assert cat =~ "@headless ~w("
      assert cat =~ "accordion"
    end
  end

  describe "--module (-m)" do
    test "overrides the engine namespace and destination directory" do
      igniter = stage(Task, ["--module", "MyApp.UiKit", "--yes"])

      assert staged?(igniter, "lib/my_app/ui_kit/kit.ex")
      assert staged_content(igniter, "lib/my_app/ui_kit/kit.ex") =~ "defmodule MyApp.UiKit do"

      assert staged_content(igniter, "lib/my_app/ui_kit/catalog.ex") =~
               "defmodule MyApp.UiKit.Catalog"
    end
  end

  describe "spark dependency" do
    test "adds {:spark, ...} to mix.exs by default (the only dep the engine needs)" do
      igniter = stage(Task, ["--yes"])
      assert staged_content(igniter, "mix.exs") =~ "spark"
    end

    test "--no-deps leaves mix.exs untouched" do
      igniter = stage(Task, ["--no-deps", "--yes"])
      refute staged?(igniter, "mix.exs")
    end
  end

  describe "starter module" do
    test "scaffolds a Customizations module inside the kit folder, wired to the vendored engine" do
      igniter = stage(Task, ["--yes"])
      starter = staged_content(igniter, "lib/development/kit/customizations.ex")

      assert starter =~ "defmodule Development.Kit.Customizations do"
      assert starter =~ "use Development.Kit"
      assert starter =~ "components(DevelopmentWeb.Components)"
      assert starter =~ "headless(DevelopmentWeb.Components.Headless)"
    end

    test "never writes outside the kit folder (leaves the real DevelopmentWeb.Kit untouched)" do
      igniter = stage(Task, ["--yes"])

      refute staged?(igniter, "lib/development_web/kit.ex")
      assert File.read!("lib/development_web/kit.ex") =~ "customize :button"
    end

    test "--no-starter skips scaffolding entirely" do
      igniter = stage(Task, ["--no-starter", "--yes"])
      refute staged?(igniter, "lib/development/kit/customizations.ex")
    end
  end

  describe "CLI contract" do
    test "exposes the documented positional, schema and aliases" do
      info = Task.info([], nil)
      assert info.positional == []

      for opt <- [:module, :no_deps, :no_starter] do
        assert Keyword.has_key?(info.schema, opt), "schema should expose --#{opt}"
      end

      assert info.aliases[:m] == :module
    end
  end

  # --- helpers ---------------------------------------------------------------------------

  # Compile the vendored engine in dependency order — entities/runtime/catalog first, then the
  # transformer/verifiers they reference, then the DSL + the `use Spark.Dsl` entry module.
  defp compile_engine!(dir) do
    ~w(
      entities/rule.ex entities/part.ex entities/customize.ex
      runtime.ex catalog.ex transformers/generate.ex
      verifiers/catalog.ex verifiers/rules.ex
      dsl.ex info.ex kit.ex
    )
    |> Enum.each(&Code.compile_file(Path.join(dir, &1)))
  end

  defp engine_modules(base) do
    [
      "",
      ".Dsl",
      ".Runtime",
      ".Info",
      ".Catalog",
      ".Entities.Customize",
      ".Entities.Part",
      ".Entities.Rule",
      ".Transformers.Generate",
      ".Verifiers.Catalog",
      ".Verifiers.Rules"
    ]
    |> Enum.map(&Module.concat([base <> &1]))
  end
end
