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

  describe "module prefixes that do not end in an underscore" do
    test "are normalised, so a component and its sibling agree on the module name" do
      # `--module-prefix mishka` used to yield MishkacloseButton aliasing
      # MishkaActionIcon while the sibling defined MishkaactionIcon — code that
      # does not compile. The prefix is normalised to `mishka_` instead.
      igniter = gen(["close_button", "--module-prefix", "mishka", "--yes"])

      generated = content(igniter, "lib/test/components/mishka_close_button.ex")
      sibling = content(igniter, "lib/test/components/mishka_action_icon.ex")

      assert generated =~ "defmodule Test.Components.MishkaCloseButton do"
      assert sibling =~ "defmodule Test.Components.MishkaActionIcon do"
      assert generated =~ "alias Test.Components.MishkaActionIcon"
    end

    test "an already-underscored prefix is unchanged" do
      with_underscore = gen(["chip", "--module-prefix", "mishka_", "--yes"])
      without = gen(["chip", "--module-prefix", "mishka", "--yes"])

      assert content(with_underscore, "lib/test/components/mishka_chip.ex") ==
               content(without, "lib/test/components/mishka_chip.ex")
    end
  end

  describe "the composite registry" do
    test "is written, and registers the generated tag" do
      igniter = gen(["chip", "--yes"])
      registry = content(igniter, "lib/test/components.ex")

      assert registry =~ "defmodule Test.Components do"
      assert registry =~ "{:chip, Test.Components.Chip}"
      assert registry =~ "Mob.Composite.register(tag, {module, :expand})"
    end

    test "includes siblings pulled in during the same run" do
      registry = gen(["close_button", "--yes"]) |> content("lib/test/components.ex")

      assert registry =~ "{:action_icon,"
      assert registry =~ "{:close_button,"
    end

    test "the tag follows --module-prefix, exactly like the module does" do
      bare = gen(["chip", "--yes"]) |> content("lib/test/components.ex")

      mishka =
        gen(["chip", "--module-prefix", "mishka_", "--yes"]) |> content("lib/test/components.ex")

      acme =
        gen(["chip", "--module-prefix", "acme_", "--yes"]) |> content("lib/test/components.ex")

      assert bare =~ "{:chip, Test.Components.Chip}"
      assert mishka =~ "{:mishka_chip, Test.Components.MishkaChip}"
      assert acme =~ "{:acme_chip, Test.Components.AcmeChip}"
    end

    test "the generated docs name the tag the app actually registers" do
      acme = gen(["chip", "--module-prefix", "acme_", "--yes"])

      assert content(acme, "lib/test/components/acme_chip.ex") =~ "`<AcmeChip />`"
    end

    test "never lists the kit modules as components" do
      registry = gen(["hue_slider", "--yes"]) |> content("lib/test/components.ex")

      refute registry =~ ":event,"
      refute registry =~ ":color,"
    end

    test "names the module --module actually created, not one guessed from the filename" do
      # The registry used to derive the module from the file name, so a custom
      # --module produced an entry pointing at a module that does not exist.
      igniter = gen(["chip", "--module", "my_app.widgets.chip", "--yes"])

      assert content(igniter, "lib/test/components.ex") =~ "{:chip, MyApp.Widgets.Chip}"
    end

    test "--no-register leaves it alone" do
      igniter = gen(["chip", "--no-register", "--yes"])

      refute igniter.rewrite.sources["lib/test/components.ex"]
    end
  end

  describe "registering at boot" do
    @app_ex "lib/test/app.ex"
    @app_src """
    defmodule Test.App do
      use Mob.App

      def on_start do
        Mob.Nav.push(Test.HomeScreen)
      end
    end
    """

    defp gen_with_app(args) do
      [files: %{@app_ex => @app_src}]
      |> test_project_with_formatter()
      |> Igniter.compose_task(Mob, args)
    end

    # A registry nothing calls registers nothing — and an unregistered tag does
    # not fail, it renders nothing. Leaving this to the docs is leaving a step
    # whose only symptom is a blank screen.
    test "calls register_all/0 from the app's on_start/0" do
      app = gen_with_app(["chip", "--yes"]) |> content(@app_ex)

      assert app =~ "Test.Components.register_all()"
      assert app =~ "Mob.Nav.push(Test.HomeScreen)"
    end

    test "is idempotent — a second component does not add the call twice" do
      app =
        [files: %{@app_ex => @app_src}]
        |> test_project_with_formatter()
        |> Igniter.compose_task(Mob, ["chip", "--yes"])
        |> Igniter.compose_task(Mob, ["pill", "--yes"])
        |> content(@app_ex)

      assert app |> String.split("Test.Components.register_all()") |> length() == 2
    end

    test "--no-register leaves boot alone, there being no registry to call" do
      refute gen_with_app(["chip", "--no-register", "--yes"]) |> content(@app_ex) =~
               "register_all()"
    end

    test "says what to add when the app module is not where it is expected" do
      igniter = gen(["chip", "--yes"])

      assert Enum.any?(igniter.notices, &(&1 =~ "register_all()"))
    end
  end

  describe "the ~MOB tag declaration (config :mob, :extra_tags)" do
    @config "config/config.exs"
    @seeded "import Config\n\nconfig :mob, :extra_tags, ~w(\n  MishkaChip\n)\n"

    defp gen_with_config(args, config \\ @seeded) do
      [files: %{@config => config}]
      |> test_project_with_formatter()
      |> Igniter.compose_task(Mob, args)
    end

    # Read the way Mob does — evaluating the config — so a ~w() sigil and a plain
    # list both come back as the same thing.
    defp tags(igniter) do
      path = Path.join(System.tmp_dir!(), "extra_tags_#{System.unique_integer([:positive])}.exs")
      File.write!(path, content(igniter, @config))
      on_exit(fn -> File.rm(path) end)

      path |> Config.Reader.read!() |> get_in([:mob, :extra_tags]) |> Enum.map(&to_string/1)
    end

    # Registering a composite makes the tag render; it does not make it compile
    # without a warning, and on --warnings-as-errors that difference is what
    # decides whether the tag form can be used at all.
    test "adds the generated tag, as ~MOB spells it" do
      assert "Chip" in tags(gen_with_config(["chip", "--yes"]))
    end

    test "keeps tags already in the list" do
      assert "MishkaChip" in tags(gen_with_config(["chip", "--yes"]))
    end

    test "creates the setting when the app has none" do
      igniter = gen_with_config(["chip", "--yes"], "import Config\n")

      assert tags(igniter) == ["Chip"]
    end

    test "carries --module-prefix, which is why it reads the registry not the files" do
      assert "AcmeChip" in tags(gen_with_config(["chip", "--module-prefix", "acme_", "--yes"]))
    end

    test "declares siblings pulled in during the same run" do
      tags = tags(gen_with_config(["close_button", "--yes"]))

      assert "CloseButton" in tags
      assert "ActionIcon" in tags
    end

    # Mob reads the setting at each ~MOB call site's compile time and Mix does
    # not track that read, so already-compiled screens need a forced compile.
    test "queues compile --force, without which compiled screens keep warning" do
      assert {"compile", ["--force"]} in gen_with_config(["chip", "--yes"]).tasks
    end

    test "never writes into Mob's own files under deps/" do
      igniter = gen_with_config(["chip", "--yes"])

      refute Enum.any?(Map.keys(igniter.rewrite.sources), &String.starts_with?(&1, "deps/"))
    end

    test "--no-tags leaves :extra_tags alone" do
      igniter = gen_with_config(["chip", "--no-tags", "--yes"])

      assert tags(igniter) == ["MishkaChip"]
      refute {"compile", ["--force"]} in igniter.tasks
    end

    test "edits a plain list too, keeping what is in it" do
      tags =
        tags(
          gen_with_config(
            ["chip", "--yes"],
            "import Config\n\nconfig :mob, :extra_tags, [:my_tag]\n"
          )
        )

      assert "my_tag" in tags
      assert "Chip" in tags
    end

    test "says so when the value is computed, instead of rewriting it" do
      computed = "import Config\n\nconfig :mob, :extra_tags, Enum.map([:a], & &1)\n"
      igniter = gen_with_config(["chip", "--yes"], computed)

      assert content(igniter, @config) =~ "Enum.map"
      assert Enum.any?(igniter.warnings, &(&1 =~ "Chip"))
    end

    # Re-running a generator must not accumulate duplicate tags.
    test "is idempotent — generating twice yields the same list" do
      once = gen_with_config(["chip", "--yes"]) |> content(@config)

      twice =
        [files: %{@config => once}]
        |> test_project_with_formatter()
        |> Igniter.compose_task(Mob, ["chip", "--yes"])

      assert tags(twice) == ["MishkaChip", "Chip"]
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

  describe "the catalog's docs block" do
    test "never reaches the generator, so nothing it writes depends on it" do
      declared = Config.Reader.read!("priv/mob/chip.exs")[:chip]
      assert Keyword.has_key?(declared, :docs)

      igniter = gen(["chip", "--yes"])

      assert igniter.assigns.template_config == Keyword.delete(declared, :docs)
      assert content(igniter, "lib/test/components/chip.ex")
    end
  end
end
