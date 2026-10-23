defmodule MishkaMob.Device.FloatingWindowTest do
  @moduledoc """
  Device tests for the Floating Window page: a port of `FloatingWindowTest.kt`, one
  test per `@Test`, on the host-driven suite instead of Compose instrumentation.

  The component's whole claim is that it DRAGS, and that claim is only worth anything
  on a device: the moduledoc used to say "Mob delivers no pointer coordinates to
  render/1, so the drag cannot be ported", which was false all along (`on_drag` is a
  registered handler and a `:canvas` carries it). "dragging the title bar moves the
  window" settles it, with a real gesture and the window's frame measured before and
  after.

  Everything here asserts on TAGS, never on page text. All the examples render into one
  scrolling page and the code samples are text nodes too. The position is in a tag for
  the same reason: an offset is no more readable to a device test than a colour is.

  Run with `mix test --only device test/device/floating_window_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :floating_window

  test "dragging the title bar moves the window" do
    scroll_into_view("win-window")
    before = frame!("win-window")

    swipe(title_bar("win-window"), plus(title_bar("win-window"), 40))

    assert_eventually(
      fn -> frame!("win-window").left > before.left + 30 end,
      message: fn ->
        "dragging right did not move the window: #{before.left} -> #{frame!("win-window").left}"
      end
    )

    # The readout carries the position in its tag, because a device test can read
    # neither an offset nor the text of the right example.
    refute shown?("win-pos-20-12"), "the window reports the position it started at"
  end

  test "a drag that starts below the title bar moves nothing" do
    scroll_into_view("win-window")
    panel = frame!("win-window")

    # The drag surface covers the whole stage (it must, to be a stable ruler), so
    # without the handle test every touch anywhere would teleport the window to the
    # finger.
    from = {panel.left + panel.width * 0.3, panel.bottom - panel.height * 0.1}
    swipe(from, plus(from, 40))

    assert shown?("win-pos-20-12"), "a drag that began in the body moved the window anyway"
    assert frame!("win-window").left == panel.left
  end

  test "the handle says when it is being dragged" do
    scroll_into_view("win-window")
    assert_shown("win-handle")

    {x, y} = title_bar("win-window")
    node = device!()
    assert :ok = Mob.Test.press_down_xy(node, x, y)

    try do
      # data-dragging on the web; here it has to be in the tag, because the only other
      # place the state shows is the strip's colour.
      sync()
      assert_shown("win-handle-dragging")

      assert :ok = Mob.Test.press_move_xy(node, x + 20, y)
      sync()
    after
      Mob.Test.press_up_xy(node, x + 20, y)
      sync()
    end

    assert_shown("win-handle")
    refute_shown("win-handle-dragging")
  end

  test "an arrow moves the window one step" do
    assert_shown("step-pos-0-0")

    tap("step-nudge-right")

    # step is 20, and it is read from the window's own props: it used to be a
    # documented prop that nothing read.
    assert_shown("step-pos-20-0")

    tap("step-nudge-down")
    assert_shown("step-pos-20-20")

    tap("step-nudge-up")
    tap("step-nudge-left")
    assert_shown("step-pos-0-0")
  end

  test "the arrows stop at the stage edge" do
    assert_shown("step-pos-0-0")

    # A 240 stage and a 200 window: two steps of 20 reach the edge, and every tap after
    # that must do nothing. Clamping to the stage instead of the stage MINUS the window
    # would let it walk most of the way out.
    for _press <- 1..5, do: tap("step-nudge-right")

    assert_shown("step-pos-40-0")
  end

  test "the close button hides the window and reopening brings it back" do
    assert shown?("closable-window"), "the window was not open to begin with"

    tap("closable-close")

    refute_shown("closable-window")

    tap("closable-open")
    assert_shown("closable-window")
  end

  test "a window with no drag surface still takes taps in its body" do
    # Reopening clears the counter, so this starts from a known number.
    tap("closable-open")
    assert_shown("closable-pings-0")

    tap("closable-ping")

    # The body sits above the drag surface where there is one, and this window has
    # none at all: no on_move, no canvas.
    assert_shown("closable-pings-1")
  end

  test "a drag surface exists only where the window can move" do
    assert shown?("win-drag") and shown?("step-drag"),
           "a window with on_move and bounds has no drag surface"

    refute shown?("closable-drag") or shown?("custom-drag"),
           "a window with no on_move laid a drag surface over its own body"
  end

  test "arrows appear only when something is listening for them" do
    assert shown?("step-nudge-up") and shown?("step-nudge-down"),
           "the arrows are missing from the window that wired on_move"

    # show_nudges: false on the first window, and no on_move at all on the last two:
    # an arrow nobody listens to is a control that renders perfectly and does nothing.
    refute shown?("win-nudge-up"), "show_nudges: false still drew the arrows"

    refute shown?("closable-nudge-up") or shown?("custom-nudge-up"),
           "arrows were drawn for a window with no on_move"
  end

  test "the arrows are full touch targets" do
    scroll_into_view("step-nudge-left")

    # Measured against the window's own width: that window is 200dp wide and an arrow
    # is 48dp, so the ratio is the same figure at any density. The old arrows were 4dp
    # of padding round a glyph, about 20dp of target, which is a miss more often than a
    # tap.
    window = frame!("step-window").width

    for direction <- ~w(left up down right) do
      arrow = frame!("step-nudge-#{direction}")

      assert arrow.width > window * 0.2,
             "the #{direction} arrow is #{arrow.width}dp of a #{window}dp window, under 48dp"

      assert arrow.height >= arrow.width - 1, "the #{direction} arrow is not square"
    end
  end

  test "the page renders every example" do
    for heading <- [
          "Drag it by the title bar",
          "Nudge, for precision",
          "A window that closes",
          "Its own title bar",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every window is laid out, not just described by the tree.
    for id <- ~w(win step closable custom), do: assert_shown("#{id}-window")
  end

  # A point inside a window's title bar: the top 48dp of the panel, and the only band
  # that starts a drag. Taken as a fraction of the panel, so it holds at any density:
  # 15% down a 100dp window is inside a 48dp bar.
  defp title_bar(window) do
    panel = frame!(window)

    {panel.left + panel.width * 0.3, panel.top + panel.height * 0.15}
  end

  defp plus({x, y}, dx), do: {x + dx, y}
end
