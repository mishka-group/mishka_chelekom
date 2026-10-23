defmodule MishkaMob.Device.PreviewCardTest do
  @moduledoc """
  Device tests for the Preview Card page: a port of `PreviewCardTest.kt`, one test
  per `@Test`, on the host-driven suite instead of Compose instrumentation.

  The web component is a trigger plus a popup, and the trigger is the half this
  port shipped without: it drew the card and left every caller to invent what
  opened it. On the web that is a hover; on a touch screen it is a long press,
  which is what `holding a name reveals its card` asserts.

  Everything here reads TAGS. Every example on this page renders into one scrolling
  column, the code samples are text nodes too, and the states this component has
  (open, which side it took, where the arrow sits) are a position and a colour. So
  the component folds them into its tags instead: `<id>-open`,
  `<id>-popup-<side>`, `<id>-arrow-<align>`.

  An open card is a window of its own, over the page. A finger on another trigger
  while one is open lands in that window first, as the touch outside it that
  dismisses, exactly as for a user. Where a step needs the second trigger's hold
  itself to arrive, it is delivered with `event/2` and says so.

  Run with `mix test --only device test/device/preview_card_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :preview_card

  # A point outside `popup` that a finger could land on: the left gutter, 80dp below
  # it, or above it when there is no room below.
  defp outside(popup) do
    page = frame!("page")
    below = popup.bottom + 80

    if below < page.bottom, do: {10.0, below}, else: {10.0, popup.top - 80}
  end

  test "holding a name reveals its card" do
    refute shown?("pc-elixir-open"), "this card was already open"

    hold("pc-elixir-trigger")

    assert_shown("pc-elixir-open")
    refute_shown("pc-elixir-closed")

    # The popup and every part of it, so a broken header cannot hide behind a root
    # that merely says "open".
    for part <- ~w(popup-bottom avatar title subtitle description footer) do
      assert_shown("pc-elixir-#{part}")
    end
  end

  test "a plain tap does not reveal it" do
    # The long press must not swallow the ordinary tap: the web's trigger is a
    # link, and tapping a link still follows it. That is why on_tap and on_hold are
    # separate props rather than one repurposed handler.
    #
    # Tap the other one second: the readout names the LAST tap, so asserting a tag
    # an earlier step may already have set would pass without anything happening.
    tap("pc-elixir-trigger")
    assert_shown("pc-visited-pc-elixir")

    tap("pc-phoenix-trigger")

    assert_shown("pc-visited-pc-phoenix")
    refute shown?("pc-phoenix-open"), "a plain tap opened the card"
    refute shown?("pc-elixir-open"), "a plain tap opened the card"
  end

  test "holding another name moves the card" do
    hold("pc-elixir-trigger")
    assert_shown("pc-elixir-open")

    # The open card is a modal window, so a real finger on the second name would
    # arrive as an outside touch and dismiss; it is the hold's own handler that is
    # under test here, so deliver it.
    event("pc-phoenix-trigger", :on_long_press)

    # One `open` assign, so there is still exactly one card: it belongs to the
    # other name now.
    assert_shown("pc-phoenix-open")
    refute_shown("pc-elixir-open")
  end

  test "holding it again closes it" do
    hold("pc-elixir-trigger")
    assert_shown("pc-elixir-open")

    # Nothing here closes the card but the screen: there is no pointer to move
    # away, so the hold has to toggle. The open card's window sits over the page, so
    # the second hold is delivered by event, for the reason above.
    event("pc-elixir-trigger", :on_long_press)

    assert_shown("pc-elixir-closed")
    refute_shown("pc-elixir-popup-bottom")
  end

  test "the trigger survives the closed state" do
    # The popup is what disappears; the trigger is what you hold, so it has to be
    # there when there is nothing to see.
    assert_shown("pc-elixir-trigger")
    assert_shown("pc-elixir-closed")
  end

  test "the side and the alignment are in the tags" do
    hold("pc-elixir-trigger")
    assert_shown("pc-elixir-arrow-center")

    # Each hold below lands while the previous card is open; the second and third
    # triggers belong to their own assigns, so they are delivered by event (see
    # `holding another name moves the card`).
    event("pc-top-trigger", :on_long_press)
    assert_shown("pc-top-popup-top")
    assert_shown("pc-top-arrow-end")

    event("pc-side-trigger", :on_long_press)
    assert_shown("pc-side-popup-right")
    assert_shown("pc-side-arrow-start")

    # Each example owns its own assign, so opening one leaves the others as they
    # were: a shared assign would make every assertion above true of whichever card
    # happened to be last.
    assert shown?("pc-top-popup-top"), "opening one card closed another"
  end

  test "the footer belongs to the card and acts" do
    hold("pc-elixir-trigger")
    assert_shown("pc-elixir-footer")

    # The footer button is in the card's own window; the touch is routed there.
    # "Follow" and "Following" differ by a word and a colour, so the button states
    # its own state in its tag.
    tap("pc-elixir-follow-off")

    assert_shown("pc-elixir-follow-on")
    assert_shown("pc-followed-pc-elixir")

    tap("pc-elixir-follow-on")
    assert_shown("pc-elixir-follow-off")
  end

  test "the pinned card needs no trigger at all" do
    # Leave the trigger out and it is the popup alone: the shape this port used to
    # be, still supported.
    assert_shown("pc-static-popup-bottom")
    assert_shown("pc-static-avatar")
    assert_shown("pc-bare-popup-bottom")
    refute shown?("pc-static-trigger"), "a card with no trigger grew one"
  end

  test "the page renders every example" do
    for heading <- [
          "Hold a name",
          "Above the trigger",
          "Beside the trigger",
          "Pinned open",
          "Scroller",
          "Props"
        ] do
      assert_text(heading)
    end

    for id <- ~w(pc-elixir pc-phoenix pc-top pc-side), do: assert_shown("#{id}-trigger")

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  # Reported by the user: "why we click out of it not closed?". It did not, because
  # nothing was wired to an outside tap: the card could only be closed by finding
  # its trigger again and holding it. The web dismisses on pointer-leave, which a
  # finger has no equivalent of; an outside tap is the equivalent a finger CAN make.
  test "a tap outside the card closes it" do
    hold("pc-elixir-trigger")
    popup = settled_frame("pc-elixir-popup-bottom")

    # A real touch, delivered in-process to the card's own window the way the
    # window manager would route a finger outside it. Compose's performClick, and a
    # BEAM event, can neither dismiss a popup nor prove that a finger would.
    {x, y} = outside(popup)
    tap_xy(x, y)

    refute_shown("pc-elixir-open")

    # The window and the assign must agree: a card that vanished while the assign
    # stayed true would leave the root reading open.
    assert_shown("pc-elixir-closed")
  end
end
