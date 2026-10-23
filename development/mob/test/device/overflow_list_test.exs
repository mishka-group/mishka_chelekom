defmodule MishkaMob.Device.OverflowListTest do
  @moduledoc """
  Device tests for the Overflow List page: a port of `OverflowListTest.kt`, one test
  per `@Test`, on the host-driven suite instead of Compose instrumentation.

  Two things are worth asserting on a device and nowhere else.

  The counter must HUG. A box given neither a width nor `fill_width` fills its parent,
  which turned the "+N" pill into a bar stretching across the rest of the row: a pure
  layout fact that no unit test can see, because the tree is identical either way.
  "the counter hugs its label" measures it.

  And the item count must follow `visible`. Items are caller-supplied nodes, so the
  component stamps `<id>-item-<n>` on each SHOWN one: counting those tags counts what
  survived the split.

  Run with `mix test --only device test/device/overflow_list_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :overflow_list

  # Roughly 70dp of finger travel along the rail: enough to cross touch slop and to
  # change how many badges fit.
  @pull 70

  test "the counter hugs its label" do
    scroll_into_view("langs")

    counter = frame!("langs-counter")
    item = frame!("langs-item-1")
    row = frame!("langs")

    # "+4" is shorter than "Design", so the pill must be narrower than a real item, and
    # nowhere near the full row. Without fill_width={false} it filled its parent and
    # stretched across everything left over, which is what this measures and what a unit
    # test cannot see.
    assert counter.width < item.width,
           "the +N counter is wider than an item: counter=#{inspect(counter)} item=#{inspect(item)}"

    assert counter.width < row.width / 2,
           "the +N counter stretched across the row: counter=#{inspect(counter)} row=#{inspect(row)}"
  end

  test "the counter is not squeezed into a column of characters" do
    scroll_into_view("langs")

    counter = frame!("langs-counter")
    item = frame!("langs-item-1")
    row = frame!("langs")

    # The bug this guards, exactly as reported: with every child of the Row unweighted,
    # Compose measured them in order and the counter, last, got the scraps, so "+4"
    # wrapped CHARACTER BY CHARACTER into a stack of "+" over "4". Two independent
    # symptoms, so two assertions.
    #
    # 1. It is no taller than an item. A two-line counter is roughly double.
    assert counter.height < item.height * 1.5,
           "the counter is stacking its characters vertically: " <>
             "counter=#{inspect(counter)} item=#{inspect(item)}"

    # 2. It is wide enough to actually read. A starved counter collapsed to roughly one
    # character (the Kotlin bound, 40px, is 14dp).
    assert counter.width > 14,
           "the counter was squeezed to #{inspect(counter)}: there is no room for the count"

    # And it sits INSIDE the row it belongs to, rather than being pushed out past the
    # edge.
    assert counter.right <= row.right + 1,
           "the counter overflowed its row: counter=#{inspect(counter)} row=#{inspect(row)}"
  end

  test "dragging the box's right edge changes how many fit" do
    scroll_into_view("rail-handle")
    before = shown_count("rail")

    # Grab the box's RIGHT EDGE: the drag only engages there. The canvas spans the whole
    # width range and covers the badges, so that a tap on a badge cannot snap the width
    # to the finger.
    edge = frame!("rail")
    y = center(frame!("rail-handle")) |> elem(1)
    swipe({edge.right, y}, {edge.right + @pull, y})

    after_pull = shown_count("rail")

    assert after_pull > before,
           "pulling the edge right did not reveal more badges: #{before} -> #{after_pull}"

    # And back: narrowing hides them again, so the count follows the width rather than
    # only ever growing.
    wider = frame!("rail")
    swipe({wider.right, y}, {wider.right - @pull, y})

    narrowed = shown_count("rail")

    assert narrowed < after_pull,
           "pulling the edge back did not hide badges: #{after_pull} -> #{narrowed}"
  end

  test "a touch away from the edge does not resize" do
    scroll_into_view("rail-handle")
    before = shown_count("rail")

    # The drag surface has to cover the badges to be a stable ruler, so the handler
    # refuses any gesture that does not start on the edge: otherwise tapping a badge
    # would snap the box to your finger.
    box = frame!("rail")
    y = center(frame!("rail-handle")) |> elem(1)
    swipe({box.left + 7, y}, {box.left + 7 + @pull, y})

    assert shown_count("rail") == before,
           "a drag starting on a badge resized the box: #{before} -> #{shown_count("rail")}"
  end

  test "it shows exactly what visible asks for" do
    scroll_into_view("langs")

    # visible={3} over seven tags.
    assert shown_count("langs") == 3, "expected 3 items, found #{shown_count("langs")}"
    assert shown?("langs-counter"), "four items are hidden but no counter was drawn"
  end

  test "tapping the counter reveals one more" do
    scroll_into_view("more")
    before = shown_count("more")

    tap("more-counter")

    assert_eventually(
      fn -> shown_count("more") > before end,
      message: "tapping the counter revealed nothing (still #{before} items)"
    )
  end

  test "min visible is a floor" do
    scroll_into_view("floor-one")

    # Both ask for visible={0}. The first floors at the default 1, the second at
    # min_visible={2}, so the floor is doing the work, not the requested count, which is
    # zero in both cases.
    assert shown_count("floor-one") == 1,
           "visible={0} showed #{shown_count("floor-one")}, expected the default floor of 1"

    assert shown_count("floor-two") == 2, "min_visible={2} showed #{shown_count("floor-two")}"
  end

  test "the counter can say something other than plus N" do
    scroll_into_view("worded")

    assert shown?("worded-counter"), "the worded example drew no counter"

    # visible={2} of seven leaves five hidden, and counter_text turns that count into
    # prose rather than "+5". Read off the counter's own node: the page prints other
    # text of its own.
    counter = find_node("worded-counter")
    assert counter, "the rendered tree has no worded-counter"
    assert tree_has_text?(counter, "5 more"), "counter_text did not replace the +N label"
    refute tree_has_text?(counter, "+5"), "the +N label is still there"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Make it bigger",
          "Three fit, four do not",
          "Tap the counter",
          "min_visible is a floor",
          "A counter that says something else",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree.
    for id <- ~w(rail langs more floor-one floor-two worded), do: assert_shown(id)
  end

  # How many items the list actually rendered, counted by their own tags.
  defp shown_count(list) do
    item = ~r/^#{Regex.escape(list)}-item-\d+$/

    Enum.count(frames(), fn {tag, {_x, _y, width, height}} ->
      width > 0 and height > 0 and Regex.match?(item, tag)
    end)
  end
end
