defmodule MishkaChelekom.Generators.AssetsNpmTest do
  @moduledoc """
  The npm side of `Assets.wire_scripts/3`, exercised directly with hand-built catalog configs.

  Driving the function rather than a real catalog is deliberate: a throwaway `.exs` in
  `priv/headless/` would be picked up by `Core.resolve_components/5`, the dev harness's
  `HeadlessCatalog`, the showcase smoke test and hex packaging. This way the pipeline is provable
  before any npm-backed component exists.
  """
  use ExUnit.Case, async: false

  import MishkaChelekom.ComponentTestHelper

  alias MishkaChelekom.Generators.Assets

  @moduletag :igniter

  setup do
    Application.ensure_all_started(:owl)
    MishkaChelekom.ComponentTestHelper.setup_config()
    on_exit(fn -> MishkaChelekom.ComponentTestHelper.cleanup_config() end)
    :ok
  end

  defp source_content(igniter, path) do
    igniter.rewrite.sources[path] |> Rewrite.Source.get(:content)
  end

  defp config(overrides) do
    Keyword.merge(
      [name: "probe", args: [type: ["probe"]], optional: [], necessary: []],
      overrides
    )
  end

  defp project_with_assets(files \\ %{}) do
    test_project_with_formatter(
      files:
        Map.merge(
          %{
            "assets/js/app.js" => """
            import { LiveSocket } from "phoenix_live_view";
            let liveSocket = new LiveSocket("/live", Socket, { hooks: {} });
            """
          },
          files
        )
    )
  end

  defp package_json(igniter) do
    igniter |> source_content("assets/package.json") |> Jason.decode!()
  end

  defp install_queued?(igniter) do
    Enum.any?(igniter.tasks, fn {task, _argv} -> task == "mishka.assets.install" end)
  end

  describe "npm packages declared by a catalog" do
    test "creates package.json with the exact pins and queues the install" do
      igniter =
        project_with_assets()
        |> Assets.wire_scripts(
          config(
            npm: [
              %{name: "@tiptap/core", version: "3.28.0"},
              %{name: "left-pad", version: "1.3.0"}
            ]
          )
        )

      deps = package_json(igniter)["dependencies"]

      assert deps["@tiptap/core"] == "3.28.0"
      assert deps["left-pad"] == "1.3.0"
      assert install_queued?(igniter)
    end

    test "a component with npm but no scripts is still wired (the old gate skipped it entirely)" do
      igniter =
        project_with_assets()
        |> Assets.wire_scripts(config(npm: [%{name: "dompurify", version: "3.2.5"}]))

      assert package_json(igniter)["dependencies"]["dompurify"] == "3.2.5"
    end

    test "a second run over the manifest we already wrote queues no install and leaves mix.exs alone" do
      npm = [%{name: "@tiptap/core", version: "3.28.0"}]

      # Feed the FIRST run's own output back in: that is what the second `mix` invocation sees,
      # and what the idempotency CI job replays. A hand-written fixture would differ only in JSON
      # formatting and re-encode into a "change", masking the regression this guards.
      first = project_with_assets() |> Assets.wire_scripts(config(npm: npm))
      manifest = source_content(first, "assets/package.json")

      igniter =
        project_with_assets(%{"assets/package.json" => manifest})
        |> Assets.wire_scripts(config(npm: npm))

      refute install_queued?(igniter),
             "an unchanged package.json must not queue an install — Igniter shells out to " <>
               "`mix deps.get` whenever the task queue is non-empty"

      refute Igniter.has_changes?(igniter, ["assets/package.json"])

      refute Igniter.has_changes?(igniter, ["config/config.exs"]),
             "{:bun, ...} config must never be added when package.json is unchanged"
    end

    test "wiring twice changes nothing the second time (what idempotency_check.exs measures)" do
      npm = [%{name: "@tiptap/core", version: "3.28.0"}]
      cfg = config(npm: npm)

      first = project_with_assets() |> Assets.wire_scripts(cfg)
      second = Assets.wire_scripts(first, cfg)

      for path <- ["mix.exs", ".gitignore", "assets/package.json"] do
        assert source_content(first, path) == source_content(second, path),
               "#{path} drifted on a second wiring — aliases/entries must be idempotent"
      end
    end

    test "--no-npm writes the manifest but queues nothing" do
      igniter =
        project_with_assets()
        |> Assets.wire_scripts(config(npm: [%{name: "left-pad", version: "1.3.0"}]), no_npm: true)

      assert package_json(igniter)["dependencies"]["left-pad"] == "1.3.0"
      assert igniter.tasks == [], "--no-npm must keep the task queue empty (offline installs)"
    end

    test "warns before overwriting a version the project already pinned differently" do
      pinned = ~s({"name": "test", "dependencies": {"left-pad": "1.0.0"}}\n)

      igniter =
        project_with_assets(%{"assets/package.json" => pinned})
        |> Assets.wire_scripts(config(npm: [%{name: "left-pad", version: "1.3.0"}]))

      assert Enum.join(igniter.warnings, " ") =~ "left-pad is already pinned"
      assert package_json(igniter)["dependencies"]["left-pad"] == "1.3.0"
    end

    test "reads packages from the default entry of libs when there is no top-level npm" do
      libs = [
        tiptap: [default: true, npm: [%{name: "@tiptap/core", version: "3.28.0"}]],
        other: [npm: [%{name: "nope", version: "9.9.9"}]]
      ]

      igniter = project_with_assets() |> Assets.wire_scripts(config(libs: libs))
      deps = package_json(igniter)["dependencies"]

      assert deps["@tiptap/core"] == "3.28.0"
      refute Map.has_key?(deps, "nope")
    end
  end

  describe "making the project able to BUILD with the dependency" do
    test "gitignores assets/node_modules once, idempotently" do
      igniter =
        project_with_assets(%{".gitignore" => "/_build/\n/deps/\n"})
        |> Assets.wire_scripts(config(npm: [%{name: "left-pad", version: "1.3.0"}]))

      gitignore = source_content(igniter, ".gitignore")

      assert gitignore =~ "/assets/node_modules/"
      assert gitignore =~ "/_build/", "must not clobber the project's existing entries"

      again = Assets.wire_scripts(igniter, config(npm: [%{name: "left-pad", version: "1.3.0"}]))

      assert length(String.split(source_content(again, ".gitignore"), "/assets/node_modules/")) ==
               2
    end

    test "prepends the install to assets.deploy so esbuild never runs before node_modules exists" do
      igniter =
        project_with_assets()
        |> Assets.wire_scripts(config(npm: [%{name: "left-pad", version: "1.3.0"}]))

      mix_exs = source_content(igniter, "mix.exs")

      assert mix_exs =~ "mishka.assets.install"
    end
  end

  describe "projects without a JS pipeline" do
    test "an API-only app gets a notice instead of a stray package.json" do
      igniter =
        test_project_with_formatter()
        |> Assets.wire_scripts(config(npm: [%{name: "left-pad", version: "1.3.0"}]))

      refute igniter.rewrite.sources["assets/package.json"]
      assert Enum.join(igniter.notices, " ") =~ "no assets/js/app.js"
    end
  end
end
