defmodule MishkaChelekom.MCP.Tools.GetMixTaskInfoTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Tools.GetMixTaskInfo
  alias Anubis.Server.Frame

  defp run(params) do
    {:reply, response, _frame} = GetMixTaskInfo.execute(params, %Frame{})
    [content | _] = response.content
    content["text"]
  end

  describe "input_schema/0" do
    test "exposes an optional task field" do
      schema = GetMixTaskInfo.input_schema()

      assert schema["type"] == "object"
      assert Map.has_key?(schema["properties"], "task")
    end
  end

  describe "full documentation" do
    test "surfaces the real mix-tasks.md content" do
      text = run(%{})

      # the actual documented tasks show up, straight from the source doc
      assert text =~ "## mix mishka.ui.gen.component"
      assert text =~ "## mix mishka.mcp.setup"
      assert text =~ "Full CLI docs"
    end
  end

  describe "a specific task" do
    test "extracts just that task's section, not the whole file" do
      full = run(%{})
      section = run(%{task: "gen.component"})

      assert section =~ "mishka.ui.gen.component"
      # section extraction genuinely narrowed the output...
      assert byte_size(section) < byte_size(full)
      # ...and dropped unrelated sections
      refute section =~ "## mix mishka.mcp.setup"
    end

    test "accepts common aliases for the same task" do
      # 'uninstall' and 'remove' both map to mishka.ui.uninstall
      for alias_name <- ["uninstall", "remove"] do
        assert run(%{task: alias_name}) =~ "mishka.ui.uninstall"
      end
    end
  end

  describe "an unknown task" do
    test "reports that the section was not found rather than failing" do
      assert run(%{task: "totally_bogus_task"}) =~ "Section not found"
    end
  end
end
