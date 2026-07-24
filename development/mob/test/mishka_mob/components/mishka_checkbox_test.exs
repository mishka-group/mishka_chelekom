defmodule MishkaMob.Components.MishkaCheckboxTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaCheckbox

  doctest MishkaMob.Components.MishkaCheckbox

  defp indicator(tree), do: find(tree, :box)
  defp glyph(tree), do: indicator(tree) |> find(:text) |> get_in([Access.key(:props), :text])

  describe "toggle/1 — the transition a tap should produce" do
    test "unchecked becomes checked and back" do
      assert MishkaCheckbox.toggle(%{checked: false}) == {true, false}
      assert MishkaCheckbox.toggle(%{checked: true}) == {false, false}
    end

    test "a mixed box resolves to fully checked, never to empty" do
      assert MishkaCheckbox.toggle(%{indeterminate: true}) == {true, false}
      assert MishkaCheckbox.toggle(%{indeterminate: true, checked: true}) == {true, false}
      assert MishkaCheckbox.toggle(%{indeterminate: true, checked: false}) == {true, false}
    end

    test "an empty state is treated as unchecked" do
      assert MishkaCheckbox.toggle(%{}) == {true, false}
    end
  end

  describe "the three states" do
    test "unchecked draws no glyph on a raised surface" do
      tree = MishkaCheckbox.checkbox(label: "x")

      assert glyph(tree) == ""
      assert indicator(tree).props.background == :surface_raised
    end

    test "checked fills with the accent and draws a tick" do
      tree = MishkaCheckbox.checkbox(label: "x", checked: true)

      assert glyph(tree) == "✓"
      assert indicator(tree).props.background == :primary
    end

    test "indeterminate draws a DASH, so the states differ by glyph not only colour" do
      tree = MishkaCheckbox.checkbox(label: "x", indeterminate: true)

      assert glyph(tree) == "–"
      assert indicator(tree).props.background == :primary
    end

    test "indeterminate overrides checked, matching aria-checked=mixed" do
      tree = MishkaCheckbox.checkbox(label: "x", checked: true, indeterminate: true)

      assert glyph(tree) == "–"
    end
  end

  describe "layout" do
    test "is one tappable row of indicator plus label" do
      tree = MishkaCheckbox.checkbox(label: "Remember me", on_toggle: :r)

      assert tree.type == :row
      assert tree.props.on_tap == {self(), :r}
      assert text(tree) =~ "Remember me"
    end

    test "no label renders no text and no gap" do
      tree = MishkaCheckbox.checkbox(checked: true)

      assert Enum.filter(tree.children, &(&1.type == :spacer)) == []
      assert find_all(tree, :text) |> Enum.map(& &1.props.text) == ["✓"]
    end

    test "size sets the indicator's edge" do
      assert indicator(MishkaCheckbox.checkbox(size: 30)).props.width == 30
      assert indicator(MishkaCheckbox.checkbox(size: 30)).props.height == 30
    end

    test "is never a Button" do
      assert find_all(MishkaCheckbox.checkbox(label: "x", on_toggle: :t), :button) == []
    end
  end

  describe "disabled" do
    test "wires no handler and mutes both label and glyph" do
      tree = MishkaCheckbox.checkbox(label: "x", checked: true, disabled: true, on_toggle: :t)

      refute Map.has_key?(tree.props, :on_tap)
      assert find(tree, :text, text: "x").props.text_color == :muted
      # a disabled box does not keep the accent fill
      assert indicator(tree).props.background == :surface_raised
    end
  end

  test "the handler is widened to {pid, tag}" do
    assert MishkaCheckbox.checkbox(on_toggle: {:item, :a}).props.on_tap == {self(), {:item, :a}}
  end

  test "expand/3 delegates to checkbox/1" do
    assert MishkaCheckbox.expand(%{label: "x"}, [], %{screen: self()}) ==
             MishkaCheckbox.checkbox(label: "x")
  end

  test "every variant renders" do
    for props <- [%{}, %{label: "x"}, %{checked: true}, %{indeterminate: true}, %{disabled: true}] do
      assert_renderable(MishkaCheckbox.checkbox(props))
    end
  end
end
