defmodule MishkaMob.Components.MishkaTabsTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaTabs

  defp panel(text), do: [%{type: :text, props: %{text: text}, children: []}]

  defp three do
    [
      MishkaTabs.tab(:a, "Overview", panel("A body")),
      MishkaTabs.tab(:b, "Specs", panel("B body")),
      MishkaTabs.tab(:c, "Locked", panel("C body"), disabled: true)
    ]
  end

  defp build(props \\ %{}), do: MishkaTabs.tabs(Map.merge(%{on_change: :pick}, props), three())

  defp strip(tree), do: hd(tree.children)
  defp triggers(tree), do: Enum.filter(strip(tree).children, &(&1.type == :column))

  describe "active selection" do
    test "defaults to the first tab" do
      assert MishkaTabs.active(%{}, [%{id: :a}, %{id: :b}]) == :a
    end

    test "a stale or unknown id falls back to the first tab, never an empty panel" do
      assert MishkaTabs.active(%{active: :gone}, [%{id: :a}, %{id: :b}]) == :a
      assert MishkaTabs.active(%{active: nil}, [%{id: :a}]) == :a
    end

    test "an id that exists is honoured" do
      assert MishkaTabs.active(%{active: :b}, [%{id: :a}, %{id: :b}]) == :b
    end

    test "no tabs at all yields nil rather than raising" do
      assert MishkaTabs.active(%{active: :a}, []) == nil
    end
  end

  describe "panels" do
    test "only the active tab's panel renders" do
      tree = build(%{active: :b})

      assert text(tree) =~ "B body"
      refute text(tree) =~ "A body"
      refute text(tree) =~ "C body"
    end

    test "switching the active id switches the panel" do
      assert text(build(%{active: :a})) =~ "A body"
      assert text(build(%{active: :b})) =~ "B body"
    end

    test "every tab label is always visible" do
      tree = build(%{active: :a})

      for label <- ["Overview", "Specs", "Locked"], do: assert(text(tree) =~ label)
    end

    test "a tab with an empty panel renders no panel column" do
      tree = MishkaTabs.tabs(%{}, [MishkaTabs.tab(:a, "Only", [])])

      # just the strip
      assert length(tree.children) == 1
    end
  end

  describe "the strip" do
    test "one trigger per tab, separated by the space gap" do
      tree = build()

      assert length(triggers(tree)) == 3
      spacers = Enum.filter(strip(tree).children, &(&1.type == :spacer))
      assert Enum.all?(spacers, &(&1.props.size == 18))

      assert Enum.all?(
               Enum.filter(strip(build(%{space: 30})).children, &(&1.type == :spacer)),
               &(&1.props.size == 30)
             )
    end

    test "triggers are tappable columns, never Buttons (a Button boxes its label)" do
      assert find_all(build(), :button) == []
    end

    test "each tap carries its own tab id" do
      taps = Enum.map(triggers(build()), & &1.props[:on_tap])

      assert [{pid, {:pick, :a}}, {_, {:pick, :b}}, nil] = taps
      assert pid == self()
    end

    test "a disabled tab wires no handler and renders muted" do
      tree = build()

      assert List.last(triggers(tree)).props[:on_tap] == nil
      assert find(tree, :text, text: "Locked").props.text_color == :muted
    end

    test "no on_change means no tab is tappable" do
      tree = MishkaTabs.tabs(%{}, three())

      assert Enum.all?(triggers(tree), &(&1.props[:on_tap] == nil))
    end
  end

  describe "the indicator" do
    test "underlines only the active tab" do
      tree = build(%{active: :b})
      underlines = Enum.map(triggers(tree), fn t -> Enum.any?(t.children, &(&1.type == :box)) end)

      assert underlines == [false, true, false]
    end

    test "indicator: false drops it, but the active label keeps its colour" do
      tree = build(%{active: :b, indicator: false})

      assert find_all(tree, :box) == []
      assert find(tree, :text, text: "Specs").props.text_color == :primary
    end

    test "colour tints the active label and its underline" do
      tree = build(%{active: :a, color: 0xFF7C3AED})

      assert find(tree, :text, text: "Overview").props.text_color == 0xFF7C3AED
      assert find(tree, :box).props.background == 0xFF7C3AED
    end

    test "inactive labels use the normal surface colour" do
      assert find(build(%{active: :a}), :text, text: "Specs").props.text_color == :on_surface
    end
  end

  describe "composite tag" do
    test "expand/3 reads :mishka_tab children and ignores anything else" do
      stray = %{type: :text, props: %{text: "stray"}, children: []}
      tree = MishkaTabs.expand(%{on_change: :pick}, three() ++ [stray], %{screen: self()})

      assert length(triggers(tree)) == 3
      refute text(tree) =~ "stray"
    end
  end

  test "every variant renders" do
    for props <- [%{}, %{active: :b}, %{indicator: false}, %{color: :primary, space: 4}] do
      assert_renderable(build(props))
    end
  end
end
