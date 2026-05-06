defmodule MishkaChelekom.CmsBundle.HelperDiscriminators do
  @moduledoc """
  Convert a list of `<%= if cond do %>` condition ASTs (from
  `MishkaChelekom.CmsBundle.HelperConditionIndex`) into a flat, install-time-
  consumable list of axis filters.

  ## Output shape

      [
        %{"axis" => "variant", "values" => ["base"]},
        %{"axis" => "color",   "values" => ["red", "black"]}
      ]

  Each entry is one **axis clause**. The MishkaCMS installer ANDs all
  clauses together: a helper is kept only if **every** clause's axis-
  value set has at least one element in the user's selection for that
  axis. Within a single clause, the listed values are an OR set
  (`color in [red, black]`).

  ## Recognised condition shapes

  Built from chelekom's actual `.eex` patterns. New shapes can be
  added without breaking the bundle JSON: unrecognised condition
  fragments produce no clauses and are ignored.

      "X" in @axis                    → [{axis, [X]}]
      "X" in @axis or "Y" in @axis    → [{axis, [X, Y]}]
      is_nil(@axis) or "X" in @axis   → [{axis, [X]}]
                                         (is_nil branch is "no filter
                                         applied", so when the user
                                         DOES filter, only the "X"
                                         path matters)
      A and B                         → discriminators(A) ++ discriminators(B)
      not A                           → ignored (negation isn't
                                         representable as a positive
                                         axis-value clause)
      everything else                 → ignored

  ## Multiple if-wrappers (nested)

  When a defp is wrapped by multiple `<%= if %>` blocks (one outer,
  one inner), each block's condition is converted independently and
  the results are concatenated. The installer ANDs them — exactly the
  semantics of nesting in HEEx.
  """

  @type axis_clause :: %{required(String.t()) => any()}

  @doc """
  Convert one or more condition ASTs into a flat list of axis clauses.
  Same-axis clauses produced by different conditions are MERGED via
  intersection (AND semantics — both wrappers must pass).
  """
  @spec from_conditions([Macro.t()]) :: [axis_clause()]
  def from_conditions(conditions) when is_list(conditions) do
    conditions
    |> Enum.flat_map(&from_condition/1)
    |> merge_same_axis()
  end

  @doc """
  Convert a single condition AST into a flat list of axis clauses.
  """
  @spec from_condition(Macro.t()) :: [axis_clause()]
  def from_condition(ast), do: walk(ast, [])

  ## ── walker

  # `A and B` — both must hold; concat clauses (merging same-axis later).
  defp walk({:and, _, [left, right]}, acc) do
    acc
    |> then(&walk(left, &1))
    |> then(&walk(right, &1))
  end

  # `A or B` — same-axis OR fuses values; cross-axis OR is too coarse
  # to represent as ANDed clauses, so we keep both sides only when
  # they reduce to the same axis. Mixed-axis OR yields no clauses
  # (conservatively unfilterable).
  defp walk({:or, _, [left, right]}, acc) do
    left_clauses = walk(left, [])
    right_clauses = walk(right, [])

    same_axis_fused = fuse_same_axis_or(left_clauses, right_clauses)

    cond do
      # Pure null-check on one side: drop it, keep the value-side
      # clauses. Pattern: `is_nil(@axis) or "X" in @axis`.
      null_check?(left) and right_clauses != [] ->
        acc ++ right_clauses

      null_check?(right) and left_clauses != [] ->
        acc ++ left_clauses

      same_axis_fused != :different_axes ->
        acc ++ same_axis_fused

      # Cross-axis OR — can't AND-represent. Skip.
      true ->
        acc
    end
  end

  # `"X" in @axis`
  defp walk({:in, _, [literal, {:@, _, [{axis, _, ctx}]}]}, acc)
       when is_atom(axis) and (is_atom(ctx) or is_nil(ctx)) do
    case literal_value(literal) do
      {:ok, value} -> [%{"axis" => Atom.to_string(axis), "values" => [value]} | acc]
      :error -> acc
    end
  end

  # `@axis in ["X", "Y", …]`
  defp walk({:in, _, [{:@, _, [{axis, _, ctx}]}, list_ast]}, acc)
       when is_atom(axis) and (is_atom(ctx) or is_nil(ctx)) do
    case literal_list(list_ast) do
      {:ok, values} when values != [] ->
        [%{"axis" => Atom.to_string(axis), "values" => values} | acc]

      _ ->
        acc
    end
  end

  # `is_nil(@axis)` alone — no value constraint, ignored.
  defp walk({:is_nil, _, [{:@, _, [{_axis, _, _}]}]}, acc), do: acc

  # `not A` — can't represent negation as positive clause; ignore.
  defp walk({:not, _, [_]}, acc), do: acc

  # `(parens)` group
  defp walk({:__block__, _, [inner]}, acc), do: walk(inner, acc)
  defp walk({:., _, _}, acc), do: acc

  # Anything else — ignore (better to keep the helper than to
  # mis-classify it).
  defp walk(_other, acc), do: acc

  ## ── helpers

  defp null_check?({:is_nil, _, [{:@, _, [{_, _, _}]}]}), do: true
  defp null_check?(_), do: false

  defp literal_value(v) when is_binary(v) or is_number(v) or is_boolean(v) or is_atom(v),
    do: {:ok, v}

  defp literal_value(_), do: :error

  defp literal_list(list) when is_list(list) do
    values = Enum.map(list, &literal_value/1)

    if Enum.all?(values, &match?({:ok, _}, &1)) do
      {:ok, Enum.map(values, fn {:ok, v} -> v end)}
    else
      :error
    end
  end

  defp literal_list(_), do: :error

  # OR of two clause lists where BOTH are single-clause + same axis:
  # merge their values into one clause. Anything else returns
  # `:different_axes`.
  defp fuse_same_axis_or([%{"axis" => a, "values" => l_vals}], [
         %{"axis" => a, "values" => r_vals}
       ]) do
    [%{"axis" => a, "values" => Enum.uniq(l_vals ++ r_vals)}]
  end

  defp fuse_same_axis_or(_, _), do: :different_axes

  # Same-axis clauses produced by different wrapping `<%= if %>` (AND
  # semantics) get merged by intersecting their value sets — both
  # conditions must hold.
  defp merge_same_axis(clauses) do
    clauses
    |> Enum.group_by(& &1["axis"])
    |> Enum.map(fn {axis, group} ->
      values =
        group
        |> Enum.map(& &1["values"])
        |> Enum.reduce(fn current, acc -> intersect(acc, current) end)

      %{"axis" => axis, "values" => values}
    end)
    |> Enum.reject(fn %{"values" => v} -> v == [] end)
  end

  defp intersect(a, b), do: a |> Enum.filter(&(&1 in b))
end
