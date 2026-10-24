defmodule MishkaMob.Device.ToggleGroupTest do
  @moduledoc """
  Device tests for the Toggle Group page: a port of `ToggleGroupTest.kt`, one test
  per `@Test`, on the host-driven suite instead of Compose instrumentation.

  `pressing the pressed one CLEARS the group` is the behaviour that makes this a
  toggle group rather than a radio group or a segmented control: single mode has an
  empty state, and you reach it by pressing the button that is already down. It is
  one line in `press/3`, so it is exactly the kind of thing that gets "simplified"
  into a radio by accident.

  `the items sit side by side` guards the layout bug that made a group unusable:
  each item is a Box, and a Box with neither a width nor `fill_width` fills its
  parent, so the first item took the whole row and the rest were pushed off the
  screen, present in the tree and invisible on the device.

  Pressed differs from idle by fill colour alone, which is not in the accessibility
  tree, so state rides in the tag: `tgg-align-left-pressed`.

  Four groups on this page render "Left", "Center" and "Right" and three of them are
  bound to the same `@tgg_align`, so only the ones that carry an `id` can be told
  apart: every touch here goes through a tag, never a label.

  Run with `mix test --only device test/device/toggle_group_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :toggle_group

  @aligns ~w(left center right)
  @states ~w(pressed idle)

  # The item's state, from whichever tag it carries now.
  defp state_of(prefix), do: state_of(prefix, @states)

  # An item's whole tag, state included: the selection moves and the tag follows.
  defp item_tag(prefix), do: state_tag(prefix, @states)

  defp item_frame(prefix), do: frame!(item_tag(prefix))

  # The pressed align, or nil: single mode really can hold nothing. A second pressed
  # item reads as nil too, so it fails loudly where a count is expected.
  defp pressed_align do
    case Enum.filter(@aligns, &(state_of("tgg-align-#{&1}") == "pressed")) do
      [only] -> only
      _none_or_many -> nil
    end
  end

  test "the items sit side by side" do
    scroll_into_view(item_tag("tgg-align-left"))

    left = item_frame("tgg-align-left")
    center = item_frame("tgg-align-center")
    right = item_frame("tgg-align-right")

    # A filling item would take the whole row and push these off the screen, where
    # they have no frame at all, so item_frame would already have failed.
    assert center.left >= left.right - 2,
           "Left and Center overlap: #{inspect(left)} vs #{inspect(center)}"

    assert right.left >= center.right - 2,
           "Center and Right overlap: #{inspect(center)} vs #{inspect(right)}"

    # Three buttons on one line, so none may be anywhere near full width.
    assert left.width > 1 and left.width <= 400, "the item is not button-sized: #{inspect(left)}"

    # space: 0 joins them into one bar: no gap between adjacent segments. A frame is
    # the node inside its own padding, and the page gives every item 10dp, so two joined
    # items are 2 * 10dp apart and a Spacer between them would add to that.
    assert center.left - left.right < 2 * 10 + 3,
           "space: 0 left a gap: #{inspect(left)} vs #{inspect(center)}"
  end

  test "pressing the pressed one CLEARS the group" do
    # The example starts with one item pressed.
    pressed = pressed_align()
    assert pressed, "the group started with nothing pressed"

    # THE differentiator: a radio group cannot be cleared, a segmented control always
    # keeps a selection, and this does neither.
    tap(item_tag("tgg-align-#{pressed}"))

    assert_eventually(fn -> pressed_align() == nil end,
      message: "pressing the pressed one did not clear"
    )

    for align <- @aligns, do: assert(state_of("tgg-align-#{align}") == "idle")
    assert text_of("tgg-align-summary") == "Value: nil", "the summary did not follow the clear"
  end

  test "single mode moves the selection rather than adding to it" do
    tap(item_tag("tgg-align-left"))
    assert_eventually(fn -> pressed_align() == "left" end)

    tap(item_tag("tgg-align-center"))
    assert_eventually(fn -> pressed_align() == "center" end)

    # pressed_align is nil if TWO are pressed, which is what a group that forgot it
    # was single-select would produce.
    assert pressed_align() == "center", "single mode holds more than one press"
  end

  test "multiple mode holds several at once" do
    scroll_into_view("tgg-style-italic-pressed")

    assert state_of("tgg-style-bold") == "pressed"
    assert state_of("tgg-style-italic") == "pressed"
    assert state_of("tgg-style-under") == "idle"

    # The point of multiple mode: pressing one must NOT release the others.
    tap("tgg-style-under-idle")

    for item <- ~w(bold italic under) do
      assert_shown("tgg-style-#{item}-pressed")
    end

    # And pressing again removes, rather than doing nothing.
    tap("tgg-style-italic-pressed")
    assert_shown("tgg-style-italic-idle")
    assert state_of("tgg-style-bold") == "pressed", "pressing Italic released Bold"
    assert state_of("tgg-style-under") == "pressed", "pressing Italic released Underline"

    tap("tgg-style-italic-idle")
    assert_shown("tgg-style-italic-pressed")
  end

  test "vertical stacks them and they share one width" do
    scroll_into_view("tgg-view-cards-idle")

    list = item_frame("tgg-view-list")
    grid = item_frame("tgg-view-grid")
    cards = item_frame("tgg-view-cards")

    # Stacked, not side by side.
    assert grid.top >= list.bottom - 2,
           "List and Grid are not stacked: #{inspect(list)} vs #{inspect(grid)}"

    assert cards.top >= grid.bottom - 2,
           "Grid and Cards are not stacked: #{inspect(grid)} vs #{inspect(cards)}"

    # And filling, so "List" and "Cards" are the same width rather than a ragged
    # staircase sized to each label.
    assert abs(list.width - cards.width) < 2,
           "stacked items are not a uniform width: #{inspect(list)} vs #{inspect(cards)}"
  end

  test "a disabled item is inert while its neighbour works" do
    scroll_into_view("tgg-one-right-idle")

    # The neighbour is live, so a dead item means something.
    tap("tgg-one-left-idle")
    assert_shown("tgg-one-left-pressed")

    # Disabled wires no handler: a real touch reaches nothing, rather than reaching a
    # handler that then reports a press.
    tap("tgg-one-right-idle", expect: :none)

    assert state_of("tgg-one-right") == "idle", "a disabled item reported a press"
    assert state_of("tgg-one-left") == "pressed", "the dead item disturbed its neighbour"
  end

  test "a disabled group cascades and still shows what is pressed" do
    scroll_into_view("tgg-off-on-pressed")

    # This group is disabled outright and wires no handler at all.
    assert state_of("tgg-off-on") == "pressed", "a disabled group lost its pressed state"
    assert state_of("tgg-off-off") == "idle", "a disabled group gained a press"

    tap("tgg-off-off-idle", expect: :none)
    tap("tgg-off-on-pressed", expect: :none)

    assert state_of("tgg-off-on") == "pressed", "a disabled group responded to a tap"
    assert state_of("tgg-off-off") == "idle", "a disabled group responded to a tap"
  end

  test "the page renders every example and the props table" do
    for heading <- ["Single", "Multiple", "Vertical", "Styled by props", "Disabled", "Props"] do
      assert_text(heading)
    end

    for prefix <- ~w(tgg-align-center tgg-style-bold tgg-view-grid tgg-one-left tgg-off-on) do
      assert_shown(item_tag(prefix))
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
