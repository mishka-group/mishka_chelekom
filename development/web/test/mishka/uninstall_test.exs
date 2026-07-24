defmodule Mishka.UninstallTest do
  @moduledoc """
  `mix mishka.ui.uninstall` — covers every flag: `--all`, `--headless`, `--dry-run`,
  `--force`, `--keep-js`, `--include-css`, `--include-config`, `--verbose`.

  The core "delete it for real" path runs end-to-end against the dev app (with `--keep-js`
  so only the component file changes) and restores the file verbatim afterwards. The
  destructive matrix modes (`--all`, cross-kind, dependency) are asserted on the staged
  `igniter.rms` so the whole harness is never mass-deleted.
  """
  use ExUnit.Case, async: false
  import MishkaCliHelper
  alias Mix.Tasks.Mishka.Ui.Uninstall, as: Task

  @moduletag :mishka_cli

  setup do
    Application.ensure_all_started(:owl)
    :ok
  end

  describe "real end-to-end deletion" do
    test "deletes a headless component from disk, then it is restored" do
      path = headless_path("tooltip")
      snap = snapshot(path)
      on_exit(fn -> restore(snap) end)

      assert File.exists?(path)
      mix!("mishka.ui.uninstall", ["tooltip", "--headless", "--keep-js", "--yes"])
      refute File.exists?(path), "expected #{path} to be deleted from disk"
    end
  end

  describe "styled (default)" do
    test "schedules the styled component file for removal" do
      igniter = stage(Task, ["accordion", "--yes"])
      assert styled_path("accordion") in igniter.rms
    end
  end

  describe "--headless" do
    test "removes the headless component and never the same-named styled one" do
      igniter = stage(Task, ["accordion", "--headless", "--yes"])
      assert headless_path("accordion") in igniter.rms
      refute styled_path("accordion") in igniter.rms
    end

    test "does not falsely flag a same-named styled dependency (cross-kind collision)" do
      igniter = stage(Task, ["scroll_area", "--headless", "--yes"])
      assert headless_path("scroll_area") in igniter.rms
      refute Enum.any?(igniter.issues, &(&1 =~ "tabs"))
    end
  end

  describe "--all" do
    test "removes both styled and headless components" do
      igniter = stage(Task, ["--all", "--yes"])
      assert styled_rms(igniter) != []
      assert headless_rms(igniter) != []
    end
  end

  describe "--all --headless" do
    test "removes only headless components with no false dependency issues" do
      igniter = stage(Task, ["--all", "--headless", "--yes"])
      assert headless_rms(igniter) != []
      assert styled_rms(igniter) == []
      assert igniter.issues == []
    end
  end

  describe "--dry-run" do
    test "schedules nothing for removal and leaves disk untouched" do
      igniter = stage(Task, ["accordion", "--dry-run"])
      refute styled_path("accordion") in igniter.rms
      assert igniter.rms == []
      assert File.exists?(styled_path("accordion"))
    end
  end

  describe "--keep-js" do
    test "removes the component but no JavaScript vendor files" do
      igniter = stage(Task, ["accordion", "--keep-js", "--yes"])
      assert styled_path("accordion") in igniter.rms
      refute Enum.any?(igniter.rms, &String.ends_with?(&1, ".js"))
    end
  end

  describe "no arguments" do
    test "asks for a component name or --all" do
      igniter = stage(Task, [])
      assert Enum.any?(igniter.issues, &(&1 =~ "--all" or &1 =~ "specify components"))
    end
  end

  describe "CLI contract" do
    test "exposes every documented flag and alias" do
      info = Task.info([], nil)

      for opt <- [
            :all,
            :headless,
            :dry_run,
            :force,
            :include_css,
            :include_config,
            :keep_js,
            :verbose
          ] do
        assert Keyword.get(info.schema, opt) == :boolean, "schema should expose --#{opt}"
      end

      assert info.aliases[:a] == :all
      assert info.aliases[:d] == :dry_run
      assert info.aliases[:f] == :force
      assert info.aliases[:V] == :verbose
    end
  end
end
