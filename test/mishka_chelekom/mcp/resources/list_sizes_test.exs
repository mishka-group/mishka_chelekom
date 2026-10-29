defmodule MishkaChelekom.MCP.Resources.ListSizesTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.ComponentConfig
  alias MishkaChelekom.MCP.Resources.ListSizes
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "name/0 returns the resource name" do
      assert ListSizes.name() == "list_sizes"
    end

    test "uri/0 returns the resource URI" do
      assert ListSizes.uri() == "mishka_chelekom://sizes"
    end

    test "mime_type/0 returns application/json" do
      assert ListSizes.mime_type() == "application/json"
    end
  end

  describe "read/2" do
    test "returns a list of sizes" do
      frame = %Frame{}

      {:reply, response, _frame} = ListSizes.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert data["sizes"] != []
      assert data["sizes"] == ComponentConfig.list_sizes()
    end

    test "includes standard size scale" do
      frame = %Frame{}

      {:reply, response, _frame} = ListSizes.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      sizes = data["sizes"]

      assert "extra_small" in sizes
      assert "small" in sizes
      assert "medium" in sizes
      assert "large" in sizes
      assert "extra_large" in sizes
    end

    test "includes size details with descriptions and aliases" do
      frame = %Frame{}

      {:reply, response, _frame} = ListSizes.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert [detail | _] = data["details"]

      assert detail["name"] == hd(data["sizes"])
      assert Map.has_key?(detail, "description")
      assert Map.has_key?(detail, "usage")
    end

    test "includes related options info" do
      frame = %Frame{}

      {:reply, response, _frame} = ListSizes.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert data["related_options"] == %{
               "padding" => ComponentConfig.list_padding(),
               "rounded" => ComponentConfig.list_rounded()
             }
    end
  end
end
