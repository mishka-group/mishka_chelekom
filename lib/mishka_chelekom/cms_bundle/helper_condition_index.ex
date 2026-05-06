defmodule MishkaChelekom.CmsBundle.HelperConditionIndex do
  @moduledoc """
  Walk a chelekom `.eex` template, identify every `defp NAME(args) do`
  declaration, and record the **enclosing `<%= if … do %>` chain** for
  each one. The exporter uses this index to attach `discriminators` to
  each helper in the v3 bundle so the MishkaCMS installer can safely
  narrow installs (e.g. base-only) without guessing positional-arg
  semantics.

  ## Why

  Chelekom's `.eex` source uses gating like:

      <%= if "base" in @variant and ("red" in @color or "black" in @color) do %>
        defp color_variant("base", "red"), do: "..."
        defp color_variant("base", "black"), do: "..."
      <% end %>

  The exporter EEx-evals the template with all options enabled, so the
  bundle's `helpers[]` array contains the wrapped defps without their
  wrapping context. This module re-tokenises the **raw .eex** (without
  evaluating) to recover that context.

  ## How

  Two real parsers, no string scanning:

    * `EEx.tokenize/1` — gives `:start_expr` / `:end_expr` /
      `:middle_expr` / `:expr` / `:text` tokens. We push the parsed
      `if cond do` AST onto a stack on `:start_expr`, pop on
      `:end_expr`.
    * `Code.string_to_quoted/1` on each `:text` chunk — extract every
      `defp NAME(args)` (with or without `do …`/`, do: …`) via AST
      traversal. The original argument-list AST is `Macro.to_string`-d
      and normalised so it round-trips against the exporter's
      `Macro.to_string` of the same arg list.

  ## Output

      %{{helper_name, normalised_arg_pattern} => [condition_ast, ...]}

  Innermost wrapper comes LAST in the list — the consumer ANDs them.

  Returns `%{}` on tokenization or parse failure (caller falls back to
  un-discriminated emission).
  """

  @type condition_ast :: Macro.t()
  @type signature :: {String.t(), String.t()}
  @type index :: %{required(signature()) => [condition_ast()]}

  @doc """
  Parse `eex_source` and return the helper-condition index.
  """
  @spec build(String.t()) :: index()
  def build(eex_source) when is_binary(eex_source) do
    case EEx.tokenize(eex_source, []) do
      {:ok, tokens} -> walk(tokens, [], %{})
      {:error, _, _, _} -> %{}
      {:error, _} -> %{}
    end
  rescue
    _ -> %{}
  catch
    _, _ -> %{}
  end

  defp walk([], _stack, acc), do: acc
  defp walk([{:eof, _} | _], _stack, acc), do: acc

  defp walk([{:start_expr, _marker, chars, _meta} | rest], stack, acc) do
    cond_ast =
      case extract_if_condition(chars) do
        {:ok, ast} -> ast
        :not_an_if -> nil
      end

    walk(rest, [cond_ast | stack], acc)
  end

  defp walk([{:middle_expr, _marker, _chars, _meta} | rest], stack, acc) do
    walk(rest, stack, acc)
  end

  defp walk([{:end_expr, _marker, _chars, _meta} | rest], stack, acc) do
    walk(rest, tl_safe(stack), acc)
  end

  defp walk([{:expr, _marker, _chars, _meta} | rest], stack, acc) do
    walk(rest, stack, acc)
  end

  defp walk([{:text, chars, _meta} | rest], stack, acc) do
    text = List.to_string(chars)

    new_acc =
      text
      |> find_defps()
      |> Enum.reduce(acc, fn {name, args}, a ->
        Map.update(a, {name, args}, conditions_from(stack), fn existing ->
          existing ++ conditions_from(stack)
        end)
      end)

    walk(rest, stack, new_acc)
  end

  defp walk([_other | rest], stack, acc), do: walk(rest, stack, acc)

  defp tl_safe([]), do: []
  defp tl_safe([_ | t]), do: t

  defp conditions_from(stack), do: stack |> Enum.reject(&is_nil/1) |> Enum.reverse()

  # Parse the start_expr body as Elixir source. EEx's `:start_expr`
  # always opens a `do … end` block; appending `ok end` lets us
  # `Code.string_to_quoted/1` the fragment as if it were a complete
  # block. We then pattern-match `if cond do ok end` to extract the
  # condition AST. `for`/`cond`/`case` etc. fall through to
  # `:not_an_if` and contribute nothing.
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
  # in `text`. Uses `Code.string_to_quoted/1` to parse the chunk as
  # Elixir source, then walks the AST collecting `defp` nodes. This
  # replaces the previous hand-rolled balanced-paren scanner.
  defp find_defps(text) do
    case Code.string_to_quoted(text, file: "eex_text") do
      {:ok, ast} -> collect_defps(ast)
      {:error, _} -> []
    end
  rescue
    _ -> []
  catch
    _, _ -> []
  end

  # Walk the AST collecting every `{:defp, _, [head, opts]}` node.
  # Returns `[{name_string, normalized_args_string}, …]` in source
  # order. The argument list is `Macro.to_string`-d; normalisation
  # collapses whitespace so it matches the exporter's `Macro.to_string`
  # of the same arg list.
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
  #
  #   {name, _, [arg1, arg2, ...]}              — `defp foo(a, b)`
  #   {:when, _, [{name, _, args}, _guard]}     — `defp foo(a) when is_x(a)`
  #
  # No-arg defps (`defp foo()`) appear as `{name, _, []}` (Elixir 1.18+)
  # or `{name, _, nil}` (older). Both are handled.
  defp extract_head({:when, _, [inner, _guard]}), do: extract_head(inner)

  defp extract_head({name, _, args}) when is_atom(name) and is_list(args) do
    {:ok, to_string(name), args_to_string(args)}
  end

  defp extract_head({name, _, nil}) when is_atom(name) do
    {:ok, to_string(name), ""}
  end

  defp extract_head(_), do: :not_a_defp

  defp args_to_string([]), do: ""

  defp args_to_string(args) do
    args |> Enum.map(&Macro.to_string/1) |> Enum.join(", ")
  end

  @doc """
  Normalise a string argument-list — collapse whitespace, drop
  leading/trailing space. Both this index and the exporter call this
  on their respective sources so signatures match exactly.
  """
  @spec normalize_args(String.t()) :: String.t()
  def normalize_args(args) when is_binary(args) do
    args
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end
