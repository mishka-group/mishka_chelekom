defmodule MishkaMob.Components.MishkaPopoverTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaPopover

  defp content, do: [%{type: :text, props: %{text: "panel body"}, children: []}]

  describe "open gate" do
    test "renders nothing when closed" do
      assert MishkaPopover.popover(%{}, content()) == %{type: :column, props: %{}, children: []}

      assert MishkaPopover.popover(%{open: false}, content()) == %{
               type: :column,
               props: %{},
               children: []
             }
    end

    test "renders the panel when open" do
      tree = MishkaPopover.popover(%{open: true}, content())

      assert tree.type == :box
      assert text(tree) =~ "panel body"
    end
  end

  describe "the panel shell" do
    test "carries a border, so it reads as separate from the content beneath" do
      tree = MishkaPopover.panel(%{}, content())

      assert tree.props.border_color == :border
      assert tree.props.border_width == 1
    end

    test "defaults: surface fill, rounded, padded, filling its parent" do
      tree = MishkaPopover.panel(%{}, content())

      assert tree.props.background == :surface
      assert tree.props.corner_radius == :radius_md
      assert tree.props.padding == :space_md
      assert tree.props.fill_width == true
    end

    test "a width replaces fill_width rather than fighting it" do
      tree = MishkaPopover.panel(%{width: 240}, content())

      assert tree.props.width == 240
      refute Map.has_key?(tree.props, :fill_width)
    end

    test "chrome is overridable, border included" do
      tree =
        MishkaPopover.panel(
          %{background: 0xFF1E1B4B, corner_radius: 4, padding: 2, border_width: 0},
          content()
        )

      assert tree.props.background == 0xFF1E1B4B
      assert tree.props.corner_radius == 4
      assert tree.props.padding == 2
      assert tree.props.border_width == 0
    end
  end

  describe "offsets are a nudge, not anchoring" do
    test "are omitted unless asked for" do
      props = MishkaPopover.panel(%{}, content()).props

      refute Map.has_key?(props, :offset_x)
      refute Map.has_key?(props, :offset_y)
    end

    test "are passed through when given" do
      props = MishkaPopover.panel(%{offset_x: 8, offset_y: -4}, content()).props

      assert props.offset_x == 8
      assert props.offset_y == -4
    end
  end

  test "expand/3 uses the tag's children as the content" do
    assert MishkaPopover.expand(%{open: true}, content(), %{screen: self()}) ==
             MishkaPopover.popover(%{open: true}, content())
  end

  test "every variant renders" do
    for props <- [%{open: true}, %{open: true, width: 200}, %{open: true, border_width: 0}] do
      assert_renderable(MishkaPopover.popover(props, content()))
    end
  end
end
