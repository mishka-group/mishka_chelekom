defmodule MishkaMob.Device.SeparatorTest do
  @moduledoc """
  Device tests for the Separator page: a port of `SeparatorTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  A rule has no text and no state, it draws a line, so everything worth asserting
  here is geometry, and geometry needs a tag. That is why the component grew an
  `id`: without one there is nothing in the frame table to address, and a test
  could only claim the page rendered.

  Run with `mix test --only device test/device/separator_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :separator

  test "a plain rule is a hairline across the width" do
    rule = scroll_into_view("sep-plain")

    # Thin on one axis, wide on the other: that is the whole claim a rule makes, and
    # it is the one a wrong `thickness` or a dropped `fill` would break.
    assert rule.height < 4, "the default rule is not a hairline: #{inspect(rule)}"
    assert rule.width > 100, "the rule did not span its column: #{inspect(rule)}"
  end

  test "thickness is honoured and is not the default" do
    thin = scroll_into_view("sep-plain")
    thick = scroll_into_view("sep-thick")

    # thickness={3} against the default 1. Asserting the ORDER rather than exact dp
    # keeps this honest across densities while still failing if the prop stops being
    # read, which is what "3 is thicker than 1" means and what a hardcoded 1 breaks.
    assert thick.height > thin.height,
           "thickness={3} was not thicker than the default: #{inspect(thick)} vs #{inspect(thin)}"
  end

  test "a labelled rule centres its label between two equal lines" do
    scroll_into_view("sep-or-line-start")
    start = frame!("sep-or-line-start")
    finish = frame!("sep-or-line-end")

    # Both lines carry weight={1}, so they split the leftover width evenly. This is
    # the assertion that would catch the weight being dropped.
    assert abs(start.width - finish.width) < 4,
           "the flanking lines are not equal: start=#{inspect(start)} end=#{inspect(finish)}"

    assert start.width > 8, "the flanking lines collapsed: #{inspect(start)}"

    assert start.left < finish.left,
           "the lines are out of order: #{inspect(start)} then #{inspect(finish)}"

    assert_text("or continue with")
  end

  test "a longer label takes width from the lines, not from the page" do
    short_label_line = scroll_into_view("sep-year-line-start")
    long_label_line = scroll_into_view("sep-or-line-start")

    # "1994" against "or continue with" in the same column. The lines flex; the row
    # does not grow. A rule whose lines had fixed widths would push the long label
    # out of the row instead.
    assert short_label_line.width > long_label_line.width,
           "the shorter label did not leave more room for its lines: " <>
             "1994=#{inspect(short_label_line)} vs 'or continue with'=#{inspect(long_label_line)}"
  end

  test "a vertical rule is tall and thin rather than wide and flat" do
    rule = scroll_into_view("sep-vert")

    assert rule.width < 4, "the vertical rule is not a hairline: #{inspect(rule)}"
    assert rule.height > rule.width, "the vertical rule did not stand up: #{inspect(rule)}"
  end

  test "the page renders every example and the props table" do
    for heading <- ["Plain rule", "Labelled", "Colour and thickness", "Vertical", "Props"] do
      assert_text(heading)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
