defmodule MishkaMob.GeneratedComponentsTest do
  # These modules are defined at RUNTIME by the test itself — each generated
  # template is rendered and Code.compile_string'd inside the relevant test. The
  # compiler is right that they do not exist yet at compile time, and wrong that
  # it matters, so the warning is declared away rather than worked around.
  @compile {:no_warn_undefined,
            [
              Generated.Live.Chip,
              Generated.Live.CloseButton,
              Generated.Live.Color,
              Generated.Live.NumberFormatter,
              Generated.Live.Switch,
              Generated.Live.Toast.Queue,
              Generated.Live.Tree,
              Generated.Pfx.MishkaCloseButton
            ]}

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
      # The drawn switch's thumb arithmetic is public API, and the one piece of
      # geometry a caller is invited to reuse at a call site.
      assert Generated.Live.Switch.thumb_offset(true, 46, 22, 3) == 9.0
      assert Generated.Live.Switch.thumb_offset(false, 46, 22, 3) == -9.0
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

    # The default case above only proves the templates were not broken; it says
    # nothing about a prop added to a component after its template was written,
    # which is precisely how the two drift. So these pass the whole surface —
    # sizing, typography, slots, per-state colours — in one call each.
    test "a component's LATER props survive generation too, not only its defaults" do
      cases = [
        # A switch in its drawn rendering: a whole second way of building the
        # control that the default cases never reach, and the only one whose
        # geometry is computed here rather than forwarded to a native widget.
        {Generated.Live.Switch, MishkaMob.Components.MishkaSwitch, :switch,
         [
           %{
             render: :box,
             checked: true,
             disabled: false,
             label: "Wi-Fi",
             track_width: 46,
             track_height: 28,
             track_radius: 14,
             thumb_size: 22,
             thumb_radius: 11,
             thumb_inset: 3,
             track_on_color: :success,
             track_off_color: :muted,
             thumb_on_color: 0xFFFFFFFF,
             thumb_off_color: :surface,
             disabled_track_color: :muted,
             disabled_thumb_color: :border,
             thumb_shadow: "0 1 3 0 #33000000",
             on_toggle: :wifi_tapped
           }
         ]},
        # The same switch off and disabled: the other half of every colour
        # fallback, the mirrored thumb offset, and the dropped tap handler.
        {Generated.Live.Switch, MishkaMob.Components.MishkaSwitch, :switch,
         [
           %{
             render: :box,
             checked: false,
             disabled: true,
             track_width: 46,
             track_height: 28,
             thumb_size: 22,
             thumb_inset: 3,
             disabled_track_color: :muted,
             disabled_thumb_color: :border,
             on_toggle: :wifi_tapped
           }
         ]},
        # A chip whose disabled state is transparent with a muted label: the
        # design that could not be expressed at all while the unchecked and
        # disabled colours were hardcoded to theme tokens.
        {Generated.Live.Chip, MishkaMob.Components.MishkaChip, :chip,
         [
           %{
             label: "Unread",
             trailing: "12",
             trailing_gap: 6,
             width: 96,
             height: 32,
             padding_x: 15,
             padding_y: 0,
             corner_radius: 8,
             text_size: 12,
             font_weight: :medium,
             max_lines: 1,
             align: :center,
             disabled: true,
             disabled_color: 0x00000000,
             disabled_text_color: :muted,
             unchecked_color: 0x00000000,
             unchecked_text_color: :subtle
           }
         ]},
        # A pill sized to a design, with both slots filled and the content row
        # told to stop centring.
        {Generated.Live.Pill, MishkaMob.Components.MishkaPill, :pill,
         [
           %{
             label: "PRO",
             leading: "●",
             leading_gap: 6,
             leading_size: 8,
             with_remove: true,
             remove_gap: 4,
             remove_size: :sm,
             content_align: :top,
             content_fill_width: true,
             fill_width: true,
             height: 12,
             padding_top: 9,
             padding_bottom: 9,
             padding_left: 12,
             padding_right: 12,
             corner_radius: 4,
             text_size: 11.5,
             font_weight: :semibold,
             letter_spacing: 0.5,
             line_height: 1.2,
             border_color: :outline,
             border_width: 1,
             shadow: "0 1 3 0 #33000000",
             align: :center
           }
         ]},
        # A drawn progress bar in its FIXED-width shape, full. The fill's width
        # is arithmetic (`width * fraction`) rather than a forwarded prop, so a
        # template that dropped the arithmetic would still render a plausible
        # bar — just the wrong length — and only a parity check catches it.
        {Generated.Live.Progress, MishkaMob.Components.MishkaProgress, :progress,
         [
           %{
             value: 100,
             render: :box,
             width: 46,
             height: 6,
             corner_radius: 3,
             track_color: :transparent,
             color: 0xFFFF7A00,
             id: "upload"
           }
         ]},
        # The same bar EMPTY and fill-width: the shape that claims its share
        # with `weight`, at the fraction where a zero weight would be emitted by
        # anything that computed it naively. Compose rejects `weight: 0.0`
        # outright, so 0% is the edge worth pinning, not an afterthought.
        {Generated.Live.Progress, MishkaMob.Components.MishkaProgress, :progress,
         [%{value: 0, render: :box, height: 6, label: "Uploading", show_value: true}]},
        # A drawn meter, which reaches the same drawing code through a sibling
        # module — so this also covers the sibling call surviving generation.
        {Generated.Live.Meter, MishkaMob.Components.MishkaMeter, :meter,
         [
           %{
             value: 72,
             render: :box,
             width: 46,
             height: 6,
             corner_radius: 3,
             track_color: :surface_raised,
             color: 0xFFFF7A00,
             id: "storage"
           }
         ]},
        # A drawn bar carries its fraction as a WIDTH rather than a prop, so the
        # fill's test tag is the only thing a device test can read it back from
        # — and it is a new public function rather than a node, which none of
        # the tree comparisons above can see. Meter's delegates to Progress's,
        # so a template that did not carry it over does not define it at all.
        {Generated.Live.Progress, MishkaMob.Components.MishkaProgress, :fill_id, ["upload"]},
        {Generated.Live.Meter, MishkaMob.Components.MishkaMeter, :fill_id, ["storage"]}
      ]

      for {generated, shipped, function, args} <- cases do
        assert apply(generated, function, args) == apply(shipped, function, args),
               "#{inspect(generated)} diverged on a later prop"
      end
    end

    # Reached through `expand/3` rather than through each component's own
    # function, because that is the composite protocol every generated component
    # keeps under any prefix. So a case is a NAME, a props map and its children,
    # and adding one needs no alias and no entry in the `@compile` list above:
    # `Module.concat/1` resolves after `setup` has compiled these into being.
    test "a container's later props — shadow, border, sizing — survive generation" do
      option = fn id, label ->
        %{type: :mishka_segmented_control_option, props: %{id: id, label: label}, children: []}
      end

      cases = [
        # A rule drawn as a filled Box rather than as Material's antialiased
        # stroke, with a label restyled on all three of its axes.
        {"separator",
         %{
           render: :box,
           label: "or continue with",
           label_size: 13,
           label_color: :primary,
           label_weight: :semibold,
           space: 6,
           thickness: 2,
           id: "sep"
         }, []},
        # A vertical rule carrying its own height, which is the one Box shape
        # iOS sizes on both axes.
        {"separator", %{orientation: :vertical, length: 24, thickness: 2, color: :border}, []},
        # A floating disc: the shadow and the hairline are what make it one, and
        # neither could be expressed while the container was written inside the
        # sigil, where an unset prop lands in the map as a nil.
        {"action_icon",
         %{
           icon: "→",
           variant: :filled,
           shape: :circle,
           shadow: "0 1 2 0 #0D1A1917 | 0 8 16 -12 #801A1917",
           border_color: :border,
           border_width: 2,
           on_tap: :next
         }, []},
        # The same, on a variant that already draws a border of its own — the
        # caller's colour has to REPLACE the variant's rather than fight it.
        {"theme_icon",
         %{
           icon: "★",
           variant: :outline,
           radius: :full,
           shadow: "0 1 2 0 #0D1A1917",
           border_color: :primary,
           border_width: 3,
           label: "Star",
           id: "ti"
         }, []},
        # A strip pinned to a design: a trough of a fixed height, equal-width
        # segments, a bolded selection lifted off the track, and a heading with
        # a type scale of its own.
        {"segmented_control",
         %{
           label: "View",
           heading_size: 11,
           heading_color: 0xFF010203,
           heading_weight: :semibold,
           heading_gap: 4,
           width: 240,
           height: 30,
           align: :center,
           shadow: "0 1 3 0 #11000000",
           track_padding: 3,
           segment_width: 70,
           segment_height: 28,
           segment_align: :center,
           segment_weight: 1,
           selected_shadow: "0 1 2 0 #0D1A1917",
           font_weight: :medium,
           selected_weight: :bold,
           letter_spacing: 0.2,
           line_height: 1.1,
           max_lines: 1,
           text_size: 10.5,
           padding_top: 0,
           padding_bottom: 0,
           padding_left: 10,
           padding_right: 10,
           fill_width: true,
           value: :week,
           id: "view",
           on_change: :pick
         }, [option.(:day, "Day"), option.(:week, "Week")]},
        # The 46x28 button the toggle's moduledoc promises, spelled with
        # `padding: 0` because padding is applied before width and height.
        {"toggle",
         %{
           label: "W",
           width: 46,
           height: 28,
           padding: 0,
           padding_left: 4,
           padding_right: 4,
           border_width: 0,
           corner_radius: 8,
           text_size: 11.5,
           font_weight: :semibold,
           letter_spacing: 0.2,
           line_height: 1.1,
           max_lines: 1,
           align: :center,
           shadow: "0 1 2 0 #0D1A1917",
           pressed: true,
           id: "t",
           on_change: :bold
         }, []}
      ]

      for {name, props, children} <- cases do
        generated = Module.concat([Generated.Live, Macro.camelize(name)])
        shipped = Module.concat([MishkaMob.Components, "Mishka#{Macro.camelize(name)}"])

        assert generated.expand(props, children, %{screen: self()}) ==
                 shipped.expand(props, children, %{screen: self()}),
               "#{name} diverged on a prop added after its template was written"
      end
    end

    test "the generated separator still defaults to a Divider, not to the new Box" do
      # Every other case here compares generated against shipped, so a template
      # that ported `render: :box` AND flipped the default would sail through
      # them all. The default is load-bearing on its own: the Box paints three
      # full pixel rows where Material's divider paints two and one at ~69%, so
      # flipping it would move the rule under every existing caller.
      separator = Module.concat([Generated.Live, "Separator"])
      ctx = %{screen: self()}

      assert separator.expand(%{}, [], ctx) == separator.expand(%{render: :divider}, [], ctx)
      assert separator.expand(%{}, [], ctx).type == :divider
      assert separator.expand(%{render: :box}, [], ctx).type == :box
    end

    test "the toast template carries its nested Queue module" do
      # Queue lives in its own file in this app; a generator writes one file per
      # component, so it has to travel inside the toast template.
      assert Code.ensure_loaded?(Generated.Live.Toast.Queue)
      assert Generated.Live.Toast.Queue.push([], %{id: 1}) == [%{id: 1}]
    end
  end
end
