defmodule MishkaMob.Components.MishkaTextInputTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaTextInput

  describe "the field" do
    test "is a text field carrying only the props it was given" do
      node = MishkaTextInput.text_input(value: "Dune", placeholder: "Title", fill_width: true)

      assert node.type == :text_field
      assert node.props.value == "Dune"
      assert node.props.placeholder == "Title"
      assert node.props.fill_width == true

      refute Map.has_key?(node.props, :multiline)
      refute Map.has_key?(node.props, :background)
    end

    test "value_epoch reaches the bridge" do
      node = MishkaTextInput.text_input(value: "", value_epoch: 3)

      assert node.props.value_epoch == 3
    end

    test "events are widened to {pid, tag}" do
      node = MishkaTextInput.text_input(on_change: :typed, on_submit: :done)

      assert node.props.on_change == {self(), :typed}
      assert node.props.on_submit == {self(), :done}
      refute Map.has_key?(node.props, :on_focus)
    end

    test "renders" do
      assert_renderable(MishkaTextInput.text_input(placeholder: "Search"))
    end
  end

  describe "leading and trailing" do
    test "with neither, the node is the field itself" do
      node = MishkaTextInput.text_input(value: "x")

      assert node.type == :text_field
    end

    test "a slot wraps the field in a fill-width row with a gap either side" do
      leading = %{type: :text, props: %{text: "⌕"}, children: []}
      trailing = %{type: :text, props: %{text: "⚙"}, children: []}

      node = MishkaTextInput.text_input(leading: leading, trailing: trailing, slot_gap: 6)

      assert node.type == :row
      assert node.props.fill_width == true
      assert node.props.align == :center
      assert [^leading, gap, %{type: :text_field}, gap2, ^trailing] = node.children
      assert gap.props.size == 6
      assert gap2.props.size == 6
    end

    test "one slot adds one gap" do
      leading = %{type: :text, props: %{text: "⌕"}, children: []}

      node = MishkaTextInput.text_input(leading: leading)

      assert [^leading, _gap, %{type: :text_field}] = node.children
    end
  end

  test "expand/3 ignores children" do
    assert MishkaTextInput.expand(%{placeholder: "x"}, [], %{screen: self()}) ==
             MishkaTextInput.text_input(%{placeholder: "x"})
  end
end
