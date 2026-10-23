defmodule MishkaMob.Components.MishkaNumberFieldTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaNumberField, as: NF

  doctest MishkaMob.Components.MishkaNumberField

  describe "parse/2 — partial input must not blow up or snap to zero" do
    test "reads whole numbers and decimals" do
      assert NF.parse("42") == 42
      assert NF.parse("4.5") == 4.5
      assert NF.parse("-7") == -7
    end

    test "keeps integers integral — \"42\" is not 42.0" do
      assert is_integer(NF.parse("42"))
      assert is_float(NF.parse("42.0"))
    end

    test "mid-typing input is 'not a number yet', not an error" do
      for partial <- ["", "-", "+", ".", "-.", "   "], do: assert(NF.parse(partial) == nil)
    end

    test "junk is nil rather than raising" do
      assert NF.parse("abc") == nil
      assert NF.parse("12abc") == nil
      assert NF.parse(nil) == nil
    end

    test "clamps into the range when one is given" do
      assert NF.parse("150", min: 0, max: 100) == 100
      assert NF.parse("-5", min: 0, max: 100) == 0
      assert NF.parse("50", min: 0, max: 100) == 50
    end

    test "a number passes straight through, still clamped" do
      assert NF.parse(7) == 7
      assert NF.parse(700, max: 100) == 100
    end
  end

  describe "step/3" do
    test "moves by the step in either direction" do
      assert NF.step(1, :up, step: 1) == 2
      assert NF.step(1, :down, step: 1) == 0
      assert NF.step(10, :down, step: 5) == 5
    end

    test "does not accumulate floating-point noise" do
      assert NF.step(0.3, :up, step: 0.1) == 0.4
      assert NF.step(0.7, :down, step: 0.1) == 0.6
    end

    test "clamps at both bounds" do
      assert NF.step(10, :up, step: 1, max: 10) == 10
      assert NF.step(0, :down, step: 1, min: 0) == 0
    end

    test "the first press on an empty field lands ON min, not a step past it" do
      assert NF.step(nil, :up, step: 1, min: 5) == 5
      assert NF.step(nil, :down, step: 1, min: 5) == 5
      assert NF.step(nil, :up, step: 1) == 0
    end
  end

  describe "to_text/2 and decimals_for/1" do
    test "renders at the step's precision" do
      assert NF.to_text(4, 0) == "4"
      assert NF.to_text(4.5, 1) == "4.5"
      assert NF.to_text(4.5, 2) == "4.50"
    end

    test "an absent value renders empty, not \"0\"" do
      assert NF.to_text(nil, 0) == ""
    end

    test "decimals are derived from the step" do
      assert NF.decimals_for(1) == 0
      assert NF.decimals_for(0.1) == 1
      assert NF.decimals_for(0.25) == 2
    end
  end

  describe "the rendered field" do
    test "is ONE bordered strip: stepper, value, stepper" do
      tree = NF.number_field(value: 1)

      # A Box, not a Row. It used to be a stepper, a gap, a filling bordered
      # field and another stepper, so the buttons drifted to opposite edges with
      # a wide box marooned between them. The border belongs to the strip.
      assert tree.type == :box
      assert tree.props.border_width == 1
      assert find(tree, :text_field)
      assert text(tree) =~ "−"
      assert text(tree) =~ "+"
    end

    test "the inner field draws no box of its own" do
      field = find(NF.number_field(value: 1), :text_field)

      # Otherwise the strip has a second border inside it — and with no border of
      # its own the platform would draw its indicator underline instead, which is
      # what `underline: false` turns off.
      assert field.props.underline == false
      assert field.props.background == :transparent
      assert field.props.text_align == "center"
      refute Map.has_key?(field.props, :border_width)
    end

    test "the value slot widens for a longer rendered value" do
      # A fixed slot clipped "$1,999.99" down to "99.99". There is no text
      # measurement on this side of the bridge, so the width is estimated from
      # the string the component is about to render.
      short = NF.number_field(value: 3)
      money = NF.number_field(value: 1999.99, step: 0.01, format: :currency)

      short_slot = short |> find_all(:box) |> Enum.find(&(&1.props[:width] not in [nil, 1, 56]))
      money_slot = money |> find_all(:box) |> Enum.find(&(&1.props[:width] not in [nil, 1, 56]))

      assert money_slot.props.width > short_slot.props.width

      assert NF.number_field(value: 3, value_width: 200)
             |> find_all(:box)
             |> Enum.any?(&(&1.props[:width] == 200))
    end

    # The platform field draws its placeholder in a text that wraps when the slot
    # is narrow. In a 96dp slot "How many?" wrapped over three lines, and the
    # empty strip stood twice as tall as the one holding a value.
    test "the value slot is wide enough for the placeholder, not just the value" do
      empty = NF.number_field(value: nil, placeholder: "How many?")
      bare = NF.number_field(value: nil)

      # "How many?" is about 82dp of text inside 48dp of padding (Material's
      # 16dp a side and the node's 8dp a side). 130dp still wrapped it on a phone.
      assert slot(empty).props.width >= 150
      assert slot(empty).props.width > slot(bare).props.width
      assert slot(bare).props.width == 96
    end

    test "the slot keeps its width when a value takes the placeholder's place" do
      empty = NF.number_field(value: nil, placeholder: "How many?")
      filled = NF.number_field(value: 3, placeholder: "How many?")

      # Otherwise the strip would change width as the first digit went in.
      assert slot(filled).props.width == slot(empty).props.width
    end

    test "a value longer than the placeholder still decides the width" do
      money = NF.number_field(value: 1999.99, step: 0.01, format: :currency, placeholder: "$")

      assert slot(money).props.width == 40 + 16 * String.length("$1,999.99")
    end

    test "an explicit value_width beats the estimate for the placeholder" do
      tree = NF.number_field(value: nil, placeholder: "How many?", value_width: 140)

      assert slot(tree).props.width == 140
    end

    test "the value slot leaves its height to the field, so the text is never clipped" do
      # Pinned to `size` and centred, the slot cut the platform field's text to a
      # sliver on a device: the field keeps its own padding inside the height.
      for props <- [
            [value: nil, placeholder: "How many?"],
            [value: 3],
            [value: nil, placeholder: "How many?", fill_width: true]
          ] do
        refute Map.has_key?(slot(NF.number_field(props)).props, :height)
      end
    end

    test "the steppers and the hairlines follow a custom size" do
      tree = NF.number_field(value: nil, placeholder: "How many?", size: 48)
      boxes = find_all(tree, :box)

      assert Enum.count(boxes, &(&1.props[:height] == 48)) == 4
    end

    test "the spanning slot shares the row" do
      slot = slot(NF.number_field(value: nil, placeholder: "How many?", fill_width: true))

      assert slot.props.weight == 1
      refute Map.has_key?(slot.props, :width)
    end

    test "the strip hugs by default and spans on request" do
      assert NF.number_field(value: 1).props.fill_width == false
      assert NF.number_field(value: 1, fill_width: true).props.fill_width == true
    end

    test "a stepper goes inert at its bound, not just when disabled" do
      at_max = NF.number_field(value: 10, max: 10, on_step: :bump)
      taps = at_max |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)

      # Only the DOWN stepper is still wired.
      assert taps == [{self(), {:bump, :down}}]

      at_min = NF.number_field(value: 0, min: 0, on_step: :bump)

      taps_min =
        at_min |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)

      assert taps_min == [{self(), {:bump, :up}}]
    end

    test "id tags the value field and both steppers with their direction" do
      tree = NF.number_field(value: 1, id: "qty")
      ids = tree |> find_all(:box) |> Enum.map(& &1.props[:id]) |> Enum.reject(&is_nil/1)

      assert find(tree, :text_field).props.id == "qty"
      assert ids == ["qty-down", "qty-up"]
    end

    test "no id leaves everything untagged" do
      tree = NF.number_field(value: 1)

      refute Map.has_key?(find(tree, :text_field).props, :id)
      assert tree |> find_all(:box) |> Enum.all?(&is_nil(&1.props[:id]))
    end

    test "an unbounded field keeps both steppers live" do
      tree = NF.number_field(value: 999, on_step: :bump)
      taps = tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)

      assert [_, _] = taps
    end

    test "picks the numeric keypad for whole steps and decimal otherwise" do
      assert find(NF.number_field(value: 1, step: 1), :text_field).props.keyboard == "number"
      assert find(NF.number_field(value: 1, step: 0.1), :text_field).props.keyboard == "decimal"
    end

    test "the value is rendered at the step's precision" do
      assert find(NF.number_field(value: 4, step: 1), :text_field).props.value == "4"
      assert find(NF.number_field(value: 0.5, step: 0.1), :text_field).props.value == "0.5"
    end

    test "format reaches the rendered value" do
      currency = NF.number_field(value: 1999.99, step: 0.01, format: :currency)
      percent = NF.number_field(value: 0.075, step: 0.001, format: :percent)

      assert find(currency, :text_field).props.value == "$1,999.99"
      # The stored value is a FRACTION — 0.075 is 7.5%, not 0.075%.
      assert find(percent, :text_field).props.value == "7.5%"
    end

    test "each stepper carries its own direction" do
      tree = NF.number_field(value: 1, on_step: :bump)
      taps = tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)

      assert taps == [{self(), {:bump, :down}}, {self(), {:bump, :up}}]
    end

    test "disabled unwires the field and both steppers" do
      tree = NF.number_field(value: 1, disabled: true, on_step: :bump, on_change: :typed)

      assert tree |> find_all(:box) |> Enum.all?(&(&1.props[:on_tap] == nil))
      refute Map.has_key?(find(tree, :text_field).props, :on_change)
    end
  end

  # The Box that holds the platform field, between the two hairlines.
  defp slot(tree) do
    tree
    |> find_all(:box)
    |> Enum.find(fn box -> Enum.any?(box.children, &(&1.type == :text_field)) end)
  end

  test "expand/3 delegates" do
    assert NF.expand(%{value: 1}, [], %{screen: self()}) == NF.number_field(value: 1)
  end

  test "every variant renders" do
    for props <- [%{}, %{value: 1}, %{value: 0.5, step: 0.1}, %{disabled: true}] do
      assert_renderable(NF.number_field(props))
    end
  end
end
