defmodule MishkaMob.Components.MishkaCardTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaCard

  import Mob.Sigil

  defp txt(value), do: %{type: :text, props: %{text: value}, children: []}
  defp box, do: %{type: :box, props: %{width: 40, height: 40}, children: []}

  defp slot(type, children), do: %{type: type, props: %{}, children: children}

  describe "the surface" do
    test "is a Column carrying only the props it was given" do
      node = MishkaCard.card(%{background: :surface_raised, corner_radius: 22, padding: 17}, [])

      assert node.type == :column
      assert node.props.fill_width == true
      assert node.props.background == :surface_raised
      assert node.props.corner_radius == 22
      assert node.props.padding == 17

      refute Map.has_key?(node.props, :shadow)
      refute Map.has_key?(node.props, :border_width)
    end

    test "direction: :row is a Row, and align rides with it" do
      row = MishkaCard.card(%{direction: :row, align: :center}, [])
      column = MishkaCard.card(%{direction: :column, align: :center}, [])

      assert row.type == :row
      assert row.props.align == :center

      assert column.type == :column
      refute Map.has_key?(column.props, :align)
    end

    test "on_tap is widened to {pid, tag}" do
      assert MishkaCard.card(%{on_tap: :open}, []).props.on_tap == {self(), :open}
    end

    test "weight is passed through, and left off when unset" do
      assert MishkaCard.card(%{weight: 1.0}, []).props.weight == 1.0
      refute Map.has_key?(MishkaCard.card(%{}, []).props, :weight)
    end

    test "an empty card renders" do
      assert_renderable(MishkaCard.card())
    end
  end

  describe "min_height" do
    test "rides on the surface, and is absent when unset" do
      assert MishkaCard.card(%{min_height: 52}, []).props.min_height == 52
      refute Map.has_key?(MishkaCard.card(%{}, []).props, :min_height)
    end
  end

  describe "the body opens for a title or actions" do
    test "a title draws first and the content follows" do
      content = txt("content")
      node = MishkaCard.card(%{title: "Reading list"}, [content])

      assert [body] = node.children
      assert body.type == :column
      assert body.props.fill_width == true
      assert [title, ^content] = body.children
      assert title.props.text == "Reading list"
    end

    test "actions draw last" do
      content = txt("content")
      action = txt("Edit")
      node = MishkaCard.card(%{actions: [action]}, [content])

      assert [body] = node.children
      assert body.children == [content, action]
    end

    test "a row card gives the body the space beside the figure" do
      figure = box()
      node = MishkaCard.card(%{direction: :row, figure: figure, title: "Title"}, [])

      assert [^figure, body] = node.children
      assert body.props.weight == 1.0
    end
  end

  describe "the figure" do
    test "starts before the body by default" do
      figure = box()
      content = txt("content")

      assert [^figure, ^content] = MishkaCard.card(%{figure: figure}, [content]).children
    end

    test "figure_position: :end draws it after the body" do
      figure = box()
      content = txt("content")

      assert [^content, ^figure] =
               MishkaCard.card(%{figure: figure, figure_position: :end}, [content]).children
    end
  end

  describe "slots" do
    test "a slot wins over its prop and is consumed" do
      node =
        MishkaCard.expand(
          %{title: "from prop", figure: box(), actions: [txt("prop action")]},
          [
            slot(:mishka_card_title, [txt("from slot")]),
            txt("content"),
            slot(:mishka_card_actions, [txt("slot action")]),
            slot(:mishka_card_figure, [box()])
          ],
          %{}
        )

      assert [figure, body] = node.children
      assert figure.type == :box

      refute Enum.any?(body.children, &(&1[:type] in [:mishka_card_title, :mishka_card_actions]))
      assert [title, _content, action] = body.children
      assert title.props.text == "from slot"
      assert action.props.text == "slot action"
    end

    test "slot tags written as markup expand" do
      Mob.Composite.register(:mishka_card, {MishkaCard, :expand})

      tree =
        ~MOB"""
        <MishkaCard id="c" background={:surface_raised} corner_radius={22}>
          <MishkaCardTitle>
            <Text text="T" />
          </MishkaCardTitle>
          <MishkaCardActions>
            <Text text="Go" />
          </MishkaCardActions>
        </MishkaCard>
        """
        |> Mob.Composite.expand(self())

      assert text(tree) =~ "T"
      assert text(tree) =~ "Go"
    end
  end
end
