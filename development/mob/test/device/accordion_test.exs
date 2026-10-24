defmodule MishkaMob.Device.AccordionTest do
  @moduledoc """
  Device tests for the Accordion page: a port of `AccordionTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  The open set lives in the screen, since a composite is a pure function of its
  props, so every test here is a round trip: tap a header, the screen recomputes
  the set, the panel is in the next render. A closed item renders its trigger and
  nothing else, which is what makes "the panel is there" a real assertion. Each
  example has its own `id`, and every item is `<id>-<item>-trigger` with, while it
  is open, `<id>-<item>-panel`: three examples share item ids such as `:native`,
  and page text could not tell them apart anyway, since every code sample is text.

  `an_open_change_reports_the_direction` matters most. `on_toggle` says which
  trigger was hit and nothing else, so "did it open or close" was a question a
  screen could not answer without recomputing it. The answer now travels in the tag.

  Run with `mix test --only device test/device/accordion_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :accordion

  test "a header opens its panel" do
    # The body is only in the tree while the panel is open: a closed item renders
    # its trigger and nothing else, which is what makes this a real assertion
    # rather than a visibility check.
    refute_shown("acc-faq-styled-panel")

    tap("acc-faq-styled-trigger")

    assert_shown("acc-faq-styled-panel")
  end

  test "one at a time closes the previous panel" do
    # The example starts with its first item open. Open another one.
    assert_shown("acc-faq-what-panel")

    tap("acc-faq-native-trigger")
    assert_shown("acc-faq-native-panel")

    refute_shown("acc-faq-what-panel")
    refute_shown("acc-faq-styled-panel")
  end

  test "an open change reports the direction" do
    assert text_of("acc-watch-log") == "Nothing yet — open or close a panel above."

    # The new half. Tapping the SAME trigger twice must log two different things;
    # on_toggle could only ever have said "shipping" both times.
    tap("acc-watch-shipping-trigger")
    assert_shown("acc-watch-shipping-panel")
    assert text_of("acc-watch-log") == "Last: shipping opened"

    tap("acc-watch-shipping-trigger")
    refute_shown("acc-watch-shipping-panel")
    assert text_of("acc-watch-log") == "Last: shipping closed, shipping opened"
  end

  test "a disabled item does not open" do
    # The neighbour works, so the page is live and a missing panel means something.
    tap("acc-off-ok-trigger")
    assert_shown("acc-off-ok-panel")

    # disabled wires no handler at all: a real touch must reach nothing, rather
    # than reach a handler that then ignores it.
    tap("acc-off-nope-trigger", expect: :none)

    refute_shown("acc-off-nope-panel")
    assert_shown("acc-off-ok-panel")
  end

  test "the page renders every example and the props table" do
    for heading <- ["One at a time", "Multiple open", "Knowing which way it went", "Props"] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree.
    for id <- ~w(acc-faq acc-multi acc-locked acc-off acc-watch), do: assert_shown(id)

    # And the page is one long scroll that reaches its end.
    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
