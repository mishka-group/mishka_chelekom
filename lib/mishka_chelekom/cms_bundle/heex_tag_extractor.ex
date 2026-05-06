defmodule MishkaChelekom.CmsBundle.HeexTagExtractor do
  @moduledoc """
  Extract top-level chelekom-component invocations from a HEEx demo
  file. Each result is a complete `<.X ...>...</.X>` (or self-closing
  `<.X .../>`) **verbatim source-text snippet** whose name is in the
  kit's component set, plus its source line.

  ## Strategy

  Tokenize the raw source via `MishkaChelekom.CmsBundle.HeexTokenStream`
  (the official `EEx.tokenize` + `Phoenix.LiveView.Tokenizer`
  composition) and walk the token stream maintaining an open-tag
  stack:

    * `:local_component` whose name is in `kit_components` and is at
      the top level (stack is empty of other components) — record its
      start position.
    * `:close :local_component` matching that name — record end
      position, slice the original source between them.
    * Self-closing components (`closing: :self`) — emit immediately.
    * Any other tag (`:tag`, `:remote_component`, `:slot`) — push/pop
      onto the stack so we know when we're inside a non-kit container.
    * Enclosing `:for=` / `:if=` directives on ancestor `:tag` /
      component nodes — captured and used to *re-wrap* the snippet so
      it renders self-contained.

  ## Why a token stream?

  The previous version used a hand-rolled byte-level scanner. The
  tokenizer-based version inherits HEEx's real grammar:

    * HTML attribute string boundaries (a literal `<.X>` inside
      `class="…<.X>…"` is no longer extracted).
    * EEx delimiters (`<%= … %>`, `<%-- … --%>`) — handled by
      `EEx.tokenize` upstream.
    * Self-closing semantics (`<.icon/>` vs `<.icon></.icon>`).
    * Slot syntax (`<:inner_block>`).

  A parse error returns `[]` — the caller is expected to surface
  errors via `mix mishka.ui.verify` rather than have export crash.

  ## Output

      %{component: "shape", source: "<.shape variant=\\"x\\"/>", line: 32}
  """

  alias MishkaChelekom.CmsBundle.{HeexTokenStream, SourceSlicer}

  @type extraction :: %{component: String.t(), source: String.t(), line: pos_integer()}

  @doc """
  Walk `text`, extract every top-level invocation whose tag name is in
  `kit_components`. Returns extractions in source order.
  """
  @spec extract(String.t() | nil, MapSet.t(String.t())) :: [extraction()]
  def extract(nil, _kit_components), do: []
  def extract("", _kit_components), do: []

  def extract(text, kit_components) when is_binary(text) do
    cond do
      MapSet.size(kit_components) == 0 ->
        []

      true ->
        case HeexTokenStream.tokenize(text, file: "extractor") do
          {:ok, tokens} ->
            offset_table = SourceSlicer.build(text)
            walk(tokens, text, offset_table, kit_components, [], [])

          {:error, _msg} ->
            []
        end
    end
  end

  # State carried through the walker:
  #   stack — list of `{kind, name, attrs, meta}` of currently-open tags,
  #           innermost first.
  #   acc   — list of completed extractions (reversed at the end).
  #
  # We only emit an extraction when popping a `:local_component` whose
  # name is in `kit` and which sat at the *outer* edge of any kit
  # component on the stack — i.e. nested kit calls inside an already-
  # captured kit call don't get a separate row.

  defp walk([], _src, _table, _kit, _stack, acc), do: Enum.reverse(acc)

  # Self-closing component (`<.X .../>`) — never pushed; emit immediately
  # if it's at the top level (no enclosing kit component on the stack).
  defp walk(
         [{:local_component, name, _attrs, %{closing: :self} = meta} | rest],
         src,
         table,
         kit,
         stack,
         acc
       ) do
    if MapSet.member?(kit, name) and not inside_kit_component?(stack, kit) do
      {from, to} = self_closing_bounds(meta)
      base_snippet = SourceSlicer.slice!(src, table, from: from, to: to)
      snippet = wrap_with_ancestors(base_snippet, stack)

      extraction = %{component: name, source: snippet, line: meta.line}
      walk(rest, src, table, kit, stack, [extraction | acc])
    else
      walk(rest, src, table, kit, stack, acc)
    end
  end

  # Open `:local_component` / `:remote_component` / `:tag` / `:slot` —
  # push onto the stack with its start meta + attrs so a later
  # `:close` can locate the slicing range AND we can inspect ancestor
  # `:for=` / `:if=` directives when emitting.
  defp walk([{kind, name, attrs, meta} | rest], src, table, kit, stack, acc)
       when kind in [:local_component, :remote_component, :tag, :slot] do
    walk(rest, src, table, kit, [{kind, name, attrs, meta} | stack], acc)
  end

  # Closing tag — pop the matching frame off the stack, and if it was a
  # top-level kit component, slice + emit.
  defp walk([{:close, kind, name, close_meta} | rest], src, table, kit, stack, acc)
       when kind in [:local_component, :remote_component, :tag, :slot] do
    case pop_matching(stack, kind, name) do
      {{^kind, ^name, _attrs, open_meta}, rest_stack} ->
        cond do
          kind == :local_component and MapSet.member?(kit, name) and
              not inside_kit_component?(rest_stack, kit) ->
            from = %{line: open_meta.line, column: open_meta.column}
            to = close_end(close_meta)
            base_snippet = SourceSlicer.slice!(src, table, from: from, to: to)
            snippet = wrap_with_ancestors(base_snippet, rest_stack)

            extraction = %{component: name, source: snippet, line: open_meta.line}
            walk(rest, src, table, kit, rest_stack, [extraction | acc])

          true ->
            walk(rest, src, table, kit, rest_stack, acc)
        end

      :no_match ->
        # Stray close — keep walking without modifying the stack.
        walk(rest, src, table, kit, stack, acc)
    end
  end

  # `:eex`, `:eex_comment`, `:text` — stack-neutral.
  defp walk([_other | rest], src, table, kit, stack, acc) do
    walk(rest, src, table, kit, stack, acc)
  end

  # Any kit-component on the stack means we're already inside an
  # extracted snippet — nested kit calls don't get a separate row.
  defp inside_kit_component?(stack, kit) do
    Enum.any?(stack, fn
      {:local_component, name, _attrs, _meta} -> MapSet.member?(kit, name)
      _ -> false
    end)
  end

  # Pop until we find the matching open tag (handles unbalanced HTML
  # gracefully — e.g. void elements like `<input>` that the user
  # didn't self-close).
  defp pop_matching(stack, kind, name) do
    case Enum.split_while(stack, fn {k, n, _, _} -> not (k == kind and n == name) end) do
      {_skipped, []} -> :no_match
      {_skipped, [match | rest]} -> {match, rest}
    end
  end

  # `meta.inner_location` is `{line, column}` right AFTER the `>` /
  # `/>` of the tag — i.e. the start of the tag's body, or for a
  # self-closing tag, the byte right after the closing slash-gt.
  # `meta.line` / `meta.column` point to the start of the tag (the
  # `<`).
  defp self_closing_bounds(meta) do
    from = %{line: meta.line, column: meta.column}
    {to_line, to_col} = meta.inner_location
    {from, %{line: to_line, column: to_col}}
  end

  # `:close` token's `line/column` points at the start of `</`. Slice
  # up to and including the `>` by adding `byte_size("</" <> tag_name
  # <> ">")` (where `tag_name` is `.foo` for local components and the
  # bare name for HTML tags / remote components).
  defp close_end(%{line: line, column: col, tag_name: name}) when is_binary(name) do
    %{line: line, column: col + byte_size("</#{name}>")}
  end

  defp close_end(%{line: line, column: col}) do
    %{line: line, column: col}
  end

  # Re-wrap an extracted snippet with any enclosing `:for=` / `:if=`
  # directives so the snippet renders self-contained when fed back
  # into the harness.
  defp wrap_with_ancestors(snippet, stack) do
    ancestors =
      stack
      |> Enum.reverse()
      |> Enum.flat_map(&directive_wrapper/1)

    case ancestors do
      [] ->
        snippet

      pairs ->
        opens = Enum.map_join(pairs, "", fn {open, _close} -> open end)

        closes =
          pairs |> Enum.reverse() |> Enum.map_join("", fn {_open, close} -> close end)

        opens <> snippet <> closes
    end
  end

  # Build the open/close text pair for an ancestor element. Only
  # ancestors carrying a `:for=` / `:if=` directive contribute — a
  # plain `<div>` adds no rendering meaning to the wrapped snippet.
  defp directive_wrapper({kind, name, attrs, _meta}) do
    case directive_attrs(attrs) do
      [] ->
        []

      directives ->
        directive_text = Enum.map_join(directives, " ", fn {k, v} -> "#{k}={#{v}}" end)

        tag_name =
          case kind do
            :local_component -> "." <> name
            _ -> name
          end

        [{"<#{tag_name} #{directive_text}>", "</#{tag_name}>"}]
    end
  end

  defp directive_attrs(attrs) do
    Enum.flat_map(attrs, fn
      {":" <> _ = key, {:expr, value, _meta}, _} -> [{key, value}]
      _ -> []
    end)
  end
end
