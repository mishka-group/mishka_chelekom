defmodule MishkaMob.Showcase.TooltipPageTest do
  # async: false — the registry and composite registry are global (persistent_term).
  use Mob.ScreenCase, async: false

  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.ComponentScreen

  # A bubble's body is two 8dp paddings around one line of text and its arrow
  # adds 6dp: 36dp even at the smallest text, so nothing under this can hold one.
  @least_bubble_height 36
  # "side left" is the shortest hint on a left side, and it is wider than this.
  @least_bubble_width 48

  setup do
    Showcase.reset()
    Showcase.register_all()
    :ok
  end

  defp page do
    view = mount_screen(ComponentScreen, %{slug: :tooltip})

    view |> tree() |> Mob.Composite.expand(self())
  end

  defp nodes(node), do: [node | Enum.flat_map(node.children, &nodes/1)]

  # Every tooltip the page opens on its own, with the node it sits in and where.
  # An :anchored node with two children is an open one — a closed one has only
  # its trigger — and the trigger carries the id the example gave it.
  defp open_tooltips(tree) do
    for parent <- nodes(tree),
        {%{type: :anchored, children: [trigger, _bubble]} = anchored, index} <-
          Enum.with_index(parent.children) do
      %{id: trigger.props.id, anchored: anchored, parent: parent, index: index}
    end
  end

  defp open(tree, id), do: Enum.find(open_tooltips(tree), &(&1.id == id <> "-trigger"))

  defp sibling(%{parent: parent, index: index}, offset),
    do: Enum.at(parent.children, index + offset)

  describe "the examples that hold several bubbles open at once" do
    # The bubble is drawn in a window of its own and takes no room in the page,
    # so the only thing that keeps one off its neighbour's trigger and off the
    # description above is room reserved for it. These examples used to sit the
    # triggers 14dp apart, and every bubble landed on the next control.
    test "every one of them is open, so the check below covers all twelve" do
      ids = page() |> open_tooltips() |> Enum.map(& &1.id) |> Enum.sort()

      assert ids == [
               "align-center-trigger",
               "align-end-trigger",
               "align-start-trigger",
               "dismiss-soft-trigger",
               "dismiss-sticky-trigger",
               "side-bottom-trigger",
               "side-left-trigger",
               "side-right-trigger",
               "side-top-trigger",
               "style-dark-trigger",
               "style-plum-trigger",
               "style-token-trigger"
             ]
    end

    test "a bubble above its trigger has the room above it reserved, gap included" do
      tree = page()

      for id <- ~w(side-top align-start align-center align-end style-dark style-token style-plum) do
        tooltip = open(tree, id)
        room = sibling(tooltip, -1)

        assert tooltip.anchored.props.side == :top
        assert room.type == :box, "#{id} has nothing reserved above it"

        assert room.props.height >= tooltip.anchored.props.side_offset + @least_bubble_height,
               "#{id}: #{room.props.height}dp above it cannot hold its bubble"
      end
    end

    test "a bubble below its trigger has the room below it reserved" do
      tooltip = open(page(), "side-bottom")
      room = sibling(tooltip, 1)

      assert tooltip.anchored.props.side == :bottom
      assert room.type == :box
      assert room.props.height >= tooltip.anchored.props.side_offset + @least_bubble_height
    end

    test "a bubble to the left has the room to the left reserved, in a row" do
      tooltip = open(page(), "side-left")
      room = sibling(tooltip, -1)

      assert tooltip.anchored.props.side == :left
      assert tooltip.parent.type == :row
      assert room.type == :box
      assert room.props.width >= tooltip.anchored.props.side_offset + @least_bubble_width
      # A Spacer's size is both axes, so a run of space in a Row has to be a Box
      # of one dp tall — otherwise the row stands as tall as the space is wide.
      assert room.props.height == 1
    end

    test "the room is empty space, never something drawn" do
      tree = page()

      rooms = [
        sibling(open(tree, "side-top"), -1),
        sibling(open(tree, "side-bottom"), 1),
        sibling(open(tree, "side-left"), -1)
      ]

      for room <- rooms do
        assert room.children == []
        refute Map.has_key?(room.props, :background)
      end
    end

    test "the bubbles that open to the right are stacked, not set side by side in a row" do
      # Two right-hand bubbles in one row used to sit under each other's triggers.
      tree = page()

      for id <- ~w(dismiss-soft dismiss-sticky) do
        tooltip = open(tree, id)

        assert tooltip.anchored.props.side == :right
        assert tooltip.parent.type == :column
      end

      assert open(tree, "dismiss-soft").parent == open(tree, "dismiss-sticky").parent
    end
  end
end
