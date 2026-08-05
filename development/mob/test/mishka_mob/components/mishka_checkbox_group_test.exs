defmodule MishkaMob.Components.MishkaCheckboxGroupTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaCheckboxGroup, as: Group

  # The checkbox mark is drawn, not typed: two canvas lines are a tick, one is a
  # dash. Counting them is how these rows report their state now.
  defp mark_lines(tree) do
    tree |> find_all(:canvas) |> Enum.map(&Enum.count(&1.props.draw, fn op -> op.op == :line end))
  end

  doctest MishkaMob.Components.MishkaCheckboxGroup

  defp items do
    [Group.item(:a, "Alpha"), Group.item(:b, "Beta"), Group.item(:c, "Gamma", disabled: true)]
  end

  defp build(props),
    do: Group.checkbox_group(Map.merge(%{on_change: :pick}, props), items())

  defp rows(tree), do: find_all(tree, :row) |> Enum.filter(&(text(&1) != ""))

  describe "toggle/2" do
    test "adds and removes, preserving order" do
      assert Group.toggle([:a], :b) == [:a, :b]
      assert Group.toggle([:a, :b], :a) == [:b]
      assert Group.toggle([], :a) == [:a]
    end
  end

  describe "select_all/2" do
    test "an empty or partial selection fills up — mixed asks to be completed" do
      assert Group.select_all([], [:a, :b]) == [:a, :b]
      assert Group.select_all([:a], [:a, :b]) == [:a, :b]
    end

    test "a full selection clears" do
      assert Group.select_all([:a, :b], [:a, :b]) == []
    end

    test "an empty group cannot be 'all selected'" do
      assert Group.select_all([], []) == []
    end
  end

  describe "parent_state/2" do
    test "none, some and all map to the three checkbox states" do
      assert Group.parent_state([], [:a, :b]) == {false, false}
      assert Group.parent_state([:a], [:a, :b]) == {false, true}
      assert Group.parent_state([:a, :b], [:a, :b]) == {true, false}
    end

    test "ids outside the group do not make it look complete" do
      assert Group.parent_state([:zzz], [:a, :b]) == {false, false}
      assert Group.parent_state([:a, :zzz], [:a, :b]) == {false, true}
    end

    test "an empty group is neither checked nor mixed" do
      assert Group.parent_state([], []) == {false, false}
    end
  end

  describe "the parent row" do
    test "is absent unless select_all is set" do
      refute text(build(%{value: [:a]})) =~ "Select all"
      assert text(build(%{value: [:a], select_all: true})) =~ "Select all"
    end

    test "renders the derived mixed state as a dash" do
      tree = build(%{value: [:a], select_all: true})

      assert 1 in mark_lines(tree)
    end

    test "renders a tick when everything is selected" do
      tree = build(%{value: [:a, :b, :c], select_all: true})

      assert 2 in mark_lines(tree)
      refute 1 in mark_lines(tree)
    end

    test "its label is overridable" do
      assert text(build(%{select_all: true, select_all_label: "Everything"})) =~ "Everything"
    end

    test "an empty group renders no parent even when asked" do
      tree = Group.checkbox_group(%{select_all: true}, [])

      refute text(tree) =~ "Select all"
    end
  end

  describe "items" do
    test "checked state follows value" do
      tree = build(%{value: [:a]})

      assert text(tree) =~ "Alpha"
      assert 2 in mark_lines(tree)
    end

    test "each row reports the same tag widened with its own id" do
      taps = build(%{value: []}) |> rows() |> Enum.map(& &1.props[:on_tap])

      assert [{pid, {:pick, :a}}, {_, {:pick, :b}}, nil] = taps
      assert pid == self()
    end

    test "a disabled item is inert while the rest work" do
      taps = build(%{}) |> rows() |> Enum.map(& &1.props[:on_tap])

      assert List.last(taps) == nil
      refute Enum.at(taps, 0) == nil
    end

    test "a disabled group cascades to every row and the parent" do
      tree = build(%{select_all: true, disabled: true})

      assert Enum.all?(rows(tree), &(&1.props[:on_tap] == nil))
    end

    test "no on_change means nothing is tappable" do
      tree = Group.checkbox_group(%{value: [:a]}, items())

      assert Enum.all?(rows(tree), &(&1.props[:on_tap] == nil))
    end
  end

  describe "row test tags" do
    # The tick and dash are DRAWN, so no row carries text saying whether it is
    # ticked. These tags are the only thing a device test can read, and it needs
    # to name ONE row, hence the composed prefix.
    test "each row's indicator is tagged <group>-<item>-<state>" do
      ids = build(%{id: "langs", value: [:a]}) |> find_all(:box) |> Enum.map(& &1.props[:id])

      assert "langs-a-checked" in ids
      assert "langs-b-empty" in ids
      assert "langs-c-empty" in ids
    end

    test "the parent is tagged too, and reports its derived tristate" do
      mixed = build(%{id: "langs", select_all: true, value: [:a]})
      full = build(%{id: "langs", select_all: true, value: [:a, :b, :c]})
      none = build(%{id: "langs", select_all: true, value: []})

      assert "langs-all-mixed" in (mixed |> find_all(:box) |> Enum.map(& &1.props[:id]))
      assert "langs-all-checked" in (full |> find_all(:box) |> Enum.map(& &1.props[:id]))
      assert "langs-all-empty" in (none |> find_all(:box) |> Enum.map(& &1.props[:id]))
    end

    test "no group id leaves every row untagged rather than inventing one" do
      ids = build(%{select_all: true, value: [:a]}) |> find_all(:box) |> Enum.map(& &1.props[:id])

      assert Enum.all?(ids, &is_nil/1)
    end
  end

  test "the group label renders when given" do
    assert text(build(%{label: "LIBRARIES"})) =~ "LIBRARIES"
  end

  describe "rows, written as tags" do
    # What the sigil makes of `<MishkaCheckboxGroupItem id={:a} label="Alpha" />`:
    # the type atom, the attributes as props, and nothing at all filled in for
    # what the caller left out. A slot tag has no module and no expander, so it
    # arrives at the group exactly like this.
    defp tag(props), do: %{type: :mishka_checkbox_group_item, props: props, children: []}

    defp expanded(children, props), do: Group.expand(props, children, %{screen: self()})

    # Both handlers and an id, so the equalities below cover the wiring and the
    # test tags too, not just the shape.
    @group %{id: "langs", value: [:a], select_all: true, on_change: :pick, on_select_all: :all}

    test "<MishkaCheckboxGroupItem> builds exactly what item/3 builds" do
      tags = [tag(%{id: :a, label: "Alpha"}), tag(%{id: :c, label: "Gamma", disabled: true})]
      built = [Group.item(:a, "Alpha"), Group.item(:c, "Gamma", disabled: true)]

      assert expanded(tags, @group) == Group.checkbox_group(@group, built)
    end

    test "an attribute left out — or written nil — falls back to the builder's default" do
      for props <- [%{id: :a, label: "Alpha"}, %{id: :a, label: "Alpha", disabled: nil}] do
        assert expanded([tag(props)], @group) ==
                 Group.checkbox_group(@group, [Group.item(:a, "Alpha")])
      end
    end

    test "no <MishkaCheckboxGroupItem> marker survives expansion" do
      tree = expanded([tag(%{id: :a, label: "Alpha"})], @group)

      # A marker that leaks reaches the renderer, which has never heard of the
      # type and draws nothing. assert_renderable will not catch it either: the
      # name is whitelisted in mix.exs, so the sigil accepts the tag.
      assert find_all(tree, :mishka_checkbox_group_item) == []
      assert text(tree) =~ "Alpha"
    end

    test "a row written as a tag is wired to the group's on_change, widened with its id" do
      taps =
        expanded([tag(%{id: :a, label: "Alpha"})], @group)
        |> rows()
        |> Enum.map(& &1.props[:on_tap])

      assert {self(), {:pick, :a}} in taps
    end

    test "slot_types/0 names every node the group consumes as a row" do
      assert Group.slot_types() == [:mishka_checkbox_group_item]
    end
  end

  test "expand/3 reads item children and ignores anything else" do
    stray = %{type: :text, props: %{text: "stray"}, children: []}
    tree = Group.expand(%{value: []}, items() ++ [stray], %{screen: self()})

    refute text(tree) =~ "stray"
    assert length(rows(tree)) == 3
  end

  test "every variant renders" do
    for props <- [%{}, %{value: [:a]}, %{select_all: true}, %{disabled: true, select_all: true}] do
      assert_renderable(build(props), extra: [:canvas])
    end
  end
end
