defmodule MishkaMob.Device.TagsInputTest do
  @moduledoc """
  Device tests for the Tags Input page: a port of `TagsInputTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  `return commits the draft` is the interaction the whole component exists for, and it is
  the one that cannot be unit tested: there is no keydown on a phone, so the draft is
  committed by the text field's IME action. The submit event carries NO payload (the
  screen commits the draft it is already holding from on_change), so a broken on_change
  looks exactly like a broken return key until a real keyboard is driven.

  The return key here is a real Enter key event (`type("\\n")`), which Compose answers
  with the field's IME action, the same as the keyboard's own return key.

  Every X renders the same glyph, so tokens are addressed by tag: `ti-tag-elixir`, and
  its X as `ti-tag-elixir-remove`.

  Run with `mix test --only device test/device/tags_input_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :tags_input

  test "return commits the draft" do
    scroll_into_view("ti-draft")

    refute shown?("ti-tag-otp"), "the tag existed before it was added"

    add_tag("otp")
    assert_shown("ti-tag-otp")

    # And the draft is cleared, so the next tag starts empty rather than appending to the
    # last one. The harness cannot read the native field, so this is the draft the screen
    # holds and hands back to it.
    assert_eventually(fn -> Map.fetch!(assigns(), :ti_draft) == "" end,
      message: "the draft was not cleared"
    )

    assert node!("ti-draft").props.value == ""
  end

  test "a token removes itself" do
    scroll_into_view("ti-draft")

    # Add one first, so the test does not depend on the mount value.
    add_tag("gleam")
    assert_shown("ti-tag-gleam")

    # The X is the only part of a token that answers a touch (the pill's body is inert),
    # so that is what the finger goes to.
    tap_settled("ti-tag-gleam-remove")

    refute_shown("ti-tag-gleam")
    refute "gleam" in Map.fetch!(assigns(), :ti_tags)
  end

  test "a duplicate is refused and whitespace trimmed" do
    scroll_into_view("ti-draft")

    # "elixir" is one of the mount tags. Counted in the screen's list, not in the frame
    # table: a frame table has one entry per tag however many tokens there are, and the
    # "It ships no look" example renders the same list under its own ids.
    assert count("elixir") == 1, "the list did not hold exactly one elixir token"
    before = Map.fetch!(assigns(), :ti_tags)

    # Padded, and already present: add/3 trims it and refuses the repeat. The draft being
    # cleared is what says the return key reached the handler, so an unchanged list is the
    # handler's refusal and not a return key that never arrived.
    add_tag("  elixir  ")

    assert_eventually(fn -> Map.fetch!(assigns(), :ti_draft) == "" end,
      message: "the return key never committed"
    )

    assert count("elixir") == 1,
           "a duplicate tag was added: #{inspect(Map.fetch!(assigns(), :ti_tags))}"

    assert Map.fetch!(assigns(), :ti_tags) == before

    # The trim half of this test's name could not fail by counting "elixir" alone: a token
    # whose label is "  elixir  " is not "elixir". The token's id carries the raw text, so
    # the padding shows up here.
    refute shown?("ti-tag-  elixir  "), "the draft was not trimmed"
  end

  test "the draft field draws no line inside the control" do
    scroll_into_view("ti-draft")

    # The control is one box. A Material text field with no border of its own draws its
    # INDICATOR line, which lands inside as a stray rule across the middle (the same
    # defect the number field had). Nothing in the tree can see a drawn line, so this
    # asserts the arrangement that avoids it: the draft sits inside the container's bounds
    # rather than beside it.
    draft = frame!("ti-draft")
    first_tag = frame!("ti-tag-design")

    assert draft.top >= first_tag.top - 1, "the draft is not below the tokens"
    assert draft.left <= first_tag.left + 14, "the draft is indented oddly: #{inspect(draft)}"
  end

  test "tokens wrap onto more than one row when they are long" do
    scroll_into_view("ti-draft")

    # Neither renderer has a flow layout, so the component packs rows itself. Two long tags
    # must not sit on one line running off the edge.
    for tag <- ["averylongtagname", "anotherlongtagname"] do
      add_tag(tag)
      assert_shown("ti-tag-#{tag}")
    end

    a = frame!("ti-tag-averylongtagname")
    b = frame!("ti-tag-anotherlongtagname")
    screen_width = Mob.Test.screen_info(device!()).width

    assert b.top > a.top + 1.4 or b.left >= a.right,
           "long tokens overlap on one row: #{inspect(a)} vs #{inspect(b)}"

    assert a.right <= screen_width, "a token runs off the screen: #{inspect(a)}"
    assert b.right <= screen_width, "a token runs off the screen: #{inspect(b)}"
  end

  test "a disabled control cannot be edited" do
    scroll_into_view("ti-off-draft")

    assert_shown("ti-off-tag-locked", message: "the disabled control did not render")

    # A disabled token wires no remove handler, so a real touch on its X delivers nothing.
    tap("ti-off-tag-locked-remove", expect: :none)

    assert shown?("ti-off-tag-locked"), "a disabled token removed itself"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Add and remove",
          "It ships no look",
          "Empty and disabled",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree.
    for tag <- ~w(ti-draft ti-bare-draft ti-empty-draft ti-off-draft), do: assert_shown(tag)

    # And the page is one long scroll that reaches its end.
    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  # The soft keyboard that typing brought up is still resizing the page, and the new token
  # has just re-flowed it: a frame read the instant the typing ends can be a frame in
  # flight, and a touch aimed at it lands on nothing. Wait for the frame to hold still.
  defp tap_settled(tag) do
    scroll_into_view(tag)
    settled_frame("page")
    settled_frame(tag)

    tap(tag)
  end

  defp count(tag), do: Enum.count(Map.fetch!(assigns(), :ti_tags), &(&1 == tag))

  # Type into the draft and press the return key, which is what commits it.
  defp add_tag(text) do
    focus_end("ti-draft")
    for char <- String.graphemes(text), do: type(char)
    type("\n")
  end

  # A real touch in the bottom-right corner of the field, so the caret lands at the end of
  # the draft. The draft has no on_focus handler, so the touch delivers no event and tap/2
  # cannot be used.
  defp focus_end(tag) do
    scroll_into_view(tag)
    frame = settled_frame(tag)

    result = Mob.Test.tap_xy(device!(), frame.right - 4, frame.bottom - 4)
    sync()

    assert result in [:ok, {:error, :no_effect}], "the touch on #{tag} failed: #{inspect(result)}"
  end

  defp node!(tag), do: find_node(render_tree(), to_string(tag)) || flunk("no node tagged #{tag}")

  defp find_node(%{props: props, children: children} = node, id) do
    if to_string(Map.get(props, :id, "")) == id,
      do: node,
      else: Enum.find_value(children || [], &find_node(&1, id))
  end

  defp find_node(_leaf, _id), do: nil
end
