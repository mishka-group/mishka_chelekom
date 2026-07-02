defmodule Mix.Tasks.MishkaChelekom.InstallTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias Mix.Tasks.MishkaChelekom.Install
  @moduletag :igniter

  setup do
    Application.ensure_all_started(:owl)
    MishkaChelekom.ComponentTestHelper.setup_config()
    on_exit(fn -> MishkaChelekom.ComponentTestHelper.cleanup_config() end)
    :ok
  end

  describe "info/1 installer contract" do
    test "only installs in :dev and belongs to the mishka_chelekom group" do
      info = Install.info([], nil)

      # the installer must never run outside dev
      assert info.only == [:dev]
      assert info.group == :mishka_chelekom
    end
  end

  describe "igniter/1 wiring" do
    test "drives the component generator pipeline end-to-end" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(Install, [])

      # the installer composes mishka.ui.gen.components (--import --helpers --global),
      # which fans out to the per-component generator; on a bare project that surfaces
      # the Phoenix validation issue, proving the installer is wired rather than a no-op
      assert Enum.join(igniter.issues, " ") =~ "Phoenix"
    end
  end
end
