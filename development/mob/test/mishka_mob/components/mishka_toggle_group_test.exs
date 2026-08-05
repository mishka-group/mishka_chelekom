defmodule MishkaMob.Components.MishkaToggleGroupTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  import Mob.Sigil

  alias MishkaMob.Components.MishkaToggleGroup, as: Group

  doctest MishkaMob.Components.MishkaToggleGroup

  defp items do
    [Group.item(:a, "A"), Group.item(:b, "B"), Group.item(:c, "C", disabled: true)]
  end

  defp build(props), do: Group.toggle_group(Map.merge(%{on_change: :pick}, props), items())
  defp buttons(tree), do: Enum.filter(tree.children, &(&1.type == :box))

  describe "press/3 in single mode" do
    test "pressing selects, and pressing another moves the selection" do
      assert Group.press(nil, :a, false) == :a
      assert Group.press(:a, :b, false) == :b
    end

    test "pressing the pressed button CLEARS it — the radio group difference" do
      assert Group.press(:a, :a, false) == nil
    end
  end

  describe "press/3 in multiple mode" do
    test "builds a set, preserving order" do
      assert Group.press([:a], :b, true) == [:a, :b]
      assert Group.press([], :a, true) == [:a]
    end

    test "pressing again removes" do
      assert Group.press([:a, :b], :a, true) == [:b]
      assert Group.press([:a], :a, true) == []
    end

    test "a bare value is treated as a one-element set" do
      assert Group.press(:a, :b, true) == [:a, :b]
    end
  end

  describe "pressed?/2" do
    test "works for both a bare value and a list" do
      assert Group.pressed?(:a, :a)
      refute Group.pressed?(:a, :b)
      assert Group.pressed?([:a, :b], :b)
      refute Group.pressed?([:a], :b)
      refute Group.pressed?(nil, :a)
    end
  end

  describe "rendering" do
    test "one button per item, separated by the space gap" do
      tree = build(%{space: 20})

      assert length(buttons(tree)) == 3
      assert Enum.all?(Enum.filter(tree.children, &(&1.type == :spacer)), &(&1.props.size == 20))
    end

    test "only the selected item is pressed, in single mode" do
      fills = build(%{value: :b}) |> buttons() |> Enum.map(& &1.props.background)

      assert fills == [:surface_raised, :primary, :surface_raised]
    end

    test "several are pressed in multiple mode" do
      fills =
        build(%{value: [:a, :b], multiple: true}) |> buttons() |> Enum.map(& &1.props.background)

      assert fills == [:primary, :primary, :surface_raised]
    end

    test "horizontal by default, vertical on request" do
      assert build(%{}).type == :row
      assert build(%{orientation: :vertical}).type == :column
    end

    test "each item reports the same tag widened with its own id" do
      taps = build(%{}) |> buttons() |> Enum.map(& &1.props[:on_tap])

      assert [{pid, {:pick, :a}}, {_, {:pick, :b}}, nil] = taps
      assert pid == self()
    end

    test "a disabled item is inert; a disabled group cascades" do
      assert build(%{}) |> buttons() |> List.last() |> Map.fetch!(:props) |> Map.get(:on_tap) ==
               nil

      assert Enum.all?(buttons(build(%{disabled: true})), &(&1.props[:on_tap] == nil))
    end

    test "no on_change means nothing is tappable" do
      tree = Group.toggle_group(%{value: :a}, items())

      assert Enum.all?(buttons(tree), &(&1.props[:on_tap] == nil))
    end

    test "horizontal items HUG; stacked items fill" do
      # Side by side, an item that fills takes the whole row and pushes the rest
      # off the screen. Stacked, filling is what makes the buttons a uniform
      # width instead of a ragged staircase.
      assert Enum.all?(buttons(build(%{})), &(&1.props.fill_width == false))
      assert Enum.all?(buttons(build(%{orientation: :vertical})), &(&1.props.fill_width == true))
    end

    test "the container fills by default and can be told to hug" do
      # Distinct from each ITEM's width. A group that fills cannot be wrapped in
      # a hugging track: the track stretches to the screen edge around three
      # short buttons, which is what a segmented bar must not do.
      assert build(%{}).props.fill_width == true
      assert build(%{fill_width: false}).props.fill_width == false
      assert build(%{orientation: :vertical, fill_width: false}).props.fill_width == false
    end

    test "space: 0 emits NO spacer, rather than a zero-sized one" do
      # A Spacer of size 0 is not a 0pt gap on iOS: fixedSize == 0 means "fill
      # the available space", so the buttons would be flung apart instead of
      # joined into one bar — which is the entire point of space: 0.
      joined = build(%{space: 0})

      assert Enum.filter(joined.children, &(&1.type == :spacer)) == []
      assert length(buttons(joined)) == 3
    end
  end

  describe "styling passes through to every item" do
    test "the Toggle's visual props are forwarded untouched" do
      button =
        build(%{
          value: :a,
          padding: 14,
          corner_radius: 2,
          border_width: 0,
          background: :background,
          color: 0xFF7C3AED
        })
        |> buttons()
        |> hd()

      assert button.props.padding == 14
      assert button.props.corner_radius == 2
      assert button.props.border_width == 0
      assert button.props.background == 0xFF7C3AED
    end

    test "an unstyled group leaves the Toggle's own defaults in place" do
      button = build(%{}) |> buttons() |> hd()

      assert button.props.corner_radius == :radius_md
      assert button.props.border_width == 1
    end
  end

  describe "item test tags" do
    # A pressed button differs by fill colour alone, and colour is not in the
    # accessibility tree — these tags are all a device test has to read.
    test "each item is tagged <group>-<item>-<state>" do
      ids = build(%{id: "align", value: :b}) |> buttons() |> Enum.map(& &1.props[:id])

      assert ids == ["align-a-idle", "align-b-pressed", "align-c-idle"]
    end

    test "no group id leaves every item untagged" do
      ids = build(%{value: :b}) |> buttons() |> Enum.map(& &1.props[:id])

      assert Enum.all?(ids, &is_nil/1)
    end
  end

  test "expand/3 reads item children and ignores anything else" do
    stray = %{type: :text, props: %{text: "stray"}, children: []}
    tree = Group.expand(%{value: :a}, items() ++ [stray], %{screen: self()})

    refute text(tree) =~ "stray"
    assert length(buttons(tree)) == 3
  end

  test "every variant renders" do
    for props <- [%{}, %{value: :a}, %{value: [:a], multiple: true}, %{orientation: :vertical}] do
      assert_renderable(build(props))
    end
  end

  describe "the item slot tag" do
    test "<MishkaToggleGroupItem> and item/3 name the same node" do
      from_tag = ~MOB(<MishkaToggleGroupItem id={:a} label="A" />)

      assert from_tag.type == Group.item(:a, "A").type
      assert from_tag.props.id == :a
      assert from_tag.props.label == "A"
    end

    test "a tag with no :disabled is read as enabled and wires a handler" do
      tree =
        Group.toggle_group(%{id: "g", value: :a, on_change: :pick}, [
          ~MOB(<MishkaToggleGroupItem id={:a} label="A" />),
          ~MOB(<MishkaToggleGroupItem id={:b} label="B" disabled={true} />)
        ])

      ids = tree |> flatten() |> Enum.map(& &1.props[:id]) |> Enum.reject(&is_nil/1)

      assert "g-a-pressed" in ids
      assert "g-b-idle" in ids

      taps = tree |> flatten() |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)
      assert {self(), {:pick, :a}} in taps
      refute {self(), {:pick, :b}} in taps
    end

    test "no item marker reaches the renderer" do
      tree = Group.toggle_group(%{id: "g"}, [~MOB(<MishkaToggleGroupItem id={:a} label="A" />)])

      # assert_renderable is blind to this: mix.exs whitelists the tag's name,
      # so it counts as renderable while MobBridge has no branch for it and
      # silently draws nothing.
      assert find_all(tree, :mishka_toggle_group_item) == []
      assert_renderable(tree)
    end
  end

  # The gallery page is what ToggleGroupTest.kt drives, and every bar on it is
  # now written as markup — group props and item tags alike, no builder.
  describe "the gallery page" do
    alias MishkaMob.Showcase.Components.ToggleGroup, as: Page

    setup do
      MishkaMob.Showcase.reset()
      MishkaMob.Showcase.register_all()

      :ok
    end

    defp cards do
      assigns = Page.mount(Mob.Socket.new(MishkaMob.Showcase.ComponentScreen)).assigns

      Enum.map(Page.examples(), &Mob.Composite.expand(&1.render.(assigns), self()))
    end

    test "every button the device test names is still tagged" do
      ids = cards() |> Enum.flat_map(&flatten/1) |> Enum.map(& &1.props[:id])

      # The suffix is state, and the device test taps its way through several,
      # so name the button and accept either.
      for button <- ~w(tgg-align-left tgg-align-center tgg-align-right
                       tgg-style-bold tgg-style-italic
                       tgg-view-list tgg-view-grid tgg-view-cards
                       tgg-one-right tgg-off-on tgg-off-off) do
        assert "#{button}-pressed" in ids or "#{button}-idle" in ids,
               "the #{button} button is missing"
      end
    end

    test "no item marker reaches the renderer from the page either" do
      for card <- cards() do
        assert find_all(card, :mishka_toggle_group_item) == []
      end
    end
  end
end
