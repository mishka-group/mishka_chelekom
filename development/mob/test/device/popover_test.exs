defmodule MishkaMob.Device.PopoverTest do
  @moduledoc """
  Device tests for the Popover page: a port of `PopoverTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  Every assertion reads an element by its tag rather than by page text, for the
  reason the Kotlin suite found: the page is one eagerly rendered tree, one example
  is a popover pinned open, and every code sample is text too. The trigger's open
  state rides in its tag (`-trigger-open` / `-trigger-closed`) because the only
  other thing that says so is its fill.

  Run with `mix test --only device test/device/popover_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :popover

  # Every interactive example on the page, by the id it was given.
  @examples ~w(pop hold above beside aligned)

  test "tapping the trigger opens the panel" do
    refute_shown("pop-panel")

    tap("pop-trigger-closed")

    assert_shown("pop-panel")
    assert_shown("pop-trigger-open")
    refute_shown("pop-trigger-closed")
  end

  test "the panel carries its title, description and beak" do
    tap("pop-trigger-closed")
    assert_shown("pop-panel")

    # The web wires these through aria-labelledby / aria-describedby. Mob exposes
    # no accessibility semantics, so they are rendered instead, each with its own tag.
    assert_shown("pop-title")
    assert_shown("pop-desc")
    assert_shown("pop-arrow")
  end

  test "the footer close puts it away" do
    tap("pop-trigger-closed")
    assert_shown("pop-close")

    # The close button is in the panel's own window; the touch is routed there.
    tap("pop-close")

    refute_shown("pop-panel")
    assert_shown("pop-trigger-closed")
  end

  test "a long press opens it too" do
    refute_shown("hold-panel")

    # open_on_hold is the port of open_on_hover: a phone has no pointer to rest on
    # something, and a long press is what it has instead.
    hold("hold-trigger-closed")

    assert_shown("hold-panel")
  end

  test "a long press only ever opens" do
    hold("hold-trigger-closed")
    assert_shown("hold-panel")

    # A hover never toggled, so neither does this. The open panel is a modal
    # window, so a real finger on the trigger would reach it as an outside touch
    # and dismiss: the handler's own payload is what is under test, so deliver it.
    event("hold-trigger-open", :on_long_press)
    assert_shown("hold-panel")
    assert Map.fetch!(assigns(), :pop_hold), "a second hold closed the panel"

    # The tap is the toggle, and the long press did not swallow it.
    tap("hold-trigger-open")
    refute_shown("hold-panel")
  end

  test "side top puts the panel above its trigger" do
    tap("above-trigger-closed")

    panel = settled_frame("above-panel")
    trigger = frame!("above-trigger-open")

    assert panel.bottom <= trigger.top,
           "side={:top} did not lift the panel above its trigger: " <>
             "trigger=#{inspect(trigger)} panel=#{inspect(panel)}"
  end

  # The whole point of the change, stated as geometry. "Which side it takes" holds
  # `above` and `beside` in one Column. When the panel was a sibling in that Column,
  # opening either one pushed the other down the page by the panel's height. A
  # floating panel cannot move it at all.
  test "opening a panel does not move the sibling below it" do
    # Both triggers on screen first, so that tapping the upper one scrolls nothing.
    scroll_into_view("above-trigger-closed")
    before = frame!("beside-trigger-closed")

    tap("above-trigger-closed")
    panel = settled_frame("above-panel")
    after_open = frame!("beside-trigger-closed")

    assert abs(before.top - after_open.top) <= 1,
           "opening a popover displaced its sibling: #{inspect(before)} -> #{inspect(after_open)}. " <>
             "The panel is in flow."

    # And the panel is real, not merely absent: it has area.
    assert panel.width > 0 and panel.height > 0
  end

  # Reported by the user: an open panel "comes with us in scroll". The position
  # clamp ran unconditionally, so once the trigger had scrolled off the top the panel
  # was dragged back inside the window and followed the reader down the page.
  test "the panel leaves the screen with its trigger" do
    tap("pop-trigger-closed")
    settled_frame("pop-panel")

    # Scroll the PAGE, not the panel, which is in its own window.
    scroll_page(:bottom)

    trigger = frame!("pop-trigger-open")

    assert trigger.top < -100,
           "the page did not scroll far enough to prove anything: trigger=#{inspect(trigger)}"

    # The popup follows its anchor asynchronously, so wait for it to catch up.
    assert_eventually(
      fn ->
        panel = frame("pop-panel")
        panel == nil or panel.bottom <= 0
      end,
      message: fn ->
        "the panel stayed on screen after its trigger scrolled away: " <>
          "trigger=#{inspect(frame("pop-trigger-open"))} panel=#{inspect(frame("pop-panel"))}"
      end
    )
  end

  # Also reported: tapping outside an open panel did not close it. The panel's window
  # reports the outside tap through on_open_change and the SCREEN closes it; the
  # window never closes itself, or it would vanish while `open` stayed true.
  test "a tap outside the panel closes it" do
    tap("pop-trigger-closed")
    panel = settled_frame("pop-panel")

    # A real touch, delivered in-process to the panel's own window the way the window
    # manager would route a finger outside it. Compose's performClick, and a BEAM
    # event, can neither dismiss a popup nor prove that a finger would.
    {x, y} = outside(panel)
    tap_xy(x, y)

    refute_shown("pop-panel")

    # The window and the assign must agree: a panel that vanished while `open` stayed
    # true would leave the trigger reading open.
    assert_shown("pop-trigger-closed")
    refute_shown("pop-trigger-open")
  end

  test "side right puts them abreast" do
    tap("beside-trigger-closed")

    panel = settled_frame("beside-panel")
    trigger = frame!("beside-trigger-open")

    assert panel.left >= trigger.right - 1,
           "side={:right} did not put the panel beside the trigger: " <>
             "trigger=#{inspect(trigger)} panel=#{inspect(panel)}"

    # Abreast, not stacked: align={:start} lines the tops up, UNLESS the window clamp
    # moves the panel up to stay on screen. The web's positionPopup clamps the same
    # way, so accept either, but not a panel drifted below its anchor.
    aligned = abs(panel.top - trigger.top) <= 2
    clamped_up = panel.top < trigger.top and panel.bottom <= trigger.bottom

    assert aligned or clamped_up,
           "align={:start} neither lined the tops up nor clamped upward: " <>
             "trigger=#{inspect(trigger)} panel=#{inspect(panel)}"
  end

  test "align end pushes a narrow panel to the trailing edge" do
    tap("aligned-trigger-closed")

    panel = settled_frame("aligned-panel")
    trigger = frame!("aligned-trigger-open")

    assert panel.width > 0 and panel.height > 0, "the panel has no area: #{inspect(panel)}"

    # align={:end} lines the panel's trailing edge up with the TRIGGER's, unless that
    # would push it off the leading edge, in which case the clamp wins and it pins
    # flush at the screen's padding. This example hits the second: the trigger sits
    # ~110dp wide near the left edge, so a 220dp panel cannot have its right edge at
    # the trigger's without its left going negative.
    aligned = abs(panel.right - trigger.right) <= 2
    clamped = panel.left <= 32 and panel.right > trigger.right

    assert aligned or clamped,
           "align={:end} neither lined the trailing edges up nor clamped: " <>
             "trigger=#{inspect(trigger)} panel=#{inspect(panel)}"
  end

  test "a disabled trigger cannot open anything" do
    # disabled wires no handler at all, so a real touch reaches nothing: the tap
    # must deliver no event, rather than deliver one that is then ignored.
    tap("off-trigger-closed", expect: :none)

    refute_shown("off-panel")
    assert_shown("off-trigger-closed")
  end

  test "the pinned example needs no trigger at all" do
    # Omit `trigger` and the popover is the panel alone, which is how Menu and the
    # select-style components use it. Its parts are still tagged.
    assert_shown("chrome-panel")
    assert_shown("chrome-title")
    assert_shown("chrome-desc")

    refute_shown("chrome-trigger-closed")
    refute_shown("chrome-trigger-open")
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Tap the trigger",
          "Hold to open",
          "Which side it takes",
          "A narrow panel has somewhere to go",
          "Disabled, and without a chevron",
          "Chrome",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every interactive example is laid out, not just described by the tree.
    for id <- @examples, do: assert_shown("#{id}-trigger-closed")
    assert_shown("off-trigger-closed")

    # And the page is one long scroll that reaches its end.
    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
