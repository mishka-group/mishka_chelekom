defmodule MishkaMob.Components.MishkaOverflowListTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaOverflowList

  doctest MishkaMob.Components.MishkaOverflowList

  defp items(n), do: for(i <- 1..n, do: %{type: :text, props: %{text: "i#{i}"}, children: []})

  defp counter_box(tree) do
    tree |> find_all(:box) |> Enum.find(&(&1.props[:corner_radius] == :radius_pill))
  end

  describe "split/2" do
    test "shows the first N and counts the rest" do
      tree = MishkaOverflowList.overflow_list(%{visible: 2}, items(5))

      assert text(tree) =~ "i1"
      assert text(tree) =~ "i2"
      refute text(tree) =~ "i3"
      assert text(tree) =~ "+3"
    end

    test "no counter when everything fits" do
      refute text(MishkaOverflowList.overflow_list(%{visible: 5}, items(3))) =~ "+"
    end

    test "min_visible wins, so the list cannot collapse entirely" do
      assert MishkaOverflowList.split([1, 2, 3], %{visible: 0}) == {[1], [2, 3]}
      assert MishkaOverflowList.split([1, 2, 3], %{visible: 0, min_visible: 2}) == {[1, 2], [3]}
    end

    test "asking for more than there is shows everything" do
      assert MishkaOverflowList.split([1, 2], %{visible: 99}) == {[1, 2], []}
      assert MishkaOverflowList.split([], %{visible: 3}) == {[], []}
    end
  end

  describe "the counter" do
    test "reports taps" do
      tree = MishkaOverflowList.overflow_list(%{visible: 1, on_counter: :more}, items(4))

      assert counter_box(tree).props.on_tap == {self(), :more}
    end

    test "takes its label from a function or a string" do
      fun = MishkaOverflowList.overflow_list(%{visible: 1, counter_text: &"#{&1} more"}, items(4))
      str = MishkaOverflowList.overflow_list(%{visible: 1, counter_text: "…"}, items(4))

      assert text(fun) =~ "3 more"
      assert text(str) =~ "…"
    end

    test "is measured before the items, and never wraps" do
      tree = MishkaOverflowList.overflow_list(%{visible: 4, id: "l"}, items(7))
      [body, _space, counter] = tree.children

      # Compose measures a Row's UNWEIGHTED children first, in order, against
      # what is left. With everything unweighted the items ate the row and the
      # counter — last — was squeezed to a column of characters: "+" over "3".
      # Weighting the items inverts the order so the counter gets its natural
      # width and the overflow is what gets clipped.
      assert body.props.weight == 1
      refute Map.has_key?(counter.props, :weight)
      assert counter.props.fill_width == false

      # And a starved Text wraps CHARACTER BY CHARACTER unless told not to,
      # which is what turned "no room" into a vertical stack rather than a clip.
      assert find(counter, :text).props.max_lines == 1
    end

    test "an empty list renders a row with a body and no counter" do
      tree = MishkaOverflowList.overflow_list(%{}, [])

      assert tree.type == :row
      assert [%{props: %{weight: 1}}] = tree.children
      refute counter_box(tree)
    end
  end

  describe "fit/3" do
    # The component cannot measure. This is for the caller that already knows
    # its width — the honest stand-in for the web's ResizeObserver.
    test "more room means more items" do
      labels = ~w(Design Phoenix Elixir LiveView Tailwind Headless Accessibility)

      wide = MishkaOverflowList.fit(labels, 600)
      narrow = MishkaOverflowList.fit(labels, 260)

      assert wide > narrow
      assert narrow >= 1
    end

    test "never returns zero, however narrow" do
      assert MishkaOverflowList.fit(~w(Accessibility), 10) == 1
      assert MishkaOverflowList.fit(~w(a b c), 0) == 1
    end

    test "it stops at the first label that does not fit, keeping priority order" do
      # Long first label eats the row, so nothing after it can be counted even
      # though the later ones are short.
      assert MishkaOverflowList.fit(["Accessibility", "a", "b"], 200) == 1
    end

    test "leaves room for the counter, so the count is never the thing that is cut" do
      labels = ~w(Design Phoenix Elixir)

      # Same width, but reserving a wider counter must not fit more.
      assert MishkaOverflowList.fit(labels, 300, counter_width: 100) <=
               MishkaOverflowList.fit(labels, 300, counter_width: 20)
    end
  end

  describe "ids" do
    test "tag the row, each shown item, and the counter" do
      tree = MishkaOverflowList.overflow_list(%{visible: 2, id: "l"}, items(5))

      assert tree.props.id == "l"
      assert MishkaOverflowList.counter_id("l") == "l-counter"
      assert MishkaOverflowList.item_id("l", 2) == "l-item-2"

      tagged = tree |> find_all(:text) |> Enum.map(& &1.props[:id]) |> Enum.reject(&is_nil/1)
      assert tagged == ["l-item-1", "l-item-2"]
    end

    test "no id, no tags anywhere" do
      tree = MishkaOverflowList.overflow_list(%{visible: 2}, items(5))

      refute Map.has_key?(tree.props, :id)
      refute Map.has_key?(counter_box(tree).props, :id)
    end
  end

  test "expand/3 delegates to overflow_list/2" do
    ctx = %{screen: self()}

    assert MishkaOverflowList.expand(%{visible: 1}, items(3), ctx) ==
             MishkaOverflowList.overflow_list(%{visible: 1}, items(3))
  end

  test "every variant renders" do
    for props <- [%{}, %{visible: 0}, %{visible: 99}, %{visible: 2, on_counter: :x}] do
      assert_renderable(MishkaOverflowList.overflow_list(props, items(4)))
    end
  end
end
