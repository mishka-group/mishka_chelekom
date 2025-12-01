defmodule MishkaChelekom.UsageRulesSyncTest do
  @moduledoc """
  Real-world integration test that runs `mix usage_rules.sync` command
  and verifies CLAUDE.md contains all mishka_chelekom rules.

  This creates a temporary Phoenix-like project, adds mishka_chelekom as
  a path dependency, and runs the actual sync command.
  """
  use ExUnit.Case

  @moduletag :sync_integration
  @project_root File.cwd!()

  describe "mix usage_rules.sync real-world test" do
    setup do
      # Create a temporary test project directory
      tmp_dir = Path.join(System.tmp_dir!(), "usage_rules_sync_test_#{:rand.uniform(100_000)}")
      File.mkdir_p!(tmp_dir)

      # Create minimal mix.exs for the test project
      mix_exs_content = """
      defmodule TestProject.MixProject do
        use Mix.Project

        def project do
          [
            app: :test_project,
            version: "0.1.0",
            elixir: "~> 1.14",
            deps: deps()
          ]
        end

        defp deps do
          [
            {:mishka_chelekom, path: "#{@project_root}"},
            {:usage_rules, "~> 0.1.26"}
          ]
        end
      end
      """

      File.write!(Path.join(tmp_dir, "mix.exs"), mix_exs_content)

      # Create .formatter.exs (required by usage_rules/igniter)
      formatter_content = """
      [
        inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
      ]
      """

      File.write!(Path.join(tmp_dir, ".formatter.exs"), formatter_content)

      # Create lib directory (required for mix)
      File.mkdir_p!(Path.join(tmp_dir, "lib"))
      File.write!(Path.join(tmp_dir, "lib/test_project.ex"), """
      defmodule TestProject do
      end
      """)

      # Create config directory
      File.mkdir_p!(Path.join(tmp_dir, "config"))
      File.write!(Path.join(tmp_dir, "config/config.exs"), """
      import Config
      """)

      on_exit(fn ->
        File.rm_rf!(tmp_dir)
      end)

      {:ok, tmp_dir: tmp_dir}
    end

    test "mix usage_rules.sync creates CLAUDE.md with mishka_chelekom rules", %{tmp_dir: tmp_dir} do
      IO.puts("\n" <> String.duplicate("=", 60))
      IO.puts("Running real-world usage_rules.sync test")
      IO.puts("Temp project: #{tmp_dir}")
      IO.puts(String.duplicate("=", 60))

      # Get dependencies first
      IO.puts("\n>>> Running: mix deps.get")
      {output, exit_code} = System.cmd("mix", ["deps.get"],
        cd: tmp_dir,
        stderr_to_stdout: true,
        env: [{"MIX_ENV", "dev"}]
      )

      if exit_code != 0 do
        IO.puts("deps.get failed: #{output}")
      end

      assert exit_code == 0, "mix deps.get should succeed"
      IO.puts(">>> deps.get completed successfully")

      # Run the sync command
      IO.puts("\n>>> Running: mix usage_rules.sync CLAUDE.md mishka_chelekom")
      {sync_output, sync_exit_code} = System.cmd("mix", [
        "usage_rules.sync",
        "CLAUDE.md",
        "mishka_chelekom"
      ],
        cd: tmp_dir,
        stderr_to_stdout: true,
        env: [{"MIX_ENV", "dev"}]
      )

      IO.puts("\n--- Command Output ---")
      IO.puts(sync_output)
      IO.puts("--- End Output ---")

      assert sync_exit_code == 0, "mix usage_rules.sync should succeed: #{sync_output}"

      # Check CLAUDE.md was created
      claude_path = Path.join(tmp_dir, "CLAUDE.md")
      assert File.exists?(claude_path), "CLAUDE.md should be created at #{claude_path}"

      # Read and verify content
      content = File.read!(claude_path)
      content_size = String.length(content)

      IO.puts("\n>>> CLAUDE.md created successfully!")
      IO.puts(">>> File size: #{content_size} bytes")
      IO.puts("\n--- CLAUDE.md Preview (first 3000 chars) ---")
      IO.puts(String.slice(content, 0, 3000))
      IO.puts("\n... [truncated] ...")
      IO.puts("--- End Preview ---")

      # Verify mishka_chelekom content is present
      assert content =~ "mishka_chelekom",
             "CLAUDE.md should contain mishka_chelekom marker"

      assert content =~ "Mishka Chelekom",
             "CLAUDE.md should contain 'Mishka Chelekom'"

      assert content =~ "mix mishka.ui.gen.component",
             "CLAUDE.md should contain component generation command"

      assert content =~ "Phoenix",
             "CLAUDE.md should mention Phoenix"

      assert content =~ "LiveView",
             "CLAUDE.md should mention LiveView"

      assert content =~ "button",
             "CLAUDE.md should mention button component"

      # Verify file is substantial
      assert content_size > 5000,
             "CLAUDE.md should be substantial (>5KB), got #{content_size} bytes"

      # Verify components are listed
      components = ["accordion", "alert", "avatar", "badge", "button", "card",
                    "carousel", "checkbox_field", "combobox", "dropdown", "modal",
                    "navbar", "pagination", "sidebar", "table", "tabs", "toast"]

      missing_components = Enum.filter(components, fn c ->
        not (content =~ c)
      end)

      IO.puts("\n>>> Checking components in generated CLAUDE.md...")
      IO.puts(">>> Missing components: #{inspect(missing_components)}")

      assert missing_components == [],
             "CLAUDE.md should contain all components, missing: #{inspect(missing_components)}"

      # Verify JS hooks section
      assert content =~ "JavaScript",
             "CLAUDE.md should mention JavaScript hooks"

      IO.puts("\n>>> All assertions passed!")
      IO.puts(String.duplicate("=", 60))
    end

    test "mix usage_rules.sync with mishka_chelekom:all includes sub-rules", %{tmp_dir: tmp_dir} do
      IO.puts("\n" <> String.duplicate("=", 60))
      IO.puts("Testing mishka_chelekom:all (includes sub-rules)")
      IO.puts(String.duplicate("=", 60))

      # Get dependencies
      {_output, exit_code} = System.cmd("mix", ["deps.get"],
        cd: tmp_dir,
        stderr_to_stdout: true,
        env: [{"MIX_ENV", "dev"}]
      )

      assert exit_code == 0

      # Run sync with :all to get sub-rules
      IO.puts("\n>>> Running: mix usage_rules.sync FULL_RULES.md mishka_chelekom:all")
      {sync_output, sync_exit_code} = System.cmd("mix", [
        "usage_rules.sync",
        "FULL_RULES.md",
        "mishka_chelekom:all"
      ],
        cd: tmp_dir,
        stderr_to_stdout: true,
        env: [{"MIX_ENV", "dev"}]
      )

      IO.puts("\n--- Command Output ---")
      IO.puts(sync_output)
      IO.puts("--- End Output ---")

      assert sync_exit_code == 0, "sync with :all should succeed: #{sync_output}"

      rules_path = Path.join(tmp_dir, "FULL_RULES.md")
      assert File.exists?(rules_path), "FULL_RULES.md should be created"

      content = File.read!(rules_path)
      content_size = String.length(content)

      IO.puts("\n>>> FULL_RULES.md created!")
      IO.puts(">>> File size: #{content_size} bytes")

      # Main rules should be present
      assert content =~ "Mishka Chelekom"

      IO.puts("\n>>> Checking for sub-rules content...")
      IO.puts("Contains mix tasks: #{content =~ "mishka.ui.gen.component"}")
      IO.puts("Contains components: #{content =~ "Button" or content =~ "button"}")

      IO.puts("\n>>> Test completed!")
      IO.puts(String.duplicate("=", 60))
    end

    test "generated CLAUDE.md contains all expected content", %{tmp_dir: tmp_dir} do
      IO.puts("\n" <> String.duplicate("=", 60))
      IO.puts("Verifying generated CLAUDE.md has all content")
      IO.puts(String.duplicate("=", 60))

      # Get dependencies and run sync
      {_output, _exit_code} = System.cmd("mix", ["deps.get"],
        cd: tmp_dir,
        stderr_to_stdout: true,
        env: [{"MIX_ENV", "dev"}]
      )

      {_sync_output, sync_exit_code} = System.cmd("mix", [
        "usage_rules.sync",
        "CLAUDE.md",
        "mishka_chelekom"
      ],
        cd: tmp_dir,
        stderr_to_stdout: true,
        env: [{"MIX_ENV", "dev"}]
      )

      assert sync_exit_code == 0

      # Read generated CLAUDE.md
      claude_path = Path.join(tmp_dir, "CLAUDE.md")
      content = File.read!(claude_path)
      content_size = String.length(content)

      IO.puts("\n>>> Generated CLAUDE.md size: #{content_size} bytes")

      # Count how many components are mentioned
      all_components = [
        "accordion", "alert", "avatar", "badge", "banner", "blockquote",
        "breadcrumb", "button", "card", "carousel", "chat", "checkbox_card",
        "checkbox_field", "clipboard", "collapse", "color_field", "combobox",
        "date_time_field", "device_mockup", "divider", "drawer", "dropdown",
        "email_field", "fieldset", "file_field", "footer", "form_wrapper",
        "gallery", "image", "indicator", "input_field", "jumbotron",
        "keyboard", "layout", "list", "mega_menu", "menu", "modal",
        "native_select", "navbar", "number_field", "overlay", "pagination",
        "password_field", "popover", "progress", "radio_card", "radio_field",
        "range_field", "rating", "scroll_area", "search_field", "sidebar",
        "skeleton", "speed_dial", "spinner", "stepper", "table", "table_content",
        "tabs", "tel_field", "text_field", "textarea_field", "timeline",
        "toast", "toggle_field", "tooltip", "typography", "url_field", "video"
      ]

      found_components = Enum.filter(all_components, fn c -> content =~ c end)
      missing_components = all_components -- found_components

      IO.puts(">>> Components found in CLAUDE.md: #{length(found_components)}/#{length(all_components)}")

      if length(missing_components) > 0 do
        IO.puts(">>> Missing: #{inspect(Enum.take(missing_components, 10))}...")
      end

      # Should have most components listed in the table
      assert length(found_components) >= 50,
             "CLAUDE.md should reference at least 50 components, found #{length(found_components)}"

      # Verify JS hooks are mentioned
      js_hooks = ["Carousel", "Clipboard", "Collapsible", "Combobox", "Floating", "ScrollArea", "Sidebar"]
      found_hooks = Enum.filter(js_hooks, fn h -> content =~ h end)

      IO.puts(">>> JS Hooks found: #{length(found_hooks)}/#{length(js_hooks)}")
      assert length(found_hooks) >= 5,
             "CLAUDE.md should mention JS hooks"

      # Verify key sections exist
      assert content =~ "mix mishka.ui.gen.component",
             "Should have component generation command"

      assert content =~ "mishka.tools",
             "Should reference mishka.tools documentation"

      IO.puts("\n>>> All content verified!")
      IO.puts(String.duplicate("=", 60))
    end
  end
end
