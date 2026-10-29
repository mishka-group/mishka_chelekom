defmodule MishkaChelekom.MCP.Resources.ListScriptsTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.ComponentConfig
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

      data = Jason.decode!(response.contents["text"])
      unique_scripts = ComponentConfig.list_unique_scripts()
      scripts_by_component = ComponentConfig.list_scripts()

      assert data["total_scripts"] == length(unique_scripts)
      assert data["total_scripts"] > 0
      assert data["total_components_with_js"] == map_size(scripts_by_component)
      assert length(data["unique_scripts"]) == length(unique_scripts)

      assert Enum.sort(Map.keys(data["by_component"])) ==
               Enum.sort(Map.keys(scripts_by_component))

      assert Enum.sort(data["components_requiring_js"]) ==
               Enum.sort(Map.keys(scripts_by_component))
    end

    test "unique_scripts include required fields" do
      frame = %Frame{}

      {:reply, response, _frame} = ListScripts.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      [expected | _] = ComponentConfig.list_unique_scripts()

      assert [script | _] = data["unique_scripts"]

      assert script == %{
               "file" => expected.file,
               "module" => expected.module,
               "imports" => expected.imports,
               "type" => expected.type
             }
    end

    test "by_component maps component names to scripts" do
      frame = %Frame{}

      {:reply, response, _frame} = ListScripts.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert [script] = data["by_component"]["carousel"]
      assert script["module"] == "Carousel"
      assert script["file"] == "carousel.js"
    end

    test "includes description and note" do
      frame = %Frame{}

      {:reply, response, _frame} = ListScripts.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert data["description"] ==
               "JavaScript files required by components for interactive behavior"

      assert data["note"] =~ "automatically copied to your project"
    end
  end
end
