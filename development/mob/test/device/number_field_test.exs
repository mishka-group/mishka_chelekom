defmodule MishkaMob.Device.NumberFieldTest do
  @moduledoc """
  Device tests for the Number Field page: a port of `NumberFieldTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  `the control is one joined strip` is the reported regression. It used to be a stepper,
  a gap, a bordered field that FILLED the row, and another stepper, so the two buttons
  drifted to opposite edges of the screen with a wide empty box marooned between them.
  The web draws one bordered strip. Only measurement can tell the difference: the node
  tree is equally correct either way.

  The steppers all read "-" or "+", and every number field on the page has a pair, so
  they are addressed by tag: `nf-qty-down`, `nf-qty-up`.

  The value a field shows is read from the rendered tree (its `value`), which is what the
  screen asked the native field to show. The harness has no way to read the native
  field's own text.

  Run with `mix test --only device test/device/number_field_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :number_field

  # The Kotlin thresholds were pixels on a 1080px, 2.8125x screen; these are the same
  # numbers in dp.
  #
  # Material's own horizontal padding is ~8dp a side, and a stepper reports its OUTER box
  # while a TextField reports its inner text area, so a perfectly joined strip still shows
  # ~9dp between those two rectangles. The bug this guards against was two 8dp Spacers AND
  # a value slot that filled the row, which the strip-width assertion catches.
  @inset 11
  @compact_strip 249

  test "the control is one joined strip" do
    scroll_into_view("nf-qty")

    down = frame!("nf-qty-down")
    field = frame!("nf-qty")
    up = frame!("nf-qty-up")

    # Adjacent and in order.
    assert field.left >= down.right - 0.5,
           "value overlaps the - stepper: #{inspect(down)} vs #{inspect(field)}"

    assert up.left >= field.right - 0.5,
           "+ stepper overlaps the value: #{inspect(field)} vs #{inspect(up)}"

    assert field.left - down.right < @inset,
           "a real gap before the value: #{inspect(down)} vs #{inspect(field)}"

    assert up.left - field.right < @inset,
           "a real gap after the value: #{inspect(field)} vs #{inspect(up)}"

    # And the whole strip hugs rather than spanning the screen. Before the fix this
    # measured ~845px on a 1080px screen.
    strip = up.right - down.left
    assert strip > 0 and strip < @compact_strip, "the strip is not compact: #{strip}"

    # Nothing but the two hairlines separates the parts: the strip is the sum of its
    # pieces, not its pieces plus spacers.
    parts = down.width + up.width + field.width + 2 * @inset
    assert strip <= parts + 3, "the strip is wider than its parts: #{strip} vs #{parts}"

    # The steppers are square and the same size.
    assert abs(down.width - down.height) < 1, "the - stepper is not square: #{inspect(down)}"
    assert abs(down.width - up.width) < 1, "the steppers differ in size"
  end

  test "fill width spans while the default hugs" do
    scroll_into_view("nf-wide")

    hugging = frame!("nf-hug-up").right - frame!("nf-hug-down").left
    spanning = frame!("nf-wide-up").right - frame!("nf-wide-down").left

    # Spanning has to add at least a stepper's width to the strip. A ratio (1.5x)
    # depended on how wide the card is: a 384dp phone spans 1.44x.
    stepper = frame!("nf-wide-up").width

    assert spanning > hugging + stepper,
           "fill_width did not span: hugging=#{hugging} spanning=#{spanning} stepper=#{stepper}"
  end

  test "the steppers move the value and clamp" do
    before = number("nf-qty")

    tap("nf-qty-up")

    assert_eventually(fn -> number("nf-qty") != before end,
      message: "the + stepper did not move the value"
    )

    assert number("nf-qty") == before + 1, "+ moved by more than one step"

    tap("nf-qty-down")

    assert_eventually(fn -> number("nf-qty") == before end,
      message: "the - stepper did not move it back"
    )
  end

  test "a stepper goes inert at its bound" do
    # Walk to the top of the 1..10 range.
    steps = 10 - number("nf-qty")
    for _step <- 1..steps//1, do: tap("nf-qty-up")

    assert_eventually(fn -> value_of("nf-qty") == "10" end,
      message: fn -> "never reached the max: #{value_of("nf-qty")}" end
    )

    # The + is unwired at the bound, so a real touch on it delivers nothing, and the
    # node is still there and still laid out, just inert.
    tap("nf-qty-up", expect: :none)
    assert value_of("nf-qty") == "10", "the + stepped past its max"
    assert shown?("nf-qty-up"), "the + stepper vanished at the bound"

    # Coming back down works, which proves the clamp is not a freeze.
    tap("nf-qty-down")

    assert_eventually(fn -> value_of("nf-qty") == "9" end,
      message: "the - stepper froze at the max"
    )
  end

  test "percent shows a fraction as a percentage" do
    scroll_into_view("nf-pct")

    # The assign holds 0.075. The field must read 7.5%, not 0.075 and not 0.075%: the
    # displayed number is never the stored one here.
    shown = value_of("nf-pct")
    assert String.ends_with?(shown, "%"), "percent lost its sign: #{shown}"
    assert shown == "7.5%", "0.075 did not read as 7.5%: #{shown}"

    # The caption is read from its own node (`nf-pct-note`) and checked against the field.
    # Asking the whole page whether a substring is somewhere on it would not do: the
    # props table repeats most of this page's prose.
    note = text_of("nf-pct-note")

    # The assign is still the fraction: format changes how the value reads, never what is
    # stored, and the caption inspects the assign itself.
    assert String.starts_with?(note, "Stored: 0.075 "),
           "the stored value is not the fraction: #{note}"

    # And the promise the caption makes is the reading the field gives. The "reads as "
    # prefix is what makes this falsifiable: a field that showed the raw 0.075 would
    # still be a substring of the caption without it.
    assert note =~ "reads as #{shown}",
           "the caption and the field disagree: #{inspect(note)} vs #{inspect(shown)}"
  end

  test "currency groups and prefixes" do
    scroll_into_view("nf-price")

    assert value_of("nf-price") == "$1,999.99",
           "currency formatting is wrong: #{value_of("nf-price")}"

    # And stepping keeps the format rather than dropping back to a raw float.
    tap("nf-price-up")

    assert_eventually(fn -> value_of("nf-price") == "$2,000.00" end,
      message: fn -> "stepping dropped the format: #{value_of("nf-price")}" end
    )
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Whole numbers",
          "Decimal steps",
          "Currency and percent",
          "It hugs, or it spans",
          "Empty and disabled",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree.
    for tag <- ~w(nf-qty nf-rate nf-price nf-pct nf-hug nf-wide), do: assert_shown(tag)

    # And the page is one long scroll that reaches its end.
    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  defp number(tag), do: tag |> value_of() |> String.to_integer()

  # The value the rendered tree gives the text field `tag`.
  defp value_of(tag), do: node!(tag).props.value

  # The text of the rendered node whose :id is `tag`.
  defp text_of(tag), do: node!(tag).props.text

  defp node!(tag), do: find_node(render_tree(), to_string(tag)) || flunk("no node tagged #{tag}")

  defp find_node(%{props: props, children: children} = node, id) do
    if to_string(Map.get(props, :id, "")) == id,
      do: node,
      else: Enum.find_value(children || [], &find_node(&1, id))
  end

  defp find_node(_leaf, _id), do: nil
end
