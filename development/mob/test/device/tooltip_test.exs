defmodule MishkaMob.Device.TooltipTest do
  @moduledoc """
  Device tests for the Tooltip page: a port of `TooltipTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  The web reveals a tooltip on hover or focus, and a phone has neither. The touch
  equivalent is a long press, the same gesture the context menu opens on, and
  `holding a control reveals its hint` is the thing the port shipped without: it had
  a bubble and no way to summon it.

  Everything here asserts on TAGS. The whole page is one scroll, every example
  renders a tooltip, and each `code:` block is a text node too, so a page-wide text
  query is answered by whichever example happens to contain the string.

  A bubble is a window of its own, over the page. A finger on another trigger while
  one is open lands in that window first, as the touch outside it that dismisses,
  exactly as for a user. Where a step needs the second trigger's hold itself to
  arrive, it is delivered with `event/2` and says so.

  Run with `mix test --only device test/device/tooltip_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :tooltip

  # The page mounts with two dismissable hints open (`dismiss-soft` and
  # `dismiss-sticky`). A dismissable bubble is a modal window: until it is gone the
  # first touch ANYWHERE outside it is the dismissal and never reaches the page,
  # exactly as for a user, and the topmost of them takes it. So a test that wants a
  # finger on the page puts the two away first, with the touch a user would use: a
  # tap in the left gutter, which belongs to neither bubble. The two tests about
  # those hints themselves do not call this.
  defp put_hints_away do
    {x, y} = gutter()

    for hint <- ~w(dismiss-sticky dismiss-soft) do
      tap_xy(x, y)
      refute_shown("#{hint}-open")
    end
  end

  # Empty page margin: no bubble or control sits at the left edge.
  defp gutter do
    page = frame!("page")

    {10.0, page.top + page.height / 2}
  end

  # A point outside `bubble` that a finger could land on: the left gutter, 120dp
  # below it, or above it when there is no room below.
  defp outside(bubble) do
    page = frame!("page")
    below = bubble.bottom + 120

    if below < page.bottom, do: {10.0, below}, else: {10.0, bubble.top - 120}
  end

  test "holding a control reveals its hint" do
    put_hints_away()
    refute shown?("tip-copy-open"), "this hint was already showing"

    hold("tip-copy-trigger")

    assert_shown("tip-copy-open")
    # The arrow's tag carries the side because a drawn triangle is not something a
    # device test can read: no text, no glyph, just a path.
    assert shown?("tip-copy-arrow-bottom"), "the hint opened without its arrow"
  end

  test "holding it again puts the hint away" do
    put_hints_away()
    hold("tip-copy-trigger")
    assert_shown("tip-copy-open")

    # The open bubble's window sits over the page, so a finger on the trigger
    # arrives as an outside touch; the hold's own handler is what is under test.
    event("tip-copy-trigger", :on_long_press)

    refute_shown("tip-copy-open")
  end

  test "holding another control moves the hint" do
    put_hints_away()
    hold("tip-copy-trigger")
    assert_shown("tip-copy-open")

    # Delivered by event, for the reason above.
    event("tip-share-trigger", :on_long_press)

    assert_shown("tip-share-open")
    refute_shown("tip-copy-open")
  end

  test "a plain tap uses the control and leaves the hint shut" do
    # The hold must not swallow the ordinary tap: the control keeps doing whatever
    # it did, which is why the trigger carries both handlers on one
    # combinedClickable rather than trading one for the other.
    #
    # Two taps, because the readout names the LAST one: a single tap would also
    # pass against a value an earlier step left behind. The second has to move it.
    put_hints_away()
    tap("tip-share-trigger")
    assert_eventually(fn -> assigns().tip_tapped == :share end)

    tap("tip-copy-trigger")

    assert_eventually(fn -> assigns().tip_tapped == :copy end)
    assert_text("tapped copy")
    refute shown?("tip-copy-open"), "a plain tap revealed the hint"
    refute shown?("tip-share-open"), "a plain tap revealed the hint"
  end

  test "every side draws the arrow that points back" do
    page = frame!("page")

    for side <- ~w(top bottom left right) do
      # The bubble floats at its trigger, so bring the trigger on screen first.
      scroll_into_view("side-#{side}-trigger")
      arrow = settled_frame("side-#{side}-arrow-#{side}")

      assert arrow.top >= page.top and arrow.bottom <= page.bottom,
             "the #{side} arrow is not on screen: #{inspect(arrow)}"
    end
  end

  test "align places the bubble without moving the trigger" do
    # All three are pinned open; what differs is where the bubble lands, which only
    # the tag can confirm is even present on the page.
    for id <- ~w(align-start align-center align-end) do
      scroll_into_view("#{id}-trigger")
      assert_shown("#{id}-open")
      assert_shown("#{id}-trigger")
    end
  end

  test "tapping the hint dismisses it" do
    assert_shown("dismiss-soft-open")

    # The sticky bubble is open too and is the topmost window, so a touch on the
    # soft one would be its outside touch. Put the sticky one away first (a tap in
    # the gutter), leaving the soft hint as the only one up.
    {x, y} = gutter()
    tap_xy(x, y)
    refute_shown("dismiss-sticky-open")
    assert_shown("dismiss-soft-open")

    tap("dismiss-soft-open")

    refute_shown("dismiss-soft-open")
    assert_shown("dismiss-soft-trigger")
  end

  test "close_on_tap false keeps the hint up until a hold" do
    assert_shown("dismiss-sticky-open")

    # With close_on_tap={false} the bubble wires no handler at all: a touch on it
    # reaches nothing, and the hint stays up.
    tap("dismiss-sticky-open", expect: :none)
    assert shown?("dismiss-sticky-open"), "close_on_tap={false} dismissed anyway"

    # The bubble is a modal window over its own trigger: a finger on the trigger
    # would arrive as the outside touch that dismisses (a different path, and not
    # the hold under test). Deliver the hold's own handler.
    event("dismiss-sticky-trigger", :on_long_press)

    refute_shown("dismiss-sticky-open")
  end

  test "a disabled tooltip never opens" do
    put_hints_away()

    # disabled drops the hold handler rather than ignoring the event, so there is
    # nothing to arrive and nothing to ignore: the touch reaches no handler.
    hold("tip-off-trigger", 650, expect: :none)

    refute_shown("tip-off-open")
    assert_shown("tip-off-trigger")
  end

  test "a closed tooltip contributes no node at all" do
    assert_shown("bare-open")
    refute shown?("bare-shut-open"), "a closed tooltip still occupied the layout"
  end

  test "styling reaches every bubble" do
    for id <- ~w(style-dark style-token style-plum) do
      scroll_into_view("#{id}-trigger")
      assert_shown("#{id}-open")
    end
  end

  test "the page renders every example" do
    for heading <- [
          "Hold to reveal",
          "Every side, with an arrow",
          "Align, and the two offsets",
          "Tap the hint to dismiss",
          "Disabled",
          "Colours, size and a static nudge",
          "Without a trigger",
          "Props"
        ] do
      assert_text(heading)
    end

    for id <- ~w(tip-copy tip-share tip-trash tip-off), do: assert_shown("#{id}-trigger")

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  # The same complaint as the preview card: an open hint could only be dismissed by
  # finding the bubble itself, which on a phone is exactly the thing the finger is
  # covering.
  test "a tap outside the bubble dismisses it" do
    put_hints_away()
    hold("tip-copy-trigger")
    bubble = settled_frame("tip-copy-open")

    # A real touch, delivered in-process to the bubble's own window the way the
    # window manager would route a finger outside it.
    {x, y} = outside(bubble)
    tap_xy(x, y)

    refute_shown("tip-copy-open")
  end
end
