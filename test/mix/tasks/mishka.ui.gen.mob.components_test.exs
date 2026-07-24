defmodule Mix.Tasks.Mishka.Ui.Gen.Mob.ComponentsTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias Mix.Tasks.Mishka.Ui.Gen.Mob.Components, as: MobComponents
  alias Mix.Tasks.Mishka.Ui.Gen.Mob.Kit, as: MobKit
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

  defp generated(igniter) do
    igniter.rewrite.sources
    |> Map.keys()
    |> Enum.filter(&String.starts_with?(&1, "lib/test/components/"))
    |> Enum.map(&Path.basename(&1, ".ex"))
    |> Enum.sort()
  end

  describe "the kit task" do
    test "vendors both support modules into the components directory" do
      igniter = test_project_with_formatter() |> Igniter.compose_task(MobKit, ["--yes"])

      assert content(igniter, "lib/test/components/event.ex") =~
               "defmodule Test.Components.Event do"

      assert content(igniter, "lib/test/components/color.ex") =~
               "defmodule Test.Components.Color do"
    end

    test "Event carries the widening that makes handlers fire at all" do
      igniter = test_project_with_formatter() |> Igniter.compose_task(MobKit, ["--yes"])
      event = content(igniter, "lib/test/components/event.ex")

      # A bare tag serialises as an ordinary prop and the control silently does
      # nothing; only `{pid, tag}` is registered as a handler.
      assert event =~ "def handler({pid, _tag} = wired) when is_pid(pid), do: wired"
      assert event =~ "def handler(tag), do: {self(), tag}"
    end

    test "--only vendors just that module" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(MobKit, ["--only", "event", "--yes"])

      assert content(igniter, "lib/test/components/event.ex")
      refute igniter.rewrite.sources["lib/test/components/color.ex"]
    end

    test "an unknown kit module is an issue rather than a silent no-op" do
      igniter =
        test_project_with_formatter() |> Igniter.compose_task(MobKit, ["--only", "nope", "--yes"])

      assert [issue] = igniter.issues
      assert issue =~ "No known kit modules"
    end
  end

  describe "selecting components" do
    test "generates each name given" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(MobComponents, ["chip,pill,switch", "--yes"])

      assert "chip" in generated(igniter)
      assert "pill" in generated(igniter)
      assert "switch" in generated(igniter)
    end

    test "a bare invocation generates the whole catalog" do
      # The convention the other plural tasks set: no argument means all of them.
      igniter = test_project_with_formatter() |> Igniter.compose_task(MobComponents, ["--yes"])

      names = generated(igniter)

      # 72 components plus the two vendored kit modules.
      assert length(names) == 74
      assert "drawer" in names
      assert "event" in names
    end

    test "the literal name `all` means the same thing" do
      bare = test_project_with_formatter() |> Igniter.compose_task(MobComponents, ["--yes"])

      explicit =
        test_project_with_formatter() |> Igniter.compose_task(MobComponents, ["all", "--yes"])

      assert generated(bare) == generated(explicit)
    end

    test "--exclude drops names from a whole-catalog run" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(MobComponents, ["--exclude", "drawer", "--yes"])

      names = generated(igniter)

      refute "drawer" in names
      assert "chip" in names
    end

    test "an excluded component still generates when something else needs it" do
      # alert_dialog delegates to dialog. Honouring the exclusion literally would
      # write a module whose alias points at a file that was never created — the
      # failure would surface as a compile error in the consumer's app, about a
      # component they did not ask for. A dependency wins over an exclusion.
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(MobComponents, ["alert_dialog", "--exclude", "dialog", "--yes"])

      names = generated(igniter)

      assert "alert_dialog" in names
      assert "dialog" in names
    end

    test "an unknown name surfaces as an issue from the single-component task" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(MobComponents, ["chip,nope", "--yes"])

      assert Enum.any?(igniter.issues, &(&1 =~ "not found in priv/mob/"))
      # the valid one is still generated
      assert "chip" in generated(igniter)
    end
  end

  describe "the registry across a bulk run" do
    test "is written once and lists every generated component" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(MobComponents, ["chip,pill", "--yes"])

      registry = content(igniter, "lib/test/components.ex")

      assert registry =~ "{:mishka_chip, Test.Components.Chip}"
      assert registry =~ "{:mishka_pill, Test.Components.Pill}"
    end

    test "a whole-catalog run registers all 72, and no kit module" do
      igniter = test_project_with_formatter() |> Igniter.compose_task(MobComponents, ["--yes"])

      registry = content(igniter, "lib/test/components.ex")
      tags = Regex.scan(~r/\{:(mishka_\w+),/, registry) |> Enum.map(&List.last/1)

      assert length(tags) == 72
      assert Enum.uniq(tags) == tags, "a tag was registered twice"
      refute "mishka_event" in tags
      refute "mishka_color" in tags
    end

    test "honours --module-prefix for the modules while keeping tags stable" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(MobComponents, ["chip", "--module-prefix", "mishka_", "--yes"])

      registry = content(igniter, "lib/test/components.ex")

      assert registry =~ "{:mishka_chip, Test.Components.MishkaChip}"
    end

    test "--no-register skips it entirely" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(MobComponents, ["chip", "--no-register", "--yes"])

      refute igniter.rewrite.sources["lib/test/components.ex"]
    end
  end

  describe "a whole-catalog generation" do
    setup do
      igniter = test_project_with_formatter() |> Igniter.compose_task(MobComponents, ["--yes"])

      %{igniter: igniter}
    end

    test "every component the catalog declares lands on disk", %{igniter: igniter} do
      catalog =
        Path.wildcard("priv/mob/*.eex") |> Enum.map(&Path.basename(&1, ".eex")) |> Enum.sort()

      assert catalog -- generated(igniter) == []
    end

    test "no generated file still mentions the development app", %{igniter: igniter} do
      # A leaked `MishkaMob.Components.…` would compile in our repo and fail in
      # the consumer's, which is the worst place to find out.
      leaked =
        igniter.rewrite.sources
        |> Enum.filter(fn {path, _} -> String.starts_with?(path, "lib/test/") end)
        |> Enum.filter(fn {_, source} -> Rewrite.Source.get(source, :content) =~ "MishkaMob" end)
        |> Enum.map(&elem(&1, 0))

      assert leaked == []
    end

    test "no generated file still contains an unrendered EEx tag", %{igniter: igniter} do
      unrendered =
        igniter.rewrite.sources
        |> Enum.filter(fn {path, _} -> String.starts_with?(path, "lib/test/") end)
        |> Enum.filter(fn {_, source} -> Rewrite.Source.get(source, :content) =~ "<%=" end)
        |> Enum.map(&elem(&1, 0))

      assert unrendered == []
    end
  end
end
