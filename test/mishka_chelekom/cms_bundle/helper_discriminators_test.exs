defmodule MishkaChelekom.CmsBundle.DiscriminatorsTest do
  @moduledoc """
  Unit tests for the AST-to-axis-clause converter. Each test feeds a
  raw Elixir AST (the same shape `HelperConditionIndex` emits) and
  asserts the resulting flat clause list.
  """
  use ExUnit.Case, async: true
  alias MishkaChelekom.CmsBundle.Discriminators, as: D

  @moduletag :unit

  defp parse!(src), do: Code.string_to_quoted!(src)

  ## ── single-condition shapes ───────────────────────────────────────

  test "`X in @axis` → one clause" do
    ast = parse!(~S<"base" in @variant>)
    assert D.from_condition(ast) == [%{"axis" => "variant", "values" => ["base"]}]
  end

  test "`@axis in [X, Y]` → one clause with both values" do
    ast = parse!(~S<@variant in ["base", "outline"]>)
    assert D.from_condition(ast) == [%{"axis" => "variant", "values" => ["base", "outline"]}]
  end

  test "is_nil(@axis) alone is ignored (no value to filter on)" do
    ast = parse!(~S<is_nil(@variant)>)
    assert D.from_condition(ast) == []
  end

  test "`is_nil(@axis) or X in @axis` ⇒ keep the value side" do
    ast = parse!(~S<is_nil(@color) or "primary" in @color>)
    assert D.from_condition(ast) == [%{"axis" => "color", "values" => ["primary"]}]
  end

  test "`X in @axis or is_nil(@axis)` (reversed order) ⇒ same result" do
    ast = parse!(~S<"primary" in @color or is_nil(@color)>)
    assert D.from_condition(ast) == [%{"axis" => "color", "values" => ["primary"]}]
  end

  ## ── boolean composition ──────────────────────────────────────────

  test "AND across distinct axes → one clause per axis" do
    ast = parse!(~S<"base" in @variant and "primary" in @color>)

    clauses = D.from_condition(ast) |> Enum.sort_by(& &1["axis"])

    assert clauses == [
             %{"axis" => "color", "values" => ["primary"]},
             %{"axis" => "variant", "values" => ["base"]}
           ]
  end

  test "OR on the same axis fuses values" do
    ast = parse!(~S<"red" in @color or "black" in @color>)
    assert D.from_condition(ast) == [%{"axis" => "color", "values" => ["red", "black"]}]
  end

  test "OR across different axes (cross-axis) is conservatively dropped" do
    ast = parse!(~S<"base" in @variant or "primary" in @color>)
    assert D.from_condition(ast) == []
  end

  test "`not A` is ignored (negation can't be a positive clause)" do
    ast = parse!(~S<"base" not in @variant>)
    assert D.from_condition(ast) == []
  end

  test "complex: AND with grouped same-axis OR" do
    # The exact shape the user asked us to support:
    # `"base" in @variant and ("red" in @color or "black" in @color)`
    ast = parse!(~S<"base" in @variant and ("red" in @color or "black" in @color)>)

    clauses = D.from_condition(ast) |> Enum.sort_by(& &1["axis"])

    assert clauses == [
             %{"axis" => "color", "values" => ["red", "black"]},
             %{"axis" => "variant", "values" => ["base"]}
           ]
  end

  test "three-axis AND: variant + color + size" do
    ast = parse!(~S<"base" in @variant and "primary" in @color and "small" in @size>)

    clauses = D.from_condition(ast) |> Enum.sort_by(& &1["axis"])

    assert clauses == [
             %{"axis" => "color", "values" => ["primary"]},
             %{"axis" => "size", "values" => ["small"]},
             %{"axis" => "variant", "values" => ["base"]}
           ]
  end

  ## ── multi-condition merging (nested wrappers) ────────────────────

  test "two ANDed conditions on different axes flatten" do
    outer = parse!(~S<"default" in @variant>)
    inner = parse!(~S<"primary" in @color>)

    clauses = D.from_conditions([outer, inner]) |> Enum.sort_by(& &1["axis"])

    assert clauses == [
             %{"axis" => "color", "values" => ["primary"]},
             %{"axis" => "variant", "values" => ["default"]}
           ]
  end

  test "two ANDed conditions on SAME axis intersect (AND semantics)" do
    # Outer: variant ∈ {default, outline}
    # Inner: variant ∈ {default, shadow}
    # Both must hold ⇒ {default}.
    outer = parse!(~S<@variant in ["default", "outline"]>)
    inner = parse!(~S<@variant in ["default", "shadow"]>)

    assert D.from_conditions([outer, inner]) ==
             [%{"axis" => "variant", "values" => ["default"]}]
  end

  test "same-axis intersection that drops to empty removes the clause" do
    # No intersection ⇒ helper would never run; clause removed.
    outer = parse!(~S<@variant in ["a", "b"]>)
    inner = parse!(~S<@variant in ["c", "d"]>)

    assert D.from_conditions([outer, inner]) == []
  end

  test "empty conditions list ⇒ empty clauses" do
    assert D.from_conditions([]) == []
  end

  ## ── output shape (downstream contract) ───────────────────────────

  test "every clause uses string keys `axis` and `values`" do
    ast = parse!(~S<"base" in @variant>)
    [clause] = D.from_condition(ast)

    assert Map.keys(clause) |> Enum.sort() == ["axis", "values"]
    assert is_binary(clause["axis"])
    assert is_list(clause["values"])
  end

  test "axis name is the attribute name as a string" do
    ast = parse!(~S<"foo" in @custom_axis_name>)
    [clause] = D.from_condition(ast)

    assert clause["axis"] == "custom_axis_name"
  end
end
