defmodule MishkaMob.Components.MishkaJsonInputTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaJsonInput, MishkaNumberFormatter}

  doctest MishkaMob.Components.MishkaJsonInput
  doctest MishkaMob.Components.MishkaNumberFormatter

  describe "validate/1" do
    test "accepts objects, arrays and bare scalars" do
      assert MishkaJsonInput.validate(~s({"a": 1})) == {:ok, %{"a" => 1}}
      assert MishkaJsonInput.validate("[1, 2]") == {:ok, [1, 2]}
      assert MishkaJsonInput.validate("42") == {:ok, 42}
      assert MishkaJsonInput.validate(~s("text")) == {:ok, "text"}
      assert MishkaJsonInput.validate("null") == {:ok, nil}
    end

    test "blank is :empty, not an error — an untouched field is not a mistake" do
      assert MishkaJsonInput.validate("") == :empty
      assert MishkaJsonInput.validate("   \n ") == :empty
      assert MishkaJsonInput.validate(nil) == :empty
    end

    test "reports the parser's own message, not a generic one" do
      assert {:error, message} = MishkaJsonInput.validate("{oops}")
      assert message =~ "position"
    end
  end

  describe "format/1" do
    test "pretty-prints valid JSON" do
      assert MishkaJsonInput.format(~s({"a":1})) == "{\n  \"a\": 1\n}"
    end

    test "leaves invalid text exactly as typed" do
      assert MishkaJsonInput.format("{oops}") == "{oops}"
      assert MishkaJsonInput.format("") == ""
      assert MishkaJsonInput.format(nil) == ""
    end

    test "is idempotent, so a second tap changes nothing" do
      once = MishkaJsonInput.format(~s({"a":[1,2]}))

      assert MishkaJsonInput.format(once) == once
    end
  end

  describe "rendering" do
    test "is a multi-line field — the reason the bridge grew `lines`" do
      field = MishkaJsonInput.json_input(value: "{}", lines: 8) |> find(:text_field)

      assert field.props.lines == 8
      assert field.props.value == "{}"
    end

    test "invalid text paints the border and shows the message" do
      tree = MishkaJsonInput.json_input(value: "{oops}")

      # :error, not :danger. :danger was in no theme and no fallback palette, so
      # it serialised as the string "danger": the border was not drawn at all
      # (a border needs BOTH a colour and a width) and the message was not red
      # on Android and fully transparent on iOS. These assertions passed anyway,
      # because a token is only resolved on its way to the device.
      assert find(tree, :text_field).props.border_color == :error
      assert find(tree, :text).props.text_color == :error
    end

    test "valid and blank text are both left alone" do
      for value <- [~s({"a": 1}), "", "   "] do
        tree = MishkaJsonInput.json_input(value: value)

        assert find(tree, :text_field).props.border_color == :border
        refute find(tree, :text)
      end
    end

    test "invalid can be forced, and overridden" do
      forced = MishkaJsonInput.json_input(value: ~s({"a": 1}), invalid: true)
      suppressed = MishkaJsonInput.json_input(value: "{oops}", invalid: false)

      assert find(forced, :text_field).props.border_color == :error
      assert find(suppressed, :text_field).props.border_color == :border
    end

    test "the message can be replaced or hidden" do
      custom = MishkaJsonInput.json_input(value: "{oops}", error_text: "Check your braces")
      hidden = MishkaJsonInput.json_input(value: "{oops}", show_error: false)

      assert text(custom) =~ "Check your braces"
      refute find(hidden, :text)
      # …but the border still marks it.
      assert find(hidden, :text_field).props.border_color == :error
    end

    test "reports keystrokes, and disabled reports nothing" do
      live = MishkaJsonInput.json_input(on_change: :draft) |> find(:text_field)
      dead = MishkaJsonInput.json_input(on_change: :draft, disabled: true) |> find(:text_field)

      assert live.props.on_change == {self(), :draft}
      refute Map.has_key?(dead.props, :on_change)
    end

    test "disabled actually disables it, rather than only going quiet" do
      # Withholding the handler stops the BEAM hearing about edits but leaves
      # the field focusable and editable: it accepts typing, shows a caret, and
      # silently discards everything. `enabled` is what the platform reads.
      dead = MishkaJsonInput.json_input(disabled: true) |> find(:text_field)
      live = MishkaJsonInput.json_input() |> find(:text_field)

      assert dead.props.enabled == false
      assert live.props.enabled == true
    end

    test "the error colour is overridable, like every other colour here" do
      tree = MishkaJsonInput.json_input(value: "{oops}", error_color: 0xFF00FF00)

      assert find(tree, :text_field).props.border_color == 0xFF00FF00
      assert find(tree, :text).props.text_color == 0xFF00FF00
    end

    test "id tags the field, so a device test can address it" do
      assert MishkaJsonInput.json_input(id: "cfg")
             |> find(:text_field)
             |> get_in([Access.key(:props), :id]) ==
               "cfg"

      refute MishkaJsonInput.json_input()
             |> find(:text_field)
             |> Map.fetch!(:props)
             |> Map.has_key?(:id)
    end

    test "forcing invalid on text that PARSES tints, but does not claim bad syntax" do
      # The caller knows something the parser does not — a schema rejected it,
      # the server said no. "Invalid JSON" would be a lie about the one thing
      # this component actually checked.
      forced = MishkaJsonInput.json_input(value: ~s({"a": 1}), invalid: true)

      assert find(forced, :text_field).props.border_color == :error
      refute find(forced, :text)

      # With a message supplied, it says that instead.
      told =
        MishkaJsonInput.json_input(value: ~s({"a": 1}), invalid: true, error_text: "Rejected")

      assert text(told) =~ "Rejected"
    end
  end

  describe "number formatter" do
    test "groups thousands without touching the decimals" do
      assert MishkaNumberFormatter.format(1_234_567) == "1,234,567"
      assert MishkaNumberFormatter.format(1234.5678, decimals: 4) == "1,234.5678"
    end

    test "reverses once — the classic bug gives 1,432,765" do
      assert MishkaNumberFormatter.format(1_234_567) == "1,234,567"
      assert MishkaNumberFormatter.format(12_345) == "12,345"
      assert MishkaNumberFormatter.format(123_456) == "123,456"
    end

    test "small numbers get no separator at all" do
      for {value, expected} <- [{0, "0"}, {7, "7"}, {99, "99"}, {999, "999"}, {1000, "1,000"}] do
        assert MishkaNumberFormatter.format(value) == expected
      end
    end

    test "the sign stays outside the grouping" do
      assert MishkaNumberFormatter.format(-1_234_567) == "-1,234,567"
      assert MishkaNumberFormatter.format(-999) == "-999"
      assert MishkaNumberFormatter.format(-1234.5, decimals: 1) == "-1,234.5"
    end

    test "decimals are padded and rounded, not truncated" do
      assert MishkaNumberFormatter.format(1.5, decimals: 3) == "1.500"
      assert MishkaNumberFormatter.format(1.567, decimals: 2) == "1.57"
      assert MishkaNumberFormatter.format(2, decimals: 2) == "2.00"
    end

    test "nil decimals keeps whatever the number has" do
      assert MishkaNumberFormatter.format(1.5) == "1.5"
      assert MishkaNumberFormatter.format(2) == "2"
    end

    test "both separators are configurable, for European style" do
      assert MishkaNumberFormatter.format(1234.5,
               decimals: 2,
               thousand_separator: ".",
               decimal_separator: ","
             ) == "1.234,50"
    end

    test "grouping can be switched off, or asked for by name" do
      assert MishkaNumberFormatter.format(1_234_567, thousand_separator: false) == "1234567"
      assert MishkaNumberFormatter.format(1_234_567, thousand_separator: true) == "1,234,567"
      assert MishkaNumberFormatter.format(1_234_567, thousand_separator: " ") == "1 234 567"
    end

    test "prefix and suffix wrap the digits, sign included" do
      assert MishkaNumberFormatter.format(1234, prefix: "$", suffix: " USD") == "$1,234 USD"
      assert MishkaNumberFormatter.format(-5, prefix: "$") == "$-5"
    end

    test "numeric strings are parsed; nonsense is passed through" do
      assert MishkaNumberFormatter.format("1234.5", decimals: 1) == "1,234.5"
      assert MishkaNumberFormatter.format("n/a") == "n/a"
      assert MishkaNumberFormatter.format(nil) == ""
    end

    test "renders as a styled Text node" do
      node = MishkaNumberFormatter.number_formatter(value: 1000, text_color: :danger)

      assert node.type == :text
      assert node.props.text == "1,000"
      assert node.props.text_color == :danger
    end
  end

  test "expand/3 delegates for both" do
    ctx = %{screen: self()}

    assert MishkaJsonInput.expand(%{value: "1"}, [], ctx) ==
             MishkaJsonInput.json_input(value: "1")

    assert MishkaNumberFormatter.expand(%{value: 5}, [], ctx) ==
             MishkaNumberFormatter.number_formatter(value: 5)
  end

  test "every variant renders" do
    for props <- [%{}, %{value: "{oops}"}, %{value: ~s({"a":1}), lines: 2}, %{disabled: true}] do
      assert_renderable(MishkaJsonInput.json_input(props))
    end

    assert_renderable(MishkaNumberFormatter.number_formatter(value: -1234.5, decimals: 2))
  end
end
