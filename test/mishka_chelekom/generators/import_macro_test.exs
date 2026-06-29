defmodule MishkaChelekom.Generators.ImportMacroTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias MishkaChelekom.Generators.ImportMacro
  @moduletag :igniter

  test "is a no-op when :import is not set" do
    igniter = test_project_with_formatter()
    before = map_size(igniter.rewrite.sources)

    result = ImportMacro.create(igniter, ["accordion"], import: false)

    assert map_size(result.rewrite.sources) == before
  end

  test "generates the MishkaComponents import macro file when :import is set" do
    igniter =
      test_project_with_formatter()
      |> ImportMacro.create(["accordion"], import: true)

    assert Enum.any?(
             Map.keys(igniter.rewrite.sources),
             &String.ends_with?(&1, "components/mishka_components.ex")
           )
  end
end
