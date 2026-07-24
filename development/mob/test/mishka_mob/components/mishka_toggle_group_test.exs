defmodule MishkaMob.Components.MishkaToggleGroupTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaToggleGroup, as: Group

  doctest MishkaMob.Components.MishkaToggleGroup

  defp items do
    [Group.item(:a, "A"), Group.item(:b, "B"), Group.item(:c, "C", disabled: true)]
  end

  defp build(props \\ %{}), do: Group.toggle_group(Map.merge(%{on_change: :pick}, props), items())
  defp buttons(tree), do: Enum.filter(tree.children, &(&1.type == :box))

  describe "press/3 in single mode" do
    test "pressing selects, and pressing another moves the selection" do
      assert Group.press(nil, :a, false) == :a
      assert Group.press(:a, :b, false) == :b
    end

    test "pressing the pressed button CLEARS it — the radio group difference" do
      assert Group.press(:a, :a, false) == nil
    end
  end

  describe "press/3 in multiple mode" do
    test "builds a set, preserving order" do
      assert Group.press([:a], :b, true) == [:a, :b]
      assert Group.press([], :a, true) == [:a]
    end

    test "pressing again removes" do
      assert Group.press([:a, :b], :a, true) == [:b]
      assert Group.press([:a], :a, true) == []
    end

    test "a bare value is treated as a one-element set" do
      assert Group.press(:a, :b, true) == [:a, :b]
    end
  end

  describe "pressed?/2" do
    test "works for both a bare value and a list" do
      assert Group.pressed?(:a, :a)
      refute Group.pressed?(:a, :b)
      assert Group.pressed?([:a, :b], :b)
      refute Group.pressed?([:a], :b)
      refute Group.pressed?(nil, :a)
    end
  end

  describe "rendering" do
    test "one button per item, separated by the space gap" do
      tree = build(%{space: 20})

      assert length(buttons(tree)) == 3
      assert Enum.all?(Enum.filter(tree.children, &(&1.type == :spacer)), &(&1.props.size == 20))
    end

    test "only the selected item is pressed, in single mode" do
      fills = build(%{value: :b}) |> buttons() |> Enum.map(& &1.props.background)

      assert fills == [:surface_raised, :primary, :surface_raised]
    end

    test "several are pressed in multiple mode" do
      fills =
        build(%{value: [:a, :b], multiple: true}) |> buttons() |> Enum.map(& &1.props.background)

      assert fills == [:primary, :primary, :surface_raised]
    end

    test "horizontal by default, vertical on request" do
      assert build(%{}).type == :row
      assert build(%{orientation: :vertical}).type == :column
    end

    test "each item reports the same tag widened with its own id" do
      taps = build(%{}) |> buttons() |> Enum.map(& &1.props[:on_tap])

      assert [{pid, {:pick, :a}}, {_, {:pick, :b}}, nil] = taps
      assert pid == self()
    end

    test "a disabled item is inert; a disabled group cascades" do
      assert build(%{}) |> buttons() |> List.last() |> Map.fetch!(:props) |> Map.get(:on_tap) ==
               nil

      assert Enum.all?(buttons(build(%{disabled: true})), &(&1.props[:on_tap] == nil))
    end

    test "no on_change means nothing is tappable" do
      tree = Group.toggle_group(%{value: :a}, items())

      assert Enum.all?(buttons(tree), &(&1.props[:on_tap] == nil))
    end
  end

  test "expand/3 reads item children and ignores anything else" do
    stray = %{type: :text, props: %{text: "stray"}, children: []}
    tree = Group.expand(%{value: :a}, items() ++ [stray], %{screen: self()})

    refute text(tree) =~ "stray"
    assert length(buttons(tree)) == 3
  end

  test "every variant renders" do
    for props <- [%{}, %{value: :a}, %{value: [:a], multiple: true}, %{orientation: :vertical}] do
      assert_renderable(build(props))
    end
  end
end
