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

      for key <- [:multiline, :lines, :keyboard, :font, :background] do
        refute Map.has_key?(node.props, key)
      end
    end
  end

  describe "prop names mob's text field reads" do
    test "keyboard_type is sent as keyboard, a string, from an atom or a string" do
      for {given, sent} <- [email: "email", number: "number", phone: "phone", default: "default"] do
        node = MishkaTextInput.text_input(keyboard_type: given)

        assert node.props.keyboard == sent
        refute Map.has_key?(node.props, :keyboard_type)
      end

      assert MishkaTextInput.text_input(keyboard_type: "phone").props.keyboard == "phone"
    end

    test "mob's keyboard is accepted, and wins over keyboard_type" do
      assert MishkaTextInput.text_input(keyboard: :decimal).props.keyboard == "decimal"

      node = MishkaTextInput.text_input(keyboard: "url", keyboard_type: :email)
      assert node.props.keyboard == "url"
    end

    test "font_family is sent as font; mob's font wins" do
      node = MishkaTextInput.text_input(font_family: "Inter")

      assert node.props.font == "Inter"
      refute Map.has_key?(node.props, :font_family)

      assert MishkaTextInput.text_input(font: "Mono", font_family: "Inter").props.font == "Mono"
    end

    test "multiline: true with no lines is three rows" do
      node = MishkaTextInput.text_input(multiline: true)

      assert node.props.lines == 3
      refute Map.has_key?(node.props, :multiline)
    end

    test "an explicit lines wins over multiline" do
      assert MishkaTextInput.text_input(multiline: true, lines: 5).props.lines == 5
      assert MishkaTextInput.text_input(multiline: true, lines: 1).props.lines == 1
      assert MishkaTextInput.text_input(lines: 4).props.lines == 4
    end

    test "multiline: false is a single-line field" do
      refute Map.has_key?(MishkaTextInput.text_input(multiline: false).props, :lines)
    end

    test "value_epoch, which no renderer reads, is not forwarded" do
      node = MishkaTextInput.text_input(value: "", value_epoch: 3)

      refute Map.has_key?(node.props, :value_epoch)
    end
  end

  describe "events and rendering" do
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
