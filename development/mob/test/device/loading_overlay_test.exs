defmodule MishkaMob.Device.LoadingOverlayTest do
  @moduledoc """
  Device tests for the Loading Overlay page: a port of `LoadingOverlayTest.kt`, one
  test per `@Test`, on the host-driven suite instead of Compose instrumentation.

  The Kotlin class found every node by its text, and worked around the overlay's
  indeterminate Progress (an infinite animation, so Compose never reports idle) by
  scrolling first and never calling `waitForIdle` while an overlay was up. This suite
  reads tags, and its barrier is the main looper rather than Compose's idleness, so the
  animation costs it nothing.

  The page and the component grew the tags that made that possible: the page names its
  cards and its controls (a control that swaps its label also swaps its tag, so the tag
  says which state the page is in), and the component stamps `<id>-scrim` and
  `<id>-label` when it is given an `id`.

  "the label is centred" is the regression the page was reported for. The body used to
  be a `<Column fill_width={false}>`, and a Column cannot align its children, so the
  label left-aligned against the 140dp bar and sat visibly off centre on Android, while
  on iOS the whole body pinned to the left edge. The assertion measures the label against
  a full-width button on the same page, because that button's centre IS the content
  centre.

  Run with `mix test --only device test/device/loading_overlay_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :loading_overlay

  # Roughly 7dp: the 20px the Kotlin test allowed on the phone it was written for.
  @tolerance 7

  test "it absorbs the taps it covers" do
    # The whole reason this is an overlay and not a spinner beside a button. First prove
    # the card does count a tap, or "the count did not move" proves nothing.
    tap("lo-order-card")
    assert_shown("lo-order-hits-1")

    tap("lo-order-start")
    assert_shown("lo-order-scrim")

    # Tap the covered card. The scrim must swallow it.
    tap("lo-order-card")

    assert shown?("lo-order-hits-1"), "a tap reached the covered card"
    assert Map.fetch!(assigns(), :lo_hits) == 1, "the covered card heard the tap"

    tap("lo-order-finish")
    refute_shown("lo-order-scrim")
  end

  test "the label is centred" do
    button = scroll_into_view("lo-order-start")

    tap("lo-order-start")
    label = assert_shown("lo-order-label")

    # The button is fill_width, so its centre is the content centre. Before the fix the
    # label left-aligned against the 140dp bar and landed ~35dp off; 7dp is comfortably
    # inside the fixed layout and outside the bug.
    {label_x, _y} = center(label)
    {button_x, _y} = center(button)

    assert abs(label_x - button_x) < @tolerance,
           "the label is not centred: #{label_x} vs #{button_x}"

    tap("lo-order-finish")
  end

  test "without a label the indicator still covers the card" do
    assert_shown("lo-prices-card")

    tap("lo-prices-refresh")

    # Nothing to read (the bar carries no text), so the assertion is that the page
    # swapped to its busy control and a scrim now lies over the card. The card is read
    # after the tap: tapping the button scrolled the page to it.
    assert_shown("lo-prices-stop")
    scrim = assert_shown("lo-prices-scrim")
    card = frame!("lo-prices-card")
    refute shown?("lo-prices-label"), "an unlabelled overlay drew a label"

    for edge <- [:left, :top, :right, :bottom] do
      assert abs(Map.fetch!(scrim, edge) - Map.fetch!(card, edge)) <= 1,
             "the scrim does not cover the card's #{edge} edge: #{inspect(scrim)} over #{inspect(card)}"
    end

    tap("lo-prices-stop")
    assert_shown("lo-prices-refresh")
    refute_shown("lo-prices-scrim")
  end

  test "a page-wide overlay covers everything and its own control still works" do
    trigger = scroll_into_view("lo-sync-start")

    tap("lo-sync-start")

    # The overlay is the screen root's, so it is tagged by its own id, not the card's.
    scrim = assert_shown("lo-sync-scrim")
    headline = assert_shown("lo-sync-headline")

    {headline_x, _y} = center(headline)
    {trigger_x, _y} = center(trigger)

    assert abs(headline_x - trigger_x) < @tolerance,
           "the custom panel is not centred: #{headline_x} vs #{trigger_x}"

    assert scrim.height >= frame!("page").height - 1, "the overlay does not span the page"

    # The scrim absorbs taps, but a control INSIDE it must still get its own: otherwise a
    # full-page overlay would be a trap with no way out.
    tap("lo-sync-cancel")

    refute_shown("lo-sync-headline")
    refute_shown("lo-sync-scrim")
    assert_shown("lo-sync-start")
  end

  test "invisible costs nothing" do
    scroll_into_view("lo-idle-text")

    # A permanently-mounted invisible overlay must leave its region alone.
    assert_shown("lo-idle-text")
    refute shown?("lo-idle-scrim"), "an invisible overlay drew a scrim"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "It absorbs the taps it covers",
          "Without a label",
          "Its own scrim, panel and indicator",
          "Over the whole page, with a body of your own",
          "Invisible costs nothing",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree, and none is busy.
    for id <- ~w(lo-order-start lo-prices-refresh lo-upload-start lo-sync-start lo-idle-text) do
      assert_shown(id)
    end

    for id <- ~w(lo-order lo-prices lo-upload lo-sync lo-idle) do
      refute shown?("#{id}-scrim"), "#{id} was busy on a fresh page"
    end
  end
end
