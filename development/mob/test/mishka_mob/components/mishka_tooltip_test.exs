defmodule MishkaMob.Components.MishkaTooltipTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaPopover, MishkaTooltip}

  test "renders nothing when closed, so it takes no space in the layout" do
    assert MishkaTooltip.tooltip(text: "x") == %{type: :column, props: %{}, children: []}

    assert MishkaTooltip.tooltip(text: "x", open: false) == %{
             type: :column,
             props: %{},
             children: []
           }
  end

  test "is a compact dark bubble when open" do
    tree = MishkaTooltip.tooltip(text: "Copy", open: true)

    assert tree.type == :box
    assert tree.props.background == 0xFF111827
    assert find(tree, :text).props.text_color == 0xFFFFFFFF
    assert find(tree, :text).props.text_size == :sm
    assert text(tree) =~ "Copy"
  end

  test "is deliberately NOT the Popover shell — a hint is not a panel" do
    tip = MishkaTooltip.tooltip(text: "x", open: true)
    panel = MishkaPopover.panel(%{}, [])

    # no border, tighter padding, and a dark fill rather than the surface
    refute Map.has_key?(tip.props, :border_width)
    refute tip.props.background == panel.props.background
    refute tip.props.padding == panel.props.padding
  end

  test "colours and size are overridable" do
    tree =
      MishkaTooltip.tooltip(
        text: "x",
        open: true,
        background: 0xFF7C3AED,
        color: 0xFF000000,
        text_size: :base
      )

    assert tree.props.background == 0xFF7C3AED
    assert find(tree, :text).props.text_color == 0xFF000000
    assert find(tree, :text).props.text_size == :base
  end

  test "offsets are omitted unless asked for" do
    props = MishkaTooltip.tooltip(text: "x", open: true).props

    refute Map.has_key?(props, :offset_x)
    refute Map.has_key?(props, :offset_y)

    nudged = MishkaTooltip.tooltip(text: "x", open: true, offset_x: 6, offset_y: -2).props
    assert nudged.offset_x == 6
    assert nudged.offset_y == -2
  end

  test "expand/3 delegates to tooltip/1" do
    assert MishkaTooltip.expand(%{text: "x", open: true}, [], %{screen: self()}) ==
             MishkaTooltip.tooltip(text: "x", open: true)
  end

  test "every variant renders" do
    for props <- [%{open: true}, %{text: "x", open: true}, %{text: "x", open: false}] do
      assert_renderable(MishkaTooltip.tooltip(props))
    end
  end
end
