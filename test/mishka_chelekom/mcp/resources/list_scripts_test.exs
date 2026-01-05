defmodule MishkaChelekom.MCP.Resources.ListScriptsTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Resources.ListScripts
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "name/0 returns the resource name" do
      assert ListScripts.name() == "list_scripts"
    end

    test "uri/0 returns the resource URI" do
      assert ListScripts.uri() == "mishka_chelekom://scripts"
    end

    test "mime_type/0 returns application/json" do
      assert ListScripts.mime_type() == "application/json"
    end
  end

  describe "read/2" do
    test "returns script information" do
      frame = %Frame{}

      {:reply, response, _frame} = ListScripts.read(%{}, frame)

      assert response.contents != nil

      data = Jason.decode!(response.contents["text"])

      assert is_integer(data["total_scripts"])
      assert is_integer(data["total_components_with_js"])
      assert is_list(data["unique_scripts"])
      assert is_map(data["by_component"])
      assert is_list(data["components_requiring_js"])
    end

    test "unique_scripts include required fields" do
      frame = %Frame{}

      {:reply, response, _frame} = ListScripts.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      if length(data["unique_scripts"]) > 0 do
        [script | _] = data["unique_scripts"]

        assert Map.has_key?(script, "file")
        assert Map.has_key?(script, "module")
        assert Map.has_key?(script, "imports")
        assert Map.has_key?(script, "type")
      end
    end

    test "by_component maps component names to scripts" do
      frame = %Frame{}

      {:reply, response, _frame} = ListScripts.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      # If there are components with JS, verify structure
      if map_size(data["by_component"]) > 0 do
        {_component, scripts} = Enum.at(data["by_component"], 0)
        assert is_list(scripts)
      end
    end

    test "includes description and note" do
      frame = %Frame{}

      {:reply, response, _frame} = ListScripts.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert data["description"] != nil
      assert data["note"] != nil
    end
  end
end
