defmodule Mishka.GenHeadlessComponentsTest do
  @moduledoc """
  `mix mishka.ui.gen.headless.components [names]` — the batch headless generator.

  Covers a named list, `--exclude`, the prefixes, and the "omit the list ⇒ generate every
  headless component" behaviour.
  """
  use ExUnit.Case, async: false
  import MishkaCliHelper
  alias Mix.Tasks.Mishka.Ui.Gen.Headless.Components, as: Task

  @moduletag :mishka_cli
  # Staging the whole catalog through Igniter runs well past ExUnit's 60s default on a
  # loaded CI runner; the work is real, not a hang.
  @moduletag timeout: 300_000

  setup do
    Application.ensure_all_started(:owl)
    :ok
  end

  describe "real end-to-end" do
    test "writes a headless component to disk via the batch task, then removes it" do
      prefix = uniq_prefix("ghc")
      path = prefixed_headless_path(prefix, "dialog")
      on_exit(fn -> rm_generated(path) end)

      refute File.exists?(path)

      mix!("mishka.ui.gen.headless.components", [
        "dialog",
        "--module-prefix",
        prefix,
        "--no-save",
        "--yes"
      ])

      assert File.exists?(path)
    end
  end

  describe "component list" do
    test "generates every requested headless component" do
      igniter = stage(Task, ["dialog,tabs", "--yes"])
      assert staged?(igniter, headless_path("dialog"))
      assert staged?(igniter, headless_path("tabs"))
    end
  end

  describe "--exclude" do
    test "skips excluded names" do
      igniter = stage(Task, ["dialog,tabs", "--exclude", "tabs", "--yes"])
      assert staged?(igniter, headless_path("dialog"))
      refute staged?(igniter, headless_path("tabs"))
    end
  end

  describe "no list ⇒ every headless component" do
    test "generates the whole headless catalog when the list is omitted" do
      igniter = stage(Task, ["--yes"])
      generated = headless_rms_or_sources(igniter)

      assert length(generated) > 20,
             "expected the full headless catalog, got #{length(generated)}"

      assert staged?(igniter, headless_path("dialog"))
    end
  end

  describe "--module-prefix / --component-prefix" do
    test "--module-prefix prefixes each generated file path" do
      igniter = stage(Task, ["dialog", "--module-prefix", "Admin", "--yes"])
      assert staged?(igniter, "#{headless_dir()}/Admindialog.ex")
    end

    test "--component-prefix prefixes the public function names" do
      igniter = stage(Task, ["dialog", "--component-prefix", "my_", "--yes"])
      assert staged_content(igniter, headless_path("dialog")) =~ "my_dialog"
    end
  end

  describe "--import / --helpers / --global" do
    @macro_path "lib/development_web/components/mishka_headless_components.ex"
    @web_path "lib/development_web.ex"

    test "--import stages a headless macro listing each generated module" do
      igniter = stage(Task, ["dialog,tabs", "--import", "--yes"])
      content = staged_content(igniter, @macro_path)

      assert content =~ "DevelopmentWeb.Components.Headless.Dialog"
      assert content =~ "DevelopmentWeb.Components.Headless.Tabs"
      refute staged?(igniter, "lib/development_web/components/mishka_components.ex")
    end

    test "nothing is staged for the macro without --import" do
      refute staged?(stage(Task, ["dialog", "--yes"]), @macro_path)
    end

    test "--global stages one use line in html_helpers and keeps the styled one" do
      igniter = stage(Task, ["dialog", "--import", "--global", "--yes"])
      web = staged_content(igniter, @web_path)

      assert length(Regex.scan(~r/use DevelopmentWeb\.Components\.MishkaHeadlessComponents/, web)) ==
               1

      assert web =~ "use DevelopmentWeb.Components.MishkaComponents"
    end
  end

  describe "CLI contract" do
    test "exposes the batch schema and the -e alias" do
      info = Task.info([], nil)
      assert info.positional == [{:components, optional: true}]
      assert "mishka.ui.gen.headless" in info.composes

      for opt <- [
            :exclude,
            :component_prefix,
            :module_prefix,
            :no_save,
            :import,
            :helpers,
            :global
          ] do
        assert Keyword.has_key?(info.schema, opt), "schema should expose --#{opt}"
      end

      assert info.aliases[:e] == :exclude
      assert info.aliases[:i] == :import
      assert info.aliases[:g] == :global
    end
  end

  defp headless_rms_or_sources(igniter) do
    igniter.rewrite.sources
    |> Map.keys()
    |> Enum.filter(&String.contains?(&1, "/components/headless/"))
  end
end
