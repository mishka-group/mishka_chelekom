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

    test "the divider itself is the drag handle — no separate control" do
      tree = MishkaSplitter.splitter(%{on_change: :s}, panes())

      # There is no Slider any more. The component shipped one under the panes
      # on the stated grounds that Mob delivers no pointer coordinates, which
      # was false: on_drag is a registered handler and only :canvas carries it.
      refute find(tree, :slider)

      canvas = find(tree, :canvas)
      assert canvas.props.on_drag == {self(), :s}
    end

    test "disabling unwires the grip rather than hiding it" do
      disabled = MishkaSplitter.splitter(%{disabled: true, on_change: :s}, panes())
      canvas = find(disabled, :canvas)

      # Still drawn — a divider that vanishes when disabled makes the layout
      # jump — but nothing can fire it.
      assert canvas
      refute Map.has_key?(canvas.props, :on_drag)
    end

    test "the panes keep their sizes when disabled" do
      enabled = MishkaSplitter.splitter(%{value: 30, extent: 300}, panes())
      disabled = MishkaSplitter.splitter(%{value: 30, extent: 300, disabled: true}, panes())

      assert Enum.map(pane_boxes(enabled), & &1.props.width) ==
               Enum.map(pane_boxes(disabled), & &1.props.width)
    end

    test "the grip is drawn AT the split, on a canvas spanning the whole extent" do
      # Two ops: a faint band (the touch target, made visible) and the pill.
      for {orientation, key} <- [{:horizontal, :w}, {:vertical, :h}] do
        canvas =
          MishkaSplitter.splitter(%{orientation: orientation, value: 25, extent: 200}, panes())
          |> find(:canvas)

        [band, pill] = canvas.props.draw

        # The canvas spans the extent along the drag axis — that is what makes
        # its coordinates a stable ruler instead of one that moves with the
        # divider.
        assert Map.fetch!(canvas.props, if(orientation == :vertical, do: :height, else: :width)) ==
                 200

        # And the grip is drawn a quarter of the way along, because value is 25.
        assert_in_delta Map.fetch!(band, if(orientation == :vertical, do: :y, else: :x)),
                        38.0,
                        0.1

        assert Map.fetch!(band, key) == 24
        assert pill.op == :rect
      end
    end

    test "id tags the root, the panes and the grip — a canvas has no text to find" do
      tree = MishkaSplitter.splitter(%{id: "sp"}, panes())

      assert tree.props.id == "sp"
      assert Enum.map(pane_boxes(tree), & &1.props.id) == ["sp-pane-1", "sp-pane-2"]
      assert find(tree, :canvas).props.id == "sp-grip"

      assert MishkaSplitter.grip_id("sp") == "sp-grip"
      assert MishkaSplitter.pane_id("sp", 2) == "sp-pane-2"
    end
  end

  describe "drag/3" do
    # The drag surface spans the whole extent, so x is a POSITION. A canvas
    # riding on the divider would have been a ruler sliding under the finger —
    # on the device that moved 10dp for a 60dp drag while this arithmetic was
    # provably right, which is why the canvas is static and this is absolute.
    test "a grab on the divider then a move sets the split from the position" do
      opts = [value: 50, extent: 200]

      {_, grab} = MishkaSplitter.drag(%{phase: "began", x: 100.0}, nil, opts)
      {value, _} = MishkaSplitter.drag(%{phase: "dragging", x: 140.0}, grab, opts)

      assert value == 70.0
    end

    test "a touch that misses the divider engages nothing" do
      opts = [value: 50, extent: 200]

      # The canvas covers both panes — it must, to be a stable ruler — so
      # without this every tap anywhere would teleport the split to the finger.
      assert {50, nil} = MishkaSplitter.drag(%{phase: "began", x: 10.0}, nil, opts)
      assert {50, nil} = MishkaSplitter.drag(%{phase: "began", x: 190.0}, nil, opts)

      {_, grab} = MishkaSplitter.drag(%{phase: "began", x: 10.0}, nil, opts)
      assert {50, nil} = MishkaSplitter.drag(%{phase: "dragging", x: 20.0}, grab, opts)
    end

    test "grabbing off-centre does not snap the divider under the finger" do
      opts = [value: 50, extent: 200, grip: 24]

      # 100 is the divider; grab at 112, still within the grip.
      {_, grab} = MishkaSplitter.drag(%{phase: "began", x: 112.0}, nil, opts)
      assert grab.offset == 12.0

      # Holding still keeps the split exactly where it was.
      assert {50.0, _} = MishkaSplitter.drag(%{phase: "dragging", x: 112.0}, grab, opts)
    end

    test "it clamps into min..max, so a pane can never be dragged away" do
      opts = [value: 50, extent: 100, min: 20, max: 80]

      {_, grab} = MishkaSplitter.drag(%{phase: "began", x: 50.0}, nil, opts)

      assert {80.0, _} = MishkaSplitter.drag(%{phase: "dragging", x: 900.0}, grab, opts)
      assert {20.0, _} = MishkaSplitter.drag(%{phase: "dragging", x: -900.0}, grab, opts)
    end

    test "a vertical splitter reads y instead of x" do
      opts = [value: 50, extent: 200, orientation: :vertical]

      {_, grab} = MishkaSplitter.drag(%{phase: "began", x: 999.0, y: 100.0}, nil, opts)
      {value, _} = MishkaSplitter.drag(%{phase: "dragging", x: 0.0, y: 140.0}, grab, opts)

      assert value == 70.0
    end

    test "ending releases the anchor; a stray sample without one changes nothing" do
      opts = [value: 50, extent: 200]
      grab = %{offset: 0.0}

      assert {70.0, nil} = MishkaSplitter.drag(%{phase: "ended", x: 140.0}, grab, opts)
      assert {50, nil} = MishkaSplitter.drag(%{phase: "ended", x: 140.0}, nil, opts)
    end

    test "the phase is an ATOM on the wire, which is how this shipped dead" do
      opts = [value: 50, extent: 200]

      # The NIF sends :began / :dragging / :ended as atoms. This module compared
      # them against "began" and fell through to the :dragging default, so the
      # anchor was never set and every drag returned the split unchanged — the
      # divider was completely inert on the device while every unit test here
      # passed, because they all used strings.
      {_, grab} = MishkaSplitter.drag(%{phase: :began, x: 100.0}, nil, opts)
      assert grab, "an atom :began did not engage the drag"

      {value, _} = MishkaSplitter.drag(%{phase: :dragging, x: 140.0}, grab, opts)
      assert value == 70.0

      assert {70.0, nil} = MishkaSplitter.drag(%{phase: :ended, x: 140.0}, grab, opts)
    end

    test "string keys work too, because the payload crosses a wire" do
      opts = [value: 50, extent: 200]

      {_, grab} = MishkaSplitter.drag(%{"phase" => "began", "x" => 100.0}, nil, opts)
      {value, _} = MishkaSplitter.drag(%{"phase" => "dragging", "x" => 140.0}, grab, opts)

      assert value == 70.0
    end
  end

  describe "panes" do
    test "a missing pane renders as blank rather than crashing" do
      # extra: [:canvas] — the divider is a canvas now, and canvas is a plugin
      # tag rather than one of mob's baked-in renderable types.
      assert_renderable(MishkaSplitter.splitter(%{}, []), extra: [:canvas])
      assert_renderable(MishkaSplitter.splitter(%{}, [hd(panes())]), extra: [:canvas])
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
          %{value: 90, grip: 32}
        ] do
      assert_renderable(MishkaSplitter.splitter(props, panes()), extra: [:canvas])
    end

    for props <- [%{}, %{visible: 0}, %{visible: 99}, %{visible: 2, on_counter: :x}] do
      assert_renderable(MishkaOverflowList.overflow_list(props, items(4)))
    end
  end
end
