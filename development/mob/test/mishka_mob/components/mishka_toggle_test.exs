defmodule MishkaMob.Components.MishkaToggleTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaToggle

  test "is a square-cornered button-like Box, not Mob's Toggle (which is a switch)" do
    node = MishkaToggle.toggle(label: "B", on_change: :bold)

    assert node.type == :box
    assert node.props.corner_radius == :radius_md
    refute node.type == :toggle
    assert find_all(node, :toggle) == []
  end

  test "pressed fills with the accent; unpressed stays on the raised surface" do
    on = MishkaToggle.toggle(label: "B", pressed: true)
    off = MishkaToggle.toggle(label: "B")

    assert on.props.background == :primary
    assert find(on, :text).props.text_color == :on_primary
    assert off.props.background == :surface_raised
    assert find(off, :text).props.text_color == :on_surface
  end

  test "colour and text colour are overridable when pressed" do
    node =
      MishkaToggle.toggle(label: "B", pressed: true, color: 0xFF7C3AED, text_color: 0xFFFFFFFF)

    assert node.props.background == 0xFF7C3AED
    assert find(node, :text).props.text_color == 0xFFFFFFFF
  end

  test "disabled mutes it and wires no handler, pressed or not" do
    node = MishkaToggle.toggle(label: "B", pressed: true, disabled: true, on_change: :bold)

    refute Map.has_key?(node.props, :on_tap)
    assert find(node, :text).props.text_color == :muted
    assert node.props.background == :surface_raised
  end

  test "the handler is widened to {pid, tag}" do
    assert MishkaToggle.toggle(label: "B", on_change: :bold).props.on_tap == {self(), :bold}
  end

  test "children replace the label" do
    icon = [%{type: :text, props: %{text: "★"}, children: []}]
    node = MishkaToggle.toggle(%{label: "B"}, icon)

    assert text(node) =~ "★"
    refute text(node) =~ "B"
  end

  test "expand/3 uses the tag's children" do
    icon = [%{type: :text, props: %{text: "★"}, children: []}]

    assert MishkaToggle.expand(%{}, icon, %{screen: self()}) == MishkaToggle.toggle(%{}, icon)
  end

  test "every variant renders" do
    for props <- [%{}, %{label: "B"}, %{label: "B", pressed: true}, %{label: "B", disabled: true}] do
      assert_renderable(MishkaToggle.toggle(props))
    end
  end
end
