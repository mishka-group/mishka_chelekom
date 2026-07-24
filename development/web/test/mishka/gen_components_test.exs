defmodule Mishka.GenComponentsTest do
  @moduledoc """
  `mix mishka.ui.gen.components [names]` — the batch styled generator.

  Covers `--import`, `--helpers`, `--global`, `--exclude`, the prefixes, and `--sub`.
  """
  use ExUnit.Case, async: false
  import MishkaCliHelper
  alias Mix.Tasks.Mishka.Ui.Gen.Components, as: Task

  @moduletag :mishka_cli

  setup do
    Application.ensure_all_started(:owl)
    :ok
  end

  describe "real end-to-end" do
    test "writes a styled component to disk via the batch task, then removes it" do
      prefix = uniq_prefix("gcs")
      path = prefixed_styled_path(prefix, "badge")
      on_exit(fn -> rm_generated(path) end)

      refute File.exists?(path)
      mix!("mishka.ui.gen.components", ["badge", "--module-prefix", prefix, "--no-save", "--yes"])
      assert File.exists?(path)
    end
  end

  describe "component list" do
    test "generates every requested styled component" do
      igniter = stage(Task, ["accordion,alert", "--yes"])
      assert staged?(igniter, styled_path("accordion"))
      assert staged?(igniter, styled_path("alert"))
    end
  end

  describe "--exclude" do
    test "skips excluded names" do
      igniter = stage(Task, ["accordion,alert", "--exclude", "alert", "--yes"])
      assert staged?(igniter, styled_path("accordion"))
      refute staged?(igniter, styled_path("alert"))
    end
  end

  describe "--import / --helpers" do
    test "--import writes the MishkaComponents import macro" do
      igniter = stage(Task, ["accordion", "--import", "--yes"])
      assert staged?(igniter, "#{components_dir()}/mishka_components.ex")
    end

    test "--helpers is accepted alongside --import" do
      igniter = stage(Task, ["accordion", "--import", "--helpers", "--yes"])
      assert staged?(igniter, "#{components_dir()}/mishka_components.ex")
      assert igniter.issues == []
    end
  end

  describe "--global" do
    test "wires the components into the web module without error" do
      igniter = stage(Task, ["accordion", "--import", "--global", "--yes"])
      assert igniter.issues == []
    end
  end

  describe "--module-prefix / --component-prefix" do
    test "--module-prefix prefixes each generated file path" do
      igniter = stage(Task, ["accordion", "--module-prefix", "Admin", "--yes"])
      assert staged?(igniter, "#{components_dir()}/Adminaccordion.ex")
    end

    test "--component-prefix prefixes the public function names" do
      igniter = stage(Task, ["accordion", "--component-prefix", "my_", "--yes"])
      assert staged_content(igniter, styled_path("accordion")) =~ "my_accordion"
    end
  end

  describe "CLI contract" do
    test "exposes the batch schema and aliases" do
      info = Task.info([], nil)
      assert info.positional == [{:components, optional: true}]
      assert "mishka.ui.gen.component" in info.composes

      for opt <- [
            :import,
            :helpers,
            :global,
            :exclude,
            :component_prefix,
            :module_prefix,
            :no_save
          ] do
        assert Keyword.has_key?(info.schema, opt), "schema should expose --#{opt}"
      end

      assert info.aliases[:i] == :import
      assert info.aliases[:g] == :global
      assert info.aliases[:e] == :exclude
    end
  end
end
