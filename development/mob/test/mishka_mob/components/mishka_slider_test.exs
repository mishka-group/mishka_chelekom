defmodule MishkaMob.Components.MishkaSliderTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaSlider

  doctest MishkaMob.Components.MishkaSlider

  describe "snap/2 — stepping the widget cannot do itself" do
    test "rounds to the nearest step" do
      assert MishkaSlider.snap(42.7, step: 5) == 45
      assert MishkaSlider.snap(42.0, step: 5) == 40
      assert MishkaSlider.snap(42.7, step: 10) == 40
      assert MishkaSlider.snap(45.1, step: 10) == 50
    end

    test "snaps relative to min, so a shifted range lands inside it" do
      # 5..25 by 5 must produce 5,10,15,20,25 — not multiples of 5 from zero
      # that happen to miss the range's own grid
      assert MishkaSlider.snap(11.0, step: 5, min: 5, max: 25) == 10
      assert MishkaSlider.snap(13.0, step: 5, min: 5, max: 25) == 15

      # a range whose min is not a multiple of the step still steps from min
      assert MishkaSlider.snap(4.0, step: 3, min: 1, max: 10) == 4
      assert MishkaSlider.snap(5.0, step: 3, min: 1, max: 10) == 4
    end

    test "clamps into the range" do
      assert MishkaSlider.snap(999.0, step: 5) == 100
      assert MishkaSlider.snap(-40.0, step: 5) == 0
      assert MishkaSlider.snap(999.0, step: 1, min: 1, max: 5) == 5
    end

    test "without a step it only clamps" do
      assert MishkaSlider.snap(42.7, []) == 42.7
      assert MishkaSlider.snap(120.0, []) == 100
    end

    test "a zero or negative step is ignored rather than dividing by zero" do
      assert MishkaSlider.snap(42.7, step: 0) == 42.7
      assert MishkaSlider.snap(42.7, step: -5) == 42.7
    end
  end

  describe "the track" do
    test "is the native Slider carrying an explicit range" do
      node = MishkaSlider.slider(value: 40)

      assert node.type == :slider
      # max must be explicit — the bridge defaults it to 1.0, not 100
      assert node.props.min == 0
      assert node.props.max == 100
      assert node.props.value == 40
    end

    test "value defaults to min, not zero, on a shifted range" do
      assert MishkaSlider.slider(min: 5, max: 25).props.value == 5
    end

    test "colour is passed through and omitted when absent" do
      assert MishkaSlider.slider(value: 1, color: :primary).props.color == :primary
      refute Map.has_key?(MishkaSlider.slider(value: 1).props, :color)
    end

    test "the handler is widened to {pid, tag}" do
      assert MishkaSlider.slider(value: 1, on_change: :vol).props.on_change == {self(), :vol}
    end

    test "no handler means the prop is omitted entirely" do
      refute Map.has_key?(MishkaSlider.slider(value: 1).props, :on_change)
    end
  end

  describe "label and readout" do
    test "a bare slider is a single node" do
      assert MishkaSlider.slider(value: 40).type == :slider
    end

    test "a label wraps it in a column" do
      tree = MishkaSlider.slider(value: 40, label: "Volume")

      assert tree.type == :column
      assert text(tree) =~ "Volume"
      assert find(tree, :slider).props.value == 40
    end

    test "show_value renders the rounded value" do
      assert text(MishkaSlider.slider(value: 40.6, show_value: true)) =~ "41"
    end

    test "value_text overrides the number" do
      tree = MishkaSlider.slider(value: 3, max: 5, show_value: true, value_text: "★★★")

      assert text(tree) =~ "★★★"
      refute text(tree) =~ "3"
    end

    test "value_text is ignored unless show_value is set" do
      refute text(MishkaSlider.slider(value: 3, value_text: "★★★")) =~ "★★★"
    end
  end

  describe "composite tag" do
    test "expand/3 delegates to slider/1 and ignores children" do
      children = [%{type: :text, props: %{text: "ignored"}, children: []}]

      assert MishkaSlider.expand(%{value: 40}, children, %{screen: self()}) ==
               MishkaSlider.slider(value: 40)
    end
  end

  test "every variant renders" do
    for props <- [
          %{},
          %{value: 40},
          %{value: 40, label: "L", show_value: true},
          %{value: 3, min: 1, max: 5, value_text: "★★★", show_value: true}
        ] do
      assert_renderable(MishkaSlider.slider(props))
    end
  end
end
