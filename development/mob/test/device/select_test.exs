defmodule MishkaMob.Device.SelectTest do
  @moduledoc """
  Device tests for the Select page: a port of `SelectTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  The two behaviours that separate a select from a menu are both about what happens
  AFTER a pick: single mode replaces the value and closes the list, multiple
  accumulates and stays open. `toggle/3` returns `{value, close?}` for exactly that
  reason, and a screen that ignores the second element gets a multi-select that
  slams shut after every tap.

  A chosen option is marked with a ✓, and a glyph cannot be attributed to one row
  among several, so state rides in the tags: `sel-pizza-option-onion-selected`.

  Run with `mix test --only device test/device/select_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :select

  # Every example starts closed (the page remounts), which is the shape the Kotlin
  # suite had to restore by hand before each test.

  defp open?(select), do: shown?("#{select}-trigger-open")
  defp picked?(select, option), do: shown?("#{select}-option-#{option}-selected")

  defp open_it(select) do
    unless open?(select) do
      tap("#{select}-trigger-closed")
      assert_shown("#{select}-trigger-open")
    end
  end

  # Does this select's own TRIGGER read `text`?
  #
  # A page-wide search cannot answer that. The page carries two other renderers of
  # the same words: every example's source is drawn as an ordinary text node (the
  # "Single choice" snippet spells out `option(:ir, "Iran")`), and an open list
  # draws each option's label. So a page-global query for a label is true whether
  # the trigger followed the pick or stayed on its placeholder.
  #
  # The trigger folds open/closed into its own tag, hence the lookup.
  defp trigger_shows?(select, text) do
    tag = "#{select}-trigger-" <> if(open?(select), do: "open", else: "closed")

    case node_by_id(render_tree(), tag) do
      nil -> false
      trigger -> tree_has_text?(trigger, text)
    end
  end

  defp node_by_id(%{props: props, children: children} = node, id) do
    if to_string(Map.get(props, :id, "")) == id,
      do: node,
      else: Enum.find_value(children || [], &node_by_id(&1, id))
  end

  defp node_by_id(_leaf, _id), do: nil

  test "the list is hidden until the trigger is tapped" do
    scroll_into_view("sel-country-trigger-closed")

    # Closed means the options are not merely hidden: they are not rendered.
    refute_shown("sel-country-option-uk-idle")
    refute_shown("sel-country-option-uk-selected")

    open_it("sel-country")

    assert shown?("sel-country-option-uk-idle") or shown?("sel-country-option-uk-selected"),
           "opening did not render the options"
  end

  test "single mode replaces the value and CLOSES" do
    open_it("sel-country")

    tap("sel-country-option-ir-idle")

    # Both halves matter. toggle/3 returns {value, close?} precisely so the screen
    # can do this, and a screen that drops close? leaves the list hanging open over
    # the rest of the page.
    assert_shown("sel-country-trigger-closed")
    refute open?("sel-country")

    # Both of these are about the trigger, so both ask the trigger. A page-wide
    # search for "Iran" was already true at mount off the code sample above the
    # select, and would have passed on a trigger still reading "Choose a
    # country..." or on a display/3 that returned nothing.
    assert trigger_shows?("sel-country", "Iran"), "the trigger did not show the new choice"

    refute trigger_shows?("sel-country", "Choose a country"),
           "the trigger kept its placeholder after a choice"

    open_it("sel-country")
    assert picked?("sel-country", "ir"), "the chosen option is not ticked"
    refute picked?("sel-country", "uk"), "single mode kept a second choice"

    # And picking another REPLACES rather than accumulating.
    tap("sel-country-option-de-idle")
    assert_shown("sel-country-trigger-closed")
    open_it("sel-country")

    assert picked?("sel-country", "de"), "the new choice is not ticked"
    refute picked?("sel-country", "ir"), "single mode accumulated two values"
  end

  test "multiple mode accumulates and STAYS OPEN" do
    open_it("sel-pizza")

    before = picked?("sel-pizza", "onion")

    tap(
      if before,
        do: "sel-pizza-option-onion-selected",
        else: "sel-pizza-option-onion-idle"
    )

    assert_eventually(fn -> picked?("sel-pizza", "onion") != before end)

    # The whole point: a multi-select that closed after every pick would be
    # exhausting, so the list must still be open.
    assert open?("sel-pizza"), "the list closed after a pick in multiple mode"

    # And the other choice is untouched: picking adds rather than replaces.
    assert picked?("sel-pizza", "pepperoni"), "picking onion cleared pepperoni"
  end

  test "groups put a heading above each run" do
    open_it("sel-pizza")

    assert_shown("sel-pizza-group-CLASSIC")
    assert_shown("sel-pizza-group-VEGGIE")

    # A heading belongs to the run BELOW it: Cheese and Pepperoni sit under
    # CLASSIC, Mushroom and Onion under VEGGIE. Order is the grouping.
    pepperoni_tag =
      if picked?("sel-pizza", "pepperoni"),
        do: "sel-pizza-option-pepperoni-selected",
        else: "sel-pizza-option-pepperoni-idle"

    # Bring the last of them on screen first, so every frame is read at one scroll.
    scroll_into_view("sel-pizza-option-onion-idle")

    classic = frame!("sel-pizza-group-CLASSIC")
    veggie = frame!("sel-pizza-group-VEGGIE")
    pepperoni = frame!(pepperoni_tag)

    assert pepperoni.top > classic.top, "Pepperoni is not under CLASSIC"
    assert pepperoni.top < veggie.top, "Pepperoni fell under VEGGIE"
    assert frame!("sel-pizza-option-onion-idle").top > veggie.top, "Onion is not under VEGGIE"
  end

  test "the trigger shows the placeholder when nothing is chosen" do
    open_it("sel-lang")

    # The page mounts with nothing chosen.
    for lang <- ["elixir", "erlang", "gleam"], do: refute(picked?("sel-lang", lang))

    assert trigger_shows?("sel-lang", "Choose any"), "an empty multi-select lost its placeholder"

    # And a choice replaces the placeholder with the label. Multiple mode leaves the
    # list OPEN, so the "Elixir" option row is on screen while this runs and
    # answered a page-wide query by itself: the line held even if the trigger never
    # followed the pick, which is the only thing left for it to prove once the wait
    # below has checked the tick.
    tap("sel-lang-option-elixir-idle")
    assert_eventually(fn -> picked?("sel-lang", "elixir") end)

    assert trigger_shows?("sel-lang", "Elixir"), "the trigger did not show the chosen label"

    refute trigger_shows?("sel-lang", "Choose any"),
           "the trigger kept its placeholder after a choice"
  end

  test "a disabled select cannot open" do
    scroll_into_view("sel-off-trigger-closed")

    # Disabled wires no handler, so a real touch reaches nothing.
    tap("sel-off-trigger-closed", expect: :none)

    refute_shown("sel-off-trigger-open")
    assert_shown("sel-off-trigger-closed")
  end

  test "the page renders every example and the props table" do
    for heading <- ["Single choice", "Multiple", "Grouped", "Disabled", "Props"] do
      assert_text(heading)
    end

    for select <- ~w(sel-country sel-lang sel-pizza sel-off) do
      assert_shown("#{select}-trigger-closed")
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
