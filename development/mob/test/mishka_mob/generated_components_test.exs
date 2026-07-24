defmodule MishkaMob.GeneratedComponentsTest do
  @moduledoc """
  The round trip: every `priv/mob` template is rendered, compiled and **called**
  inside a real Mob application, and its output compared against the component
  this repository actually develops and ships.

  ## Why this test exists here and not in the library

  `mishka_chelekom` cannot run it. It does not depend on `mob`, so a rendered
  component would not compile there — `Mob.Sigil`, `Mob.UI` and `Mob.Composite`
  are all missing. The library's own tests can only assert on the *text* a
  generator produces.

  Text is not the property that matters. What matters is that a consumer who
  runs `mix mishka.ui.gen.mob drawer` gets a module that compiles against the
  real framework and renders the same node tree we test on a device. That can
  only be checked where `mob` is a dependency, which is here.

  So this asserts the strong version: rendered → compiled → invoked → identical.
  """
  # async: false — compiles modules into the global namespace.
  use Mob.ScreenCase, async: false

  import ExUnit.CaptureIO

  @priv Path.expand("../../../../priv/mob", __DIR__)

  setup_all do
    unless File.dir?(@priv) do
      raise "priv/mob not found at #{@priv}. Run `mix mishka.mob.sync` in the library root."
    end

    # Generated modules are compiled repeatedly across the cases below.
    previous = Code.get_compiler_option(:ignore_module_conflict)
    Code.put_compiler_option(:ignore_module_conflict, true)
    on_exit(fn -> Code.put_compiler_option(:ignore_module_conflict, previous) end)

    :ok
  end

  defp templates, do: @priv |> Path.join("*.eex") |> Path.wildcard() |> Enum.sort()
  defp kit_templates, do: @priv |> Path.join("kit/*.eex") |> Path.wildcard() |> Enum.sort()

  defp component_name(path), do: Path.basename(path, ".eex")

  # The generator hands templates a module atom WITHOUT the `Elixir.` prefix, so
  # that `<%= @module %>` interpolates as `MyApp.Components.Chip` rather than
  # `Elixir.MyApp.Components.Chip`. `defmodule` then defines the Elixir-prefixed
  # module, so rendering and looking-up need different atoms for the same thing.
  defp assign_name(namespace, prefix, name),
    do: "#{namespace}.#{prefix}#{Macro.camelize(name)}"

  defp compiled_module(namespace, prefix, name),
    do: Module.concat([namespace, "#{prefix}#{Macro.camelize(name)}"])

  defp render(path, namespace, module_prefix, component_prefix) do
    module = assign_name(namespace, module_prefix, component_name(path))

    EEx.eval_file(path,
      assigns: [
        module: module,
        namespace: namespace,
        module_prefix_camel: module_prefix,
        component_prefix: component_prefix
      ]
    )
  end

  # Compiling a component whose sibling is not compiled yet warns about an
  # undefined module; the batch is complete by the end, so the warning is noise.
  defp compile_all(namespace, module_prefix, component_prefix) do
    capture_io(:stderr, fn ->
      for path <- kit_templates() do
        source =
          EEx.eval_file(path,
            assigns: [
              module: assign_name(namespace, "", component_name(path)),
              namespace: namespace,
              module_prefix_camel: "",
              component_prefix: ""
            ]
          )

        Code.compile_string(source, path)
      end

      for path <- templates() do
        Code.compile_string(render(path, namespace, module_prefix, component_prefix), path)
      end
    end)

    :ok
  end

  describe "the catalog itself" do
    test "has a template and a catalog for every component, and nothing orphaned" do
      eex = MapSet.new(templates(), &component_name/1)

      exs =
        @priv |> Path.join("*.exs") |> Path.wildcard() |> MapSet.new(&Path.basename(&1, ".exs"))

      assert MapSet.equal?(eex, exs),
             "unpaired: #{inspect(MapSet.symmetric_difference(eex, exs) |> MapSet.to_list())}"

      assert MapSet.size(eex) > 50,
             "the wildcard matched almost nothing — this would pass vacuously"
    end

    test "covers exactly the components this app develops" do
      shipped =
        "lib/mishka_mob/components/mishka_*.ex"
        |> Path.wildcard()
        |> Enum.map(&(&1 |> Path.basename(".ex") |> String.replace_prefix("mishka_", "")))
        # toast_queue is not a component: it defines MishkaToast.Queue, which
        # travels inside the toast template.
        |> Enum.reject(&(&1 == "toast_queue"))
        |> MapSet.new()

      assert MapSet.equal?(MapSet.new(templates(), &component_name/1), shipped),
             "catalog and app disagree — run `mix mishka.mob.sync`"
    end

    test "no template leaks the development namespace" do
      leaked = Enum.filter(templates() ++ kit_templates(), &(File.read!(&1) =~ "MishkaMob"))

      assert leaked == [],
             "these still name the dev app: #{inspect(Enum.map(leaked, &Path.basename/1))}"
    end

    test "every template declares its module through the assign" do
      for path <- templates() do
        assert File.read!(path) =~ "defmodule <%= @module %> do",
               "#{Path.basename(path)} does not take its module from the generator"
      end
    end
  end

  describe "rendered and compiled with no prefixes" do
    setup do
      compile_all(Generated.Plain, "", "")
      :ok
    end

    test "every component compiles" do
      for path <- templates() do
        module = compiled_module(Generated.Plain, "", component_name(path))

        assert Code.ensure_loaded?(module), "#{component_name(path)} did not compile"
      end
    end

    test "every component still exposes the composite expander" do
      for path <- templates() do
        module = compiled_module(Generated.Plain, "", component_name(path))

        assert function_exported?(module, :expand, 3),
               "#{component_name(path)} lost expand/3 in generation"
      end
    end

    test "every component renders a node tree identical to the one we ship" do
      for path <- templates() do
        name = component_name(path)
        generated = compiled_module(Generated.Plain, "", name)
        shipped = Module.concat([MishkaMob.Components, "Mishka#{Macro.camelize(name)}"])

        assert generated.expand(%{}, [], %{screen: self()}) ==
                 shipped.expand(%{}, [], %{screen: self()}),
               "#{name} renders differently after generation"
      end
    end

    test "the rendered tree is one the native layer can actually draw" do
      for path <- templates() do
        module = compiled_module(Generated.Plain, "", component_name(path))

        assert_renderable(module.expand(%{}, [], %{screen: self()}), extra: [:canvas])
      end
    end
  end

  describe "rendered and compiled with both prefixes" do
    setup do
      compile_all(Generated.Pfx, "Mishka", "mishka_")
      :ok
    end

    test "every component compiles under a module prefix" do
      for path <- templates() do
        module = compiled_module(Generated.Pfx, "Mishka", component_name(path))

        assert Code.ensure_loaded?(module),
               "#{component_name(path)} did not compile with prefixes"
      end
    end

    test "prefixing does not change what a component renders" do
      for path <- templates() do
        name = component_name(path)
        generated = compiled_module(Generated.Pfx, "Mishka", name)
        shipped = Module.concat([MishkaMob.Components, "Mishka#{Macro.camelize(name)}"])

        assert generated.expand(%{}, [], %{screen: self()}) ==
                 shipped.expand(%{}, [], %{screen: self()}),
               "#{name} renders differently under a prefix"
      end
    end

    test "the public function moved, and its siblings' calls moved with it" do
      # close_button delegates to action_icon. If only the definition moved, this
      # call raises UndefinedFunctionError — the exact failure a consumer would
      # hit at runtime rather than at generation time.
      assert function_exported?(Generated.Pfx.MishkaCloseButton, :mishka_close_button, 2)
      assert function_exported?(Generated.Pfx.MishkaActionIcon, :mishka_action_icon, 2)

      node = Generated.Pfx.MishkaCloseButton.mishka_close_button(%{on_tap: :dismiss})

      assert node.type == :box
      assert text(node) =~ "✕"
    end

    test "expand/3 keeps its name — it is the composite protocol, not a component" do
      assert function_exported?(Generated.Pfx.MishkaChip, :expand, 3)
      refute function_exported?(Generated.Pfx.MishkaChip, :mishka_expand, 3)
    end
  end

  describe "behaviour beyond the empty case" do
    setup do
      compile_all(Generated.Live, "", "")
      :ok
    end

    test "handlers are widened, so a generated component's taps actually fire" do
      # The single easiest thing to break: a bare tag serialises as an ordinary
      # prop and the control renders perfectly and does nothing.
      node = Generated.Live.Chip.chip(label: "Elixir", on_toggle: :pick)

      assert node.props.on_tap == {self(), :pick}
    end

    test "a component that composes a sibling produces the sibling's markup" do
      generated = Generated.Live.CloseButton.close_button(on_tap: :dismiss)
      shipped = MishkaMob.Components.MishkaCloseButton.close_button(on_tap: :dismiss)

      assert generated == shipped
      assert text(generated) =~ "✕"
    end

    test "pure helpers survive generation intact" do
      assert Generated.Live.Color.parse("#3b82f6") == {:ok, {59, 130, 246}}
      assert Generated.Live.NumberFormatter.format(1_234_567) == "1,234,567"
      assert Generated.Live.Tree.toggle_expand("a", []) == ["a"]
    end

    test "a component with real props renders the same as the shipped one" do
      cases = [
        {Generated.Live.Chip, MishkaMob.Components.MishkaChip, :chip,
         [%{label: "x", checked: true}]},
        {Generated.Live.HueSlider, MishkaMob.Components.MishkaHueSlider, :hue_slider,
         [%{value: 210, show_value: true}]},
        {Generated.Live.Tree, MishkaMob.Components.MishkaTree, :tree,
         [
           %{
             nodes: [%{label: "a", value: "a", children: [%{label: "b", value: "b"}]}],
             expanded: ["a"]
           }
         ]}
      ]

      for {generated, shipped, function, args} <- cases do
        assert apply(generated, function, args) == apply(shipped, function, args),
               "#{inspect(generated)} diverged"
      end
    end

    test "the toast template carries its nested Queue module" do
      # Queue lives in its own file in this app; a generator writes one file per
      # component, so it has to travel inside the toast template.
      assert Code.ensure_loaded?(Generated.Live.Toast.Queue)
      assert Generated.Live.Toast.Queue.push([], %{id: 1}) == [%{id: 1}]
    end
  end
end
