defmodule MishkaMob.Device.ScrollerTest do
  @moduledoc """
  Device tests for the Scroller rail on the Preview Card page: a port of
  `ScrollerTest.kt`, one test per `@Test`, on the host-driven suite instead of Compose
  instrumentation.

  The point of this file is the distinction the component exists for: a rail that
  scrolls under a FINGER is the platform doing its job, and proves nothing about this
  component. What has to work is pressing the previous and next arrows: the arrows are
  the whole component, and they used to emit their tags into a handler that only counted
  them, so the rail never moved. "pressing next moves the rail" is that test.

  A scrolled rail does not move its own container; only its contents slide under it. So
  every assertion here reads a TILE's position, not the rail's.

  Run with `mix test --only device test/device/scroller_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :preview_card

  # Roughly 7dp: the 20px the Kotlin test allowed on the phone it was written for.
  @tolerance 7

  setup do
    # Bring the rail into view without scrolling to a tile: a tile's nearest scrollable
    # ancestor is the RAIL, so that would scroll the rail sideways and leave the page
    # where it was. The arrow is below the rail and outside it, so scrolling to that
    # moves the page and pulls the rail into view above it.
    scroll_into_view("gallery-next")
    :ok
  end

  test "pressing next moves the rail" do
    before = tile_x(1)

    press("gallery-next")

    # The tile slid LEFT, i.e. its x decreased: that is the rail scrolling rightwards.
    # The regression this guards is the one the component shipped with: the arrow fired
    # its tag, the handler ran, and nothing moved, because the handler only incremented
    # a counter.
    after_press = tile_x(1)

    assert after_press < before - @tolerance,
           "pressing next did not scroll the rail: tile 1 was at #{before}, now #{after_press}"
  end

  test "pressing prev brings it back" do
    start = tile_x(1)

    press("gallery-next")
    nudged = tile_x(1)
    assert nudged < start, "next did not move the rail, so prev cannot be tested"

    press("gallery-prev")

    # Back where it started. A `nudge` that only ever scrolled one way would pass the
    # test above and fail this one.
    assert abs(tile_x(1) - start) < @tolerance,
           "prev did not undo next: started #{start}, ended #{tile_x(1)}"
  end

  test "the rail stops at its left edge rather than running negative" do
    at_rest = tile_x(1)

    # A fresh page is at the left edge already. Pressing prev again must be a no-op, not
    # a scroll into negative space: nudge/3 clamps before it calls the NIF.
    press("gallery-prev")
    press("gallery-prev")

    assert abs(tile_x(1) - at_rest) < 1.5,
           "prev scrolled past the start: #{at_rest} -> #{tile_x(1)}"
  end

  test "a finger scrolls it too and the arrows agree with the finger" do
    before = tile_x(1)

    tile = frame!("gallery-tile-1")
    drag("gallery-tile-1", {-tile.width, 0})

    swiped = tile_x(1)
    assert swiped < before, "a swipe did not move the rail: #{before} -> #{swiped}"

    # Both routes drive the same native scroll state, so prev after a swipe steps back
    # from where the FINGER left it, not from some offset the handler was tracking
    # separately. That is the difference between nudging a live widget and re-rendering
    # a remembered position.
    press("gallery-prev")

    assert tile_x(1) > swiped,
           "prev did not continue from where the swipe stopped: #{swiped} -> #{tile_x(1)}"
  end

  test "the arrow reports its tap as well as scrolling" do
    before = Map.fetch!(assigns(), :pc_nudges)

    press("gallery-next")

    # The counter is the visible difference between "the arrow is dead" and "the rail is
    # already at the end and cannot move further": worth keeping precisely because a
    # nudge has nothing of its own to re-render. It is a label with no tag, so read the
    # assign that prints it.
    assert_eventually(
      fn -> Map.fetch!(assigns(), :pc_nudges) > before end,
      message: "the arrow tap was never counted (still #{before})"
    )
  end

  test "the page renders the rail and both arrows" do
    assert_shown("gallery-tile-1")

    for arrow <- ~w(gallery-prev gallery-next), do: assert_shown(arrow)

    assert_text("Scroller")
  end

  # A tile's x. Settled first: a nudge or a fling moves the rail over several frames.
  # Read unclipped: once the rail scrolls, the leading tiles sit at negative x, which is
  # the very thing these tests measure.
  defp tile_x(n), do: settled_frame("gallery-tile-#{n}").left

  defp press(tag), do: tap(tag)
end
