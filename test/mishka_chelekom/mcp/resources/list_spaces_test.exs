defmodule MishkaChelekom.MCP.Resources.ListSpacesTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.ComponentConfig
  alias MishkaChelekom.MCP.Resources.ListSpaces
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "name/0 returns the resource name" do
      assert ListSpaces.name() == "list_spaces"
    end

    test "uri/0 returns the resource URI" do
      assert ListSpaces.uri() == "mishka_chelekom://spaces"
    end

    test "mime_type/0 returns application/json" do
      assert ListSpaces.mime_type() == "application/json"
    end
  end

  describe "read/2" do
    test "returns a list of spaces" do
      frame = %Frame{}

      {:reply, response, _frame} = ListSpaces.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert data["spaces"] == ComponentConfig.list_spaces()
      assert [detail | _] = data["details"]
      assert detail["name"] == hd(data["spaces"])
    end

    test "spaces include expected options" do
      frame = %Frame{}

      {:reply, response, _frame} = ListSpaces.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      spaces = data["spaces"]

      assert "small" in spaces
      assert "medium" in spaces
      assert "large" in spaces
    end

    test "details include required fields" do
      frame = %Frame{}

      {:reply, response, _frame} = ListSpaces.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert [detail | _] = data["details"]

      assert Map.has_key?(detail, "name")
      assert Map.has_key?(detail, "description")
      assert Map.has_key?(detail, "usage")
    end

    test "includes usage example" do
      frame = %Frame{}

      {:reply, response, _frame} = ListSpaces.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert data["usage_example"] == "mix mishka.ui.gen.component accordion --space medium"
    end
  end
end
