defmodule MishkaMob.Device.SpoilerTest do
  @moduledoc """
  Device tests for the Spoiler page: a port of `SpoilerTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  Collapsed content is not in the tree at all, since the component swaps `preview`
  for the children rather than clipping them, so revealing it is a real round trip
  through the screen. Each example has an `id`. What the spoiler shows is
  `<id>-preview` or, once expanded, `<id>-content`; the control is `<id>-control`
  and its text `<id>-label`.

  The other device-only claim is the tap target. The control is a line of text, and
  a line of `:base` text is about 20 dp tall, less than half the ~44 dp both
  platforms ask for. It is wrapped in a padded Box for that reason, and
  `the control is a finger sized target` measures the result.

  Run with `mix test --only device test/device/spoiler_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :spoiler

  # Roughly what both platforms ask of a tap target, in dp.
  @min_target_dp 44

  test "show more reveals the content and becomes show less" do
    # The full paragraph is genuinely absent while collapsed: preview replaces it
    # rather than clipping it, because Mob reports no geometry back and nothing here
    # can clip to a measured height.
    assert_shown("sp-more-preview")
    refute_shown("sp-more-content")
    assert text_of("sp-more-label") == "Show more"

    tap("sp-more-control")
    assert_shown("sp-more-content")
    refute_shown("sp-more-preview")

    # The label is derived from the boolean, not stored beside it.
    assert text_of("sp-more-label") == "Show less"

    tap("sp-more-control")
    refute_shown("sp-more-content")
    assert_shown("sp-more-preview")
    assert text_of("sp-more-label") == "Show more"
  end

  test "the control is a finger sized target" do
    # A bare line of :base text is ~20 dp. The padded Box is what takes it to a real
    # target, and only touch can say whether it worked: a frame is the node inside its
    # own padding, so the label's frame is the control's too.
    scroll_into_view("sp-more-control")
    label = frame!("sp-more-label")

    # The label is small, so the padding is what does the work.
    assert label.height < @min_target_dp,
           "the label alone is #{label.height}dp, so this assertion no longer measures what it thinks"

    # Tap a point just ABOVE the label's own box: inside the padding, which only counts
    # as a hit if the padded Box is the target.
    {x, _y} = center(label)
    tap_xy(x, label.top - 5)

    assert_shown("sp-more-content")
    assert text_of("sp-more-label") == "Show less"

    # And just below it, to close again. The content grew above the control and moved
    # it, so it is brought back into view and the label measured afresh.
    scroll_into_view("sp-more-control")
    label = frame!("sp-more-label")
    tap_xy(x, label.bottom + 5)

    assert_shown("sp-more-preview")
    assert text_of("sp-more-label") == "Show more"
  end

  test "custom labels replace the defaults" do
    assert_shown("sp-custom-control")

    assert text_of("sp-custom-label") == "Read the rest",
           "show_label did not replace the default"

    tap("sp-custom-control")

    assert text_of("sp-custom-label") == "Collapse", "hide_label did not replace the default"
  end

  test "the page renders every example and the props table" do
    for heading <- ["Revealing the rest", "Custom labels", "No preview", "Props"] do
      assert_text(heading)
    end

    for id <- ~w(sp-more sp-custom sp-bare), do: assert_shown(id)

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
