defmodule MishkaMob.Device.ChipTest do
  @moduledoc """
  Device tests for the Chip page: a port of `ChipTest.kt`, one test per `@Test`,
  on the host-driven suite instead of Compose instrumentation.

  `a chip hugs its label` is the regression this page was reported for. The pill
  was a Box with neither `width` nor `fill_width`, and such a Box FILLS its parent
  on both platforms, so one chip took the whole row and the set read as a stack of
  banners. Only layout can catch that, and the assertion is a measurement.

  A chip is checked or not by its fill colour alone, which is not in the
  accessibility tree, so the state rides in the tag: `chip-tag-erlang-idle` becomes
  `chip-tag-erlang-checked` when it is tapped. Each chip's label is `<chip>-label`.

  Run with `mix test --only device test/device/chip_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :chip

  import MishkaMob.DeviceText

  test "a chip hugs its label" do
    elixir = scroll_into_view("chip-tag-elixir-checked")
    erlang = frame!("chip-tag-erlang-idle")

    # Three chips share one row, so none may be anywhere near full width.
    assert elixir.width > 1 and elixir.width <= 400,
           "the chip is not chip-sized: #{inspect(elixir)}"

    # And they sit side by side rather than stacked.
    assert erlang.left >= elixir.right - 2,
           "chips are not on one line: #{inspect(elixir)} vs #{inspect(erlang)}"

    # Every label must render IN FULL, inside its own chip. It was once ellipsised,
    # because the chip carried its own padding on top of Material's: "Gleam" came
    # out as "Gle...".
    for {chip, label} <- [
          {"chip-tag-elixir-checked", "chip-tag-elixir-label"},
          {"chip-tag-erlang-idle", "chip-tag-erlang-label"},
          {"chip-tag-gleam-idle", "chip-tag-gleam-label"}
        ] do
      chip = frame!(chip)
      label = frame!(label)

      assert label.width > 0, "#{inspect(label)} did not render in full"
      assert label.left >= chip.left and label.right <= chip.right, "the label overran its chip"
    end
  end

  test "a longer label makes a wider chip" do
    scroll_into_view("chip-size-m-checked")

    # If the pill were filling its parent, every chip would measure the same. The
    # chips are measured, not their text: a Text hugs its content whatever its
    # parent does, so a text-bounds assertion passes even when the Box fills.
    short = frame!("chip-size-s-idle")
    long = frame!("chip-size-m-checked")

    assert long.width > short.width,
           "chips do not size to their label: Low=#{inspect(short)} Normal=#{inspect(long)}"
  end

  test "tapping a chip toggles membership" do
    scroll_into_view("chip-tag-erlang-idle")

    # The summary line is rendered from the same assign the chips drive, so it is
    # the honest witness that the composed {:tag, id} reached a clause.
    assert text_of("chip-summary") == "Selected: elixir"
    refute_shown("chip-tag-erlang-checked")

    tap("chip-tag-erlang-idle")
    assert_shown("chip-tag-erlang-checked")
    assert text_of("chip-summary") == "Selected: elixir, erlang"

    tap("chip-tag-erlang-checked")
    assert_shown("chip-tag-erlang-idle")
    assert text_of("chip-summary") == "Selected: elixir"
  end

  test "single select replaces rather than toggles" do
    scroll_into_view("chip-size-l-idle")
    assert_shown("chip-size-m-checked")
    neighbour = frame!("chip-size-m-checked")

    tap("chip-size-l-idle")

    # Replaced, not added to.
    assert_shown("chip-size-l-checked")
    assert_shown("chip-size-m-idle")

    # A radio set cannot be cleared: tapping the chosen one again leaves it chosen,
    # which is the whole difference from the checkbox set above. The chip still
    # hears the tap; it is the screen that keeps the choice.
    tap("chip-size-l-checked")
    assert_shown("chip-size-l-checked")
    refute_shown("chip-size-l-idle")
    assert Map.fetch!(assigns(), :chip_size) == :l

    # The Kotlin test could only check that the row had not reflowed; keep that too.
    assert frame!("chip-size-m-idle").width == neighbour.width, "the radio row reflowed"
  end

  test "the page renders every example and the props table" do
    for heading <- ["Multi-select", "Single select", "Disabled", "Colour", "Props"] do
      assert_text(heading)
    end

    for id <- ~w(chip-tag-elixir-checked chip-size-m-checked chip-locked-on-checked) do
      assert_shown(id)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
