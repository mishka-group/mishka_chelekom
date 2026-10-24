defmodule MishkaMob.Device.DisplayTest do
  @moduledoc """
  Device tests for the Code and Avatar pages: a port of `DisplayTest.kt`, one test
  per `@Test`, on the host-driven suite instead of Compose instrumentation.

  Neither component has events, so what only a device can answer is size and
  shape. Inline code says it "hugs its text" and did not: a Box given neither
  `width` nor `fill_width` fills its parent, so it rendered as a full-width bar,
  and the unit test asserted the ABSENCE of `fill_width` and called that hugging.
  And an avatar's `:circle` is `size / 2` rather than a radius token, which only
  works if the box really is square.

  Run with `mix test --only device test/device/display_test.exs`.
  """
  use MishkaMob.DeviceCase

  describe "Code" do
    @describetag page: :code

    test "inline code hugs its text" do
      # THE regression. By tag, not by text: "mix mob.deploy" is in this example's
      # own code sample too, and that node spans the card.
      snippet = scroll_into_view("inline-code")
      page = frame!("page")

      assert snippet.width > 0, "the inline snippet was not laid out"

      assert snippet.width < page.width / 2,
             "inline code spans #{snippet.width} of #{page.width}: it is filling, not hugging"
    end

    test "a code block fills the width" do
      # The other half of the same prop: a block is meant to fill, so the two
      # together prove fill_width is honoured in BOTH directions rather than just
      # being absent everywhere. The Kotlin test only checked that the "Block"
      # heading was displayed; the block carries a tag now, so it measures it.
      block = scroll_into_view("code-block")
      page = frame!("page")

      assert block.width > page.width / 2,
             "a code block spans #{block.width} of #{page.width}: it is hugging, not filling"
    end

    test "the code page renders every example and the props table" do
      assert_headings(["Inline", "Block", "Without the scroller", "Colours", "Props"])
    end
  end

  describe "Avatar" do
    @describetag page: :avatar

    test "an avatar is square at every size" do
      # :circle resolves to size/2 rather than a radius token, which is what keeps
      # a 28 and a 64 both round, and it only works if the box really is square.
      scroll_into_view("avatar-64")

      for tag <- ["avatar-28", "avatar-44", "avatar-64"] do
        box = frame!(tag)

        assert box.width > 0, "#{tag} was not laid out"

        assert abs(box.width - box.height) < 2,
               "#{tag} is #{box.width}x#{box.height}: not square, so size/2 cannot round it"
      end

      # ...and they really are three different sizes, so the radius has to scale.
      small = frame!("avatar-28")
      large = frame!("avatar-64")

      assert large.width > small.width * 2, "28 and 64 came out #{small.width} and #{large.width}"
    end

    test "the fallback shows without a src" do
      # The stacking contract: the fallback is always built and an image is drawn
      # OVER it. With no src there is no image, so the initials are the avatar,
      # not an empty circle waiting for a load that never comes.
      assert_text("SH")
    end

    test "the avatar page renders every example and the props table" do
      assert_headings(["Initials", "Shapes", "Sizes", "In a row", "Props"])
    end
  end
end
