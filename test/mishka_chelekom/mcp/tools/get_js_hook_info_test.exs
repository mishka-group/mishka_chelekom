defmodule MishkaChelekom.MCP.Tools.GetJsHookInfoTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Tools.GetJsHookInfo
  alias MishkaChelekom.MCP.ComponentConfig
  alias Anubis.Server.Frame

  defp run(params) do
    {:reply, response, _frame} = GetJsHookInfo.execute(params, %Frame{})
    [content | _] = response.content
    content["text"]
  end

  # A hook that genuinely ships a markdown doc under usage-rules/js/ — derived, not hardcoded.
  defp a_documented_hook do
    Path.wildcard("usage-rules/js/*.md")
    |> Enum.map(&Path.basename(&1, ".md"))
    |> Enum.sort()
    |> List.first()
  end

  describe "input_schema/0" do
    test "exposes an optional name field" do
      schema = GetJsHookInfo.input_schema()

      assert schema["type"] == "object"
      assert Map.has_key?(schema["properties"], "name")
    end
  end

  describe "listing all hooks" do
    test "reports the real hook count and every hook module" do
      hooks = ComponentConfig.list_js_hooks()
      text = run(%{})

      assert text =~ "#{length(hooks)} JavaScript hooks"
      assert text =~ "Available Hooks"

      Enum.each(hooks, fn hook -> assert text =~ hook.module end)
    end

    test "an empty name string is treated as \"list all\"" do
      assert run(%{name: ""}) =~ "Available Hooks"
    end
  end

  describe "a specific hook with documentation" do
    test "embeds the real markdown doc and points at the JS file" do
      hook = a_documented_hook()
      refute is_nil(hook), "expected at least one usage-rules/js/*.md doc to exist"

      doc = File.read!("usage-rules/js/#{hook}.md")
      text = run(%{name: hook})

      # the full, real documentation body is surfaced verbatim
      assert String.contains?(text, String.trim(doc))
      # and it links to the actual hook source
      assert text =~ "priv/assets/js/#{hook}.js"
    end

    test "hook names are matched case-insensitively" do
      hook = a_documented_hook()
      doc = File.read!("usage-rules/js/#{hook}.md")

      assert String.contains?(run(%{name: String.upcase(hook)}), String.trim(doc))
    end
  end

  describe "an unknown hook" do
    test "falls back gracefully and still lists the available hooks" do
      text = run(%{name: "definitely_not_a_real_hook"})

      assert text =~ "Documentation not found"
      # the fallback still helps the caller by listing real hooks
      real_hook = ComponentConfig.list_js_hooks() |> List.first()
      assert text =~ real_hook.name
    end
  end
end
