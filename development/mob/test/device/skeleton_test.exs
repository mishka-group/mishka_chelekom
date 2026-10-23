defmodule MishkaMob.Device.SkeletonTest do
  @moduledoc """
  Device tests for the Skeleton page: a port of `SkeletonTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  A placeholder has no text and no events, so almost nothing about it is assertable
  from the node tree, which is exactly why it needs a device test. The component
  numbers its bars into native tags (`id-0`, `id-1`, ...) for this purpose, and
  every assertion here is a MEASUREMENT.

  `the bars have a real height` guards a bug that is invisible on Android: iOS's
  MobBox applies a Box's `height` only inside its `fixedWidth > 0` branch, so a
  childless bar measured 0pt tall and the whole placeholder disappeared. Android was
  always fine, so this asserts the invariant rather than the symptom: a bar must
  have height.

  `the last line really is shorter` is Android-only by nature. The short line is a
  Row weight, and the iOS renderer never parses weight.

  Run with `mix test --only device test/device/skeleton_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :skeleton

  test "the bars have a real height" do
    scroll_into_view("sk-text-2")

    # A bar carries no text and no children of its own, so "it rendered" and "it is
    # 0pt tall" look identical in the tree. Measure it.
    for tag <- ["sk-text-0", "sk-text-1", "sk-text-2"] do
      bar = frame!(tag)

      assert bar.height > 0, "#{tag} has no height: #{inspect(bar)}"
      assert bar.width > 0, "#{tag} has no width: #{inspect(bar)}"
    end
  end

  test "the last line really is shorter" do
    # THE device-only claim. The short line is a Row WEIGHT, 60% of a parent whose
    # width nothing in Elixir knows, so only real layout can say whether it landed.
    scroll_into_view("sk-text-2")

    first = frame!("sk-text-0")
    last = frame!("sk-text-2")

    assert last.width < first.width,
           "the last bar is #{last.width} against #{first.width}: it did not come out short"

    ratio = last.width / first.width
    assert ratio > 0.5 and ratio < 0.7, "the last bar is #{ratio} of the width, not ~0.6"
  end

  test "loading swaps the placeholder for content of the same shape" do
    # Before: no name, and a circle where the avatar will be.
    refute_shown("sk-name")
    circle = frame!("sk-avatar")

    tap("sk-toggle")

    # After: the row it stood in for, and the avatar sits where the circle was, at
    # the same size, so nothing jumps.
    assert_shown("sk-name")
    name = frame!("sk-name")
    caption = frame!("sk-caption")

    assert caption.top > name.top, "the two lines are not stacked"
    assert abs(name.left - caption.left) < 2, "the two lines do not share a left edge"

    avatar = frame!("sk-avatar")

    assert abs(avatar.width - circle.width) < 1 and abs(avatar.height - circle.height) < 1,
           "the avatar is not the placeholder's size: #{inspect(circle)} -> #{inspect(avatar)}"

    # The avatar renders its INITIALS. It used to be handed a `name` prop
    # MishkaAvatar does not have, so the circle came up empty.
    assert_text("AL")

    tap("sk-toggle")

    refute_shown("sk-name")
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Standing in for a real row",
          "Text",
          "Blocks and circles",
          "It does not shimmer",
          "Props"
        ] do
      assert_text(heading)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
