defmodule MishkaChelekom.MCP.Resources.ListDependenciesTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.ComponentConfig
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

      data = Jason.decode!(response.contents["text"])
      dependencies = ComponentConfig.list_dependencies()

      assert data["total_components_with_dependencies"] == map_size(dependencies)
      assert data["total_components_with_dependencies"] > 0
      assert data["all_necessary_dependencies"] == ComponentConfig.list_necessary_deps()
      assert data["all_optional_dependencies"] == ComponentConfig.list_optional_deps()
      assert Enum.sort(Map.keys(data["by_component"])) == Enum.sort(Map.keys(dependencies))
    end

    test "by_component includes necessary and optional fields" do
      frame = %Frame{}

      {:reply, response, _frame} = ListDependencies.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      # Carousel needs the image and icon components
      assert data["by_component"]["carousel"] == %{
               "necessary" => ["image", "icon"],
               "optional" => []
             }
    end

    test "includes description and notes" do
      frame = %Frame{}

      {:reply, response, _frame} = ListDependencies.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert data["description"] =~ "necessary deps are auto-installed"
      assert data["note"]["necessary"] =~ "automatically installed"
      assert data["note"]["optional"] =~ "optionally added"
    end

    test "includes usage example" do
      frame = %Frame{}

      {:reply, response, _frame} = ListDependencies.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert data["usage_example"] =~ "mix mishka.ui.gen.component modal"
    end
  end
end
