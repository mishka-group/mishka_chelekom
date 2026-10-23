defmodule MishkaMob.Device.RollingNumberTest do
  @moduledoc """
  Device tests for the Rolling Number page: a port of `RollingNumberTest.kt`, one
  test per `@Test`, on the host-driven suite instead of Compose instrumentation.

  The component itself is one Text node, and the interesting half is that it
  CANNOT animate itself. `steps/3` is a pure function and the screen walks the
  sequence on a timer, so the only honest device assertion is the round trip: tap,
  and the number must arrive at the target. The easing is unit-tested off
  `steps/3` instead (`mishka_rolling_number_test.exs`), where it is exact and not a
  race.

  Each example prints its own source, so "1234567" and "1,284" are in the tree
  whether or not anything rendered. The numbers are addressed by tag instead
  (`rn-count`, `rn-comma`, ...), and their text is read from the rendered tree.

  Run with `mix test --only device test/device/rolling_number_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :rolling_number

  test "the number rolls all the way to its target" do
    assert_reads("rn-count", "0")

    tap("rn-roll")

    # steps/3 always lands exactly on the target. An eased walk that stopped one
    # step short would still look plausible on screen, which is why the assertion is
    # the exact landing value and not "it changed".
    assert_reads("rn-count", "1,284", timeout: 15_000)
  end

  test "it counts down as happily as up" do
    tap("rn-roll")
    assert_reads("rn-count", "1,284", timeout: 15_000)

    tap("rn-down")

    # The number this button rolls is the one in the "Counting up" card above, so
    # it is that tag that must leave 1,284 and land on 42.
    assert_reads("rn-count", "42", timeout: 15_000)
  end

  test "reset returns it to zero" do
    tap("rn-roll")
    assert_reads("rn-count", "1,284", timeout: 15_000)

    tap("rn-reset")

    assert_reads("rn-count", "0")
  end

  test "grouping renders every separator the description promises" do
    # The page claims a comma, a space, none, and a preserved sign. All four used to
    # be claimed and only three rendered.
    for {tag, rendered} <- [
          {"rn-comma", "1,234,567"},
          {"rn-space", "1 234 567"},
          {"rn-none", "1234567"},
          {"rn-negative", "-98,765"}
        ] do
      scroll_into_view(tag)
      assert_shown(tag)
      assert text_of(tag) == rendered, "the grouping example never rendered #{rendered}"
    end
  end

  test "the page renders every example and the props table" do
    for heading <- ["Counting up", "Counting down", "Grouping", "Size and colour", "Props"] do
      assert_text(heading)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  defp assert_reads(tag, text, opts \\ []) do
    assert_shown(tag)

    assert_eventually(fn -> text_of(tag) == text end,
      timeout: Keyword.get(opts, :timeout, 3_000),
      message: fn -> "#{tag} reads #{inspect(text_of(tag))}, not #{inspect(text)}" end
    )
  end

  defp text_of(tag) do
    case find_node(render_tree(), to_string(tag)) do
      %{props: %{text: text}} -> text
      other -> flunk("#{tag} is not a text node: #{inspect(other)}")
    end
  end

  defp find_node(%{props: props, children: children} = node, id) do
    if to_string(Map.get(props, :id, "")) == id,
      do: node,
      else: Enum.find_value(children || [], &find_node(&1, id))
  end

  defp find_node(_leaf, _id), do: nil
end
