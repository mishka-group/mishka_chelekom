defmodule Mishka.GenHeadlessTest do
  @moduledoc """
  `mix mishka.ui.gen.headless <component>` — the single headless generator.

  One real end-to-end pass (writes a uniquely-prefixed file to the dev app and removes it),
  plus exhaustive per-option coverage staged in-memory via `Igniter.new/0`.
  """
  use ExUnit.Case, async: false
  import MishkaCliHelper
  alias Mix.Tasks.Mishka.Ui.Gen.Headless, as: Task

  @moduletag :mishka_cli

  setup do
    Application.ensure_all_started(:owl)
    :ok
  end

  describe "real end-to-end" do
    test "writes a headless component to the dev app filesystem, then it is removed" do
      prefix = uniq_prefix("gh")
      path = prefixed_headless_path(prefix, "dialog")
      on_exit(fn -> rm_generated(path) end)

      refute File.exists?(path)
      mix!("mishka.ui.gen.headless", ["dialog", "--module-prefix", prefix, "--no-save", "--yes"])
      assert File.exists?(path), "expected #{path} to be generated on disk"
      assert File.read!(path) =~ "defmodule"
    end
  end

  describe "component argument" do
    test "generates the component under components/headless/" do
      igniter = stage(Task, ["dialog", "--yes"])
      assert staged?(igniter, headless_path("dialog"))
      refute staged?(igniter, styled_path("dialog"))
    end

    test "an unknown component surfaces a not-found issue" do
      igniter = stage(Task, ["not_a_real_component", "--yes"])
      assert Enum.any?(igniter.issues, &(&1 =~ "not_a_real_component" or &1 =~ "not found"))
    end
  end

  describe "--module-prefix" do
    test "prefixes the module name and the file path" do
      igniter = stage(Task, ["dialog", "--module-prefix", "Admin", "--yes"])
      assert staged?(igniter, "#{headless_dir()}/Admindialog.ex")
      assert staged_content(igniter, "#{headless_dir()}/Admindialog.ex") =~ "Admindialog"
    end
  end

  describe "--component-prefix" do
    test "prefixes the public component function name" do
      igniter = stage(Task, ["dialog", "--component-prefix", "my_", "--yes"])
      assert staged_content(igniter, headless_path("dialog")) =~ "my_dialog"
    end
  end

  describe "--module (-m)" do
    test "overrides the module name" do
      igniter = stage(Task, ["dialog", "--module", "CustomDialog", "--yes"])

      content =
        Enum.find_value(igniter.rewrite.sources, fn {p, s} ->
          String.contains?(p, "dialog") && Rewrite.Source.get(s, :content)
        end)

      assert content =~ "CustomDialog"
    end
  end

  describe "--sub (dependency sub-generation)" do
    test "still generates the component but prints no banner" do
      out =
        ExUnit.CaptureIO.capture_io(fn ->
          igniter = stage(Task, ["dialog", "--sub", "--yes"])
          assert staged?(igniter, headless_path("dialog"))
        end)

      refute out =~ "Mishka.tools"
    end
  end

  describe "--no-save" do
    test "does not persist prefixes into the mishka config on disk" do
      config = "priv/mishka_chelekom/config.exs"
      before = File.read(config)

      stage(Task, ["dialog", "--module-prefix", "Temp", "--no-save", "--yes"])

      assert File.read(config) == before
    end
  end

  describe "CLI contract" do
    test "exposes the documented positional, schema and aliases" do
      info = Task.info([], nil)
      assert info.positional == [:component]

      for opt <- [:module, :component_prefix, :module_prefix, :sub, :no_save] do
        assert Keyword.has_key?(info.schema, opt), "schema should expose --#{opt}"
      end

      assert info.aliases[:m] == :module
    end
  end
end
