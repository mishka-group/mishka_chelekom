defmodule MishkaChelekom.CmsBundle.Discriminators do
  @moduledoc """
  Convert chelekom `.eex` source into per-helper **axis-value clauses**
  that the MishkaCMS installer uses to narrow installs (e.g. base-only)
  without guessing positional-arg semantics.

  Two conceptual stages, exposed as one combined surface plus a few
  primitives:

    1. **Index build** (`build_index/1`) — walk the raw `.eex`,
       identify every `defp NAME(args) do` declaration, and record the
       enclosing `<%= if … do %>` chain. Innermost wrapper comes LAST
       in the list so the consumer ANDs them.

    2. **Clause conversion** (`from_conditions/1`) — convert a list of
       condition ASTs into a flat `[%{"axis" => …, "values" => [...]}]`
       list the installer can apply directly.

  Both stages use real parsers — `EEx.tokenize/1` for the template,
  `Code.string_to_quoted/1` + `Macro.prewalk/3` for `defp` discovery
  and condition shapes — so the chain is predictable and resilient
  to whitespace / comment / paren noise.

  ## Why

  Chelekom's `.eex` source uses gating like:

      <%= if "base" in @variant and ("red" in @color or "black" in @color) do %>
        defp color_variant("base", "red"),   do: "..."
        defp color_variant("base", "black"), do: "..."
      <% end %>

  The exporter EEx-evals the template with all options enabled, so the
  bundle's `helpers[]` array contains the wrapped defps without their
  wrapping context. This module recovers the context by re-parsing
  the **raw .eex** (without evaluating).

  ## Recognised condition shapes

      "X" in @axis                    → [{axis, [X]}]
      @axis in [X, Y]                 → [{axis, [X, Y]}]
      "X" in @axis or "Y" in @axis    → [{axis, [X, Y]}]
      is_nil(@axis) or "X" in @axis   → [{axis, [X]}]   (is_nil branch
                                         is "no filter applied", so
                                         when the user DOES filter,
                                         only the value path matters)
      A and B                         → discriminators(A) ++ discriminators(B)
      not A                           → ignored
      everything else                 → ignored

  When the same axis appears in multiple ANDed wrappers (different
  `<%= if %>` blocks), value sets are **intersected** — both
  conditions must hold.
  """

  @type condition_ast :: Macro.t()
  @type signature :: {String.t(), String.t()}
  @type index :: %{required(signature()) => [condition_ast()]}
  @type axis_clause :: %{required(String.t()) => any()}

  ## ─── index build ───────────────────────────────────────────────────

  @doc """
  Parse `eex_source` and return the helper-condition index.

      %{{helper_name, normalized_arg_pattern} => [condition_ast, ...]}

  Returns `%{}` on tokenization or parse failure (caller should fall
  back to un-discriminated emission).
  """
  @spec build_index(String.t()) :: index()
  def build_index(eex_source) when is_binary(eex_source) do
    case EEx.tokenize(eex_source, []) do
      {:ok, tokens} -> walk_index(tokens, [], %{})
      {:error, _, _, _} -> %{}
      {:error, _} -> %{}
    end
  rescue
    _ -> %{}
  catch
    _, _ -> %{}
  end

  defp walk_index([], _stack, acc), do: acc
  defp walk_index([{:eof, _} | _], _stack, acc), do: acc

  defp walk_index([{:start_expr, _marker, chars, _meta} | rest], stack, acc) do
    cond_ast =
      case extract_if_condition(chars) do
        {:ok, ast} -> ast
        :not_an_if -> nil
      end

    walk_index(rest, [cond_ast | stack], acc)
  end

  defp walk_index([{:middle_expr, _marker, _chars, _meta} | rest], stack, acc) do
    walk_index(rest, stack, acc)
  end

  defp walk_index([{:end_expr, _marker, _chars, _meta} | rest], stack, acc) do
    walk_index(rest, tl_safe(stack), acc)
  end

  defp walk_index([{:expr, _marker, _chars, _meta} | rest], stack, acc) do
    walk_index(rest, stack, acc)
  end

  defp walk_index([{:text, chars, _meta} | rest], stack, acc) do
    text = List.to_string(chars)

    new_acc =
      text
      |> find_defps()
      |> Enum.reduce(acc, fn {name, args}, a ->
        Map.update(a, {name, args}, conditions_from(stack), fn existing ->
          existing ++ conditions_from(stack)
        end)
      end)

    walk_index(rest, stack, new_acc)
  end

  defp walk_index([_other | rest], stack, acc), do: walk_index(rest, stack, acc)

  defp tl_safe([]), do: []
  defp tl_safe([_ | t]), do: t

  defp conditions_from(stack), do: stack |> Enum.reject(&is_nil/1) |> Enum.reverse()

  # `:start_expr` always opens a `do … end` block. Append `ok end` to
  # parse the fragment as a complete block, then pattern-match
  # `if cond do ok end`. `for`/`cond`/`case` etc. fall through to
  # `:not_an_if` and contribute no condition (the frame still pushes
  # a `nil` so depth stays aligned).
  defp extract_if_condition(chars) do
    expr = chars |> List.to_string() |> String.trim()

    case Code.string_to_quoted("#{expr} ok end") do
      {:ok, {:if, _, [cond_ast, _opts]}} -> {:ok, cond_ast}
      _ -> :not_an_if
    end
  rescue
    _ -> :not_an_if
  catch
    _, _ -> :not_an_if
  end

  # Find every `defp NAME(ARGS), do: …` and `defp NAME(ARGS) do … end`
  # in `text` via `Code.string_to_quoted/1` + `Macro.prewalk/3`.
  #
  # `text` is a raw EEx text segment, which may be ordinary template prose rather than Elixir code
  # (e.g. demo copy containing apostrophes like "ya'll"/"we'll", which the parser reads as a `'…'`
  # charlist). We only want the `defp` AST, so we parse inside `Code.with_diagnostics/1` and discard
  # the diagnostics — otherwise those spurious deprecation/parse warnings leak to stderr during export.
  defp find_defps(text) do
    {result, _diagnostics} =
      Code.with_diagnostics(fn ->
        case Code.string_to_quoted(text, file: "eex_text") do
          {:ok, ast} -> collect_defps(ast)
          {:error, _} -> []
        end
      end)

    result
  rescue
    _ -> []
  catch
    _, _ -> []
  end

  defp collect_defps(ast) do
    {_, defps} =
      Macro.prewalk(ast, [], fn
        {:defp, _, [head | _]} = node, acc ->
          case extract_head(head) do
            {:ok, name, args} -> {node, [{name, normalize_args(args)} | acc]}
            :not_a_defp -> {node, acc}
          end

        node, acc ->
          {node, acc}
      end)

    Enum.reverse(defps)
  end

  # `head` shapes:
  #   {name, _, [arg1, arg2, ...]}              — `defp foo(a, b)`
  #   {:when, _, [{name, _, args}, _guard]}     — `defp foo(a) when …`
  #   {name, _, nil}                            — older zero-arg form
  defp extract_head({:when, _, [inner, _guard]}), do: extract_head(inner)

  defp extract_head({name, _, args}) when is_atom(name) and is_list(args) do
    {:ok, to_string(name), args_to_string(args)}
  end

  defp extract_head({name, _, nil}) when is_atom(name) do
    {:ok, to_string(name), ""}
  end

  defp extract_head(_), do: :not_a_defp

  defp args_to_string([]), do: ""
  defp args_to_string(args), do: Enum.map_join(args, ", ", &Macro.to_string/1)

  @doc """
  Collapse whitespace in an argument-list string + trim. Both this
  module and the exporter call this on their respective sources so
  `(name, args)` signatures match exactly.
  """
  @spec normalize_args(String.t()) :: String.t()
  def normalize_args(args) when is_binary(args) do
    args
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end

  ## ─── condition AST → axis clauses ──────────────────────────────────

  @doc """
  Convert a list of condition ASTs into a flat list of axis clauses.
  Same-axis clauses produced by different conditions are MERGED via
  intersection (AND semantics — both wrappers must pass).
  """
  @spec from_conditions([condition_ast()]) :: [axis_clause()]
  def from_conditions(conditions) when is_list(conditions) do
    conditions
    |> Enum.flat_map(&from_condition/1)
    |> merge_same_axis()
  end

  @doc """
  Convert a single condition AST into a flat list of axis clauses.
  """
  @spec from_condition(condition_ast()) :: [axis_clause()]
  def from_condition(ast), do: walk_clauses(ast, [])

  # `A and B` — both must hold; concat clauses.
  defp walk_clauses({:and, _, [left, right]}, acc) do
    acc
    |> then(&walk_clauses(left, &1))
    |> then(&walk_clauses(right, &1))
  end

  # `A or B` — same-axis OR fuses values; cross-axis OR is too coarse
  # to represent as ANDed clauses, so we keep both sides only when
  # they reduce to the same axis. Mixed-axis OR yields no clauses
  # (conservatively unfilterable).
  defp walk_clauses({:or, _, [left, right]}, acc) do
    left_clauses = walk_clauses(left, [])
    right_clauses = walk_clauses(right, [])

    same_axis_fused = fuse_same_axis_or(left_clauses, right_clauses)

    cond do
      null_check?(left) and right_clauses != [] ->
        acc ++ right_clauses

      null_check?(right) and left_clauses != [] ->
        acc ++ left_clauses

      same_axis_fused != :different_axes ->
        acc ++ same_axis_fused

      true ->
        acc
    end
  end

  # `"X" in @axis`
  defp walk_clauses({:in, _, [literal, {:@, _, [{axis, _, ctx}]}]}, acc)
       when is_atom(axis) and (is_atom(ctx) or is_nil(ctx)) do
    case literal_value(literal) do
      {:ok, value} -> [%{"axis" => Atom.to_string(axis), "values" => [value]} | acc]
      :error -> acc
    end
  end

  # `@axis in ["X", "Y", …]`
  defp walk_clauses({:in, _, [{:@, _, [{axis, _, ctx}]}, list_ast]}, acc)
       when is_atom(axis) and (is_atom(ctx) or is_nil(ctx)) do
    case literal_list(list_ast) do
      {:ok, values} when values != [] ->
        [%{"axis" => Atom.to_string(axis), "values" => values} | acc]

      _ ->
        acc
    end
  end

  defp walk_clauses({:is_nil, _, [{:@, _, [{_axis, _, _}]}]}, acc), do: acc
  defp walk_clauses({:not, _, [_]}, acc), do: acc
  defp walk_clauses({:__block__, _, [inner]}, acc), do: walk_clauses(inner, acc)
  defp walk_clauses({:., _, _}, acc), do: acc
  defp walk_clauses(_other, acc), do: acc

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

  defp fuse_same_axis_or(
         [%{"axis" => a, "values" => l_vals}],
         [%{"axis" => a, "values" => r_vals}]
       ) do
    [%{"axis" => a, "values" => Enum.uniq(l_vals ++ r_vals)}]
  end

  defp fuse_same_axis_or(_, _), do: :different_axes

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

  defp intersect(a, b), do: Enum.filter(a, &(&1 in b))
end
