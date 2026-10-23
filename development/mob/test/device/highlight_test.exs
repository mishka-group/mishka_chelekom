defmodule MishkaMob.Device.HighlightTest do
  @moduledoc """
  Device tests for the Mark and Highlight pages: a port of `HighlightTest.kt`, one
  test per `@Test`, on the host-driven suite instead of Compose instrumentation.

  A mark rendered as a full-width bar rather than a highlighted word, the
  opposite of what `<mark>` means, because a Box told neither `width` nor
  `fill_width` fills its parent. The node tree was correct throughout, so the
  assertions here are geometric: `a mark sits inline with its neighbour` fails on
  the old build and nothing in `mix test` could.

  The other thing only a device shows is the wrap. `Text` has no span API, so a
  highlighted sentence is many nodes in a `Row`, and a `Row` does not wrap:
  `wrap_at` packs them into lines by a declared character budget.

  Case sensitivity is deliberately NOT tested here: a node's background is not
  readable on a device, so "is this word marked" is unanswerable there.
  `MishkaHighlightTest` covers it against `split/3` directly.

  A mark is addressed by its tag: `MishkaMark` puts its `id` on the Box, and
  `MishkaHighlight` numbers its marks `<id>-0`, `<id>-1`, ... in reading order.

  Run with `mix test --only device test/device/highlight_test.exs`.
  """
  use MishkaMob.DeviceCase

  describe "Mark" do
    @describetag page: :mark

    test "a mark sits inline with its neighbour" do
      scroll_into_view("mark-beam")

      # THE regression. A filling mark takes the whole line, so these two cannot
      # share a row, which is exactly what the screen showed.
      beam = frame!("mark-beam")
      device = frame!("mark-device")

      assert same_row?(beam, device),
             "different rows: BEAM=#{inspect(beam)} onDevice=#{inspect(device)}"

      assert device.left > beam.right, "\"on device\" is not to the right of \"BEAM\""
    end

    test "a mark hugs its word rather than filling the line" do
      beam = scroll_into_view("mark-beam")
      page = frame!("page")

      assert beam.width < page.width / 3,
             "a mark spans #{beam.width} of #{page.width}: it is filling, not hugging"
    end

    test "a mark composes inline with ordinary text" do
      scroll_into_view("mark-error")

      # The per-match-colour example: a tinted word followed by plain text, which
      # is what Highlight's single background cannot express.
      error = frame!("mark-error")
      rest = frame!("mark-error-rest")

      assert same_row?(error, rest), "the mark and its sentence are on different rows"
      assert rest.left > error.right, "the sentence is not to the right of the mark"
    end

    test "the mark page renders every example and the props table" do
      assert_headings([
        "Highlighted text",
        "A colour per mark",
        "In a sentence",
        "Colours",
        "Props"
      ])
    end
  end

  describe "Highlight" do
    @describetag page: :highlight

    test "a highlighted sentence wraps instead of running off the edge" do
      scroll_into_view("hl-every-0")

      # wrap_at={34} breaks this sentence after "THIS", so the first two marks
      # share a line and the third starts the next one.
      first = frame!("hl-every-0")
      second = frame!("hl-every-1")
      third = frame!("hl-every-2")

      assert same_row?(first, second),
             "different rows: This=#{inspect(first)} THIS=#{inspect(second)}"

      refute same_row?(first, third), "no wrap: This=#{inspect(first)} this=#{inspect(third)}"

      assert third.top > first.top,
             "this above This: This=#{inspect(first)} this=#{inspect(third)}"

      # ...and nothing left the screen on the way.
      edge = frame!("page").right

      for mark <- [first, second, third] do
        assert mark.right <= edge, "a mark at #{mark.right} is past the edge (#{edge})"
      end
    end

    test "the highlight page renders every example and the props table" do
      assert_headings([
        "Every occurrence",
        "Case sensitivity",
        "Matching a query",
        "Several queries",
        "Wrapping a sentence",
        "No match, no marks",
        "Props"
      ])
    end

    test "the live query follows the tapped button" do
      # The button is the query itself, and the page keeps rendering the sentence
      # it marks: a crash or a dropped handler shows up here. "che" marks the
      # "Che" of "Chelekom"; nothing in "Mishka Chelekom" matches "beam".
      scroll_into_view("hl-query-beam")
      assert_shown("hl-live-0")

      tap("hl-query-beam")

      assert Map.fetch!(assigns(), :hl_query) == "beam"
      refute_shown("hl-live-0")
      assert_shown("hl-live")

      tap("hl-query-o")

      assert Map.fetch!(assigns(), :hl_query) == "o"
      assert_shown("hl-live-0")
    end

    test "the code samples show the tags inside a sigil" do
      tree = render_tree()

      assert tree_has_text?(tree, "<MishkaHighlight"), "no <MishkaHighlight ... /> in the samples"

      # wrap_at and case_sensitive are the two props a reader cannot guess, so
      # both appear in a sample rather than only in the table.
      for prop <- ["wrap_at", "case_sensitive"] do
        assert tree_has_text?(tree, prop), "#{prop} appears in no code sample"
      end
    end
  end

  defp same_row?(a, b) do
    {_x, a_y} = center(a)
    {_x, b_y} = center(b)

    abs(a_y - b_y) < a.height
  end

  # Every heading is a text the rendered tree carries, and the page is one long
  # scroll that reaches its end.
  defp assert_headings(headings) do
    for heading <- headings, do: assert_text(heading)

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
