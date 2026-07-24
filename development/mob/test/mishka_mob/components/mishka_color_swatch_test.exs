defmodule MishkaMob.Components.MishkaColorSwatchTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaColorSwatch, MishkaLoadingOverlay}

  doctest MishkaMob.Components.MishkaColorSwatch

  describe "translucent?/1" do
    test "reads the alpha byte of an ARGB int" do
      assert MishkaColorSwatch.translucent?(0x007C3AED)
      assert MishkaColorSwatch.translucent?(0x807C3AED)
      assert MishkaColorSwatch.translucent?(0xFE7C3AED)
      refute MishkaColorSwatch.translucent?(0xFF7C3AED)
    end

    test "a theme token is never treated as translucent" do
      refute MishkaColorSwatch.translucent?(:primary)
      refute MishkaColorSwatch.translucent?(nil)
    end
  end

  describe "the checkerboard" do
    test "appears automatically for a translucent colour" do
      tree = MishkaColorSwatch.color_swatch(color: 0x807C3AED)
      tiles = tree |> find_all(:box) |> Enum.filter(&(&1.props[:width] == 18.0))

      assert length(tiles) == 4
    end

    test "is skipped for an opaque colour — the nodes would be waste" do
      tree = MishkaColorSwatch.color_swatch(color: 0xFF7C3AED)

      assert tree |> find_all(:box) |> Enum.filter(&(&1.props[:width] == 18.0)) == []
    end

    test "can be forced on or off" do
      on = MishkaColorSwatch.color_swatch(color: 0xFF7C3AED, checkerboard: true)
      off = MishkaColorSwatch.color_swatch(color: 0x807C3AED, checkerboard: false)

      refute on |> find_all(:box) |> Enum.filter(&(&1.props[:width] == 18.0)) == []
      assert off |> find_all(:box) |> Enum.filter(&(&1.props[:width] == 18.0)) == []
    end
  end

  describe "shape and selection" do
    test "a circle is exactly half the size" do
      assert MishkaColorSwatch.radius(:circle, 36) == 18.0
      assert MishkaColorSwatch.radius(:square, 36) == 0
      assert MishkaColorSwatch.radius(:rounded, 36) == :radius_sm
    end

    test "selection thickens the ring and draws a ✓" do
      on = MishkaColorSwatch.color_swatch(color: 0xFF7C3AED, selected: true)
      off = MishkaColorSwatch.color_swatch(color: 0xFF7C3AED)

      assert on.props.border_width == 2
      assert text(on) =~ "✓"
      assert off.props.border_width == 1
      refute text(off) =~ "✓"
    end

    test "children replace the ✓" do
      art = [%{type: :text, props: %{text: "★"}, children: []}]
      tree = MishkaColorSwatch.color_swatch(%{color: 0xFF7C3AED, selected: true}, art)

      assert text(tree) =~ "★"
      refute text(tree) =~ "✓"
    end
  end

  test "the handler is widened, and disabled removes it" do
    assert MishkaColorSwatch.color_swatch(color: 1, on_tap: {:pick, :a}).props.on_tap ==
             {self(), {:pick, :a}}

    refute Map.has_key?(
             MishkaColorSwatch.color_swatch(color: 1, on_tap: :x, disabled: true).props,
             :on_tap
           )
  end

  describe "loading overlay" do
    test "renders nothing when not visible" do
      assert MishkaLoadingOverlay.loading_overlay(%{}) == %{
               type: :column,
               props: %{},
               children: []
             }
    end

    test "covers its region and ABSORBS taps, so a double submit is impossible" do
      tree = MishkaLoadingOverlay.loading_overlay(%{visible: true})

      assert tree.props.fill_width == true
      assert tree.props.fill_height == true
      assert {_pid, :__mishka_loading_ignore} = tree.props.on_tap
    end

    test "uses the native indeterminate Progress — no value means it animates" do
      bar = find(MishkaLoadingOverlay.loading_overlay(%{visible: true}), :progress)

      refute Map.has_key?(bar.props, :value)
    end

    test "an optional label renders under the indicator" do
      assert text(MishkaLoadingOverlay.loading_overlay(%{visible: true, label: "Saving…"})) =~
               "Saving…"

      refute text(MishkaLoadingOverlay.loading_overlay(%{visible: true})) =~ "Saving"
    end

    test "children replace the indicator" do
      art = [%{type: :text, props: %{text: "custom"}, children: []}]
      tree = MishkaLoadingOverlay.loading_overlay(%{visible: true}, art)

      assert text(tree) =~ "custom"
      assert find_all(tree, :progress) == []
    end

    test "scrim colour and radius are overridable" do
      tree =
        MishkaLoadingOverlay.loading_overlay(%{
          visible: true,
          scrim_color: 0x99000000,
          corner_radius: 8
        })

      assert tree.props.background == 0x99000000
      assert tree.props.corner_radius == 8
    end
  end

  test "every variant renders" do
    for props <- [%{color: 0xFF7C3AED}, %{color: 0x807C3AED}, %{color: 1, selected: true}] do
      assert_renderable(MishkaColorSwatch.color_swatch(props))
    end

    assert_renderable(MishkaLoadingOverlay.loading_overlay(%{visible: true, label: "x"}))
  end
end
