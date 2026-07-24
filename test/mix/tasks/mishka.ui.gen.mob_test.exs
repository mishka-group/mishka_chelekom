defmodule Mix.Tasks.Mishka.Ui.Gen.MobTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias Mix.Tasks.Mishka.Ui.Gen.Mob
  @moduletag :igniter

  setup do
    Application.ensure_all_started(:owl)
    MishkaChelekom.ComponentTestHelper.setup_config()
    on_exit(fn -> MishkaChelekom.ComponentTestHelper.cleanup_config() end)
    :ok
  end

  defp content(igniter, path) do
    case igniter.rewrite.sources[path] do
      nil -> nil
      source -> Rewrite.Source.get(source, :content)
    end
  end

  defp gen(args), do: test_project_with_formatter() |> Igniter.compose_task(Mob, args)

  describe "location and module" do
    test "generates into lib/<app>/components — a Mob app has no _web namespace" do
      igniter = gen(["chip", "--yes"])

      assert content(igniter, "lib/test/components/chip.ex") =~
               "defmodule Test.Components.Chip do"

      # the headless layer's location must not be used
      refute igniter.rewrite.sources["lib/test_web/components/headless/chip.ex"]
    end

    test "--module-prefix moves both the file and the module" do
      igniter = gen(["chip", "--module-prefix", "mishka_", "--yes"])

      assert content(igniter, "lib/test/components/mishka_chip.ex") =~
               "defmodule Test.Components.MishkaChip do"
    end

    test "honors a custom --module" do
      igniter = gen(["chip", "--module", "my_app.widgets.chip", "--yes"])

      assert content(igniter, "lib/test/components/chip.ex") =~
               "defmodule MyApp.Widgets.Chip do"
    end

    test "an unknown component is an issue, and lists what is available" do
      igniter = gen(["not_a_component", "--yes"])

      assert [issue] = igniter.issues
      assert issue =~ "not found in priv/mob/"
      assert issue =~ "drawer"
    end
  end

  describe "the shared kit" do
    test "is vendored for a component that needs Event" do
      igniter = gen(["chip", "--yes"])

      assert content(igniter, "lib/test/components/event.ex") =~
               "defmodule Test.Components.Event do"
    end

    test "colour components pull in Color as well" do
      igniter = gen(["hue_slider", "--yes"])

      assert content(igniter, "lib/test/components/color.ex") =~ "defmodule Test.Components.Color"
      assert content(igniter, "lib/test/components/event.ex")
    end

    test "kit modules are never module-prefixed — they are not anyone's component" do
      igniter = gen(["chip", "--module-prefix", "mishka_", "--yes"])

      assert content(igniter, "lib/test/components/event.ex") =~
               "defmodule Test.Components.Event do"

      refute igniter.rewrite.sources["lib/test/components/mishka_event.ex"]
    end

    test "--no-kit skips it, for an app that already vendored its own" do
      igniter = gen(["chip", "--no-kit", "--yes"])

      refute igniter.rewrite.sources["lib/test/components/event.ex"]
    end
  end

  describe "necessary siblings" do
    test "a component that calls a sibling generates it too" do
      # close_button delegates to action_icon; without it the generated module
      # compiles into a call that does not exist.
      igniter = gen(["close_button", "--yes"])

      assert content(igniter, "lib/test/components/close_button.ex")
      assert content(igniter, "lib/test/components/action_icon.ex")
    end

    test "siblings inherit the prefixes, so the call site still resolves" do
      igniter = gen(["close_button", "--module-prefix", "mishka_", "--yes"])

      generated = content(igniter, "lib/test/components/mishka_close_button.ex")

      assert generated =~ "alias Test.Components.MishkaActionIcon"
      assert generated =~ "MishkaActionIcon.action_icon("
      assert content(igniter, "lib/test/components/mishka_action_icon.ex")
    end

    test "a transitive chain is followed" do
      # combobox -> menu -> popover, and select
      igniter = gen(["combobox", "--yes"])

      for component <- ~w(combobox menu select popover) do
        assert content(igniter, "lib/test/components/#{component}.ex"),
               "expected #{component} to be generated"
      end
    end

    test "a component with no siblings generates exactly one component file" do
      igniter = gen(["chip", "--yes"])

      components =
        igniter.rewrite.sources
        |> Map.keys()
        |> Enum.filter(&String.starts_with?(&1, "lib/test/components/"))
        |> Enum.reject(&String.ends_with?(&1, "event.ex"))

      assert components == ["lib/test/components/chip.ex"]
    end
  end

  describe "the component function prefix" do
    test "--component-prefix moves the definition AND its self-calls" do
      igniter = gen(["close_button", "--component-prefix", "mishka_", "--yes"])
      generated = content(igniter, "lib/test/components/close_button.ex")

      assert generated =~ "def mishka_close_button("
      assert generated =~ "@spec mishka_close_button("
      # expand/3 delegates to it — a prefix that moves one but not the other
      # produces a module that does not compile.
      assert generated =~ "do: mishka_close_button(props, children)"
    end

    test "and moves a sibling's call into it" do
      igniter = gen(["close_button", "--component-prefix", "mishka_", "--yes"])

      assert content(igniter, "lib/test/components/close_button.ex") =~
               "ActionIcon.mishka_action_icon(content)"
    end

    test "expand/3 is never prefixed — it is the composite protocol, not a component" do
      igniter = gen(["chip", "--component-prefix", "mishka_", "--yes"])

      assert content(igniter, "lib/test/components/chip.ex") =~ "def expand(props"
      refute content(igniter, "lib/test/components/chip.ex") =~ "def mishka_expand("
    end

    test "a composite-only component has no function to prefix" do
      # drawer exposes expand/3 and helpers, but no render function
      igniter = gen(["drawer", "--component-prefix", "mishka_", "--yes"])

      assert content(igniter, "lib/test/components/drawer.ex") =~ "def expand(props"
      refute content(igniter, "lib/test/components/drawer.ex") =~ "def mishka_drawer("
    end
  end

  describe "the composite registry" do
    test "is written, and registers the generated tag" do
      igniter = gen(["chip", "--yes"])
      registry = content(igniter, "lib/test/components.ex")

      assert registry =~ "defmodule Test.Components do"
      assert registry =~ "{:mishka_chip, Test.Components.Chip}"
      assert registry =~ "Mob.Composite.register(tag, {module, :expand})"
    end

    test "includes siblings pulled in during the same run" do
      registry = gen(["close_button", "--yes"]) |> content("lib/test/components.ex")

      assert registry =~ "{:mishka_action_icon,"
      assert registry =~ "{:mishka_close_button,"
    end

    test "the tag stays mishka_* even when the module is prefixed" do
      # The tag is the markup API; rewriting it would document a tag the app
      # never registers.
      registry =
        gen(["chip", "--module-prefix", "mishka_", "--yes"]) |> content("lib/test/components.ex")

      assert registry =~ "{:mishka_chip, Test.Components.MishkaChip}"
    end

    test "never lists the kit modules as components" do
      registry = gen(["hue_slider", "--yes"]) |> content("lib/test/components.ex")

      refute registry =~ ":mishka_event"
      refute registry =~ ":mishka_color,"
    end

    test "--no-register leaves it alone" do
      igniter = gen(["chip", "--no-register", "--yes"])

      refute igniter.rewrite.sources["lib/test/components.ex"]
    end
  end

  describe "what it deliberately does not do" do
    test "installs no CSS and no npm packages" do
      igniter = gen(["chip", "--yes"])
      paths = Map.keys(igniter.rewrite.sources)

      refute Enum.any?(paths, &String.contains?(&1, "assets/"))
      refute Enum.any?(paths, &String.ends_with?(&1, ".css"))
      refute Enum.any?(paths, &String.contains?(&1, "package.json"))
    end
  end
end
