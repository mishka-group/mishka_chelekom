defmodule Mix.Tasks.Mishka.Ui.Gen.HeadlessTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias Mix.Tasks.Mishka.Ui.Gen.Headless
  @moduletag :igniter

  setup do
    Application.ensure_all_started(:owl)
    MishkaChelekom.ComponentTestHelper.setup_config()
    on_exit(fn -> MishkaChelekom.ComponentTestHelper.cleanup_config() end)
    :ok
  end

  defp source_content(igniter, path) do
    Rewrite.Source.get(igniter.rewrite.sources[path], :content)
  end

  describe "generation" do
    test "generates a headless component under components/headless/" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(Headless, ["accordion", "--yes"])

      path = "lib/test_web/components/headless/accordion.ex"
      assert igniter.rewrite.sources[path]
      assert source_content(igniter, path) =~ "defmodule TestWeb.Components.Headless.Accordion"
    end

    test "applies --module-prefix to the file and module names" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(Headless, ["accordion", "--module-prefix", "mishka_", "--yes"])

      path = "lib/test_web/components/headless/mishka_accordion.ex"
      assert igniter.rewrite.sources[path]

      assert source_content(igniter, path) =~
               "defmodule TestWeb.Components.Headless.MishkaAccordion"
    end

    test "honors a custom --module" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(Headless, ["accordion", "--module", "my_app.foo", "--yes"])

      path = "lib/test_web/components/headless/accordion.ex"
      assert source_content(igniter, path) =~ "defmodule MyApp.Foo"
    end
  end

  describe "css + config" do
    test "installs the headless base CSS vendor file and creates config.exs" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(Headless, ["accordion", "--yes"])

      assert igniter.rewrite.sources["assets/vendor/mishka_chelekom_headless.css"]
      assert igniter.rewrite.sources["priv/mishka_chelekom/config.exs"]
    end

    test "does not install the base CSS for a --sub generation" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(Headless, ["accordion", "--sub", "--yes"])

      refute igniter.rewrite.sources["assets/vendor/mishka_chelekom_headless.css"]
    end

    test "the headless @import is inserted AFTER tailwindcss, and deduped on re-run" do
      {:ok, :added, css} =
        MishkaChelekom.SimpleCSSUtilities.add_import(
          ~s|@import "tailwindcss";|,
          "../vendor/mishka_chelekom_headless.css"
        )

      {tailwind_at, _} = :binary.match(css, "tailwindcss")
      {headless_at, _} = :binary.match(css, "mishka_chelekom_headless")
      assert tailwind_at < headless_at

      # re-running detects it and does not add a second copy
      assert {:ok, :exists, again} =
               MishkaChelekom.SimpleCSSUtilities.add_import(
                 css,
                 "../vendor/mishka_chelekom_headless.css"
               )

      assert length(String.split(again, "../vendor/mishka_chelekom_headless.css")) == 2
    end
  end

  describe "validation" do
    test "adds an issue for a non-existent headless component" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(Headless, ["does_not_exist", "--yes"])

      assert Enum.join(igniter.issues, " ") =~ "not found in priv/headless/"
    end
  end
end
