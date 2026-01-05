defmodule MishkaChelekom.MCP.Resources.ListVariantsTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Resources.ListVariants
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "name/0 returns the resource name" do
      assert ListVariants.name() == "list_variants"
    end

    test "uri/0 returns the resource URI" do
      assert ListVariants.uri() == "mishka_chelekom://variants"
    end

    test "mime_type/0 returns application/json" do
      assert ListVariants.mime_type() == "application/json"
    end
  end

  describe "read/2" do
    test "returns a list of variants" do
      frame = %Frame{}

      {:reply, response, _frame} = ListVariants.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert is_list(data["variants"])
      assert length(data["variants"]) > 0
    end

    test "includes common style variants" do
      frame = %Frame{}

      {:reply, response, _frame} = ListVariants.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      variants = data["variants"]

      assert "default" in variants
      assert "outline" in variants
      assert "shadow" in variants
      assert "bordered" in variants
      assert "gradient" in variants
    end

    test "includes variant details with descriptions" do
      frame = %Frame{}

      {:reply, response, _frame} = ListVariants.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert is_list(data["details"])
      [detail | _] = data["details"]

      assert Map.has_key?(detail, "name")
      assert Map.has_key?(detail, "description")
      assert Map.has_key?(detail, "usage")
    end

    test "includes helpful note about component-specific variants" do
      frame = %Frame{}

      {:reply, response, _frame} = ListVariants.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert is_binary(data["note"])
      assert String.contains?(data["note"], "get_component_info")
    end
  end
end
