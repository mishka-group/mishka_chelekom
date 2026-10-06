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

    test "an override that is not a CSS value stops the generation and names it" do
      for value <- ["", "red; } body { color: blue"] do
        igniter =
          project_with_config("""
          import Config

          config :mishka_chelekom,
            css_overrides: %{primary_light: #{inspect(value)}}
          """)

        assert_raise ArgumentError, ~r/css_overrides: primary_light: .* --primary-light/, fn ->
          Config.generate_css_content(igniter)
        end
      end
    end
  end

  describe "default_variables/0" do
    test "is every :root variable of the stylesheet, at its default, in its order" do
      variables = Config.default_variables()

      css =
        File.read!(Path.join(:code.priv_dir(:mishka_chelekom), "assets/css/mishka_chelekom.css"))

      assert {:ok, ^variables} = IgniterCss.get_rule_declarations(css, ":root")
      assert {"--primary-light", "#007f8c"} in variables
      assert {"--opacity-base", "10"} in variables
      assert Enum.all?(variables, fn {name, _} -> String.starts_with?(name, "--") end)
    end

    test "the sample config lists every one of them, commented out at its default" do
      {_igniter, _path, sample} = Config.create_sample_config(test_project_with_formatter())
      sample = String.downcase(sample)

      for {"--" <> name, default} <- Config.default_variables() do
        line = String.downcase(~s|# #{String.replace(name, "-", "_")}: "#{default}"|)
        assert sample =~ line, "the sample config does not list #{line}"
      end
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
