defmodule MishkaMob.Components.MishkaHeatmapTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaHeatmap

  @green 0xFF4E9A73
  @grey 0xFFE7E3DC

  describe "the grid" do
    test "breaks at the declared column count" do
      grid = MishkaHeatmap.heatmap(cells: [@green, @grey, @green, @grey, @green], columns: 2)

      rows = rows(grid)
      assert length(rows) == 3
      assert Enum.map(rows, &length(&1)) == [2, 2, 1]
    end

    test "no columns puts every cell on one line" do
      grid = MishkaHeatmap.heatmap(cells: List.duplicate(@green, 7))

      assert [row] = rows(grid)
      assert length(row) == 7
    end

    test "rows are separated by the declared row gap" do
      grid = MishkaHeatmap.heatmap(cells: List.duplicate(@green, 4), columns: 2, row_gap: 9)

      assert [row, gap, row] = grid.children
      assert row.type == :row
      assert %{type: :spacer, props: %{size: 9}} = gap
    end

    test "an empty grid draws no rows" do
      assert %{type: :column, children: []} = MishkaHeatmap.heatmap(cells: [])
      assert %{type: :column, children: []} = MishkaHeatmap.heatmap()
    end
  end

  describe "a cell" do
    test "is a square of cell_size carrying its colour" do
      grid = MishkaHeatmap.heatmap(cells: [@green], cell_size: 16)

      assert [%{type: :box, props: %{width: 16, height: 16, background: @green}}] =
               rows(grid) |> hd()
    end

    test "rounds its corners only when asked" do
      square = MishkaHeatmap.heatmap(cells: [@green]) |> rows() |> hd() |> hd()
      round = MishkaHeatmap.heatmap(cells: [@green], corner_radius: 5) |> rows() |> hd() |> hd()

      refute Map.has_key?(square.props, :corner_radius)
      assert round.props.corner_radius == 5
    end

    test "a bare colour is shorthand for a cell map" do
      assert MishkaHeatmap.heatmap(cells: [@green]) ==
               MishkaHeatmap.heatmap(cells: [%{color: @green}])
    end

    test "the declared gap sits between cells, not after the last" do
      grid = MishkaHeatmap.heatmap(cells: [@green, @grey], gap: 5)

      assert [%{type: :row, children: [first, gap, last]}] =
               Enum.filter(grid.children, &(&1.type == :row))

      assert first.type == :box
      assert %{type: :spacer, props: %{size: 5}} = gap
      assert last.type == :box
    end
  end

  describe "ticks" do
    test "a ticked cell draws the default check" do
      grid = MishkaHeatmap.heatmap(cells: [%{color: @green, tick: true}])

      assert [cell] = rows(grid) |> hd()
      assert [%{type: :text, props: %{text: "✓"}}] = cell.children
    end

    test "an unticked cell carries no child" do
      grid = MishkaHeatmap.heatmap(cells: [%{color: @green}])

      assert [%{children: []}] = rows(grid) |> hd()
    end

    test "tick_size defaults to five below the cell" do
      grid =
        MishkaHeatmap.heatmap(
          cells: [%{color: @green, tick: true}],
          cell_size: 16,
          tick_color: 0xFFFBFAF8
        )

      assert [cell] = rows(grid) |> hd()

      assert [%{type: :text, props: %{text_size: 11, text_color: 0xFFFBFAF8}}] =
               cell.children
    end

    test "a node tick keeps its own type and size" do
      glyph = %{type: :text, props: %{text: "★", text_size: 9}, children: []}
      grid = MishkaHeatmap.heatmap(cells: [%{color: @green, tick: true}], tick_icon: glyph)

      assert [cell] = rows(grid) |> hd()
      assert cell.children == [glyph]
    end
  end

  describe "taps and ids" do
    test "a cell id defaults to id-index, and its own id wins" do
      grid =
        MishkaHeatmap.heatmap(
          id: "week",
          cells: [@green, %{color: @grey, id: "today"}]
        )

      assert grid.props.id == "week"
      assert [first, second] = rows(grid) |> hd()
      assert first.props.id == "week-0"
      assert second.props.id == "today"
    end

    test "an on_tap tuple is passed through untouched" do
      pid = self()
      grid = MishkaHeatmap.heatmap(cells: [%{color: @green, on_tap: {pid, :day_1}}])

      assert [%{props: %{on_tap: {^pid, :day_1}}}] = rows(grid) |> hd()
    end

    test "a bare tag is widened to this process" do
      grid = MishkaHeatmap.heatmap(cells: [%{color: @green, on_tap: :day_1}])

      assert [%{props: %{on_tap: {pid, :day_1}}}] = rows(grid) |> hd()
      assert pid == self()
    end

    test "a cell with no handler carries no on_tap prop" do
      grid = MishkaHeatmap.heatmap(cells: [@green])

      assert [%{props: props}] = rows(grid) |> hd()
      refute Map.has_key?(props, :on_tap)
    end
  end

  describe "the composite tag" do
    test "expand/3 delegates to heatmap/1 and ignores children" do
      children = [%{type: :text, props: %{text: "ignored"}, children: []}]

      assert MishkaHeatmap.expand(%{cells: [@green]}, children, %{screen: self()}) ==
               MishkaHeatmap.heatmap(cells: [@green])
    end

    test "every variant renders" do
      for props <- [
            %{},
            %{cells: [@green]},
            %{cells: [%{color: @grey, tick: true, on_tap: :day_0}], columns: 7},
            %{cells: List.duplicate(@green, 91), columns: 27, cell_size: 8}
          ] do
        assert_renderable(MishkaHeatmap.heatmap(props))
      end
    end
  end

  # The cells of each row, in order. Spacers are the grid's own gaps.
  defp rows(%{children: children}) do
    children
    |> Enum.filter(&(&1.type == :row))
    |> Enum.map(fn %{children: cells} -> Enum.reject(cells, &(&1.type == :spacer)) end)
  end
end
