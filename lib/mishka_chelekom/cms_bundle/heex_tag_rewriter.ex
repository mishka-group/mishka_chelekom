defmodule MishkaChelekom.CmsBundle.HeexTagRewriter do
  @moduledoc """
  Rewrite HEEx component tag references in a template body. Given a
  `~H""" """` template string, a set of sibling-function names, and a
  kit name, every occurrence of:

      <.NAME ... />        → <.component component_name="<kit>-<NAME-slug>" .../>
      <.NAME ...>...</.NAME>
                           → opening rewritten as above; closing
                             `</.NAME>` rewritten to `</.component>`

  Other constructs (HTML tags, EEx interpolations, string literals,
  HTML comments, `phx-no-curly-interpolation` regions, slot syntax)
  are left untouched.

  ## Strategy

  Tokenize via `MishkaChelekom.CmsBundle.HeexTokenStream`, walk the
  token stream, and emit either the original verbatim source (sliced
  via `MishkaChelekom.CmsBundle.SourceSlicer`) or a rewritten
  replacement for sibling tags. The tokenizer handles:

    * Attribute string boundaries (`<.foo>` inside `class="x<.foo>"`)
    * EEx delimiters (`<%= … %>`, `<%-- … --%>`)
    * Self-closing semantics (`<.icon/>` vs `<.icon></.icon>`)
    * Slot syntax (`<:inner_block>`)
    * `{ … }` interpolations on attributes

  ## Rewrite shape

  Sibling opens become:

      <.component component_name="<kit>-<slug>" site={assigns[:site]} ATTRS… />

  Sibling closes become `</.component>`.

  `assigns[:site]` (Access protocol) is used instead of `@site` so
  siblings called from inside private helpers / slot inner_blocks
  don't crash with `KeyError` on the missing `:site` assign — the
  Access form returns `nil`, and the runtime helper coerces `nil` →
  "Global".

  Falls back to returning the input unchanged on parse failure so a
  half-broken kit doesn't crash the export pipeline.
  """

  alias MishkaChelekom.CmsBundle.{HeexTokenStream, SourceSlicer}

  @type sibling_set :: MapSet.t(String.t())

  @doc """
  Rewrite a template string. No-op when `siblings` is empty or when
  the template contains no rewritable references.
  """
  @spec rewrite(String.t() | nil, sibling_set(), String.t()) :: String.t() | nil
  def rewrite(nil, _siblings, _kit), do: nil
  def rewrite("", _siblings, _kit), do: ""

  def rewrite(template, siblings, kit_name) when is_binary(template) do
    if MapSet.size(siblings) == 0 do
      template
    else
      case HeexTokenStream.tokenize(template, file: "rewriter") do
        {:ok, tokens} ->
          do_rewrite(template, tokens, siblings, kit_name)

        {:error, _msg} ->
          template
      end
    end
  end

  defp do_rewrite(source, tokens, siblings, kit_name) do
    table = SourceSlicer.build(source)

    {replacements, _} =
      Enum.flat_map_reduce(tokens, source, fn token, _ ->
        case token do
          {:local_component, name, _attrs, meta} ->
            cond do
              MapSet.member?(siblings, name) ->
                {[{open_range(meta), open_replacement(name, kit_name)}], nil}

              true ->
                {[], nil}
            end

          {:close, :local_component, name, meta} ->
            cond do
              MapSet.member?(siblings, name) ->
                {[{close_range(meta), "</.component>"}], nil}

              true ->
                {[], nil}
            end

          _ ->
            {[], nil}
        end
      end)

    apply_replacements(source, table, replacements)
  end

  # Replacements are non-overlapping (open vs close are far apart, and
  # we only rewrite siblings — never overlap between siblings). Sort
  # by start position and splice from end to start so earlier ranges'
  # offsets stay valid.
  defp apply_replacements(source, table, replacements) do
    sorted =
      Enum.sort_by(replacements, fn {%{from: from}, _} ->
        {from.line, from.column}
      end)

    [last_byte, parts] =
      Enum.reduce(sorted, [byte_size(source), []], fn {%{from: from, to: to}, replacement},
                                                      [_cursor, parts] ->
        from_byte = byte_offset(table, from.line, from.column)
        to_byte = byte_offset(table, to.line, to.column)
        [from_byte, [{from_byte, to_byte, replacement} | parts]]
      end)

    _ = last_byte

    # Build output left-to-right by interleaving original slices with
    # replacements.
    parts
    |> Enum.reverse()
    |> Enum.reduce({0, []}, fn {from_b, to_b, replacement}, {cursor, acc} ->
      head = binary_part(source, cursor, from_b - cursor)
      {to_b, [replacement, head | acc]}
    end)
    |> case do
      {cursor, acc} ->
        tail = binary_part(source, cursor, byte_size(source) - cursor)
        Enum.reverse([tail | acc]) |> IO.iodata_to_binary()
    end
  end

  defp byte_offset(table, line, column) do
    elem(table, line - 1) + (column - 1)
  end

  # Open-tag range: from `<` to the byte right after the start-tag's
  # name + attrs (i.e. right before the `>` or `/>`). We replace that
  # *prefix*, leaving the `>` / `/>` and any later `attrs` untouched
  # — but here `attrs` of the original would have been re-tokenized
  # already, so the replacement includes everything up to (but not
  # including) the original tag's `>` or `/>`.
  #
  # Simpler: replace just the head `<.NAME` (no attrs) with
  # `<.component component_name="…" site={assigns[:site]}` and let the
  # rest of the original tag (attrs + `>` or `/>`) flow through.
  defp open_range(meta) do
    %{
      from: %{line: meta.line, column: meta.column},
      to: %{
        line: meta.line,
        column: meta.column + byte_size("<#{meta.tag_name}")
      }
    }
  end

  defp close_range(meta) do
    %{
      from: %{line: meta.line, column: meta.column},
      to: %{
        line: meta.line,
        column: meta.column + byte_size("</#{meta.tag_name}>")
      }
    }
  end

  defp open_replacement(name, kit_name) do
    target = kit_name <> "-" <> slug(name)
    ~s|<.component component_name="#{target}" site={assigns[:site]}|
  end

  defp slug(name), do: name |> String.downcase() |> String.replace("_", "-")
end
