defmodule MishkaMob.Device.AlertDialogTest do
  @moduledoc """
  Device tests for the Alert Dialog page: a port of `AlertDialogTest.kt`, one test
  per `@Test`, on the host-driven suite instead of Compose instrumentation.

  The one rule that separates this from a plain Dialog is that its backdrop does not
  dismiss it, and "the backdrop neither dismisses nor leaks" is the test for it. It
  asserts the stronger half too: the backdrop must SWALLOW the tap. A box with a
  background but no pointer handler paints over the page without consuming a touch,
  so until the port wired an absorbing handler a user could reach straight past the
  dim and press the button that opened the dialog.

  Every assertion reads a tag rather than page text. All five examples render into one
  scrolling column and each prints its own source, so "Discard changes?" is on
  screen from the moment the page mounts whether or not anything is open.

  Run with `mix test --only device test/device/alert_dialog_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :alert_dialog

  test "the backdrop neither dismisses nor leaks" do
    # The count lives in the tag, so the card is found by `ad-stubborn-leaks-0`
    # and a leaked tap would rename it.
    scroll_into_view("ad-stubborn-leaks-0")
    tap("ad-stubborn-trigger")
    assert_shown("ad-stubborn-open")

    # The counter card sits directly under the backdrop, so a tap on its centre is
    # a backdrop tap aimed at something that WOULD react.
    tap("ad-stubborn-leaks-0")

    assert shown?("ad-stubborn-open"), "the backdrop dismissed an alert dialog"
    assert shown?("ad-stubborn-leaks-0"), "the tap went through the backdrop"
    assert Map.fetch!(assigns(), :ad_stubborn_leaks) == 0, "the covered card heard the tap"

    tap("ad-stubborn-ok-neutral")
    refute_shown("ad-stubborn-open")
  end

  test "the backdrop is inert away from the panel too" do
    # The dialog above passes dismissible={true} and is refused it; this one never
    # asks. Between them the backdrop is proven inert either way. The panel is
    # centred, so 5% down the backdrop is dim and nothing else.
    tap("ad-confirm-trigger")
    backdrop = assert_shown("ad-confirm-backdrop-modal")

    tap_xy(backdrop.left + backdrop.width / 2, backdrop.top + backdrop.height * 0.05)

    assert shown?("ad-confirm-open"), "a backdrop tap closed the dialog"
    assert shown?("ad-confirm-choice-none"), "the backdrop reported a choice"
  end

  test "close true fires on_close" do
    tap("ad-confirm-trigger")
    assert_shown("ad-confirm-open")

    # Cancel carries close: true and no handler of its own (the port of the web's
    # data-close), so tapping it has to fire the dialog's on_close.
    tap("ad-confirm-cancel-neutral")

    refute_shown("ad-confirm-open")
    assert_shown("ad-confirm-choice-cancel")
  end

  test "an action with its own handler wins" do
    tap("ad-confirm-trigger")
    assert_shown("ad-confirm-open")

    tap("ad-confirm-go-primary")

    refute_shown("ad-confirm-open")
    assert_shown("ad-confirm-choice-discard")
  end

  test "the destructive action says so in its tag" do
    assert_shown("ad-delete-state-intact")

    tap("ad-delete-trigger")
    assert_shown("ad-delete-open")

    # :error against :surface_raised is the only difference between these two buttons
    # on screen, and a fill is not something a device test can read.
    assert_shown("ad-delete-go-danger")
    assert_shown("ad-delete-cancel-neutral")

    tap("ad-delete-go-danger")

    refute_shown("ad-delete-open")
    assert_shown("ad-delete-state-gone")
  end

  test "cancelling the destructive dialog deletes nothing" do
    tap("ad-delete-trigger")
    assert_shown("ad-delete-open")

    tap("ad-delete-cancel-neutral")

    refute_shown("ad-delete-open")
    assert_shown("ad-delete-state-intact")
    refute_shown("ad-delete-state-gone")
  end

  test "a title made of nodes still carries the title tag" do
    tap("ad-slots-trigger")
    assert_shown("ad-slots-open")

    # The web's <:title> and <:description> are slots, not strings. Ported, they
    # still have to be the tagged parts a test addresses.
    assert_shown("ad-slots-title")
    assert_shown("ad-slots-description")
    assert_shown("ad-slots-footer")

    tap("ad-slots-ok-neutral")
    refute_shown("ad-slots-open")
  end

  test "every data part became a test tag" do
    tap("ad-chrome-trigger")
    assert_shown("ad-chrome-open")

    # Dialog's part names, not a set of this component's own: an alert dialog IS a
    # dialog, and a test should not have to know which it has.
    for part <- ~w(open backdrop-modal panel title description content footer) do
      assert shown?("ad-chrome-#{part}"), "no tag for the #{part} part"
    end

    tap("ad-chrome-ok-neutral")

    # -open exists ONLY while open, so its absence IS the closed state: there is no
    # second tag to look for. The panel goes with it.
    refute_shown("ad-chrome-open")
    refute_shown("ad-chrome-panel")
  end

  test "the page renders every example" do
    for heading <- [
          "Confirm or cancel",
          "The backdrop will not dismiss it",
          "Destructive",
          "A title that is not a string",
          "Its own chrome",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree.
    for id <- ~w(confirm stubborn delete slots chrome), do: assert_shown("ad-#{id}-trigger")
  end
end
