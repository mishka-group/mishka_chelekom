defmodule MishkaChelekom.MCP.Resources.ListSpacesTest do
  use ExUnit.Case, async: true

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

      assert response.contents != nil

      data = Jason.decode!(response.contents["text"])

      assert is_list(data["spaces"])
      assert is_list(data["details"])
    end

    test "spaces include expected options" do
      frame = %Frame{}

      {:reply, response, _frame} = ListSpaces.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      spaces = data["spaces"]

      assert "small" in spaces or "medium" in spaces or "large" in spaces
    end

    test "details include required fields" do
      frame = %Frame{}

      {:reply, response, _frame} = ListSpaces.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      if length(data["details"]) > 0 do
        [detail | _] = data["details"]

        assert Map.has_key?(detail, "name")
        assert Map.has_key?(detail, "description")
        assert Map.has_key?(detail, "usage")
      end
    end

    test "includes usage example" do
      frame = %Frame{}

      {:reply, response, _frame} = ListSpaces.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert data["usage_example"] != nil
      assert String.contains?(data["usage_example"], "--space")
    end
  end
end
