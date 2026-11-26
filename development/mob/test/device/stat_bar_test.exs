defmodule MishkaMob.Device.StatBarTest do
  @moduledoc """
  Device tests for the Stat Bar page: the label and the reading sit on one
  line, the bar is under them and is the declared thickness, and a clamped
  value still draws a full bar.
  """
  use MishkaMob.DeviceCase, page: :stat_bar

  test "both examples draw their labels and readings" do
    assert_text("Action")
    assert_text("52%")
    assert_text("Adventure")
    assert_text("30%")
  end

  test "a ranked row draws its rank and its name" do
    assert_text("Apocalypse Z: New World")
    assert_text("Avengers: Doomsday")
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Where the hours went",
          "A ranked row",
          "A percentage, a thin bar, no reading",
          "Props"
        ] do
      assert_text(heading)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
