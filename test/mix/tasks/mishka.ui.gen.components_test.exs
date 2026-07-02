defmodule Mix.Tasks.Mishka.Ui.Gen.ComponentsTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias Mix.Tasks.Mishka.Ui.Gen.Components
  @moduletag :igniter

  setup do
    Application.ensure_all_started(:owl)
    MishkaChelekom.ComponentTestHelper.setup_config()
    on_exit(fn -> MishkaChelekom.ComponentTestHelper.cleanup_config() end)
    :ok
  end

  describe "info/1 CLI contract" do
    test "composes the singular generator and exposes every batch option" do
      info = Components.info([], nil)

      assert info.group == :mishka_chelekom
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

      # the documented CLI aliases
      assert info.aliases[:i] == :import
      assert info.aliases[:g] == :global
      assert info.aliases[:e] == :exclude
    end
  end

  describe "end-to-end wiring" do
    test "drives the per-component generator (surfaces host validation) rather than no-op'ing" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(Components, ["button", "--yes"])

      # the batch task fanned out to the singular generator, which validated the host
      # project; on a bare project (no Phoenix) that validation must surface as an issue
      assert Enum.join(igniter.issues, " ") =~ "Phoenix"
    end
  end
end
