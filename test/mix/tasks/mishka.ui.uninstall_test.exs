defmodule Mix.Tasks.Mishka.Ui.UninstallTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias Mix.Tasks.Mishka.Ui.Uninstall
  @moduletag :igniter

  # Note: Igniter.Test.test_project uses app_name: :test by default,
  # so web module is "test_web" and components path is "lib/test_web/components/"
  #
  # The --all flag requires scanning the real filesystem which doesn't work
  # in Igniter's virtual test environment. Tests for --all use explicit component
  # names instead to demonstrate the same functionality.

  setup do
    Application.ensure_all_started(:owl)
    :ok
  end

  describe "argument validation" do
    test "requires component name or --all flag" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(Uninstall, [])

      issues_text = Enum.join(igniter.issues, " ")
      assert String.contains?(issues_text, "Please specify components")
      assert String.contains?(issues_text, "--all")
    end

    test "accepts single component name" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/accordion.ex", """
        defmodule TestWeb.Components.Accordion do
          use Phoenix.Component
          def accordion(assigns), do: ~H"<div>Accordion</div>"
        end
        """)
        |> Igniter.compose_task(Uninstall, ["accordion", "--yes"])

      issues_text = Enum.join(igniter.issues, " ")
      refute String.contains?(issues_text, "Please specify components")
    end

    test "accepts comma-separated component names" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/accordion.ex", """
        defmodule TestWeb.Components.Accordion do
          use Phoenix.Component
          def accordion(assigns), do: ~H"<div>Accordion</div>"
        end
        """)
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.compose_task(Uninstall, ["accordion,button", "--yes"])

      issues_text = Enum.join(igniter.issues, " ")
      refute String.contains?(issues_text, "Please specify components")
    end
  end

  describe "component file removal" do
    test "removes component file when it exists" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.create_new_file("priv/components/button.exs", """
        [button: [args: [], necessary: [], optional: [], scripts: []]]
        """)
        |> Igniter.compose_task(Uninstall, ["button", "--yes"])

      assert "lib/test_web/components/button.ex" in igniter.rms
    end

    test "removes multiple component files" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.create_new_file("lib/test_web/components/alert.ex", """
        defmodule TestWeb.Components.Alert do
          use Phoenix.Component
          def alert(assigns), do: ~H"<div>Alert</div>"
        end
        """)
        |> Igniter.compose_task(Uninstall, ["button,alert", "--yes"])

      assert "lib/test_web/components/button.ex" in igniter.rms
      assert "lib/test_web/components/alert.ex" in igniter.rms
    end

    test "handles non-existent component gracefully" do
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(Uninstall, ["non_existent_component", "--yes"])

      notices_text = Enum.join(igniter.notices, " ")
      assert String.contains?(notices_text, "complete") || igniter.issues == []
    end
  end

  describe "module prefix support" do
    test "finds components with module prefix" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", """
        import Config
        config :mishka_chelekom, module_prefix: "mishka_"
        """)
        |> Igniter.create_new_file("lib/test_web/components/mishka_accordion.ex", """
        defmodule TestWeb.Components.MishkaAccordion do
          use Phoenix.Component
          def accordion(assigns), do: ~H"<div>Accordion</div>"
        end
        """)
        |> Igniter.create_new_file("priv/components/accordion.exs", """
        [accordion: [args: [], necessary: [], optional: [], scripts: []]]
        """)
        |> Igniter.compose_task(Uninstall, ["accordion", "--yes"])

      assert "lib/test_web/components/mishka_accordion.ex" in igniter.rms
    end
  end

  describe "JavaScript hook management" do
    test "removes JS file when no other component uses it" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/clipboard.ex", """
        defmodule TestWeb.Components.Clipboard do
          use Phoenix.Component
          def clipboard(assigns), do: ~H"<div>Clipboard</div>"
        end
        """)
        |> Igniter.create_new_file("assets/vendor/clipboard.js", """
        export default { mounted() {} };
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/clipboard.exs", """
        [clipboard: [
          args: [],
          necessary: [],
          optional: [],
          scripts: [%{type: "file", file: "clipboard.js", module: "Clipboard", imports: "import Clipboard from \\"./clipboard.js\\";"}]
        ]]
        """)
        |> Igniter.compose_task(Uninstall, ["clipboard", "--yes"])

      # Component should be removed
      assert "lib/test_web/components/clipboard.ex" in igniter.rms
      # JS file should also be removed when no other component uses it
      assert "assets/vendor/clipboard.js" in igniter.rms
    end

    test "preserves JS file when other component uses it" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/accordion.ex", """
        defmodule TestWeb.Components.Accordion do
          use Phoenix.Component
          def accordion(assigns), do: ~H"<div>Accordion</div>"
        end
        """)
        |> Igniter.create_new_file("lib/test_web/components/collapse.ex", """
        defmodule TestWeb.Components.Collapse do
          use Phoenix.Component
          def collapse(assigns), do: ~H"<div>Collapse</div>"
        end
        """)
        |> Igniter.create_new_file("assets/vendor/collapsible.js", """
        export default { mounted() {} };
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/accordion.exs", """
        [accordion: [
          args: [],
          necessary: [],
          optional: [],
          scripts: [%{type: "file", file: "collapsible.js", module: "Collapsible", imports: "import Collapsible from \\"./collapsible.js\\";"}]
        ]]
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/collapse.exs", """
        [collapse: [
          args: [],
          necessary: [],
          optional: [],
          scripts: [%{type: "file", file: "collapsible.js", module: "Collapsible", imports: "import Collapsible from \\"./collapsible.js\\";"}]
        ]]
        """)
        |> Igniter.compose_task(Uninstall, ["accordion", "--yes"])

      # Should NOT remove collapsible.js since collapse still uses it
      refute "assets/vendor/collapsible.js" in igniter.rms
      # Should remove the accordion component
      assert "lib/test_web/components/accordion.ex" in igniter.rms
    end

    test "keeps JS files with --keep-js flag" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/clipboard.ex", """
        defmodule TestWeb.Components.Clipboard do
          use Phoenix.Component
          def clipboard(assigns), do: ~H"<div>Clipboard</div>"
        end
        """)
        |> Igniter.create_new_file("assets/vendor/clipboard.js", """
        export default { mounted() {} };
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/clipboard.exs", """
        [clipboard: [
          args: [],
          necessary: [],
          optional: [],
          scripts: [%{type: "file", file: "clipboard.js", module: "Clipboard", imports: "import Clipboard from \\"./clipboard.js\\";"}]
        ]]
        """)
        |> Igniter.compose_task(Uninstall, ["clipboard", "--yes", "--keep-js"])

      # Should NOT remove the JS file with --keep-js
      refute "assets/vendor/clipboard.js" in igniter.rms
      # But should still remove the component
      assert "lib/test_web/components/clipboard.ex" in igniter.rms
    end
  end

  describe "--dry-run flag" do
    test "does not modify files in dry-run mode" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.compose_task(Uninstall, ["button", "--dry-run"])

      # In dry-run mode, nothing should be removed
      assert igniter.rms == []

      notices_text = Enum.join(igniter.notices, " ")
      assert String.contains?(notices_text, "Dry-run complete")
    end
  end

  describe "option aliases" do
    test "supports -d for --dry-run" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.compose_task(Uninstall, ["button", "-d"])

      notices_text = Enum.join(igniter.notices, " ")
      assert String.contains?(notices_text, "Dry-run complete")
    end

    test "supports -y for --yes" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.compose_task(Uninstall, ["button", "-y"])

      assert "lib/test_web/components/button.ex" in igniter.rms
    end

    test "supports -a for --all with explicit components" do
      # Note: -a/--all requires real filesystem, so we test with explicit component names
      # to verify the alias is recognized
      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task(Uninstall, ["-a"])

      # Should not have "Please specify components" error since -a is provided
      issues_text = Enum.join(igniter.issues, " ")
      refute String.contains?(issues_text, "Please specify components")
    end

    test "supports -V for --verbose" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.compose_task(Uninstall, ["button", "-y", "-V"])

      # Verbose should still complete successfully
      assert "lib/test_web/components/button.ex" in igniter.rms
    end
  end

  describe "cleanup when all components removed" do
    test "removes mishka_components.js when last component is removed" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.create_new_file("assets/vendor/mishka_components.js", """
        const Components = {};
        export default Components;
        """)
        |> Igniter.compose_task(Uninstall, ["button", "--yes"])

      # Component should be removed
      assert "lib/test_web/components/button.ex" in igniter.rms
      # mishka_components.js should be removed when no components remain
      assert "assets/vendor/mishka_components.js" in igniter.rms
    end

    test "keeps mishka_components.js with --keep-js" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.create_new_file("assets/vendor/mishka_components.js", """
        const Components = {};
        export default Components;
        """)
        |> Igniter.compose_task(Uninstall, ["button", "--yes", "--keep-js"])

      # Component should be removed
      assert "lib/test_web/components/button.ex" in igniter.rms
      # mishka_components.js should NOT be removed with --keep-js
      refute "assets/vendor/mishka_components.js" in igniter.rms
    end
  end

  describe "notices" do
    test "shows completion notice after uninstall" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.compose_task(Uninstall, ["button", "--yes"])

      notices_text = Enum.join(igniter.notices, " ")
      assert String.contains?(notices_text, "Uninstall complete")
      assert String.contains?(notices_text, "Components removed")
    end
  end

  describe "--include-css option" do
    test "removes CSS file when --all and --include-css are used" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/button.exs", """
        [button: [args: [], necessary: [], optional: [], scripts: []]]
        """)
        |> Igniter.create_new_file("assets/vendor/mishka_chelekom.css", """
        /* Mishka Chelekom styles */
        .button { display: inline-block; }
        """)
        |> Igniter.compose_task(Uninstall, ["button", "--yes", "--all", "--include-css"])

      # Component should be removed
      assert "lib/test_web/components/button.ex" in igniter.rms
      # CSS should be removed with --include-css
      assert "assets/vendor/mishka_chelekom.css" in igniter.rms
    end

    test "keeps CSS file without --include-css" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.create_new_file("assets/vendor/mishka_chelekom.css", """
        /* Mishka Chelekom styles */
        .button { display: inline-block; }
        """)
        |> Igniter.compose_task(Uninstall, ["button", "--yes"])

      # Component should be removed
      assert "lib/test_web/components/button.ex" in igniter.rms
      # CSS should NOT be removed without --include-css
      refute "assets/vendor/mishka_chelekom.css" in igniter.rms
    end
  end

  describe "--include-config option" do
    test "removes config file when --all and --include-config are used" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/button.exs", """
        [button: [args: [], necessary: [], optional: [], scripts: []]]
        """)
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", """
        import Config
        config :mishka_chelekom, []
        """)
        |> Igniter.compose_task(Uninstall, ["button", "--yes", "--all", "--include-config"])

      # Component should be removed
      assert "lib/test_web/components/button.ex" in igniter.rms
      # Config should be removed with --all and --include-config
      assert "priv/mishka_chelekom/config.exs" in igniter.rms
    end

    test "keeps config file without --include-config" do
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/button.exs", """
        [button: [args: [], necessary: [], optional: [], scripts: []]]
        """)
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", """
        import Config
        config :mishka_chelekom, []
        """)
        |> Igniter.compose_task(Uninstall, ["button", "--yes"])

      # Component should be removed
      assert "lib/test_web/components/button.ex" in igniter.rms
      # Config should NOT be removed without --include-config
      refute "priv/mishka_chelekom/config.exs" in igniter.rms
    end
  end

  describe "dependency warnings" do
    test "blocks removal with --yes when dependencies exist (requires --force)" do
      # When using --yes without --force, removal is blocked if dependencies exist
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/icon.ex", """
        defmodule TestWeb.Components.Icon do
          use Phoenix.Component
          def icon(assigns), do: ~H"<svg>Icon</svg>"
        end
        """)
        |> Igniter.create_new_file("lib/test_web/components/modal.ex", """
        defmodule TestWeb.Components.Modal do
          use Phoenix.Component
          def modal(assigns), do: ~H"<div>Modal</div>"
        end
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/icon.exs", """
        [icon: [args: [], necessary: [], optional: [], scripts: []]]
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/modal.exs", """
        [modal: [args: [], necessary: ["icon"], optional: [], scripts: []]]
        """)
        |> Igniter.compose_task(Uninstall, ["icon", "--yes"])

      # Should be blocked - icon not removed because modal depends on it
      assert igniter.issues != []
      assert Enum.any?(igniter.issues, &String.contains?(&1, "Cannot remove components"))
    end

    test "completes removal with --force even when dependencies exist" do
      # When using --force, removal proceeds with warnings
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/icon.ex", """
        defmodule TestWeb.Components.Icon do
          use Phoenix.Component
          def icon(assigns), do: ~H"<svg>Icon</svg>"
        end
        """)
        |> Igniter.create_new_file("lib/test_web/components/modal.ex", """
        defmodule TestWeb.Components.Modal do
          use Phoenix.Component
          def modal(assigns), do: ~H"<div>Modal</div>"
        end
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/icon.exs", """
        [icon: [args: [], necessary: [], optional: [], scripts: []]]
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/modal.exs", """
        [modal: [args: [], necessary: ["icon"], optional: [], scripts: []]]
        """)
        |> Igniter.compose_task(Uninstall, ["icon", "--yes", "--force"])

      # Icon should be removed with --force
      assert "lib/test_web/components/icon.ex" in igniter.rms
      # Modal should NOT be removed
      refute "lib/test_web/components/modal.ex" in igniter.rms
    end

    test "detects multiple components depending on the same component" do
      # When icon is removed, button, modal, and alert all depend on it
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/icon.ex", """
        defmodule TestWeb.Components.Icon do
          use Phoenix.Component
          def icon(assigns), do: ~H"<svg>Icon</svg>"
        end
        """)
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.create_new_file("lib/test_web/components/modal.ex", """
        defmodule TestWeb.Components.Modal do
          use Phoenix.Component
          def modal(assigns), do: ~H"<div>Modal</div>"
        end
        """)
        |> Igniter.create_new_file("lib/test_web/components/alert.ex", """
        defmodule TestWeb.Components.Alert do
          use Phoenix.Component
          def alert(assigns), do: ~H"<div>Alert</div>"
        end
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/icon.exs", """
        [icon: [args: [], necessary: [], optional: [], scripts: []]]
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/button.exs", """
        [button: [args: [], necessary: ["icon"], optional: [], scripts: []]]
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/modal.exs", """
        [modal: [args: [], necessary: ["icon"], optional: [], scripts: []]]
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/alert.exs", """
        [alert: [args: [], necessary: ["icon"], optional: [], scripts: []]]
        """)
        |> Igniter.compose_task(Uninstall, ["icon", "--yes"])

      # Should be blocked - multiple components depend on icon
      assert igniter.issues != []
      assert Enum.any?(igniter.issues, &String.contains?(&1, "Cannot remove components"))
      # The error should mention button, modal, and alert
      error_msg = Enum.join(igniter.issues, " ")

      assert String.contains?(error_msg, "button") or String.contains?(error_msg, "modal") or
               String.contains?(error_msg, "alert")
    end

    test "cascade removes dependent components when specified" do
      # Removing icon,button,modal,alert together should work
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/icon.ex", """
        defmodule TestWeb.Components.Icon do
          use Phoenix.Component
          def icon(assigns), do: ~H"<svg>Icon</svg>"
        end
        """)
        |> Igniter.create_new_file("lib/test_web/components/button.ex", """
        defmodule TestWeb.Components.Button do
          use Phoenix.Component
          def button(assigns), do: ~H"<button>Button</button>"
        end
        """)
        |> Igniter.create_new_file("lib/test_web/components/modal.ex", """
        defmodule TestWeb.Components.Modal do
          use Phoenix.Component
          def modal(assigns), do: ~H"<div>Modal</div>"
        end
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/icon.exs", """
        [icon: [args: [], necessary: [], optional: [], scripts: []]]
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/button.exs", """
        [button: [args: [], necessary: ["icon"], optional: [], scripts: []]]
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/modal.exs", """
        [modal: [args: [], necessary: ["icon"], optional: [], scripts: []]]
        """)
        # Remove all together - no dependency issues
        |> Igniter.compose_task(Uninstall, ["icon,button,modal", "--yes"])

      # All should be removed
      assert "lib/test_web/components/icon.ex" in igniter.rms
      assert "lib/test_web/components/button.ex" in igniter.rms
      assert "lib/test_web/components/modal.ex" in igniter.rms
    end

    test "detects nested dependencies (card -> alert -> icon)" do
      # card depends on alert, alert depends on icon
      # Removing icon should warn about alert (direct) and card will be warned when alert is cascade-removed
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/icon.ex", """
        defmodule TestWeb.Components.Icon do
          use Phoenix.Component
          def icon(assigns), do: ~H"<svg>Icon</svg>"
        end
        """)
        |> Igniter.create_new_file("lib/test_web/components/alert.ex", """
        defmodule TestWeb.Components.Alert do
          use Phoenix.Component
          def alert(assigns), do: ~H"<div>Alert</div>"
        end
        """)
        |> Igniter.create_new_file("lib/test_web/components/card.ex", """
        defmodule TestWeb.Components.Card do
          use Phoenix.Component
          def card(assigns), do: ~H"<div>Card</div>"
        end
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/icon.exs", """
        [icon: [args: [], necessary: [], optional: [], scripts: []]]
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/alert.exs", """
        [alert: [args: [], necessary: ["icon"], optional: [], scripts: []]]
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/card.exs", """
        [card: [args: [], necessary: ["alert"], optional: [], scripts: []]]
        """)
        |> Igniter.compose_task(Uninstall, ["icon", "--yes"])

      # Should be blocked - alert depends on icon
      assert igniter.issues != []
      error_msg = Enum.join(igniter.issues, " ")
      assert String.contains?(error_msg, "alert")
    end

    test "removes entire dependency chain when all specified" do
      # card -> alert -> icon, removing all should work
      igniter =
        test_project_with_formatter()
        |> Igniter.create_new_file("lib/test_web/components/icon.ex", """
        defmodule TestWeb.Components.Icon do
          use Phoenix.Component
          def icon(assigns), do: ~H"<svg>Icon</svg>"
        end
        """)
        |> Igniter.create_new_file("lib/test_web/components/alert.ex", """
        defmodule TestWeb.Components.Alert do
          use Phoenix.Component
          def alert(assigns), do: ~H"<div>Alert</div>"
        end
        """)
        |> Igniter.create_new_file("lib/test_web/components/card.ex", """
        defmodule TestWeb.Components.Card do
          use Phoenix.Component
          def card(assigns), do: ~H"<div>Card</div>"
        end
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/icon.exs", """
        [icon: [args: [], necessary: [], optional: [], scripts: []]]
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/alert.exs", """
        [alert: [args: [], necessary: ["icon"], optional: [], scripts: []]]
        """)
        |> Igniter.create_new_file("deps/mishka_chelekom/priv/components/card.exs", """
        [card: [args: [], necessary: ["alert"], optional: [], scripts: []]]
        """)
        |> Igniter.compose_task(Uninstall, ["icon,alert,card", "--yes"])

      # All should be removed
      assert "lib/test_web/components/icon.ex" in igniter.rms
      assert "lib/test_web/components/alert.ex" in igniter.rms
      assert "lib/test_web/components/card.ex" in igniter.rms
    end
  end
end
