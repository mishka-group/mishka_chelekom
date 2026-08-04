defmodule MishkaMob.Components.MishkaTooltipTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaPopover, MishkaTooltip}

  # A trigger has to be SOMETHING, and what it is never matters to the tooltip.
  defp control, do: %{type: :text, props: %{text: "⧉"}, children: []}

  defp ids(tree) do
    tree
    |> flatten()
    |> Enum.map(&Map.get(&1.props, :id))
    |> Enum.reject(&is_nil/1)
  end

  describe "the bare bubble" do
    test "renders nothing when closed, so it takes no space in the layout" do
      assert MishkaTooltip.tooltip(text: "x") == %{type: :column, props: %{}, children: []}

      assert MishkaTooltip.tooltip(text: "x", open: false) == %{
               type: :column,
               props: %{},
               children: []
             }
    end

    test "is a compact dark bubble when open" do
      tree = MishkaTooltip.tooltip(text: "Copy", open: true)

      assert tree.type == :box
      assert tree.props.background == 0xFF111827
      assert find(tree, :text).props.text_color == 0xFFFFFFFF
      assert find(tree, :text).props.text_size == :sm
      assert text(tree) =~ "Copy"
    end

    test "hugs its text rather than filling the row it sits in" do
      # A Box with neither a width nor the flag fills its parent, which is how
      # a hint used to render as a full-width bar.
      assert MishkaTooltip.tooltip(text: "x", open: true).props.fill_width == false
    end

    test "keeps the hint to one line" do
      # Squeezed narrower than its content a Text wraps one character per line.
      assert find(MishkaTooltip.tooltip(text: "x", open: true), :text).props.max_lines == 1
    end

    test "is deliberately NOT the Popover shell — a hint is not a panel" do
      tip = MishkaTooltip.tooltip(text: "x", open: true)
      panel = MishkaPopover.panel(%{}, [])

      # no border, tighter padding, and a dark fill rather than the surface
      refute Map.has_key?(tip.props, :border_width)
      refute tip.props.background == panel.props.background
      refute tip.props.padding == panel.props.padding
    end

    test "colours and size are overridable" do
      tree =
        MishkaTooltip.tooltip(
          text: "x",
          open: true,
          background: 0xFF7C3AED,
          color: 0xFF000000,
          text_size: :base
        )

      assert tree.props.background == 0xFF7C3AED
      assert find(tree, :text).props.text_color == 0xFF000000
      assert find(tree, :text).props.text_size == :base
    end

    test "offsets are omitted unless asked for" do
      props = MishkaTooltip.tooltip(text: "x", open: true).props

      refute Map.has_key?(props, :offset_x)
      refute Map.has_key?(props, :offset_y)

      nudged = MishkaTooltip.tooltip(text: "x", open: true, offset_x: 6, offset_y: -2).props
      assert nudged.offset_x == 6
      assert nudged.offset_y == -2
    end
  end

  describe "the trigger" do
    test "children become the trigger, and the bubble joins them in one stack" do
      tree = MishkaTooltip.tooltip(%{text: "Copy", open: true, id: "tip"}, [control()])

      assert tree.type == :column
      assert ids(tree) == ["tip-open", "tip-trigger"]
      assert text(tree) =~ "Copy"
      assert text(tree) =~ "⧉"
    end

    test "a closed tooltip still renders its trigger, and nothing else" do
      tree = MishkaTooltip.tooltip(%{text: "Copy", open: false, id: "tip"}, [control()])

      assert ids(tree) == ["tip-trigger"]
      refute text(tree) =~ "Copy"
    end

    test "holding it asks for the state the tooltip does not have" do
      shut = MishkaTooltip.tooltip(%{text: "x", open: false, on_open_change: :chg}, [control()])
      open = MishkaTooltip.tooltip(%{text: "x", open: true, on_open_change: :chg}, [control()])

      assert {self(), {:chg, true}} == trigger(shut).props.on_long_press
      assert {self(), {:chg, false}} == trigger(open).props.on_long_press
    end

    test "an already-wired handler is passed through rather than re-wrapped" do
      # Written as a tag, Mob.Composite widens on_open_change to {pid, tag}
      # BEFORE expand/3 runs. Composing that again would bury the tag one level
      # deeper and the screen's clause would silently never match.
      pid = self()

      tree =
        MishkaTooltip.tooltip(%{text: "x", open: false, on_open_change: {pid, :chg}}, [control()])

      assert {^pid, {:chg, true}} = trigger(tree).props.on_long_press
    end

    test "no handler means no prop, not a nil one" do
      tree = MishkaTooltip.tooltip(%{text: "x", open: false}, [control()])

      refute Map.has_key?(trigger(tree).props, :on_long_press)
    end

    test "the wrapped control's own tap rides on the trigger" do
      # Compose hands a gesture to the innermost clickable, so a tappable child
      # would eat the hold. One node carries both.
      node =
        %{text: "x", open: false, on_open_change: :chg, on_tap: :use}
        |> MishkaTooltip.tooltip([control()])
        |> trigger()

      assert node.props.on_tap == {self(), :use}
      assert node.props.on_long_press == {self(), {:chg, true}}
    end
  end

  describe "disabled" do
    test "wires no hold handler" do
      tree =
        MishkaTooltip.tooltip(
          %{text: "x", open: false, disabled: true, on_open_change: :chg},
          [control()]
        )

      refute Map.has_key?(trigger(tree).props, :on_long_press)
    end

    test "beats open — the hint is what is switched off" do
      tree =
        MishkaTooltip.tooltip(%{text: "x", open: true, disabled: true, id: "tip"}, [control()])

      assert ids(tree) == ["tip-trigger"]
      refute text(tree) =~ "x"
    end

    test "leaves the control's own tap alone" do
      tree =
        MishkaTooltip.tooltip(%{text: "x", disabled: true, on_tap: :use}, [control()])

      assert trigger(tree).props.on_tap == {self(), :use}
    end
  end

  describe "dismissal" do
    test "tapping the bubble asks to close — the phone's Escape" do
      tree = MishkaTooltip.tooltip(%{text: "x", open: true, on_open_change: :chg}, [control()])

      assert bubble(tree).props.on_tap == {self(), {:chg, false}}
    end

    test "close_on_tap: false leaves the bubble inert" do
      tree =
        MishkaTooltip.tooltip(
          %{text: "x", open: true, close_on_tap: false, on_open_change: :chg, id: "tip"},
          [control()]
        )

      refute Map.has_key?(bubble(tree).props, :on_tap)
    end
  end

  describe "side" do
    test "top and left put the bubble before the trigger, bottom and right after" do
      for {side, order} <- [
            {:top, ["tip-open", "tip-trigger"]},
            {:bottom, ["tip-trigger", "tip-open"]},
            {:left, ["tip-open", "tip-trigger"]},
            {:right, ["tip-trigger", "tip-open"]}
          ] do
        tree = MishkaTooltip.tooltip(%{text: "x", open: true, id: "tip", side: side}, [control()])
        assert ids(tree) == order, "side #{side} stacked as #{inspect(ids(tree))}"
      end
    end

    test "a vertical side stacks, a horizontal one sits beside" do
      above = MishkaTooltip.tooltip(%{text: "x", open: true, side: :top}, [control()])
      beside = MishkaTooltip.tooltip(%{text: "x", open: true, side: :left}, [control()])

      assert above.type == :column
      assert beside.type == :row
    end

    test "accepts the web's string spelling as well as the atom" do
      atom = MishkaTooltip.tooltip(%{text: "x", open: true, side: :bottom}, [control()])
      string = MishkaTooltip.tooltip(%{text: "x", open: true, side: "bottom"}, [control()])

      assert atom == string
    end

    test "an unknown side falls back to the default rather than blowing up" do
      assert MishkaTooltip.tooltip(%{text: "x", open: true, side: :sideways}, [control()]) ==
               MishkaTooltip.tooltip(%{text: "x", open: true, side: :top}, [control()])
    end
  end

  describe "side_offset" do
    test "is the gap between trigger and bubble" do
      tree = MishkaTooltip.tooltip(%{text: "x", open: true, side_offset: 20}, [control()])

      assert Enum.any?(flatten(tree), &(&1.type == :spacer and &1.props[:size] == 20))
    end

    test "goes with the bubble, so a closed tooltip reserves nothing" do
      tree = MishkaTooltip.tooltip(%{text: "x", open: false, side_offset: 20}, [control()])

      refute Enum.any?(flatten(tree), &(&1.type == :spacer and &1.props[:size] == 20))
    end
  end

  describe "align" do
    test "across a vertical side it is a flexible Spacer on the free side" do
      for {align, before, after_} <- [{:start, 0, 1}, {:center, 1, 1}, {:end, 1, 0}] do
        row =
          %{text: "x", open: true, align: align}
          |> MishkaTooltip.tooltip([control()])
          |> find(:row)

        {lead, [_bubble | trail]} =
          Enum.split_while(row.children, &(&1.type == :spacer and &1.props[:weight] == 1))

        assert length(lead) == before, "align #{align} had #{length(lead)} leading spacers"
        assert length(trail) == after_, "align #{align} had #{length(trail)} trailing spacers"
      end
    end

    test "across a horizontal side it is the Row's own vertical alignment" do
      for {align, expected} <- [{:start, :top}, {:center, :center}, {:end, :bottom}] do
        tree =
          MishkaTooltip.tooltip(%{text: "x", open: true, side: :left, align: align}, [control()])

        assert tree.props.align == expected
      end
    end
  end

  describe "align_offset" do
    test "nudges along the horizontal axis for a vertical side" do
      tree = MishkaTooltip.tooltip(%{text: "x", open: true, align_offset: 8}, [control()])

      assert bubble(tree).props.offset_x == 8
      refute Map.has_key?(bubble(tree).props, :offset_y)
    end

    test "nudges along the vertical axis for a horizontal side" do
      tree =
        MishkaTooltip.tooltip(%{text: "x", open: true, side: :right, align_offset: 8}, [control()])

      assert bubble(tree).props.offset_y == 8
      refute Map.has_key?(bubble(tree).props, :offset_x)
    end

    test "adds to an explicit offset rather than replacing it" do
      tree =
        MishkaTooltip.tooltip(%{text: "x", open: true, offset_x: 4, align_offset: 8}, [control()])

      assert bubble(tree).props.offset_x == 12
    end
  end

  describe "the arrow" do
    test "is off unless asked for" do
      tree = MishkaTooltip.tooltip(text: "x", open: true)

      assert find(tree, :canvas) == nil
    end

    test "is a filled triangle in the bubble's own colour" do
      tree = MishkaTooltip.tooltip(text: "x", open: true, arrow: true, background: 0xFF7C3AED)
      [op] = find(tree, :canvas).props.draw

      assert op.op == :path
      assert op.fill == true
      assert op.closed == true
      assert op.color == 0xFF7C3AED
      assert length(op.points) == 3
    end

    test "points back at the trigger on every side" do
      # A tooltip on the :top of its trigger sits ABOVE it, so its arrow points
      # DOWN and the apex is on the low edge. Beside a trigger the triangle
      # turns on its side, and the canvas turns with it.
      drawn =
        for side <- [:top, :bottom, :left, :right] do
          canvas =
            %{text: "x", open: true, arrow: true, side: side}
            |> MishkaTooltip.tooltip([control()])
            |> find(:canvas)

          [op] = canvas.props.draw
          {side, {canvas.props.width, canvas.props.height}, op.points}
        end

      assert drawn == [
               {:top, {12, 6}, [[0, 0], [12, 0], [6.0, 6]]},
               {:bottom, {12, 6}, [[0, 6], [12, 6], [6.0, 0]]},
               {:left, {6, 12}, [[0, 0], [6, 6.0], [0, 12]]},
               {:right, {6, 12}, [[6, 0], [0, 6.0], [6, 12]]}
             ]
    end

    test "the stacking Box aligns it to the edge that faces the trigger" do
      for {side, align} <- [
            {:top, :bottom_center},
            {:bottom, :top_center},
            {:left, :trailing},
            {:right, :leading}
          ] do
        tree =
          MishkaTooltip.tooltip(%{text: "x", open: true, arrow: true, side: side}, [control()])

        assert Enum.any?(flatten(tree), &(&1.props[:align] == align)),
               "no #{align} stack for side #{side}"
      end
    end
  end

  describe "testTags" do
    test "the trigger, the bubble and the arrow each get one" do
      tree =
        MishkaTooltip.tooltip(
          %{text: "x", open: true, id: "tip", arrow: true, side: :bottom},
          [control()]
        )

      assert ids(tree) == ["tip-trigger", "tip-open", "tip-arrow-bottom"]
    end

    test "the arrow's tag carries the side, because a drawn triangle is unreadable" do
      for side <- [:top, :bottom, :left, :right] do
        tree =
          MishkaTooltip.tooltip(%{text: "x", open: true, id: "t", arrow: true, side: side}, [
            control()
          ])

        assert "t-arrow-#{side}" in ids(tree)
      end
    end

    test "no id means no tags at all" do
      tree = MishkaTooltip.tooltip(%{text: "x", open: true, arrow: true}, [control()])

      assert ids(tree) == []
    end
  end

  describe "fill_width" do
    test "the stack fills by default, so align has room" do
      tree = MishkaTooltip.tooltip(%{text: "x", open: true}, [control()])

      assert tree.props.fill_width == true
      assert Enum.any?(flatten(tree), &(&1.type == :spacer and &1.props[:weight] == 1))
    end

    test "turning it off drops the flexible spacers that would starve a sibling" do
      tree = MishkaTooltip.tooltip(%{text: "x", open: true, fill_width: false}, [control()])

      assert tree.props.fill_width == false
      refute Enum.any?(flatten(tree), &(&1.type == :spacer and &1.props[:weight] == 1))
    end

    test "a horizontal side drops its trailing spacer too" do
      tree =
        MishkaTooltip.tooltip(%{text: "x", open: true, side: :left, fill_width: false}, [
          control()
        ])

      refute Enum.any?(flatten(tree), &(&1.type == :spacer and &1.props[:weight] == 1))
    end
  end

  test "expand/3 delegates to tooltip/2" do
    assert MishkaTooltip.expand(%{text: "x", open: true}, [], %{screen: self()}) ==
             MishkaTooltip.tooltip(text: "x", open: true)

    assert MishkaTooltip.expand(%{text: "x", open: true}, [control()], %{screen: self()}) ==
             MishkaTooltip.tooltip(%{text: "x", open: true}, [control()])
  end

  test "every variant renders" do
    for props <- [
          %{open: true},
          %{text: "x", open: true},
          %{text: "x", open: false},
          %{text: "x", open: true, arrow: true, side: :left, align: :end},
          %{text: "x", open: true, disabled: true, id: "t"}
        ],
        children <- [[], [control()]] do
      assert_renderable(MishkaTooltip.tooltip(props, children), extra: [:canvas])
    end
  end

  # The bubble is the node carrying the hint, which is the only :box with a
  # background — the trigger and the arrow stack are both bare wrappers.
  defp bubble(tree) do
    tree
    |> flatten()
    |> Enum.find(&(&1.type == :box and Map.has_key?(&1.props, :background)))
  end

  # And the trigger is the bare one — no background, and no `align` either,
  # which is what tells it apart from the arrow's stacking Box. `find(tree,
  # :box)` is not enough: on the default side the bubble comes FIRST in the
  # tree, so a depth-first search hands back the hint and every handler
  # assertion quietly checks the wrong node.
  defp trigger(tree) do
    tree
    |> flatten()
    |> Enum.find(
      &(&1.type == :box and
          not Map.has_key?(&1.props, :background) and
          not Map.has_key?(&1.props, :align))
    )
  end
end
