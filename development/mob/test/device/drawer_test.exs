defmodule MishkaMob.Device.DrawerTest do
  @moduledoc """
  Device tests for the Drawer page: a port of `DrawerTest.kt`, one test per `@Test`,
  on the host-driven suite instead of Compose instrumentation.

  The web drawer is a gesture-driven sheet (swipe to dismiss, snap points, a drag
  handle) and none of that is readable from text. Every assertion is on a tag: the
  page renders nine drawers into one scrolling tree, and the code samples are text
  nodes too.

  The state with no text at all rides in the tags. `<id>-panel` says the drawer is
  open, and `sheet-snap-<n>` says which snap point is active, since a height cannot be
  attributed to a snap point without it.

  Gesture distances are fractions of the screen rather than constants, so they mean
  the same on any density; the component's thresholds are in dp.

  Run with `mix test --only device test/device/drawer_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :drawer

  @examples ~w(side size sheet head skin chrome locked bare edge)

  test "a trigger opens the drawer and the close button shuts it" do
    refute shown?("side"), "the drawer was already open"

    tap("side-open-right")
    assert_shown("side-panel")

    # The root tag is the open signal: a closed drawer renders nothing at all, so
    # there is no colour or glyph to read instead.
    assert shown?("side"), "the panel rendered without its overlay root"

    tap("side-close")
    refute_shown("side-panel")
    refute_shown("side")
  end

  test "each side anchors the panel to its own edge" do
    screen = screen()

    open("side", "side-open-left")
    left = settled_frame("side-panel")
    assert left.left < 4, "a left drawer did not start at the left edge: #{left.left}"
    close("side")

    open("side", "side-open-right")
    right = settled_frame("side-panel")

    assert right.right > screen.width - 4,
           "a right drawer did not reach the right edge: #{right.right} of #{screen.width}"

    assert right.left > left.left + 20, "both sides rendered in the same place"
    close("side")

    open("side", "side-open-bottom")
    bottom = settled_frame("side-panel")

    # The system navigation bar sits below the app's content, so a sheet flush with the
    # bottom edge stops short of the window's bottom by exactly that inset.
    floor = screen.height - screen.safe_area.bottom

    assert bottom.bottom > floor - 4,
           "a bottom sheet floated off its edge: #{bottom.bottom} of #{floor}"

    # A sheet fills the width and hugs its content height. The Android renderer needs a
    # Column for that: a Box wraps its content there, and collapsed the sheet to
    # content WIDTH instead.
    assert bottom.width > screen.width - 4, "the sheet did not fill the width"
    assert bottom.height < screen.height / 2, "the sheet filled the height"
  end

  test "size changes the panel width" do
    open("size", "size-open-xs")
    small = settled_frame("size-panel").width
    close("size")

    open("size", "size-open-xl")
    large = settled_frame("size-panel").width

    # 240dp against 384dp: a 1.6x span no rounding can blur.
    assert large > small * 1.4, "size did not change the panel width: #{small} -> #{large}"
  end

  test "a backdrop tap dismisses" do
    open("head")
    panel = settled_frame("head-panel")

    # Aim beside the panel, not at the scrim's centre: the scrim spans the whole screen
    # and its middle is underneath the panel.
    tap_xy(panel.left / 2, screen().height / 2)

    refute_shown("head-panel")
  end

  test "an undismissable drawer ignores the backdrop" do
    open("locked")
    panel = settled_frame("locked-panel")

    # The inert scrim still absorbs the tap (it reaches the screen's catch-all), which
    # is why this tap is not retried as a drop: it is delivered and must change nothing.
    tap_xy(screen().width / 2, panel.top / 2)

    assert shown?("locked-panel"), "dismissible={false} was dismissed by the backdrop"

    # ...and the drawer's own exit still works, which is the only way out it has.
    tap("locked-done")
    refute_shown("locked-panel")
  end

  test "without a scrim there is no backdrop" do
    open("bare")

    assert shown?("bare-panel"), "the panel is missing"
    refute shown?("bare-scrim"), "scrim={false} still rendered a backdrop"

    # Every other drawer has one, so this is a property of the prop rather than of the
    # tag never being emitted at all.
    close("bare")
    open("head")
    assert shown?("head-scrim"), "a default drawer lost its backdrop"
  end

  test "the header parts are addressable and header false drops them" do
    open("head")

    for part <- ~w(head-title head-description head-close head-scrim) do
      assert shown?(part), "expected a node tagged #{part}"
    end

    close("head")
    open("chrome")

    assert shown?("chrome-panel"), "the custom-chrome drawer did not open"
    refute shown?("chrome-close"), "header={false} still rendered the built-in close"
    refute shown?("chrome-title"), "header={false} still rendered the built-in title"
  end

  test "dragging the handle down steps one snap point" do
    park_sheet(3)
    tall = settled_frame("sheet-panel").height

    drag("sheet-handle", {0, step()})

    assert_snap(2)

    assert settled_frame("sheet-panel").height < tall - 20,
           "the snap tag moved but the sheet did not shrink"
  end

  test "snap sequential moves one point per flick however far the finger goes" do
    park_sheet(3)

    # Far enough to clear every point at once, and to land below the smallest, which is
    # where a non-sequential sheet would fly off.
    drag("sheet-handle", {0, settled_frame("sheet-panel").height * 0.9})

    assert_snap(2)
    assert shown?("sheet-panel"), "a long flick dismissed a sheet above its smallest point"
  end

  test "dragging the handle up grows the sheet" do
    park_sheet(1)
    short = settled_frame("sheet-panel").height

    drag("sheet-handle", {0, -step()})

    assert_snap(2)
    assert settled_frame("sheet-panel").height > short + 20, "the sheet did not grow"
  end

  test "a short drag leaves the sheet where it was" do
    park_sheet(2)
    height = settled_frame("sheet-panel").height

    # Past touch slop, well under the 48dp threshold.
    drag("sheet-handle", {0, 20})

    assert_snap(2)
    assert abs(settled_frame("sheet-panel").height - height) < 3, "a nudge resized the sheet"
  end

  test "swiping the sheet off dismisses it" do
    park_sheet(1)

    # From the smallest point, a drag below it is a dismissal: 80% of the sheet's own
    # height, so the gesture stays on screen.
    drag("sheet-handle", {0, settled_frame("sheet-panel").height * 0.8})

    refute_shown("sheet-panel")
    refute_shown("sheet")
  end

  test "a sideways drag does not dismiss a bottom sheet" do
    park_sheet(2)

    # swipe_direction follows the side, so a bottom sheet reads y only.
    drag("sheet-handle", {reach(), 0})

    assert shown?("sheet-panel"), "a horizontal drag dismissed a vertical sheet"
    assert shown?("sheet-snap-2"), "a horizontal drag moved the snap point"
  end

  test "the edge swipe area opens a closed drawer" do
    refute shown?("edge-panel"), "the edge drawer was already open"
    # It is the one part of a CLOSED drawer that draws anything.
    assert_shown("edge-swipe-area")

    drag("edge-swipe-area", {reach(), 0})

    assert_shown("edge-panel")
    refute_shown("edge-swipe-area")

    # And the handle takes it back out the way it came in: one fold serves both
    # directions. Drag to the screen edge rather than by a constant, so the gesture
    # cannot run off the window on a narrow device.
    {handle_x, _y} = center(frame!("edge-handle"))
    drag("edge-handle", {-(handle_x - 8), 0})
    refute_shown("edge-panel")
  end

  test "a drag along the edge does not open it" do
    refute shown?("edge-panel"), "the edge drawer was already open"
    assert_shown("edge-swipe-area")

    # Along the edge, not across it. The outward direction cannot be tested here: the
    # patch is 16dp from the screen edge, so a drag away from the drawer immediately
    # leaves the window and its samples are dropped, which would pass whatever the
    # component did. A drag on the other AXIS is a real gesture that must still be
    # ignored.
    drag("edge-swipe-area", {0, step()})

    refute shown?("edge-panel"), "a drag along the edge opened the drawer"
    assert shown?("edge-swipe-area"), "the swipe area went away without opening anything"
  end

  test "the page renders every example" do
    for heading <- [
          "A trigger, and any side",
          "Panel width",
          "Bottom sheet",
          "Title, description",
          "Custom colours",
          "Custom chrome",
          "Undismissable",
          "Swipe in from the edge",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every example has its opener laid out, and no drawer is open on a fresh page.
    for id <- ~w(side-open-right size-open-md sheet-open head-open skin-open chrome-open
                 locked-open bare-open edge-open) do
      assert_shown(id)
    end

    for id <- @examples, do: refute(shown?("#{id}-panel"), "#{id} was open on a fresh page")
  end

  # The window the device reports: width and height in dp, and the insets.
  defp screen, do: Mob.Test.screen_info(device!())

  # Roughly 125dp of vertical travel: past the sheet's 48dp threshold, inside one snap
  # step (the points are 180, 300 and 440dp).
  defp step, do: screen().height * 0.15

  # Roughly 150dp sideways, which clears the 64dp default threshold on any density.
  defp reach, do: screen().width * 0.4

  # Opens an example from `trigger` (default: its `<id>-open` button) and waits for it.
  defp open(id, trigger \\ nil) do
    tap(trigger || "#{id}-open")
    # Settled, since a tap aimed into the panel next must not land on a panel in flight.
    settled_frame("#{id}-panel")
  end

  defp close(id) do
    # header={false} means no close button: that drawer carries its own way out, which
    # is the whole point of the example.
    tap(if(id == "chrome", do: "chrome-signout", else: "#{id}-close"))
    refute_shown("#{id}-panel")
  end

  # Which snap point the sheet is parked on is a tag, and only one is ever there.
  defp assert_snap(index), do: assert_shown("sheet-snap-#{index}")

  # Opens the sheet and parks it on a snap point. A fresh page opens it on the middle
  # one (300dp), so this is at most one flick, and never a downward drag from the
  # smallest point, which would dismiss it.
  defp park_sheet(index) do
    open("sheet")
    assert_snap(2)

    cond do
      index > 2 -> drag("sheet-handle", {0, -step()})
      index < 2 -> drag("sheet-handle", {0, step()})
      true -> :ok
    end

    assert_snap(index)
  end
end
