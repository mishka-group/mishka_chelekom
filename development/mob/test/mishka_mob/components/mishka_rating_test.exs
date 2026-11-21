defmodule MishkaMob.Components.MishkaRatingTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaRating, as: Rating

  defp texts(tree), do: tree |> find_all(:text) |> Enum.map(& &1.props[:text])
  defp count(tree, glyph), do: Enum.count(texts(tree), &(&1 == glyph))
  # The row's children alternate cell, gap, cell, …
  defp cells(tree), do: Enum.take_every(tree.children, 2)

  describe "the value" do
    test "whole stars split into full and empty" do
      tree = Rating.rating(value: 3)

      assert count(tree, "★") == 3
      assert count(tree, "☆") == 2
    end

    test "0 is five empty cells, not an empty row" do
      tree = Rating.rating(value: 0)

      assert count(tree, "★") == 0
      assert count(tree, "☆") == 5
    end

    test "a fraction below a half draws no half" do
      tree = Rating.rating(value: 3.4)

      assert count(tree, "★") == 3
      assert count(tree, "☆") == 2
      assert find(tree, :box, clip_width: 0.5) == nil
    end

    test "half: false keeps the row whole" do
      tree = Rating.rating(value: 3.5, half: false)

      assert count(tree, "★") == 3
      assert find(tree, :box, clip_width: 0.5) == nil
    end
  end

  describe "the default ink" do
    # An atom that is neither a theme token nor a palette colour reaches native
    # as a string: iOS draws it fully transparent, Android in the fallback text
    # colour. The original default (:warning) was one.
    test "is a colour mob resolves" do
      drawable = Map.keys(Mob.Renderer.colors()) ++ Map.keys(Map.from_struct(%Mob.Theme{}))

      inks = Rating.rating(value: 2.5) |> find_all(:text) |> Enum.map(& &1.props[:text_color])

      assert [_ | _] = inks
      assert Enum.reject(inks, &(&1 in drawable)) == []
    end
  end

  describe "the half star" do
    test "is the empty glyph with a filled one clipped over it" do
      tree = Rating.rating(value: 3.5)
      clip = find(tree, :box, clip_width: 0.5)

      assert %{type: :box} = clip
      assert [full] = find_all(clip, :text)
      assert full.props.text == "★"

      half = Enum.at(cells(tree), 3)
      assert [%{type: :text, props: %{text: "☆"}}, ^clip] = half.children
    end

    test "the overlay hugs the filled glyph, so the 50% cut is the middle of its advance" do
      # clip_width is a fraction of the overlay's own width. A fixed width would
      # put the cut at half of that width instead, wherever the glyph sits.
      clip = find(Rating.rating(value: 3.5, size: 22), :box, clip_width: 0.5)

      assert clip.props.fill_width == false
      refute Map.has_key?(clip.props, :width)
      refute Map.has_key?(clip.props, :height)
    end

    test "the half cell centres the empty glyph and the overlay, and hugs them" do
      # Start-aligned (mob's box default on both platforms), the overlay sits at
      # the cell's leading edge and its cut misses the empty star's centre.
      half = Enum.at(cells(Rating.rating(value: 3.5, size: 22)), 3)

      assert half.props == %{fill_width: false, align: "center"}
    end

    test "the overlay hugs a node icon too" do
      icon = %{type: :text, props: %{text: "X"}, children: []}
      clip = find(Rating.rating(value: 0.5, icon: icon), :box, clip_width: 0.5)

      assert clip.children == [icon]
      refute Map.has_key?(clip.props, :width)
    end
  end

  describe "cells" do
    test "no cell has a fixed width or height, at any size" do
      # `size` is a text size (sp on Android, times text_scale): a cell `size`
      # dp wide would cut the glyph at a large font scale.
      for size <- [14, 22, 40] do
        tree = Rating.rating(value: 2.5, size: size)

        for cell <- cells(tree) do
          assert cell.type == :box
          assert cell.props.fill_width == false
          refute Map.has_key?(cell.props, :width)
          refute Map.has_key?(cell.props, :height)
        end

        refute Enum.any?(find_all(tree, :box), &(&1.props[:width] == size))
      end
    end

    test "a list-of-nodes icon stays inside its one cell" do
      empty = [
        %{type: :text, props: %{text: "O"}, children: []},
        %{type: :text, props: %{text: "o"}, children: []}
      ]

      tree = Rating.rating(value: 0, empty_icon: empty, gap: 4)

      assert [_, _, _, _, _] = cells = cells(tree)
      assert Enum.all?(cells, &(&1.children == empty))
    end
  end

  describe "geometry" do
    test "count sets how many cells" do
      assert count(Rating.rating(value: 7, count: 10), "★") == 7
    end

    test "gap is a declared spacer between cells" do
      tree = Rating.rating(value: 2, gap: 4)

      assert tree |> find_all(:box) |> Enum.count(&(&1.props[:width] == 4)) == 4
    end

    test "a string icon is drawn at size" do
      tree = Rating.rating(value: 1, size: 30)

      assert [full | _rest] = find_all(tree, :text)
      assert full.props.text_size == 30
    end
  end

  describe "icons" do
    test "a node replaces the string glyph" do
      icon = %{type: :text, props: %{text: "X"}, children: []}
      empty = %{type: :text, props: %{text: "O"}, children: []}

      tree = Rating.rating(value: 1, icon: icon, empty_icon: empty)

      assert texts(tree) == ["X", "O", "O", "O", "O"]
    end

    test "a list of nodes is used as given" do
      empty = [%{type: :text, props: %{text: "O"}, children: []}]

      tree = Rating.rating(value: 0, empty_icon: empty)

      assert count(tree, "O") == 5
    end
  end

  test "id is a testTag on the row" do
    assert Rating.rating(value: 3, id: "rating").props.id == "rating"
  end

  test "renders" do
    assert_renderable(Rating.rating(value: 3.5))
  end
end
