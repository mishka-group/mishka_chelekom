defmodule MishkaMob.Components.MishkaToggleTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaToggle

  test "is a square-cornered button-like Box, not Mob's Toggle (which is a switch)" do
    node = MishkaToggle.toggle(label: "B", on_change: :bold)

    assert node.type == :box
    assert node.props.corner_radius == :radius_md
    # No `refute node.type == :toggle` — the assert above already pins it to
    # :box, so the compiler proves that redundant. The tree-wide check is the
    # one that carries meaning: nothing anywhere below is Mob's Toggle either.
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

  test "disabled wires no handler, pressed or not" do
    on = MishkaToggle.toggle(label: "B", pressed: true, disabled: true, on_change: :bold)
    off = MishkaToggle.toggle(label: "B", disabled: true, on_change: :bold)

    refute Map.has_key?(on.props, :on_tap)
    refute Map.has_key?(off.props, :on_tap)
  end

  test "a disabled toggle still SHOWS whether it is pressed" do
    on = MishkaToggle.toggle(label: "B", pressed: true, disabled: true)
    off = MishkaToggle.toggle(label: "B", disabled: true)

    # Greyed rather than accented, but still filled. If disabled fell back to the
    # idle background, "locked on" and "locked off" would render identically and
    # the user could not see what they are locked into — the rule the chip
    # settled on, and what the web's disabled group shows.
    assert on.props.background == :muted
    assert off.props.background == :surface_raised
    refute find(on, :text).props.text_color == find(off, :text).props.text_color
  end

  describe "layout" do
    test "hugs its label by default — a Box with no width would fill its parent" do
      # This is the bug that made every toggle a full-width slab and a row of
      # them impossible. It is the chip's trap, one component over.
      assert MishkaToggle.toggle(label: "B").props.fill_width == false
    end

    test "fill_width: true is available for a toggle that should span" do
      assert MishkaToggle.toggle(label: "B", fill_width: true).props.fill_width == true
    end
  end

  describe "styling is the caller's" do
    test "every visual prop is overridable" do
      node =
        MishkaToggle.toggle(
          label: "B",
          padding: 20,
          corner_radius: 4,
          border_color: :primary,
          border_width: 2,
          background: :background,
          label_color: :muted,
          text_size: :sm
        )

      assert node.props.padding == 20
      assert node.props.corner_radius == 4
      assert node.props.border_color == :primary
      assert node.props.border_width == 2
      assert node.props.background == :background
      assert find(node, :text).props.text_color == :muted
      assert find(node, :text).props.text_size == :sm
    end

    test "border_width: 0 removes the border, for a segmented bar's inner buttons" do
      assert MishkaToggle.toggle(label: "B", border_width: 0).props.border_width == 0
    end
  end

  describe "the test tag carries the state" do
    # Pressed differs from idle by FILL COLOUR alone, and colour is not in the
    # accessibility tree — without this a device test cannot see a press at all.
    test "pressed and idle are distinguishable by tag" do
      assert MishkaToggle.toggle(label: "B", id: "bold", pressed: true).props.id == "bold-pressed"
      assert MishkaToggle.toggle(label: "B", id: "bold").props.id == "bold-idle"
    end

    test "no id leaves the node untagged" do
      refute Map.has_key?(MishkaToggle.toggle(label: "B", pressed: true).props, :id)
    end
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
