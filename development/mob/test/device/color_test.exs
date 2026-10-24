defmodule MishkaMob.Device.ColorTest do
  @moduledoc """
  Device tests for the colour family: the hue, alpha and angle sliders and the picker.
  A port of `ColorTest.kt`, one test per `@Test`, on the host-driven suite instead of
  Compose instrumentation. Each test names its page with `@tag page:`.

  ## Why every one of these needs a device

  These components have no value events. The drawing IS the control, so a touch arrives
  as `{:drag, tag, %{x:, y:, phase:}}` and the screen converts the POSITION into a
  number. Three separate things have to line up for that to work, and the Elixir suite
  can see none of them:

    * the Android bridge must actually deliver the drag (`canvasDragModifier` was missing
      entirely until this port added it, so every colour control rendered perfectly and
      did nothing);
    * `phase` must be "began" on touch-down, which is what makes a TAP set the value
      rather than only a drag;
    * the inverse (`hue_at`, `alpha_at`, `angle_at`, `sv_at`) must be computed against the
      width the strip was actually drawn at (a mismatch there put the finger and the
      marker up to 8% apart and was invisible to `mix test`).

  A canvas is a drawing: no text, no label. Each one carries an `:id`, and that is the
  only handle these have.

  The touches here are real, but a canvas drag leaves no `Mob.Agent.Receipts` entry, so
  `tap/2` (which proves a handler received the touch by its receipt) cannot be used;
  `touch/3` is a tap that requires no receipt, at a fraction across and down the canvas,
  and the readout the page renders from its own assign is what proves it landed.

  Run with `mix test --only device test/device/color_test.exs`.
  """
  use MishkaMob.DeviceCase, page: nil

  # The readout a page renders from its own assign, e.g. "238°" or "60%". Matched WHOLE:
  # every colour page's own description contains the unit ("Pick a hue, 0-360°, against a
  # rainbow"), so a substring match returns the prose, and three tests spent a device run
  # comparing that sentence with itself.
  @degrees ~r/^\d+°$/
  @hsb ~r/^H (\d+)\s+S (\d+)\s+B (\d+)$/

  # ── Hue ────────────────────────────────────────────────────────────────────

  @tag page: :hue_slider
  test "tapping the hue strip sets the hue" do
    touch("hue-strip", 0.1)
    low = readout_int(@degrees)

    touch("hue-strip", 0.9)
    high = readout_int(@degrees)

    assert low != high, "the hue did not change: #{low} then #{high}"
    assert high > low, "further right should be a higher hue: #{low} then #{high}"
  end

  @tag page: :hue_slider
  test "the far right of the hue strip is 360 not 0" do
    # The regression this pins: wrap_hue/1 was fmod, and fmod(360, 360) is 0.0, so
    # dragging to the maximum teleported the marker back to the left edge and erased the
    # dial. A finger cannot land exactly on the strip's last pixel (its right edge is
    # outside it), so the maximum is reached the way a person reaches it: by dragging past
    # the end, which the screen clamps to 360.
    touch("hue-strip", 0.9)
    {x, y} = point("hue-strip", 0.9)
    swipe({x, y}, {frame!("hue-strip").right + 30, y})

    deg = readout_int(@degrees)
    assert deg > 300, "the right edge reads #{deg}°, not near 360"
  end

  @tag page: :hue_slider
  test "dragging the hue strip tracks the finger" do
    touch("hue-strip", 0.05)
    start = readout_int(@degrees)

    {from_x, y} = point("hue-strip", 0.05)
    {to_x, _y} = point("hue-strip", 0.8)
    swipe({from_x, y}, {to_x, y})

    finish = readout_int(@degrees)
    assert finish > start, "a drag left the hue at #{finish}, from #{start}"
  end

  # ── Alpha ──────────────────────────────────────────────────────────────────

  @tag page: :alpha_slider
  test "tapping the alpha track sets the opacity" do
    touch("alpha-track", 0.15)
    low = percent()

    touch("alpha-track", 0.85)
    high = percent()

    assert high > low, "opacity went #{low}% then #{high}%; further right should be more"
  end

  @tag page: :alpha_slider
  test "alpha clamps rather than wrapping" do
    # Hue is circular so 360 needed care; opacity is not. The far right must pin at 100
    # and stay there rather than rolling over to 0. First at the last pixel a finger can
    # land on, then dragged past the end.
    touch("alpha-track", 1.0)
    a = percent()

    touch("alpha-track", 0.9)
    {x, y} = point("alpha-track", 0.9)
    swipe({x, y}, {frame!("alpha-track").right + 30, y})
    b = percent()

    assert a >= 99 and b >= 99, "the right edge gave #{a}% then #{b}%"
  end

  # ── Angle ──────────────────────────────────────────────────────────────────

  @tag page: :angle_slider
  test "the dial has a dead centre" do
    # A pixel either side of the middle swings the angle wildly, so angle_at/3 returns
    # :dead inside the inner ring and follow/2 passes it through unchanged. Touching the
    # centre must leave the value alone. The first touch moves the dial off its mount
    # value (45), so the second one is known to be reaching a working control.
    touch("angle-dial", 0.5, 0.15)
    edge = readout_int(@degrees)
    refute edge == 45, "the first touch did not reach the dial"

    touch("angle-dial", 0.5, 0.5)
    centre = readout_int(@degrees)

    assert edge == centre, "the dead centre moved the angle: #{edge} then #{centre}"
  end

  @tag page: :angle_slider
  test "the dial reads zero at the top not the right" do
    # Screen maths puts 0° at three o'clock; a direction dial puts it at twelve.
    # angle_at/3 applies the rotation, so the top must be ~0/360 and the right ~90.
    touch("angle-dial", 0.5, 0.02)
    top = readout_int(@degrees)

    touch("angle-dial", 0.98, 0.5)
    right = readout_int(@degrees)

    assert top < 20 or top > 340, "the top of the dial reads #{top}°, not ~0"
    assert right in 70..110, "the right of the dial reads #{right}°, not ~90"
  end

  # ── Picker ─────────────────────────────────────────────────────────────────

  @tag page: :color_picker
  test "one drag on the square sets both axes" do
    # The reason on_area replaced on_saturation + on_value: a component cannot emit two
    # events from one gesture, so the square sends a single {x, y} and sv_at/4 turns it
    # into the pair.
    touch("picker-area", 0.1, 0.9)
    dark = hsb()

    touch("picker-area", 0.9, 0.1)
    bright = hsb()

    assert dark != bright, "one drag changed nothing: #{inspect(dark)}"

    assert dark.s != bright.s,
           "one drag did not set saturation: #{inspect(dark)} then #{inspect(bright)}"

    assert dark.b != bright.b,
           "one drag did not set brightness: #{inspect(dark)} then #{inspect(bright)}"
  end

  @tag page: :color_picker
  test "saturation runs left to right and brightness top to bottom" do
    # sv_at/4 is the exact inverse of what the square paints. Forgetting to flip y puts
    # the ring in the wrong half, and the readout is the only thing that can say so.
    touch("picker-area", 0.95, 0.05)
    hi = hsb()

    touch("picker-area", 0.05, 0.05)
    lo = hsb()

    # Same row, so brightness matches; only saturation should differ, and it grows to the
    # right.
    assert hi != lo, "left and right of the square read the same: #{inspect(hi)}"

    assert hi.s > lo.s,
           "saturation does not grow to the right: #{inspect(lo)} then #{inspect(hi)}"

    assert hi.b == lo.b, "the same row read two brightnesses: #{inspect(lo)} vs #{inspect(hi)}"

    # And brightness falls going down the square.
    touch("picker-area", 0.5, 0.95)
    bottom = hsb()

    assert bottom.b < hi.b,
           "brightness does not fall toward the bottom: #{inspect(hi)} then #{inspect(bottom)}"
  end

  @tag page: :color_picker
  test "the pickers own hue strip is a separate control" do
    # The picker owns TWO canvases and they must not collide: the square is "<id>-area"
    # and the strip beneath it "<id>-hue".
    assert_shown("picker-hue", message: "the picker's hue strip has no tag of its own")

    touch("picker-hue", 0.15)
    a = hsb()

    touch("picker-hue", 0.85)
    b = hsb()

    assert a != b, "the picker's hue strip did nothing: #{inspect(a)}"

    assert a.h != b.h,
           "the picker's hue strip did not set the hue: #{inspect(a)} then #{inspect(b)}"
  end

  # ── The pages ──────────────────────────────────────────────────────────────

  test "no colour page still ships a slider under its canvas" do
    # The user asked for these to be removed: the drawn control IS the control, and a
    # Slider underneath was scaffolding from before Mob delivered drag positions.
    for {slug, marker, tag} <- [
          {:hue_slider, "one per two units", "hue-strip"},
          {:alpha_slider, "really shows through", "alpha-track"},
          {:angle_slider, "increasing clockwise", "angle-dial"}
        ] do
      fresh_page(slug)

      assert_text(marker)
      assert_shown(tag)
      refute has_type?(render_tree(), :slider), "the #{slug} page still renders a slider"
    end
  end

  # ── helpers ────────────────────────────────────────────────────────────────

  defp hsb do
    text = readout(@hsb) || flunk("no H/S/B readout on screen")

    [h, s, b] =
      text
      |> then(&Regex.run(@hsb, &1, capture: :all_but_first))
      |> Enum.map(&String.to_integer/1)

    %{h: h, s: s, b: b}
  end

  defp has_type?(%{type: type, children: children}, wanted),
    do: type == wanted or Enum.any?(children || [], &has_type?(&1, wanted))

  defp has_type?(_leaf, _wanted), do: false
end
