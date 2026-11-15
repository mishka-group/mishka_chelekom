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

  describe "layer: :headless" do
    @headless_path "lib/test_web/components/mishka_headless_components.ex"

    defp headless(components, opts \\ []) do
      igniter =
        ImportMacro.create(
          test_project_with_formatter(),
          components,
          [import: true, layer: :headless] ++ opts
        )

      {_, source} = Rewrite.source(igniter.rewrite, @headless_path)
      Rewrite.Source.get(source, :content)
    end

    test "writes its own file and leaves the styled macro alone" do
      igniter =
        ImportMacro.create(test_project_with_formatter(), ["accordion"],
          import: true,
          layer: :headless
        )

      assert igniter.rewrite.sources[@headless_path]
      refute igniter.rewrite.sources[@path]
    end

    test "imports the Headless modules" do
      content = headless(["accordion", "dialog"])

      assert content =~ "defmodule TestWeb.Components.MishkaHeadlessComponents"
      assert content =~ "TestWeb.Components.Headless.Accordion"
      assert content =~ "TestWeb.Components.Headless.Dialog"
      assert content =~ "mix mishka.ui.gen.headless.components --import"
    end

    test "--helpers adds the catalog helper functions" do
      with_helpers = headless(["accordion"], helpers: true)
      assert with_helpers =~ "only: ["
    end

    test "applies the module and component prefixes" do
      content = headless(["accordion"], module_prefix: "mishka_", component_prefix: "m_")

      assert content =~ "TestWeb.Components.Headless.MishkaAccordion"
      assert content =~ "m_accordion: 1"
    end

    test "--global warns with the names both macros really share, unless prefixed" do
      styled = fn function ->
        """
        defmodule TestWeb.Components.MishkaComponents do
          defp imports, do: [{TestWeb.Components.Thing, only: [#{function}: 1]}]
        end
        """
      end

      run = fn function, extra ->
        test_project_with_formatter(
          files: %{
            @path => styled.(function),
            "lib/test_web.ex" => "defmodule TestWeb do\nend\n"
          }
        )
        |> ImportMacro.create(
          ["accordion"],
          [import: true, layer: :headless, global: true] ++ extra
        )
      end

      assert [warning] = run.("accordion", []).warnings
      assert warning =~ "accordion"
      assert run.("button", []).warnings == []
      assert run.("accordion", component_prefix: "hl_").warnings == []
    end

    test "--global appends one use and keeps CoreComponents" do
      web_ex = """
      defmodule TestWeb do
        defp html_helpers do
          quote do
            use Phoenix.Component
            import TestWeb.CoreComponents
          end
        end
      end
      """

      run = fn igniter ->
        ImportMacro.create(igniter, ["accordion"], import: true, layer: :headless, global: true)
      end

      igniter =
        test_project_with_formatter(files: %{"lib/test_web.ex" => web_ex})
        |> run.()
        |> Igniter.Test.apply_igniter!()
        |> run.()

      {_, source} = Rewrite.source(igniter.rewrite, "lib/test_web.ex")
      web = Rewrite.Source.get(source, :content)

      assert length(Regex.scan(~r/use TestWeb\.Components\.MishkaHeadlessComponents/, web)) == 1
      assert web =~ "import TestWeb.CoreComponents"
    end
  end
end
