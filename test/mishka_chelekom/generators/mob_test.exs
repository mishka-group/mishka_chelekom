defmodule MishkaChelekom.Generators.MobTest do
  @moduledoc """
  Invariants for the `priv/mob` catalog and the derivation that produces it.

  Everything here reads the filesystem, so a component added to
  `development/mob` is covered the moment `mix mishka.mob.sync` runs — there is
  no list to keep up to date.
  """
  use ExUnit.Case, async: true

  alias MishkaChelekom.Generators.{Core, Mob}

  doctest MishkaChelekom.Generators.Mob

  @templates Path.wildcard("priv/mob/*.eex")
  @catalogs Path.wildcard("priv/mob/*.exs")

  defp names, do: MapSet.new(@templates, &Path.basename(&1, ".eex"))

  defp config(path) do
    name = Path.basename(path, ".exs")

    {name, Config.Reader.read!(path)[String.to_atom(name)]}
  end

  test "there is a catalog to check at all" do
    assert length(@templates) > 50,
           "the wildcard matched nothing — every test in this file would pass vacuously"
  end

  describe "catalog integrity" do
    test "every template has a catalog, and every catalog a template" do
      assert MapSet.equal?(names(), MapSet.new(@catalogs, &Path.basename(&1, ".exs")))
    end

    test "every catalog passes the shape the generator requires" do
      for path <- @catalogs do
        {name, config} = config(path)

        assert {:ok, _} = Core.validate_catalog(config), "#{name} has an invalid catalog"
        assert config[:name] == name, "#{name}'s :name disagrees with its filename"
      end
    end

    test "every `necessary` entry names a component that exists" do
      # A dangling name makes the generator compose a task for a component with
      # no template, and the consumer sees an error about something they never
      # asked for.
      for path <- @catalogs do
        {name, config} = config(path)
        dangling = Enum.reject(config[:necessary] || [], &MapSet.member?(names(), &1))

        assert dangling == [], "#{name} depends on missing component(s): #{inspect(dangling)}"
      end
    end

    test "no component depends on itself" do
      # Self-dependency makes `generate_necessary` recurse until the run is
      # killed; it happened, from doctests that alias their own module.
      for path <- @catalogs do
        {name, config} = config(path)

        refute name in (config[:necessary] || []), "#{name} lists itself as necessary"
      end
    end

    test "every `mob: [kit: …]` entry names a real kit module" do
      for path <- @catalogs do
        {name, config} = config(path)
        kit = get_in(config, [:mob, :kit]) || []

        assert kit -- Mob.kit_modules() == [], "#{name} wants an unknown kit module"
      end
    end

    test "the composite tag is the UNPREFIXED base — the run supplies the prefix" do
      # The catalog is written at sync time, long before any consumer's prefix is
      # known, so it can only record the base. `--module-prefix acme_` then
      # registers :acme_chip.
      for path <- @catalogs do
        {name, config} = config(path)

        assert get_in(config, [:mob, :composite_tag]) == name
      end
    end

    test "a component's declared function is the one the template defines" do
      for path <- @catalogs do
        {name, config} = config(path)
        template = File.read!("priv/mob/#{name}.eex")

        case get_in(config, [:mob, :function]) do
          nil ->
            refute template =~ "def <%= @component_prefix %>#{name}(",
                   "#{name} declares no function but its template prefixes one"

          function ->
            assert template =~ "def <%= @component_prefix %>#{function}(",
                   "#{name} declares #{function} but its template does not define it"
        end
      end
    end

    test "scripts are empty — a Mob component has no JS engine to wire" do
      for path <- @catalogs do
        {name, config} = config(path)

        assert config[:scripts] == [], "#{name} declares scripts; Mob has no JS layer"
      end
    end
  end

  describe "template hygiene" do
    test "no template mentions the development application" do
      leaked = Enum.filter(@templates, &(File.read!(&1) =~ "MishkaMob"))

      assert leaked == [],
             "still name the dev app: #{inspect(Enum.map(leaked, &Path.basename/1))}"
    end

    test "every template takes its module from the generator" do
      for path <- @templates do
        assert File.read!(path) =~ "defmodule <%= @module %> do", "#{Path.basename(path)}"
      end
    end

    test "every cross-component alias goes through the namespace assign" do
      # A hard-coded namespace would resolve to a module the consumer's app does
      # not have.
      for path <- @templates do
        for [line] <- Regex.scan(~r/^\s*alias .*$/m, File.read!(path)) do
          if line =~ "Components" do
            assert line =~ "<%= @namespace %>", "#{Path.basename(path)}: #{String.trim(line)}"
          end
        end
      end
    end

    test "kit modules define an unprefixed module, even though their docs are prefixed" do
      # Event and Color are shared, so the modules themselves are never prefixed.
      # Their moduledocs do name components (`<MishkaDrawer />`), and those tags
      # follow the run's prefix like everything else.
      for path <- Path.wildcard("priv/mob/kit/*.eex") do
        source = File.read!(path)
        name = Path.basename(path, ".eex")

        assert source =~ "defmodule <%= @namespace %>.#{Macro.camelize(name)} do",
               "#{Path.basename(path)} should define an unprefixed module"
      end
    end
  end

  describe "siblings/1" do
    test "reads alias lines and ignores prose" do
      source = """
        alias <<<NS>>>.{Event, MishkaPill}
        alias <<<NS>>>.MishkaActionIcon

        See `<<<NS>>>.MishkaChip` for the other one.
      """

      source = String.replace(source, "<<<NS>>>", "MishkaMob.Components")

      assert Mob.siblings(source) == [{"ActionIcon", "action_icon"}, {"Pill", "pill"}]
    end

    test "returns the underscored component name beside the module suffix" do
      source = "  alias MishkaMob.Components.MishkaScrollArea"

      assert Mob.siblings(source) == [{"ScrollArea", "scroll_area"}]
    end
  end

  describe "templatize/2" do
    test "rewrites the module, the namespace and the public function" do
      source = """
      defmodule MishkaMob.Components.MishkaChip do
        alias MishkaMob.Components.Event

        def expand(props, _children, _ctx), do: chip(props)

        @spec chip(map()) :: map()
        def chip(props), do: Event.handler(props)
      end
      """

      template = Mob.templatize(source, component: "chip")

      assert template =~ "defmodule <%= @module %> do"
      assert template =~ "alias <%= @namespace %>.Event"
      assert template =~ "def <%= @component_prefix %>chip(props)"
      assert template =~ "@spec <%= @component_prefix %>chip("
      # the delegating self-call has to move with the definition
      assert template =~ "do: <%= @component_prefix %>chip(props)"
      refute template =~ "MishkaMob"
    end

    test "a composite tag in the docs follows the prefix, like every other name" do
      # `<MishkaChip />` is markup, and the tag it names is prefixed with the same
      # `--module-prefix` as the module — so the doc has to move with it, or it
      # documents a tag the app never registers.
      source = """
      defmodule MishkaMob.Components.MishkaChip do
        @doc "Composite expander (`<MishkaChip />`)."
        def expand(a, b, c), do: {a, b, c}
      end
      """

      assert Mob.templatize(source, component: "chip") =~
               "`<<%= @module_prefix_camel %>Chip />`"
    end

    test "appends a companion module into the same file" do
      main = "defmodule MishkaMob.Components.MishkaToast do\nend\n"
      queue = "defmodule MishkaMob.Components.MishkaToast.Queue do\nend\n"

      template = Mob.templatize(main, component: "toast", companions: [queue])

      assert template =~ "defmodule <%= @module %> do"
      # fully qualified: the companion is a real module in the consumer's app
      assert template =~ "defmodule <%= @namespace %>.<%= @module_prefix_camel %>Toast.Queue do"
    end
  end

  describe "discovery" do
    test "finds the components and excludes the nested companion" do
      discovered = Mob.components() |> Enum.map(&elem(&1, 0))

      assert "toast" in discovered
      refute "toast_queue" in discovered, "a nested module is not a component"
      assert length(discovered) == MapSet.size(names())
    end

    test "companions/2 finds toast's queue and nothing for a plain component" do
      assert Mob.companions("toast") != []
      assert Mob.companions("chip") == []
    end
  end
end
