defmodule MishkaMob.Components.MishkaRadioTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaRadio

  defp ring(tree), do: find(tree, :box)
  defp dot(tree), do: ring(tree).children |> Enum.find(&(&1.type == :box))

  describe "the indicator" do
    test "is a circle: an exact size/2 radius, so it stays round at any size" do
      assert ring(MishkaRadio.radio(size: 22)).props.corner_radius == 11.0
      assert ring(MishkaRadio.radio(size: 40)).props.corner_radius == 20.0
    end

    test "selected shows a centre dot; unselected shows none" do
      assert dot(MishkaRadio.radio(checked: true)) != nil
      assert dot(MishkaRadio.radio(checked: false)) == nil
    end

    test "the dot is round too, and scales with the size" do
      small = dot(MishkaRadio.radio(checked: true, size: 22))
      large = dot(MishkaRadio.radio(checked: true, size: 40))

      assert small.props.corner_radius == small.props.width / 2
      assert large.props.width > small.props.width
    end

    test "selection thickens and tints the ring" do
      on = ring(MishkaRadio.radio(checked: true))
      off = ring(MishkaRadio.radio(checked: false))

      assert on.props.border_width == 2
      assert on.props.border_color == :primary
      assert off.props.border_width == 1
      assert off.props.border_color == :border
    end

    test "colour is overridable" do
      tree = MishkaRadio.radio(checked: true, color: 0xFF7C3AED)

      assert ring(tree).props.border_color == 0xFF7C3AED
      assert dot(tree).props.background == 0xFF7C3AED
    end
  end

  describe "layout" do
    test "is one tappable row of indicator plus label" do
      tree = MishkaRadio.radio(label: "Pro", on_select: :pick)

      assert tree.type == :row
      assert tree.props.on_tap == {self(), :pick}
      assert text(tree) =~ "Pro"
    end

    test "no label renders no text and no gap" do
      tree = MishkaRadio.radio(checked: true)

      assert Enum.filter(tree.children, &(&1.type == :spacer)) == []
      assert find_all(tree, :text) == []
    end

    test "is never a Button" do
      assert find_all(MishkaRadio.radio(label: "x", on_select: :p), :button) == []
    end
  end

  describe "disabled" do
    test "wires no handler and mutes the label and the dot" do
      tree = MishkaRadio.radio(label: "x", checked: true, disabled: true, on_select: :p)

      refute Map.has_key?(tree.props, :on_tap)
      assert find(tree, :text, text: "x").props.text_color == :muted
      assert dot(tree).props.background == :muted
    end
  end

  test "the handler is widened, so one handler can serve a whole group" do
    assert MishkaRadio.radio(on_select: {:plan, :pro}).props.on_tap == {self(), {:plan, :pro}}
  end

  test "expand/3 delegates to radio/1" do
    assert MishkaRadio.expand(%{label: "x"}, [], %{screen: self()}) ==
             MishkaRadio.radio(label: "x")
  end

  test "every variant renders" do
    for props <- [%{}, %{label: "x"}, %{checked: true}, %{disabled: true, checked: true}] do
      assert_renderable(MishkaRadio.radio(props))
    end
  end
end
