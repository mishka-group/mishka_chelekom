defmodule MishkaChelekom.MCP.Tools.GetComponentInfoTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Tools.GetComponentInfo
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "input_schema/0 returns a valid JSON schema" do
      schema = GetComponentInfo.input_schema()

      assert schema["type"] == "object"
      assert is_map(schema["properties"])
      assert "name" in schema["required"]
    end
  end

  describe "execute/2" do
    test "returns component info with documentation link" do
      frame = %Frame{}
      params = %{name: "button"}

      {:reply, response, _frame} = GetComponentInfo.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "# Button Component"
      assert text =~ "https://mishka.tools/chelekom/docs/button"
      assert text =~ "mix mishka.ui.gen.component button"
    end

    test "returns variants for existing component" do
      frame = %Frame{}
      params = %{name: "button"}

      {:reply, response, _frame} = GetComponentInfo.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      # Button has variants in its config
      assert text =~ "Variants:"
    end

    test "returns colors for existing component" do
      frame = %Frame{}
      params = %{name: "alert"}

      {:reply, response, _frame} = GetComponentInfo.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      # Alert has colors in its config
      assert text =~ "Colors:"
    end

    test "returns sizes for existing component" do
      frame = %Frame{}
      params = %{name: "button"}

      {:reply, response, _frame} = GetComponentInfo.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      # Button has sizes in its config
      assert text =~ "Sizes:"
    end

    test "returns helpers for components that have them" do
      frame = %Frame{}
      params = %{name: "alert"}

      {:reply, response, _frame} = GetComponentInfo.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      # Alert component has helper functions
      assert text =~ "Helper Functions:"
    end

    test "handles non-existent component config gracefully" do
      frame = %Frame{}
      params = %{name: "nonexistent_component"}

      {:reply, response, _frame} = GetComponentInfo.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      # Should still return a response with the component name
      assert text =~ "NonexistentComponent Component"
      # Should include generation command even for unknown components
      assert text =~ "mix mishka.ui.gen.component nonexistent_component"
    end
  end
end
