defmodule MishkaChelekom.MCP.Tools.UpdateConfigTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Tools.UpdateConfig
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "input_schema/0 returns a valid JSON schema" do
      schema = UpdateConfig.input_schema()

      assert schema["type"] == "object"
      assert is_map(schema["properties"])
      assert "setting" in schema["required"]
    end
  end

  describe "execute/2 - list settings" do
    test "generates config for component_colors" do
      frame = %Frame{}
      params = %{setting: "component_colors", values: "primary,danger,success"}

      {:reply, response, _frame} = UpdateConfig.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "component_colors"
      assert text =~ ~s(["primary", "danger", "success"])
    end

    test "generates config for exclude_components" do
      frame = %Frame{}
      params = %{setting: "exclude_components", values: "carousel,gallery"}

      {:reply, response, _frame} = UpdateConfig.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "exclude_components"
      assert text =~ "carousel"
      assert text =~ "gallery"
    end
  end

  describe "execute/2 - string settings" do
    test "generates config for component_prefix" do
      frame = %Frame{}
      params = %{setting: "component_prefix", values: "mishka_"}

      {:reply, response, _frame} = UpdateConfig.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "component_prefix"
      assert text =~ ~s("mishka_")
      assert text =~ "mishka_button"
    end

    test "generates config for module_prefix" do
      frame = %Frame{}
      params = %{setting: "module_prefix", values: "mishka_"}

      {:reply, response, _frame} = UpdateConfig.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "module_prefix"
      assert text =~ "MishkaButton"
    end
  end

  describe "execute/2 - CSS override" do
    test "generates CSS override config" do
      frame = %Frame{}
      params = %{setting: "css_override", variable: "primary_light", value: "#2563eb"}

      {:reply, response, _frame} = UpdateConfig.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "css_overrides"
      assert text =~ "primary_light"
      assert text =~ "#2563eb"
      assert text =~ "--primary-light"
    end

    test "shows help when variable not provided" do
      frame = %Frame{}
      params = %{setting: "css_override"}

      {:reply, response, _frame} = UpdateConfig.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "provide both"
      assert text =~ "variable"
      assert text =~ "value"
    end
  end

  describe "execute/2 - invalid settings" do
    test "shows error for invalid setting" do
      frame = %Frame{}
      params = %{setting: "invalid_setting"}

      {:reply, response, _frame} = UpdateConfig.execute(params, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "Invalid Setting"
      assert text =~ "Valid Settings"
    end
  end
end
