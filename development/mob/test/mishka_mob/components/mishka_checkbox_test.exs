defmodule MishkaMob.Components.MishkaCheckboxTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaCheckbox

  doctest MishkaMob.Components.MishkaCheckbox

  defp indicator(tree), do: find(tree, :box)
  # The mark is drawn rather than typed, so "which glyph" is "how many lines":
  # two for a tick, one for a dash, none for a clear box. Keeping the old names
  # lets the state tests below go on reading as prose.
  defp glyph(tree) do
    case indicator(tree) |> find_all(:canvas) do
      [] -> nil
      [canvas] -> lines(canvas)
    end
  end

  defp lines(canvas) do
    case Enum.count(canvas.props.draw, &(&1.op == :line)) do
      2 -> "✓"
      1 -> "–"
      _ -> nil
    end
  end

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

      # An unchecked box draws nothing at all, rather than an empty glyph.
      assert glyph(tree) == nil
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
      # No label means no Text anywhere: the mark itself is drawn, not typed.
      assert find_all(tree, :text) == []
      assert glyph(tree) == "✓"
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
      assert_renderable(MishkaCheckbox.checkbox(props), extra: [:canvas])
    end
  end

  describe "the mark is drawn, not typed" do
    test "a tick is two canvas lines, sized to the box" do
      tree = MishkaCheckbox.checkbox(label: "x", checked: true, size: 22)
      canvas = find(tree, :canvas)

      assert canvas.props.width == 22
      assert canvas.props.height == 22
      assert [%{op: :line}, %{op: :line}] = canvas.props.draw
    end

    test "a mixed box is one line, and a clear box has no canvas at all" do
      mixed = MishkaCheckbox.checkbox(label: "x", indeterminate: true, size: 22)
      clear = MishkaCheckbox.checkbox(label: "x", size: 22)

      assert [%{op: :line}] = find(mixed, :canvas).props.draw
      assert find_all(clear, :canvas) == []
    end

    test "every coordinate stays inside the box, at every size" do
      # Regression: the mark was a "✓" Text, and a text glyph sits on its
      # baseline with descent space beneath — so it rode high and looked
      # off-centre, worst at small sizes. Drawn lines have no metrics.
      for size <- [14, 16, 22, 26, 40] do
        tree = MishkaCheckbox.checkbox(label: "x", checked: true, size: size)
        canvas = find(tree, :canvas)

        for %{x1: x1, y1: y1, x2: x2, y2: y2} <- canvas.props.draw do
          for coord <- [x1, y1, x2, y2] do
            assert coord > 0 and coord < size
          end
        end
      end
    end

    test "the mark is centred by construction — the tick spans the middle" do
      tree = MishkaCheckbox.checkbox(label: "x", checked: true, size: 100)
      [a, b] = find(tree, :canvas).props.draw

      # Left end left of centre, right end right of centre, and the elbow below
      # both — the shape of a tick rather than a slash.
      assert a.x1 < 50 and b.x2 > 50
      assert a.y2 > a.y1 and b.y2 < b.y1
    end
  end
end
