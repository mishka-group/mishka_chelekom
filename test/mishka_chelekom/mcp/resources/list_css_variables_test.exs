defmodule MishkaChelekom.MCP.Resources.ListCssVariablesTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Resources.ListCssVariables
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "name/0 returns the resource name" do
      assert ListCssVariables.name() == "list_css_variables"
    end

    test "uri/0 returns the resource URI" do
      assert ListCssVariables.uri() == "mishka_chelekom://css-variables"
    end

    test "mime_type/0 returns text/plain" do
      assert ListCssVariables.mime_type() == "text/plain"
    end
  end

  describe "read/2" do
    test "returns CSS variables documentation" do
      frame = %Frame{}

      {:reply, response, _frame} = ListCssVariables.read(%{}, frame)

      assert response.contents != nil
      text = response.contents["text"]

      assert text =~ "Mishka Chelekom CSS Variables"
      assert text =~ "css_overrides"
    end

    test "includes primary theme variables" do
      frame = %Frame{}

      {:reply, response, _frame} = ListCssVariables.read(%{}, frame)

      text = response.contents["text"]

      assert text =~ "Primary Theme"
      assert text =~ "primary_light"
      assert text =~ "primary_dark"
    end

    test "includes how to override section" do
      frame = %Frame{}

      {:reply, response, _frame} = ListCssVariables.read(%{}, frame)

      text = response.contents["text"]

      assert text =~ "How to Override"
      assert text =~ "config :mishka_chelekom"
    end

    test "includes regenerate command" do
      frame = %Frame{}

      {:reply, response, _frame} = ListCssVariables.read(%{}, frame)

      text = response.contents["text"]

      assert text =~ "mix mishka.ui.css.config --regenerate"
    end
  end
end
