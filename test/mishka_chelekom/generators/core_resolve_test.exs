defmodule MishkaChelekom.Generators.CoreResolveTest do
  # Exercises the batch/fan-out helpers that the plural generators
  # (`mishka.ui.gen.components` / `mishka.ui.gen.headless.components`) rely on.
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias MishkaChelekom.Generators.Core
  @moduletag :igniter

  setup do
    {:ok, igniter: test_project_with_formatter()}
  end

  describe "all_component_names/2" do
    test "returns the real, sorted, unique styled component set", %{igniter: igniter} do
      names = Core.all_component_names(igniter, :styled)

      assert names != []
      assert names == Enum.sort(names)
      assert names == Enum.uniq(names)
      # a few components everyone knows must be present
      assert "button" in names
      assert "card" in names
      assert "accordion" in names
    end

    test "the headless set matches the files on disk", %{igniter: igniter} do
      names = Core.all_component_names(igniter, :headless)

      on_disk =
        Core.template_dir(:headless)
        |> Path.join("*.eex")
        |> Path.wildcard()
        |> Enum.map(&Path.basename(&1, ".eex"))
        |> Enum.sort()

      assert names == on_disk
    end
  end

  describe "resolve_components/5" do
    test "an empty request expands to every styled component", %{igniter: igniter} do
      assert Core.resolve_components(igniter, nil, :styled, %{}, nil) ==
               Core.all_component_names(igniter, :styled)

      assert Core.resolve_components(igniter, "", :styled, %{}, nil) ==
               Core.all_component_names(igniter, :styled)
    end

    test "\"all\" also expands to every component", %{igniter: igniter} do
      assert Core.resolve_components(igniter, "all", :styled, %{}, nil) ==
               Core.all_component_names(igniter, :styled)
    end

    test "an explicit list is used verbatim", %{igniter: igniter} do
      assert Core.resolve_components(igniter, "button,alert,card", :styled, %{}, nil) ==
               ["button", "alert", "card"]
    end

    test "CLI --exclude removes names from a full expansion", %{igniter: igniter} do
      all = Core.all_component_names(igniter, :styled)
      resolved = Core.resolve_components(igniter, nil, :styled, %{}, ["button"])

      refute "button" in resolved
      assert length(resolved) == length(all) - 1
    end

    test "config :exclude_components is honored too", %{igniter: igniter} do
      resolved =
        Core.resolve_components(igniter, "all", :styled, %{exclude_components: ["alert"]}, nil)

      refute "alert" in resolved
    end

    test "config and CLI exclusions are merged", %{igniter: igniter} do
      resolved =
        Core.resolve_components(igniter, "all", :styled, %{exclude_components: ["button"]}, [
          "alert"
        ])

      refute "button" in resolved
      refute "alert" in resolved
    end
  end

  describe "append_arg/3" do
    test "appends flag/value pairs only when a value is present" do
      assert Core.append_arg(["mix"], "--module-prefix", "Mishka") ==
               ["mix", "--module-prefix", "Mishka"]

      assert Core.append_arg(["mix"], "--module-prefix", nil) == ["mix"]
      assert Core.append_arg(["mix"], "--module-prefix", "") == ["mix"]
    end
  end

  describe "fetch_catalog/3" do
    test "resolves a real styled component's template and validated catalog", %{igniter: igniter} do
      assert {:ok, %{component: "button", path: path, config: config}} =
               Core.fetch_catalog(igniter, "button", :styled)

      assert String.ends_with?(path, "components/button.eex")
      assert File.exists?(path)
      # the sibling .exs catalog was read and validated
      assert config[:name] == "button"
      assert Keyword.keyword?(config[:args])
    end

    test "resolves a real headless component", %{igniter: igniter} do
      assert {:ok, %{component: "accordion", path: path}} =
               Core.fetch_catalog(igniter, "accordion", :headless)

      assert String.ends_with?(path, "headless/accordion.eex")
    end

    test "normalizes the requested name (casing) before lookup", %{igniter: igniter} do
      # fetch_catalog runs Macro.underscore, so "Button" resolves to the same catalog
      assert {:ok, %{component: "button"}} = Core.fetch_catalog(igniter, "Button", :styled)
    end

    test "returns a structured not_found for an unknown component", %{igniter: igniter} do
      assert {:error, {:not_found, path}} =
               Core.fetch_catalog(igniter, "definitely_not_real", :styled)

      assert String.ends_with?(path, "definitely_not_real.eex")
    end
  end

  describe "validate_catalog/1" do
    test "accepts a well-formed catalog (args optional)" do
      assert {:ok, _} = Core.validate_catalog(name: "button", args: [color: ["primary"]])
      assert {:ok, _} = Core.validate_catalog(name: "x")
    end

    test "rejects input that is not a keyword list" do
      assert {:error, msg} = Core.validate_catalog(%{name: "x"})
      assert msg =~ "keyword list"
      assert {:error, _} = Core.validate_catalog("nope")
    end

    test "requires a string :name" do
      assert {:error, msg} = Core.validate_catalog(args: [])
      assert msg =~ "name"
    end

    test "rejects a non-keyword :args" do
      assert {:error, msg} = Core.validate_catalog(name: "x", args: ["not", "keyword"])
      assert msg =~ ":args"
    end
  end
end
