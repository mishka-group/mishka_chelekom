defmodule Mix.Tasks.Mishka.Ui.UninstallMobTest do
  @moduledoc """
  `mix mishka.ui.uninstall --mob`.

  A Mob application is not a Phoenix one — no `_web` namespace, no JS hooks, no
  stylesheet — so most of what uninstall does has nothing to act on. What it must
  get right is the part unique to Mob: the composite registry names every
  generated component, so a removal that leaves it alone leaves the app naming a
  module that no longer exists.
  """
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias Mix.Tasks.Mishka.Ui.Gen.Mob, as: GenMob
  alias Mix.Tasks.Mishka.Ui.Gen.Mob.Components, as: GenMobComponents
  alias Mix.Tasks.Mishka.Ui.Uninstall
  @moduletag :igniter

  setup do
    Application.ensure_all_started(:owl)
    MishkaChelekom.ComponentTestHelper.setup_config()
    on_exit(fn -> MishkaChelekom.ComponentTestHelper.cleanup_config() end)
    :ok
  end

  defp content(igniter, path) do
    case igniter.rewrite.sources[path] do
      nil -> nil
      source -> Rewrite.Source.get(source, :content)
    end
  end

  # A removal drops the source AND records the path in igniter.rms; checking both
  # keeps the assertion from passing just because a key happens to be absent.
  defp rm_planned?(igniter, path), do: path in Map.get(igniter, :rms, [])

  defp still_present?(igniter, path) do
    Map.has_key?(igniter.rewrite.sources, path) and not rm_planned?(igniter, path)
  end

  describe "targeting" do
    test "--mob resolves to lib/<app>/components, not lib/<app>_web" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(GenMob, ["chip", "--yes"])
        |> Igniter.compose_task(Uninstall, ["chip", "--mob", "--dry-run", "--yes"])

      # dry run touches nothing, but resolving the wrong directory would have
      # produced a "not found" and no plan at all
      assert igniter.assigns.plan.components == [{"chip", :mob}]
      assert [{label, path, found?, module}] = igniter.assigns.plan.component_files
      assert label == "chip (mob)"
      assert path == "lib/test/components/chip.ex"
      assert found?
      assert module == Test.Components.Chip
    end

    test "without --mob the same name resolves to the styled location" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(Uninstall, ["chip", "--dry-run", "--yes"])

      assert igniter.assigns.plan.components == [{"chip", :styled}]
      assert [{"chip", path, _, _}] = igniter.assigns.plan.component_files
      refute path == "lib/test/components/chip.ex"
    end

    test "--mob wins over --headless when both are passed by mistake" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(Uninstall, ["chip", "--mob", "--headless", "--dry-run", "--yes"])

      assert igniter.assigns.plan.components == [{"chip", :mob}]
    end

    test "the plan labels mob components so they cannot be confused with styled ones" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(GenMob, ["chip", "--yes"])
        |> Igniter.compose_task(Uninstall, ["chip", "--mob", "--dry-run", "--yes"])

      assert [{"chip (mob)", _, _, _}] = igniter.assigns.plan.component_files
    end
  end

  describe "removal" do
    test "removes the component file" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(GenMob, ["chip", "--yes"])
        |> Igniter.compose_task(Uninstall, ["chip", "--mob", "--yes"])

      refute still_present?(igniter, "lib/test/components/chip.ex")
    end

    test "leaves the shared kit alone — it is not a component" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(GenMob, ["chip", "--yes"])
        |> Igniter.compose_task(Uninstall, ["chip", "--mob", "--yes"])

      assert still_present?(igniter, "lib/test/components/event.ex")
    end

    test "--all --mob targets every mob component and nothing else" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(GenMobComponents, ["chip,pill,switch", "--yes"])
        |> Igniter.compose_task(Uninstall, ["--all", "--mob", "--dry-run", "--yes"])

      kinds = igniter.assigns.plan.components |> Enum.map(&elem(&1, 1)) |> Enum.uniq()
      names = igniter.assigns.plan.components |> Enum.map(&elem(&1, 0)) |> Enum.sort()

      assert kinds == [:mob]
      assert names == ["chip", "pill", "switch"]
    end
  end

  describe "the composite registry" do
    test "is rewritten without the removed component, keeping the survivors" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(GenMobComponents, ["chip,pill", "--yes"])
        |> Igniter.compose_task(Uninstall, ["chip", "--mob", "--yes"])

      registry = content(igniter, "lib/test/components.ex")

      # Leaving :mishka_chip behind would name a module that no longer exists and
      # the app would stop compiling.
      refute registry =~ "{:chip,"
      assert registry =~ "{:pill, Test.Components.Pill}"
    end

    test "is deleted when the last mob component goes" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(GenMob, ["chip", "--yes"])
        |> Igniter.compose_task(Uninstall, ["chip", "--mob", "--yes"])

      refute still_present?(igniter, "lib/test/components.ex")
    end

    test "is untouched by a styled or headless uninstall" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(GenMob, ["chip", "--yes"])
        |> Igniter.compose_task(Uninstall, ["accordion", "--headless", "--yes"])

      assert content(igniter, "lib/test/components.ex") =~ "{:chip,"
    end

    test "survives a partial --all --mob with a prefix" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(GenMobComponents, [
          "chip,pill",
          "--module-prefix",
          "mishka_",
          "--yes"
        ])
        |> Igniter.compose_task(Uninstall, ["chip", "--mob", "--yes"])

      registry = content(igniter, "lib/test/components.ex")

      refute registry =~ "{:mishka_chip,"
      assert registry =~ "{:mishka_pill, Test.Components.MishkaPill}"
    end
  end

  describe "what it skips for mob" do
    test "no CSS, npm or JS work is planned" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(GenMob, ["chip", "--yes"])
        |> Igniter.compose_task(Uninstall, ["chip", "--mob", "--dry-run", "--yes"])

      plan = igniter.assigns.plan

      assert plan.js_to_remove == []
      assert plan.npm_to_remove == []
    end

    test "a mob-only run does not touch the web module" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(GenMob, ["chip", "--yes"])
        |> Igniter.compose_task(Uninstall, ["chip", "--mob", "--yes"])

      touched =
        igniter.rewrite.sources
        |> Map.keys()
        |> Enum.filter(&String.contains?(&1, "test_web"))

      assert touched == []
    end
  end
end
