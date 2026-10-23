defmodule MishkaMob.Device.ToolbarTest do
  @moduledoc """
  Device tests for the Toolbar page: a port of `ToolbarTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  Everything here is addressed by TAG. The page renders nine toolbars into one
  scrolling column, each example's code sample is a text node, and the props table
  repeats most of the prose, so any page-wide text query is answered by whichever
  example happens to contain the string, not by the one under test. Each bar
  therefore carries its own `id`, each item is tagged `<bar>-<item_id>`, and a
  disabled item's tag ends in `-disabled`, because a device test can read neither
  the muted ink nor a missing handler. The captions have an id of their own: they
  are read as the one node, never as the page.

  The two things only hardware proves are here as well: that a long press on an icon
  button names it (the touch equivalent of the web's hover tooltip, and the only home
  the web's `aria-label` has on a device), and that a scrolling strip really reaches
  its last control.

  Run with `mix test --only device test/device/toolbar_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :toolbar

  test "all four item kinds render and each carries its own tag" do
    # button, link, input, separator: the web's <:item> types. A separator draws no
    # text and takes no tag, so the other three are what proves the slot ported at all.
    assert shown?("tb-kinds-bold"), "the button did not render"
    assert shown?("tb-kinds-docs"), "the link did not render"
    assert shown?("tb-kinds-find"), "the input did not render"
  end

  test "tapping a button reports its own id" do
    tap("tb-kinds-bold")

    assert text_of("tb-kinds-status") == "Tapped bold"
  end

  test "tapping a link reports its id too, so one handler serves the bar" do
    tap("tb-kinds-docs")

    # The link is not a second event shape: it reports its id like every other item,
    # and href/2 is what turns that id back into a destination.
    assert text_of("tb-kinds-status") == "Tapped docs"
  end

  test "typing in the toolbar input reaches the screen" do
    # The tag sits on the text field itself rather than on the box that weights it,
    # because only the field accepts text. Focusing a field is not an event the screen
    # hears, so the tap must reach no handler.
    tap("tb-kinds-find", expect: :none)
    type("beam")

    # Case-insensitive: the status reads "Looking for beam" on a fresh page but
    # "Tapped X, looking for beam" once something has been tapped.
    assert_eventually(fn ->
      String.downcase(text_of("tb-kinds-status")) =~ "looking for beam"
    end)

    assert Map.fetch!(assigns(), :tb_kinds_query) == "beam"
  end

  test "holding an icon button names it" do
    # The web puts the name in aria-label and a desktop browser shows it on hover.
    # There is neither here, so the long press is the port, and this is the assertion
    # that proves the gesture actually reaches the BEAM.
    refute_shown("tb-hint-hint")

    hold("tb-hint-undo")
    assert text_of("tb-hint-hint") == "Undo"

    hold("tb-hint-redo")
    assert text_of("tb-hint-hint") == "Redo"
  end

  test "a disabled bar marks every item and still answers a hold" do
    # `disabled` on the bar reaches every item, and the state is in the tag because
    # the only other signal is the ink.
    assert shown?("tb-off-bold-disabled"), "the disabled bar did not mark its items"
    refute shown?("tb-off-bold"), "a disabled item kept its live tag"

    # focusable_when_disabled: on the web a disabled item stays in the roving order so
    # it remains discoverable. Here that means it can still be held.
    hold("tb-off-italic-disabled")
    assert text_of("tb-off-hint") == "Italic"
  end

  test "a disabled item does nothing while its neighbour still acts" do
    # Establish a reading first, then touch the dead item and assert it did not move.
    tap("tb-mix-bold")
    assert text_of("tb-mix-status") == "Picked bold"

    # A real touch on it reaches no handler at all: this bar has no on_hold.
    tap("tb-mix-italic-disabled", expect: :none)
    assert text_of("tb-mix-status") == "Picked bold", "a disabled item acted"
  end

  test "consecutive items sharing a group become one cluster" do
    # The group's label is an aria-label on the web: invisible there, and unavailable
    # here, so the tag is the one place it survives.
    assert shown?("tb-grp-group-align"), "the Align group did not render"
    assert shown?("tb-grp-group-lists"), "the Lists group did not render"
    assert shown?("tb-grp-left"), "the group swallowed its items' tags"
  end

  test "collapsing keeps the first controls and hides the rest" do
    assert shown?("tb-more-cut"), "the first control was collapsed away"
    assert shown?("tb-more-paste"), "fewer than `visible` controls survived"
    refute shown?("tb-more-table"), "the tail was not collapsed"
    assert shown?("tb-more-overflow"), "no ⋯ for the hidden controls"

    tap("tb-more-overflow")

    assert text_of("tb-more-status") == "The rest would open in a drawer"
  end

  test "a scrolling strip reaches its last control" do
    # Bring the bar into view by its outer Box, which sits outside the horizontal
    # scroller.
    scroll_into_view("tb-scr")

    assert shown?("tb-scr-table"), "the thirteenth control was never composed"

    # Measure the FIRST control travelling, not the last arriving: a control clipped
    # away by the strip's viewport is still laid out past the edge, so its own position
    # can neither prove nor disprove that the strip moved.
    first_before = frame!("tb-scr-cut").left
    assert first_before > 0, "the strip never came into view"

    window = frame!("page")
    refute frame!("tb-scr-table").right <= window.right, "the last control already fits"

    # A real drag of the strip itself, enough fingers' worth to reach the end of
    # thirteen controls.
    for _drag <- 1..6, do: drag("tb-scr-scroll", {-150, 0})

    assert_eventually(
      fn -> frame!("tb-scr-cut").left < first_before - 20 end,
      message: fn ->
        "the strip did not scroll: first control was at #{first_before}, " <>
          "now #{inspect(frame("tb-scr-cut"))}"
      end
    )

    last = settled_frame("tb-scr-table")

    assert last.right <= window.right + 1,
           "the last control is still past the edge: #{inspect(last)}"
  end

  test "a vertical bar stacks its controls" do
    scroll_into_view("tb-vert-delete")

    top = frame!("tb-vert-edit")
    bottom = frame!("tb-vert-delete")

    # A unit test can prove the tree says Column. Only the device proves Compose laid
    # it out that way, which is the half that has bitten this library before.
    assert bottom.top >= top.bottom, "the vertical bar laid its items out sideways"
  end

  test "each example renders its own bar" do
    # Nine bars, nine ids. Sharing one would make every assertion above ambiguous the
    # moment a second bar rendered the same label.
    bars = ~w(tb-own tb-kinds tb-grp tb-hint tb-off tb-mix tb-scr tb-more tb-vert)

    for bar <- bars, do: assert(shown?(bar), "no toolbar tagged #{bar}")

    assert shown?("tb-scr-scroll"), "the scrolling bar registered no scroller"
  end

  test "the page renders every example" do
    for heading <- ["Four item kinds", "Groups", "Overflow: collapse", "Props"] do
      assert_text(heading)
    end
  end
end
