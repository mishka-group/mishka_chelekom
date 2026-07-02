defmodule MishkaChelekom.MCP.Tools.UninstallComponentTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Tools.UninstallComponent
  alias MishkaChelekom.MCP.ComponentConfig
  alias Anubis.Server.Frame

  defp run(params) do
    {:reply, response, _frame} = UninstallComponent.execute(params, %Frame{})
    [content | _] = response.content
    content["text"]
  end

  # The exact command a user would run — the content of the first ```bash fence (the
  # "## Command" block, which precedes the "Recommended Usage" examples).
  defp generated_command(text) do
    [_, command_block | _] = String.split(text, "```bash")

    command_block
    |> String.split("```")
    |> List.first()
    |> String.trim()
  end

  describe "input_schema/0" do
    test "exposes every documented option" do
      schema = UninstallComponent.input_schema()

      assert schema["type"] == "object"

      for field <- ~w(name all dry_run force keep_js) do
        assert Map.has_key?(schema["properties"], field), "schema should document #{field}"
      end
    end
  end

  describe "command building" do
    test "a single component produces a non-interactive uninstall command" do
      assert generated_command(run(%{name: "accordion"})) ==
               "mix mishka.ui.uninstall accordion --yes"
    end

    test "--all is honored and warns about the destructive scope" do
      text = run(%{all: true})

      assert generated_command(text) == "mix mishka.ui.uninstall --all --yes"
      assert text =~ "ALL"
    end

    test "dry-run previews and never appends --yes" do
      text = run(%{name: "accordion", dry_run: true})

      assert generated_command(text) == "mix mishka.ui.uninstall accordion --dry-run"
      assert text =~ "Dry Run"
    end

    test "force and keep-js flags are threaded through in order" do
      assert generated_command(run(%{name: "accordion", force: true, keep_js: true})) ==
               "mix mishka.ui.uninstall accordion --force --keep-js --yes"
    end
  end

  describe "dependency awareness" do
    test "warns when removing a component other components necessarily depend on" do
      deps = ComponentConfig.list_dependencies()

      # a component that at least one other component lists as a *necessary* dependency
      target =
        deps
        |> Enum.flat_map(fn {_comp, %{necessary: nec}} -> Enum.filter(nec, &is_binary/1) end)
        |> List.first()

      expected_dependents =
        deps
        |> Enum.filter(fn {_comp, %{necessary: nec}} -> target in nec end)
        |> Enum.map(fn {comp, _} -> comp end)

      refute is_nil(target), "expected some component to declare a necessary dependency"
      assert expected_dependents != []

      text = run(%{name: target})

      assert text =~ "depend on"
      assert text =~ "--force"

      assert Enum.any?(expected_dependents, &(text =~ &1)),
             "warning should name the dependent component(s): #{inspect(expected_dependents)}"
    end

    test "--force suppresses the dependency warning" do
      deps = ComponentConfig.list_dependencies()

      target =
        deps
        |> Enum.flat_map(fn {_comp, %{necessary: nec}} -> Enum.filter(nec, &is_binary/1) end)
        |> List.first()

      refute run(%{name: target, force: true}) =~ "depend on"
    end
  end
end
