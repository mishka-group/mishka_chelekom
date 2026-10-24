defmodule MishkaMob.Device.MeterTest do
  @moduledoc """
  Device tests for the Meter page: a port of `MeterTest.kt`, one test per `@Test`,
  on the host-driven suite instead of Compose instrumentation.

  A meter draws no text of its own, since the gauge is a native bar, so everything
  here is asserted through the READOUT the page renders beside it from the same
  assign the buttons move. That makes each one a round trip.

  `the stored value clamps too` is the one worth keeping. `ratio/1` clamps what is
  DRAWN, so a runaway assign still shows a full gauge; the bug it catches is that
  the value behind the bar kept climbing, and coming back down then took as many
  wasted taps as had been spent going up. The bar looked right the whole time,
  which is exactly why no unit test noticed.

  The readout is read from the rendered tree: the first text on the page that is
  shaped like a percentage, which is the one the buttons are wired to.

  Run with `mix test --only device test/device/meter_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :meter

  test "the buttons move the gauge and the readout follows" do
    start = percent()

    tap("mt-up")
    assert_eventually(fn -> percent() != start end, message: "the readout never left #{start}%")
    up = percent()
    assert up > start, "Fill up went from #{start}% to #{up}%"

    tap("mt-down")
    assert_eventually(fn -> percent() != up end, message: "the readout never left #{up}%")
    assert percent() < up, "Free up did not come back down from #{up}%"
  end

  test "the stored value clamps too" do
    # Push well past the top. The gauge pins at 100 either way, and the point is
    # what happens NEXT.
    for _fill <- 1..10, do: tap("mt-up")
    assert percent() == 100, "after ten fills the readout is #{percent()}%, not 100%"

    # One tap down must move it immediately. If the assign had run past 100 behind
    # a full bar, this would still read 100.
    tap("mt-down")
    assert percent() == 88, "one tap down from full gave #{percent()}%, not 88%"
  end

  test "a custom readout replaces the percentage" do
    # Exact, not contained: the code sample carries the same words.
    assert "3 of 5 bars" in texts(), "value_text did not replace the computed readout"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "A gauge",
          "Any range",
          "Clamped, never overshooting",
          "Colour and thickness",
          "Props"
        ] do
      assert_text(heading)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
