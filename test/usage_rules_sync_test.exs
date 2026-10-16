defmodule MishkaChelekom.UsageRulesSyncTest do
  @moduledoc """
  Real-world integration test that runs `mix usage_rules.sync` (usage_rules 1.2) and verifies the
  generated file contains the mishka_chelekom rules.

  This creates a temporary project whose `mix.exs` carries the `usage_rules:` configuration,
  adds mishka_chelekom as a path dependency, and runs the actual sync command.
  """
  use ExUnit.Case

  @moduletag :sync_integration
  @moduletag timeout: :timer.minutes(10)
  @project_root File.cwd!()

  @components ~w(accordion alert avatar badge banner blockquote breadcrumb button card carousel
    chat checkbox_card checkbox_field clipboard collapse color_field combobox date_time_field
    device_mockup divider drawer dropdown email_field fieldset file_field footer form_wrapper
    gallery image indicator input_field jumbotron keyboard layout list mega_menu menu modal
    native_select navbar number_field overlay pagination password_field popover progress
    radio_card radio_field range_field rating scroll_area search_field sidebar skeleton
    speed_dial spinner stepper table table_content tabs tel_field text_field textarea_field
    timeline toast toggle_field tooltip typography url_field video)

  defp mix_exs(usage_rules) do
    """
    defmodule TestProject.MixProject do
      use Mix.Project

      def project do
        [
          app: :test_project,
          version: "0.1.0",
          elixir: "~> 1.14",
          deps: deps(),
          usage_rules: #{usage_rules}
        ]
      end

      defp deps do
        [
          {:mishka_chelekom, path: "#{@project_root}"},
          {:usage_rules, "~> 1.2", only: :dev}
        ]
      end
    end
    """
  end

  defp mix(tmp_dir, args) do
    System.cmd("mix", args, cd: tmp_dir, stderr_to_stdout: true, env: [{"MIX_ENV", "dev"}])
  end

  defp sync!(tmp_dir, usage_rules) do
    File.write!(Path.join(tmp_dir, "mix.exs"), mix_exs(usage_rules))

    {output, exit_code} = mix(tmp_dir, ["deps.get"])
    assert exit_code == 0, "mix deps.get should succeed: #{output}"

    {output, exit_code} = mix(tmp_dir, ["usage_rules.sync", "--yes"])
    assert exit_code == 0, "mix usage_rules.sync should succeed: #{output}"

    File.read!(Path.join(tmp_dir, "CLAUDE.md"))
  end

  setup do
    tmp_dir = Path.join(System.tmp_dir!(), "usage_rules_sync_test_#{:rand.uniform(100_000)}")
    File.mkdir_p!(Path.join(tmp_dir, "lib"))
    File.mkdir_p!(Path.join(tmp_dir, "config"))

    File.write!(Path.join(tmp_dir, ".formatter.exs"), """
    [inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]]
    """)

    File.write!(Path.join(tmp_dir, "lib/test_project.ex"), "defmodule TestProject do\nend\n")
    File.write!(Path.join(tmp_dir, "config/config.exs"), "import Config\n")

    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    {:ok, tmp_dir: tmp_dir}
  end

  describe "mix usage_rules.sync" do
    test "usage_rules: [:mishka_chelekom] writes the main rules and the top-level sub-rules", %{
      tmp_dir: tmp_dir
    } do
      content = sync!(tmp_dir, ~s|[file: "CLAUDE.md", usage_rules: [:mishka_chelekom]]|)

      assert content =~ "<!-- mishka_chelekom-start -->"
      assert content =~ "<!-- mishka_chelekom:mix-tasks-start -->"
      refute content =~ "<!-- mishka_chelekom:components/button-start -->"

      assert String.length(content) > 5000

      for text <- ["Mishka Chelekom", "Phoenix", "LiveView", "mix mishka.ui.gen.component"] do
        assert content =~ text, "CLAUDE.md should contain #{text}"
      end

      missing = Enum.reject(@components, &(content =~ &1))
      assert length(@components) - length(missing) >= 50, "missing: #{inspect(missing)}"

      for hook <- ~w(Carousel Clipboard Collapsible Combobox Floating ScrollArea Sidebar) do
        assert content =~ hook, "CLAUDE.md should mention the #{hook} hook"
      end

      assert content =~ "mishka.tools"
    end

    test "sub_rules names the nested files of one component", %{tmp_dir: tmp_dir} do
      content =
        sync!(tmp_dir, """
        [
          file: "CLAUDE.md",
          usage_rules: [{:mishka_chelekom, sub_rules: ["components/button", "docs/kit"]}]
        ]
        """)

      assert content =~ "<!-- mishka_chelekom-start -->"
      assert content =~ "<!-- mishka_chelekom:components/button-start -->"
      assert content =~ "<!-- mishka_chelekom:docs/kit-start -->"
      refute content =~ "<!-- mishka_chelekom:components/modal-start -->"
      refute content =~ "<!-- mishka_chelekom:mix-tasks-start -->"
    end
  end
end
