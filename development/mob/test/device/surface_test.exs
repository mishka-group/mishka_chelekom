defmodule MishkaMob.Device.SurfaceTest do
  @moduledoc """
  Device tests for the Color Swatch and Loading Overlay pages: a port of
  `SurfaceTest.kt`, one test per `@Test`, on the host-driven suite instead of
  Compose instrumentation. (Loading Overlay has a page-wide class of its own in
  `loading_overlay_test.exs`; the two tests here are the ones `SurfaceTest.kt`
  kept.)

  Each asserts something the Elixir suite structurally cannot.

  The swatch's selection is a round trip through the screen: the tree shows
  `on_tap: {pid, {:sw_pick, :blue}}` whether or not anything receives it.

  The overlay's whole purpose is that it EATS the taps aimed at what it covers, and
  "a tap did not happen" is a statement about hit-testing, not about nodes.
  `the overlay absorbs taps aimed at what it covers` is the one that matters, and a
  real finger is the only thing that can say it. The Kotlin version had to click
  without scrolling and without waiting for idle while the overlay was up, because
  its indicator is an indeterminate Progress and Compose never reports idle under
  one. This suite waits on a native frame barrier instead, which an animation does
  not hold up.

  A swatch carries no text, so it is reached by its `:id`, which Mob turns into a
  native tag.

  Run with `mix test --only device test/device/surface_test.exs`.
  """
  use MishkaMob.DeviceCase

  describe "Color Swatch" do
    @describetag page: :color_swatch

    test "picking a swatch reaches the screen and comes back" do
      # The readout under the palette is rendered from the assign the tap sets, so
      # this is the round trip and not a local highlight.
      assert "Violet" in texts(render_tree())

      tap("swatch-green")

      assert_eventually(fn -> "Green" in texts(render_tree()) end,
        message: "the readout never followed the tap"
      )

      assert Map.fetch!(assigns(), :sw_picked) == :green
      refute "Violet" in texts(render_tree()), "the old pick is still shown"

      tap("swatch-red")

      assert_eventually(fn -> "Red" in texts(render_tree()) end,
        message: "the readout never followed the second tap"
      )
    end

    test "the swatch page renders every example and the props table" do
      for heading <- ["A palette", "Disabled", "Transparency", "Shapes and sizes", "Props"] do
        assert_text(heading)
      end

      %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
      assert max_y > 0, "the page does not scroll, so the props table is out of reach"
    end
  end

  describe "Loading Overlay" do
    @describetag page: :loading_overlay

    test "the overlay absorbs taps aimed at what it covers" do
      # Tap the card underneath: the count rises.
      tap("lo-order-card")
      assert_shown("lo-order-hits-1")

      # Now cover it, and tap the same place again. The BUTTON's label is the
      # visibility signal, not the word "Saving...": that appears in this example's
      # own code sample as well, so it is on screen whether or not the scrim is.
      tap("lo-order-start")
      assert_shown("lo-order-finish")

      tap("lo-order-card")

      assert shown?("lo-order-hits-1"),
             "the count moved through the scrim: the overlay is not absorbing taps"

      assert Map.fetch!(assigns(), :lo_hits) == 1

      # And it starts working again once the overlay lifts.
      tap("lo-order-finish")
      assert_shown("lo-order-start")

      tap("lo-order-card")
      assert_shown("lo-order-hits-2")
    end

    test "an invisible overlay covers nothing" do
      scroll_into_view("lo-idle-text")

      assert_shown("lo-idle-text")
      assert_text("the overlay below is invisible")
    end
  end

  defp texts(%{props: props, children: children}) do
    own = if is_binary(props[:text]), do: [props.text], else: []

    own ++ Enum.flat_map(children || [], &texts/1)
  end

  defp texts(_leaf), do: []
end
