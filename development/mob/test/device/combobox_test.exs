defmodule MishkaMob.Device.ComboboxTest do
  @moduledoc """
  Device tests for the Combobox page: a port of `ComboboxTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  Filtering is a pure function with its own unit tests; what a device adds is
  everything around it: that typing actually reaches the filter, that a chip shows
  the selection while the list is open, and that the create row appears for a
  query no option matches. `typing filters the list` is the whole chain:
  keystroke, on_query, handle_change, filter/3, re-render. A break anywhere in it
  looks identical from the outside, and every link but the last is invisible to a
  unit test.

  Keystrokes are real key events into the focused field, so a test taps the field
  first, and replacing text is backspaces and then typing (there is no select-all).
  What a field SHOWS is read from the render tree: the `value` the screen handed it.

  Run with `mix test --only device test/device/combobox_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :combobox

  @countries ~w(ir uk de jp br se tr)

  # cb-one's own empty text, which nothing else on the page renders. The empty
  # state used to be checked with "No matches", which is the fourth example's
  # TITLE and the props table's printed default for `empty_text`, both on screen
  # from mount, so a panel that collapsed to nothing instead of saying so passed.
  @empty_text "No country by that name."

  # The BEAM keeps no state between tests here (every test remounts the page), but
  # the examples now start CLOSED, like the web, rather than hardcoding open={true}.
  # Open each list through its own ▾, the way a user would.
  setup do
    open_list("cb-one", "ir")
    open_list("cb-food", "apple")
    :ok
  end

  defp open_list(box, probe) do
    unless listed?(box, probe) do
      tap("#{box}-on_toggle")
      assert_eventually(fn -> listed?(box, probe) end, message: "#{box} did not open")
    end
  end

  defp picked?(box, option), do: shown?("#{box}-option-#{option}-selected")
  defp listed?(box, option), do: picked?(box, option) or shown?("#{box}-option-#{option}-idle")

  # Which of `ids` the `box` list offers, from one read of the frame table.
  defp options_of(box, ids) do
    laid_out = laid_out_tags()

    Enum.filter(ids, fn id ->
      MapSet.member?(laid_out, "#{box}-option-#{id}-idle") or
        MapSet.member?(laid_out, "#{box}-option-#{id}-selected")
    end)
  end

  defp laid_out_tags do
    for {tag, {_x, _y, width, height}} <- frames(),
        width > 0,
        height > 0,
        into: MapSet.new(),
        do: tag
  end

  # What the screen told the field to show.
  defp field_value(tag) do
    case node_by_id(render_tree(), tag) do
      %{props: %{value: value}} -> value
      other -> flunk("#{tag} carries no value: #{inspect(other)}")
    end
  end

  defp node_by_id(%{props: props, children: children} = node, id) do
    if to_string(Map.get(props, :id, "")) == id,
      do: node,
      else: Enum.find_value(children || [], &node_by_id(&1, id))
  end

  defp node_by_id(_leaf, _id), do: nil

  # A tap on a text field raises the keyboard, which resizes the page over the next
  # ~400ms and scrolls it to keep the caret in view. A tap that has to scroll to its
  # target, or lands, while that is in flight is lost, so wait for the page to stop
  # moving before doing anything else. (The harness's own retry would paper over it,
  # and `stats/0` would count it.)
  defp tap_field(tag) do
    tap(tag)
    settled_frame("page")
  end

  # A chip is removed by its ✕, which is the chip's trailing glyph and not its
  # centre: tap where a finger would, at the chip's trailing edge inside its padding.
  defp tap_chip_remove(chip) do
    frame = scroll_into_view(chip)
    tap_xy(frame.right - 14, frame.top + frame.height / 2)
  end

  test "typing filters the list" do
    assert listed?("cb-one", "de"), "Germany is missing before filtering"

    tap_field("cb-one-input")
    type("ira")

    assert_eventually(fn -> options_of("cb-one", @countries) == ["ir"] end,
      message: fn -> ~s("ira" filtered to #{inspect(options_of("cb-one", @countries))}) end
    )

    # Accents folded BOTH ways: an unaccented query finds an accented label, which
    # is what a phone keyboard actually produces.
    delete_backward(3)
    type("turkiye")

    assert_eventually(fn -> options_of("cb-one", @countries) == ["tr"] end,
      message: fn -> ~s("turkiye" filtered to #{inspect(options_of("cb-one", @countries))}) end
    )
  end

  test "no matches says so rather than collapsing" do
    # The row has to APPEAR, so prove it is absent while the list is full,
    # otherwise a permanently-rendered row would satisfy the wait below.
    refute_shown("cb-one-empty")

    tap_field("cb-one-input")
    type("zzzzz")

    assert_shown("cb-one-empty")
    assert_text(@empty_text)
    refute listed?("cb-one", "ir"), "an option survived a query nothing matches"
  end

  test "the clear button empties the query" do
    tap_field("cb-one-input")
    type("zzzzz")

    # Gate on something only the typing can produce. Waiting for a string the page
    # renders anyway established nothing, so the ✕ was tapped with the full list
    # still up, and "the options came back" below was true because they had never
    # left. Both option tags and the empty row have to agree that the query
    # reached the filter.
    assert_shown("cb-one-empty")
    assert options_of("cb-one", @countries) == []

    tap("cb-one-on_clear")

    # Clearing restores the full list, which is the observable half.
    assert_eventually(fn -> listed?("cb-one", "ir") and listed?("cb-one", "de") end)
    refute_shown("cb-one-empty")

    # And empties the FIELD, which is what the button is named for: the restored
    # list only proves the query the filter saw is now blank, not that the text the
    # user typed is gone from the box.
    assert_eventually(fn -> assert field_value("cb-one-input") == "" end,
      message: "the ✕ left the query in the field"
    )
  end

  test "the trigger opens and closes the list" do
    # The setup opened it through this same button, so getting here at all is half
    # the assertion.
    assert listed?("cb-one", "ir"), "the list is not open"

    tap("cb-one-on_toggle")
    refute_shown("cb-one-option-ir-idle")
    refute listed?("cb-one", "ir")

    tap("cb-one-on_toggle")
    assert_eventually(fn -> listed?("cb-one", "ir") end)
  end

  test "a chosen option becomes a removable chip" do
    scroll_into_view("cb-food-input")

    # A chip is the only thing showing the selection while the list is open;
    # without it a multi-select is a guessing game.
    assert_shown("cb-food-chip-apple")
    assert picked?("cb-food", "apple"), "the chosen option is not ticked"

    tap_chip_remove("cb-food-chip-apple")
    refute_shown("cb-food-chip-apple")
    refute picked?("cb-food", "apple"), "removing the chip left the option ticked"

    # And picking it again brings the chip back.
    tap("cb-food-option-apple-idle")
    assert_shown("cb-food-chip-apple")
  end

  test "groups and disabled options survive filtering" do
    scroll_into_view("cb-food-input")

    assert_shown("cb-food-group-FRUIT")
    assert_shown("cb-food-group-VEGETABLE")

    # Options used to be flattened to {id, label}, which threw both `group` and
    # `disabled` away.
    assert listed?("cb-food", "durian"), "the disabled option did not render"

    # A disabled row wires no handler, so the touch falls through to the card
    # around it, whose on_tap closes the list. The pick itself must not happen.
    tap("cb-food-option-durian-idle")
    refute :durian in assigns().cb_food, "a disabled option was selectable"
    refute picked?("cb-food", "durian"), "a disabled option was selectable"

    # Filtering keeps the heading of whatever survives, and drops the rest.
    tap_field("cb-food-input")
    type("carrot")
    assert_eventually(fn -> not listed?("cb-food", "apple") end)

    assert_shown("cb-food-group-VEGETABLE")
    refute_shown("cb-food-group-FRUIT")
  end

  test "creatable offers a row for an unmatched query" do
    scroll_into_view("cb-food-input")

    refute_shown("cb-food-option-create-idle")

    tap_field("cb-food-input")
    type("Pear")

    assert_shown("cb-food-option-create-idle")
    assert_text(~s(Create "Pear"))

    tap("cb-food-option-create-idle")
    assert_shown("cb-food-chip-pear")

    # The created option joins the list under its own heading, and the query is
    # cleared so the next one starts fresh.
    assert_shown("cb-food-group-CREATED")
  end

  test "an exact match suppresses the create row" do
    scroll_into_view("cb-food-input")

    # A PARTIAL match still offers to create (the web offers "Ban" while "Banana"
    # is listed), but an exact one must not.
    tap_field("cb-food-input")
    type("Ban")

    assert_shown("cb-food-option-create-idle")
    assert_text(~s(Create "Ban"))

    type("ana")

    refute_shown("cb-food-option-create-idle")
    assert listed?("cb-food", "banana"), "the exact match vanished"
  end

  test "tapping the field opens the list" do
    # Close it first: the setup opens it, and "already open" proves nothing.
    tap("cb-one-on_toggle")
    refute_shown("cb-one-option-ir-idle")
    refute listed?("cb-one", "ir")

    # A tap into the field focuses it, and a tap is what opens the list. Without
    # this a user has to find the ▾ before they can search.
    tap_field("cb-one-input")

    assert_eventually(fn -> listed?("cb-one", "ir") end,
      message: "tapping the field did not open the list"
    )
  end

  test "typing opens the list too" do
    # Focus the field, then shut the list through the ▾: the caret stays where it
    # was, so the next keystroke is typed by someone with the list closed.
    tap_field("cb-one-input")
    tap("cb-one-on_toggle")
    refute_shown("cb-one-option-ir-idle")
    refute listed?("cb-one", "ir")

    # Someone who taps and starts typing before the list appears must not have to
    # tap again.
    type("ira")

    assert_eventually(fn -> listed?("cb-one", "ir") end,
      message: "typing did not open the list"
    )
  end

  test "tapping outside the control closes the list" do
    assert listed?("cb-one", "ir"), "the list is not open"

    # The caption below the control is part of the card, not the combobox. The
    # list renders in flow rather than in an overlay, so nothing covers the page to
    # catch this: the screen puts an on_tap on the container, and a child's own
    # handler consumes taps on the control and its options. The caption's own node
    # is the only thing guaranteed to be outside the control.
    tap("cb-caption")

    refute_shown("cb-one-option-ir-idle")
    refute listed?("cb-one", "ir")
  end

  test "picking an option does not close a multiple list" do
    open_list("cb-food", "banana")

    # The backdrop must not swallow taps meant for the list, and blur must not
    # close it: a multi-select that shut on every pick would be exhausting, and
    # both mistakes look identical from here.
    before = picked?("cb-food", "banana")
    tap(if before, do: "cb-food-option-banana-selected", else: "cb-food-option-banana-idle")

    assert_eventually(fn -> picked?("cb-food", "banana") != before end)
    assert listed?("cb-food", "apple"), "picking closed a multiple list"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Filter and choose",
          "Multiple",
          "Grouped, creatable",
          "No matches",
          "starts_with",
          "Props"
        ] do
      assert_text(heading)
    end

    # The interactive examples are laid out, not just described by the tree.
    for box <- ~w(cb-one cb-multi cb-food), do: assert_shown("#{box}-input")

    # And the page is one long scroll that reaches its end.
    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
