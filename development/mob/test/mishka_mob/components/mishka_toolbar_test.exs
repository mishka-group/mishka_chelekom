defmodule MishkaMob.Components.MishkaToolbarTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaBurger, MishkaToolbar}
  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.ComponentScreen

  doctest MishkaMob.Components.MishkaToolbar

  defp control(label), do: %{type: :text, props: %{text: label}, children: []}

  defp items, do: [control("A"), MishkaToolbar.separator(), control("B")]

  defp kinds do
    [
      MishkaToolbar.button(:bold, "Bold", icon: "B"),
      MishkaToolbar.link(:docs, "Docs", href: "https://mishka.tools"),
      MishkaToolbar.separator(),
      MishkaToolbar.input(:find, placeholder: "Find…", value: "abc")
    ]
  end

  # The box a given item id renders into, whatever suffix its state added.
  defp tagged(tree, tag), do: tree |> flatten() |> Enum.find(&(&1.props[:id] == tag))

  defp tags(tree) do
    tree |> flatten() |> Enum.map(& &1.props[:id]) |> Enum.reject(&is_nil/1)
  end

  describe "the strip" do
    test "is a bounded box holding a row" do
      tree = MishkaToolbar.toolbar(%{}, items())

      assert tree.type == :box
      assert tree.props.background == :surface_raised
      assert tree.props.corner_radius == :radius_md
      assert find(tree, :row)
    end

    test "vertical lays the controls in a column and does not fill width" do
      tree = MishkaToolbar.toolbar(%{orientation: :vertical}, items())

      assert find(tree, :column)
      refute tree.props.fill_width == true
    end

    test "space sets the gap" do
      tree = MishkaToolbar.toolbar(%{space: 20}, items())
      gaps = find(tree, :row).children |> Enum.filter(&(&1.type == :spacer))

      assert gaps != []
      assert Enum.all?(gaps, &(&1.props.size == 20))
    end

    test "chrome is overridable, and height bounds the strip" do
      tree =
        MishkaToolbar.toolbar(
          %{background: 0xFF111827, corner_radius: 4, padding: 2, height: 60},
          items()
        )

      assert tree.props.background == 0xFF111827
      assert tree.props.corner_radius == 4
      assert tree.props.padding == 2
      assert tree.props.height == 60
    end

    test "no height prop means no height key, rather than an explicit nil" do
      refute Map.has_key?(MishkaToolbar.toolbar(%{}, items()).props, :height)
    end
  end

  describe "the separator follows the toolbar's axis" do
    test "horizontal gets a vertical hairline" do
      tree = MishkaToolbar.toolbar(%{}, items())
      line = tree |> find_all(:box) |> Enum.find(&(&1.props[:width] == 1))

      assert line.props.height == 22
    end

    test "vertical gets a horizontal rule" do
      tree = MishkaToolbar.toolbar(%{orientation: :vertical}, items())
      line = tree |> find_all(:box) |> Enum.find(&(&1.props[:height] == 1))

      assert line.props.fill_width == true
    end
  end

  test "controls pass through untouched — the toolbar invents no button type" do
    tree = MishkaToolbar.toolbar(%{}, items())

    assert text(tree) =~ "A"
    assert text(tree) =~ "B"
  end

  test "expand/3 uses the tag's children" do
    assert MishkaToolbar.expand(%{}, items(), %{screen: self()}) ==
             MishkaToolbar.toolbar(%{}, items())

    # expand/3 routes every item through its builder to normalise the slot tags,
    # so a builder node must survive that trip untouched — otherwise writing the
    # markup and calling the function would drift apart on the next default.
    assert MishkaToolbar.expand(%{id: "fmt"}, kinds(), %{screen: self()}) ==
             MishkaToolbar.toolbar(%{id: "fmt"}, kinds())
  end

  describe "the four item kinds" do
    test "none of them reaches the renderer as a slot type" do
      # The item builders make node types the native layer has never heard of.
      # If a clause stopped matching, they would serialise straight through.
      assert_renderable(MishkaToolbar.toolbar(%{}, kinds()))
    end

    test "a button draws its label" do
      tree = MishkaToolbar.toolbar(%{}, [MishkaToolbar.button(:bold, "Bold")])

      assert text(tree) =~ "Bold"
    end

    test "an icon replaces the label, which becomes the hint instead" do
      item = MishkaToolbar.button(:bold, "Bold", icon: "B")
      tree = MishkaToolbar.toolbar(%{}, [item])

      assert text(tree) =~ "B"
      refute text(tree) =~ "Bold"
      assert MishkaToolbar.toolbar(%{hint: :bold}, [item]) |> text() =~ "Bold"
    end

    test "a link is tinted and underlined, so colour is not the only difference" do
      tree = MishkaToolbar.toolbar(%{}, [MishkaToolbar.link(:docs, "Docs")])
      label = find(tree, :text, text: "Docs")
      rule = tree |> find_all(:box) |> Enum.find(&(&1.props[:height] == 1))

      assert label.props.text_color == :primary
      assert rule.props.background == :primary
    end

    test "link_color and item_color override the ink" do
      tree =
        MishkaToolbar.toolbar(%{item_color: :on_secondary, link_color: :secondary}, [
          MishkaToolbar.button(:bold, "Bold"),
          MishkaToolbar.link(:docs, "Docs")
        ])

      assert find(tree, :text, text: "Bold").props.text_color == :on_secondary
      assert find(tree, :text, text: "Docs").props.text_color == :secondary
    end

    test "an input is a real text field carrying its placeholder and value" do
      tree = MishkaToolbar.toolbar(%{}, kinds())
      field = find(tree, :text_field)

      assert field.props.placeholder == "Find…"
      assert field.props.value == "abc"
      assert field.props.enabled == true
    end

    test "every kind renders" do
      for orientation <- [:horizontal, :vertical],
          overflow <- [:none, :scroll, :collapse] do
        assert_renderable(
          MishkaToolbar.toolbar(%{orientation: orientation, overflow: overflow}, kinds())
        )
      end
    end
  end

  describe "the four item kinds, written as tags" do
    # What the sigil makes of `<MishkaToolbarButton id={:bold} label="Bold" />`:
    # the type atom, the attributes as props, and nothing at all filled in for
    # what the caller left out. A slot tag has no module and no expander, so it
    # arrives at the parent exactly like this.
    defp tag(type, props), do: %{type: type, props: props, children: []}

    defp expanded(children, props), do: MishkaToolbar.expand(props, children, %{screen: self()})

    # Every handler the bar owns, so the equality below covers the wiring too and
    # not just the shape.
    @bar %{id: "fmt", on_select: :act, on_hold: :hold, on_input: :typed}

    defp kind_tags do
      [
        tag(:mishka_toolbar_button, %{id: :bold, label: "Bold", icon: "B"}),
        tag(:mishka_toolbar_link, %{id: :docs, label: "Docs", href: "https://mishka.tools"}),
        tag(:mishka_toolbar_separator, %{}),
        tag(:mishka_toolbar_input, %{id: :find, placeholder: "Find…", value: "abc"})
      ]
    end

    test "<MishkaToolbarButton> builds exactly what button/3 builds" do
      item = tag(:mishka_toolbar_button, %{id: :bold, label: "Bold", icon: "B", group: "Text"})
      built = MishkaToolbar.button(:bold, "Bold", icon: "B", group: "Text")

      assert expanded([item], @bar) == MishkaToolbar.toolbar(@bar, [built])
    end

    test "no <MishkaToolbarButton> marker survives expansion" do
      tree = expanded([tag(:mishka_toolbar_button, %{id: :bold, label: "Bold"})], @bar)

      # A marker that leaks reaches the renderer, which has never heard of the
      # type and draws nothing. assert_renderable will not catch it either: the
      # name is whitelisted in mix.exs so the sigil accepts the tag.
      assert find_all(tree, :mishka_toolbar_button) == []
      assert text(tree) =~ "Bold"
    end

    test "<MishkaToolbarLink> builds exactly what link/3 builds" do
      item =
        tag(:mishka_toolbar_link, %{
          id: :docs,
          label: "Docs",
          href: "https://mishka.tools",
          icon: "↗"
        })

      built = MishkaToolbar.link(:docs, "Docs", href: "https://mishka.tools", icon: "↗")

      assert expanded([item], @bar) == MishkaToolbar.toolbar(@bar, [built])
    end

    test "no <MishkaToolbarLink> marker survives expansion" do
      tree = expanded([tag(:mishka_toolbar_link, %{id: :docs, label: "Docs"})], @bar)

      assert find_all(tree, :mishka_toolbar_link) == []
      assert text(tree) =~ "Docs"
    end

    test "<MishkaToolbarInput> builds exactly what input/2 builds" do
      item =
        tag(:mishka_toolbar_input, %{id: :find, placeholder: "Find…", value: "abc", width: 90})

      built = MishkaToolbar.input(:find, placeholder: "Find…", value: "abc", width: 90)

      assert expanded([item], @bar) == MishkaToolbar.toolbar(@bar, [built])
    end

    test "no <MishkaToolbarInput> marker survives expansion" do
      tree = expanded([tag(:mishka_toolbar_input, %{id: :find, placeholder: "Find…"})], @bar)

      assert find_all(tree, :mishka_toolbar_input) == []
      assert find(tree, :text_field).props.placeholder == "Find…"
    end

    test "<MishkaToolbarSeparator> builds exactly what separator/1 builds" do
      items = [
        tag(:mishka_toolbar_button, %{id: :bold, label: "Bold", group: "Align"}),
        tag(:mishka_toolbar_separator, %{group: "Align"})
      ]

      built = [
        MishkaToolbar.button(:bold, "Bold", group: "Align"),
        MishkaToolbar.separator(group: "Align")
      ]

      assert expanded(items, @bar) == MishkaToolbar.toolbar(@bar, built)
    end

    test "no <MishkaToolbarSeparator> marker survives expansion" do
      tree = expanded([tag(:mishka_toolbar_separator, %{})], @bar)

      assert find_all(tree, :mishka_toolbar_separator) == []
      assert tree |> find_all(:box) |> Enum.find(&(&1.props[:width] == 1))
    end

    test "a whole bar of tags is the same bar of builders — tags, groups and all" do
      props = Map.merge(@bar, %{hint: :bold})

      assert expanded(kind_tags(), props) == MishkaToolbar.toolbar(props, kinds())
    end

    test "an attribute left out — or written nil — falls back to the builder's default" do
      for {item, built} <- [
            {tag(:mishka_toolbar_button, %{id: :bold, label: "Bold"}),
             MishkaToolbar.button(:bold, "Bold")},
            {tag(:mishka_toolbar_button, %{id: :bold, label: "Bold", icon: nil, group: nil}),
             MishkaToolbar.button(:bold, "Bold")},
            {tag(:mishka_toolbar_input, %{id: :find}), MishkaToolbar.input(:find)},
            {tag(:mishka_toolbar_separator, %{}), MishkaToolbar.separator()}
          ] do
        assert expanded([item], @bar) == MishkaToolbar.toolbar(@bar, [built])
      end
    end

    test "disabled={true} on a tag reaches the item, tag and handler both" do
      item = tag(:mishka_toolbar_button, %{id: :bold, label: "Bold", disabled: true})
      tree = expanded([item], @bar)

      assert tagged(tree, "fmt-bold-disabled")
      refute tagged(tree, "fmt-bold-disabled").props[:on_tap]
    end

    test "a control that is not ours still passes through a tag bar untouched" do
      tree = expanded([tag(:mishka_toolbar_separator, %{}), control("A")], @bar)

      assert text(tree) =~ "A"
    end
  end

  describe "the input is the flexible one, and only when it can be" do
    test "a horizontal strip weights it, so the buttons are measured first" do
      tree = MishkaToolbar.toolbar(%{}, kinds())
      box = tree |> find_all(:box) |> Enum.find(&(&1.props[:weight] == 1))

      assert find(box, :text_field)
    end

    test "a scrolling strip gives it a width instead — a weight has no bound to divide" do
      tree = MishkaToolbar.toolbar(%{overflow: :scroll}, kinds())

      assert tree |> find_all(:box) |> Enum.all?(&(&1.props[:weight] == nil))
      assert tree |> find_all(:box) |> Enum.find(&(&1.props[:width] == 160))
    end

    test "a vertical strip gives it a width — the main axis there is height" do
      tree = MishkaToolbar.toolbar(%{orientation: :vertical}, kinds())

      assert tree |> find_all(:box) |> Enum.all?(&(&1.props[:weight] == nil))
      assert tree |> find_all(:box) |> Enum.find(&(&1.props[:width] == 160))
    end

    test "an explicit width wins over the weight" do
      tree = MishkaToolbar.toolbar(%{}, [MishkaToolbar.input(:find, width: 90)])
      box = tree |> find_all(:box) |> Enum.find(&(&1.props[:width] == 90))

      assert find(box, :text_field)
      refute box.props[:weight]
    end
  end

  describe "test tags" do
    test "an item's tag is the toolbar's id plus its own" do
      tree = MishkaToolbar.toolbar(%{id: "fmt"}, kinds())

      assert tagged(tree, "fmt-bold")
      assert tagged(tree, "fmt-docs")
      assert tree.props.id == "fmt"
    end

    test "the input's tag is on the FIELD, because that is what a test types into" do
      tree = MishkaToolbar.toolbar(%{id: "fmt"}, kinds())

      assert tagged(tree, "fmt-find").type == :text_field
    end

    test "disabled goes into the tag — a device test can read neither ink nor a missing handler" do
      tree =
        MishkaToolbar.toolbar(%{id: "fmt"}, [
          MishkaToolbar.button(:bold, "Bold"),
          MishkaToolbar.button(:italic, "Italic", disabled: true)
        ])

      assert tagged(tree, "fmt-bold")
      assert tagged(tree, "fmt-italic-disabled")
      refute tagged(tree, "fmt-italic")
    end

    test "a disabled toolbar disables every tag, input included" do
      tree = MishkaToolbar.toolbar(%{id: "fmt", disabled: true}, kinds())

      assert tagged(tree, "fmt-bold-disabled")
      assert tagged(tree, "fmt-docs-disabled")
      assert tagged(tree, "fmt-find-disabled")
    end

    test "a group carries its label, which is the only place an aria-label survives" do
      tree =
        MishkaToolbar.toolbar(%{id: "fmt"}, [
          MishkaToolbar.button(:left, "Left", group: "Text align"),
          MishkaToolbar.button(:right, "Right", group: "Text align")
        ])

      assert tagged(tree, "fmt-group-text-align")
    end

    test "the hint, the overflow and the scroller each get one" do
      tree =
        MishkaToolbar.toolbar(
          %{id: "fmt", hint: :bold, overflow: :collapse, visible: 1},
          [MishkaToolbar.button(:bold, "Bold"), MishkaToolbar.button(:italic, "Italic")]
        )

      assert tagged(tree, "fmt-hint")
      assert tagged(tree, "fmt-overflow")

      assert MishkaToolbar.toolbar(%{id: "fmt", overflow: :scroll}, kinds())
             |> tagged("fmt-scroll")
    end

    test "no id means no tags anywhere, rather than tags reading \"nil-bold\"" do
      tree =
        MishkaToolbar.toolbar(
          %{hint: :bold, overflow: :collapse, visible: 1},
          [MishkaToolbar.button(:bold, "Bold"), MishkaToolbar.button(:italic, "Italic")]
        )

      assert tags(tree) == []
    end
  end

  describe "events" do
    test "one on_select serves the bar, and each item reports its own id" do
      tree = MishkaToolbar.toolbar(%{on_select: :act}, kinds())

      assert tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1) ==
               [{self(), {:act, :bold}}, {self(), {:act, :docs}}]
    end

    test "an input reports through on_input as a change, not a tap" do
      tree = MishkaToolbar.toolbar(%{on_input: :typed}, kinds())

      assert find(tree, :text_field).props.on_change == {self(), {:typed, :find}}
    end

    test "the overflow reports a bare tap — there is no item behind it" do
      tree =
        MishkaToolbar.toolbar(
          %{overflow: :collapse, visible: 1, on_overflow: :more, id: "fmt"},
          [MishkaToolbar.button(:bold, "Bold"), MishkaToolbar.button(:italic, "Italic")]
        )

      assert tagged(tree, "fmt-overflow").props.on_tap == {self(), :more}
    end

    test "a disabled item wires nothing, and a disabled input is not editable either" do
      tree = MishkaToolbar.toolbar(%{id: "fmt", disabled: true, on_select: :act}, kinds())

      refute tagged(tree, "fmt-bold-disabled").props[:on_tap]
      refute tagged(tree, "fmt-find-disabled").props[:on_change]
      assert tagged(tree, "fmt-find-disabled").props.enabled == false
    end

    test "a disabled item still answers a long press — that is focusable_when_disabled" do
      props = %{id: "fmt", disabled: true, on_select: :act, on_hold: :hold}
      tree = MishkaToolbar.toolbar(props, kinds())

      assert tagged(tree, "fmt-bold-disabled").props.on_long_press == {self(), {:hold, :bold}}
    end

    test "focusable_when_disabled: false takes the long press away too" do
      props = %{id: "fmt", disabled: true, on_hold: :hold, focusable_when_disabled: false}
      tree = MishkaToolbar.toolbar(props, kinds())

      refute tagged(tree, "fmt-bold-disabled").props[:on_long_press]
    end

    test "an input carries no long press — a text field consumes its own" do
      tree = MishkaToolbar.toolbar(%{id: "fmt", on_hold: :hold}, kinds())

      refute tagged(tree, "fmt-find").props[:on_long_press]
    end

    test "a bar with no handlers wires nothing at all" do
      tree = MishkaToolbar.toolbar(%{}, kinds())

      assert tree |> flatten() |> Enum.all?(&(&1.props[:on_tap] == nil))
      assert tree |> flatten() |> Enum.all?(&(&1.props[:on_long_press] == nil))
    end
  end

  describe "groups" do
    test "consecutive items sharing a group become one cluster" do
      tree =
        MishkaToolbar.toolbar(%{id: "fmt"}, [
          MishkaToolbar.button(:left, "L", group: "Align"),
          MishkaToolbar.button(:right, "R", group: "Align")
        ])

      cluster = tagged(tree, "fmt-group-align")

      assert cluster.props.background == :surface
      # fill_width={false} or the first cluster swallows the strip.
      assert cluster.props.fill_width == false
      assert text(cluster) =~ "L"
      assert text(cluster) =~ "R"
    end

    test "two labels make two clusters, and ungrouped items are not wrapped" do
      tree =
        MishkaToolbar.toolbar(%{id: "fmt"}, [
          MishkaToolbar.button(:left, "L", group: "Align"),
          MishkaToolbar.button(:list, "U", group: "Lists"),
          MishkaToolbar.button(:bold, "B")
        ])

      assert tagged(tree, "fmt-group-align")
      assert tagged(tree, "fmt-group-lists")
      refute tagged(tree, "fmt-bold").props[:background]
    end

    test "the chunking is by RUN, not by name — the web's Enum.chunk_by, exactly" do
      tree =
        MishkaToolbar.toolbar(%{id: "fmt"}, [
          MishkaToolbar.button(:left, "L", group: "Align"),
          MishkaToolbar.button(:bold, "B"),
          MishkaToolbar.button(:right, "R", group: "Align")
        ])

      clusters = tree |> flatten() |> Enum.filter(&(&1.props[:id] == "fmt-group-align"))

      assert match?([_, _], clusters)
    end

    test "group_background is overridable" do
      tree =
        MishkaToolbar.toolbar(%{id: "fmt", group_background: :on_primary}, [
          MishkaToolbar.button(:left, "L", group: "Align")
        ])

      assert tagged(tree, "fmt-group-align").props.background == :on_primary
    end

    test "a separator can live inside a group" do
      tree =
        MishkaToolbar.toolbar(%{id: "fmt"}, [
          MishkaToolbar.button(:left, "L", group: "Align"),
          MishkaToolbar.separator(group: "Align"),
          MishkaToolbar.button(:right, "R", group: "Align")
        ])

      assert tagged(tree, "fmt-group-align")
             |> find_all(:box)
             |> Enum.find(&(&1.props[:width] == 1))
    end
  end

  describe "overflow" do
    defp eight do
      for n <- 1..8, do: MishkaToolbar.button(:"b#{n}", "B#{n}")
    end

    test ":none is the web's behaviour — everything renders, nothing collapses" do
      tree = MishkaToolbar.toolbar(%{id: "fmt"}, eight())

      assert tagged(tree, "fmt-b8")
      refute tagged(tree, "fmt-overflow")
    end

    test ":scroll wraps the strip, on the toolbar's own axis" do
      horizontal = MishkaToolbar.toolbar(%{id: "fmt", overflow: :scroll}, eight())

      vertical =
        MishkaToolbar.toolbar(%{id: "fmt", overflow: :scroll, orientation: :vertical}, eight())

      assert find(horizontal, :scroll).props.axis == "horizontal"
      assert find(vertical, :scroll).props.id == "fmt-scroll"
      refute find(vertical, :scroll).props[:axis]
      assert tagged(horizontal, "fmt-b8")
    end

    test ":collapse keeps `visible` controls and hides the rest behind a ⋯" do
      tree = MishkaToolbar.toolbar(%{id: "fmt", overflow: :collapse, visible: 3}, eight())

      assert tagged(tree, "fmt-b3")
      refute tagged(tree, "fmt-b4")
      assert tagged(tree, "fmt-overflow")
    end

    test "the ⋯ appears only when something is actually hidden" do
      tree = MishkaToolbar.toolbar(%{id: "fmt", overflow: :collapse, visible: 20}, eight())

      refute tagged(tree, "fmt-overflow")
    end

    test "split/2 counts CONTROLS, so a separator does not spend a slot" do
      items = [
        MishkaToolbar.button(:a, "A"),
        MishkaToolbar.separator(),
        MishkaToolbar.button(:b, "B"),
        MishkaToolbar.button(:c, "C")
      ]

      {shown, hidden} = MishkaToolbar.split(items, 2)

      assert match?([_, _, _], shown)
      assert match?([_], hidden)
    end

    test "split/2 never ends the strip on a divider" do
      items = [
        MishkaToolbar.button(:a, "A"),
        MishkaToolbar.separator(),
        MishkaToolbar.button(:b, "B")
      ]

      {shown, _hidden} = MishkaToolbar.split(items, 1)

      assert match?([_], shown)
    end

    test "split/2 keeps one control however low `visible` goes" do
      {shown, hidden} = MishkaToolbar.split(eight(), 0)

      assert match?([_], shown)
      assert match?([_, _, _, _, _, _, _], hidden)
    end
  end

  describe "the hint — the port of hover, and of aria-label" do
    test "it prints the held item's label under the strip" do
      tree =
        MishkaToolbar.toolbar(%{id: "fmt", hint: :redo}, [
          MishkaToolbar.button(:undo, "Undo", icon: "↺"),
          MishkaToolbar.button(:redo, "Redo", icon: "↻")
        ])

      # The tag is on the Text itself, not on a Row around it, so a device test
      # reads this caption from its own node rather than asking the page whether
      # the string is somewhere on it — and the props table repeats most of the
      # prose on that page.
      assert tagged(tree, "fmt-hint").type == :text
      assert text(tagged(tree, "fmt-hint")) == "Redo"
    end

    test "an unknown id, or an item with no label, prints nothing" do
      items = [MishkaToolbar.button(:undo, "Undo", icon: "↺")]

      refute MishkaToolbar.toolbar(%{id: "fmt", hint: :nope}, items) |> tagged("fmt-hint")
      refute MishkaToolbar.toolbar(%{id: "fmt"}, items) |> tagged("fmt-hint")
    end

    test "it sits outside the scroller, so it does not slide away with the strip" do
      tree =
        MishkaToolbar.toolbar(%{id: "fmt", hint: :undo, overflow: :scroll}, [
          MishkaToolbar.button(:undo, "Undo", icon: "↺")
        ])

      refute find(tree, :scroll) |> tagged("fmt-hint")
      assert tagged(tree, "fmt-hint")
    end

    test "a collapsed-away item cannot be hinted, because it is not on screen" do
      tree =
        MishkaToolbar.toolbar(
          %{id: "fmt", hint: :b8, overflow: :collapse, visible: 2},
          eight()
        )

      refute tagged(tree, "fmt-hint")
    end
  end

  describe "href/2" do
    test "finds a link's destination by the id the tap reported" do
      assert MishkaToolbar.href(kinds(), :docs) == "https://mishka.tools"
    end

    test "a button with the same id is not a destination" do
      assert MishkaToolbar.href([MishkaToolbar.button(:docs, "Docs")], :docs) == nil
    end
  end

  test "slot_types/0 names every node the toolbar consumes" do
    types = MishkaToolbar.slot_types()

    assert Enum.map(kinds(), & &1.type) |> Enum.uniq() |> Enum.all?(&(&1 in types))
  end

  describe "the showcase page" do
    setup do
      Showcase.reset()
      Showcase.register_all()
      :ok
    end

    test "renders, and every node it emits is one the native layer can draw" do
      view = mount_screen(ComponentScreen, %{slug: :toolbar})

      assert_renderable(Mob.Composite.expand(tree(view), self()))
    end

    test "the page is written in tags, and not one marker reaches the renderer" do
      view = mount_screen(ComponentScreen, %{slug: :toolbar})
      tree = Mob.Composite.expand(tree(view), self())

      # The check assert_renderable cannot make: mix.exs whitelists these names
      # for the sigil, so a marker the toolbar failed to consume serialises
      # cleanly and simply draws nothing.
      for type <- MishkaToolbar.slot_types() do
        assert find_all(tree, type) == [], "#{type} leaked to the renderer"
      end
    end

    test "each example has its own toolbar id, so a device test can say which it touched" do
      view = mount_screen(ComponentScreen, %{slug: :toolbar})
      tree = Mob.Composite.expand(tree(view), self())

      bars = ~w(tb-own tb-kinds tb-grp tb-hint tb-off tb-mix tb-scr tb-more tb-vert)

      for bar <- bars, do: assert(tagged(tree, bar), "no toolbar tagged #{bar}")
      assert length(Enum.uniq(bars)) == length(bars)
    end

    test "holding an item names it, and the hint belongs to the bar that was held" do
      view = mount_screen(ComponentScreen, %{slug: :toolbar})
      view = render_info(view, {:tap, {:tb_hint_hold, :redo}})
      tree = Mob.Composite.expand(tree(view), self())

      assert text(tagged(tree, "tb-hint-hint")) == "Redo"
      refute tagged(tree, "tb-off-hint")
    end

    test "a disabled bar still reports a hold, and its items read as disabled" do
      view = mount_screen(ComponentScreen, %{slug: :toolbar})
      view = render_info(view, {:tap, {:tb_off_hold, :italic}})
      tree = Mob.Composite.expand(tree(view), self())

      assert text(tagged(tree, "tb-off-hint")) == "Italic"
      assert tagged(tree, "tb-off-bold-disabled")
      assert tagged(tree, "tb-mix-italic-disabled")
      assert tagged(tree, "tb-mix-bold")
    end

    test "typing in the toolbar's input reaches the screen" do
      view = mount_screen(ComponentScreen, %{slug: :toolbar})
      view = render_info(view, {:change, {:tb_kinds_type, :find}, "beam"})

      assert assigns(view).tb_kinds_query == "beam"
      assert view |> tree() |> Mob.Composite.expand(self()) |> text() =~ "Looking for beam"
    end

    test "the collapsing bar hides its tail and offers the ⋯" do
      view = mount_screen(ComponentScreen, %{slug: :toolbar})
      tree = Mob.Composite.expand(tree(view), self())

      assert tagged(tree, "tb-more-cut")
      refute tagged(tree, "tb-more-table")
      assert tagged(tree, "tb-more-overflow")
      # The scrolling bar shows the same eight, because it scrolls instead.
      assert tagged(tree, "tb-scr-table")
    end

    test "every status caption carries its own tag, so no assertion is page-wide" do
      view = mount_screen(ComponentScreen, %{slug: :toolbar})
      tree = Mob.Composite.expand(tree(view), self())

      for tag <- ~w(tb-kinds-status tb-grp-status tb-mix-status tb-more-status) do
        assert tagged(tree, tag).type == :text, "no caption tagged #{tag}"
      end
    end
  end

  describe "burger" do
    test "closed draws three bars" do
      tree = MishkaBurger.burger()
      bars = tree |> find_all(:box) |> Enum.filter(&(&1.props[:height] == 2))

      assert match?([_, _, _], bars)
    end

    test "open draws a real cross, not two bars that read as an equals sign" do
      tree = MishkaBurger.burger(opened: true)

      assert text(tree) =~ "✕"
      assert tree |> find_all(:box) |> Enum.filter(&(&1.props[:height] == 2)) == []
    end

    test "both states keep the SAME tap target, so it stays one control" do
      closed = MishkaBurger.burger(size: 44)
      open = MishkaBurger.burger(opened: true, size: 44)

      assert closed.props.width == 44
      assert open.props.width == 44
      assert closed.props.height == open.props.height
    end

    test "the handler is widened, and disabled removes it and mutes the bars" do
      assert MishkaBurger.burger(on_toggle: :nav).props.on_tap == {self(), :nav}

      off = MishkaBurger.burger(disabled: true, on_toggle: :nav)
      refute Map.has_key?(off.props, :on_tap)
      assert off |> find_all(:box) |> Enum.all?(&(&1.props[:background] in [:muted, nil]))
    end

    test "colour is overridable" do
      tree = MishkaBurger.burger(color: 0xFF7C3AED)
      bars = tree |> find_all(:box) |> Enum.filter(&(&1.props[:height] == 2))

      assert Enum.all?(bars, &(&1.props.background == 0xFF7C3AED))
    end

    test "every variant renders" do
      for props <- [%{}, %{opened: true}, %{disabled: true}, %{size: 56}] do
        assert_renderable(MishkaBurger.burger(props))
      end
    end
  end
end
