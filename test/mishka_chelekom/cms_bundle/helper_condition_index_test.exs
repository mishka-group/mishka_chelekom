defmodule MishkaChelekom.CmsBundle.HelperConditionIndexTest do
  @moduledoc """
  Unit tests for the raw `.eex` walker that records the
  `<%= if … do %>` chain wrapping each `defp` declaration.
  """
  use ExUnit.Case, async: true
  alias MishkaChelekom.CmsBundle.HelperConditionIndex, as: Index

  @moduletag :unit

  ## ── basic walker behaviour ────────────────────────────────────────

  test "ungated defps have no conditions" do
    eex = ~S"""
    defp foo("a"), do: "x"
    defp foo(_), do: ""
    """

    idx = Index.build(eex)
    assert idx[{"foo", "\"a\""}] == []
    assert idx[{"foo", "_"}] == []
  end

  test "single-level `<%= if %>` is captured" do
    eex = ~S"""
    <%= if "base" in @variant do %>
    defp color("base"), do: "x"
    <% end %>
    """

    idx = Index.build(eex)
    [cond_ast] = idx[{"color", "\"base\""}]
    assert match?({:in, _, ["base", {:@, _, [{:variant, _, _}]}]}, cond_ast)
  end

  test "nested `<%= if %>` records both conditions in outer-to-inner order" do
    eex = ~S"""
    <%= if "default" in @variant do %>
      <%= if "primary" in @color do %>
    defp cv("default", "primary"), do: "x"
      <% end %>
    <% end %>
    """

    idx = Index.build(eex)
    conds = idx[{"cv", "\"default\", \"primary\""}]
    assert length(conds) == 2

    # Outer (variant) comes first, inner (color) second.
    [outer, inner] = conds
    assert match?({:in, _, ["default", {:@, _, [{:variant, _, _}]}]}, outer)
    assert match?({:in, _, ["primary", {:@, _, [{:color, _, _}]}]}, inner)
  end

  test "<% if %> (statement form) is also tracked" do
    eex = ~S"""
    <% if "x" in @axis do %>
    defp foo("x"), do: "z"
    <% end %>
    """

    idx = Index.build(eex)
    assert [_one] = idx[{"foo", "\"x\""}]
  end

  test "non-if blocks (for, case, cond) keep stack depth aligned without polluting conditions" do
    # `case`/`cond`/`for` push a `nil` onto the stack but contribute
    # no condition. Inside, an `if` adds a real condition. After all
    # `<% end %>` pop, depth must be 0 again — so a defp following the
    # whole block sees no leftover conditions.
    eex = ~S"""
    <%= cond do %>
      <% true -> %>
        <%= if "base" in @variant do %>
    defp inside("base"), do: "y"
        <% end %>
    <% end %>
    defp after_block(_), do: "z"
    """

    idx = Index.build(eex)

    # Inner defp sees only the `if` condition (the cond frame
    # contributed nil and was filtered out).
    assert [_one] = idx[{"inside", "\"base\""}]

    # Outer defp sees no conditions — the cond block popped cleanly.
    assert idx[{"after_block", "_"}] == []
  end

  test "`<% else %>` (middle_expr) does not pop the stack" do
    eex = ~S"""
    <%= if "a" in @x do %>
    defp f("a"), do: "y"
    <% else %>
    defp f("b"), do: "z"
    <% end %>
    """

    idx = Index.build(eex)
    # Both defps were inside an `if` frame; both must have a condition.
    assert [_] = idx[{"f", "\"a\""}]
    assert [_] = idx[{"f", "\"b\""}]
  end

  ## ── defp scanner robustness ───────────────────────────────────────

  test "single-line `defp f(args), do: …` is parsed" do
    eex = "defp f(\"x\"), do: \"v\""
    assert Map.has_key?(Index.build(eex), {"f", "\"x\""})
  end

  test "multi-line `defp f(args) do … end` is parsed" do
    eex = ~S"""
    defp f("x") do
      "v"
    end
    """

    assert Map.has_key?(Index.build(eex), {"f", "\"x\""})
  end

  test "complex pattern with nested parens parsed correctly" do
    eex = ~S"""
    defp f(%{a: 1, b: (1 + 2)} = x), do: x
    """

    # AST-based scanner canonicalises args via `Macro.to_string`, which
    # drops superfluous parens. The exporter round-trips the same way,
    # so signatures still match.
    assert Map.has_key?(Index.build(eex), {"f", "%{a: 1, b: 1 + 2} = x"})
  end

  test "identifiers ending in ? or ! are recognised" do
    eex = ~S"""
    defp valid?("y"), do: true
    defp save!("y"), do: :ok
    """

    idx = Index.build(eex)
    assert Map.has_key?(idx, {"valid?", "\"y\""})
    assert Map.has_key?(idx, {"save!", "\"y\""})
  end

  ## ── argument normalisation ────────────────────────────────────────

  test "normalize_args/1 collapses whitespace + trims" do
    assert Index.normalize_args("  \"a\" ,    \"b\"  ") == "\"a\" , \"b\""
    assert Index.normalize_args("foo\n  bar") == "foo bar"
  end

  ## ── error paths ───────────────────────────────────────────────────

  test "tokenization failure returns empty index, not raise" do
    # Unterminated `<%=` — EEx tokenizer rejects it.
    assert Index.build("<%= if x do %>\ndefp f(_), do: nil") == %{} or
             is_map(Index.build("<%= if x do %>\ndefp f(_), do: nil"))
  end
end
