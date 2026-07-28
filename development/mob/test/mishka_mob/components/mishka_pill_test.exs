defmodule MishkaMob.Components.MishkaPillTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaPill

  # The ✕ lives in its own nested row. Match on a DIRECT child, since the outer
  # row also contains the ✕ through its descendants.
  defp remove_row(tree) do
    tree
    |> find_all(:row)
    |> Enum.find(fn row ->
      Enum.any?(row.children, &(&1.type == :text and &1.props[:text] == "✕"))
    end)
  end

  describe "shape" do
    test "is a pill-shaped box holding its label" do
      node = MishkaPill.pill(label: "elixir")

      assert node.type == :box
      assert node.props.corner_radius == :radius_pill
      assert text(node) =~ "elixir"
    end

    test "children replace the label" do
      icon = [%{type: :text, props: %{text: "★"}, children: []}]
      node = MishkaPill.pill(%{label: "elixir"}, icon)

      assert text(node) =~ "★"
      refute text(node) =~ "elixir"
    end

    test "background and colour are props" do
      node = MishkaPill.pill(label: "e", background: 0xFF7C3AED, color: 0xFFFFFFFF)

      assert node.props.background == 0xFF7C3AED
      assert find(node, :text).props.text_color == 0xFFFFFFFF
    end

    test "hugs its label rather than filling the row" do
      # The regression: a Box with neither width nor fill_width FILLS its parent,
      # so every pill came out a full-width bar and only one fit per row. It is
      # asserted here because a pill that fills is still a perfectly valid tree —
      # nothing else in the suite can tell the two apart.
      assert MishkaPill.pill(label: "elixir").props.fill_width == false
    end
  end

  describe "the remove button" do
    test "is absent unless with_remove is set" do
      refute text(MishkaPill.pill(label: "e")) =~ "✕"
      assert text(MishkaPill.pill(label: "e", with_remove: true)) =~ "✕"
    end

    test "carries its OWN handler, separate from the pill body" do
      node = MishkaPill.pill(label: "e", with_remove: true, on_remove: {:drop, :e})

      # body is not tappable …
      refute Map.has_key?(node.props, :on_tap)
      # … but the ✕ is
      assert remove_row(node).props.on_tap == {self(), {:drop, :e}}
    end

    test "the body and the ✕ can both be tappable, with different tags" do
      node = MishkaPill.pill(label: "e", with_remove: true, on_tap: :open, on_remove: :drop)

      assert node.props.on_tap == {self(), :open}
      assert remove_row(node).props.on_tap == {self(), :drop}
    end

    test "with_remove but no on_remove renders an inert ✕" do
      node = MishkaPill.pill(label: "e", with_remove: true)

      refute Map.has_key?(remove_row(node).props, :on_tap)
    end
  end

  describe "disabled" do
    test "mutes the label and wires nothing, including the ✕" do
      node =
        MishkaPill.pill(
          label: "e",
          with_remove: true,
          disabled: true,
          on_remove: :drop,
          on_tap: :open
        )

      refute Map.has_key?(node.props, :on_tap)
      refute Map.has_key?(remove_row(node).props, :on_tap)
      assert find(node, :text).props.text_color == :muted
    end

    test "disabled_color overrides the muted default" do
      node = MishkaPill.pill(label: "e", disabled: true, disabled_color: 0xFF9CA3AF)

      assert find(node, :text).props.text_color == 0xFF9CA3AF
    end

    test "disabled_color is ignored while enabled" do
      node = MishkaPill.pill(label: "e", disabled_color: 0xFF9CA3AF)

      assert find(node, :text).props.text_color == :on_surface
    end
  end

  describe "composite tag" do
    test "expand/3 uses the tag's children as the content" do
      icon = [%{type: :text, props: %{text: "★"}, children: []}]

      assert MishkaPill.expand(%{}, icon, %{screen: self()}) == MishkaPill.pill(%{}, icon)
    end
  end

  test "every variant renders" do
    for props <- [
          %{},
          %{label: "e"},
          %{label: "e", with_remove: true, on_remove: :drop},
          %{label: "e", disabled: true, with_remove: true}
        ] do
      assert_renderable(MishkaPill.pill(props))
    end
  end
end
