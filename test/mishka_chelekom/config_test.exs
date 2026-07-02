defmodule MishkaChelekom.ConfigTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias MishkaChelekom.Config
  @moduletag :igniter

  @config_path "priv/mishka_chelekom/config.exs"

  defp source_content(igniter, path) do
    Rewrite.Source.get(igniter.rewrite.sources[path], :content)
  end

  defp project_with_config(config_body) do
    test_project_with_formatter(files: %{@config_path => config_body})
  end

  describe "generate_css_content/1 (merge strategy)" do
    test "returns the default CSS untouched when there are no overrides" do
      css = Config.generate_css_content(test_project_with_formatter())

      # the real default stylesheet is returned, :root and known variables intact
      assert css =~ ":root"
      assert css =~ "--primary-light"
    end

    test "applies css_overrides onto the real default stylesheet" do
      igniter =
        project_with_config("""
        import Config

        config :mishka_chelekom,
          css_overrides: %{
            primary_light: "#123456",
            danger_dark: "#654321"
          }
        """)

      css = Config.generate_css_content(igniter)

      # each overridden variable ends up with the caller's value in :root
      assert css =~ "--primary-light: #123456;"
      assert css =~ "--danger-dark: #654321;"
    end
  end

  describe "generate_css_content/1 (replace strategy)" do
    test "replaces the whole stylesheet with a custom file when configured" do
      custom_path =
        Path.join(System.tmp_dir!(), "mishka_custom_#{System.unique_integer([:positive])}.css")

      File.write!(custom_path, ":root { --my-brand: #abcabc; }\n")
      on_exit(fn -> File.rm(custom_path) end)

      igniter =
        project_with_config("""
        import Config

        config :mishka_chelekom,
          css_merge_strategy: :replace,
          custom_css_path: "#{custom_path}"
        """)

      css = Config.generate_css_content(igniter)

      assert css == ":root { --my-brand: #abcabc; }\n"
    end
  end

  describe "update_component_prefix/2" do
    test "creates the config from the sample and fills in the prefix when none exists" do
      igniter = Config.update_component_prefix(test_project_with_formatter(), "mishka_")

      assert source_content(igniter, @config_path) =~ ~s(component_prefix: "mishka_")
    end

    test "rewrites an existing prefix value in place" do
      igniter =
        project_with_config("""
        import Config

        config :mishka_chelekom,
          component_prefix: "old_"
        """)
        |> Config.update_component_prefix("new_")

      content = source_content(igniter, @config_path)
      assert content =~ ~s(component_prefix: "new_")
      refute content =~ ~s(component_prefix: "old_")
    end
  end

  describe "update_module_prefix/2" do
    test "creates the config from the sample and fills in the prefix when none exists" do
      igniter = Config.update_module_prefix(test_project_with_formatter(), "Mishka")

      assert source_content(igniter, @config_path) =~ ~s(module_prefix: "Mishka")
    end

    test "rewrites an existing module prefix value in place" do
      igniter =
        project_with_config("""
        import Config

        config :mishka_chelekom,
          module_prefix: "Old"
        """)
        |> Config.update_module_prefix("New")

      content = source_content(igniter, @config_path)
      assert content =~ ~s(module_prefix: "New")
      refute content =~ ~s(module_prefix: "Old")
    end
  end
end
