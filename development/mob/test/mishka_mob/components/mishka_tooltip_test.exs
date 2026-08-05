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

      assert tree.type == :anchored
      # The bubble's -open tag comes SECOND now, because the trigger is always
      # the anchor and the bubble is always the panel — the order no longer
      # encodes which side the bubble is on.
      assert ids(tree) == ["tip-trigger", "tip-open"]
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

  # The bubble is not a sibling of the trigger any more: it is child [1] of an
  # :anchored node, drawn in its own window over the page. So these assert the
  # anchored node's PROPS. The old assertions were about ordering, flexible
  # spacers and Row alignment — all of which existed to place a bubble that
  # shared a parent with the control it describes, which is exactly why opening
  # a tooltip used to shove the next icon button sideways.
  describe "anchoring" do
    defp anchored(tree), do: Enum.find(flatten(tree), &(&1.type == :anchored))

    defp anchor_props(props) do
      anchored(MishkaTooltip.tooltip(Map.merge(%{text: "x", open: true}, props), [control()])).props
    end

    test "the trigger is the anchor and the bubble is the panel, in that order always" do
      node = anchored(MishkaTooltip.tooltip(%{text: "Copy", open: true, id: "tip"}, [control()]))

      assert length(node.children) == 2
      assert hd(node.children).props.id == "tip-trigger"
      assert text(List.last(node.children)) =~ "Copy"
    end

    test "side rides on the anchored node, for every side" do
      for side <- [:top, :right, :bottom, :left] do
        assert anchor_props(%{side: side}).side == side
      end
    end

    test "top is the default, and an unknown side falls back to it" do
      assert anchor_props(%{}).side == :top
      assert anchor_props(%{side: :sideways}).side == :top
      assert anchor_props(%{side: "bottom"}).side == :bottom
    end

    test "side_offset is the gap, and defaults to 6" do
      # It used to be a :spacer sibling, which cannot express a gap between two
      # things that are not in the same layout.
      assert anchor_props(%{}).side_offset == 6
      assert anchor_props(%{side_offset: 14}).side_offset == 14

      tree = MishkaTooltip.tooltip(%{text: "x", open: true}, [control()])
      refute Enum.any?(anchored(tree).children, &(&1.type == :spacer))
    end

    test "align rides on the anchored node instead of a flexible Spacer" do
      for align <- [:start, :center, :end] do
        assert anchor_props(%{align: align}).align == align
      end

      # No weighted spacers left anywhere — those WERE the alignment.
      tree = MishkaTooltip.tooltip(%{text: "x", open: true}, [control()])
      refute Enum.any?(flatten(tree), &(&1.type == :spacer and &1.props[:weight] == 1))
    end

    test "align_offset is one prop, not an axis-dependent offset" do
      # It used to fold into offset_x on a vertical side and offset_y on a
      # horizontal one, because a nudge in flow must name its axis.
      assert anchor_props(%{align_offset: 10}).align_offset == 10
      assert anchor_props(%{side: :left, align_offset: 10}).align_offset == 10
    end

    test "an explicit offset is the raw escape hatch, renamed so it moves the BUBBLE" do
      props = anchor_props(%{align_offset: 10, offset_x: -3, offset_y: 4})

      assert props.panel_offset_x == -3
      assert props.panel_offset_y == 4
      assert props.align_offset == 10

      # And it is NOT left on the bubble: Mob.Renderer would wrap the bubble in
      # an offset Box inside its own popup window, shifting the content out of
      # the window rather than moving the window.
      bubble =
        List.last(
          anchored(MishkaTooltip.tooltip(%{text: "x", open: true, offset_x: -3}, [control()])).children
        )

      refute Map.has_key?(bubble.props, :offset_x)
    end

    test "a closed tooltip anchors nothing but still holds its trigger" do
      node = anchored(MishkaTooltip.tooltip(%{text: "x", open: false, id: "tip"}, [control()]))

      assert length(node.children) == 1
      assert hd(node.children).props.id == "tip-trigger"
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
