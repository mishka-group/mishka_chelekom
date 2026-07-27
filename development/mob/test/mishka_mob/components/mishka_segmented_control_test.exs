defmodule MishkaMob.Components.MishkaSegmentedControlTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaSegmentedControl, as: SC

  doctest MishkaMob.Components.MishkaSegmentedControl

  defp opts do
    [SC.option(:day, "Day"), SC.option(:week, "Week"), SC.option(:month, "Month", disabled: true)]
  end

  defp build(props),
    do: SC.segmented_control(Map.merge(%{on_change: :pick}, props), opts())

  defp track(tree), do: find(tree, :box)
  defp segments(tree), do: find(tree, :row).children

  describe "always one selected" do
    test "select/2 returns the tapped id, so it can never be cleared" do
      assert SC.select(:a, :b) == :b
      assert SC.select(:a, :a) == :a
    end

    test "an unknown or missing value falls back to the first option" do
      assert SC.selected(%{}, [%{id: :a}, %{id: :b}]) == :a
      assert SC.selected(%{value: :gone}, [%{id: :a}, %{id: :b}]) == :a
      assert SC.selected(%{value: :b}, [%{id: :a}, %{id: :b}]) == :b
    end

    test "no options yields nil rather than raising" do
      assert SC.selected(%{value: :a}, []) == nil
    end

    test "exactly one segment is filled" do
      fills = build(%{value: :week}) |> segments() |> Enum.map(& &1.props.background)

      assert Enum.count(fills, &(&1 == :primary)) == 1
      assert Enum.at(fills, 1) == :primary
    end

    test "with no value the FIRST segment is filled, never none" do
      fills = build(%{}) |> segments() |> Enum.map(& &1.props.background)

      assert Enum.at(fills, 0) == :primary
    end
  end

  describe "the track" do
    test "is one joined box holding the segments" do
      tree = build(%{})

      assert track(tree).props.background == :surface_raised
      assert track(tree).props.corner_radius == :radius_md
      assert length(segments(tree)) == 3
    end

    test "unselected segments are transparent so the track shows through" do
      fills = build(%{value: :day}) |> segments() |> Enum.map(& &1.props.background)

      assert Enum.at(fills, 1) == :transparent
    end

    test "track and selection colours are overridable" do
      tree = build(%{value: :day, background: 0xFF111827, color: 0xFF7C3AED})

      assert track(tree).props.background == 0xFF111827
      assert Enum.at(segments(tree), 0).props.background == 0xFF7C3AED
    end
  end

  describe "events" do
    test "each segment reports the same tag widened with its own id" do
      taps = build(%{value: :day}) |> segments() |> Enum.map(& &1.props[:on_tap])

      assert [{pid, {:pick, :day}}, {_, {:pick, :week}}, nil] = taps
      assert pid == self()
    end

    test "a disabled segment is inert; a disabled control cascades" do
      assert build(%{}) |> segments() |> List.last() |> get_in([Access.key(:props), :on_tap]) ==
               nil

      assert Enum.all?(segments(build(%{disabled: true})), &(&1.props[:on_tap] == nil))
    end

    test "no on_change means nothing is tappable" do
      tree = SC.segmented_control(%{value: :day}, opts())

      assert Enum.all?(segments(tree), &(&1.props[:on_tap] == nil))
    end
  end

  test "the label renders above the strip when given" do
    assert text(build(%{label: "VIEW"})) =~ "VIEW"
  end

  test "expand/3 reads segment children and ignores anything else" do
    stray = %{type: :text, props: %{text: "stray"}, children: []}
    tree = SC.expand(%{value: :day}, opts() ++ [stray], %{screen: self()})

    refute text(tree) =~ "stray"
    assert length(segments(tree)) == 3
  end

  test "every variant renders" do
    for props <- [%{}, %{value: :week}, %{disabled: true}, %{label: "V"}] do
      assert_renderable(build(props))
    end
  end
end
