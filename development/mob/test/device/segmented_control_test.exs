defmodule MishkaMob.Device.SegmentedControlTest do
  @moduledoc """
  Device tests for the Segmented Control page: a port of `SegmentedControlTest.kt`,
  one test per `@Test`, on the host-driven suite instead of Compose instrumentation.

  `the selection can never be emptied` is what makes this component distinct from
  its two neighbours: a toggle group CLEARS when you re-press the pressed one, a
  radio group KEEPS its selection, and a segmented control keeps it too but can never
  start empty either. `select/2` is one line, so it is exactly the kind of rule a
  screen quietly reimplements wrongly.

  `the segments sit side by side` guards the layout bug that hit every Box-based
  control in this library: a Box with neither a width nor `fill_width` fills its
  parent, so the first segment took the whole strip and the rest were pushed off the
  screen, correct in the node tree and invisible on the device.

  Selection is a fill colour, which is not in the accessibility tree, so state rides
  in the tag: `sc-view-week-selected` / `sc-view-week-idle`. "Day", "Week" and "Month"
  are rendered by three controls on this page and only `sc-view` is tagged, so every
  touch goes through a tag and not a label: the two styled strips are bound to the
  same assign and would move it identically, so tapping by text could not tell them
  apart from `sc-view`, and the assertions would pass whichever was pressed.

  Run with `mix test --only device test/device/segmented_control_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :segmented_control

  import MishkaMob.DeviceText

  @views ~w(day week month)

  # The segment's state, from whichever tag it carries now.
  defp state_of(prefix), do: Enum.find(~w(selected idle), &shown?("#{prefix}-#{&1}"))

  # A segment's whole tag, state included: the selection moves and the tag follows.
  defp segment_tag(prefix),
    do: "#{prefix}-" <> (state_of(prefix) || flunk("#{prefix} is untagged"))

  defp segment_frame(prefix), do: frame!(segment_tag(prefix))

  # The selected view. Two selections read as nil and fail loudly.
  defp selected_view do
    case Enum.filter(@views, &(state_of("sc-view-#{&1}") == "selected")) do
      [only] -> only
      _none_or_many -> nil
    end
  end

  test "the segments sit side by side" do
    scroll_into_view(segment_tag("sc-view-day"))

    day = segment_frame("sc-view-day")
    week = segment_frame("sc-view-week")
    month = segment_frame("sc-view-month")

    # A filling segment would take the whole strip and push these off the screen,
    # where they have no frame at all, so segment_frame would already have failed.
    assert week.left >= day.right - 2, "Day and Week overlap: #{inspect(day)} vs #{inspect(week)}"

    assert month.left >= week.right - 2,
           "Week and Month overlap: #{inspect(week)} vs #{inspect(month)}"

    # Three segments in one strip, so none may be anywhere near full width.
    assert day.width > 1 and day.width <= 400, "the segment is not segment-sized: #{inspect(day)}"

    # Content-sized, as the moduledoc claims: "Month" is wider than "Day".
    assert month.width > day.width,
           "segments are not content-sized: #{inspect(day)} vs #{inspect(month)}"
  end

  test "the selection can never be emptied" do
    before = selected_view()
    assert before, "the control started with nothing selected"

    # Re-tapping the selected segment is a NO-OP. A toggle group would clear here:
    # that is the entire difference between the two components. The press goes
    # through sc-view's own tag, so the assertion below is about this control and not
    # about a styled strip bound to the same assign. The segment still hears the tap;
    # it is the rule in select/2 that keeps the selection.
    tap(segment_tag("sc-view-#{before}"))

    assert selected_view() == before, "re-tapping cleared the selection"
    assert text_of("sc-view-summary") == "Value: #{before}"
  end

  test "tapping another segment moves the selection" do
    before = selected_view()
    id = Enum.find(@views, &(&1 != before))

    # Pressed by tag, so the tap and the assertions are about one control.
    tap(segment_tag("sc-view-#{id}"))
    assert_eventually(fn -> selected_view() == id end)

    # selected_view is nil for two selections, which is what a control that forgot to
    # clear the old one would produce.
    assert selected_view() == id, "more than one segment is selected"
    assert text_of("sc-view-summary") == "Value: #{id}"
  end

  test "the track hugs unless fill width is asked for" do
    # Scroll to the caption BELOW both strips, so both are on screen at once.
    scroll_into_view(segment_tag("sc-fill-l"))

    # Same three labels, two strips: one hugging, one spanning. Compare the strips by
    # their outermost segments rather than their tracks, which carry no tag of their
    # own.
    hug_left = segment_frame("sc-hug-s")
    hug_right = segment_frame("sc-hug-l")
    fill_left = segment_frame("sc-fill-s")

    hug_width = hug_right.right - hug_left.left
    assert hug_width > 1 and hug_width <= 500, "the hugging strip is not compact: #{hug_width}"

    # The spanning one starts at the same left edge but its track runs on: the
    # segments stay content-sized, which is the documented compromise.
    assert abs(fill_left.left - hug_left.left) < 40,
           "the two strips do not share a left edge: #{inspect(hug_left)} vs #{inspect(fill_left)}"
  end

  test "a disabled segment cannot be selected" do
    scroll_into_view("sc-one-archive-idle")

    before = state_of("sc-one-archive")
    assert before == "idle", "the disabled segment started selected"

    # A real touch on it reaches nothing: disabled wires no handler.
    tap("sc-one-archive-idle", expect: :none)

    assert state_of("sc-one-archive") == before, "a disabled segment took the selection"
    assert state_of("sc-one-inbox") == "selected", "the dead segment disturbed its neighbour"
  end

  test "a disabled control cascades and still shows its selection" do
    scroll_into_view("sc-off-mid-selected")

    # Greyed rather than accented, but still SHOWN: a locked control must say which
    # option it is locked into.
    assert state_of("sc-off-mid") == "selected", "a disabled control lost its selection"
    assert state_of("sc-off-low") == "idle", "a disabled control gained a selection"

    tap("sc-off-low-idle", expect: :none)

    assert state_of("sc-off-mid") == "selected", "a disabled control responded to a tap"
    assert state_of("sc-off-low") == "idle", "a disabled control responded to a tap"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Always one selected",
          "With a label",
          "It hugs, or it spans",
          "Styled by props",
          "Disabled",
          "Props"
        ] do
      assert_text(heading)
    end

    for prefix <- ~w(sc-view-day sc-theme-system sc-role-admin sc-hug-m sc-one-inbox sc-off-mid) do
      assert_shown(segment_tag(prefix))
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
