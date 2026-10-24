defmodule MishkaMob.Device.ToastTest do
  @moduledoc """
  Device tests for the Toast page: a port of `ToastTest.kt`, one test per `@Test`,
  on the host-driven suite instead of Compose instrumentation.

  `the close button can actually be hit` is why this file exists. The card's body
  was a `fill_width` Column sitting BEFORE the fixed-width ✕ in the same Row, and a
  Compose Row measures a non-weighted child against the space left over, so the
  body claimed the whole row and the ✕ was measured at width 0. It was in the node
  tree, it had its on_tap, and a harness would happily deliver the event; only a
  finger could tell. iOS was unaffected, because an HStack serves its fixed-size
  children first, which is exactly what let it survive review. Measure the control,
  do not trust the tree: the touch here lands where the control's frame is.

  String traps on this page, and there are several: every example prints its own
  source, so "Saved", "Welcome", "Dismiss" and "Written in markup, not queued." are
  all on screen whether or not anything rendered. So the viewport is given an `id`
  and tags what it draws: `tst-<toast id>` is a card, with `-title` and `-close`
  inside it. Queued toasts are numbered from 1 by the page's counter; the markup
  item is `tst-welcome`. Text is only read where the RENDER produces it and the
  samples do not:

    * "Heads up" is the :info toast's title (the samples only say "Saved").
    * "its body is a slot" is the markup item's body (the sample stops earlier).
    * the exact glyph "✕": the page's description merely mentions it inside a longer
      string, so an exact match splits them.

  Run with `mix test --only device test/device/toast_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :toast

  # The dismiss controls laid out right now, one per card.
  defp close_controls do
    for {tag, {_x, _y, width, height}} <- frames(),
        tag =~ ~r/^tst-[^-]+-close$/,
        width > 0,
        height > 0,
        do: tag
  end

  test "tapping a button stacks a toast" do
    tap("tst-info")
    assert_shown("tst-1")
    assert text_of!("tst-1-title") == "Heads up"

    tap("tst-warning")
    assert_shown("tst-2")
    assert text_of!("tst-2-title") == "Careful"

    assert shown?("tst-1"), "the second toast replaced the first instead of stacking"
  end

  test "the close button can actually be hit" do
    tap("tst-info")
    assert_shown("tst-1")

    # The regression: the ✕ was measured to ZERO width because the card's body took
    # the whole Row. A node with no area has no frame at all, so being laid out is
    # already half of it; measure it, then use it.
    glyph = frame("tst-1-close") || flunk("no laid-out ✕: the close button has no size at all")
    assert glyph.width >= 8, "the ✕ is too narrow to hit: #{inspect(glyph)}"

    # And it sits clear of the text rather than under it.
    title = frame!("tst-1-title")

    assert glyph.left >= title.right - 2,
           "the ✕ overlaps the title: #{inspect(glyph)} vs #{inspect(title)}"

    # The round trip is the feature: tapping it must remove that toast.
    tap("tst-1-close")
    refute_shown("tst-1")
    refute_shown("tst-1-close")
  end

  test "each card gets its own close button" do
    tap("tst-info")
    assert_shown("tst-1")
    tap("tst-warning")
    assert_shown("tst-2")

    # Two cards, two hittable ✕s: the per-card id is what makes one handler clause
    # serve every toast.
    glyphs = close_controls()
    assert Enum.sort(glyphs) == ["tst-1-close", "tst-2-close"], "expected a ✕ per card"

    assert Enum.all?(glyphs, &(frame!(&1).width >= 8)),
           "a ✕ was measured too narrow: #{inspect(glyphs)}"

    # Dismissing one leaves the other alone.
    tap("tst-1-close")
    refute_shown("tst-1")

    assert shown?("tst-2"), "dismissing one dropped both"
    assert close_controls() == ["tst-2-close"]
  end

  test "limit keeps only the newest few" do
    # The page pushes with limit: 3, so a fourth distinct toast evicts the oldest
    # rather than growing the stack.
    for button <- ~w(tst-info tst-success tst-warning tst-danger), do: tap(button)

    assert_shown("tst-4")
    assert text_of!("tst-4-title") == "Failed"

    refute_shown("tst-1")

    assert Enum.sort(close_controls()) == ["tst-2-close", "tst-3-close", "tst-4-close"],
           "limit: 3 did not cap the stack at the newest three"
  end

  test "the markup toast renders its slot body and close label" do
    tap("tst-toggle-markup")

    # "its body is a slot" is only ever produced by the render: the printed sample
    # stops at "not queued."
    assert_shown("tst-welcome")
    assert_text("its body is a slot")

    # <MishkaToastClose> replaces the glyph on every card, so the exact-"✕" node
    # disappears while a "Dismiss" label takes its place.
    assert text_count("✕") == 0, "the close slot did not replace the ✕"
    assert text_count("Dismiss") == 1, "the close slot rendered nothing"

    # A static item is not in the queue, so its ✕ cannot go through Queue.dismiss:
    # the screen drops it by flipping the flag.
    tap("tst-welcome-close")

    refute_shown("tst-welcome")
    refute assigns().tst_static
  end

  test "a markup toast stacks with the queued ones" do
    tap("tst-toggle-markup")
    assert_shown("tst-welcome")

    tap("tst-info")
    assert_shown("tst-1")

    # Static items render BEFORE the queued ones.
    markup = frame!("tst-welcome")
    queued = frame!("tst-1")

    assert markup.top < queued.top, "the markup toast is not above the queued one"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Stack a few",
          "Capped and deduped",
          "Position",
          "Slots",
          "Auto-dismiss",
          "Props"
        ] do
      assert_text(heading)
    end

    # The buttons of each interactive example are laid out.
    for button <- ~w(tst-info tst-repeat tst-clear tst-top tst-bottom tst-toggle-markup) do
      assert_shown(button)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
