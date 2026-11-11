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

  test "the week is seven equal lanes on one line" do
    first = scroll_into_view("cw-lane-1")
    second = frame!("cw-lane-2")
    seventh = frame!("cw-lane-7")

    assert same_row?(first, second), "lanes are on different lines"
    assert same_row?(second, seventh), "the last lane left the row"
    assert_in_delta first.width, second.width, 1.0
    assert_in_delta second.width, seventh.width, 1.0
    assert first.right <= second.left and second.right <= seventh.left
  end

  test "the day's rows run top to bottom in time order" do
    one = scroll_into_view("cd-row-1")
    two = frame!("cd-row-2")
    three = frame!("cd-row-3")
    four = frame!("cd-row-4")

    assert one.top < two.top and two.top < three.top and three.top < four.top,
           "day rows are out of order"

    assert_in_delta one.left, four.left, 1.0
  end

  test "agenda sections follow one another" do
    today = scroll_into_view("ca-section-today")
    tomorrow = frame!("ca-section-tomorrow")

    assert today.top < tomorrow.top, "agenda sections are out of order"
    assert_in_delta today.left, tomorrow.left, 1.0
  end

  test "a computed month reports the date of the cell it drew" do
    tap("cal-c-2026-11-20")

    assert_eventually(fn -> assigns().calendar_selected == ~D[2026-11-20] end)
  end
end
