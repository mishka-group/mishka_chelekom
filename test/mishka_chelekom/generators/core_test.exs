defmodule MishkaChelekom.Generators.CoreTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias MishkaChelekom.Generators.Core
  @moduletag :igniter

  describe "eex_assigns/4" do
    test "nil-fills declared catalog args and merges module/web_module/prefixes" do
      igniter = test_project_with_formatter()
      config = [name: "button", args: [color: ["primary"], size: ["sm"]]]

      assigns =
        Core.eex_assigns(igniter, :"TestProjectWeb.Components.Button", config,
          values: [color: ["primary"]],
          component_prefix: "mc_",
          module_prefix: "mishka_"
        )

      assert assigns[:module] == :"TestProjectWeb.Components.Button"
      assert assigns[:color] == ["primary"]
      assert assigns[:size] == nil
      assert assigns[:component_prefix] == "mc_"
      assert assigns[:module_prefix_camel] == "Mishka"
      assert assigns[:web_module] == Igniter.Libs.Phoenix.web_module(igniter)
    end

    test "empty-list values become nil and prefixes default" do
      igniter = test_project_with_formatter()
      config = [name: "x", args: [color: ["primary"]]]

      assigns = Core.eex_assigns(igniter, :X, config, values: [color: []])

      assert assigns[:color] == nil
      assert assigns[:component_prefix] == nil
      assert assigns[:module_prefix_camel] == ""
    end

    test "works for a catalog without :args" do
      igniter = test_project_with_formatter()
      assigns = Core.eex_assigns(igniter, :X, [name: "x"], [])

      assert assigns[:module] == :X
      assert Keyword.has_key?(assigns, :web_module)
    end
  end

  describe "resolve_components/5" do
    test "uses the requested list and removes CLI + config excludes" do
      igniter = test_project_with_formatter()

      list =
        Core.resolve_components(
          igniter,
          "alert,button,badge",
          :styled,
          %{exclude_components: ["badge"]},
          ["alert"]
        )

      assert list == ["button"]
    end

    test "drops blank entries from the requested list" do
      igniter = test_project_with_formatter()
      assert Core.resolve_components(igniter, "alert,,button", :styled, %{}, nil) == ["alert", "button"]
    end
  end

  describe "append_arg/3" do
    test "appends only when the value is present" do
      assert Core.append_arg([], "--x", nil) == []
      assert Core.append_arg([], "--x", "") == []
      assert Core.append_arg(["a"], "--x", "v") == ["a", "--x", "v"]
    end
  end

  describe "fetch_catalog/3" do
    test "returns a not_found error for an unknown component" do
      igniter = test_project_with_formatter()
      assert {:error, {:not_found, path}} = Core.fetch_catalog(igniter, "nope_nope", :styled)
      assert String.ends_with?(path, "nope_nope.eex")
    end

    test "routes headless names to priv/headless" do
      igniter = test_project_with_formatter()
      assert {:error, {:not_found, path}} = Core.fetch_catalog(igniter, "nope_nope", :headless)
      assert String.ends_with?(path, Path.join("headless", "nope_nope.eex"))
    end
  end
end
