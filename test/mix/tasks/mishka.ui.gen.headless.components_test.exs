defmodule Mix.Tasks.Mishka.Ui.Gen.Headless.ComponentsTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias Mix.Tasks.Mishka.Ui.Gen.Headless.Components
  @moduletag :igniter

  setup do
    Application.ensure_all_started(:owl)
    MishkaChelekom.ComponentTestHelper.setup_config()
    on_exit(fn -> MishkaChelekom.ComponentTestHelper.cleanup_config() end)
    :ok
  end

  test "generates each requested headless component" do
    igniter =
      test_project_with_formatter()
      |> Igniter.compose_task(Components, ["accordion,dialog", "--yes"])

    assert igniter.rewrite.sources["lib/test_web/components/headless/accordion.ex"]
    assert igniter.rewrite.sources["lib/test_web/components/headless/dialog.ex"]
  end

  test "skips components named in --exclude" do
    igniter =
      test_project_with_formatter()
      |> Igniter.compose_task(Components, ["accordion,dialog", "--exclude", "dialog", "--yes"])

    assert igniter.rewrite.sources["lib/test_web/components/headless/accordion.ex"]
    refute igniter.rewrite.sources["lib/test_web/components/headless/dialog.ex"]
  end

  test "applies --module-prefix to every generated component" do
    igniter =
      test_project_with_formatter()
      |> Igniter.compose_task(Components, ["accordion", "--module-prefix", "mishka_", "--yes"])

    assert igniter.rewrite.sources["lib/test_web/components/headless/mishka_accordion.ex"]
  end
end
