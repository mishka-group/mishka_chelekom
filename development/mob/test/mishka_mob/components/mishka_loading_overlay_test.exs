defmodule MishkaMob.Components.MishkaLoadingOverlayTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaLoadingOverlay

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

  describe "the body is centred, and reads as a loader" do
    # Regression: the body was a `<Column fill_width={false}>`, and a Column
    # cannot align its children — Android maps it to a bare Compose Column with
    # no horizontalAlignment, iOS to `VStack(alignment: .leading)` under an
    # unconditional `.frame(maxWidth: .infinity, alignment: .topLeading)`. So the
    # narrow label left-aligned against the 140dp bar (visibly off centre on
    # Android) and the whole body pinned to the far left edge on iOS.
    test "every part sits in its own centring Box" do
      tree = MishkaLoadingOverlay.loading_overlay(%{visible: true, label: "Saving…"})
      centred = tree |> find_all(:box) |> Enum.filter(&(&1.props[:align] == :center))

      # The scrim, the indicator's box and the label's box, at least.
      assert [_, _, _ | _] = centred
      assert Enum.all?(find_all(tree, :column), &(&1.props[:align] == nil))
    end

    test "no Column relies on fill_width for placement — iOS ignores it" do
      tree = MishkaLoadingOverlay.loading_overlay(%{visible: true, label: "Saving…"})

      assert Enum.all?(find_all(tree, :column), &(&1.props[:fill_width] != false))
    end

    test "the indicator and label sit on a fixed-width panel" do
      tree = MishkaLoadingOverlay.loading_overlay(%{visible: true, label: "Saving…"})
      panel = tree |> find_all(:box) |> Enum.find(&(&1.props[:background] == :surface))

      # A lone 4dp bar on a big scrim reads as a stray divider; the panel is what
      # makes it read as a loader. Fixed width because a Box cannot hug on iOS.
      assert panel.props.width == 176
      assert panel.props.corner_radius == :radius_lg
    end

    test "the panel is recoloured for a dark scrim" do
      tree =
        MishkaLoadingOverlay.loading_overlay(%{
          visible: true,
          scrim_color: 0xE6111827,
          panel_color: 0xFF1F2937
        })

      assert tree |> find_all(:box) |> Enum.any?(&(&1.props[:background] == 0xFF1F2937))
    end

    test "children own the body entirely — no panel is imposed" do
      art = [%{type: :text, props: %{text: "custom"}, children: []}]
      tree = MishkaLoadingOverlay.loading_overlay(%{visible: true}, art)

      refute tree |> find_all(:box) |> Enum.any?(&(&1.props[:width] == 176))
    end
  end

  test "every variant renders" do
    variants = [
      %{visible: true},
      %{visible: true, label: "Saving…"},
      %{visible: true, scrim_color: 0x99000000, panel_color: 0xFF1F2937, corner_radius: 8}
    ]

    for props <- variants do
      assert_renderable(MishkaLoadingOverlay.loading_overlay(props))
    end
  end
end
