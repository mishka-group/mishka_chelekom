defmodule MishkaMob.Components.MishkaActionIconTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaActionIcon, MishkaCloseButton}

  doctest MishkaMob.Components.MishkaActionIcon

  describe "the tap target" do
    test "defaults to 40, NOT the glyph size — an icon-sized target is the classic bug" do
      node = MishkaActionIcon.action_icon(icon: "✕")

      assert node.props.width == 40
      assert node.props.height == 40
    end

    test "can be shrunk deliberately" do
      assert MishkaActionIcon.action_icon(icon: "✕", size: 28).props.width == 28
    end

    test "content is centred in it" do
      assert MishkaActionIcon.action_icon(icon: "✕").props.align == :center
    end
  end

  describe "shape" do
    test "a circle is exactly half the size, at any size" do
      assert MishkaActionIcon.radius(:circle, 40) == 20.0
      assert MishkaActionIcon.radius(:circle, 56) == 28.0

      assert MishkaActionIcon.action_icon(icon: "x", shape: :circle, size: 56).props.corner_radius ==
               28.0
    end

    test "rounded uses a radius token" do
      assert MishkaActionIcon.radius(:rounded, 40) == :radius_md
    end
  end

  describe "variant" do
    test "plain is transparent; filled sits on a raised surface" do
      assert MishkaActionIcon.action_icon(icon: "x").props.background == :transparent

      assert MishkaActionIcon.action_icon(icon: "x", variant: :filled).props.background ==
               :surface_raised
    end

    test "the fill is overridable" do
      node = MishkaActionIcon.action_icon(icon: "x", variant: :filled, background: 0xFF7C3AED)

      assert node.props.background == 0xFF7C3AED
    end
  end

  describe "behaviour" do
    test "the handler is widened to {pid, tag}" do
      assert MishkaActionIcon.action_icon(icon: "x", on_tap: :menu).props.on_tap ==
               {self(), :menu}
    end

    test "disabled wires no handler and mutes the glyph" do
      node = MishkaActionIcon.action_icon(icon: "x", disabled: true, on_tap: :menu)

      refute Map.has_key?(node.props, :on_tap)
      assert find(node, :text).props.text_color == :muted
    end

    test "children replace the glyph" do
      art = [%{type: :text, props: %{text: "★"}, children: []}]
      node = MishkaActionIcon.action_icon(%{icon: "x"}, art)

      assert text(node) =~ "★"
      refute text(node) =~ "x"
    end

    test "is never a Button" do
      assert find_all(MishkaActionIcon.action_icon(icon: "x", on_tap: :m), :button) == []
    end
  end

  describe "close button" do
    test "is the action icon with a ✕ and a circle baked in" do
      node = MishkaCloseButton.close_button(on_tap: :dismiss)

      assert text(node) =~ "✕"
      assert node.props.corner_radius == 20.0
      assert node.props.on_tap == {self(), :dismiss}
    end

    test "inherits the finger-sized default" do
      assert MishkaCloseButton.close_button().props.width == 40
    end

    test "its defaults can still be overridden" do
      node = MishkaCloseButton.close_button(icon: "✖", shape: :rounded, size: 32)

      assert text(node) =~ "✖"
      assert node.props.corner_radius == :radius_md
      assert node.props.width == 32
    end

    test "expand/3 delegates" do
      assert MishkaCloseButton.expand(%{on_tap: :x}, [], %{screen: self()}) ==
               MishkaCloseButton.close_button(on_tap: :x)
    end
  end

  test "expand/3 uses the tag's children" do
    art = [%{type: :text, props: %{text: "★"}, children: []}]

    assert MishkaActionIcon.expand(%{}, art, %{screen: self()}) ==
             MishkaActionIcon.action_icon(%{}, art)
  end

  test "every variant renders" do
    for props <- [%{}, %{icon: "x"}, %{icon: "x", variant: :filled}, %{icon: "x", disabled: true}] do
      assert_renderable(MishkaActionIcon.action_icon(props))
    end
  end
end
