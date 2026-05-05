defmodule MishkaChelekom.HelperConditionIndex do
  @moduledoc """
  Walks a chelekom `.eex` template, identifies every `defp NAME(args) do`
  declaration, and records the **enclosing `<%= if … do %>` chain**
  for each one. The exporter uses this index to attach
  `discriminators` to each helper in the v3 bundle so the MishkaCMS
  installer can safely narrow installs (e.g. base-only) without
  guessing positional-arg semantics.

  ## Why

  Chelekom's `.eex` source uses gating like:

      <%= if "base" in @variant and ("red" in @color or "black" in @color) do %>
        defp color_variant("base", "red"), do: "..."
        defp color_variant("base", "black"), do: "..."
      <% end %>

  The exporter EEx-evals the template with all options enabled, so the
  bundle's `helpers[]` array contains the wrapped defps without their
  wrapping context. This module re-parses the **raw .eex** (without
  evaluating) to recover that context.

  ## Output

      %{{helper_name, normalized_arg_pattern} => [condition_ast, ...]}

  `condition_ast` is the parsed Elixir AST of the wrapping `if`
  expression. Innermost wrapper comes LAST in the list — the consumer
  ANDs them all together (an inner `<% if %>` only fires when its
  outer ones do).

  ## Algorithm

  1. `EEx.tokenize/1` returns a token stream.
  2. Walk tokens with a **condition stack**:
     - `:start_expr` whose body matches `if … do` — push the `if`
       condition AST onto the stack.
     - `:end_expr` (matching `end`) — pop one entry.
     - `:text` — scan for `defp NAME(args) do`; for each found,
       record the current stack snapshot.
  3. Non-`if` start_expr (`for`, `cond`, `case`) push `nil` so depth
     stays aligned but adds no discriminator.
  """

  @type condition_ast :: Macro.t()
  @type signature :: {String.t(), String.t()}
  @type index :: %{required(signature()) => [condition_ast()]}

  @doc """
  Parse `eex_source` and return the helper-condition index.
  Returns an empty map on tokenization failure (caller falls back to
  un-discriminated emission).
  """
  @spec build(String.t()) :: index()
  def build(eex_source) when is_binary(eex_source) do
    case EEx.tokenize(eex_source, []) do
      {:ok, tokens} -> walk(tokens, [], %{})
      {:error, _, _} -> %{}
    end
  rescue
    _ -> %{}
  end

  defp walk([], _stack, acc), do: acc

  defp walk([{:eof, _} | _], _stack, acc), do: acc

  # `<%= if cond do %>` / `<% if cond do %>`
  defp walk([{:start_expr, _marker, chars, _meta} | rest], stack, acc) do
    expr = chars |> List.to_string() |> String.trim()

    cond_ast =
      case extract_if_condition(expr) do
        {:ok, ast} -> ast
        :not_an_if -> nil
      end

    walk(rest, [cond_ast | stack], acc)
  end

  # `<% else %>`, `<% else if … do %>` etc. — keep the same stack depth.
  defp walk([{:middle_expr, _marker, _chars, _meta} | rest], stack, acc) do
    walk(rest, stack, acc)
  end

  # `<% end %>` — pop one frame.
  defp walk([{:end_expr, _marker, _chars, _meta} | rest], stack, acc) do
    walk(rest, tl_safe(stack), acc)
  end

  # Single expression `<%= … %>` — no scoping change.
  defp walk([{:expr, _marker, _chars, _meta} | rest], stack, acc) do
    walk(rest, stack, acc)
  end

  # Text region — scan for `defp NAME(args) do`.
  defp walk([{:text, chars, _meta} | rest], stack, acc) do
    text = List.to_string(chars)

    new_acc =
      text
      |> find_defps()
      |> Enum.reduce(acc, fn {name, args}, a ->
        Map.update(a, {name, normalize_args(args)}, conditions_from(stack), fn existing ->
          existing ++ conditions_from(stack)
        end)
      end)

    walk(rest, stack, new_acc)
  end

  defp walk([_unhandled | rest], stack, acc) do
    walk(rest, stack, acc)
  end

  defp tl_safe([]), do: []
  defp tl_safe([_ | t]), do: t

  defp conditions_from(stack), do: stack |> Enum.reject(&is_nil/1) |> Enum.reverse()

  # Parse the start_expr body. Recognise `if COND do`. Anything else
  # (`for`, `cond`, `case`, multi-clause `if … else`) is treated as
  # `:not_an_if` — its frame still pushes onto the stack as `nil` so
  # depth stays aligned, but it doesn't contribute discriminators.
  defp extract_if_condition(expr) do
    case Code.string_to_quoted("#{expr} ok end") do
      {:ok, {:if, _, [cond_ast, _opts]}} -> {:ok, cond_ast}
      _ -> :not_an_if
    end
  rescue
    _ -> :not_an_if
  catch
    _, _ -> :not_an_if
  end

  # Find every `defp NAME(ARGS)` (with or without `do`, single-line or
  # multi-line). Returns `[{name_string, args_string}, …]`.
  #
  # Hand-rolled, balanced-paren extraction. Handles:
  #
  #   defp foo("bar", _),        do: "x"
  #   defp foo("bar", _) do … end
  #   defp foo(%{a: 1} = assigns) do
  defp find_defps(text) do
    do_find_defps(text, [])
    |> Enum.reverse()
  end

  defp do_find_defps("", acc), do: acc

  defp do_find_defps("defp " <> rest, acc) do
    case parse_defp_signature(rest) do
      {:ok, name, args, after_sig} ->
        do_find_defps(after_sig, [{name, args} | acc])

      :no_match ->
        do_find_defps(rest, acc)
    end
  end

  defp do_find_defps(<<_::utf8, rest::binary>>, acc), do: do_find_defps(rest, acc)

  defp parse_defp_signature(text) do
    with {:ok, name, after_name} <- take_atom(text),
         after_ws = trim_leading_ws(after_name),
         <<"(", after_paren::binary>> <- after_ws,
         {:ok, args, after_close} <- take_balanced_parens(after_paren, 1, []) do
      {:ok, name, args, after_close}
    else
      _ -> :no_match
    end
  end

  defp take_atom(text), do: take_atom(text, [])

  defp take_atom(<<c::utf8, rest::binary>>, []) when c in ?a..?z or c == ?_ do
    take_atom(rest, [<<c::utf8>>])
  end

  defp take_atom(_, []), do: :no_match

  defp take_atom(<<c::utf8, rest::binary>>, acc)
       when c in ?a..?z or c in ?A..?Z or c in ?0..?9 or c == ?_ or c == ?! or c == ?? do
    take_atom(rest, [<<c::utf8>> | acc])
  end

  defp take_atom(rest, acc) do
    name = acc |> Enum.reverse() |> IO.iodata_to_binary()
    {:ok, name, rest}
  end

  defp take_balanced_parens("", _depth, _acc), do: :no_match

  defp take_balanced_parens(")" <> rest, 1, acc) do
    args = acc |> Enum.reverse() |> IO.iodata_to_binary()
    {:ok, args, rest}
  end

  defp take_balanced_parens(")" <> rest, depth, acc) do
    take_balanced_parens(rest, depth - 1, [")" | acc])
  end

  defp take_balanced_parens("(" <> rest, depth, acc) do
    take_balanced_parens(rest, depth + 1, ["(" | acc])
  end

  defp take_balanced_parens(<<c::utf8, rest::binary>>, depth, acc) do
    take_balanced_parens(rest, depth, [<<c::utf8>> | acc])
  end

  defp trim_leading_ws(<<c, rest::binary>>) when c in [?\s, ?\t, ?\n, ?\r],
    do: trim_leading_ws(rest)

  defp trim_leading_ws(s), do: s

  #
  # The exporter emits a helper's `args` field by `Macro.to_string`-ing
  # the argument AST list. The raw .eex `defp` line has the same
  # arguments but with possibly different whitespace. Normalise both
  # sides: collapse whitespace, drop trailing newlines.
  @doc false
  def normalize_args(args) when is_binary(args) do
    args
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end
