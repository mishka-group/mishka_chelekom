defmodule MishkaMob.Components.MishkaNavigationMenuTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaNavigationMenu

  @items [
    %{
      label: "Products",
      value: :products,
      content: [%{type: :text, props: %{text: "panel"}, children: []}]
    },
    %{
      label: "Docs",
      value: :docs,
      content: [%{type: :text, props: %{text: "docs"}, children: []}]
    },
    %{label: "Blog", value: :blog}
  ]

  # The bar is the first child of the root Column; each item sits in a Row of
  # its own beside a 4-wide spacer.
  defp bar(tree), do: tree.children |> hd()
  defp items(tree), do: tree |> bar() |> Map.fetch!(:children) |> Enum.map(&hd(&1.children))

  describe "a horizontal bar" do
    test "every item hugs its label, so each one in the row keeps room to draw" do
      # A Box given neither a width nor `fill_width: false` fills its parent. In
      # the bar's Row the first item took the whole row, left Docs and Blog zero
      # wide and wrapped their labels a letter per line: the screenshot showed
      # only "Products", with the bar standing tall and empty.
      tree = MishkaNavigationMenu.navigation_menu(items: @items)

      assert bar(tree).type == :row
      assert [products, docs, blog] = items(tree)

      for item <- [products, docs, blog] do
        assert item.type == :box
        assert item.props.fill_width == false
        refute Map.has_key?(item.props, :width)
      end
    end

    test "no node under an item fills the width either" do
      tree = MishkaNavigationMenu.navigation_menu(items: @items)

      for item <- items(tree) do
        assert item |> flatten() |> Enum.filter(&(&1.props[:fill_width] == true)) == []
      end
    end

    test "an item per entry, in order, with a chevron only on the triggers" do
      tree = MishkaNavigationMenu.navigation_menu(items: @items)
      [products, docs, blog] = items(tree)

      labels = for item <- [products, docs, blog], do: find(item, :text).props.text
      assert labels == ["Products", "Docs", "Blog"]

      assert text(products) =~ "▸"
      assert text(docs) =~ "▸"
      refute text(blog) =~ "▸"
    end

    test "the open item keeps hugging, and is the only one raised" do
      tree = MishkaNavigationMenu.navigation_menu(items: @items, value: :docs)
      [products, docs, blog] = items(tree)

      assert Enum.map([products, docs, blog], & &1.props.fill_width) == [false, false, false]
      assert docs.props.background == :surface_raised
      assert products.props.background == :transparent
      assert text(docs) =~ "▾"
    end
  end

  describe "a vertical bar" do
    test "stacks the items in a column and lets each fill it, so the whole line taps" do
      tree = MishkaNavigationMenu.navigation_menu(items: @items, orientation: :vertical)

      assert bar(tree).type == :column
      assert [_, _, _] = items(tree)
      assert Enum.all?(items(tree), &(&1.props.fill_width == true))
    end
  end

  test "the open panel is a sibling of the bar and still fills the width" do
    tree = MishkaNavigationMenu.navigation_menu(items: @items, value: :products)

    assert [_bar, viewport] = tree.children
    assert viewport.props.fill_width == true
    assert text(viewport) =~ "panel"
  end
end
