defmodule MishkaMob.Components.ColorControlsTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{
    Color,
    MishkaAlphaSlider,
    MishkaAngleSlider,
    MishkaColorInput,
    MishkaColorPicker,
    MishkaHueSlider
  }

  doctest MishkaMob.Components.MishkaHueSlider
  doctest MishkaMob.Components.MishkaAlphaSlider
  doctest MishkaMob.Components.MishkaAngleSlider
  doctest MishkaMob.Components.MishkaColorPicker
  doctest MishkaMob.Components.MishkaColorInput

  defp canvas(tree), do: find(tree, :canvas)
  defp ops(tree), do: canvas(tree).props.draw
  defp ops_of(tree, op), do: Enum.filter(ops(tree), &(&1.op == op))

  # Canvas is missing from mob 0.7.20's tag whitelist but is rendered by both
  # bridges; see the note in MishkaMob.ShowcaseTest.
  defp assert_draws(tree), do: assert_renderable(tree, extra: [:canvas])

  describe "hue slider" do
    test "paints a spectrum whose bands sweep the whole wheel" do
      tree = MishkaHueSlider.hue_slider(value: 0, width: 300, height: 16)
      bands = ops_of(tree, :rect)

      assert Enum.count_until(bands, 101) == 101, "expected a smooth strip, got #{length(bands)}"

      first = List.first(bands).color
      middle = Enum.at(bands, div(length(bands), 2)).color

      # Red at the left, cyan-ish halfway round — a real sweep, not one colour.
      assert first == Color.argb({255, 0, 0})
      refute middle == first
    end

    test "the marker tracks the value across the track" do
      left = MishkaHueSlider.hue_slider(value: 0, width: 300) |> ops_of(:line) |> List.first()
      right = MishkaHueSlider.hue_slider(value: 359, width: 300) |> ops_of(:line) |> List.first()

      assert left.x1 < right.x1
    end

    test "the marker stays inside the track at both extremes" do
      for hue <- [0, 360] do
        [marker | _] = MishkaHueSlider.hue_slider(value: hue, width: 300) |> ops_of(:line)

        # Half the 3px stroke, so the marker never clips and never sits visibly
        # short of the edge the finger is aiming at.
        assert marker.x1 >= 1.5 and marker.x1 <= 298.5
      end
    end

    # The bug this pins: hue is wrapped with fmod, and fmod(360.0, 360.0) is 0.0,
    # so the far end of the strip teleported the marker back to the near end.
    # "Inside the track" was true of both positions, which is why the test above
    # stayed green through it — the assertion has to be about WHICH end.
    test "360 sits at the far end of the strip, not back at the start" do
      [at_360 | _] = MishkaHueSlider.hue_slider(value: 360, width: 300) |> ops_of(:line)
      [at_0 | _] = MishkaHueSlider.hue_slider(value: 0, width: 300) |> ops_of(:line)

      assert at_360.x1 > 290
      assert at_0.x1 < 10
    end

    test "a full turn draws the dial's ring instead of erasing it" do
      # arc/4 skips a zero sweep, and 360 collapsing to 0.0 met that guard — so
      # the dial vanished at exactly the maximum.
      assert MishkaAngleSlider.angle_slider(value: 360) |> ops_of(:arc) != []
    end

    test "the strip itself is the control — no separate slider under it" do
      tree = MishkaHueSlider.hue_slider(value: 90, on_change: :hue)
      strip = find(tree, :canvas)

      # on_drag, not on_change: a drawn control needs the touch POSITION, and
      # {:change, tag, value} carries none. The whole reason a native Slider used
      # to sit underneath was that this handler had nowhere to come from.
      assert strip.props.on_drag == {self(), :hue}
      refute find(tree, :slider)
    end

    test "hue_at is the inverse of the marker, so finger and marker agree" do
      for x <- [0, 75, 150, 225, 300] do
        hue = MishkaHueSlider.hue_at(x, 300)
        [marker | _] = MishkaHueSlider.hue_slider(value: hue, width: 300) |> ops_of(:line)

        assert_in_delta marker.x1, x, 1.6
      end
    end

    test "hues past 360 wrap rather than pinning the marker" do
      [wrapped | _] = MishkaHueSlider.hue_slider(value: 380, width: 300) |> ops_of(:line)
      [at_20 | _] = MishkaHueSlider.hue_slider(value: 20, width: 300) |> ops_of(:line)

      assert wrapped.x1 == at_20.x1
    end

    test "the header appears only when asked for" do
      refute find(MishkaHueSlider.hue_slider(value: 10), :row)
      assert text(MishkaHueSlider.hue_slider(value: 10, show_value: true)) =~ "10°"
      assert text(MishkaHueSlider.hue_slider(value: 10, label: "Hue")) =~ "Hue"
    end
  end

  describe "alpha slider" do
    test "lays the colour over a checkerboard, fading in from transparent" do
      tree = MishkaAlphaSlider.alpha_slider(value: 50, color: "#ff0000", width: 64, height: 16)
      fades = ops(tree) |> Enum.filter(&Map.has_key?(&1, :opacity))

      assert List.first(fades).opacity == 0.0
      assert List.last(fades).opacity == 1.0
      assert Enum.all?(fades, &(&1.color == Color.argb({255, 0, 0})))
    end

    test "the checkerboard alternates two shades" do
      tree = MishkaAlphaSlider.alpha_slider(width: 64, height: 16)

      shades =
        ops(tree)
        |> Enum.reject(&Map.has_key?(&1, :opacity))
        |> Enum.filter(&(&1.op == :rect))
        |> Enum.map(& &1.color)
        |> Enum.uniq()

      assert match?([_, _], shades)
    end

    test "an unparseable colour falls back to black rather than crashing" do
      tree = MishkaAlphaSlider.alpha_slider(color: "not a colour")
      fades = ops(tree) |> Enum.filter(&Map.has_key?(&1, :opacity))

      assert Enum.all?(fades, &(&1.color == Color.argb({0, 0, 0})))
      assert_draws(tree)
    end

    test "the track itself is the control — no separate slider under it" do
      tree = MishkaAlphaSlider.alpha_slider(value: 60, on_change: :a)

      # on_drag, not on_change: a drawn control needs the touch POSITION, and
      # {:change, tag, value} carries none.
      assert find(tree, :canvas).props.on_drag == {self(), :a}
      refute find(tree, :slider)
    end

    test "runs 0..100, not 0..1" do
      assert MishkaAlphaSlider.alpha_at(300, 300) == 100.0
      assert MishkaAlphaSlider.alpha_at(150, 300) == 50.0
    end

    test "clamps out-of-range opacity to the track's far end" do
      [at_300 | _] = MishkaAlphaSlider.alpha_slider(value: 300, width: 300) |> ops_of(:line)
      [at_100 | _] = MishkaAlphaSlider.alpha_slider(value: 100, width: 300) |> ops_of(:line)

      assert at_300.x1 == at_100.x1
      assert at_300.x1 > 290
    end

    test "alpha_at is the inverse of the marker, so finger and marker agree" do
      for x <- [0, 75, 150, 225, 300] do
        alpha = MishkaAlphaSlider.alpha_at(x, 300)
        [marker | _] = MishkaAlphaSlider.alpha_slider(value: alpha, width: 300) |> ops_of(:line)

        assert_in_delta marker.x1, x, 1.6
      end
    end

    test "shows a percentage, not a fraction" do
      assert text(MishkaAlphaSlider.alpha_slider(value: 60, show_value: true)) =~ "60%"
    end
  end

  describe "angle slider" do
    test "0° points up and 90° points right" do
      assert MishkaAngleSlider.point_on_dial(50, 50, 40, 0) == {50.0, 10.0}
      assert MishkaAngleSlider.point_on_dial(50, 50, 40, 90) == {90.0, 50.0}
      assert MishkaAngleSlider.point_on_dial(50, 50, 40, 180) == {50.0, 90.0}
      assert MishkaAngleSlider.point_on_dial(50, 50, 40, 270) == {10.0, 50.0}
    end

    test "the arc starts at the top and sweeps to the angle" do
      [arc] = MishkaAngleSlider.angle_slider(value: 90) |> ops_of(:arc)

      assert arc.start_deg == -90
      assert arc.end_deg == 0
    end

    test "at zero there is no arc at all — a round cap would draw a blob" do
      assert MishkaAngleSlider.angle_slider(value: 0) |> ops_of(:arc) == []
    end

    test "the handle sits on the ring, and moves with the value" do
      handle = fn angle ->
        MishkaAngleSlider.angle_slider(value: angle, size: 160)
        |> ops_of(:circle)
        |> List.last()
      end

      top = handle.(0)
      right = handle.(90)

      assert top.y < right.y
      assert right.x > top.x
    end

    test "the reading is centred text, and can be turned off" do
      [reading] = MishkaAngleSlider.angle_slider(value: 45) |> ops_of(:text)

      assert reading.text == "45°"
      assert reading.anchor == :center
      assert MishkaAngleSlider.angle_slider(value: 45, show_value: false) |> ops_of(:text) == []
    end

    test "wraps past a full turn" do
      [reading] = MishkaAngleSlider.angle_slider(value: 450) |> ops_of(:text)

      assert reading.text == "90°"
    end

    test "the ring itself is the control — no separate slider under it" do
      tree = MishkaAngleSlider.angle_slider(value: 45, on_change: :angle)

      assert find(tree, :canvas).props.on_drag == {self(), :angle}
      refute find(tree, :slider)
    end

    test "angle_at inverts point_on_dial, so the knob follows the finger" do
      for deg <- [0, 45, 90, 180, 270, 315] do
        {x, y} = MishkaAngleSlider.point_on_dial(80, 80, 70, deg)

        assert_in_delta MishkaAngleSlider.angle_at(x, y, 160), deg, 0.001
      end
    end

    # Near the centre the angle swings through a whole turn over a few pixels,
    # so a fingertip resting there would spin the value. :dead is what a caller
    # ignores rather than assigns.
    test "a touch near the centre reports :dead rather than a wild angle" do
      assert MishkaAngleSlider.angle_at(80, 80, 160) == :dead
      assert MishkaAngleSlider.angle_at(84, 82, 160) == :dead
      refute MishkaAngleSlider.angle_at(80, 20, 160) == :dead
    end
  end

  describe "color picker" do
    test "the area is saturation across x and darkness down y" do
      tree = MishkaColorPicker.color_picker(hue: 0, saturation: 50, value: 50)
      rects = ops_of(tree, :rect)

      sat_bands = Enum.reject(rects, &Map.has_key?(&1, :opacity))
      val_bands = Enum.filter(rects, &Map.has_key?(&1, :opacity))

      # White at the left edge, full hue at the right.
      assert List.first(sat_bands).color == Color.argb({255, 255, 255})
      assert List.last(sat_bands).color == Color.argb({255, 0, 0})

      # Clear at the top, black at the bottom.
      assert List.first(val_bands).opacity == 0.0
      assert Enum.all?(val_bands, &(&1.color == Color.argb({0, 0, 0})))
    end

    test "the crosshair follows saturation and brightness" do
      cross = fn s, v ->
        MishkaColorPicker.color_picker(saturation: s, value: v)
        |> ops_of(:circle)
        |> List.first()
      end

      assert cross.(10, 50).x < cross.(90, 50).x
      # High brightness sits near the TOP, so y decreases as value rises.
      assert cross.(50, 90).y < cross.(50, 10).y
    end

    test "both axes are dragged on the square; no sliders inside the component" do
      tree = MishkaColorPicker.color_picker(on_hue: :h, on_area: :area)

      handlers =
        tree |> find_all(:canvas) |> Enum.map(& &1.props[:on_drag]) |> Enum.reject(&is_nil/1)

      # The square first, then the hue strip nested inside it.
      assert handlers == [{self(), :area}, {self(), :h}]

      # A labelled slider per axis is a SCREEN's way of driving the picker, not
      # part of the picker. One drag on the square already sets both.
      refute find(tree, :slider)
    end

    test "sv_at inverts the area, so the ring lands under the finger" do
      assert MishkaColorPicker.sv_at(0, 0, 260, 180) == {0.0, 100.0}
      assert MishkaColorPicker.sv_at(260, 180, 260, 180) == {100.0, 0.0}
      assert MishkaColorPicker.sv_at(130, 90, 260, 180) == {50.0, 50.0}
    end

    test "sv_at clamps a touch that leaves the square" do
      assert MishkaColorPicker.sv_at(-50, -50, 260, 180) == {0.0, 100.0}
      assert MishkaColorPicker.sv_at(999, 999, 260, 180) == {100.0, 0.0}
    end

    test "the component is the square and the strip, and nothing else" do
      tree = MishkaColorPicker.color_picker(hue: 210, saturation: 48, value: 58)

      # A swatch, a hex readout and a slider per axis are all things a SCREEN
      # builds around the picker. The picker is the two canvases.
      assert tree |> find_all(:canvas) |> length() == 2
      refute find(tree, :slider)
      refute tree |> find_all(:text) |> Enum.any?(&String.starts_with?(&1.props.text, "#"))
    end

    test "ink_on keeps a readout legible over the colour it reports" do
      # The showcase draws the swatch now, but the contrast choice is the
      # library's and is what actually breaks if it regresses.
      assert Color.ink_on(Color.hsv_to_rgb(0, 100, 10)) == 0xFFFFFFFF
      assert Color.ink_on(Color.hsv_to_rgb(0, 0, 100)) == 0xFF111827
    end

    test "the preview can be hidden, for embedding in a panel" do
      tree = MishkaColorPicker.color_picker(show_preview: false)

      refute text(tree) =~ "#"
    end

    test "hsv/1 clamps and wraps; hex/1 reports the result" do
      assert MishkaColorPicker.hsv(%{hue: 400, saturation: 120, value: -5}) == {40.0, 100, 0}
      assert MishkaColorPicker.hex(%{hue: 0, saturation: 100, value: 100}) == "#ff0000"
    end
  end

  describe "color input" do
    test "the swatch opens the panel, not just the trigger" do
      tree = MishkaColorInput.color_input(value: "#3b82f6", on_toggle: :open)

      taps = tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)

      # Both the swatch and the ▾ trigger. The swatch is the most colour-like
      # thing on the row, so it is what a finger reaches for first.
      assert length(taps) == 2
      assert Enum.all?(taps, &(&1 == {self(), :open}))
    end

    test "a disabled input wires neither of them" do
      tree = MishkaColorInput.color_input(disabled: true, on_toggle: :open)

      assert tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1) ==
               []
    end

    # The panel embeds a picker, so it has to forward the picker's OWN event
    # props. When those were renamed, color_input kept passing the old ones —
    # which is not an error: the square simply rendered and could not be
    # dragged. Nothing failed, which is why this test exists.
    test "the open panel forwards handlers to both of the picker's canvases" do
      tree = MishkaColorInput.color_input(open: true, on_hue: :h, on_area: :area)

      handlers =
        tree |> find_all(:canvas) |> Enum.map(& &1.props[:on_drag]) |> Enum.reject(&is_nil/1)

      assert {self(), :area} in handlers
      assert {self(), :h} in handlers
    end

    test "a closed panel renders no picker at all" do
      assert MishkaColorInput.color_input(open: false, on_area: :area) |> find_all(:canvas) == []
    end

    test "the swatch shows the field's colour" do
      tree = MishkaColorInput.color_input(value: "#ff0000")

      assert find(tree, :box).props.background == Color.argb({255, 0, 0})
      assert find(tree, :text_field).props.value == "#ff0000"
    end

    test "a half-typed hex shows the surface, not a misleading colour" do
      tree = MishkaColorInput.color_input(value: "#3b82")

      assert find(tree, :box).props.background == :surface_raised
      # …and the field still shows exactly what was typed.
      assert find(tree, :text_field).props.value == "#3b82"
    end

    test "three digits is a real colour, not a half-typed six" do
      # CSS shorthand: #3b8 is #33bb88. Treating it as incomplete would refuse
      # to commit a value the user had finished typing.
      assert MishkaColorInput.commit("#3b8") ==
               {:ok, Color.rgb_to_hsv({51, 187, 136})}

      assert MishkaColorInput.color_input(value: "#3b8")
             |> find(:box)
             |> then(& &1.props.background) ==
               Color.argb({51, 187, 136})
    end

    test "commit/2 waits until the text parses" do
      assert MishkaColorInput.commit("#ff0000") == {:ok, {0, 100, 100}}
      assert MishkaColorInput.commit("#ff00") == :incomplete
      assert MishkaColorInput.commit("") == :incomplete
      assert MishkaColorInput.commit(nil) == :incomplete
    end

    test "the panel appears only when open, in flow under the control" do
      closed = MishkaColorInput.color_input(value: "#3b82f6")
      open = MishkaColorInput.color_input(value: "#3b82f6", open: true)

      refute canvas(closed)
      assert canvas(open)
    end

    test "the trigger flips its glyph and reports taps" do
      closed = MishkaColorInput.color_input(on_toggle: :toggle)
      open = MishkaColorInput.color_input(open: true, on_toggle: :toggle)

      assert text(closed) =~ "▾"
      assert text(open) =~ "▴"

      trigger = closed |> find_all(:box) |> Enum.find(&(&1.props[:on_tap] != nil))
      assert trigger.props.on_tap == {self(), :toggle}
    end

    test "an open panel follows the field's colour without being told" do
      tree = MishkaColorInput.color_input(value: "#ff0000", open: true)
      sat_bands = ops(tree) |> Enum.filter(&(&1.op == :rect and not Map.has_key?(&1, :opacity)))

      assert List.last(sat_bands).color == Color.argb({255, 0, 0})
    end

    test "explicit picker props win over the field's colour" do
      tree = MishkaColorInput.color_input(value: "#ff0000", open: true, hue: 240)
      sat_bands = ops(tree) |> Enum.filter(&(&1.op == :rect and not Map.has_key?(&1, :opacity)))

      assert List.last(sat_bands).color == Color.argb({0, 0, 255})
    end

    test "disabled unwires the field and the trigger" do
      tree = MishkaColorInput.color_input(disabled: true, on_change: :hex, on_toggle: :toggle)

      refute Map.has_key?(find(tree, :text_field).props, :on_change)
      assert tree |> find_all(:box) |> Enum.all?(&(&1.props[:on_tap] == nil))
    end
  end

  describe "composite tags" do
    test "each expander delegates to its function component" do
      ctx = %{screen: self()}

      assert MishkaHueSlider.expand(%{value: 10}, [], ctx) ==
               MishkaHueSlider.hue_slider(value: 10)

      assert MishkaAlphaSlider.expand(%{value: 10}, [], ctx) ==
               MishkaAlphaSlider.alpha_slider(value: 10)

      assert MishkaAngleSlider.expand(%{value: 10}, [], ctx) ==
               MishkaAngleSlider.angle_slider(value: 10)

      assert MishkaColorPicker.expand(%{hue: 10}, [], ctx) ==
               MishkaColorPicker.color_picker(hue: 10)

      assert MishkaColorInput.expand(%{value: "#fff"}, [], ctx) ==
               MishkaColorInput.color_input(value: "#fff")
    end
  end

  test "every variant renders" do
    for tree <- [
          MishkaHueSlider.hue_slider(),
          MishkaHueSlider.hue_slider(value: 400, label: "H", show_value: true),
          MishkaAlphaSlider.alpha_slider(),
          MishkaAlphaSlider.alpha_slider(value: 0, color: "#zzz"),
          MishkaAngleSlider.angle_slider(),
          MishkaAngleSlider.angle_slider(value: 359, show_value: false, label: "A"),
          MishkaColorPicker.color_picker(),
          MishkaColorPicker.color_picker(hue: 0, saturation: 0, value: 0, show_preview: false),
          MishkaColorInput.color_input(),
          MishkaColorInput.color_input(value: "#bad", open: true, label: "L", disabled: true)
        ] do
      assert_draws(tree)
    end
  end
end
