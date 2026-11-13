defmodule MishkaMob.Components.MishkaListItemTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaListItem

  defp txt(value), do: %{type: :text, props: %{text: value}, children: []}
  defp box, do: %{type: :box, props: %{width: 30, height: 30}, children: []}

  describe "the row" do
    test "is a fill-width Row whose body takes the space between the slots" do
      node = MishkaListItem.list_item(%{leading: box()}, [txt("Title")])

      assert node.type == :row
      assert node.props.fill_width == true
      assert node.props.align == :center

      assert [leading, gap, body] = node.children
      assert leading == box()
      assert gap.props.size == 13
      assert body.type == :column
      assert body.props.weight == 1.0
      assert [%{props: %{text: "Title"}}] = body.children
    end

    test "the trailing gap is its own number" do
      node = MishkaListItem.list_item(%{leading: box(), trailing: txt("›")}, [txt("Title")])

      assert [_, _gap, _body, trailing_gap, %{props: %{text: "›"}}] = node.children
      assert trailing_gap.props.size == 12
    end

    test "a missing slot leaves no spacer behind" do
      node = MishkaListItem.list_item(%{}, [txt("Only a body")])

      assert [%{type: :column}] = node.children
    end

    test "gap numbers are overridable" do
      node =
        MishkaListItem.list_item(
          %{leading: box(), trailing: txt("›"), gap: 16, trailing_gap: 8},
          [txt("Title")]
        )

      assert [_, %{props: %{size: 16}}, _body, %{props: %{size: 8}}, _] = node.children
    end

    test "on_tap and on_long_press are widened and padding is forwarded" do
      node =
        MishkaListItem.list_item(
          %{
            on_tap: :open,
            on_long_press: :manage,
            padding_top: 14,
            padding_bottom: 14
          },
          [txt("Title")]
        )

      assert node.props.on_tap == {self(), :open}
      assert node.props.on_long_press == {self(), :manage}
      assert node.props.padding_top == 14
      assert node.props.padding_bottom == 14
    end

    test "renders" do
      assert_renderable(MishkaListItem.list_item(%{leading: box()}, [txt("Title")]))
    end
  end

  test "expand/3 uses the tag's children as the body" do
    body = [txt("Title")]

    assert MishkaListItem.expand(%{leading: box()}, body, %{screen: self()}) ==
             MishkaListItem.list_item(%{leading: box()}, body)
  end
end
