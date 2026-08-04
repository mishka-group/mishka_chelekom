defmodule MishkaMob.Components.MishkaContextMenuTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaContextMenu, MishkaMenu}

  defp items,
    do: [MishkaMenu.item(:rename, "Rename"), MishkaMenu.item(:delete, "Delete", danger: true)]

  test "renders through Menu — same surface, same rows" do
    ctx = MishkaContextMenu.context_menu(%{open: true, on_select: :act}, items())
    menu = MishkaMenu.menu(%{open: true, on_select: :act}, items())

    assert ctx == menu
  end

  test "for_label is prepended as a heading, naming the subject" do
    tree = MishkaContextMenu.context_menu(%{open: true, for_label: "report.pdf"}, items())

    assert text(tree) =~ "report.pdf"
    # …and it is a muted label, not a tappable row
    label = find(tree, :text, text: "report.pdf")
    assert label.props.text_color == :muted
    assert label.props.text_size == :xs
  end

  test "the heading comes FIRST, above the actions" do
    tree = MishkaContextMenu.context_menu(%{open: true, for_label: "report.pdf"}, items())
    texts = tree |> find_all(:text) |> Enum.map(& &1.props.text)

    assert hd(texts) == "report.pdf"
  end

  test "for_label is not leaked into Menu's own props" do
    tree = MishkaContextMenu.context_menu(%{open: true, for_label: "x"}, items())

    refute Map.has_key?(tree.props, :for_label)
  end

  test "the actions still carry their ids and danger tint" do
    tree = MishkaContextMenu.context_menu(%{open: true, for_label: "x", on_select: :act}, items())

    taps = tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)
    assert [{_, {:act, :rename}}, {_, {:act, :delete}}] = taps
    assert find(tree, :text, text: "Delete").props.text_color == :error
  end

  test "renders nothing when closed" do
    assert MishkaContextMenu.context_menu(%{for_label: "x"}, items()) ==
             %{type: :column, props: %{}, children: []}
  end

  test "expand/3 uses the tag's children" do
    assert MishkaContextMenu.expand(%{open: true, for_label: "x"}, items(), %{screen: self()}) ==
             MishkaContextMenu.context_menu(%{open: true, for_label: "x"}, items())
  end

  test "every variant renders" do
    for props <- [%{open: true}, %{open: true, for_label: "x"}, %{open: false}] do
      assert_renderable(MishkaContextMenu.context_menu(props, items()))
    end
  end

  describe "trigger/3" do
    test "a long press opens it — the touch equivalent of the web's right-click" do
      node = MishkaContextMenu.trigger(:report, [], on_hold: :hold)

      # on_long_press, not on_tap: a plain tap passes through so the row keeps
      # doing whatever it already did.
      assert node.props.on_long_press == {self(), {:hold, :report}}
      refute Map.has_key?(node.props, :on_tap)
    end

    test "no handler, no gesture" do
      refute MishkaContextMenu.trigger(:report, [])
             |> Map.fetch!(:props)
             |> Map.has_key?(:on_long_press)
    end

    test "it wraps its children and can carry a test tag" do
      child = %{type: :text, props: %{text: "report.pdf"}, children: []}
      node = MishkaContextMenu.trigger(:report, [child], test_id: "row-report")

      assert node.children == [child]
      assert node.props.id == "row-report"
    end
  end
end
