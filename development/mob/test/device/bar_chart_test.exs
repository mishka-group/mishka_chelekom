defmodule MishkaMob.Device.BarChartTest do
  @moduledoc """
  Device tests for the Bar Chart page: both orientations draw their labels and
  readings, a capped list reports what it cut, and a tap on a bar reaches the
  page and shows that row's reading.

  The tap is the half only a phone can settle: the handler is registered by the
  renderer from a `{pid, {tag, key}}` prop, and whether that key survives the
  bridge is exactly what a node-tree assertion cannot see.
  """
  use MishkaMob.DeviceCase, page: :bar_chart

  test "a ranking draws its labels and readings" do
    assert_text("Action")
    assert_text("6h")
    assert_text("Adventure")
    assert_text("5h")
  end

  test "columns draw their value and their category" do
    assert_text("The same week, as columns")
    assert_text("M")
  end

  test "a capped list says how many it cut" do
    assert_text("and 4 more")
    assert_text("The Long Hollow")
  end

  test "tapping a bar shows that row's reading" do
    assert_text("Selected: none")

    tap("bc-albums-2")

    assert_text("Selected: 2")
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Where the hours went",
          "The same week, as columns",
          "A banded scale, and a ramp",
          "One bar, several colours",
          "Tap a bar and read it",
          "Props"
        ] do
      assert_text(heading)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
