defmodule MishkaMob.Components.MishkaSeparatorTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`, so two
  # concurrent ScreenCase files race to start it (see mishka_accordion_test).
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaSeparator

  describe "plain rule" do
    test "is a native Divider carrying the default colour and thickness" do
      assert %{type: :divider, props: %{color: :border, thickness: 1}, children: []} =
               MishkaSeparator.separator()
    end

    test "colour and thickness are overridable, tokens or ARGB" do
      assert %{props: %{color: 0xFF7C3AED, thickness: 3}} =
               MishkaSeparator.separator(color: 0xFF7C3AED, thickness: 3)

      assert %{props: %{color: :primary}} = MishkaSeparator.separator(color: :primary)
    end

    test "accepts a map as well as a keyword list" do
      assert MishkaSeparator.separator(%{thickness: 2}) == MishkaSeparator.separator(thickness: 2)
    end
  end

  describe "labelled" do
    test "renders line — label — line in a row" do
      tree = MishkaSeparator.separator(label: "or")

      assert %{type: :row, props: %{fill_width: true}} = tree
      assert [%{type: :divider}, _, %{type: :text}, _, %{type: :divider}] = tree.children
      assert text(tree) =~ "or"
    end

    test "the flanking lines flex so the label stays centred" do
      tree = MishkaSeparator.separator(label: "or")

      assert Enum.all?(find_all(tree, :divider), &(&1.props[:weight] == 1))
    end

    test "the label gap is the space prop" do
      tree = MishkaSeparator.separator(label: "or", space: 30)

      assert Enum.all?(find_all(tree, :spacer), &(&1.props[:size] == 30))
    end

    test "an empty or non-binary label falls back to a plain rule" do
      assert %{type: :divider} = MishkaSeparator.separator(label: "")
      assert %{type: :divider} = MishkaSeparator.separator(label: nil)
    end

    test "the label inherits the rule colour and thickness" do
      tree = MishkaSeparator.separator(label: "or", color: :primary, thickness: 2)

      assert Enum.all?(find_all(tree, :divider), &(&1.props.color == :primary))
      assert Enum.all?(find_all(tree, :divider), &(&1.props.thickness == 2))
    end
  end

  describe "vertical" do
    test "is a width-locked, height-filling Box (Divider is horizontal-only natively)" do
      assert %{type: :box, props: %{width: 1, fill_height: true, background: :border}} =
               MishkaSeparator.separator(orientation: :vertical)
    end

    test "thickness becomes the width" do
      assert %{props: %{width: 4}} =
               MishkaSeparator.separator(orientation: :vertical, thickness: 4)
    end

    test "a label is ignored on a vertical rule" do
      tree = MishkaSeparator.separator(orientation: :vertical, label: "or")

      assert tree.type == :box
      refute text(tree) =~ "or"
    end
  end

  describe "composite tag" do
    test "expand/3 delegates to separator/1 and ignores children" do
      children = [%{type: :text, props: %{text: "ignored"}, children: []}]

      assert MishkaSeparator.expand(%{label: "or"}, children, %{screen: self()}) ==
               MishkaSeparator.separator(label: "or")

      refute text(MishkaSeparator.expand(%{}, children, %{screen: self()})) =~ "ignored"
    end
  end

  describe "id" do
    # A rule draws a line: no text, no state, nothing in the semantics tree. So
    # `id` is the only thing that makes one addressable at all, and the only way
    # to check the one thing a rule can get wrong — its geometry.
    test "tags whichever node the variant actually renders" do
      assert %{type: :divider, props: %{id: "r"}} = MishkaSeparator.separator(id: "r")

      assert %{type: :box, props: %{id: "v"}} =
               MishkaSeparator.separator(orientation: :vertical, id: "v")

      assert %{type: :row, props: %{id: "l"}} = MishkaSeparator.separator(label: "or", id: "l")
    end

    test "a labelled rule tags both lines, so their widths can be compared" do
      row = MishkaSeparator.separator(label: "or", id: "l")
      lines = Enum.filter(row.children, &(&1.type == :divider))

      assert Enum.map(lines, & &1.props.id) == ["l-line-start", "l-line-end"]
      assert MishkaSeparator.line_ids("l") == {"l-line-start", "l-line-end"}

      # Both still carry the weight that makes them share the leftover width —
      # tagging them must not disturb the thing being measured.
      assert Enum.all?(lines, &(&1.props.weight == 1))
    end

    test "no id, no tag — on the rule or on its lines" do
      refute Map.has_key?(MishkaSeparator.separator().props, :id)

      MishkaSeparator.separator(label: "or")
      |> Map.fetch!(:children)
      |> Enum.filter(&(&1.type == :divider))
      |> Enum.each(&refute(Map.has_key?(&1.props, :id)))
    end
  end

  test "every variant renders" do
    for props <- [%{}, %{label: "or"}, %{orientation: :vertical}, %{color: :primary}] do
      assert_renderable(MishkaSeparator.separator(props))
    end
  end
end
