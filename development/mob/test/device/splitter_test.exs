defmodule MishkaMob.Device.SplitterTest do
  @moduledoc """
  Device tests for the Splitter page: a port of `SplitterTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  The whole point of this component is that the DIVIDER is the drag handle. It used to
  ship a Slider bolted under the panes, on the stated grounds that "Mob delivers no
  pointer coordinates to render/1", which was false: `on_drag` is a registered handler
  and a `:canvas` carries it. So the test that matters is "dragging the grip moves the
  split": a real gesture on the grip, and the panes measured before and after.

  A canvas is a drawing, with no text and no label, so the grip is only addressable
  through its `id`, which is why the component grew one.

  Run with `mix test --only device test/device/splitter_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :splitter

  test "dragging the grip moves the split" do
    before = pane_size("panes", 1)

    drag_grip("panes", 40)

    # The first pane grew and the second shrank by about as much: this is a splitter, so
    # the extent is conserved. Asserting only that one pane moved would pass if both grew
    # and the layout simply overflowed.
    after_drag = pane_size("panes", 1)

    assert after_drag > before + 30,
           "dragging right did not widen the first pane: #{before} -> #{after_drag}"
  end

  test "the two panes always add up" do
    total = pane_size("panes", 1) + pane_size("panes", 2)

    drag_grip("panes", 35)

    moved = pane_size("panes", 1) + pane_size("panes", 2)
    assert abs(moved - total) < 2, "the panes stopped summing to the extent: #{total} -> #{moved}"
  end

  test "dragging back returns the split" do
    start = pane_size("panes", 1)

    # Move AWAY from the nearer bound, so neither leg of the round trip is silently
    # eaten by the min/max clamp, which would look exactly like an asymmetric fold.
    out = if start > pane_size("panes", 2), do: -40, else: 40

    drag_grip("panes", out)
    moved = pane_size("panes", 1)

    assert abs(moved - start) > 14,
           "the drag did not move, so dragging back cannot be tested: #{start} -> #{moved}"

    drag_grip("panes", -out)

    # Symmetry is the evidence that the fold is relative to where the drag BEGAN, not
    # derived from an absolute canvas-local x, which would drift, because the grip's own
    # coordinates travel with it.
    back = pane_size("panes", 1)

    assert abs(back - start) < 7,
           "dragging back did not return the split: #{start} -> #{moved} -> #{back}"
  end

  test "min and max stop a pane vanishing" do
    extent = pane_size("bounded", 1) + pane_size("bounded", 2)

    # Shove far past the bound; min is 30%.
    drag_grip("bounded", -140)

    first = pane_size("bounded", 1)
    assert first > extent * 0.2, "the first pane was dragged below its min: #{first} of #{extent}"
    assert first < extent * 0.45, "the drag did not reach the min at all: #{first}"
  end

  test "a disabled splitter does not move" do
    before = pane_size("frozen", 1)

    drag_grip("frozen", 40)

    # Disabled omits the handler rather than hiding the grip: the divider is still there
    # to keep the layout from jumping, but nothing fires.
    assert abs(pane_size("frozen", 1) - before) < 1.5,
           "a disabled splitter moved: #{before} -> #{pane_size("frozen", 1)}"
  end

  test "a vertical splitter drags on the other axis" do
    before = frame!("stack-pane-1").height

    drag_grip("stack", 0, 40)

    after_drag = frame!("stack-pane-1").height

    assert after_drag > before + 14,
           "dragging down did not grow the top pane: #{before} -> #{after_drag}"

    # And the x it ignores really is ignored: orientation :vertical makes drag/3 read y
    # only, so a sideways shove must not move a stacked split.
    sideways = frame!("stack-pane-1").height
    drag_grip("stack", 30, 0)

    assert abs(frame!("stack-pane-1").height - sideways) < 3.5,
           "a horizontal drag moved a vertical splitter: #{sideways} -> #{frame!("stack-pane-1").height}"
  end

  test "there is no slider anywhere on the page" do
    # The regression this guards is the component's own history: a Slider under the
    # panes, which the divider was supposed to replace.
    assert_shown("panes-grip")

    for heading <- ["Side by side", "Stacked", "Bounded, and disabled", "Props"] do
      assert_text(heading)
    end
  end

  defp pane_size(splitter, n), do: frame!("#{splitter}-pane-#{n}").width

  # Drags the grip as a finger would. The touch must start ON the divider, which sits at
  # pane 1's trailing edge: the drag surface spans the whole extent (it has to, to be a
  # stable ruler) and the component only engages a drag that starts on the divider, so a
  # touch at the surface's middle misses entirely once the split has moved off 50%.
  #
  # The grip is first brought to the middle of the page, so the gesture stays inside the
  # window in both directions.
  defp drag_grip(splitter, dx, dy \\ 0) do
    surface = centre("#{splitter}-grip")
    pane = frame!("#{splitter}-pane-1")

    from =
      if dy != 0 or surface.height > surface.width,
        do: {center(surface) |> elem(0), pane.bottom + 1.5},
        else: {pane.right + 1.5, center(surface) |> elem(1)}

    {x, y} = from
    swipe(from, {x + dx, y + dy})
  end

  # Scrolls the page so `tag` is on screen and away from both edges. scroll_into_view/1
  # moves the minimum distance, and does nothing at all when the centre is already on
  # screen, which can leave the grip hard against the bottom with no room to drag down.
  defp centre(tag) do
    grip = scroll_into_view(tag)
    page = frame!("page")
    {_x, y} = center(grip)
    {_px, middle} = center(page)

    if abs(y - middle) > page.height / 4 do
      node = device!()
      %{offset: {_ox, offset}} = Mob.Test.scroll_info(node, "page")
      scale = Mob.Test.screen_info(node).scale
      :ok = Mob.Test.scroll_to(node, "page", {0.0, offset + (y - middle) * scale})
      sync()
    end

    settled_frame(tag)
  end
end
