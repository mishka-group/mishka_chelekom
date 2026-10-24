defmodule MishkaMob.Device.ProgressTest do
  @moduledoc """
  Device tests for the Progress page: a port of `ProgressTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  The bar carries no text, so what is asserted is the READOUT beside it, which the
  page renders from the same assign the buttons move, making each of these a round
  trip. It is read from the rendered tree: the first text on the page shaped like a
  percentage, which is the one the buttons are wired to.

  The Kotlin class had to freeze Compose's animation clock first, because this page
  renders an INDETERMINATE bar that loops forever and an infinite animation means
  Compose never reports idle. These tests drive real touches and wait on a native
  frame barrier instead, which an animation does not hold up, so nothing is frozen.

  Run with `mix test --only device test/device/progress_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :progress

  test "the buttons move the bar and the readout follows" do
    start = percent()

    tap("pg-up")
    assert_eventually(fn -> percent() != start end, message: "the readout never left #{start}%")
    up = percent()
    assert up > start, "+15 went from #{start}% to #{up}%"

    tap("pg-down")
    assert_eventually(fn -> percent() != up end, message: "the readout never left #{up}%")
    assert percent() < up, "-15 did not come back down from #{up}%"
  end

  test "the value clamps rather than overshooting its track" do
    # Two clamps have to agree. fraction/1 pins what is DRAWN to 0..1, and the
    # screen pins the value it stores: without the second, the assign kept
    # climbing behind a full bar and coming back down took as many extra taps as
    # you had wasted going up.
    for _fill <- 1..10, do: tap("pg-up")
    assert percent() == 100, "after ten +15s the readout is #{percent()}%, not 100%"

    # One tap down must move it immediately, which is only true if the stored
    # value stopped at 100 too.
    tap("pg-down")
    assert percent() == 85, "one tap down from full gave #{percent()}%, not 85%"

    for _drain <- 1..6, do: tap("pg-down")
    assert percent() == 0, "seven taps down from full gave #{percent()}%, not 0%"
  end

  test "a custom readout replaces the percentage" do
    # value_text overrides the rounded percentage entirely: "3 of 5" is not
    # something the component could derive. Exact, not contained, because the code
    # sample carries the same words.
    assert "3 of 5" in texts(), "value_text did not replace the computed readout"
  end

  test "the indeterminate bar shows no readout" do
    # There is no percentage to report, so show_value is ignored rather than
    # rendering a misleading 0%. The bar is tagged; the column it sits in holds its
    # caption and nothing shaped like a percentage.
    assert_shown("pg-connecting")

    block = parent_of(render_tree(), "pg-connecting")
    assert "Connecting…" in texts(block), "the caption is not beside its bar"

    readouts = Enum.filter(texts(block), &Regex.match?(~r/\d+%/, &1))
    assert readouts == [], "the indeterminate bar rendered a readout: #{inspect(readouts)}"
  end

  test "the page renders every example and the props table" do
    for heading <- ["Determinate", "Indeterminate", "Custom range and readout", "Colour", "Props"] do
      assert_text(heading)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  # The node directly above the one tagged `id`.
  defp parent_of(%{children: children} = node, id) do
    if Enum.any?(children || [], &tagged?(&1, id)),
      do: node,
      else: Enum.find_value(children || [], &parent_of(&1, id))
  end

  defp parent_of(_leaf, _id), do: nil

  defp tagged?(%{props: props}, id), do: to_string(Map.get(props, :id, "")) == id
  defp tagged?(_leaf, _id), do: false
end
