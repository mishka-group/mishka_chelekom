defmodule MishkaChelekom.CSSConfigSmokeTest do
  use ExUnit.Case
  alias MishkaChelekom.CSSConfig
  import MishkaChelekom.ComponentTestHelper
  @moduletag :igniter

  describe "CSSConfig.create_sample_config/1" do
    test "creates sample config with proper structure" do
      igniter = test_project_with_formatter()
      {_igniter, path, content} = CSSConfig.create_sample_config(igniter)

      # Verify path
      assert path == "priv/mishka_chelekom/config.exs"

      # Verify content structure
      assert content =~ "# Mishka Chelekom CSS Configuration"
      assert content =~ "import Config"
      assert content =~ "config :mishka_chelekom,"
      assert content =~ "css_overrides:"

      # Verify it has all major sections
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

      # Verify some key variables are present (commented)
      assert content =~ "# primary_light:"
      assert content =~ "# secondary_light:"
      assert content =~ "# success_light:"
      assert content =~ "# danger_light:"
      assert content =~ "# base_border_light:"
      assert content =~ "# checkbox_primary_checked:"

      # Verify merge strategy options
      assert content =~ "css_merge_strategy: :merge"
      assert content =~ "custom_css_path: nil"
    end

    test "sample config is valid Elixir syntax" do
      igniter = test_project_with_formatter()
      {_igniter, _path, content} = CSSConfig.create_sample_config(igniter)

      # Create a temporary file to test syntax
      temp_path = System.tmp_dir!() |> Path.join("test_config_#{:rand.uniform(999_999)}.exs")

      try do
        File.write!(temp_path, content)
        # This will raise if there's a syntax error
        config = Config.Reader.read!(temp_path)
        assert is_list(config)
        assert Keyword.has_key?(config, :mishka_chelekom)
      after
        File.rm(temp_path)
      end
    end
  end

  describe "CSSConfig basic functionality" do
    test "load_user_config returns defaults when no config exists" do
      igniter = test_project_with_formatter()
      config = CSSConfig.load_user_config(igniter)

      assert config.css_overrides == %{}
      assert config.custom_css_path == nil
      assert config.css_merge_strategy == :merge
    end
  end
end
