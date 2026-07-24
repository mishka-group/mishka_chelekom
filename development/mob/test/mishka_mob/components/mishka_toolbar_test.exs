defmodule MishkaMob.Components.MishkaToolbarTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaBurger, MishkaToolbar}

  defp control(label), do: %{type: :text, props: %{text: label}, children: []}

  defp items, do: [control("A"), MishkaToolbar.separator(), control("B")]

  describe "the strip" do
    test "is a bounded box holding a row" do
      tree = MishkaToolbar.toolbar(%{}, items())

      assert tree.type == :box
      assert tree.props.background == :surface_raised
      assert tree.props.corner_radius == :radius_md
      assert find(tree, :row)
    end

    test "vertical lays the controls in a column and does not fill width" do
      tree = MishkaToolbar.toolbar(%{orientation: :vertical}, items())

      assert find(tree, :column)
      refute tree.props.fill_width == true
    end

    test "space sets the gap" do
      tree = MishkaToolbar.toolbar(%{space: 20}, items())
      gaps = find(tree, :row).children |> Enum.filter(&(&1.type == :spacer))

      assert Enum.all?(gaps, &(&1.props.size == 20))
    end

    test "chrome is overridable" do
      tree =
        MishkaToolbar.toolbar(%{background: 0xFF111827, corner_radius: 4, padding: 2}, items())

      assert tree.props.background == 0xFF111827
      assert tree.props.corner_radius == 4
      assert tree.props.padding == 2
    end
  end

  describe "the separator follows the toolbar's axis" do
    test "horizontal gets a vertical hairline" do
      tree = MishkaToolbar.toolbar(%{}, items())
      line = tree |> find_all(:box) |> Enum.find(&(&1.props[:width] == 1))

      assert line.props.height == 22
    end

    test "vertical gets a horizontal rule" do
      tree = MishkaToolbar.toolbar(%{orientation: :vertical}, items())
      line = tree |> find_all(:box) |> Enum.find(&(&1.props[:height] == 1))

      assert line.props.fill_width == true
    end
  end

  test "controls pass through untouched — the toolbar invents no button type" do
    tree = MishkaToolbar.toolbar(%{}, items())

    assert text(tree) =~ "A"
    assert text(tree) =~ "B"
  end

  test "expand/3 uses the tag's children" do
    assert MishkaToolbar.expand(%{}, items(), %{screen: self()}) ==
             MishkaToolbar.toolbar(%{}, items())
  end

  describe "burger" do
    test "closed draws three bars" do
      tree = MishkaBurger.burger()
      bars = tree |> find_all(:box) |> Enum.filter(&(&1.props[:height] == 2))

      assert length(bars) == 3
    end

    test "open draws a real cross, not two bars that read as an equals sign" do
      tree = MishkaBurger.burger(opened: true)

      assert text(tree) =~ "✕"
      assert tree |> find_all(:box) |> Enum.filter(&(&1.props[:height] == 2)) == []
    end

    test "both states keep the SAME tap target, so it stays one control" do
      closed = MishkaBurger.burger(size: 44)
      open = MishkaBurger.burger(opened: true, size: 44)

      assert closed.props.width == 44
      assert open.props.width == 44
      assert closed.props.height == open.props.height
    end

    test "the handler is widened, and disabled removes it and mutes the bars" do
      assert MishkaBurger.burger(on_toggle: :nav).props.on_tap == {self(), :nav}

      off = MishkaBurger.burger(disabled: true, on_toggle: :nav)
      refute Map.has_key?(off.props, :on_tap)
      assert off |> find_all(:box) |> Enum.all?(&(&1.props[:background] in [:muted, nil]))
    end

    test "colour is overridable" do
      tree = MishkaBurger.burger(color: 0xFF7C3AED)
      bars = tree |> find_all(:box) |> Enum.filter(&(&1.props[:height] == 2))

      assert Enum.all?(bars, &(&1.props.background == 0xFF7C3AED))
    end

    test "every variant renders" do
      for props <- [%{}, %{opened: true}, %{disabled: true}, %{size: 56}] do
        assert_renderable(MishkaBurger.burger(props))
      end
    end
  end
end
