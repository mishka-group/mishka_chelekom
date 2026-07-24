defmodule MishkaMob.Components.MishkaFieldTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaField, MishkaFieldset}

  doctest MishkaMob.Components.MishkaField

  defp control, do: [%{type: :text_field, props: %{value: ""}, children: []}]

  describe "invalid?/1" do
    test "ignores blank and nil messages" do
      assert MishkaField.invalid?(%{errors: ["too short"]})
      refute MishkaField.invalid?(%{errors: []})
      refute MishkaField.invalid?(%{errors: [nil, ""]})
      refute MishkaField.invalid?(%{})
    end

    test "accepts a bare string as well as a list" do
      assert MishkaField.invalid?(%{errors: "boom"})
    end
  end

  describe "label" do
    test "renders above the control when given" do
      tree = MishkaField.field(%{label: "Email"}, control())

      assert text(tree) =~ "Email"
      assert find(tree, :text_field)
    end

    test "required appends a marker" do
      assert text(MishkaField.field(%{label: "Email", required: true}, control())) =~ "*"
      refute text(MishkaField.field(%{label: "Email"}, control())) =~ "*"
    end

    test "no label renders no label row" do
      tree = MishkaField.field(%{}, control())

      assert find_all(tree, :text) == []
    end
  end

  describe "description and errors" do
    test "the description shows when there are no errors" do
      tree = MishkaField.field(%{description: "We'll never share it."}, control())

      assert text(tree) =~ "never share"
    end

    test "errors REPLACE the description — a hint above a failure buries it" do
      tree =
        MishkaField.field(
          %{description: "We'll never share it.", errors: ["Must contain an @."]},
          control()
        )

      assert text(tree) =~ "Must contain an @."
      refute text(tree) =~ "never share"
    end

    test "every error renders, each with a ✕ so colour is not the only signal" do
      tree = MishkaField.field(%{errors: ["Too short.", "Already taken."]}, control())

      assert text(tree) =~ "Too short."
      assert text(tree) =~ "Already taken."
      assert length(find_all(tree, :row)) == 2
      assert text(tree) =~ "✕"
    end

    test "blank and nil errors are ignored, so the description survives" do
      tree = MishkaField.field(%{description: "hint", errors: [nil, ""]}, control())

      assert text(tree) =~ "hint"
    end
  end

  test "disabled mutes the label" do
    tree = MishkaField.field(%{label: "Email", disabled: true}, control())

    assert find(tree, :text, text: "Email").props.text_color == :muted
  end

  test "expand/3 uses the tag's children as the control" do
    assert MishkaField.expand(%{label: "x"}, control(), %{screen: self()}) ==
             MishkaField.field(%{label: "x"}, control())
  end

  describe "fieldset" do
    test "renders a legend above its children" do
      tree = MishkaFieldset.fieldset(%{legend: "Billing"}, control())

      assert text(tree) =~ "Billing"
      assert find(tree, :text_field)
    end

    test "disabled mutes the legend but does NOT touch the children" do
      child = [%{type: :text_field, props: %{value: "", on_change: {self(), :x}}, children: []}]
      tree = MishkaFieldset.fieldset(%{legend: "Billing", disabled: true}, child)

      assert find(tree, :text, text: "Billing").props.text_color == :muted
      # the control keeps its handler — the cascade is the caller's job
      assert find(tree, :text_field).props.on_change == {self(), :x}
    end

    test "decoration is optional and skipped when not asked for" do
      plain = MishkaFieldset.fieldset(%{legend: "x"}, control())

      boxed =
        MishkaFieldset.fieldset(
          %{legend: "x", background: :surface_raised, padding: 8},
          control()
        )

      assert plain.type == :column
      assert boxed.type == :box
      assert boxed.props.background == :surface_raised
    end

    test "expand/3 uses the tag's children" do
      assert MishkaFieldset.expand(%{legend: "x"}, control(), %{screen: self()}) ==
               MishkaFieldset.fieldset(%{legend: "x"}, control())
    end
  end

  test "every variant renders" do
    for props <- [%{}, %{label: "L"}, %{errors: ["e"]}, %{label: "L", description: "d"}] do
      assert_renderable(MishkaField.field(props, control()))
    end

    assert_renderable(MishkaFieldset.fieldset(%{legend: "g"}, control()))
  end
end
