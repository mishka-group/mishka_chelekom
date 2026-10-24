defmodule MishkaMob.Device.AutocompleteTest do
  @moduledoc """
  Device tests for the Autocomplete page: a port of `AutocompleteTest.kt`, one test
  per `@Test`, on the host-driven suite instead of Compose instrumentation.

  An autocomplete differs from a combobox in one respect, and it is the one worth
  driving: the QUERY is the value. Choosing a suggestion fills the field in rather
  than selecting an id, and the panel then has nothing left to say.
  `choosing fills the field and closes` and `an exactly typed suggestion leaves no
  dead panel` are the two halves of that. The second guards a bug this page used to
  have: the whole option list was blanked once the query matched exactly, so the
  still-open panel showed "No suggestions", which is false, and nothing could
  dismiss it.

  Keystrokes are real key events into the focused field, so a test taps the field
  first, and replacing text is backspaces and then typing (there is no select-all).
  What a field SHOWS is read from the render tree: the `value` the screen handed
  it, which is the half a screen can get wrong.

  Run with `mix test --only device test/device/autocomplete_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :autocomplete

  # Is `city` offered by the `box` autocomplete right now?
  defp offered?(box, city),
    do: shown?("#{box}-option-#{city}-idle") or shown?("#{box}-option-#{city}-selected")

  # Tap the caption inside the first card. The card's container carries the
  # on_tap that closes the panel, and a child's own handler consumes taps on the
  # control and its options, so the caption is the one thing guaranteed to be
  # inside the card and outside the control.
  defp close_card, do: tap("ac-caption")

  test "the panel is closed until the field is tapped" do
    # It used to be pinned open={true}, standing permanently expanded with
    # every city listed before the user touched anything.
    refute offered?("ac-city", "Tehran")

    # Park focus on the OTHER field first, and close its card: the first field's
    # panel must not open for a tap that was never on it.
    tap("ac-any-input")
    close_card()

    refute offered?("ac-city", "Tehran"), "the panel opened without a tap"

    tap("ac-city-input")

    assert_eventually(fn -> offered?("ac-city", "Tehran") end,
      message: "tapping the field did not open the panel"
    )
  end

  test "typing filters by PREFIX by default" do
    tap("ac-city-input")
    type("te")

    # :starts_with is the default, which is what "autocomplete" means. A
    # combobox defaults to :contains.
    assert_eventually(fn -> offered?("ac-city", "Tehran") end)

    # The mid-word check used to name "Istanbul", which is not one of the six
    # cities this page offers, so no option tag for it can ever exist and the
    # negation held for every query and every mode. "te" cannot discriminate
    # either: Tehran is the only city containing it, and it contains it at the
    # front, so :contains and :starts_with return the same list. "on" is the real
    # discriminator: mid-word in Toronto, final in Lisbon, initial in neither, so
    # :contains would offer both and the prefix default offers nothing at all.
    delete_backward(2)
    type("on")

    assert_shown("ac-city-empty")
    refute offered?("ac-city", "Toronto"), "prefix mode matched mid-word"
    refute offered?("ac-city", "Lisbon"), "prefix mode matched a suffix"
  end

  test "choosing fills the field and closes" do
    tap("ac-city-input")
    type("te")
    assert_eventually(fn -> offered?("ac-city", "Tehran") end)

    tap("ac-city-option-Tehran-idle")

    # The query IS the value: the suggestion's TEXT lands in the field.
    refute_shown("ac-city-option-Tehran-idle")
    refute offered?("ac-city", "Tehran")

    # Read the FIELD, not the page. "Tehran" is on this screen twice over without
    # the field ever changing: the caption below prints Value: "Tehran" off the
    # same assign. A page-wide search for the word therefore passed even for the
    # bug this component's moduledoc warns about: the assign updated, the field
    # left blank.
    assert_eventually(fn -> assert value_of("ac-city-input") == "Tehran" end,
      message: "the chosen suggestion did not fill the field"
    )
  end

  test "an exactly typed suggestion leaves no dead panel" do
    tap("ac-city-input")
    type("Tehran")

    # Typing reached the screen, and the screen asked for the panel to be open...
    assert_eventually(fn -> assigns().ac_query == "Tehran" end)
    assert assigns().ac_open

    # ...yet the panel used to blank its whole option list here and then draw
    # "No suggestions", which is false, and which nothing could dismiss because
    # there was no trigger, no focus wiring and no backdrop.
    refute_shown("ac-city-empty")
    refute offered?("ac-city", "Tehran")
    refute offered?("ac-city", "Toronto")
  end

  test "a query nothing matches still says so" do
    tap("ac-city-input")
    type("zzzzz")

    # The empty panel is information HERE, the distinction the fix turns on.
    assert_shown("ac-city-empty")
  end

  test "tapping outside closes the panel" do
    tap("ac-city-input")
    type("te")
    assert_eventually(fn -> offered?("ac-city", "Tehran") end)

    # The caption, NOT the example's title: the title is rendered by the screen
    # OUTSIDE the container that carries the backdrop, so tapping it is not
    # "inside the card" at all.
    close_card()

    refute_shown("ac-city-option-Tehran-idle")
    refute offered?("ac-city", "Tehran")
  end

  test "the two examples no longer move in lockstep" do
    tap("ac-city-input")
    type("te")
    assert_eventually(fn -> value_of("ac-city-input") == "te" end)

    # They shared one assign, so typing in either rewrote the other's field.
    other = value_of("ac-any-input")

    refute other == "te", "the second field mirrored the first: #{inspect(other)}"
  end

  test "the pills picker adds on tap and removes on a second tap" do
    tap("ac-pills-draft")
    assert_shown("ac-pick-Grace Hopper-idle")

    # Tapping a name adds it as a pill.
    tap("ac-pick-Grace Hopper-idle")
    assert_shown("ac-pick-Grace Hopper-selected")

    # Tapping the SAME name again removes it. One clause does both, which is also
    # what makes a duplicate impossible rather than a rule enforced separately on
    # each path and forgotten on one of them.
    tap("ac-pick-Grace Hopper-selected")
    assert_shown("ac-pick-Grace Hopper-idle")
  end

  test "the same person cannot be added twice" do
    tap("ac-pills-draft")
    assert_shown("ac-pick-Alan Turing-idle")

    tap("ac-pick-Alan Turing-idle")
    assert_shown("ac-pick-Alan Turing-selected")

    # One pill, not two: count what the screen draws with that exact label (the
    # pill, and the row in the picker).
    pills = text_count("Alan Turing")

    tap("ac-pick-Alan Turing-selected")
    assert_shown("ac-pick-Alan Turing-idle")

    tap("ac-pick-Alan Turing-idle")
    assert_shown("ac-pick-Alan Turing-selected")

    assert text_count("Alan Turing") == pills,
           "adding the same person again produced a second pill"

    assert Enum.count(assigns().ac_recipients, &(&1 == "Alan Turing")) == 1
  end

  test "typing filters the pills picker" do
    tap("ac-pills-draft")
    assert_shown("ac-pick-Ada Lovelace-selected")

    type("gra")

    assert_shown("ac-pick-Grace Hopper-idle")
    refute_shown("ac-pick-Alan Turing-idle")

    delete_backward(3)
    assert_shown("ac-pick-Alan Turing-idle")
  end

  test "the page renders every example and the props table" do
    for heading <- ["Suggest as you type", "Contains matching", "Pills input", "Props"] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree.
    assert_shown("ac-city-input")
    assert_shown("ac-any-input")
    assert_shown("ac-pills-draft")

    # And the page is one long scroll that reaches its end.
    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
