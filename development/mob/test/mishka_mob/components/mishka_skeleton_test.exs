defmodule MishkaMob.Components.MishkaSkeletonTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaSkeleton

  doctest MishkaMob.Components.MishkaSkeleton

  defp bars(tree) do
    tree
    |> find_all(:box)
    |> Enum.map(& &1.props[:weight])
    |> Enum.reject(&is_nil/1)
  end

  describe "text" do
    test "is one bar per line, the last one short" do
      assert bars(MishkaSkeleton.skeleton(shape: :text, lines: 3)) == [1.0, 1.0, 0.6]
    end

    test "the short bar is followed by a spacer that takes the rest of the row" do
      # Weights, not widths: a share of the parent is the only way to express
      # this when no geometry is reported back to render/1.
      tree = MishkaSkeleton.skeleton(shape: :text, lines: 1, last_line: 0.6)

      assert [%{type: :box, props: %{weight: 0.6}}, %{type: :spacer, props: %{weight: rest}}] =
               find(tree, :row).children

      assert_in_delta rest, 0.4, 0.0001
    end

    test "a full-width last line adds no spacer at all" do
      tree = MishkaSkeleton.skeleton(shape: :text, lines: 1, last_line: 1.0)

      assert [%{type: :box, props: %{weight: 1.0}}] = find(tree, :row).children
    end

    test "lines are separated by gap, and nothing trails the last one" do
      tree = MishkaSkeleton.skeleton(shape: :text, lines: 3, gap: 14)
      gaps = tree.children |> Enum.filter(&(&1.type == :spacer)) |> Enum.map(& &1.props[:size])

      assert gaps == [14, 14]
    end

    test "height and colour are props" do
      tree = MishkaSkeleton.skeleton(shape: :text, lines: 1, height: 20, color: :primary)
      bar = find(tree, :box)

      assert bar.props.height == 20
      assert bar.props.background == :primary
    end

    test "an id numbers every bar, including the short last one" do
      # The short bar's row holds the box AND its weighted spacer, so a
      # one-child match works for the full-width rows and dies on the last —
      # which is exactly what shipped until a device test could not find it.
      ids =
        MishkaSkeleton.skeleton(shape: :text, lines: 3, id: "sk")
        |> find_all(:box)
        |> Enum.map(& &1.props[:id])

      assert ids == ["sk-0", "sk-1", "sk-2"]
    end

    test "no id leaves the bars untagged" do
      tree = MishkaSkeleton.skeleton(shape: :text, lines: 2)

      assert Enum.all?(find_all(tree, :box), &(not Map.has_key?(&1.props, :id)))
    end

    test "an impossible line count renders an empty column rather than raising" do
      tree = MishkaSkeleton.skeleton(shape: :text, lines: 0)

      assert tree.type == :column
      assert find_all(tree, :box) == []
      assert_renderable(tree)
    end

    test "last_line is clamped into 0..1" do
      assert MishkaSkeleton.shares(1, 5.0) == [1.0]
      assert MishkaSkeleton.shares(1, -2.0) == [0.0]
    end
  end

  describe "circle" do
    test "is square, with a radius of half its size" do
      node = MishkaSkeleton.skeleton(shape: :circle, size: 48)

      assert node.props.width == 48
      assert node.props.height == 48
      assert node.props.corner_radius == 24.0
    end

    test "carries an id when given one" do
      assert MishkaSkeleton.skeleton(shape: :circle, id: "avatar").props.id == "avatar"
      assert MishkaSkeleton.skeleton(width: 40, id: "block").props.id == "block"
      refute Map.has_key?(MishkaSkeleton.skeleton(shape: :circle).props, :id)
    end

    test "hugs rather than filling" do
      # A Box given neither width nor fill_width fills its parent — an avatar
      # placeholder that did that would stretch across the row.
      assert MishkaSkeleton.skeleton(shape: :circle).props.fill_width == false
    end
  end

  describe "block" do
    test "fills the width by default, because that is what a card does" do
      node = MishkaSkeleton.skeleton(height: 120)

      assert node.props.fill_width == true
      assert node.props.height == 120
      refute Map.has_key?(node.props, :width)
    end

    test "an explicit width stops it filling" do
      node = MishkaSkeleton.skeleton(width: 120, height: 60)

      assert node.props.width == 120
      assert node.props.fill_width == false
    end

    test "corner_radius overrides the shape's default" do
      assert MishkaSkeleton.skeleton(corner_radius: 0).props.corner_radius == 0
      assert MishkaSkeleton.skeleton(shape: :circle, corner_radius: 4).props.corner_radius == 4
    end
  end

  test "expand/3 delegates to skeleton/1 and ignores children" do
    children = [%{type: :text, props: %{text: "ignored"}, children: []}]

    assert MishkaSkeleton.expand(%{shape: :circle}, children, %{screen: self()}) ==
             MishkaSkeleton.skeleton(shape: :circle)
  end

  test "it wires no handlers — a placeholder is not interactive" do
    for props <- [%{}, %{shape: :text}, %{shape: :circle}] do
      tree = MishkaSkeleton.skeleton(props)
      nodes = [:box, :row, :column] |> Enum.flat_map(&find_all(tree, &1)) |> Kernel.++([tree])

      assert Enum.all?(nodes, &(not Map.has_key?(&1.props, :on_tap)))
    end
  end

  test "every variant renders" do
    for props <- [
          %{},
          %{shape: :text},
          %{shape: :text, lines: 5, last_line: 0.3},
          %{shape: :circle, size: 64},
          %{width: 200, height: 24},
          %{shape: :nonsense}
        ] do
      assert_renderable(MishkaSkeleton.skeleton(props))
    end
  end
end
