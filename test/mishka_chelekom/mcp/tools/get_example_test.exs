defmodule MishkaChelekom.MCP.Tools.GetExampleTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Tools.GetExample
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "input_schema/0 returns a valid JSON schema" do
      schema = GetExample.input_schema()

      assert schema["type"] == "object"
      assert is_map(schema["properties"])
      assert "name" in schema["required"]
    end
  end

  describe "execute/2" do
    test "returns full documentation for alert component" do
      frame = %Frame{}
      params = %{name: "alert"}

      {:reply, response, _frame} = GetExample.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      # Should include the markdown documentation
      assert text =~ "Alert Component"
      assert text =~ "flash"
      assert text =~ "mix mishka.ui.gen.component alert"
    end

    test "returns full documentation for button component" do
      frame = %Frame{}
      params = %{name: "button"}

      {:reply, response, _frame} = GetExample.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "Button Component"
      assert text =~ "mix mishka.ui.gen.component button"
    end

    test "includes documentation link in response" do
      frame = %Frame{}
      params = %{name: "card"}

      {:reply, response, _frame} = GetExample.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "https://mishka.tools/chelekom/docs/card"
    end

    test "includes generator command in response" do
      frame = %Frame{}
      params = %{name: "tabs"}

      {:reply, response, _frame} = GetExample.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "mix mishka.ui.gen.component tabs"
    end

    test "returns fallback for unknown component" do
      frame = %Frame{}
      params = %{name: "unknown_component"}

      {:reply, response, _frame} = GetExample.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      # Fallback response includes basic example
      assert text =~ "<.unknown_component>"
      assert text =~ "Content here"
      assert text =~ "Documentation file not found"
    end

    test "includes component types for multi-type components" do
      frame = %Frame{}
      params = %{name: "alert"}

      {:reply, response, _frame} = GetExample.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      # Alert has multiple types: flash, flash_group, alert
      assert text =~ "Component Types"
    end

    test "includes attributes section from documentation" do
      frame = %Frame{}
      params = %{name: "modal"}

      {:reply, response, _frame} = GetExample.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "Attributes"
    end

    test "returns dependencies info from documentation" do
      frame = %Frame{}
      params = %{name: "alert"}

      {:reply, response, _frame} = GetExample.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      # Alert depends on icon
      assert text =~ "icon"
    end
  end
end
