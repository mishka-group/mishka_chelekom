defmodule MishkaMob.Components.MishkaMenubarTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaMenubar

  @menus [
    %{label: "File", value: :file, items: [%{label: "New", value: :new}]},
    %{label: "Edit", value: :edit, items: [%{label: "Undo", value: :undo}]},
    %{label: "View", value: :view, items: [%{label: "Zoom", value: :zoom}]}
  ]

  # The bar's Row is the first child of the root Column, and each trigger sits
  # in a Row of its own beside a 4-wide spacer.
  defp bar(tree), do: tree.children |> hd()
  defp triggers(tree), do: tree |> bar() |> Map.fetch!(:children) |> Enum.map(&hd(&1.children))

  describe "the bar's width" do
    test "every trigger hugs its label, so each menu in a row keeps room to draw" do
      # A Box given neither a width nor `fill_width: false` fills its parent. In
      # the bar's Row the first trigger took the whole row, left Edit and View
      # zero wide and wrapped their labels a letter per line: the screenshot
      # showed only "File", with the bar standing tall and empty.
      tree = MishkaMenubar.menubar(menus: @menus)

      assert [file, edit, view] = triggers(tree)

      for trigger <- [file, edit, view] do
        assert trigger.type == :box
        assert trigger.props.fill_width == false
        refute Map.has_key?(trigger.props, :width)
      end
    end

    test "no node under a trigger fills the width either" do
      tree = MishkaMenubar.menubar(menus: @menus)

      for trigger <- triggers(tree) do
        assert trigger |> flatten() |> Enum.filter(&(&1.props[:fill_width] == true)) == []
      end
    end

    test "one trigger per menu, each carrying its own label" do
      tree = MishkaMenubar.menubar(menus: @menus)

      assert tree |> triggers() |> Enum.map(&text/1) == ["File", "Edit", "View"]
    end

    test "the bar is a filling row, and its triggers are the only things in it" do
      tree = MishkaMenubar.menubar(menus: @menus)

      assert bar(tree).type == :row
      assert bar(tree).props.fill_width == true
      assert [_file, _edit, _view] = bar(tree).children
    end

    test "opening a menu does not change how its trigger lays out" do
      closed = MishkaMenubar.menubar(menus: @menus)
      open = MishkaMenubar.menubar(menus: @menus, open: :edit)

      assert [_, edit, _] = triggers(open)
      assert edit.props.fill_width == false
      assert edit.props.background == :surface_raised
      assert triggers(closed) |> Enum.map(& &1.props.fill_width) == [false, false, false]
    end

    test "the open panel still fills the bar's width beneath the row" do
      tree = MishkaMenubar.menubar(menus: @menus, open: :file)

      # The panel is a sibling of the row, in the Column, where filling is right.
      assert [_row, panel] = tree.children
      assert panel.type == :column
      assert panel.props.fill_width == true
    end
  end
end
