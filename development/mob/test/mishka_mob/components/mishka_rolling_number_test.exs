defmodule MishkaMob.Components.MishkaRollingNumberTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaRollingNumber

  doctest MishkaMob.Components.MishkaRollingNumber

  describe "rolling number: format/2" do
    test "groups thousands from the RIGHT" do
      assert MishkaRollingNumber.format(1_234_567, ",") == "1,234,567"
      assert MishkaRollingNumber.format(1_000, ",") == "1,000"
      assert MishkaRollingNumber.format(999, ",") == "999"
      assert MishkaRollingNumber.format(0, ",") == "0"
    end

    test "keeps the sign outside the grouping" do
      assert MishkaRollingNumber.format(-1_234, ",") == "-1,234"
      assert MishkaRollingNumber.format(-999_999, ",") == "-999,999"
    end

    test "an empty separator disables grouping" do
      assert MishkaRollingNumber.format(1_234_567, "") == "1234567"
    end

    test "any separator works" do
      assert MishkaRollingNumber.format(1_234_567, " ") == "1 234 567"
      assert MishkaRollingNumber.format(1_234_567, ".") == "1.234.567"
    end
  end

  describe "rolling number: steps/3" do
    test "ends exactly on the target" do
      assert List.last(MishkaRollingNumber.steps(0, 1_284, 18)) == 1_284
      assert List.last(MishkaRollingNumber.steps(500, 10, 7)) == 10
    end

    test "eases out — early steps move further than late ones" do
      [a, b | _] = steps = MishkaRollingNumber.steps(0, 100, 10)
      last_two = Enum.take(steps, -2)

      assert b - a > Enum.at(last_two, 1) - Enum.at(last_two, 0)
    end

    test "counts down as happily as up" do
      steps = MishkaRollingNumber.steps(100, 0, 5)

      assert List.last(steps) == 0
      assert Enum.all?(steps, &(&1 <= 100))
    end

    test "a flat range yields the same value throughout" do
      assert MishkaRollingNumber.steps(5, 5, 3) == [5, 5, 5]
    end

    test "zero or fewer steps jumps straight to the target" do
      assert MishkaRollingNumber.steps(0, 9, 0) == [9]
      assert MishkaRollingNumber.steps(0, 9, -3) == [9]
    end
  end

  test "the number node renders the formatted value" do
    tree = MishkaRollingNumber.rolling_number(value: 1_234_567)

    assert tree.type == :text
    assert tree.props.text == "1,234,567"
  end

  test "expand/3 delegates to rolling_number/1" do
    assert MishkaRollingNumber.expand(%{value: 1}, [], %{screen: self()}) ==
             MishkaRollingNumber.rolling_number(value: 1)
  end

  test "every variant renders" do
    for props <- [%{}, %{value: 1_234_567}, %{value: -98_765, separator: ""}] do
      assert_renderable(MishkaRollingNumber.rolling_number(props))
    end
  end
end
