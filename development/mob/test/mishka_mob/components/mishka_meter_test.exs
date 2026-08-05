defmodule MishkaMob.Components.MishkaMeterTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaMeter, MishkaProgress}

  doctest MishkaMob.Components.MishkaMeter

  describe "fill ratio" do
    test "reads the measurement as a fraction of the range" do
      assert MishkaMeter.ratio(%{value: 72}) == 0.72
      assert MishkaMeter.ratio(%{value: 3, max: 5}) == 0.6
    end

    test "clamps instead of overshooting" do
      assert MishkaMeter.ratio(%{value: 250}) == 1.0
      assert MishkaMeter.ratio(%{value: -40}) == 0.0
    end

    test "an absent value reads empty — never indeterminate" do
      assert MishkaMeter.ratio(%{}) == 0.0
      assert MishkaMeter.ratio(%{value: nil}) == 0.0
    end

    test "an absent value falls back to min, not zero, on a shifted range" do
      assert MishkaMeter.ratio(%{min: 20, max: 40}) == 0.0
      assert MishkaMeter.ratio(%{value: 20, min: 20, max: 40}) == 0.0
      assert MishkaMeter.ratio(%{value: 40, min: 20, max: 40}) == 1.0
    end
  end

  describe "the gauge" do
    test "renders the native Progress widget with the fill ratio" do
      assert %{type: :progress, props: %{value: 0.72}} = MishkaMeter.meter(value: 72)
    end

    test "a meter with no value is an EMPTY gauge, not the animated bar" do
      node = MishkaMeter.meter()

      # the distinction that matters: Progress would omit :value and animate
      assert node.props.value == 0.0
      refute MishkaProgress.progress(%{}).props[:value] == 0.0
    end

    test "colour is passed through" do
      assert MishkaMeter.meter(value: 1, color: :primary).props.color == :primary
    end

    test "accepts a map as well as a keyword list" do
      assert MishkaMeter.meter(%{value: 40}) == MishkaMeter.meter(value: 40)
    end
  end

  describe "label and readout" do
    test "label and percentage readout" do
      tree = MishkaMeter.meter(value: 72, label: "Storage", show_value: true)

      assert text(tree) =~ "Storage"
      assert text(tree) =~ "72%"
    end

    test "value_text replaces the percentage" do
      tree = MishkaMeter.meter(value: 3, max: 5, value_text: "3 of 5 bars", show_value: true)

      assert text(tree) =~ "3 of 5 bars"
      refute text(tree) =~ "60%"
    end

    test "a valueless meter still reports a readout, unlike an indeterminate bar" do
      assert text(MishkaMeter.meter(show_value: true)) =~ "0%"
    end

    test "a bare gauge is a single node" do
      assert MishkaMeter.meter(value: 40).type == :progress
    end
  end

  describe "composite tag" do
    test "expand/3 delegates to meter/1 and ignores children" do
      children = [%{type: :text, props: %{text: "ignored"}, children: []}]

      assert MishkaMeter.expand(%{value: 40}, children, %{screen: self()}) ==
               MishkaMeter.meter(value: 40)
    end
  end

  test "every variant renders" do
    for props <- [%{}, %{value: 72}, %{value: 3, max: 5, show_value: true}, %{value: 250}] do
      assert_renderable(MishkaMeter.meter(props))
    end
  end
end
