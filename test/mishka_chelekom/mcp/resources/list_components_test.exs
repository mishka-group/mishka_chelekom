defmodule MishkaChelekom.MCP.Resources.ListComponentsTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Resources.ListComponents
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "name/0 returns the resource name" do
      assert ListComponents.name() == "list_components"
    end

    test "uri/0 returns the resource URI" do
      assert ListComponents.uri() == "mishka_chelekom://components"
    end

    test "mime_type/0 returns text/plain" do
      assert ListComponents.mime_type() == "text/plain"
    end
  end

  describe "read/2" do
    test "returns formatted text with components" do
      frame = %Frame{}

      {:reply, response, _frame} = ListComponents.read(%{}, frame)

      assert response.contents != nil
      text = response.contents["text"]

      # Should contain the header
      assert String.contains?(text, "Mishka Chelekom Components")
      assert String.contains?(text, "components")
    end

    test "includes category sections" do
      frame = %Frame{}

      {:reply, response, _frame} = ListComponents.read(%{}, frame)

      text = response.contents["text"]

      # Should contain category headers
      assert String.contains?(text, "General")
      assert String.contains?(text, "Forms")
      assert String.contains?(text, "Navigations")
      assert String.contains?(text, "Feedback")
    end

    test "includes JS and dependency notes" do
      frame = %Frame{}

      {:reply, response, _frame} = ListComponents.read(%{}, frame)

      text = response.contents["text"]

      # Should contain notes about JS and dependencies
      assert String.contains?(text, "Requires JS") or String.contains?(text, "Has dependencies")
    end

    test "includes documentation URL" do
      frame = %Frame{}

      {:reply, response, _frame} = ListComponents.read(%{}, frame)

      text = response.contents["text"]

      assert String.contains?(text, "https://mishka.tools/chelekom/docs")
    end

    test "includes generator command" do
      frame = %Frame{}

      {:reply, response, _frame} = ListComponents.read(%{}, frame)

      text = response.contents["text"]

      assert String.contains?(text, "mix mishka.ui.gen.component")
    end
  end
end
