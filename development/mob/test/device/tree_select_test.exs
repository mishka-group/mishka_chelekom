defmodule MishkaMob.Device.TreeSelectTest do
  @moduledoc """
  Device tests for the Tree Select page: a port of `TreeSelectTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  Everything this component says about itself, it says in a colour and a glyph: a
  placeholder is muted where a real selection is not, and open is a ▴ where closed
  is a ▾. None of that is in the accessibility tree, and the trigger's only text is
  whatever the caller passed, so the assertions here are all on tags, with the state
  folded into the name: `ts-file-trigger-open`, `ts-team-placeholder`,
  `ts-file-panel`.

  Text queries would be answered by the wrong thing anyway. Five examples share one
  scrolling page, every example's source is drawn as an ordinary text node, and the
  snippets spell out the very labels the triggers show.

  Every test starts from a fresh `mount/1`: the page is remounted before each one,
  which is what the Kotlin suite got by leaving the page and coming back. A
  selection cannot be un-picked by tapping it again, so that reset matters here.

  Run with `mix test --only device test/device/tree_select_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :tree_select

  import MishkaMob.DeviceText

  defp open?(select), do: shown?("#{select}-trigger-open")

  # Does this select's own value read `text`? The code sample above each example
  # prints the same labels, so a page-wide query is true from the moment the page
  # mounts, even if the trigger never followed the pick. The value node has its own tag.
  defp value_shows?(select, text) do
    case text_of("#{select}-value") do
      nil -> false
      value -> String.contains?(value, text)
    end
  end

  defp open_it(select) do
    unless open?(select) do
      tap("#{select}-trigger-closed")
      assert_shown("#{select}-trigger-open")
    end
  end

  test "the panel is hidden until the trigger is tapped" do
    refute open?("ts-file"), "the page did not mount closed"

    # Closed means the panel is not rendered at all, not merely hidden: the web leaves
    # the div in place with display:none.
    refute shown?("ts-file-panel"), "the panel exists while closed"
    refute shown?("ts-file-tree-row-lib"), "the tree exists while closed"

    open_it("ts-file")

    assert shown?("ts-file-panel"), "opening rendered no panel"
    assert shown?("ts-file-tree-row-lib"), "the panel opened without its tree"
  end

  test "the caret follows the panel" do
    assert text_of("ts-file-caret") == "▾", "a closed select is not pointing down"

    open_it("ts-file")

    assert text_of("ts-file-caret") == "▴", "the caret did not flip when the panel opened"
  end

  test "picking a file fills the trigger and CLOSES" do
    open_it("ts-file")

    # `lib` starts expanded on a fresh page, so its children are on screen. Rows are
    # addressable because the tree inside the panel carries its own id: five panels
    # sharing MishkaTree's default would collide.
    assert_shown("ts-file-tree-row-lib/app.ex")
    tap("ts-file-tree-row-lib/app.ex")

    # Both halves matter: a tree select that showed the choice and left the panel
    # hanging open over the rest of the page would not be a select.
    refute_shown("ts-file-trigger-open")
    assert_shown("ts-file-trigger-closed")
    assert value_shows?("ts-file", "lib/app.ex"), "the trigger did not show the new choice"
    refute shown?("ts-file-placeholder"), "the trigger kept its placeholder tag"
  end

  test "expanding a branch is not a choice" do
    open_it("ts-file")

    tap("ts-file-tree-toggle-lib")

    # The tree owns expansion; only a selection closes the panel. Collapsing a branch
    # inside an open panel must leave the panel where it is.
    assert open?("ts-file"), "expanding a branch closed the panel"
    assert_shown("ts-file-tree-lib-closed")
    refute_shown("ts-file-tree-row-lib/app.ex", message: "the collapsed branch kept its rows")
  end

  test "the placeholder gives way to the chosen label" do
    # data-placeholder on the web; a muted ink here, which is why it is in the tag.
    assert shown?("ts-team-placeholder"), "an empty select lost its placeholder"
    refute shown?("ts-team-value"), "an empty select claims to hold a value"

    open_it("ts-team")
    tap("ts-team-tree-row-ana")

    assert_shown("ts-team-value")
    refute shown?("ts-team-placeholder"), "the placeholder outlived the choice"

    # The tree reports the node's VALUE ("ana"); the screen maps it to the label, and
    # the trigger is where you can tell which one arrived.
    assert value_shows?("ts-team", "Ana"), "the trigger shows the value, not the label"
  end

  test "a disabled select cannot open" do
    assert shown?("ts-off-trigger-disabled"), "the disabled trigger is not marked as one"

    # The screen's :ts_off_toggle clause is live, so what fails to happen here is the
    # component dropping the handler, not a missing one: a real touch reaches nothing.
    tap("ts-off-trigger-disabled", expect: :none)

    refute shown?("ts-off-trigger-open"), "a disabled tree select opened"
    refute shown?("ts-off-panel"), "a disabled tree select rendered its panel"
  end

  test "open renders the panel expanded with no handler at all" do
    assert shown?("ts-pinned-panel"), "open={true} did not render the panel"
    assert open?("ts-pinned"), "the pinned trigger does not report itself open"

    # Nothing dismisses a panel but the caller: with no on_toggle there is no state to
    # change, so this one stays open, and the trigger has no handler to deliver to.
    tap("ts-pinned-trigger-open", expect: :none)

    assert shown?("ts-pinned-panel"), "a select with no on_toggle closed itself"
  end

  test "a long selection stays on one line and leaves the caret its place" do
    # Frames are unclipped, so unlike the Kotlin suite nothing has to be measured while
    # it is on screen.
    short = frame!("ts-off-value")
    value = frame!("ts-long-value")
    caret = frame!("ts-long-caret")
    root = frame!("ts-long")

    # Compose measures a Row's UNWEIGHTED children first, so before the value was
    # wrapped in a weighted Box a 47-character path took the whole row and the caret
    # was measured at zero width, off the end of it.
    assert caret.left >= value.right, "the value overran the caret"
    assert caret.right <= root.right + 1, "the caret was pushed outside the component"

    # And it is ONE line: a Text squeezed narrower than its content wraps character by
    # character, which would make this several times taller than the short label one
    # example down.
    assert value.height <= short.height * 1.6,
           "the long label wrapped (#{value.height}) rather than ellipsising (#{short.height})"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Trigger and panel",
          "Placeholder",
          "Open from the start",
          "A long selection",
          "Disabled",
          "Props"
        ] do
      assert_text(heading)
    end

    for id <- ~w(ts-file ts-team ts-pinned ts-long ts-off), do: assert_shown(id)

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
