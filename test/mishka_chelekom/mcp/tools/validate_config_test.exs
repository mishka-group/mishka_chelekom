defmodule MishkaChelekom.MCP.Tools.ValidateConfigTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Tools.ValidateConfig
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "input_schema/0 returns a valid JSON schema" do
      schema = ValidateConfig.input_schema()

      assert schema["type"] == "object"
      assert is_map(schema["properties"])
    end
  end

  describe "execute/2" do
    test "returns no config message when config doesn't exist" do
      frame = %Frame{}

      {:reply, response, _frame} = ValidateConfig.execute(%{}, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "No Configuration File"
      assert text =~ "mix mishka.ui.css.config --init"
    end

    test "includes instructions to create config" do
      frame = %Frame{}

      {:reply, response, _frame} = ValidateConfig.execute(%{}, frame)

      [content | _] = response.content
      text = content["text"]

      assert text =~ "Create Config File"
    end
  end
end
