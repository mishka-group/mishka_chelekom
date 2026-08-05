defmodule MishkaMob.Components.ColorTest do
  use ExUnit.Case, async: true

  alias MishkaMob.Components.Color

  doctest MishkaMob.Components.Color

  describe "parse/1" do
    test "accepts both lengths, either case, with or without the hash" do
      assert Color.parse("#3B82F6") == {:ok, {59, 130, 246}}
      assert Color.parse("3b82f6") == {:ok, {59, 130, 246}}
      assert Color.parse("  #fff  ") == {:ok, {255, 255, 255}}
    end

    test "expands shorthand the way CSS does — doubling, not padding" do
      assert Color.parse("#f00") == {:ok, {255, 0, 0}}
      refute Color.parse("#f00") == {:ok, {0xF0, 0, 0}}
    end

    test "rejects anything that is not a whole hex colour" do
      for bad <- ["", "#", "#12", "#1234", "#12345", "#1234567", "#gggggg", "blue", nil, 42] do
        assert Color.parse(bad) == :error, "expected #{inspect(bad)} to be rejected"
      end
    end
  end

  describe "hsv_to_rgb/3" do
    test "hits the primaries at each 120° step" do
      assert Color.hsv_to_rgb(0, 100, 100) == {255, 0, 0}
      assert Color.hsv_to_rgb(120, 100, 100) == {0, 255, 0}
      assert Color.hsv_to_rgb(240, 100, 100) == {0, 0, 255}
      assert Color.hsv_to_rgb(360, 100, 100) == {255, 0, 0}
    end

    test "and the secondaries between them" do
      assert Color.hsv_to_rgb(60, 100, 100) == {255, 255, 0}
      assert Color.hsv_to_rgb(180, 100, 100) == {0, 255, 255}
      assert Color.hsv_to_rgb(300, 100, 100) == {255, 0, 255}
    end

    test "zero saturation is grey at whatever brightness, whatever the hue" do
      assert Color.hsv_to_rgb(0, 0, 50) == Color.hsv_to_rgb(200, 0, 50)
      assert Color.hsv_to_rgb(200, 0, 100) == {255, 255, 255}
    end

    test "zero brightness is black regardless of hue and saturation" do
      assert Color.hsv_to_rgb(90, 100, 0) == {0, 0, 0}
    end

    test "clamps out-of-range saturation and value instead of producing junk" do
      assert Color.hsv_to_rgb(0, 500, 500) == {255, 0, 0}
      assert Color.hsv_to_rgb(0, -50, -50) == {0, 0, 0}
    end
  end

  describe "rgb_to_hsv/1" do
    test "round-trips every primary and secondary exactly" do
      for hue <- [0, 60, 120, 180, 240, 300] do
        assert Color.rgb_to_hsv(Color.hsv_to_rgb(hue, 100, 100)) == {hue, 100, 100}
      end
    end

    test "greys report no hue and no saturation" do
      assert Color.rgb_to_hsv({0, 0, 0}) == {0, 0, 0}
      assert Color.rgb_to_hsv({255, 255, 255}) == {0, 0, 100}
      assert Color.rgb_to_hsv({128, 128, 128}) == {0, 0, 50}
    end

    test "a full hex round trip lands within one unit per channel" do
      for hex <- ["#3b82f6", "#123456", "#00ff00", "#ffffff", "#000000", "#7c3aed"] do
        {:ok, {r, g, b}} = Color.parse(hex)
        {h, s, v} = Color.rgb_to_hsv({r, g, b})
        {:ok, {r2, g2, b2}} = Color.parse(Color.hsv_to_hex(h, s, v))

        assert abs(r - r2) <= 1 and abs(g - g2) <= 1 and abs(b - b2) <= 1,
               "#{hex} round-tripped to #{Color.hex({r2, g2, b2})}"
      end
    end
  end

  describe "argb/2" do
    test "packs the alpha byte from a percentage" do
      assert Color.argb({255, 0, 0}, 100) == 0xFFFF0000
      assert Color.argb({255, 0, 0}, 0) == 0x00FF0000
      assert Color.argb({0, 0, 0}, 100) == 0xFF000000
    end

    test "clamps rather than overflowing into the neighbouring channel" do
      assert Color.argb({300, -20, 128}) == 0xFFFF0080
      assert Color.argb({0, 0, 0}, 200) == 0xFF000000
    end

    test "defaults to fully opaque" do
      assert Color.argb({1, 2, 3}) == Color.argb({1, 2, 3}, 100)
    end
  end

  describe "hex/1" do
    test "pads single digits so the string is always seven characters" do
      assert Color.hex({0, 0, 0}) == "#000000"
      assert Color.hex({1, 2, 3}) == "#010203"
      assert String.length(Color.hex({15, 15, 15})) == 7
    end

    test "is lowercase, matching what the field shows" do
      assert Color.hex({255, 255, 255}) == "#ffffff"
    end
  end

  describe "legibility" do
    test "light? follows luma, not raw magnitude" do
      # Pure green is far brighter to the eye than pure blue at the same value.
      assert Color.light?({0, 255, 0})
      refute Color.light?({0, 0, 255})
    end

    test "ink_on picks the readable one at both ends" do
      assert Color.ink_on({255, 255, 255}) == 0xFF111827
      assert Color.ink_on({0, 0, 0}) == 0xFFFFFFFF
    end
  end

  describe "wrap_hue/1" do
    test "wraps in both directions and keeps the endpoints distinct" do
      assert Color.wrap_hue(0) == 0.0
      assert Color.wrap_hue(360) == 0.0
      assert Color.wrap_hue(720 + 45) == 45.0
      assert Color.wrap_hue(-370) == 350.0
    end
  end
end
