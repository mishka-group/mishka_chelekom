defmodule MishkaChelekom.MCP.Resources.ListColorsTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.ComponentConfig
  alias MishkaChelekom.MCP.Resources.ListColors
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "name/0 returns the resource name" do
      assert ListColors.name() == "list_colors"
    end

    test "uri/0 returns the resource URI" do
      assert ListColors.uri() == "mishka_chelekom://colors"
    end

    test "mime_type/0 returns application/json" do
      assert ListColors.mime_type() == "application/json"
    end
  end

  describe "read/2" do
    test "returns a list of colors" do
      frame = %Frame{}

      {:reply, response, _frame} = ListColors.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert data["colors"] != []
      assert data["colors"] == ComponentConfig.list_colors()
    end

    test "includes common color variants" do
      frame = %Frame{}

      {:reply, response, _frame} = ListColors.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      colors = data["colors"]

      assert "primary" in colors
      assert "secondary" in colors
      assert "success" in colors
      assert "warning" in colors
      assert "danger" in colors
      assert "info" in colors
    end

    test "includes color details with descriptions" do
      frame = %Frame{}

      {:reply, response, _frame} = ListColors.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert [detail | _] = data["details"]

      assert detail["name"] == hd(data["colors"])
      assert Map.has_key?(detail, "description")
      assert Map.has_key?(detail, "usage")
    end

    test "includes usage example" do
      frame = %Frame{}

      {:reply, response, _frame} = ListColors.read(%{}, frame)

      data = Jason.decode!(response.contents["text"])

      assert data["usage_example"] ==
               "mix mishka.ui.gen.component alert --color \"info,danger,warning\""
    end
  end
end
