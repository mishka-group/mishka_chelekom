defmodule MishkaMob.Components.MishkaOtpFieldTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaMaskInput, MishkaOtpField}

  doctest MishkaMob.Components.MishkaOtpField
  doctest MishkaMob.Components.MishkaMaskInput

  describe "sanitize/2" do
    test "drops separators from a paste rather than rejecting it" do
      assert MishkaOtpField.sanitize("12-34-56", length: 6) == "123456"
      assert MishkaOtpField.sanitize("1 2 3", length: 6) == "123"
    end

    test "truncates to the slot count" do
      assert MishkaOtpField.sanitize("1234567890", length: 4) == "1234"
    end

    test "honours the validation type" do
      assert MishkaOtpField.sanitize("a1b2", validation_type: :alpha) == "ab"
      assert MishkaOtpField.sanitize("a1b2", validation_type: :numeric) == "12"
      assert MishkaOtpField.sanitize("a1-b2", validation_type: :alphanumeric) == "a1b2"
      assert MishkaOtpField.sanitize("a1-b2", validation_type: :none, length: 9) == "a1-b2"
    end

    test "nil and empty are empty" do
      assert MishkaOtpField.sanitize(nil, []) == ""
      assert MishkaOtpField.sanitize("", []) == ""
    end
  end

  describe "complete?/2" do
    test "is true only when every slot is filled" do
      assert MishkaOtpField.complete?("123456", length: 6)
      refute MishkaOtpField.complete?("12345", length: 6)
      refute MishkaOtpField.complete?("", length: 6)
      assert MishkaOtpField.complete?("12", length: 2)
    end
  end

  describe "the rendered field" do
    test "draws one slot per length, over a SINGLE text field" do
      tree = MishkaOtpField.otp_field(value: "12", length: 6)
      slots = tree |> find_all(:box) |> Enum.filter(&(&1.props[:height] == 48))

      assert length(slots) == 6
      assert length(find_all(tree, :text_field)) == 1
    end

    test "filled slots show their digit and take the accent border" do
      tree = MishkaOtpField.otp_field(value: "12", length: 4)
      slots = tree |> find_all(:box) |> Enum.filter(&(&1.props[:height] == 48))

      # Two filled, then the ACTIVE slot — where the next character lands. The
      # web gets that from focus; there is no focus API here, so it comes from
      # the value's length, which is the same answer.
      assert Enum.map(slots, & &1.props.border_width) == [2, 2, 2, 1]
      assert text(tree) =~ "1"
      assert text(tree) =~ "2"
    end

    test "the active slot is the one the next character lands in" do
      borders = fn value ->
        MishkaOtpField.otp_field(value: value, length: 4)
        |> find_all(:box)
        |> Enum.filter(&(&1.props[:height] == 48))
        |> Enum.map(& &1.props.border_width)
      end

      # An empty code still marks slot 0, so there is somewhere to look before
      # typing anything. Filled and active share the accent, which is what makes
      # the run of 2s grow by one from the left.
      assert borders.("") == [2, 1, 1, 1]
      assert borders.("1") == [2, 2, 1, 1]
      assert borders.("12") == [2, 2, 2, 1]
    end

    test "a full code has no slot left to be active" do
      slots =
        MishkaOtpField.otp_field(value: "1234", length: 4)
        |> find_all(:box)
        |> Enum.filter(&(&1.props[:height] == 48))

      assert Enum.map(slots, & &1.props.border_width) == [2, 2, 2, 2]
    end

    test "the boxes ARE the input: the field over them is invisible" do
      # The first version drew a visible TextField UNDER the boxes and made the
      # boxes a read-only display of it — two places to look, and not what the
      # web component does. The field is now stacked over the slots and
      # transparent, so the boxes are what you see and tap.
      tree = MishkaOtpField.otp_field(value: "12", length: 6)
      field = find(tree, :text_field)

      assert tree.type == :box
      assert Enum.map(tree.children, & &1.type) == [:row, :text_field]
      assert field.props.background == :transparent
      assert field.props.text_color == :transparent
      assert field.props.caret_color == :transparent
      assert field.props.border_color == :transparent
    end

    test "the field is NOT length-capped natively, so a formatted paste survives" do
      # A pasted "123-456" is seven characters. Capping the field at six would
      # refuse the whole paste, where sanitize/2 turns it into the code meant.
      field = find(MishkaOtpField.otp_field(value: "", length: 6), :text_field)

      refute Map.has_key?(field.props, :max_length)
      assert MishkaOtpField.sanitize("123-456", length: 6) == "123456"
    end

    test "disabled actually disables the field, not just its handler" do
      # Withholding the handler alone left the field editable and focusable: it
      # looked live and quietly went nowhere.
      assert find(MishkaOtpField.otp_field(value: "1", disabled: true), :text_field).props.enabled ==
               false

      assert find(MishkaOtpField.otp_field(value: "1"), :text_field).props.enabled == true
    end

    test "the overlay hides its cursor by way of a transparent text colour" do
      # caret_color is not one of the renderer's colour props, so it would never
      # resolve; the bridge takes the cursor from text_color instead.
      field = find(MishkaOtpField.otp_field(value: "1"), :text_field)

      assert field.props.text_color == :transparent
    end

    test "slots are a fixed width, because weight is Compose-only" do
      slots =
        MishkaOtpField.otp_field(value: "", length: 4)
        |> find_all(:box)
        |> Enum.filter(&(&1.props[:height] == 48))

      assert Enum.all?(slots, &(&1.props[:width] == 44))
      refute Enum.any?(slots, &Map.has_key?(&1.props, :weight))
    end

    test "mask renders bullets instead of the digits" do
      tree = MishkaOtpField.otp_field(value: "12", length: 4, mask: true)

      assert text(tree) =~ "•"
      refute text(tree) =~ "1"
    end

    test "numeric validation asks for the number keypad" do
      assert find(MishkaOtpField.otp_field(value: ""), :text_field).props.keyboard == "number"

      assert find(MishkaOtpField.otp_field(value: "", validation_type: :alpha), :text_field).props.keyboard ==
               "text"
    end

    test "disabled unwires the field" do
      tree = MishkaOtpField.otp_field(value: "1", disabled: true, on_change: :code)

      refute Map.has_key?(find(tree, :text_field).props, :on_change)
    end
  end

  describe "mask input" do
    test "inserts literals as you type" do
      assert MishkaMaskInput.apply_mask("5551234567", "(999) 999-9999") == "(555) 123-4567"
      assert MishkaMaskInput.apply_mask("12252024", "99/99/9999") == "12/25/2024"
    end

    test "is IDEMPOTENT — re-masking an already-masked value changes nothing" do
      masked = MishkaMaskInput.apply_mask("5551234567", "(999) 999-9999")

      assert MishkaMaskInput.apply_mask(masked, "(999) 999-9999") == masked
    end

    test "a partial value stops cleanly rather than padding" do
      assert MishkaMaskInput.apply_mask("555", "(999) 999-9999") == "(555"
      assert MishkaMaskInput.apply_mask("5", "(999) 999-9999") == "(5"
      assert MishkaMaskInput.apply_mask("", "99/99") == ""
    end

    test "token kinds are enforced, and mismatches are skipped not inserted" do
      assert MishkaMaskInput.apply_mask("abc1234", "aaa-9999") == "abc-1234"
      # digits cannot fill letter slots
      assert MishkaMaskInput.apply_mask("123abc", "aaa-9999") == "abc"
    end

    test "extra input past the mask is dropped" do
      assert MishkaMaskInput.apply_mask("99999", "99/99") == "99/99"
    end

    test "no mask leaves the value alone" do
      assert MishkaMaskInput.apply_mask("anything", nil) == "anything"
      assert MishkaMaskInput.apply_mask(nil, "99") == ""
    end

    test "strip/1 returns the unformatted payload" do
      assert MishkaMaskInput.strip("(555) 123-4567") == "5551234567"
      assert MishkaMaskInput.strip(nil) == ""
    end

    test "an all-digit mask picks the number keypad" do
      assert MishkaMaskInput.mask_input(mask: "99/99").props.keyboard == "number"
      assert MishkaMaskInput.mask_input(mask: "aaa-9999").props.keyboard == "text"
    end

    test "the mask doubles as the placeholder unless one is given" do
      assert MishkaMaskInput.mask_input(mask: "99/99").props.placeholder == "99/99"

      assert MishkaMaskInput.mask_input(mask: "99/99", placeholder: "DD/MM").props.placeholder ==
               "DD/MM"
    end
  end

  test "expand/3 delegates for both" do
    assert MishkaOtpField.expand(%{value: "1"}, [], %{screen: self()}) ==
             MishkaOtpField.otp_field(value: "1")

    assert MishkaMaskInput.expand(%{mask: "99"}, [], %{screen: self()}) ==
             MishkaMaskInput.mask_input(mask: "99")
  end

  test "every variant renders" do
    for props <- [%{}, %{value: "123"}, %{value: "123", mask: true}, %{disabled: true}] do
      assert_renderable(MishkaOtpField.otp_field(props))
    end

    assert_renderable(MishkaMaskInput.mask_input(mask: "(999) 999-9999"))
  end
end
