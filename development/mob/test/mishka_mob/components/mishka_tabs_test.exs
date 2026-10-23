defmodule MishkaMob.Components.MishkaTabsTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaTabs

  defp panel(text), do: [%{type: :text, props: %{text: text}, children: []}]

  defp three do
    [
      MishkaTabs.tab(:a, "Overview", panel("A body")),
      MishkaTabs.tab(:b, "Specs", panel("B body")),
      MishkaTabs.tab(:c, "Locked", panel("C body"), disabled: true)
    ]
  end

  defp build(props \\ %{}), do: MishkaTabs.tabs(Map.merge(%{on_change: :pick}, props), three())

  # The strip is a horizontal Scroll wrapping the Row of triggers — a Row cannot
  # wrap, so without the Scroll the fifth tab is drawn off-screen for good.
  defp strip(tree), do: hd(tree.children)
  defp row(tree), do: strip(tree) |> Map.fetch!(:children) |> hd()
  defp triggers(tree), do: Enum.filter(row(tree).children, &(&1.type == :column))

  describe "active selection" do
    test "defaults to the first tab" do
      assert MishkaTabs.active(%{}, [%{id: :a}, %{id: :b}]) == :a
    end

    test "a stale or unknown id falls back to the first tab, never an empty panel" do
      assert MishkaTabs.active(%{active: :gone}, [%{id: :a}, %{id: :b}]) == :a
      assert MishkaTabs.active(%{active: nil}, [%{id: :a}]) == :a
    end

    test "an id that exists is honoured" do
      assert MishkaTabs.active(%{active: :b}, [%{id: :a}, %{id: :b}]) == :b
    end

    test "no tabs at all yields nil rather than raising" do
      assert MishkaTabs.active(%{active: :a}, []) == nil
    end
  end

  describe "panels" do
    test "only the active tab's panel renders" do
      tree = build(%{active: :b})

      assert text(tree) =~ "B body"
      refute text(tree) =~ "A body"
      refute text(tree) =~ "C body"
    end

    test "switching the active id switches the panel" do
      assert text(build(%{active: :a})) =~ "A body"
      assert text(build(%{active: :b})) =~ "B body"
    end

    test "every tab label is always visible" do
      tree = build(%{active: :a})

      for label <- ["Overview", "Specs", "Locked"], do: assert(text(tree) =~ label)
    end

    test "a tab with an empty panel renders no panel column" do
      tree = MishkaTabs.tabs(%{}, [MishkaTabs.tab(:a, "Only", [])])

      # just the strip
      assert [_] = tree.children
    end
  end

  test "a tagged strip whose active tab has no panel renders, without a panel tag" do
    tree = MishkaTabs.tabs(%{id: "tb"}, [MishkaTabs.tab(:a, "Only", [])])

    assert [_strip] = tree.children
    assert Enum.all?(flatten(tree), &(&1.props[:id] != "tb-panel"))
  end

  describe "the strip" do
    test "one trigger per tab, separated by the space gap" do
      tree = build()

      assert [_, _, _] = triggers(tree)
      spacers = Enum.filter(strip(tree).children, &(&1.type == :spacer))
      assert Enum.all?(spacers, &(&1.props.size == 18))

      assert Enum.all?(
               Enum.filter(strip(build(%{space: 30})).children, &(&1.type == :spacer)),
               &(&1.props.size == 30)
             )
    end

    test "triggers are tappable columns, never Buttons (a Button boxes its label)" do
      assert find_all(build(), :button) == []
    end

    test "each tap carries its own tab id" do
      taps = Enum.map(triggers(build()), & &1.props[:on_tap])

      assert [{pid, {:pick, :a}}, {_, {:pick, :b}}, nil] = taps
      assert pid == self()
    end

    test "a disabled tab wires no handler and renders muted" do
      tree = build()

      assert List.last(triggers(tree)).props[:on_tap] == nil
      assert find(tree, :text, text: "Locked").props.text_color == :muted
    end

    test "no on_change means no tab is tappable" do
      tree = MishkaTabs.tabs(%{}, three())

      assert Enum.all?(triggers(tree), &(&1.props[:on_tap] == nil))
    end
  end

  describe "the indicator" do
    test "underlines only the active tab" do
      tree = build(%{active: :b})
      underlines = Enum.map(triggers(tree), fn t -> Enum.any?(t.children, &(&1.type == :box)) end)

      assert underlines == [false, true, false]
    end

    test "indicator: false drops it, but the active label keeps its colour" do
      tree = build(%{active: :b, indicator: false})

      assert find_all(tree, :box) == []
      assert find(tree, :text, text: "Specs").props.text_color == :primary
    end

    test "colour tints the active label and its underline" do
      tree = build(%{active: :a, color: 0xFF7C3AED})

      assert find(tree, :text, text: "Overview").props.text_color == 0xFF7C3AED
      assert find(tree, :box).props.background == 0xFF7C3AED
    end

    test "inactive labels use the normal surface colour" do
      assert find(build(%{active: :a}), :text, text: "Specs").props.text_color == :on_surface
    end
  end

  describe "the underline" do
    # The underline used to be a `fill_width` Box under the label. Inside the
    # horizontal Scroll that Box is measured against an unbounded width and comes
    # out ZERO wide, so no tab ever showed an underline; inside a plain Row it is
    # measured against everything the Row has left and the first tab swallows the
    # strip. It is now the colour of a wrapper showing through its bottom padding.
    test "is a hugging wrapper around the active label, so it is exactly as wide as the text" do
      tree = build(%{active: :b})
      [idle_a, active, _locked] = triggers(tree)
      [wrapper] = active.children

      assert wrapper.type == :box
      assert wrapper.props.fill_width == false
      assert wrapper.props.background == :primary
      assert wrapper.props.padding_bottom == 2
      refute Map.has_key?(wrapper.props, :height)
      refute Map.has_key?(wrapper.props, :width)
      assert [%{type: :text, props: %{text: "Specs"}}] = wrapper.children
      assert [%{type: :text}] = idle_a.children
    end

    test "nothing in the strip fills the width, in the Scroll or in a plain Row" do
      for props <- [%{active: :b}, %{active: :b, scrollable: false}] do
        tree = build(props)

        assert strip(tree)
               |> flatten()
               |> Enum.reject(&(&1 == strip(tree)))
               |> Enum.filter(&(&1.props[:fill_width] == true)) == []
      end
    end

    test "the active label is painted in the backdrop colour, which is what leaves the rule showing" do
      label = fn props -> find(build(props), :text, text: "Specs") end

      assert label.(%{active: :b}).props.background == :surface
      assert label.(%{active: :b, backdrop: :background}).props.background == :background
      assert label.(%{active: :b, backdrop: 0xFF111827}).props.background == 0xFF111827
    end

    test "only the active label is painted, so an idle tab draws nothing behind its text" do
      tree = build(%{active: :b})

      assert [idle, _active, locked] = triggers(tree) |> Enum.map(&find(&1, :text))
      refute Map.has_key?(idle.props, :background)
      refute Map.has_key?(locked.props, :background)
    end

    test "no indicator means nothing is painted either" do
      tree = build(%{active: :b, indicator: false})

      assert find_all(tree, :box) == []
      assert tree |> flatten() |> Enum.filter(&Map.has_key?(&1.props, :background)) == []
    end

    test "every tab is the same height, so choosing one does not move the strip" do
      # The active label keeps 6 below it inside a wrapper that adds 2; every
      # other label pads its own bottom by the same 8.
      tree = build(%{active: :b})
      [idle, active, locked] = triggers(tree)
      [wrapper] = active.children

      assert hd(idle.children).props.padding_bottom == 8
      assert hd(locked.children).props.padding_bottom == 8
      assert hd(wrapper.children).props.padding_bottom + wrapper.props.padding_bottom == 8
    end

    test "without an indicator every label reserves only the gap" do
      tree = build(%{active: :b, indicator: false})

      for trigger <- triggers(tree) do
        assert hd(trigger.children).props.padding_bottom == 6
      end
    end

    test "the underline follows the active tab, and only it" do
      for active <- [:a, :b] do
        tree = build(%{active: active})

        assert [%{props: %{text: label}}] =
                 tree |> find_all(:box) |> Enum.flat_map(& &1.children)

        assert label == %{a: "Overview", b: "Specs"}[active]
      end
    end

    test "scrollable: false puts the same triggers in a filling Row" do
      tree = build(%{active: :a, scrollable: false})

      assert strip(tree).type == :row
      assert [_, _, _] = Enum.filter(strip(tree).children, &(&1.type == :column))
      assert [wrapper] = find_all(tree, :box)
      assert wrapper.props.fill_width == false
    end

    test "ids and taps survive the wrapper, because they sit on the trigger column" do
      tree = build(%{id: "tb", active: :b})

      assert [%{props: %{id: "tb-tab-b-active", on_tap: {_, {:pick, :b}}}}] =
               tree |> triggers() |> Enum.filter(&(&1.props.id == "tb-tab-b-active"))
    end
  end

  describe "the active tab is visibly different" do
    # The default theme's primary is close to its text colour, so the colour
    # alone left the active tab looking like the rest. Only the one that was
    # given an accent colour (the violet example) was visibly active.
    test "the active label is semibold and no other label is" do
      tree = build(%{active: :b})

      assert find(tree, :text, text: "Specs").props.font_weight == :semibold
      refute Map.has_key?(find(tree, :text, text: "Overview").props, :font_weight)
      refute Map.has_key?(find(tree, :text, text: "Locked").props, :font_weight)
    end

    test "it stays semibold with the indicator off" do
      tree = build(%{active: :b, indicator: false})

      assert find(tree, :text, text: "Specs").props.font_weight == :semibold
    end

    test "colour, weight and underline all move together when the active tab changes" do
      for {active, label} <- [a: "Overview", b: "Specs"] do
        tree = build(%{active: active, color: 0xFF7C3AED})
        text = find(tree, :text, text: label)

        assert text.props.text_color == 0xFF7C3AED
        assert text.props.font_weight == :semibold
        assert find(tree, :box).props.background == 0xFF7C3AED
      end
    end
  end

  describe "composite tag" do
    test "expand/3 reads :mishka_tab children and ignores anything else" do
      stray = %{type: :text, props: %{text: "stray"}, children: []}
      tree = MishkaTabs.expand(%{on_change: :pick}, three() ++ [stray], %{screen: self()})

      assert [_, _, _] = triggers(tree)
      refute text(tree) =~ "stray"
    end
  end

  test "every variant renders" do
    for props <- [%{}, %{active: :b}, %{indicator: false}, %{color: :primary, space: 4}] do
      assert_renderable(build(props))
    end
  end

  describe "the strip scrolls" do
    test "it is a horizontal Scroll, so tabs past the edge can still be reached" do
      tree = build()

      assert strip(tree).type == :scroll
      assert strip(tree).props.axis == "horizontal"
      assert row(tree).type == :row

      # The inner Row must NOT fill: a fill_width Row inside a horizontal Scroll
      # is pinned to the viewport and there is nothing left to scroll.
      refute Map.get(row(tree).props, :fill_width)
    end

    test "scrollable: false gives back a plain filling Row" do
      tree = build(%{scrollable: false})

      assert strip(tree).type == :row
      assert strip(tree).props.fill_width
    end

    test "a strip with many tabs still renders every trigger" do
      many = for i <- 1..9, do: MishkaTabs.tab(:"t#{i}", "Tab #{i}", panel("body #{i}"))
      tree = MishkaTabs.tabs(%{on_change: :pick}, many)

      assert Enum.map(triggers(tree), &text/1) == Enum.map(1..9, &"Tab #{&1}")
    end
  end

  describe "ids" do
    test "fold the state into the tag, because colour is not in the tree" do
      tree = build(%{id: "tb", active: :b})

      tags = triggers(tree) |> Enum.map(& &1.props[:id])
      assert tags == ["tb-tab-a-idle", "tb-tab-b-active", "tb-tab-c-disabled"]

      assert MishkaTabs.tab_id("tb", :b, :active) == "tb-tab-b-active"
      assert MishkaTabs.strip_id("tb") == "tb-strip"
      assert MishkaTabs.panel_id("tb") == "tb-panel"
    end

    test "tag the strip and the panel too" do
      tree = build(%{id: "tb"})

      assert strip(tree).props.id == "tb-strip"
      assert List.last(tree.children).props.id == "tb-panel"
    end

    test "no id, no tags anywhere" do
      tree = build()

      refute Map.has_key?(strip(tree).props, :id)
      assert Enum.all?(triggers(tree), &(not Map.has_key?(&1.props, :id)))
    end
  end
end
