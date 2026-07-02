defmodule MishkaChelekom.MCP.Tools.GenerateComponentsTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Tools.GenerateComponents
  alias MishkaChelekom.MCP.ComponentConfig
  alias Anubis.Server.Frame

  # Names of every real component the library ships — the tool is expected to stay in
  # lock-step with this list, so we derive expectations from it rather than hardcoding.
  defp all_component_names, do: ComponentConfig.list_components() |> Enum.map(& &1.name)

  defp run(params) do
    {:reply, response, _frame} = GenerateComponents.execute(params, %Frame{})
    [content | _] = response.content
    content["text"]
  end

  # The exact command a user would run — the content of the first ```bash fence (the
  # "## Command" block), not the static "Recommended Commands" examples further down.
  defp generated_command(text) do
    [_, command_block | _] = String.split(text, "```bash")

    command_block
    |> String.split("```")
    |> List.first()
    |> String.trim()
  end

  describe "input_schema/0" do
    test "is a valid object schema exposing every documented option" do
      schema = GenerateComponents.input_schema()

      assert schema["type"] == "object"
      assert is_map(schema["properties"])

      for field <- ~w(components import helpers global exclude module_prefix component_prefix) do
        assert Map.has_key?(schema["properties"], field),
               "schema should document the #{field} option"
      end
    end
  end

  describe "component selection" do
    test "an empty request expands to every real component" do
      text = run(%{})
      names = all_component_names()

      assert text =~ "Components to Generate (#{length(names)})"
      # every shipped component must show up in the plan
      Enum.each(names, fn name -> assert text =~ name end)
      # and the bare command carries no explicit list
      assert generated_command(text) == "mix mishka.ui.gen.components --yes"
    end

    test "\"all\" behaves the same as an empty request" do
      assert run(%{components: "all"}) =~
               "Components to Generate (#{length(all_component_names())})"
    end

    test "a specific, comma-separated list is passed through verbatim" do
      text = run(%{components: "button,alert,card"})

      assert text =~ "Components to Generate (3)"
      assert text =~ "button"
      assert text =~ "alert"
      assert text =~ "card"
      assert generated_command(text) == "mix mishka.ui.gen.components button,alert,card --yes"
    end

    test "exclude removes components from the plan and the command" do
      names = all_component_names()
      excluded = hd(names)

      text = run(%{exclude: excluded})

      assert text =~ "Components to Generate (#{length(names) - 1})"
      assert generated_command(text) == "mix mishka.ui.gen.components --exclude #{excluded} --yes"
      assert text =~ "## Excluded: #{excluded}"
    end
  end

  describe "flags and prefixes" do
    test "import/helpers/global flags are threaded into the command and the plan" do
      text = run(%{components: "button", import: true, helpers: true, global: true})

      assert generated_command(text) ==
               "mix mishka.ui.gen.components button --import --helpers --global --yes"

      assert text =~ "Create import macro file"
      assert text =~ "Replace CoreComponents"
    end

    test "flags are omitted from the command when not requested" do
      # (the static "Recommended Commands" block always mentions the flags, so we must
      # assert on the generated command specifically, not the whole response text)
      assert generated_command(run(%{components: "button"})) ==
               "mix mishka.ui.gen.components button --yes"
    end

    test "module and component prefixes are forwarded" do
      text = run(%{components: "button", module_prefix: "Mishka", component_prefix: "mishka_"})

      assert generated_command(text) ==
               "mix mishka.ui.gen.components button --module-prefix Mishka --component-prefix mishka_ --yes"
    end

    test "the generated command is always non-interactive" do
      assert generated_command(run(%{components: "button"})) =~ "--yes"
    end
  end
end
