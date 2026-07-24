defmodule MishkaMob.Components.MishkaChipTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaChip

  describe "shape" do
    test "is a pill-shaped tappable box holding its label" do
      node = MishkaChip.chip(label: "Elixir", on_toggle: :pick)

      assert node.type == :box
      assert node.props.corner_radius == :radius_pill
      assert node.props.padding == :space_sm
      assert text(node) =~ "Elixir"
    end

    test "is never a Button — a Material Button brings its own shape and centring" do
      assert find_all(MishkaChip.chip(label: "Elixir", on_toggle: :p), :button) == []
    end
  end

  describe "checked state" do
    test "unchecked reads as a raised surface with normal text" do
      node = MishkaChip.chip(label: "Elixir")

      assert node.props.background == :surface_raised
      assert find(node, :text).props.text_color == :on_surface
    end

    test "checked fills with the accent colour" do
      node = MishkaChip.chip(label: "Elixir", checked: true)

      assert node.props.background == :primary
      assert find(node, :text).props.text_color == :on_primary
    end

    test "colour and text_color are overridable when checked" do
      node = MishkaChip.chip(label: "E", checked: true, color: 0xFF7C3AED, text_color: 0xFFFFFFFF)

      assert node.props.background == 0xFF7C3AED
      assert find(node, :text).props.text_color == 0xFFFFFFFF
    end

    test "the accent colour is ignored while unchecked" do
      node = MishkaChip.chip(label: "E", color: 0xFF7C3AED)

      assert node.props.background == :surface_raised
    end
  end

  describe "disabled" do
    test "wires no handler and mutes the label, even when checked" do
      node = MishkaChip.chip(label: "E", checked: true, disabled: true, on_toggle: :pick)

      refute Map.has_key?(node.props, :on_tap)
      assert find(node, :text).props.text_color == :muted
      assert node.props.background == :surface_raised
    end
  end

  describe "the handler" do
    test "a bare tag is widened to {pid, tag}" do
      assert MishkaChip.chip(label: "E", on_toggle: :pick).props.on_tap == {self(), :pick}
    end

    test "a tuple tag is widened too, so one handler can serve many chips" do
      assert MishkaChip.chip(label: "E", on_toggle: {:tag, :elixir}).props.on_tap ==
               {self(), {:tag, :elixir}}
    end

    test "no on_toggle means no handler at all" do
      refute Map.has_key?(MishkaChip.chip(label: "E").props, :on_tap)
    end
  end

  describe "composite tag" do
    test "expand/3 delegates to chip/1 and ignores children" do
      children = [%{type: :text, props: %{text: "ignored"}, children: []}]

      assert MishkaChip.expand(%{label: "E"}, children, %{screen: self()}) ==
               MishkaChip.chip(label: "E")
    end
  end

  test "every variant renders" do
    for props <- [%{}, %{label: "E"}, %{label: "E", checked: true}, %{label: "E", disabled: true}] do
      assert_renderable(MishkaChip.chip(props))
    end
  end
end
