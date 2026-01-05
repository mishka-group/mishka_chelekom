defmodule MishkaChelekom.MCP.Resources.GetConfigTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Resources.GetConfig
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "name/0 returns the resource name" do
      assert GetConfig.name() == "get_config"
    end

    test "uri/0 returns the resource URI" do
      assert GetConfig.uri() == "mishka_chelekom://config"
    end

    test "mime_type/0 returns text/plain" do
      assert GetConfig.mime_type() == "text/plain"
    end
  end

  describe "read/2" do
    test "returns config info when no config file exists" do
      frame = %Frame{}

      {:reply, response, _frame} = GetConfig.read(%{}, frame)

      assert response.contents != nil
      text = response.contents["text"]

      # Should indicate no config found
      assert text =~ "No configuration file found"
      assert text =~ "mix mishka.ui.css.config --init"
    end

    test "includes default settings when no config exists" do
      frame = %Frame{}

      {:reply, response, _frame} = GetConfig.read(%{}, frame)

      text = response.contents["text"]

      # Should show default settings
      assert text =~ "Default Settings"
      assert text =~ "Excluded Components"
    end

    test "includes instructions to create config" do
      frame = %Frame{}

      {:reply, response, _frame} = GetConfig.read(%{}, frame)

      text = response.contents["text"]

      # Should show how to create config
      assert text =~ "Create Config File"
      assert text =~ "--global"
    end
  end
end
