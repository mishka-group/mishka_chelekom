defmodule MishkaChelekom.CmsBundle.DocsPage do
  @moduledoc """
  Harvest the curated, per-section snippets from a vendored docs page
  pair (`<comp>_live.ex` + `<comp>_live.html.heex`).

  A docs page renders each example twice, from two independent sources:
  the `<.custom_code_wrapper>` inner block is the *live demo*, and its
  `code={@code_N}` attr is the *snippet shown to the reader*. Only the
  latter is curated — the inner block carries page scaffolding (the
  `variant="outline"` trigger button in front of every `modal`/`drawer`/
  `toast`/`banner` demo is the common case), so reading attrs off the
  markup mis-attributes roughly one section in five. `@code_N` resolves
  to a `defp code_string(N)` heredoc in the sibling `.ex`, which is
  exactly the invocation and nothing else.

  Each snippet is tagged with the `<.heading2>`/`<.heading3>` section it
  sits under, which is how the docs already partition examples per
  option (`outline-variant-card`, `card-rounded`, `card-padding`).

  The section `id` is recorded but never trusted to name an option —
  ids flip direction (`outline-variant-card` vs `list-outline-variant`),
  use a different word than the prop (`badge-radius` documents
  `rounded`), and carry typos (`combobox-bordred`, `form-checbox-*`).
  Callers derive requirements from the snippet's real attrs instead.
  """

  alias MishkaChelekom.CmsBundle.Heex

  @heading_tags ~w(heading2 heading3)
  @wrapper "custom_code_wrapper"

  @type example :: %{source: String.t(), section: String.t() | nil, label: String.t() | nil}

  @doc """
  Curated snippets for one docs page, in page order.

  `ex_source` supplies the `code_string/1` heredocs; `heex_source`
  supplies the `code={@code_N}` references and their enclosing section.
  Returns `[]` when either side is missing or unparsable.
  """
  @spec examples(String.t() | nil, String.t() | nil) :: [example()]
  def examples(nil, _heex), do: []
  def examples(_ex, nil), do: []

  def examples(ex_source, heex_source) when is_binary(ex_source) and is_binary(heex_source) do
    case code_map(ex_source) do
      map when map_size(map) == 0 ->
        []

      map ->
        case Heex.tokenize(heex_source, file: "docs_page") do
          {:ok, tokens} -> walk(tokens, map, nil, nil, nil, [], [])
          {:error, _} -> []
        end
    end
  end

  ## ─── .ex side: @code_N → code_string(N) heredoc ────────────────────

  @doc false
  @spec code_map(String.t()) :: %{optional(String.t()) => String.t()}
  def code_map(ex_source) do
    case Code.string_to_quoted(ex_source) do
      {:ok, ast} ->
        bodies = code_string_bodies(ast)

        # `assign(code_5: code_string(6))` really happens — never assume
        # the two numbers agree.
        ast
        |> assign_refs()
        |> Enum.flat_map(fn {assign_name, n} ->
          case Map.fetch(bodies, n) do
            {:ok, body} -> [{assign_name, body}]
            :error -> []
          end
        end)
        |> Map.new()

      {:error, _} ->
        %{}
    end
  end

  defp code_string_bodies(ast) do
    {_, acc} =
      Macro.prewalk(ast, %{}, fn
        {:defp, _, [{:code_string, _, [n]}, [do: body]]} = node, acc when is_integer(n) ->
          if is_binary(body), do: {node, Map.put(acc, n, body)}, else: {node, acc}

        node, acc ->
          {node, acc}
      end)

    acc
  end

  defp assign_refs(ast) do
    {_, acc} =
      Macro.prewalk(ast, [], fn
        {:assign, _, [[{key, {:code_string, _, [n]}}]]} = node, acc
        when is_atom(key) and is_integer(n) ->
          {node, [{to_string(key), n} | acc]}

        {:assign, _, [_socket, [{key, {:code_string, _, [n]}}]]} = node, acc
        when is_atom(key) and is_integer(n) ->
          {node, [{to_string(key), n} | acc]}

        {:assign, _, [_socket, key, {:code_string, _, [n]}]} = node, acc
        when is_atom(key) and is_integer(n) ->
          {node, [{to_string(key), n} | acc]}

        node, acc ->
          {node, acc}
      end)

    acc
  end

  ## ─── .heex side: walk sections, resolve code= refs ─────────────────

  defp walk([], _map, _sec, _label, _open, _buf, acc), do: Enum.reverse(acc)

  defp walk([{:local_component, name, attrs, _} | rest], map, sec, label, _open, _buf, acc)
       when name in @heading_tags do
    walk(rest, map, sec, label, string_attr(attrs, "id"), [], acc)
  end

  defp walk([{:close, :local_component, name, _} | rest], map, sec, label, open, buf, acc)
       when name in @heading_tags do
    case open do
      nil -> walk(rest, map, sec, label, nil, [], acc)
      id -> walk(rest, map, id, clean_label(buf), nil, [], acc)
    end
  end

  defp walk([{:text, text, _} | rest], map, sec, label, open, buf, acc) when not is_nil(open) do
    walk(rest, map, sec, label, open, [text | buf], acc)
  end

  defp walk([{:local_component, @wrapper, attrs, _} | rest], map, sec, label, open, buf, acc) do
    acc =
      with {:ok, ref} <- code_ref(attrs),
           {:ok, source} <- Map.fetch(map, ref) do
        [%{source: source, section: sec, label: label} | acc]
      else
        _ -> acc
      end

    walk(rest, map, sec, label, open, buf, acc)
  end

  defp walk([_ | rest], map, sec, label, open, buf, acc) do
    walk(rest, map, sec, label, open, buf, acc)
  end

  # `code={@code_31}` → "code_31". A literal `code="..."` string is not a
  # reference and is left to the fallback sources.
  defp code_ref(attrs) do
    Enum.find_value(attrs, :error, fn
      {"code", {:expr, expr, _}, _} ->
        case Regex.run(~r/^\s*@([a-z_][a-zA-Z0-9_]*)\s*$/, expr) do
          [_, name] -> {:ok, name}
          nil -> :error
        end

      _ ->
        nil
    end)
  end

  defp string_attr(attrs, key) do
    Enum.find_value(attrs, fn
      {^key, {:string, value, _}, _} -> value
      _ -> nil
    end)
  end

  defp clean_label(buf) do
    label =
      buf
      |> Enum.reverse()
      |> Enum.join(" ")
      |> String.replace(~r/\s+/, " ")
      |> String.trim()

    if label == "", do: nil, else: label
  end
end
