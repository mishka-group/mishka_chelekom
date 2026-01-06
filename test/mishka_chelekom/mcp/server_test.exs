defmodule MishkaChelekom.MCP.ServerTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Server

  describe "server configuration" do
    test "server_info/0 returns correct name and version" do
      info = Server.server_info()

      assert info["name"] == "Mishka Chelekom"
      assert info["version"] == "0.0.9"
    end

    test "server_capabilities/0 includes tools and resources" do
      capabilities = Server.server_capabilities()

      assert Map.has_key?(capabilities, "tools")
      assert Map.has_key?(capabilities, "resources")
    end

    test "__components__/0 returns all registered components" do
      components = Server.__components__()

      # Should have 9 resources and 11 tools = 20 total
      assert length(components) == 20
    end

    test "__components__(:tool) returns only tools" do
      tools = Server.__components__(:tool)

      assert length(tools) == 11

      tool_names =
        tools
        |> Enum.map(& &1.name)
        |> Enum.sort()

      assert tool_names == [
               "generate_component",
               "generate_components",
               "get_component_info",
               "get_docs",
               "get_example",
               "get_js_hook_info",
               "get_mix_task_info",
               "search_components",
               "uninstall_component",
               "update_config",
               "validate_config"
             ]
    end

    test "__components__(:resource) returns only resources" do
      resources = Server.__components__(:resource)

      assert length(resources) == 9

      resource_names =
        resources
        |> Enum.map(& &1.name)
        |> Enum.sort()

      assert resource_names == [
               "get_config",
               "list_colors",
               "list_components",
               "list_css_variables",
               "list_dependencies",
               "list_scripts",
               "list_sizes",
               "list_spaces",
               "list_variants"
             ]
    end
  end
end
