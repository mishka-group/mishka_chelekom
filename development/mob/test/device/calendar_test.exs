defmodule MishkaMob.Device.CalendarTest do
  @moduledoc """
  Device tests for `MishkaCalendar`: seven equal columns per week, a row per
  week, and a tapped day reporting the date it stands for.
  """
  use MishkaMob.DeviceCase, page: :calendar

  test "the grid is seven equal cells to a row" do
    a = scroll_into_view("cal-plain-2026-11-14")
    b = frame!("cal-plain-2026-11-15")
    c = frame!("cal-plain-2026-11-21")

    assert same_row?(a, b), "two days of one week are on different rows"
    assert_in_delta a.width, b.width, 1.0
    assert_in_delta a.height, b.height, 1.0

    refute same_row?(a, c), "the next week did not start a new row"
    assert c.top > a.top, "the next week is above the one it follows"
  end

  test "tapping a day reports its own date" do
    tap("cal-plain-2026-11-20")

    assert_eventually(fn -> assigns().calendar_selected == ~D[2026-11-20] end)
  end
end
