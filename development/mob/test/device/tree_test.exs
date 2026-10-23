defmodule MishkaMob.Device.TreeTest do
  @moduledoc """
  Device tests for the Tree page: a port of `TreeTest.kt`, one test per `@Test`, on
  the host-driven suite instead of Compose instrumentation.

  ## Everything this component knows, it says in a colour or a glyph

  A checkbox is a drawn mark, an arrow is "▾" or "▸" on every row alike, and a
  selection is a tint and a font weight. None of the three is in the accessibility
  tree, so **every assertion here is on a tag**: the tree gives each part an `:id`,
  which Mob turns into a native tag, and folds the state into the tags that describe
  one: `<id>-<value>-open`, `-selected`, `-checked`, `-loading`.

  Tags rather than text for a second reason too. Every example on this page renders
  into one scrolling column, and the code samples beneath them are text nodes as
  well, so a page-wide text query is answered by whichever example happens to
  contain the string, which is rarely the one under test.

  The device frame table is keyed by tag, so every example carries its own `id`
  (`tree`, `cascade`, `multi`, `async`, `strict`). The Kotlin suite shared the
  default `tree` between the first two examples and told them apart by index, which
  a frame table cannot do: the checkbox example is `cascade` now.

  Run with `mix test --only device test/device/tree_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :tree

  # The caption under the checkbox example, rendered from the same assign.
  @caption "Checked: "

  defp caption, do: text_of("cascade-summary") || flunk("no \"#{@caption}...\" caption on screen")

  test "the checkbox example renders its caption" do
    assert_shown("cascade-summary")
    assert String.starts_with?(caption(), @caption), "caption reads #{caption()}"
  end

  test "tapping a node checkbox reaches the screen" do
    before = caption()

    # An ENABLED leaf. mix.exs is disabled: true in the demo data, so its checkbox is
    # deliberately inert and would prove nothing.
    tap("cascade-check-lib/mishka_mob.ex")

    assert_eventually(fn -> caption() != before end)

    assert caption() =~ "mishka_mob.ex",
           "the caption reads [#{caption()}], the tap did not name the node it hit"
  end

  test "the disclosure arrow still works" do
    # A handler this change never touched, on the same page and the same tree. If this
    # fails too, taps on this page are broken independently of the checkbox; if it
    # passes, the checkbox is the odd one out. Collapsing "lib" must take its children
    # off the screen with it.
    child = "cascade-check-lib/mishka_mob.ex"
    assert_shown(child)

    # By tag, not by glyph: every arrow on the page reads "▾".
    tap("cascade-toggle-lib")

    refute_shown(child)
  end

  test "the disabled node sends nothing" do
    before = caption()

    # Disabled wires no handler on the checkbox: the touch lands on nothing.
    tap("cascade-check-mix.exs", expect: :none)

    assert caption() == before, "a disabled node changed the checked set"
  end

  test "holding a row selects the range" do
    # Shift+click has no finger. A long press is what the range moved onto, and this is
    # the only thing that proves the gesture arrives at all: the selection it produces
    # is otherwise indistinguishable from four separate taps.
    tap("multi-clear")
    tap("multi-row-ada")
    assert_shown("multi-ada-selected")

    hold("multi-row-fen")

    assert_shown("multi-fen-selected")

    assert shown?("multi-bo-selected") and shown?("multi-dee-selected"),
           "the hold selected its own row but not the run leading up to it"

    # DESIGN and ENGINEERING are selectable: false and Eve is disabled. All three sit
    # inside the run and none of them may join it.
    assert shown?("multi-eng-idle"), "a header joined the range"
    assert shown?("multi-eve-idle"), "a disabled row joined the range"
  end

  test "a tap adds rather than replacing" do
    tap("multi-clear")
    tap("multi-row-ada")
    tap("multi-row-cy")

    assert_shown("multi-cy-selected")

    assert shown?("multi-ada-selected"),
           "the second tap replaced the first, multiple: true was not applied"
  end

  test "a header row cannot be selected" do
    tap("multi-clear")

    # No handler at all is wired on this row, so the touch lands on nothing. That is the
    # assertion: a category heading is not a destination.
    tap("multi-row-design", expect: :none)

    assert shown?("multi-design-idle"), "a selectable: false header was selected"
    assert shown?("multi-ada-idle"), "tapping the header selected its children"
  end

  test "the arrow tag says which way it points" do
    # The glyph is "▸" or "▾", or in this example "+" and "−", and none of them is
    # readable from a device test. The state is in the tag on the arrow rather than on
    # the Box around it, because a target renamed by the act of using it can only be
    # used once.
    assert_shown("strict-lib-open")

    tap("strict-toggle-lib")

    assert_shown("strict-lib-closed")

    refute_shown("strict-row-lib/mishka_mob.ex",
      message: "the arrow flipped but the branch's children stayed on screen"
    )

    tap("strict-toggle-lib")
    assert_shown("strict-lib-open")
  end

  test "an unfetched branch reports a load before it opens" do
    # has_children: true with no children. The first tap is a request, not a state
    # change, so the row goes busy and stays shut until the screen answers, which is the
    # whole reason on_load_children is its own event.
    tap("async-reset")
    assert_shown("async-assets-closed")

    tap("async-row-assets")

    assert_shown("async-assets-loading")
    assert shown?("async-assets-closed"), "the branch opened before its children had arrived"

    assert_shown("async-row-assets/logo.png")
    assert_shown("async-assets-open", message: "the children arrived but the branch never opened")
  end

  test "a strict check does not cascade" do
    # Fresh page: the branch is open and its parent unchecked.
    assert_shown("strict-lib-open")
    assert_shown("strict-lib-empty")

    tap("strict-check-lib")

    assert_shown("strict-lib-checked")
    assert shown?("strict-lib/mishka_mob.ex-empty"), "check_strictly cascaded to a descendant"
  end

  test "the page renders every example" do
    for heading <- [
          "Expand and select",
          "Checkboxes cascade",
          "Multiple, and hold for a range",
          "Headers, and children on demand",
          "Strict checks, everything open",
          "Tree select",
          "Props"
        ] do
      assert_text(heading)
    end

    for id <- ~w(tree-row-lib cascade-row-lib multi-row-ada async-row-project strict-row-lib) do
      assert_shown(id)
    end
  end
end
