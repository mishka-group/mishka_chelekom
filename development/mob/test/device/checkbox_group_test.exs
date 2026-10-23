defmodule MishkaMob.Device.CheckboxGroupTest do
  @moduledoc """
  Device tests for the Checkbox Group page: a port of `CheckboxGroupTest.kt`, one test
  per `@Test`, on the host-driven suite instead of Compose instrumentation.

  `the parent always agrees with its children` is the component's whole claim: the
  "select all" parent is not a special widget, it is an ordinary checkbox whose mixed
  state is DERIVED from the selection. Nothing enforces that but `parent_state/2`, and a
  screen that drifts out of sync renders a tick over a half-empty list, which reads as
  correct until you count.

  The tick and the dash are drawn on a canvas, so there is no text to assert on. Every
  row's state rides in its tag instead: `cg-langs-otp-checked`, `cg-langs-all-mixed`.
  See `MishkaMob.Components.MishkaCheckbox`.

  Run with `mix test --only device test/device/checkbox_group_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :checkbox_group

  @langs ~w(beam otp phoenix ecto)

  test "the parent always agrees with its children" do
    # An invariant, not a fixture: it holds for whatever the selection happens to be.
    assert_parent_agrees("at mount")

    # Flip one child and it must still hold. This is the half that breaks when a screen
    # updates the list without re-deriving the parent.
    before = checked_langs()
    tap_row("cg-langs-otp")
    assert_eventually(fn -> "otp" in checked_langs() != "otp" in before end)

    assert_parent_agrees("after toggling OTP")
  end

  test "the parent fills up when partial and clears only when full" do
    # select_all/2: a partial selection FILLS UP rather than clearing, because the mixed
    # state is asking to be completed. Only a full selection clears. The page mounts
    # with one language ticked.
    assert checked_langs() == ["beam"]
    assert state("cg-langs-all") == "mixed"

    tap_row("cg-langs-all")

    assert_eventually(fn -> checked_langs() == @langs end,
      message: "a partial group did not fill up"
    )

    assert state("cg-langs-all") == "checked"

    # Now it is definitely full, so the next tap must clear it.
    tap_row("cg-langs-all")
    assert_eventually(fn -> checked_langs() == [] end, message: "a full group did not clear")

    assert_eventually(fn -> state("cg-langs-all") == "empty" end,
      message: "the parent did not follow the clear"
    )
  end

  test "an item tap carries its own id" do
    before = state("cg-langs-phoenix")
    others = List.delete(checked_langs(), "phoenix")

    # One handler serves the group, so the id has to ride in the tag. If the widening
    # broke, the tap would land and silently do nothing.
    tap_row("cg-langs-phoenix")
    assert_eventually(fn -> state("cg-langs-phoenix") != before end)

    # And it must move ONLY that row: a reducer that rebuilds the list can easily drop
    # the others.
    assert List.delete(checked_langs(), "phoenix") == others,
           "toggling phoenix disturbed the other rows"

    # The summary must NAME the row the tap just moved. The lowercase id can only come
    # from the summary: the labels on this page are "Phoenix" and "Phoenix (off)".
    phoenix_checked? = state("cg-langs-phoenix") == "checked"

    assert_eventually(
      fn -> String.contains?(text_of("cg-summary"), "phoenix") == phoenix_checked? end,
      message: fn ->
        "the summary disagrees with the row: checked=#{phoenix_checked?}, summary=#{text_of("cg-summary")}"
      end
    )
  end

  test "a disabled item cannot be toggled" do
    before = state("cg-one-ecto")

    # Disabled wires no handler, so this must be inert rather than merely grey. A control
    # that looks disabled and still reports is the bug, and a real touch shows it.
    tap_row("cg-one-ecto", expect: :none)

    assert state("cg-one-ecto") == before, "a disabled item toggled"
  end

  test "a disabled group cascades to its parent too" do
    # The parent is the row most likely to escape a cascade, because it is built
    # separately from the items.
    parent_before = state("cg-off-all")
    beam_before = state("cg-off-beam")

    tap_row("cg-off-all", expect: :none)
    tap_row("cg-off-beam", expect: :none)

    assert state("cg-off-all") == parent_before, "a disabled parent toggled"
    assert state("cg-off-beam") == beam_before, "a disabled group's item toggled"
  end

  test "a group without select all renders no parent" do
    scroll_into_view("cg-notify-email-checked")

    # No parent means no parent row AND no divider: the whole block is omitted rather
    # than rendered empty.
    assert state("cg-notify-email") != nil, "the plain group did not render"
    assert state("cg-notify-all") == nil, "a group without select_all grew a parent"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Select all",
          # The card that used to be "Without a parent". It still leaves select_all off
          # (the test above proves that) and now also shows item/2 building the rows
          # from a list, next to the tags every other card writes out.
          "Rows from data",
          "Disabled",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree.
    for tag <- ~w(cg-langs-all-mixed cg-notify-email-checked cg-one-beam-checked cg-off-all-mixed) do
      assert_shown(tag)
    end

    # And the page is one long scroll that reaches its end.
    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  # "checked" | "mixed" | "empty", or nil when no such indicator exists.
  defp state(prefix), do: state(frames(), prefix)

  defp state(frames, prefix) do
    Enum.find(~w(checked mixed empty), &Map.has_key?(frames, "#{prefix}-#{&1}"))
  end

  defp checked_langs, do: checked_langs(frames())

  defp checked_langs(frames),
    do: Enum.filter(@langs, &(state(frames, "cg-langs-#{&1}") == "checked"))

  # The parent state `parent_state/2` should be showing for a given selection.
  defp expected_parent([]), do: "empty"
  defp expected_parent(checked) when length(checked) == length(@langs), do: "checked"
  defp expected_parent(_partial), do: "mixed"

  # Read from one snapshot of the frame table, so the parent and the children cannot
  # disagree because the screen moved between two reads.
  defp assert_parent_agrees(when_) do
    assert_eventually(
      fn ->
        frames = frames()
        state(frames, "cg-langs-all") == expected_parent(checked_langs(frames))
      end,
      message: fn ->
        frames = frames()

        "#{when_}, parent shows #{state(frames, "cg-langs-all")} for #{inspect(checked_langs(frames))}"
      end
    )
  end

  # A touch on the row whose indicator is tagged `<prefix>-<its current state>`.
  defp tap_row(prefix, opts \\ []) do
    tap("#{prefix}-#{state(prefix) || flunk("no row tagged #{prefix}")}", opts)
  end

  # The text of the rendered node whose :id is `tag`.
  defp text_of(tag) do
    %{props: %{text: text}} =
      find_node(render_tree(), to_string(tag)) || flunk("no node tagged #{tag}")

    text
  end

  defp find_node(%{props: props, children: children} = node, id) do
    if to_string(Map.get(props, :id, "")) == id,
      do: node,
      else: Enum.find_value(children || [], &find_node(&1, id))
  end

  defp find_node(_leaf, _id), do: nil
end
