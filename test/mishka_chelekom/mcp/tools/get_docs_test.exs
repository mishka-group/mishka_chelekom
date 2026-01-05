defmodule MishkaChelekom.MCP.Tools.GetDocsTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Tools.GetDocs
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "input_schema/0 returns a valid JSON schema" do
      schema = GetDocs.input_schema()

      assert schema["type"] == "object"
      assert is_map(schema["properties"])
      assert "topic" in schema["required"]
    end
  end

  describe "execute/2 - component topics" do
    test "returns docs link for button component" do
      frame = %Frame{}
      params = %{topic: "button"}

      {:reply, response, _frame} = GetDocs.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "Button Documentation"
      assert text =~ "https://mishka.tools/chelekom/docs/button"
      assert text =~ "mix mishka.ui.gen.component button"
    end

    test "returns docs link for modal component" do
      frame = %Frame{}
      params = %{topic: "modal"}

      {:reply, response, _frame} = GetDocs.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "Modal Documentation"
      assert text =~ "https://mishka.tools/chelekom/docs/modal"
    end

    test "handles form components with correct URL path" do
      frame = %Frame{}
      params = %{topic: "checkbox-field"}

      {:reply, response, _frame} = GetDocs.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "https://mishka.tools/chelekom/docs/forms/checkbox-field"
    end
  end

  describe "execute/2 - CLI topic" do
    test "returns CLI documentation" do
      frame = %Frame{}
      params = %{topic: "cli"}

      {:reply, response, _frame} = GetDocs.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "Cli Documentation"
      assert text =~ "Mix Tasks"
      assert text =~ "mishka.ui.gen.component"
    end
  end

  describe "execute/2 - getting started topic" do
    test "returns getting started documentation" do
      frame = %Frame{}
      params = %{topic: "getting-started"}

      {:reply, response, _frame} = GetDocs.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "Getting Started Documentation"
      assert text =~ "Installation"
      assert text =~ "mix deps.get"
    end
  end

  describe "execute/2 - local docs detection" do
    test "suggests get_example for known components" do
      frame = %Frame{}
      params = %{topic: "alert"}

      {:reply, response, _frame} = GetDocs.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      # Alert has local usage-rules docs
      assert text =~ "get_example" or text =~ "get_component_info"
    end
  end

  describe "execute/2 - topic normalization" do
    test "normalizes underscores to dashes" do
      frame = %Frame{}
      params = %{topic: "checkbox_field"}

      {:reply, response, _frame} = GetDocs.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "Checkbox Field"
    end

    test "handles uppercase input" do
      frame = %Frame{}
      params = %{topic: "BUTTON"}

      {:reply, response, _frame} = GetDocs.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "Button"
    end
  end
end
