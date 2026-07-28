defmodule MishkaMob.Components.MishkaMarkTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaMark

  test "is a Text inside a tinted Box, because Text carries no background" do
    node = MishkaMark.mark(text: "BEAM")

    assert node.type == :box
    assert node.props.background == MishkaMark.default_fill()
    assert [%{type: :text, props: %{text: "BEAM"}}] = node.children
  end

  test "is as wide as its text, not as wide as the line" do
    # A Box told neither width nor fill_width FILLS its parent, which turned
    # every mark into a full-width bar — the opposite of what <mark> means, and
    # invisible to a tree assertion that only looks at the text inside it.
    assert MishkaMark.mark(text: "BEAM").props.fill_width == false
  end

  test "pairs a light fill with dark ink so it reads in either theme" do
    node = MishkaMark.mark(text: "BEAM")

    assert find(node, :text).props.text_color == MishkaMark.default_ink()
    # explicit ARGB, not a theme token that could flip to light-on-light
    assert is_integer(node.props.background)
    assert is_integer(find(node, :text).props.text_color)
  end

  test "fill, ink and size are overridable" do
    node = MishkaMark.mark(text: "x", background: 0xFFBBF7D0, color: 0xFF000000, text_size: :sm)

    assert node.props.background == 0xFFBBF7D0
    assert find(node, :text).props.text_color == 0xFF000000
    assert find(node, :text).props.text_size == :sm
  end

  test "accepts a map as well as a keyword list" do
    assert MishkaMark.mark(%{text: "x"}) == MishkaMark.mark(text: "x")
  end

  test "expand/3 delegates to mark/1 and ignores children" do
    children = [%{type: :text, props: %{text: "ignored"}, children: []}]

    assert MishkaMark.expand(%{text: "x"}, children, %{screen: self()}) ==
             MishkaMark.mark(text: "x")
  end

  test "every variant renders" do
    for props <- [%{}, %{text: "x"}, %{text: "x", background: 0xFFBBF7D0}] do
      assert_renderable(MishkaMark.mark(props))
    end
  end
end
