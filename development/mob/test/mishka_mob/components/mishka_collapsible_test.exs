defmodule MishkaMob.Components.MishkaCollapsibleTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaCollapsible

  defp body, do: [%{type: :text, props: %{text: "the region"}, children: []}]

  defp p(extra), do: Map.merge(%{title: "Details", on_toggle: :toggle}, extra)

  defp build(extra \\ %{}), do: MishkaCollapsible.collapsible(p(extra), body())

  describe "open and closed" do
    test "the region is absent when closed and present when open" do
      refute text(build()) =~ "the region"
      assert text(build(%{open: true})) =~ "the region"
    end

    test "the trigger label always renders" do
      assert text(build()) =~ "Details"
      assert text(build(%{open: true})) =~ "Details"
    end

    test "the chevron reflects state" do
      assert text(build()) =~ "▸"
      assert text(build(%{open: true})) =~ "▾"
    end

    test "chevron: false hides the indicator but keeps the label" do
      tree = build(%{chevron: false, open: true})

      refute text(tree) =~ "▸"
      refute text(tree) =~ "▾"
      assert text(tree) =~ "Details"
      assert text(tree) =~ "the region"
    end

    test "an open collapsible with no content renders no empty region" do
      tree = MishkaCollapsible.collapsible(p(%{open: true}), [])

      # only the trigger's own column remains
      assert length(find_all(tree, :column)) == 1
    end
  end

  describe "the trigger" do
    test "is a tappable Box, never a Button (a Button centres its label)" do
      tree = build()

      assert find_all(tree, :button) == []
      assert Enum.any?(find_all(tree, :box), &Map.has_key?(&1.props, :on_tap))
    end

    test "fires a BARE tag, unlike the Accordion's {tag, item_id}" do
      tap = tree_tap(build())

      assert tap == {self(), :toggle}
    end

    test "a bare atom is widened — an unwidened atom would never register" do
      assert tree_tap(build()) == {self(), :toggle}
      assert tree_tap(build(%{on_toggle: {self(), :already}})) == {self(), :already}
    end

    test "no on_toggle means no handler at all" do
      tree = MishkaCollapsible.collapsible(%{title: "Details"}, body())

      assert Enum.all?(find_all(tree, :box), &(&1.props[:on_tap] == nil))
    end
  end

  describe "disabled" do
    test "wires no handler and mutes the label" do
      tree = build(%{disabled: true})

      assert Enum.all?(find_all(tree, :box), &(&1.props[:on_tap] == nil))
      assert find(tree, :text, text: "Details").props.text_color == :muted
    end

    test "can still be held open by the screen" do
      assert text(build(%{disabled: true, open: true})) =~ "the region"
    end
  end

  describe "styling" do
    test "defaults to a raised, rounded, padded row" do
      tree = build()

      assert tree.props.background == :surface_raised
      assert tree.props.corner_radius == :radius_md
      assert find(tree, :box, padding: :space_md)
    end

    test "background, corner_radius and padding are overridable" do
      tree = build(%{background: 0xFF7C3AED, corner_radius: 4, padding: :space_lg})

      assert tree.props.background == 0xFF7C3AED
      assert tree.props.corner_radius == 4
      assert find(tree, :box, padding: :space_lg)
    end
  end

  describe "composite tag" do
    test "expand/3 treats the tag's children as the region" do
      assert MishkaCollapsible.expand(p(%{open: true}), body(), %{screen: self()}) ==
               MishkaCollapsible.collapsible(p(%{open: true}), body())
    end
  end

  test "every variant renders" do
    for extra <- [%{}, %{open: true}, %{disabled: true}, %{chevron: false, open: true}] do
      assert_renderable(build(extra))
    end
  end

  defp tree_tap(tree) do
    tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.find(&(&1 != nil))
  end
end
