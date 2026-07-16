defmodule MishkaChelekom.CmsBundle.Sanitize do
  @moduledoc """
  Make a harvested snippet renderable with empty assigns.

  Docs snippets are written to run inside a LiveView that has already
  mounted: they lean on `~p"…"` routes and on assigns from `mount/3`
  (`{@posts.total}`, `{@csp_nonce}`). The bundle consumer has neither a
  router nor those assigns, so every such reference is resolved here —
  routes to their literal path, assigns to the literal value the demo's
  own `mount/3` gave them — and whatever still cannot be resolved is
  reported by `self_contained?/1` so the caller can drop it.

  Resolving rather than rejecting is the point: `chelekom-pagination`
  harvests 111 snippets and every one of them mentions `{@posts.total}`.

  Expression rewriting goes through `Sourceror`, not string
  substitution — a `}` inside a string literal, a heredoc sigil, or a
  sigil nested in a larger expression all break a character scanner.
  """

  @doc """
  Normalize one snippet: inline `assigns`, resolve `~p` routes, pin
  `site` to `"Global"`, drop leftover `:if` wrappers, and flatten to a
  single line.
  """
  @spec normalize(String.t() | nil, map()) :: String.t()
  def normalize(source, assigns \\ %{})

  def normalize(source, assigns) when is_binary(source) do
    source
    |> String.replace("site={assigns[:site]}", ~s(site="Global"))
    |> String.replace("site={@site}", ~s(site="Global"))
    |> String.replace("site={assigns.site}", ~s(site="Global"))
    |> rewrite_exprs(assigns)
    |> strip_if_attrs()
    |> collapse_whitespace()
    |> String.trim()
  end

  def normalize(_source, _assigns), do: ""

  @doc """
  True when every `{…}` in the snippet is a literal term, i.e. the
  snippet renders with no assigns at all.
  """
  @spec self_contained?(String.t()) :: boolean()
  def self_contained?(""), do: false
  def self_contained?(source) when is_binary(source), do: all_exprs_literal?(source)
  def self_contained?(_), do: false

  # Wrapper conditionals left over from interactive demos.
  defp strip_if_attrs(source), do: Regex.replace(~r/\s*:if=\{[^}]*\}/, source, "")

  # Whitespace between tags/attrs is insignificant in HEEx; one tidy line.
  defp collapse_whitespace(source), do: Regex.replace(~r/\s+/, source, " ")

  ## ─── expression rewriting ──────────────────────────────────────────

  defp rewrite_exprs(text, assigns), do: text |> walk(assigns, []) |> IO.iodata_to_binary()

  defp walk("", _assigns, acc), do: Enum.reverse(acc)

  # EEx blocks carry their own sentinels and are docs scaffolding, not
  # runtime references — copy them through untouched.
  defp walk("<%!" <> rest, assigns, acc), do: copy_until(rest, "%>", "<%!", assigns, acc)
  defp walk("<%=" <> rest, assigns, acc), do: copy_until(rest, "%>", "<%=", assigns, acc)
  defp walk("<%" <> rest, assigns, acc), do: copy_until(rest, "%>", "<%", assigns, acc)

  defp walk("{" <> rest, assigns, acc) do
    case take_balanced(rest, 1, []) do
      {:ok, expr, rest_after} ->
        rewritten = transform(IO.iodata_to_binary(expr), assigns)
        walk(rest_after, assigns, ["}", rewritten, "{" | acc])

      :unbalanced ->
        walk(rest, assigns, ["{" | acc])
    end
  end

  defp walk(<<char::utf8, rest::binary>>, assigns, acc),
    do: walk(rest, assigns, [<<char::utf8>> | acc])

  defp copy_until(rest, delim, prefix, assigns, acc) do
    case :binary.split(rest, delim) do
      [block, after_block] -> walk(after_block, assigns, [delim, block, prefix | acc])
      [_unsplit] -> walk("", assigns, [rest, prefix | acc])
    end
  end

  # Returns the original source on parse failure — never corrupt input
  # we do not understand.
  defp transform(code, assigns) do
    case Sourceror.parse_string(code) do
      {:ok, ast} ->
        new_ast = Macro.prewalk(ast, &resolve(&1, assigns))
        if new_ast == ast, do: code, else: Sourceror.to_string(new_ast)

      {:error, _} ->
        code
    end
  rescue
    _ -> code
  end

  # `~p"/path"` with no interpolation. An interpolated path has no
  # value at export time and is left alone.
  defp resolve({:sigil_p, _, [{:<<>>, _, [path]}, _]}, _assigns) when is_binary(path), do: path

  # `@posts.total` — matched before bare `@posts` because prewalk visits
  # the outer node first.
  defp resolve({{:., _, [{:@, _, [{name, _, nil}]}, key]}, _, []} = node, assigns)
       when is_atom(name) and is_atom(key) do
    fetch(assigns, [name, key], node)
  end

  defp resolve({:@, _, [{name, _, nil}]} = node, assigns) when is_atom(name) do
    fetch(assigns, [name], node)
  end

  defp resolve({{:., _, [Access, :get]}, _, [{:assigns, _, nil}, key]} = node, assigns)
       when is_atom(key) do
    fetch(assigns, [key], node)
  end

  defp resolve(node, _assigns), do: node

  defp fetch(assigns, path, node) do
    case get_in_safe(assigns, path) do
      {:ok, value} -> Macro.escape(value)
      :error -> node
    end
  end

  defp get_in_safe(value, []), do: {:ok, value}

  defp get_in_safe(%{} = map, [key | rest]) when not is_struct(map) do
    case Map.fetch(map, key) do
      {:ok, value} -> get_in_safe(value, rest)
      :error -> :error
    end
  end

  defp get_in_safe(_, _), do: :error

  ## ─── literal scan ──────────────────────────────────────────────────

  defp all_exprs_literal?(""), do: true

  defp all_exprs_literal?("{" <> rest) do
    case take_balanced(rest, 1, []) do
      {:ok, expr, rest_after} ->
        literal?(IO.iodata_to_binary(expr)) and all_exprs_literal?(rest_after)

      :unbalanced ->
        false
    end
  end

  defp all_exprs_literal?(<<_::utf8, rest::binary>>), do: all_exprs_literal?(rest)

  # `Macro.quoted_literal?/1` accepts nested lists/maps/tuples of
  # literals, so `errors={["oh no!"]}` and `total={10}` both pass while
  # `{@form[:email]}` does not.
  defp literal?(inner) do
    case Sourceror.parse_string(String.trim(inner)) do
      {:ok, ast} -> ast |> strip_meta() |> Macro.quoted_literal?()
      {:error, _} -> false
    end
  rescue
    _ -> false
  end

  # Sourceror wraps every literal in a `:__block__` node carrying
  # formatting metadata; `Macro.quoted_literal?/1` does not know it.
  # A negative number parses as a unary-minus CALL on a positive one,
  # which is not a literal either — fold it. Depth-first so the operand
  # is already unwrapped when the operator is visited.
  defp strip_meta(ast) do
    Macro.postwalk(ast, fn
      {:__block__, _, [literal]} -> literal
      {:-, _, [number]} when is_number(number) -> -number
      node -> node
    end)
  end

  ## ─── brace-balanced slicing (quote aware) ──────────────────────────

  defp take_balanced("", _depth, _acc), do: :unbalanced

  defp take_balanced("\\" <> <<char::utf8, rest::binary>>, depth, acc),
    do: take_balanced(rest, depth, [<<char::utf8>>, "\\" | acc])

  defp take_balanced("\"" <> rest, depth, acc) do
    {str, after_str} = take_until_unescaped(rest, "\"", [])
    take_balanced(after_str, depth, ["\"", str, "\"" | acc])
  end

  defp take_balanced("'" <> rest, depth, acc) do
    {str, after_str} = take_until_unescaped(rest, "'", [])
    take_balanced(after_str, depth, ["'", str, "'" | acc])
  end

  defp take_balanced("{" <> rest, depth, acc), do: take_balanced(rest, depth + 1, ["{" | acc])
  defp take_balanced("}" <> rest, 1, acc), do: {:ok, Enum.reverse(acc), rest}
  defp take_balanced("}" <> rest, depth, acc), do: take_balanced(rest, depth - 1, ["}" | acc])

  defp take_balanced(<<char::utf8, rest::binary>>, depth, acc),
    do: take_balanced(rest, depth, [<<char::utf8>> | acc])

  defp take_until_unescaped("", _delim, acc), do: {Enum.reverse(acc) |> IO.iodata_to_binary(), ""}

  defp take_until_unescaped("\\" <> <<char::utf8, rest::binary>>, delim, acc),
    do: take_until_unescaped(rest, delim, [<<char::utf8>>, "\\" | acc])

  defp take_until_unescaped(<<delim::utf8, rest::binary>>, <<delim::utf8>>, acc),
    do: {Enum.reverse(acc) |> IO.iodata_to_binary(), rest}

  defp take_until_unescaped(<<char::utf8, rest::binary>>, delim, acc),
    do: take_until_unescaped(rest, delim, [<<char::utf8>> | acc])
end
