defmodule MishkaMob.Device.PillTest do
  @moduledoc """
  Device tests for the Pill and its showcase page: a port of `PillTest.kt`, one
  test per `@Test`, on the host-driven suite instead of Compose instrumentation.

  The pill bug that prompted it was invisible to the whole Elixir suite, and had to
  be: `MobBridge` never read `fill_width` for a Box, so a Box could only be told to
  stop filling by pinning an exact width, which a pill, being as wide as its text,
  cannot do. Every pill therefore filled its row and the "Inside inputs" example
  showed one token per line. The node tree was correct throughout, so
  `pills wrap three to a row` is the assertion that would have failed, and it can
  only be made against real layout.

  Pills are addressed by tag. `MishkaPill` puts its `id` on the pill and
  `<id>-remove` on its ✕, so "the ✕ that dismisses Item 3" is `tok-item_3-remove`
  rather than a search for the nearest ✕ to a label's right.

  Run with `mix test --only device test/device/pill_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :pill

  @tokens 10

  test "pills wrap three to a row" do
    # THE regression. With fill_width ignored each pill took the whole row, so
    # Item 0 and Item 1 sat on different lines. Their y-centres are the entire
    # assertion, and no node-tree test can make it.
    scroll_into_view("tok-item_3")

    [zero, one, two, three] = for n <- 0..3, do: frame!("tok-item_#{n}")

    assert same_row?(zero, one), "Item 0 and Item 1 are on different rows"
    assert same_row?(zero, two), "Item 0 and Item 2 are on different rows"
    assert one.left > zero.right, "Item 1 is not to the right of Item 0"

    # ...and the chunk is three, so the fourth starts a new row BELOW.
    refute same_row?(zero, three), "Item 3 did not wrap onto a new row"
    assert three.top > zero.top, "Item 3 is above the row it should follow"
  end

  test "a pill hugs its label rather than filling the width" do
    short = scroll_into_view("tok-item_0")
    page = frame!("page")

    assert short.width < page.width / 2,
           "a pill spans #{short.width} of #{page.width}: it is filling, not hugging"
  end

  test "tapping a remove button drops exactly that token" do
    before = token_count()
    assert before == @tokens

    tap("tok-item_3-remove")

    refute_shown("tok-item_3")
    assert token_count() == before - 1, "expected #{before - 1} tokens, got #{token_count()}"
    assert shown?("tok-item_2") and shown?("tok-item_4"), "a neighbouring token went with it"
  end

  test "reset brings every token back" do
    tap("tok-item_0-remove")
    refute_shown("tok-item_0")

    tap("pill-reset")

    assert_shown("tok-item_0")

    assert token_count() == @tokens,
           "expected #{@tokens} tokens after reset, got #{token_count()}"
  end

  test "emptying the tokens leaves a message" do
    # One ✕ at a time, each through a real touch that waits for the re-render: a tap
    # sent while the screen is still rendering the previous one carries a stale
    # handle and is dropped, which on a slower device left tokens behind and
    # "No tags left" never came.
    for n <- 0..(@tokens - 1) do
      tap("tok-item_#{n}-remove")
      refute_shown("tok-item_#{n}")
    end

    assert_text("No tags left")

    tap("pill-reset")

    assert_shown("tok-item_0")
  end

  test "tapping a pill body sends its tag to the screen" do
    # on_tap is a different target from the ✕, and the caption below is rendered
    # from the assign the tap sets, so this proves the round trip rather than a
    # local highlight.
    tap("pick-elixir")
    assert_picked("elixir")

    tap("pick-swift")
    assert_picked("swift")
  end

  test "the disabled pill sends nothing" do
    tap("pick-swift")
    assert_picked("swift")

    # `disabled` DROPS the handlers rather than guarding them, so a real touch has
    # nothing to reach, on the body or on the ✕, and the pick must stand.
    tap("pill-locked", expect: :none)
    tap("pill-locked-remove", expect: :none)

    assert_picked("swift")
  end

  test "the page renders every example and the props table" do
    for heading <- ["Inside inputs", "Tappable", "Plain", "Colour", "Disabled", "Props"] do
      assert_text(heading)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  test "the code samples show the tag inside a sigil" do
    tree = render_tree()

    assert tree_has_text?(tree, "~MOB"), "no ~MOB block found in any code sample"
    assert tree_has_text?(tree, "<MishkaPill"), "no <MishkaPill ... /> in the samples"

    # Every event prop on the page is shown WITH the handler that receives it: a
    # sample that only sets on_tap leaves the reader nowhere to go.
    assert tree_has_text?(tree, "handle_info"), "no handler shown beside the event props"
  end

  defp token_count,
    do: frames() |> Map.keys() |> Enum.count(&Regex.match?(~r/\Atok-item_\d+\z/, &1))

  defp assert_picked(id) do
    assert_eventually(fn -> String.starts_with?(text_of!("pill-picked"), "Picked: #{id} ") end,
      message: fn ->
        "the caption reads #{inspect(text_of!("pill-picked"))}, not a pick of #{id}"
      end
    )
  end
end
