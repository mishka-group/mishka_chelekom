defmodule MishkaMob.Components.MishkaMenuTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaMenu, MishkaPopover}

  defp items do
    [
      MishkaMenu.label("MANAGE"),
      MishkaMenu.item(:edit, "Edit", icon: "✎"),
      MishkaMenu.item(:archive, "Archive", disabled: true),
      MishkaMenu.separator(),
      MishkaMenu.item(:delete, "Delete", danger: true)
    ]
  end

  defp build(props \\ %{}),
    do: MishkaMenu.menu(Map.merge(%{open: true, on_select: :pick}, props), items())

  defp rows(tree), do: find_all(tree, :row)

  describe "open gate" do
    test "renders nothing when closed" do
      assert MishkaMenu.menu(%{}, items()) == %{type: :column, props: %{}, children: []}
    end
  end

  describe "the surface is the Popover's" do
    test "same shell, so a menu and a popover cannot drift apart" do
      tree = build()

      assert tree.props.border_color == MishkaPopover.panel(%{}, []).props.border_color
      assert tree.props.corner_radius == MishkaPopover.panel(%{}, []).props.corner_radius
    end

    test "but with a tighter default padding, because rows carry their own" do
      assert build().props.padding == 6
    end
  end

  describe "items" do
    test "every label renders" do
      tree = build()

      for label <- ["MANAGE", "Edit", "Archive", "Delete"], do: assert(text(tree) =~ label)
    end

    test "an icon renders before its label" do
      tree = build()
      row = rows(tree) |> Enum.find(&(text(&1) =~ "Edit"))

      assert [%{props: %{text: "✎"}}, %{type: :spacer}, %{props: %{text: "Edit"}}] = row.children
    end

    test "rows are tappable boxes, never Buttons (a Button centres its label)" do
      assert find_all(build(), :button) == []
    end

    test "each item reports the same tag widened with its own id" do
      taps =
        build()
        |> find_all(:box)
        |> Enum.map(& &1.props[:on_tap])
        |> Enum.reject(&is_nil/1)

      assert [{pid, {:pick, :edit}}, {_, {:pick, :delete}}] = taps
      assert pid == self()
    end

    test "a disabled item wires no handler and is muted" do
      tree = build()

      assert find(tree, :text, text: "Archive").props.text_color == :muted
    end

    test "no on_select means nothing is tappable" do
      tree = MishkaMenu.menu(%{open: true}, items())

      assert tree |> find_all(:box) |> Enum.all?(&(&1.props[:on_tap] == nil))
    end
  end

  describe "danger" do
    test "a destructive item is tinted so it does not look like the rest" do
      assert find(build(), :text, text: "Delete").props.text_color == 0xFFDC2626
    end

    test "the tint is overridable" do
      tree = build(%{danger_color: 0xFF991B1B})

      assert find(tree, :text, text: "Delete").props.text_color == 0xFF991B1B
    end

    test "a disabled danger item is muted, not red" do
      tree =
        MishkaMenu.menu(%{open: true}, [MishkaMenu.item(:x, "X", danger: true, disabled: true)])

      assert find(tree, :text, text: "X").props.text_color == :muted
    end
  end

  describe "structure" do
    test "a separator renders a divider line" do
      tree = build()
      lines = tree |> find_all(:box) |> Enum.filter(&(&1.props[:height] == 1))

      assert length(lines) == 1
    end

    test "a label is muted and small, and is not tappable" do
      tree = build()
      label = find(tree, :text, text: "MANAGE")

      assert label.props.text_color == :muted
      assert label.props.text_size == :xs
    end
  end

  test "expand/3 uses the tag's children as the items" do
    assert MishkaMenu.expand(%{open: true, on_select: :pick}, items(), %{screen: self()}) ==
             build()
  end

  test "every variant renders" do
    for props <- [%{open: true}, %{open: true, width: 200}, %{open: false}] do
      assert_renderable(MishkaMenu.menu(props, items()))
    end
  end
end
