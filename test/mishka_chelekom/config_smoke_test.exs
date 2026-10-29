defmodule MishkaChelekom.ConfigSmokeTest do
  use ExUnit.Case
  alias MishkaChelekom.Config
  import MishkaChelekom.ComponentTestHelper
  @moduletag :igniter

  describe "Config.create_sample_config/1" do
    setup do
      igniter = test_project_with_formatter()
      {_igniter, path, content} = Config.create_sample_config(igniter)

      %{path: path, content: content}
    end

    test "creates the sample config under priv/mishka_chelekom", %{path: path} do
      assert path == "priv/mishka_chelekom/config.exs"
    end

    test "creates sample config with proper structure", %{content: content} do
      assert content =~ "# Mishka Chelekom CSS Configuration"
      assert content =~ "import Config"
      assert content =~ "config :mishka_chelekom,"
      assert content =~ "css_overrides:"
    end

    test "has all the major sections", %{content: content} do
      assert content =~ "# === Base Colors ==="
      assert content =~ "# === Primary Theme ==="
      assert content =~ "# === Secondary Theme ==="
      assert content =~ "# === Success Theme ==="
      assert content =~ "# === Warning Theme ==="
      assert content =~ "# === Danger Theme ==="
      assert content =~ "# === Info Theme ==="
      assert content =~ "# === Misc Theme ==="
      assert content =~ "# === Dawn Theme ==="
      assert content =~ "# === Silver Theme ==="
      assert content =~ "# === Shadows ==="
      assert content =~ "# === Gradients ==="
      assert content =~ "# === Form Elements ==="
      assert content =~ "# === Checkbox Colors ==="
    end

    test "lists the key variables, commented out", %{content: content} do
      assert content =~ "# primary_light:"
      assert content =~ "# secondary_light:"
      assert content =~ "# success_light:"
      assert content =~ "# danger_light:"
      assert content =~ "# base_border_light:"
      assert content =~ "# checkbox_primary_checked:"
    end

    test "sets the merge strategy options", %{content: content} do
      assert content =~ "css_merge_strategy: :merge"
      assert content =~ "custom_css_path: nil"
    end

    test "sample config is valid Elixir syntax", %{content: content} do
      # Create a temporary file to test syntax
      temp_path = System.tmp_dir!() |> Path.join("test_config_#{:rand.uniform(999_999)}.exs")

      try do
        File.write!(temp_path, content)
        # This will raise if there's a syntax error
        config = Elixir.Config.Reader.read!(temp_path)

        assert config[:mishka_chelekom][:css_overrides] == %{}
        assert config[:mishka_chelekom][:css_merge_strategy] == :merge
      after
        File.rm(temp_path)
      end
    end
  end

  describe "Config basic functionality" do
    test "load_user_config returns defaults when no config exists" do
      igniter = test_project_with_formatter()
      config = Config.load_user_config(igniter)

      assert config.css_overrides == %{}
      assert config.custom_css_path == nil
      assert config.css_merge_strategy == :merge
    end
  end
end
