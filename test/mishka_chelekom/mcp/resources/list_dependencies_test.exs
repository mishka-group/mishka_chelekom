defmodule MishkaChelekom.MCP.Resources.ListDependenciesTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Resources.ListDependencies
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "name/0 returns the resource name" do
      assert ListDependencies.name() == "list_dependencies"
    end

    test "uri/0 returns the resource URI" do
      assert ListDependencies.uri() == "mishka_chelekom://dependencies"
    end

    test "mime_type/0 returns application/json" do
      assert ListDependencies.mime_type() == "application/json"
    end
  end

  describe "read/2" do
    test "returns dependency information" do
      frame = %Frame{}

      {:reply, response, _frame} = ListDependencies.read(%{}, frame)

      assert response.contents != nil

      data = Jason.decode!(response.contents["text"])

      assert is_integer(data["total_components_with_dependencies"])
      assert is_list(data["all_necessary_dependencies"])
      assert is_list(data["all_optional_dependencies"])
      assert is_map(data["by_component"])
    end

    test "by_component includes necessary and optional fields" do
      frame = %Frame{}

      {:reply, response, _frame} = ListDependencies.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      # If there are components with dependencies, verify structure
      if map_size(data["by_component"]) > 0 do
        {_component, deps} = Enum.at(data["by_component"], 0)
        assert Map.has_key?(deps, "necessary")
        assert Map.has_key?(deps, "optional")
        assert is_list(deps["necessary"])
        assert is_list(deps["optional"])
      end
    end

    test "includes description and notes" do
      frame = %Frame{}

      {:reply, response, _frame} = ListDependencies.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert data["description"] != nil
      assert is_map(data["note"])
      assert data["note"]["necessary"] != nil
      assert data["note"]["optional"] != nil
    end

    test "includes usage example" do
      frame = %Frame{}

      {:reply, response, _frame} = ListDependencies.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert data["usage_example"] != nil
      assert String.contains?(data["usage_example"], "mix mishka.ui.gen.component")
    end
  end
end
