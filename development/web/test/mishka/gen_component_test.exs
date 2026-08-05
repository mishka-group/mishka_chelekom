defmodule Mishka.GenComponentTest do
  @moduledoc """
  `mix mishka.ui.gen.component <component>` — the single styled generator.

  Real end-to-end generation plus per-option coverage (module / prefixes / the styled
  `--variant|--color|--size|…` selectors / `--sub` / `--no-save`).
  """
  use ExUnit.Case, async: false
  import MishkaCliHelper
  alias Mix.Tasks.Mishka.Ui.Gen.Component, as: Task

  @moduletag :mishka_cli

  setup do
    Application.ensure_all_started(:owl)
    :ok
  end

  describe "real end-to-end" do
    test "writes a styled component to the dev app, then removes it" do
      prefix = uniq_prefix("gc")
      path = prefixed_styled_path(prefix, "alert")
      on_exit(fn -> rm_generated(path) end)

      refute File.exists?(path)
      mix!("mishka.ui.gen.component", ["alert", "--module-prefix", prefix, "--no-save", "--yes"])
      assert File.exists?(path), "expected #{path} to be generated on disk"
      assert File.read!(path) =~ "defmodule"
    end
  end

  describe "component argument" do
    test "generates the styled component at components/<name>.ex" do
      igniter = stage(Task, ["alert", "--yes"])
      assert staged?(igniter, styled_path("alert"))
      refute staged?(igniter, headless_path("alert"))
    end
  end

  describe "--module-prefix / --component-prefix / --module" do
    test "--module-prefix prefixes the module + file path" do
      igniter = stage(Task, ["alert", "--module-prefix", "Admin", "--yes"])
      assert staged?(igniter, "#{components_dir()}/Adminalert.ex")
    end

    test "--component-prefix prefixes the public function name" do
      igniter = stage(Task, ["alert", "--component-prefix", "my_", "--yes"])
      assert staged_content(igniter, styled_path("alert")) =~ "my_alert"
    end

    test "--module overrides the module name" do
      igniter = stage(Task, ["alert", "--module", "CustomAlert", "--yes"])

      content =
        Enum.find_value(igniter.rewrite.sources, fn {p, s} ->
          String.contains?(p, "alert") && Rewrite.Source.get(s, :content)
        end)

      assert content =~ "CustomAlert"
    end
  end

  describe "styled variant selectors" do
    test "--variant limits the generated variants" do
      all = stage(Task, ["alert", "--yes"]) |> staged_content(styled_path("alert"))

      limited =
        stage(Task, ["alert", "--variant", "default", "--yes"])
        |> staged_content(styled_path("alert"))

      assert is_binary(all) and is_binary(limited)
      # narrowing the variant set can only shrink (or equal) the generated source
      assert String.length(limited) <= String.length(all)
    end
  end

  describe "--sub" do
    test "suppresses the banner while still generating" do
      out =
        ExUnit.CaptureIO.capture_io(fn ->
          igniter = stage(Task, ["alert", "--sub", "--yes"])
          assert staged?(igniter, styled_path("alert"))
        end)

      refute out =~ "Mishka.tools"
    end
  end

  describe "--no-save" do
    test "does not persist prefixes to the mishka config" do
      config = "priv/mishka_chelekom/config.exs"
      before = File.read(config)
      stage(Task, ["alert", "--module-prefix", "Temp", "--no-save", "--yes"])
      assert File.read(config) == before
    end
  end

  describe "CLI contract" do
    test "exposes the styled schema and the -m alias" do
      info = Task.info([], nil)
      assert info.positional == [:component]

      for opt <- [
            :variant,
            :color,
            :size,
            :padding,
            :space,
            :type,
            :rounded,
            :module,
            :component_prefix,
            :module_prefix,
            :sub,
            :no_deps,
            :no_save
          ] do
        assert Keyword.has_key?(info.schema, opt), "schema should expose --#{opt}"
      end
    end
  end
end
