defmodule MishkaMob.Components.MishkaSplitterTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaOverflowList, MishkaSplitter}

  doctest MishkaMob.Components.MishkaSplitter
  doctest MishkaMob.Components.MishkaOverflowList

  defp panes do
    [
      %{type: :text, props: %{text: "left"}, children: []},
      %{type: :text, props: %{text: "right"}, children: []}
    ]
  end

  defp pane_boxes(tree) do
    tree |> find_all(:box) |> Enum.filter(&(&1.props[:background] == :surface))
  end

  describe "sizes/1" do
    test "divides the extent by the percentage" do
      assert MishkaSplitter.sizes(%{value: 50, extent: 300}) == {150.0, 150.0}
      assert MishkaSplitter.sizes(%{value: 25, extent: 400}) == {100.0, 300.0}
    end

    test "the two panes always add up to the extent" do
      for value <- [10, 33, 50, 67, 90] do
        {first, second} = MishkaSplitter.sizes(%{value: value, extent: 317})

        assert_in_delta first + second, 317, 0.001
      end
    end

    test "clamps into min..max so neither pane can vanish" do
      assert MishkaSplitter.sizes(%{value: 0, extent: 300, min: 20}) == {60.0, 240.0}
      assert MishkaSplitter.sizes(%{value: 100, extent: 300, max: 80}) == {240.0, 60.0}
    end

    test "defaults to an even split of 320" do
      assert MishkaSplitter.sizes(%{}) == {160.0, 160.0}
    end
  end

  describe "rendering" do
    test "horizontal lays the panes in a row, sized in dp" do
      tree = MishkaSplitter.splitter(%{value: 25, extent: 400}, panes())

      assert find(tree, :row)
      assert Enum.map(pane_boxes(tree), & &1.props.width) == [100.0, 300.0]
      assert text(tree) =~ "left"
      assert text(tree) =~ "right"
    end

    test "vertical stacks them, sizing height instead" do
      tree = MishkaSplitter.splitter(%{value: 25, extent: 400, orientation: :vertical}, panes())

      assert Enum.map(pane_boxes(tree), & &1.props.height) == [100.0, 300.0]
      assert Enum.all?(pane_boxes(tree), & &1.props.fill_width)
    end

    test "accepts the orientation as a string too" do
      atom = MishkaSplitter.splitter(%{orientation: :vertical}, panes())
      string = MishkaSplitter.splitter(%{orientation: "vertical"}, panes())

      assert atom == string
    end

    test "the control spans min..max, not 0..100" do
      slider =
        MishkaSplitter.splitter(%{min: 20, max: 70, on_change: :s}, panes()) |> find(:slider)

      assert {slider.props.min, slider.props.max} == {20, 70}
      assert slider.props.on_change == {self(), :s}
    end

    test "the control can be hidden, and disabling removes it" do
      refute MishkaSplitter.splitter(%{show_control: false}, panes()) |> find(:slider)
      refute MishkaSplitter.splitter(%{disabled: true}, panes()) |> find(:slider)
      assert MishkaSplitter.splitter(%{}, panes()) |> find(:slider)
    end

    test "the panes keep their sizes when disabled — only the control goes" do
      enabled = MishkaSplitter.splitter(%{value: 30, extent: 300}, panes())
      disabled = MishkaSplitter.splitter(%{value: 30, extent: 300, disabled: true}, panes())

      assert Enum.map(pane_boxes(enabled), & &1.props.width) ==
               Enum.map(pane_boxes(disabled), & &1.props.width)
    end

    test "the grip is drawn where the split is" do
      tree = MishkaSplitter.splitter(%{}, panes())
      grip = tree |> find_all(:box) |> Enum.find(&(&1.props[:corner_radius] == :radius_pill))

      assert grip.props.background == :muted
    end

    test "a missing pane renders as blank rather than crashing" do
      assert_renderable(MishkaSplitter.splitter(%{}, []))
      assert_renderable(MishkaSplitter.splitter(%{}, [hd(panes())]))
    end

    test "extra children past the second are ignored" do
      third = %{type: :text, props: %{text: "third"}, children: []}

      refute text(MishkaSplitter.splitter(%{}, panes() ++ [third])) =~ "third"
    end
  end

  describe "overflow list" do
    defp items(n), do: for(i <- 1..n, do: %{type: :text, props: %{text: "i#{i}"}, children: []})

    test "shows the first N and counts the rest" do
      tree = MishkaOverflowList.overflow_list(%{visible: 2}, items(5))

      assert text(tree) =~ "i1"
      assert text(tree) =~ "i2"
      refute text(tree) =~ "i3"
      assert text(tree) =~ "+3"
    end

    test "no counter when everything fits" do
      tree = MishkaOverflowList.overflow_list(%{visible: 5}, items(3))

      refute text(tree) =~ "+"
    end

    test "min_visible wins, so the list cannot collapse entirely" do
      assert MishkaOverflowList.split([1, 2, 3], %{visible: 0}) == {[1], [2, 3]}
      assert MishkaOverflowList.split([1, 2, 3], %{visible: 0, min_visible: 2}) == {[1, 2], [3]}
    end

    test "asking for more than there is shows everything" do
      assert MishkaOverflowList.split([1, 2], %{visible: 99}) == {[1, 2], []}
      assert MishkaOverflowList.split([], %{visible: 3}) == {[], []}
    end

    test "the counter reports taps" do
      tree = MishkaOverflowList.overflow_list(%{visible: 1, on_counter: :more}, items(4))
      counter = tree |> find_all(:box) |> Enum.find(&(&1.props[:on_tap] != nil))

      assert counter.props.on_tap == {self(), :more}
    end

    test "the counter label can be given as a function or a string" do
      fun = MishkaOverflowList.overflow_list(%{visible: 1, counter_text: &"#{&1} more"}, items(4))
      str = MishkaOverflowList.overflow_list(%{visible: 1, counter_text: "…"}, items(4))

      assert text(fun) =~ "3 more"
      assert text(str) =~ "…"
    end

    test "an empty list renders an empty row" do
      tree = MishkaOverflowList.overflow_list(%{}, [])

      assert tree.type == :row
      assert tree.children == []
    end
  end

  test "expand/3 delegates for both" do
    ctx = %{screen: self()}

    assert MishkaSplitter.expand(%{value: 30}, panes(), ctx) ==
             MishkaSplitter.splitter(%{value: 30}, panes())

    assert MishkaOverflowList.expand(%{visible: 1}, items(3), ctx) ==
             MishkaOverflowList.overflow_list(%{visible: 1}, items(3))
  end

  test "every variant renders" do
    for props <- [
          %{},
          %{value: 10, extent: 200},
          %{orientation: :vertical, disabled: true},
          %{value: 90, show_control: false}
        ] do
      assert_renderable(MishkaSplitter.splitter(props, panes()))
    end

    for props <- [%{}, %{visible: 0}, %{visible: 99}, %{visible: 2, on_counter: :x}] do
      assert_renderable(MishkaOverflowList.overflow_list(props, items(4)))
    end
  end
end
