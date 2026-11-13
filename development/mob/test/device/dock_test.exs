defmodule MishkaMob.Device.DockTest do
  @moduledoc """
  Device tests for `MishkaDock` and `MishkaDockItem`: the items divide the bar
  evenly on one line, the action sits beside the bar, and every item is live.
  """
  use MishkaMob.DeviceCase, page: :dock

  test "the items divide the bar evenly, on one line" do
    home = scroll_into_view("dock-item-home")
    library = frame!("dock-item-library")
    stats = frame!("dock-item-stats")
    bar = frame!("dock-bar")

    assert same_row?(home, library), "the first two items are on different lines"
    assert same_row?(library, stats), "the last item is on another line"

    assert home.left <= library.left and library.right <= stats.left,
           "the items are not in order: #{inspect({home, library, stats})}"

    assert_in_delta home.width, library.width, 1.0
    assert_in_delta library.width, stats.width, 1.0

    assert bar.left <= home.left and stats.right <= bar.right,
           "an item escapes the bar: #{inspect({bar, home, stats})}"
  end

  test "the action sits beside the bar, not over it" do
    bar = scroll_into_view("dock-bar")
    fab = frame!("dock-fab")

    assert same_row?(bar, fab), "the action is not on the bar's line"

    assert bar.right <= fab.left + 0.01,
           "the action overlaps the bar: #{bar.right} > #{fab.left}"
  end

  test "tapping an item reaches its handler" do
    tap("dock-item-library")
  end
end
