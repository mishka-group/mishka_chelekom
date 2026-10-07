defmodule MishkaChelekom.Generators.ImportMacroTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias MishkaChelekom.Generators.ImportMacro
  @moduletag :igniter

  @path "lib/test_web/components/mishka_components.ex"

  defp generated(components) do
    igniter = ImportMacro.create(test_project_with_formatter(), components, import: true)
    {_, source} = Rewrite.source(igniter.rewrite, @path)
    Rewrite.Source.get(source, :content)
  end

  # Compiles the generated module and expands its `__using__/1`, which is what `use` injects.
  defp injected_imports(content) do
    [{module, _bytecode}] = Code.compile_string(content)

    try do
      Enum.map(module."MACRO-__using__"(__ENV__, []), &Macro.to_string/1)
    after
      :code.purge(module)
      :code.delete(module)
    end
  end

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

  test "the macro imports each component with only its own functions" do
    assert injected_imports(generated(["accordion", "divider"])) == [
             "import TestWeb.Components.Accordion, only: [accordion: 1]",
             "import TestWeb.Components.Divider, only: [divider: 1, hr: 1]"
           ]
  end

  test "the generated module is documented and lists its imports outside the quote block" do
    content = generated(["accordion", "divider"])

    assert content =~ "@moduledoc"
    assert content =~ "{TestWeb.Components.Accordion, only: [accordion: 1]}"
    refute content =~ ~r/quote do\s+import /
  end
end
