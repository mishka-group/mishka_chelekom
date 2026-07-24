defmodule MishkaMob.Components.MishkaCheckboxGroupTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaCheckboxGroup, as: Group

  doctest MishkaMob.Components.MishkaCheckboxGroup

  defp items do
    [Group.item(:a, "Alpha"), Group.item(:b, "Beta"), Group.item(:c, "Gamma", disabled: true)]
  end

  defp build(props \\ %{}),
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

      assert text(tree) =~ "–"
    end

    test "renders a tick when everything is selected" do
      tree = build(%{value: [:a, :b, :c], select_all: true})

      assert text(tree) =~ "✓"
      refute text(tree) =~ "–"
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
      assert text(tree) =~ "✓"
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

  test "the group label renders when given" do
    assert text(build(%{label: "LIBRARIES"})) =~ "LIBRARIES"
  end

  test "expand/3 reads item children and ignores anything else" do
    stray = %{type: :text, props: %{text: "stray"}, children: []}
    tree = Group.expand(%{value: []}, items() ++ [stray], %{screen: self()})

    refute text(tree) =~ "stray"
    assert length(rows(tree)) == 3
  end

  test "every variant renders" do
    for props <- [%{}, %{value: [:a]}, %{select_all: true}, %{disabled: true, select_all: true}] do
      assert_renderable(build(props))
    end
  end
end
