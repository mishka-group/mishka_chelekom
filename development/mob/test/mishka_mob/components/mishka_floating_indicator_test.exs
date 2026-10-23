defmodule MishkaMob.Components.MishkaFloatingIndicatorTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaFloatingIndicator

  @targets [
    %{label: "Day", value: :day},
    %{label: "Week", value: :week},
    %{label: "Month", value: :month}
  ]

  # The root Box holds the group's Row or Column, which holds the targets.
  defp group(tree), do: tree.children |> hd()
  defp targets(tree), do: group(tree).children

  describe "a horizontal group" do
    test "the targets share the row equally, so each keeps room for its label" do
      # A Box given neither a width nor a weight fills its parent. In the group's
      # Row the first target took the whole row, left Week and Month zero wide and
      # wrapped their labels a letter per line: the screenshot showed only "Day".
      tree = MishkaFloatingIndicator.floating_indicator(targets: @targets, active: :day)

      assert group(tree).type == :row
      assert [_, _, _] = targets(tree)
      assert Enum.all?(targets(tree), &(&1.props.weight == 1))
    end

    test "every target is still drawn, with its own label" do
      tree = MishkaFloatingIndicator.floating_indicator(targets: @targets, active: :day)

      assert tree |> targets() |> Enum.map(&text/1) == ["Day", "Week", "Month"]
    end

    test "the weight is on the target, where the Row reads it, not on its label" do
      tree = MishkaFloatingIndicator.floating_indicator(targets: @targets)

      for target <- targets(tree) do
        assert target.type == :box
        refute Map.has_key?(find(target, :text).props, :weight)
      end
    end

    test "weighted targets still carry their highlight and their tap" do
      tree =
        MishkaFloatingIndicator.floating_indicator(
          targets: @targets,
          active: :week,
          color: 0xFF3B82F6,
          on_change: :pick
        )

      [day, week, _month] = targets(tree)

      assert week.props.background == 0xFF3B82F6
      assert day.props.background == :transparent
      assert week.props.on_tap == {self(), {:pick, :week}}
      assert week.props.weight == 1
    end

    test "a disabled target keeps its share of the row but not its handler" do
      given = [%{label: "Day", value: :day, disabled: true} | tl(@targets)]
      tree = MishkaFloatingIndicator.floating_indicator(targets: given, on_change: :pick)

      [day, week, _month] = targets(tree)

      assert day.props.weight == 1
      refute Map.has_key?(day.props, :on_tap)
      assert Map.has_key?(week.props, :on_tap)
    end
  end

  describe "a vertical group" do
    test "stacks the targets in a column and gives none a weight" do
      # In a Column the main axis is height, so a weight would stretch each target
      # to share the column's height instead of hugging its label.
      tree =
        MishkaFloatingIndicator.floating_indicator(targets: @targets, orientation: :vertical)

      assert group(tree).type == :column
      assert [_, _, _] = targets(tree)
      assert Enum.all?(targets(tree), &(not Map.has_key?(&1.props, :weight)))
    end

    test "each target fills the column's width" do
      tree =
        MishkaFloatingIndicator.floating_indicator(targets: @targets, orientation: :vertical)

      assert Enum.all?(targets(tree), &(&1.props.fill_width == true))
    end

    test "the string form of the orientation behaves the same" do
      assert MishkaFloatingIndicator.floating_indicator(
               targets: @targets,
               orientation: "vertical"
             ) ==
               MishkaFloatingIndicator.floating_indicator(
                 targets: @targets,
                 orientation: :vertical
               )
    end
  end
end
