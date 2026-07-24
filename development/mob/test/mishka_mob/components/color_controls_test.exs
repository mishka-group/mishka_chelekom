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

        assert marker.x1 >= 2 and marker.x1 <= 298
      end
    end

    test "the slider spans the full wheel and reports changes" do
      slider = MishkaHueSlider.hue_slider(value: 90, on_change: :hue) |> find(:slider)

      assert slider.props.min == 0
      assert slider.props.max == 360
      assert slider.props.value == 90.0
      assert slider.props.on_change == {self(), :hue}
    end

    test "hues past 360 wrap rather than pinning the marker" do
      wrapped = MishkaHueSlider.hue_slider(value: 380) |> find(:slider)

      assert wrapped.props.value == 20.0
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

    test "runs 0..100, not 0..1" do
      slider = MishkaAlphaSlider.alpha_slider(value: 60, on_change: :a) |> find(:slider)

      assert {slider.props.min, slider.props.max} == {0, 100}
      assert slider.props.on_change == {self(), :a}
    end

    test "clamps out-of-range opacity" do
      assert MishkaAlphaSlider.alpha_slider(value: 300) |> find(:slider) |> then(& &1.props.value) ==
               100
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

    test "the slider covers a full turn and reports changes" do
      slider = MishkaAngleSlider.angle_slider(value: 45, on_change: :angle) |> find(:slider)

      assert {slider.props.min, slider.props.max} == {0, 360}
      assert slider.props.on_change == {self(), :angle}
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

    test "there is a slider per axis, because a 2D drag is not available" do
      tree =
        MishkaColorPicker.color_picker(on_hue: :h, on_saturation: :s, on_value: :v)

      tags = tree |> find_all(:slider) |> Enum.map(& &1.props[:on_change])

      assert tags == [{self(), :h}, {self(), :s}, {self(), :v}]
    end

    test "the preview reports the colour and stays legible over it" do
      dark = MishkaColorPicker.color_picker(hue: 0, saturation: 100, value: 10)
      light = MishkaColorPicker.color_picker(hue: 0, saturation: 0, value: 100)

      # find/2 returns the first text node, which is a slider's axis label — the
      # readout is the one carrying a hex string.
      readout = fn tree ->
        tree |> find_all(:text) |> Enum.find(&String.starts_with?(&1.props.text, "#"))
      end

      assert readout.(dark).props.text_color == 0xFFFFFFFF
      assert readout.(light).props.text_color == 0xFF111827
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
