defmodule MishkaMob.Components.MishkaDialogTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaDialog

  @scrim 0x99_00_00_00

  defp body, do: [%{type: :text, props: %{text: "body text"}, children: []}]
  defp actions, do: [%{type: :button, props: %{text: "OK"}, children: []}]

  defp p(extra \\ %{}), do: Map.merge(%{open: true, on_close: :close}, extra)
  defp open(extra \\ %{}), do: MishkaDialog.dialog(p(extra), body(), actions())

  defp scrim(tree), do: find(tree, :box, background: @scrim)

  describe "closed" do
    test "renders nothing when open is false or absent" do
      empty = %{type: :column, props: %{}, children: []}

      assert MishkaDialog.dialog(%{open: false}) == empty
      assert MishkaDialog.dialog(%{}) == empty
    end

    test "the body is not in the tree when closed" do
      refute text(MishkaDialog.dialog(%{open: false}, body())) =~ "body text"
    end
  end

  describe "open" do
    test "stacks scrim then a centred viewport" do
      tree = open()

      assert %{type: :box, props: %{fill_width: true, fill_height: true}} = tree
      assert [%{type: :box}, %{type: :box, props: %{align: :center}}] = tree.children
    end

    test "renders title, description, body and actions" do
      tree = open(%{title: "Delete file?", description: "Cannot be undone."})

      assert text(tree) =~ "Delete file?"
      assert text(tree) =~ "Cannot be undone."
      assert text(tree) =~ "body text"
      # button labels are a prop, not a text node, so text/1 does not see them
      assert find(tree, :button, text: "OK")
    end

    test "title and description are omitted when not given" do
      tree = MishkaDialog.dialog(p(), body(), [])

      assert text(tree) =~ "body text"
      assert find_all(tree, :text) |> Enum.map(& &1.props.text) == ["body text"]
    end
  end

  describe "the panel" do
    test "is a width-locked Box so corners clip on both platforms" do
      panel = find(open(), :box, width: 320)

      assert panel.props.corner_radius == :radius_lg
      assert panel.props.background == :surface
    end

    test "width, background, corner_radius and padding are overridable" do
      tree = open(%{width: 280, background: 0xFF1E1B4B, corner_radius: 4, padding: :space_xl})
      panel = find(tree, :box, width: 280)

      assert panel.props.background == 0xFF1E1B4B
      assert panel.props.corner_radius == 4
      assert find(panel, :column, padding: :space_xl)
    end

    test "absorbs taps so they cannot fall through and dismiss the dialog" do
      panel = find(open(), :box, width: 320)

      assert {pid, :__mishka_dialog_ignore} = panel.props.on_tap
      assert pid == self()
    end
  end

  describe "the backdrop" do
    test "dismisses by default, with a widened handler" do
      assert scrim(open()).props.on_tap == {self(), :close}
    end

    test "dismissible: false leaves it inert — the user must choose" do
      refute Map.has_key?(scrim(open(%{dismissible: false})).props, :on_tap)
    end

    test "no on_close also leaves it inert" do
      tree = MishkaDialog.dialog(%{open: true}, body(), [])

      refute Map.has_key?(scrim(tree).props, :on_tap)
    end

    test "scrim_color is overridable" do
      tree = open(%{scrim_color: 0x66000000})

      assert find(tree, :box, background: 0x66000000)
    end
  end

  describe "footer" do
    test "actions sit in a trailing-aligned row" do
      row = find(open(), :row)

      assert [%{type: :spacer, props: %{weight: 1}} | rest] = row.children
      assert Enum.any?(rest, &(&1.type == :button))
    end

    test "no actions means no footer row" do
      tree = MishkaDialog.dialog(p(), body(), [])

      assert find_all(tree, :row) == []
    end
  end

  describe "composite tag" do
    test "expand/3 uses the tag's children as the body and the ctx screen pid" do
      tree = MishkaDialog.expand(p(), body(), %{screen: self()})

      assert text(tree) =~ "body text"
      assert find(tree, :box, width: 320).props.on_tap == {self(), :__mishka_dialog_ignore}
    end
  end

  test "every variant renders" do
    for extra <- [%{}, %{title: "T"}, %{dismissible: false}, %{width: 280}] do
      assert_renderable(open(extra))
    end
  end
end
