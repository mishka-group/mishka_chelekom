defmodule MishkaChelekom.MCP.Tools.GenerateComponentTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Tools.GenerateComponent
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "input_schema/0 returns a valid JSON schema" do
      schema = GenerateComponent.input_schema()

      assert schema["type"] == "object"
      assert is_map(schema["properties"])
      assert "name" in schema["required"]
    end

    test "input_schema includes name as required field" do
      schema = GenerateComponent.input_schema()

      assert Map.has_key?(schema["properties"], "name")
      assert "name" in schema["required"]
    end

    test "input_schema includes optional customization fields" do
      schema = GenerateComponent.input_schema()
      properties = schema["properties"]

      assert Map.has_key?(properties, "color")
      assert Map.has_key?(properties, "variant")
      assert Map.has_key?(properties, "size")
      assert Map.has_key?(properties, "padding")
      assert Map.has_key?(properties, "rounded")
    end
  end

  describe "execute/2" do
    test "generates basic mix command for component" do
      frame = %Frame{}
      params = %{name: "button"}

      {:reply, response, _frame} = GenerateComponent.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert String.contains?(text, "mix mishka.ui.gen.component button")
    end

    test "includes color option when specified" do
      frame = %Frame{}
      params = %{name: "alert", color: "info,danger"}

      {:reply, response, _frame} = GenerateComponent.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert String.contains?(text, "--color")
      assert String.contains?(text, "info,danger")
    end

    test "includes variant option when specified" do
      frame = %Frame{}
      params = %{name: "button", variant: "outline"}

      {:reply, response, _frame} = GenerateComponent.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert String.contains?(text, "--variant outline")
    end

    test "includes size option when specified" do
      frame = %Frame{}
      params = %{name: "button", size: "large"}

      {:reply, response, _frame} = GenerateComponent.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert String.contains?(text, "--size large")
    end

    test "includes multiple options when specified" do
      frame = %Frame{}

      params = %{
        name: "card",
        color: "primary",
        variant: "shadow",
        size: "medium",
        rounded: "large"
      }

      {:reply, response, _frame} = GenerateComponent.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert String.contains?(text, "mix mishka.ui.gen.component card")
      assert String.contains?(text, "--color")
      assert String.contains?(text, "--variant shadow")
      assert String.contains?(text, "--size medium")
      assert String.contains?(text, "--rounded large")
    end

    test "includes import instructions in response" do
      frame = %Frame{}
      params = %{name: "modal"}

      {:reply, response, _frame} = GenerateComponent.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert String.contains?(text, "use MishkaChelekom")
      assert String.contains?(text, "Modal")
    end
  end
end
