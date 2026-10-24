defmodule MishkaMob.Device.OtpFieldTest do
  @moduledoc """
  Device tests for the OTP Field page: a port of `OtpFieldTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  ## Why these exist here rather than in `Mob.ScreenCase`

  `Mob.ScreenCase` asserts on the node tree, which is the right place for component
  logic and covers it far better than this can. What it cannot see is the native side.
  Every bug this class pins down was invisible to it:

    * the field on screen kept characters the BEAM had discarded, because an identical
      re-render never reached Compose;
    * every `background` / `text_color` set on a TextField was serialised and then
      ignored, because the composable passed no `colors`;
    * tapping slot 1 of a six-slot code reading "1" and typing "23" gave "231", because
      the tap moved the caret to index 0 while the highlighted slot still pointed at the
      end.

  So the keys here are real key events into the focused field, one at a time, and the
  touches are real touches. What the BEAM ended up with is read from the screen's assigns
  and from the caption and slots it rendered. The harness cannot read the native field's
  own text, so the first of those bugs is only covered to the extent that the BEAM's
  answer is right.

  Run with `mix test --only device test/device/otp_field_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :otp_field

  # ── the component ──────────────────────────────────────────────────────────

  test "the slots are the input" do
    # One editable node on this example: the invisible overlay. An earlier version drew a
    # VISIBLE TextField under the boxes and made the boxes a read-only display of it.
    assert_shown("otp-code")
    assert %{type: :text_field} = node!("otp-code")
    assert_text("A 6-digit code")
  end

  test "typing appends instead of inserting where the slot was tapped" do
    # The regression this class was written for. Start with a digit in the first slot,
    # tap the FIRST slot, then type. Without `caret: "end"` the caret lands at index 0 and
    # "1" + "23" comes out as "231".
    tap("otp-code")
    type("1")
    await_count(1)

    # Tap the FIRST slot. The overlay covers the boxes, so its left edge IS the first slot,
    # and a touch there is what a finger on that box actually does. The field already has
    # focus, so the touch delivers no event of its own.
    field = settled_frame("otp-code")
    tap_xy(field.left + 1, field.top + field.height / 2, expect: :any)
    type("23")

    # Appended, not prepended: 1-2-3, where the bug gave 2-3-1.
    await_count(3)
    assert code() == "123"

    for digit <- ~w(2 3) do
      assert slot_shows?(digit), "slot showing #{digit} not found"
    end
  end

  test "deleting removes the last digit" do
    tap("otp-code")
    type("123")
    await_count(3)

    # A real backspace: with the caret pinned to the end, what leaves is the last
    # character.
    delete_backward()

    await_count(2)
    refute slot_shows?("3"), "expected no slot showing \"3\""
  end

  test "a seventh digit cannot be entered" do
    # sanitize/2 truncates to :length. The field is deliberately NOT capped natively,
    # because that would refuse a pasted "123-456" whole, so the correction comes back from
    # Elixir, and this proves it is visible.
    tap("otp-code")
    type_each("1234567")

    await_complete()
    assert code() == "123456"
  end

  test "a pasted code with separators still lands" do
    # Seven characters against six slots: capping the field natively would have refused
    # the paste whole; sanitize/2 strips the separator.
    tap("otp-code")
    type_each("123-456")

    await_complete()
    assert code() == "123456"
  end

  test "letters are rejected by the numeric validation" do
    tap("otp-code")
    type_each("12ab34")

    await_count(4)
    assert code() == "1234"
  end

  # ── the showcase page ──────────────────────────────────────────────────────

  test "the page renders every example and the props table" do
    for heading <- [
          "A 6-digit code",
          "Masked and shorter",
          "Grouped, with a separator",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree.
    for tag <- ~w(otp-code otp-masked otp-ref), do: assert_shown(tag)

    # And the page is one long scroll that reaches its end.
    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  test "the code samples show the tag inside a sigil" do
    # Every example carries a ~MOB block now.
    assert_text("~MOB")

    # And the samples show the composite tag, which is what an app writes.
    assert_text("<MishkaOtpField")
  end

  # ── helpers ────────────────────────────────────────────────────────────────

  defp code, do: Map.fetch!(assigns(), :otp_code)

  # The caption under the slots, rendered from the same assign as the slots.
  defp await_count(n) do
    assert_eventually(fn -> status() == "#{n} of 6 digits" end,
      message: fn -> "expected \"#{n} of 6 digits\", the caption says #{inspect(status())}" end
    )
  end

  # A FULL code does not say "6 of 6 digits": the showcase swaps the caption for
  # "Complete - a screen would auto-submit here.", which is the whole point of tracking
  # completeness. Waiting on the count for a full code waits forever.
  defp await_complete do
    assert_eventually(fn -> status() =~ "Complete" end,
      message: fn -> "expected a complete code, the caption says #{inspect(status())}" end
    )
  end

  defp status, do: node!("otp-status").props.text

  # Does some slot on the page show exactly `digit`? Matched whole, so it cannot be
  # satisfied by a digit inside the caption, the props table or a code sample.
  defp slot_shows?(digit), do: digit in texts()
end
