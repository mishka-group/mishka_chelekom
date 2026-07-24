defmodule MishkaMob.Components.MishkaProgressTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaProgress

  doctest MishkaMob.Components.MishkaProgress

  defp bar(tree), do: find(tree, :progress)

  describe "range translation" do
    test "maps [min, max] onto the native 0..1 fraction" do
      assert MishkaProgress.fraction(%{value: 0}) == 0.0
      assert MishkaProgress.fraction(%{value: 50}) == 0.5
      assert MishkaProgress.fraction(%{value: 100}) == 1.0
    end

    test "honours a custom range" do
      assert MishkaProgress.fraction(%{value: 3, max: 5}) == 0.6
      assert MishkaProgress.fraction(%{value: 5, min: 5, max: 10}) == 0.0
      assert MishkaProgress.fraction(%{value: 10, min: 5, max: 10}) == 1.0
    end

    test "clamps rather than overshooting the track" do
      assert MishkaProgress.fraction(%{value: 250}) == 1.0
      assert MishkaProgress.fraction(%{value: -80}) == 0.0
    end

    test "a zero-width range reads as empty instead of dividing by zero" do
      assert MishkaProgress.fraction(%{value: 5, min: 5, max: 5}) == 0.0
    end

    test "always returns a float, even on integer boundaries" do
      assert is_float(MishkaProgress.fraction(%{value: 25}))
      assert is_float(MishkaProgress.fraction(%{value: 250}))
    end

    test "no value means indeterminate" do
      assert MishkaProgress.fraction(%{}) == nil
      assert MishkaProgress.fraction(%{value: nil}) == nil
    end
  end

  describe "the bar" do
    test "a plain determinate bar is a single native Progress node" do
      assert %{type: :progress, props: %{value: 0.4}, children: []} =
               MishkaProgress.progress(value: 40)
    end

    test "an indeterminate bar omits value entirely (that is what animates it)" do
      node = MishkaProgress.progress()

      assert node.type == :progress
      refute Map.has_key?(node.props, :value)
    end

    test "colour is passed through, and omitted when absent" do
      assert MishkaProgress.progress(value: 1, color: :primary).props.color == :primary
      refute Map.has_key?(MishkaProgress.progress(value: 1).props, :color)
    end
  end

  describe "label and readout" do
    test "a label alone renders above the bar" do
      tree = MishkaProgress.progress(value: 40, label: "Uploading")

      assert tree.type == :column
      assert text(tree) =~ "Uploading"
      assert bar(tree).props.value == 0.4
    end

    test "show_value renders a rounded percentage" do
      assert text(MishkaProgress.progress(value: 40, show_value: true)) =~ "40%"
      assert text(MishkaProgress.progress(value: 1, max: 3, show_value: true)) =~ "33%"
    end

    test "value_text overrides the percentage" do
      tree = MishkaProgress.progress(value: 3, max: 5, show_value: true, value_text: "3 of 5")

      assert text(tree) =~ "3 of 5"
      refute text(tree) =~ "60%"
    end

    test "value_text is ignored unless show_value is set" do
      refute text(MishkaProgress.progress(value: 3, value_text: "3 of 5")) =~ "3 of 5"
    end

    test "an indeterminate bar shows no readout — there is no percentage" do
      tree = MishkaProgress.progress(show_value: true, value_text: "nope", label: "Connecting")

      assert text(tree) =~ "Connecting"
      refute text(tree) =~ "nope"
      refute text(tree) =~ "%"
    end

    test "label and readout share one row, label leading" do
      tree = MishkaProgress.progress(value: 40, label: "Uploading", show_value: true)
      row = find(tree, :row)

      assert [%{props: %{text: "Uploading"}}, %{type: :spacer}, %{props: %{text: "40%"}}] =
               row.children
    end

    test "a bare bar stays a single node — no wrapper column" do
      assert MishkaProgress.progress(value: 40).type == :progress
    end
  end

  describe "composite tag" do
    test "expand/3 delegates to progress/1 and ignores children" do
      children = [%{type: :text, props: %{text: "ignored"}, children: []}]

      assert MishkaProgress.expand(%{value: 40}, children, %{screen: self()}) ==
               MishkaProgress.progress(value: 40)
    end
  end

  test "every variant renders" do
    for props <- [
          %{},
          %{value: 40},
          %{value: 40, label: "L", show_value: true},
          %{value: 3, max: 5, value_text: "3 of 5", show_value: true},
          %{value: 999}
        ] do
      assert_renderable(MishkaProgress.progress(props))
    end
  end
end
