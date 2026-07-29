defmodule MishkaMob.Components.MishkaCodeTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaCode

  describe "monospace" do
    test "both forms ask for the platform's real mono face" do
      assert find(MishkaCode.code(text: "x"), :text).props.font == "monospace"
      assert find(MishkaCode.code(text: "x", block: true), :text).props.font == "monospace"
    end
  end

  describe "inline" do
    test "hugs its text — fill_width FALSE, no scroller" do
      # This asserted the ABSENCE of fill_width and called that hugging. Absence
      # is the opposite: a Box told neither width nor fill_width fills its
      # parent, so inline code rendered as a full-width bar while the test and
      # the moduledoc both said it hugged.
      tree = MishkaCode.code(text: "mix test")

      assert tree.type == :box
      assert tree.props.fill_width == false
      assert find_all(tree, :scroll) == []
      assert text(tree) =~ "mix test"
    end

    test "an id becomes a testTag on whichever variant is built" do
      assert MishkaCode.code(text: "x", id: "snippet").props.id == "snippet"
      assert MishkaCode.code(text: "x", block: true, id: "snippet").props.id == "snippet"
      refute Map.has_key?(MishkaCode.code(text: "x").props, :id)
    end

    test "uses a tight default padding" do
      assert MishkaCode.code(text: "x").props.padding == 4
    end
  end

  describe "block" do
    test "fills the width and pads generously" do
      tree = MishkaCode.code(text: "x", block: true)

      assert tree.props.fill_width == true
      assert tree.props.padding == :space_md
    end

    test "scrolls HORIZONTALLY by default — code lines do not wrap" do
      scroller = find(MishkaCode.code(text: "x", block: true), :scroll)

      assert scroller.props.axis == "horizontal"
    end

    test "scroll: false clips instead, with no scroller in the tree" do
      tree = MishkaCode.code(text: "x", block: true, scroll: false)

      assert find_all(tree, :scroll) == []
      assert text(tree) =~ "x"
    end
  end

  describe "styling" do
    test "colours and size are overridable in both forms" do
      for block <- [true, false] do
        tree =
          MishkaCode.code(
            text: "x",
            block: block,
            background: 0xFF0B1020,
            color: 0xFF93C5FD,
            text_size: :base
          )

        assert tree.props.background == 0xFF0B1020
        assert find(tree, :text).props.text_color == 0xFF93C5FD
        assert find(tree, :text).props.text_size == :base
      end
    end

    test "padding is overridable" do
      assert MishkaCode.code(text: "x", padding: 12).props.padding == 12
      assert MishkaCode.code(text: "x", block: true, padding: 2).props.padding == 2
    end
  end

  test "expand/3 delegates to code/1" do
    assert MishkaCode.expand(%{text: "x"}, [], %{screen: self()}) == MishkaCode.code(text: "x")
  end

  test "every variant renders" do
    for props <- [
          %{},
          %{text: "x"},
          %{text: "x", block: true},
          %{text: "x", block: true, scroll: false}
        ] do
      assert_renderable(MishkaCode.code(props))
    end
  end
end
