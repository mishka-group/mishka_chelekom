defmodule MishkaMob.Components.MishkaChipTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaChip

  describe "shape" do
    test "is a pill-shaped tappable box holding its label" do
      node = MishkaChip.chip(label: "Elixir", on_toggle: :pick)

      pill = node

      # A Button, because it is the only node that reads fill_width on BOTH
      # platforms — iOS's MobBox ignores it, so a Box can only hug by carrying an
      # explicit width, which a label's width is not.
      assert node.type == :button
      assert pill.props.fill_width == false
      assert pill.props.corner_radius == :radius_pill

      assert node.props.text == "Elixir"
    end

    test "hugs its label rather than filling the row" do
      short = MishkaChip.chip(label: "S")
      long = MishkaChip.chip(label: "A considerably longer chip label")

      for tree <- [short, long] do
        assert tree.type == :button
        assert tree.props.fill_width == false
        refute Map.has_key?(tree.props, :width)
      end
    end

    test "carries its own pill radius rather than inheriting Material's shape" do
      node = MishkaChip.chip(label: "Elixir", on_toggle: :p)

      assert node.props.corner_radius == :radius_pill
      assert find_all(node, :box) == []
    end
  end

  describe "checked state" do
    test "unchecked reads as a raised surface with normal text" do
      node = MishkaChip.chip(label: "Elixir")

      pill = node

      assert pill.props.background == :surface_raised
      assert node.props.text_color == :on_surface
    end

    test "checked fills with the accent colour" do
      node = MishkaChip.chip(label: "Elixir", checked: true)

      pill = node

      assert pill.props.background == :primary
      assert node.props.text_color == :on_primary
    end

    test "colour and text_color are overridable when checked" do
      node = MishkaChip.chip(label: "E", checked: true, color: 0xFF7C3AED, text_color: 0xFFFFFFFF)

      pill = node

      assert pill.props.background == 0xFF7C3AED
      assert node.props.text_color == 0xFFFFFFFF
    end

    test "the accent colour is ignored while unchecked" do
      node = MishkaChip.chip(label: "E", color: 0xFF7C3AED)

      pill = node

      assert pill.props.background == :surface_raised
    end
  end

  describe "disabled" do
    test "wires no handler, and a disabled chip still shows whether it is checked" do
      on = MishkaChip.chip(label: "E", checked: true, disabled: true, on_toggle: :pick)
      off = MishkaChip.chip(label: "E", checked: false, disabled: true, on_toggle: :pick)

      refute Map.has_key?(on.props, :on_tap)
      assert on.props.text_color == :muted

      # This used to assert both were :surface_raised, which pinned the bug: a
      # locked-ON chip looked exactly like a locked-OFF one.
      assert on.props.background == :muted
      assert off.props.background == :surface_raised
    end
  end

  describe "the handler" do
    test "a bare tag is widened to {pid, tag}" do
      assert MishkaChip.chip(label: "E", on_toggle: :pick).props.on_tap ==
               {self(), :pick}
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

  test "disabled does not erase checked — a locked-on chip still reads as on" do
    on = MishkaChip.chip(label: "Locked on", checked: true, disabled: true)
    off = MishkaChip.chip(label: "Locked off", checked: false, disabled: true)

    refute on.props.background == off.props.background
  end
end
