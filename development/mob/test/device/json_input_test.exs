defmodule MishkaMob.Device.JsonInputTest do
  @moduledoc """
  Device tests for the JSON Input page: a port of `JsonInputTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  The error state is conveyed by COLOUR (a reddened border and a red message) and a
  device test cannot read a colour. What it can read is everything that failed when the
  colour token was wrong: the field used the token `:danger`, which existed in no theme
  and no fallback palette, so it reached the renderer as the string "danger". A border
  needs BOTH a colour and a width, so invalid JSON did not redden the box, it DELETED the
  box's outline, which is a measurable geometric change, and that is what
  `an invalid field keeps its box` asserts.

  Run with `mix test --only device test/device/json_input_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :json_input

  test "an invalid field keeps its box" do
    valid = frame!("json-valid")

    replace_text("json-valid", "{oops}")

    assert_eventually(fn -> error_of("json-valid") != nil end,
      message: "the invalid text raised no error"
    )

    # The bug this guards: an unresolvable border colour made nodeModifier skip the
    # border entirely, so the invalid field lost its outline instead of reddening it. The
    # outline is not readable, but the box it encloses is: a field that still lays out at
    # the same width and a sane height is a field that still has a box drawn round it.
    invalid = frame!("json-valid")

    assert abs(invalid.width - valid.width) < 1.5,
           "the invalid field changed width: #{inspect(valid)} vs #{inspect(invalid)}"

    assert invalid.height > 0, "the invalid field collapsed: #{inspect(invalid)}"
  end

  test "the parser speaks for itself" do
    replace_text("json-valid", "{oops}")

    # Jason's own message, position and all, not a generic "Invalid JSON". Read from THIS
    # field's message: the neighbouring Invalid example also shows a parser message, and
    # it is a different one ("position 9"), so a page-wide match would be satisfied by a
    # field nobody touched.
    assert_eventually(fn -> error_of("json-valid") =~ "position 1" end,
      message: fn ->
        "the field did not report Jason's own message, it said: #{inspect(error_of("json-valid"))}"
      end
    )

    assert error_of("json-valid") =~ "unexpected byte at position 1"
  end

  test "blank is not an error" do
    # Prove the message exists first, so that its ABSENCE below is a real change and not a
    # tag that never resolved.
    replace_text("json-valid", "{oops}")

    assert_eventually(fn -> error_of("json-valid") != nil end,
      message: "the invalid text raised no error"
    )

    replace_text("json-valid", "")

    # An untouched field is not a mistake, and the web version does not paint one red
    # either.
    assert_eventually(fn -> error_of("json-valid") == nil end,
      message: fn -> "an empty field reported: #{inspect(error_of("json-valid"))}" end
    )

    # ...while the example that is MEANT to be broken still says so. Without this, tagging
    # the message wrongly would make the assertion above pass by finding nothing at all.
    assert error_of("json-broken") != nil, "the invalid example lost its message"
  end

  test "a bare scalar is valid json" do
    replace_text("json-valid", "42")
    assert_eventually(fn -> caption() == "Parses: true" end, message: "42 was not valid JSON")

    replace_text("json-valid", ~s("just a string"))

    assert_eventually(fn -> caption() == "Parses: true" end,
      message: "a bare string was not valid JSON"
    )
  end

  test "the caption follows what was typed" do
    replace_text("json-valid", ~s({"a": 1}))

    assert_eventually(fn -> caption() == "Parses: true" end,
      message: "valid JSON was not reported valid"
    )

    replace_text("json-valid", ~s({"a": }))

    assert_eventually(fn -> caption() == "Parses: false" end,
      message: "broken JSON was not reported broken"
    )
  end

  test "a disabled field cannot be typed into" do
    # enabled={false}, not merely a withheld handler: a field that only withholds its
    # handler still takes a caret and accepts typing, then throws every keystroke away.
    # The tree says the field is not enabled...
    assert %{props: %{enabled: false}} = node!("json-off")

    # ...and a real touch on it focuses nothing, so a key has nowhere to go. The page was
    # just mounted, so no other field holds focus.
    tap("json-off", expect: :none)

    assert {:error, _reason} = Mob.Test.type_text(device!(), "x"),
           "a disabled field took focus and accepted typing"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Valid, and validated on the server",
          "Invalid shows the parser's own message",
          "Disabled",
          "Number formatter",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree.
    for tag <- ~w(json-valid json-broken json-broken-error json-off), do: assert_shown(tag)

    # And the page is one long scroll that reaches its end.
    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  # The error message belonging to ONE field, or nil when it shows none.
  #
  # The page permanently renders an *Invalid* example, so its parser message is on screen
  # from the moment the page mounts. A page-wide search for "unexpected byte" is therefore
  # true before a test types anything. Ask the field.
  defp error_of(id) do
    case find_node("#{id}-error") do
      %{props: %{text: text}} -> text
      nil -> nil
    end
  end

  # The "Parses: ..." caption under the valid field.
  defp caption, do: node!("json-parses").props.text
end
