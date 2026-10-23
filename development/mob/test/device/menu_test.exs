defmodule MishkaMob.Device.MenuTest do
  @moduledoc """
  Device tests for the Menu page: a port of `MenuTest.kt`, one test per `@Test`, on
  the host-driven suite instead of Compose instrumentation.

  A menu row says what it is with a glyph (✓, ●, ▸) and a device test cannot
  attribute a character to a row. So the component appends the state to the row's
  own tag: `<test_id>-checked` / `-unchecked` for a checkbox and radio, `-open` /
  `-closed` for a submenu. Every assertion here reads those.

  The two that matter most are `ticking a checkbox leaves the menu open` (a menu
  that dismissed on every tick would be unusable for multi-select) and `a submenu
  reveals its rows inline` (a flyout has nowhere to go on a phone).

  Run with `mix test --only device test/device/menu_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :menu

  # The menu is closed until its trigger is pressed, and closing is the screen's job.
  setup do
    unless shown?("row-edit") do
      tap("menu-trigger")
      assert_shown("row-edit")
    end

    :ok
  end

  # What a text node with this id reads, from the tree the screen rendered.
  defp text_of(tag) do
    case node_by_id(render_tree(), tag) do
      %{props: %{text: text}} -> text
      other -> flunk("#{tag} carries no text: #{inspect(other)}")
    end
  end

  defp node_by_id(%{props: props, children: children} = node, id) do
    if to_string(Map.get(props, :id, "")) == id,
      do: node,
      else: Enum.find_value(children || [], &node_by_id(&1, id))
  end

  defp node_by_id(_leaf, _id), do: nil

  test "a closed menu renders nothing at all" do
    # Close it via a command row, which is what closes the menu.
    tap("row-edit")

    refute_shown("row-edit")

    refute shown?("row-grid-checked") or shown?("row-grid-unchecked"),
           "menu rows survived while the menu was closed"
  end

  test "picking a command reports its own id" do
    tap("row-dup")

    assert_eventually(fn -> assert text_of("menu-readout") == "Picked: dup" end)
  end

  test "ticking a checkbox leaves the menu open" do
    before = shown?("row-grid-checked")

    tap(if before, do: "row-grid-checked", else: "row-grid-unchecked")

    # The tick flipped...
    assert_eventually(fn -> shown?("row-grid-checked") != before end,
      message: "the checkbox did not toggle: checked was #{before}"
    )

    # ...and the menu is still up. A menu that dismissed on every tick could never
    # be used to set more than one thing.
    assert shown?("row-edit"), "ticking a checkbox closed the menu"
  end

  test "a radio group moves its selection" do
    assert shown?("row-name-checked") or shown?("row-date-checked"),
           "neither radio is selected to begin with"

    tap(if shown?("row-date-checked"), do: "row-name-unchecked", else: "row-date-unchecked")

    # Exactly one of the pair is selected: that is what a radio group means.
    assert_eventually(fn ->
      Enum.count(["row-name-checked", "row-date-checked"], &shown?/1) == 1
    end)

    assert shown?("row-edit"), "choosing a radio closed the menu"
  end

  test "a submenu reveals its rows inline" do
    assert shown?("row-share-closed"), "the submenu did not start closed"
    refute shown?("row-copy"), "a closed submenu rendered its rows"

    tap("row-share-closed")

    # Inline, under the trigger: a flyout has nowhere to go on a phone.
    assert_shown("row-share-open")
    assert shown?("row-copy") and shown?("row-email"), "the submenu opened but revealed no rows"

    # And its rows sit to the RIGHT of the trigger: they are indented. They open
    # under the trigger, so on a short screen they start below the fold; bring them
    # up first so the frames compare like with like.
    scroll_into_view("row-email")
    trigger = frame!("row-share-open")
    nested = frame!("row-copy")

    assert nested.left > trigger.left + 8,
           "the submenu rows are not indented: trigger=#{inspect(trigger)} nested=#{inspect(nested)}"

    assert nested.top > trigger.top, "the submenu rows are not below their trigger"
  end

  test "a row inside a submenu still reports and closes" do
    tap("row-share-closed")
    tap("row-copy")

    assert_eventually(fn -> assert text_of("menu-readout") == "Picked: copy" end)
    refute_shown("row-edit")
  end

  test "a disabled row does nothing" do
    # Disabled wires no handler at all, so the touch reaches nothing: the menu
    # neither reports nor closes.
    tap("row-archive", expect: :none)

    assert shown?("row-edit"), "a disabled row closed the menu"
    assert text_of("menu-readout") == "Nothing picked yet", "a disabled row reported a selection"
  end

  test "the page renders every example and the props table" do
    for heading <- ["Every row kind", "Plain actions", "As a sheet", "Props"] do
      assert_text(heading)
    end

    assert_shown("menu-trigger")

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
