defmodule MishkaMob.Device.ToggleTest do
  @moduledoc """
  Device tests for the Toggle page: a port of `ToggleTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  `a toggle hugs its label` is the reported regression. The button is a Box, and a
  Box given neither a width nor `fill_width` FILLS its parent, so every toggle
  rendered as one full-width slab and a toolbar of them was impossible. The chip
  fell into the identical trap one component earlier. Only layout can catch it: the
  node tree is perfectly correct either way, so this measures.

  Pressed differs from idle by fill colour alone, and colour is not in the
  accessibility tree, so the state rides in the tag: `tg-bold-pressed` /
  `tg-bold-idle`.

  Run with `mix test --only device test/device/toggle_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :toggle

  @states ~w(pressed idle)

  # The toggle's state, from whichever tag it carries now: "pressed", "idle", or nil
  # when it is not rendered at all.
  defp state_of(prefix), do: state_of(prefix, @states)

  # A state that must exist. Insisting on one, rather than accepting nil, means a
  # toggle that failed to render fails the test instead of quietly satisfying it.
  defp state_of!(prefix), do: state_of!(prefix, @states)

  defp toggle_frame(prefix), do: frame!(state_tag(prefix, @states))

  # Mirrors `summary/3` in the showcase, so the test can predict the line.
  defp expected_summary(bold?, italic?, underline?) do
    on =
      [{bold?, "bold"}, {italic?, "italic"}, {underline?, "underline"}]
      |> Enum.filter(&elem(&1, 0))
      |> Enum.map_join(", ", &elem(&1, 1))

    if on == "", do: "Nothing pressed", else: "Pressed: " <> on
  end

  test "a toggle hugs its label" do
    scroll_into_view("tg-bold-pressed")

    bold = toggle_frame("tg-bold")
    italic = toggle_frame("tg-italic")

    # Three buttons share one row, so none may be anywhere near full width.
    assert bold.width > 1 and bold.width <= 400,
           "the toggle is not button-sized: #{inspect(bold)}"

    # And they sit side by side rather than each taking its own line, which is
    # exactly what a filling Box produced.
    assert italic.left >= bold.right - 2,
           "toggles are not on one line: #{inspect(bold)} vs #{inspect(italic)}"
  end

  test "a longer label makes a wider button" do
    scroll_into_view("tg-long-idle")

    # Measure the BUTTON, not its text. A Text hugs its content whatever its parent
    # does, so a text-bounds assertion here passes even when the Box is filling the
    # row, which is exactly the bug being guarded.
    short = toggle_frame("tg-hug")
    long = toggle_frame("tg-long")

    assert long.width > short.width,
           "toggles do not size to their label: short=#{inspect(short)} long=#{inspect(long)}"
  end

  test "fill width true still spans when asked for" do
    scroll_into_view("tg-fill-pressed")

    # Hugging is the default, not the only option, so the opt-in must still work.
    hugging = toggle_frame("tg-hug")
    spanning = toggle_frame("tg-fill")

    assert spanning.width > hugging.width * 2,
           "fill_width did not span: hugging=#{inspect(hugging)} spanning=#{inspect(spanning)}"
  end

  test "pressing flips only that button" do
    scroll_into_view("tg-bold-pressed")

    bold_before = state_of!("tg-bold")
    italic_before = state_of!("tg-italic")
    under_before = state_of!("tg-under")

    tap("tg-bold-#{bold_before}")

    # Name the state the tap must produce. Waiting for merely "not what it was" is
    # satisfied by the toggle disappearing, since the state goes nil.
    bold_after = if bold_before == "pressed", do: "idle", else: "pressed"
    assert_shown("tg-bold-#{bold_after}")

    assert state_of("tg-italic") == italic_before, "pressing Bold disturbed Italic"
    assert state_of("tg-under") == under_before, "pressing Bold disturbed Underline"

    # The summary renders from the same assigns, so it is the honest witness that the
    # tap reached a handle_info clause rather than merely repainting, but only if it
    # is held to the ONE line those assigns imply. "Pressed:" or "Nothing pressed"
    # would be true for every possible input.
    expected =
      expected_summary(
        bold_after == "pressed",
        italic_before == "pressed",
        under_before == "pressed"
      )

    assert text_of("tg-summary") == expected, "the summary did not follow the tap"
  end

  test "a disabled toggle is inert but still shows its state" do
    scroll_into_view("tg-lockon-pressed")

    # Disabled wires no handler, so this must not move: a real touch reaches nothing.
    tap("tg-lockon-pressed", expect: :none)
    tap("tg-lockoff-idle", expect: :none)

    # Ask each toggle for its own label. A page-wide "Locked on" is true from mount,
    # since the Disabled example's code sample quotes it, so it would stay true with
    # the live toggle unrendered, unlabelled or deleted from the page.
    assert labelled?("tg-lockon-pressed", "Locked on"), "the disabled toggle vanished"
    assert labelled?("tg-lockoff-idle", "Locked off"), "the disabled idle toggle vanished"

    # Locked-on and locked-off must not read the same. Colour is invisible to the
    # tree, so the tags carry it: a disabled toggle still reports whether it is
    # pressed, which is the whole reason it stays filled when greyed.
    assert state_of("tg-lockon") == "pressed", "a disabled pressed toggle lost its state"
    assert state_of("tg-lockoff") == "idle", "a disabled idle toggle gained a state"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "A toolbar",
          "It hugs its label",
          "Styled by props",
          "Disabled",
          "Props"
        ] do
      assert_text(heading)
    end

    for id <- ~w(tg-bold-pressed tg-hug-pressed tg-fill-pressed tg-lockon-pressed) do
      assert_shown(id)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
