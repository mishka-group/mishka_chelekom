defmodule MishkaMob.Device.HeatmapTest do
  @moduledoc """
  Device tests for the Heatmap page: the grid lays its cells out on the declared
  number of columns, a tick is drawn inside its cell, and a tapped cell reaches
  its handler and moves what the page shows.

  The count line under the week is the readout — the tick is a glyph in a Box,
  which the host cannot read — so every tap is proved by the number moving.
  """
  use MishkaMob.DeviceCase, page: :heatmap

  test "the week's cells sit on one line, evenly sized" do
    first = frame!("hm-cell-0")
    middle = frame!("hm-cell-3")
    last = frame!("hm-cell-6")

    assert same_row?(first, last), "the week's cells are on different lines"
    assert same_row?(first, middle), "a cell left the row"

    assert first.left < middle.left and middle.left < last.left,
           "the cells are not in reading order: #{inspect({first, middle, last})}"

    assert_in_delta first.width, middle.width, 0.5
    assert_in_delta middle.width, last.width, 0.5

    assert_in_delta first.width, 16.0, 0.5, "a cell is not 16dp wide"
    assert_in_delta first.height, 16.0, 0.5, "a cell is not 16dp tall"
  end

  test "tapping a cell ticks it and the count follows" do
    assert_text("4 of 7 kept")

    tap("hm-cell-2")

    assert_eventually(fn -> "5 of 7 kept" in texts() end,
      message: "the tap never ticked the cell"
    )

    tap("hm-cell-2")

    assert_eventually(fn -> "4 of 7 kept" in texts() end,
      message: "the second tap never unticked it"
    )
  end

  test "every cell carries its own tap target" do
    for index <- 0..6 do
      assert frame!("hm-cell-#{index}"), "cell #{index} has no frame"
    end
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "A year of days",
          "A week of ticks",
          "Density and corners",
          "Props"
        ] do
      assert_text(heading)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
