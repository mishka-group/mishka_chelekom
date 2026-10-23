defmodule MishkaMob.Device.CheckboxTest do
  @moduledoc """
  Device tests for the Checkbox page: a port of `CheckboxTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  `the tick scales with the box` is the reported regression behind this class. The
  indicator is drawn from a Box plus a glyph (Mob has no checkbox widget) and the glyph
  was a fixed `:base` while the Box took `size`, so a small box clipped its tick into a
  smear and a large one left it stranded. Neither shows in the node tree, so the
  frames are measured.

  The mark is drawn, so there is no glyph to read: the state rides in the indicator's
  tag (`cb-remember-checked`, `-mixed`, `-empty`), and every assertion reads that.

  Run with `mix test --only device test/device/checkbox_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :checkbox

  # How far right of the indicator a label's text starts being under a finger: the
  # indicator, a 10dp spacer, then the text. Well inside "Remember me" and "Locked on".
  @label_offset 40

  test "the box scales and both report their state" do
    scroll_into_view("cb-small-checked")

    # The mark is DRAWN, so there is no glyph in the tree to look for: the state
    # rides in the tag. Both boxes are checked here.
    big = frame!("cb-large-checked")
    small = frame!("cb-small-checked")

    assert big.width > small.width,
           "size did not scale the box: #{inspect(big)} vs #{inspect(small)}"

    assert small.width > 0 and small.height > 0,
           "the small box did not lay out: #{inspect(small)}"

    # Square, so the drawn mark's fractions land where the arithmetic says.
    assert abs(small.width - small.height) < 1,
           "the small indicator is not square: #{inspect(small)}"
  end

  test "a mixed box draws a dash not a tick" do
    scroll_into_view("cb-all-mixed")

    assert_text("All languages")

    # The three states must differ by SHAPE, not only colour, so they survive a
    # colourblind reading. The tag says which state the box is in; the rendered tree
    # says what was drawn for it: one stroke for the dash, two for the tick.
    assert strokes("cb-all-mixed") == 1, "a mixed box did not draw a single dash"

    # Tapping a mixed parent selects everything, and it then draws the tick.
    tap("cb-all-mixed")
    assert_shown("cb-all-checked")
    assert strokes("cb-all-checked") == 2, "a checked box did not draw a tick"
  end

  test "tapping the label toggles it too" do
    assert_shown("cb-remember-checked")

    # on_tap sits on the Row, so the label is as tappable as the 22dp box, which is the
    # whole reason it is on the Row. The state rides in the tag, so a touch on the LABEL
    # (to the right of the indicator, not on it) must flip the tag on the indicator.
    tap_label("cb-remember-checked")
    assert_shown("cb-remember-empty")
    refute_shown("cb-remember-checked")

    tap_label("cb-remember-empty")
    assert_shown("cb-remember-checked")
    refute_shown("cb-remember-empty")
  end

  test "a disabled box does not change" do
    scroll_into_view("cb-locked-on-checked")

    # Disabled wires no handler, so this must be inert rather than merely grey: a real
    # touch on the label and on the box must each deliver nothing.
    tap_label("cb-locked-on-checked", expect: :none)
    tap("cb-locked-on-checked", expect: :none)
    tap_label("cb-locked-off-empty", expect: :none)

    # The label used to be the only witness ("the row did not vanish"); the indicator's
    # tag says the state did not move either.
    assert_shown("cb-locked-on-checked")
    assert_shown("cb-locked-off-empty")
    refute_shown("cb-locked-on-empty")
    refute_shown("cb-locked-off-checked")
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Checked and unchecked",
          "Select all",
          "Disabled",
          "Colour and size",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree.
    for tag <- ~w(cb-remember-checked cb-all-mixed cb-locked-on-checked cb-large-checked) do
      assert_shown(tag)
    end

    # And the page is one long scroll that reaches its end.
    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  # A touch on the label of the row whose indicator is `tag`: right of the indicator, on
  # the row's own text. The label has no tag of its own.
  defp tap_label(tag, opts \\ []) do
    frame = scroll_into_view(tag)
    {_x, y} = center(frame)

    tap_xy(frame.right + @label_offset, y, opts)
  end

  # How many strokes the indicator `tag` drew: its canvas's draw ops.
  defp strokes(tag) do
    %{children: [%{type: :canvas, props: %{draw: ops}}]} = node!(tag)

    length(ops)
  end
end
