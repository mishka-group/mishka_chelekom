defmodule MishkaMob.Device.SemiCircleProgressTest do
  @moduledoc """
  Device tests for the Semi Circle Progress page: a port of
  `SemiCircleProgressTest.kt`, one test per `@Test`, on the host-driven suite
  instead of Compose instrumentation.

  The arc is drawn on a canvas, which has no semantics, so these tests assert the
  two things a device CAN settle, and the arc geometry is unit-tested off the draw
  ops instead (`mishka_semi_circle_progress_test.exs`). The readout is a real Text
  stacked over the canvas: if it were painted into the canvas, nothing here could
  see it at all.

  `the value is clamped at the call site` is the one that earns its place. The
  demo used to do `sc_value + delta` with no bound, so "+ 15" walked the assign to
  147 while the arc sat at full, and then FIVE taps of "- 15" did nothing visible
  before the needle moved. Saturate, then decrement once: the readout must leave
  100%.

  Every example prints its own source, so "3 / 5" and "STEPS" are in the tree
  whether or not anything rendered. A code sample is ONE text node holding the
  whole snippet, so an exact match never hits it: every check below compares a
  whole text.

  Run with `mix test --only device test/device/semi_circle_progress_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :semi_circle_progress

  test "the gauge reports a percentage and responds to both buttons" do
    zero_the_gauge()

    tap("sc-up")
    assert_reads("15%")

    tap("sc-up")
    assert_reads("30%")

    tap("sc-down")
    assert_reads("15%")
  end

  test "the value is clamped at the call site" do
    zero_the_gauge()

    # Saturate well past the top. With the bug the assign runs to 150, and nothing
    # on screen says so.
    for _fill <- 1..10, do: tap("sc-up")
    assert_reads("100%")

    # One decrement must move the needle. Unclamped, 150 - 15 = 135, which still
    # reads 100% because only the arc's fraction was ever clamped.
    tap("sc-down")
    assert_eventually(fn -> not reads?("100%") end, message: "the readout stayed at 100%")
    assert reads?("85%"), "expected 85% after one step down from a clamped 100%"

    # And the bottom holds: one extra step below zero must stay at zero.
    zero_the_gauge()
    tap("sc-down")
    assert reads?("0%"), "the gauge went below zero"
  end

  test "value_text replaces the percentage" do
    # Rendered as exactly "3 / 5"; the printed sample is one long node.
    assert reads?("3 / 5"), "value_text did not replace the readout"
    refute reads?("60%"), "the percentage rendered alongside value_text"
  end

  test "the page renders every example and the props table" do
    for heading <- ["A gauge", "Custom readout", "Props"], do: assert_text(heading)

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  # Drive the gauge to a known 0%. Ten taps down from any value is 0, which also
  # leans on the bottom clamp.
  defp zero_the_gauge do
    for _drain <- 1..10, do: tap("sc-down")
    assert_reads("0%")
  end

  defp assert_reads(readout) do
    assert_eventually(fn -> reads?(readout) end,
      message: fn -> "no readout of #{readout} on screen (saw #{inspect(percentages())})" end
    )
  end

  defp reads?(readout), do: readout in texts()

  defp percentages, do: Enum.filter(texts(), &Regex.match?(~r/\A\d+%\z/, &1))
end
