defmodule MishkaChelekom.MCP.ComponentConfigKnownNamesTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.ComponentConfig

  describe "known_component?/1" do
    test "accepts a component the kit ships" do
      assert ComponentConfig.known_component?("button")
      assert "button" in ComponentConfig.component_names()
    end

    test "refuses a name that walks out of priv/components, though it points at a real config" do
      name = "../components/button"
      assert File.exists?(Path.join(ComponentConfig.components_path(), name <> ".exs"))

      refute ComponentConfig.known_component?(name)
      refute ComponentConfig.known_component?("../../mix")
      refute ComponentConfig.known_component?(:button)
    end
  end

  describe "known_js_hook?/1" do
    test "accepts a hook the kit ships and refuses one reached through ../" do
      assert ComponentConfig.known_js_hook?("clipboard")
      refute ComponentConfig.known_js_hook?("../js/clipboard")
      refute ComponentConfig.known_js_hook?(nil)
    end
  end

  describe "get_component/1" do
    test "finds a shipped component by its name" do
      assert Keyword.get(ComponentConfig.get_component("button"), :name) == "button"
    end

    test "returns nil for a ../ name and makes no atom of an unknown one" do
      assert ComponentConfig.get_component("../components/button") == nil

      name = "no_such_component_#{System.unique_integer([:positive])}"
      assert ComponentConfig.get_component(name) == nil
      assert_raise ArgumentError, fn -> String.to_existing_atom(name) end
    end
  end
end
