defmodule MishkaMob.Device.ThemeIconTest do
  @moduledoc """
  Device tests for the Theme Icon page: a port of `ThemeIconTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  Everything this component does is paint: a variant, a colour, a corner radius.
  None of that is readable from a device test, and there is no text to query, which
  is exactly why the component emits markers derived from its `id`. So these tests
  address tags and geometry, never page text: the gallery renders every example into
  one scrolling column and the code samples are text nodes too, so a page-wide text
  query is answered by whichever example happens to contain the string.

  Run with `mix test --only device test/device/theme_icon_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :theme_icon

  test "every variant is addressable because a colour is not" do
    # The seven variants differ only in paint. Without the `<id>-<variant>` marker
    # there is nothing here for a device test to hold on to at all.
    for variant <- ~w(filled light outline subtle white default gradient) do
      assert_shown("ti-var-#{variant}")
    end
  end

  test "the size scale is real geometry" do
    xs = scroll_into_view("ti-size-xs").width
    xl = scroll_into_view("ti-size-xl").width

    assert xs > 0, "the xs icon measured zero: it was not laid out, not small"
    assert xl > xs * 2, "xl (#{xl}) should be well over twice xs (#{xs})"
  end

  test "a labelled icon is distinguishable from a decorative one" do
    # This is the whole of the web component's accessibility story: role="img" +
    # aria-label versus aria-hidden. Mob has nothing to announce into, so the
    # distinction lives in the tag or nowhere.
    assert_shown("ti-meaning-labelled")
    assert_shown("ti-plain-decorative")
    refute_shown("ti-plain-labelled")
  end

  test "holding a labelled icon reveals what it means" do
    hold("ti-meaning")
    assert_shown("ti-held-deploy")

    # Hold the other one: a transition, not an existence check.
    hold("ti-meaning-alt")

    assert_shown("ti-held-rollback")
    refute_shown("ti-held-deploy")
  end

  test "a decorative icon has nothing to reveal" do
    hold("ti-meaning")
    assert_shown("ti-held-deploy")

    # No label, so no long-press handler: a real hold reaches nothing.
    hold("ti-plain", 650, expect: :none)

    assert_shown("ti-held-deploy")
  end

  test "a plain tap is not a hold" do
    hold("ti-meaning-alt")
    assert_shown("ti-held-rollback")

    # The icon carries a long-press handler only, so a tap reaches nothing.
    tap("ti-meaning", expect: :none)

    assert_shown("ti-held-rollback")
  end

  test "tapping the icon reports it" do
    before = taps()

    tap("ti-basic")

    assert_shown("ti-taps-#{before + 1}")
  end

  test "the switcher fills exactly the chosen option" do
    # A switcher is three of these in a row, and "active" is a fill, so the variant
    # marker is what says which one is on.
    tap("ti-sw-dark")
    assert_shown("ti-sw-dark-filled")

    tap("ti-sw-light")

    assert_shown("ti-sw-light-filled")
    assert shown?("ti-sw-dark-subtle"), "the old choice stayed filled"
    refute shown?("ti-sw-dark-filled"), "two options were active at once"
  end

  test "a caller-supplied icon still gets its container" do
    # Children are the icon, here a canvas drawing, which has no text and no
    # semantics of its own, so the container's markers are the only evidence it was
    # wrapped rather than dropped.
    assert_shown("ti-drawn")
    assert_shown("ti-drawn-default")
    assert_shown("ti-drawn-alt-outline")
  end

  test "the gradient keeps its own shape" do
    # The gradient is painted into a canvas because no Box has a gradient
    # background. It must still be an icon-sized square, not a canvas that grew or
    # collapsed.
    flat = scroll_into_view("ti-size-lg")
    gradient = scroll_into_view("ti-grad-round")

    assert abs(gradient.width - flat.width) < 0.5,
           "the gradient icon is #{gradient.width} wide, the flat one #{flat.width}"
  end

  test "the page renders every example" do
    for heading <- [
          "One icon, wrapped",
          "Variants",
          "Sizes",
          "Radius",
          "Colour",
          "Gradient",
          "What the icon means",
          "Your own icon",
          "A theme switcher, built from three",
          "Marquee",
          "Props"
        ] do
      assert_text(heading)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  # The tap counter is a tag that names its own value (`ti-taps-3`). Read where it
  # is and assert the STEP.
  defp taps do
    counters =
      for tag <- Map.keys(frames()), [_, n] <- [Regex.run(~r/\Ati-taps-(\d+)\z/, tag)], do: n

    case counters do
      [n] -> String.to_integer(n)
      other -> flunk("the tap counter is not on the page exactly once: #{inspect(other)}")
    end
  end
end
