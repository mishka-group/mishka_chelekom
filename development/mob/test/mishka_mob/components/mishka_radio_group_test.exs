defmodule MishkaMob.Components.MishkaRadioGroupTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaRadioGroup

  doctest MishkaMob.Components.MishkaRadioGroup

  defp opts do
    [
      MishkaRadioGroup.option(:free, "Free"),
      MishkaRadioGroup.option(:pro, "Pro"),
      MishkaRadioGroup.option(:team, "Team", disabled: true)
    ]
  end

  defp build(props \\ %{}),
    do: MishkaRadioGroup.radio_group(Map.merge(%{on_change: :plan}, props), opts())

  # each option renders as a Radio row
  defp rows(tree), do: find_all(tree, :row) |> Enum.filter(&(text(&1) != ""))

  describe "select/2" do
    test "a tap selects the tapped option" do
      assert MishkaRadioGroup.select(:a, :b) == :b
      assert MishkaRadioGroup.select(nil, :a) == :a
    end

    test "re-tapping the selection KEEPS it — a radio group cannot be cleared" do
      assert MishkaRadioGroup.select(:a, :a) == :a
    end
  end

  describe "selection" do
    test "exactly one option is checked" do
      tree = build(%{value: :pro})
      dots = tree |> find_all(:box) |> Enum.filter(&(&1.props[:border_width] == 2))

      assert length(dots) == 1
    end

    test "no value means nothing is checked" do
      tree = build(%{})

      assert tree |> find_all(:box) |> Enum.filter(&(&1.props[:border_width] == 2)) == []
    end

    test "every option label renders" do
      tree = build(%{value: :pro})

      for label <- ["Free", "Pro", "Team"], do: assert(text(tree) =~ label)
    end
  end

  describe "the group tag" do
    test "every option reports the same tag widened with its own id" do
      taps = build(%{value: :free}) |> rows() |> Enum.map(& &1.props[:on_tap])

      assert [{pid, {:plan, :free}}, {_, {:plan, :pro}}, nil] = taps
      assert pid == self()
    end

    test "no on_change means no option is tappable" do
      tree = MishkaRadioGroup.radio_group(%{value: :free}, opts())

      assert Enum.all?(rows(tree), &(&1.props[:on_tap] == nil))
    end
  end

  describe "disabled" do
    test "a single disabled option is inert while the rest work" do
      taps = build(%{value: :free}) |> rows() |> Enum.map(& &1.props[:on_tap])

      assert List.last(taps) == nil
      refute Enum.at(taps, 0) == nil
    end

    test "a disabled group cascades to every option" do
      tree = build(%{value: :free, disabled: true})

      assert Enum.all?(rows(tree), &(&1.props[:on_tap] == nil))
    end
  end

  describe "layout" do
    test "vertical by default, horizontal on request" do
      assert %{type: :column} = layout(build(%{}))
      assert %{type: :row} = layout(build(%{orientation: :horizontal}))
    end

    test "space sets the gap between options" do
      tree = build(%{space: 30})
      gaps = layout(tree).children |> Enum.filter(&(&1.type == :spacer))

      assert Enum.all?(gaps, &(&1.props.size == 30))
    end

    test "the label renders above the options, and is omitted when absent" do
      assert text(build(%{label: "PLAN"})) =~ "PLAN"
      assert hd(build(%{}).children).type != :text
    end

    test "colour and size reach every option" do
      tree = build(%{value: :free, color: 0xFF7C3AED, size: 30})

      assert Enum.any?(find_all(tree, :box), &(&1.props[:width] == 30))
      assert Enum.any?(find_all(tree, :box), &(&1.props[:border_color] == 0xFF7C3AED))
    end
  end

  test "expand/3 reads option children and ignores anything else" do
    stray = %{type: :text, props: %{text: "stray"}, children: []}
    tree = MishkaRadioGroup.expand(%{value: :free}, opts() ++ [stray], %{screen: self()})

    refute text(tree) =~ "stray"
    assert length(rows(tree)) == 3
  end

  test "every variant renders" do
    for props <- [%{}, %{value: :pro}, %{disabled: true}, %{orientation: :horizontal}] do
      assert_renderable(build(props))
    end
  end

  # the options container is the last child of the group column
  defp layout(tree), do: List.last(tree.children)
end
