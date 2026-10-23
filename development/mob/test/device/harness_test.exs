defmodule MishkaMob.Device.HarnessTest do
  @moduledoc """
  The device suite's own checks: that the harness reports what it should and that
  its pacing does not lose taps. Run with the rest of the suite
  (`mix test --only device`); a failure here means a failure elsewhere is the
  harness, not the component.
  """
  use MishkaMob.DeviceCase, page: :popover

  @toggles 40

  # The race this suite exists to survive. Event handles carry their render
  # generation and native drops a tap sent with a stale one. `settle` alone lost 12
  # of 30 rapid taps; with the native barrier none are lost. `retry: 0` switches the
  # one-retry safety net off, so a single drop fails the test instead of being papered
  # over.
  test "rapid toggles lose no tap" do
    dropped_before = stats().retried

    for round <- 1..@toggles do
      open? = rem(round, 2) == 1
      tap(if(open?, do: "pop-trigger-closed", else: "pop-trigger-open"), retry: 0)

      assert Map.fetch!(assigns(), :pop_details) == open?,
             "toggle #{round} left the popover #{if open?, do: "closed", else: "open"}"
    end

    assert stats().retried == dropped_before
  end

  test "a tap that reaches nothing delivers no event" do
    # The gutter at the very left of the page has no handler under it.
    {_x, y} = "pop-trigger-closed" |> frame!() |> center()

    assert [] = tap_xy(1.0, y, expect: :none)
    refute_shown("pop-panel")
  end

  # The bug: scrollInfo reported viewport_w equal to viewport_h, so a scroll view
  # always read as a square.
  test "scroll_info reports the viewport's own width and height" do
    %{viewport: {width, height}, content: {content_w, content_h}} =
      Mob.Test.scroll_info(device!(), "page")

    assert width > 0 and height > 0
    assert width != height, "viewport width and height are the same number: #{width}"
    assert content_w == width, "a vertical scroll is as wide as its viewport"
    assert content_h > height, "the page should scroll"
  end

  # The bug: scrollInfo read Compose state off the main thread and, racing a layout,
  # threw "Reading a state that was created after the snapshot was taken", which took
  # the app down. Hammer it while the page is moving.
  test "scroll_info survives being read while the page scrolls" do
    node = device!()

    reader =
      Task.async(fn ->
        for _read <- 1..60, do: Mob.Test.scroll_info(node, "page")
      end)

    {_x, y} = center(frame!("page"))
    swipe({100.0, y + 150}, {100.0, y - 150})
    swipe({100.0, y - 150}, {100.0, y + 150})

    assert reader |> Task.await(10_000) |> Enum.all?(&is_map/1)
    assert Map.has_key?(Mob.Test.scroll_info(node, "page"), :offset), "the app is still answering"
  end

  # The bug: a node that left the composition kept its frame, so "is the panel gone"
  # read the last place it was.
  test "a frame goes when its node leaves the screen" do
    tap("pop-trigger-closed")
    assert_shown("pop-panel")

    tap("pop-close")

    refute_shown("pop-panel")
    refute Map.has_key?(frames(), "pop-panel"), "the closed panel's frame outlived it"
  end

  test "the native barrier answers with the screen's geometry" do
    info = Mob.Test.screen_info(device!())

    assert info.width > 0 and info.height > info.width
    assert info.scale > 1
    assert Map.has_key?(info.safe_area, :top)
  end

  test "fresh_page puts a page back to the top, in the default theme" do
    scroll_page(:bottom)
    :rpc.call(device!(), Mob.State, :put, [:theme, :light])

    fresh_page(:popover)

    assert %{offset: {+0.0, +0.0}} = Mob.Test.scroll_info(device!(), "page")
    assert :rpc.call(device!(), Mob.State, :get, [:theme]) == :dark
    refute_shown("pop-panel")
  end
end
