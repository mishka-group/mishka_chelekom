defmodule MishkaChelekom.HeexTagExtractor do
  @moduledoc """
  Extracts top-level chelekom-component invocations from a HEEx demo
  file. Each result is a complete `<.X ...>...</.X>` (or self-closing
  `<.X .../>`) source-text snippet whose name is in the kit's component
  set, plus its source line.

  ## Pipeline

  1. Hand-rolled state-machine scanner walks the binary and identifies
     each top-level chelekom invocation. No regex.
  2. **`Phoenix.LiveView.Tokenizer` enrichment pass** — re-tokenizes
     the source, maintains an open-tag stack, and for each invocation
     captures the most-recent enclosing `:for=`/`:if=` directives.
     The captured `source` is rewritten to include the wrapping tags
     so the snippet is self-contained: `<div :for={s <- …}><.shape
     variant={s}/></div>` becomes the whole wrapper, not just the
     `<.shape>` interior.

  Skip regions:

    * `<!-- ... -->` HTML comments
    * `<% ... %>`, `<%= ... %>`, `<%! ... %>` EEx blocks
    * Double / single quoted attribute strings on outer (non-component)
      tags so a literal `<.foo>` inside a string isn't extracted.

  Nested chelekom calls inside a captured block are NOT extracted as
  separate top-level entries — rendering the outer block exercises
  them. `<.X>` inside an EEx loop body (`<%= for … do %>`) is also
  skipped: those depend on runtime data the demo's `mount/3` provides
  and should be rendered through the demo's host LiveView, not in
  isolation.

  ## Output shape

      %{
        component: "shape",
        source:    "<div :for={s <- ~w(circle hexagon)}><.shape variant={s}/></div>",
        line:      32
      }
  """

  @type extraction :: %{component: String.t(), source: String.t(), line: pos_integer()}

  @doc """
  Walk `text`, extracting every top-level invocation whose tag name is
  in `kit_components`. Returns extractions in source order. When
  `Phoenix.LiveView.Tokenizer` is available, enriches each extraction
  with its enclosing `:for`/`:if` directives so the captured snippet
  is self-contained.
  """
  @spec extract(String.t(), MapSet.t(String.t())) :: [extraction()]
  def extract(nil, _kit_components), do: []
  def extract("", _kit_components), do: []

  def extract(text, kit_components) when is_binary(text) do
    if MapSet.size(kit_components) == 0 do
      []
    else
      raw =
        walk(text, kit_components, 1, [])
        |> Enum.reverse()

      enrich_with_parent_directives(raw, text)
    end
  end

  ## ─── outer scanning loop (top-level text) ──────────────────────────

  defp walk("", _kit, _line, acc), do: acc

  defp walk("<!--" <> rest, kit, line, acc) do
    {block, after_block} = take_until(rest, "-->")
    walk(after_block, kit, line + count_newlines(block) + count_newlines("-->"), acc)
  end

  defp walk("<%!" <> rest, kit, line, acc),
    do: skip_eex(rest, "%>", kit, line + count_newlines("<%!"), acc)

  defp walk("<%=" <> rest, kit, line, acc),
    do: skip_eex(rest, "%>", kit, line + count_newlines("<%="), acc)

  defp walk("<%" <> rest, kit, line, acc),
    do: skip_eex(rest, "%>", kit, line + count_newlines("<%"), acc)

  # Possible chelekom open-tag.
  defp walk("<." <> rest, kit, line, acc) do
    case parse_name(rest) do
      {:found, name, terminator, after_name} ->
        if MapSet.member?(kit, name) do
          # Capture from the `<.` we just consumed. Reconstruct the
          # head ("<.NAME<terminator>") and find the balanced end.
          head = "<." <> name <> <<terminator>>

          case capture_invocation(head, terminator, after_name, name) do
            {:ok, source, after_invocation, lines_consumed} ->
              extraction = %{component: name, source: source, line: line}
              walk(after_invocation, kit, line + lines_consumed, [extraction | acc])

            :unbalanced ->
              # Malformed — bail out for this tag, keep scanning past it.
              walk(after_name, kit, line + count_newlines(head), acc)
          end
        else
          walk(after_name, kit, line + count_newlines("<." <> name <> <<terminator>>), acc)
        end

      :not_a_component ->
        walk(rest, kit, line, acc)
    end
  end

  # Anything else: consume one byte, advance.
  defp walk(<<?\n, rest::binary>>, kit, line, acc), do: walk(rest, kit, line + 1, acc)
  defp walk(<<_::utf8, rest::binary>>, kit, line, acc), do: walk(rest, kit, line, acc)

  ## ─── EEx skip helper ───────────────────────────────────────────────

  defp skip_eex(rest, terminator, kit, line, acc) do
    {block, after_block} = take_until(rest, terminator)
    walk(after_block, kit, line + count_newlines(block) + count_newlines(terminator), acc)
  end

  ## ─── invocation capture (balanced) ─────────────────────────────────

  # `terminator` is the byte that ended `<.NAME<term>` — one of:
  #   `?>`  → tag has no attrs (`<.foo>...`)
  #   `?/`  → self-closing without attrs (`<.foo/>`)
  #   `?\s` / `?\n` / `?\t` → has attrs to follow
  defp capture_invocation(head, terminator, after_terminator, _name) when terminator == ?/ do
    # `<.NAME/...>` — expect `>` next (with optional whitespace, no
    # attrs allowed in this branch — we only enter `?/` when no attrs).
    case skip_to_gt(after_terminator) do
      {:ok, after_gt, _consumed} ->
        # `<.NAME/>` — atomic, no body.
        full = head <> ">"
        {:ok, full, after_gt, count_newlines(full)}

      :not_found ->
        :unbalanced
    end
  end

  defp capture_invocation(head, terminator, after_terminator, name) when terminator == ?> do
    # `<.NAME>` — open tag complete with no attrs. Find balanced
    # `</.NAME>`.
    capture_balanced(head, after_terminator, name)
  end

  defp capture_invocation(head, _terminator, after_terminator, name) do
    # `<.NAME ` (whitespace) — attrs follow. Walk attrs until we hit
    # `>` or `/>` outside of any attr-string / curly expression.
    case scan_attrs(after_terminator) do
      {:self_close, after_self_close, attrs_text, attrs_lines} ->
        full = head <> attrs_text <> "/>"
        {:ok, full, after_self_close, attrs_lines + count_newlines(head)}

      {:open, after_open, attrs_text, attrs_lines} ->
        # Open tag complete; find balanced close.
        head_full = head <> attrs_text <> ">"
        capture_balanced(head_full, after_open, name, attrs_lines + count_newlines(head))

      :unbalanced ->
        :unbalanced
    end
  end

  # `head` is `<.NAME ...> ` already captured. Search for matching
  # `</.NAME>`, accounting for nested same-named opens.
  defp capture_balanced(head, after_open, name, lines_consumed_so_far \\ 0) do
    case scan_body(after_open, name, 1, [], 0) do
      {:ok, body, after_close, body_lines} ->
        full = head <> body <> "</." <> name <> ">"
        {:ok, full, after_close, lines_consumed_so_far + body_lines}

      :unbalanced ->
        :unbalanced
    end
  end

  # Walk forward through the body of a `<.NAME>...</.NAME>` block,
  # keeping the running iolist accumulator so we can return the
  # captured substring. Tracks `depth` for nested same-named opens.
  defp scan_body("", _name, _depth, _acc, _lines), do: :unbalanced

  # Skip EEx blocks (their contents may contain `<.X>` we don't care about here).
  defp scan_body("<!--" <> rest, name, depth, acc, lines) do
    {block, after_block} = take_until(rest, "-->")
    chunk = "<!--" <> block <> "-->"
    scan_body(after_block, name, depth, [chunk | acc], lines + count_newlines(chunk))
  end

  defp scan_body("<%!" <> rest, name, depth, acc, lines),
    do: scan_body_eex(rest, "<%!", "%>", name, depth, acc, lines)

  defp scan_body("<%=" <> rest, name, depth, acc, lines),
    do: scan_body_eex(rest, "<%=", "%>", name, depth, acc, lines)

  defp scan_body("<%" <> rest, name, depth, acc, lines),
    do: scan_body_eex(rest, "<%", "%>", name, depth, acc, lines)

  # `</.NAME>` — possible matching close.
  defp scan_body("</." <> rest, name, depth, acc, lines) do
    case parse_close(rest) do
      {:found, ^name, after_close} ->
        if depth == 1 do
          body = acc |> Enum.reverse() |> IO.iodata_to_binary()
          {:ok, body, after_close, lines}
        else
          chunk = "</." <> name <> ">"
          scan_body(after_close, name, depth - 1, [chunk | acc], lines)
        end

      {:found, other_name, after_close} ->
        chunk = "</." <> other_name <> ">"
        scan_body(after_close, name, depth, [chunk | acc], lines)

      :not_a_component ->
        scan_body(rest, name, depth, ["</." | acc], lines)
    end
  end

  # `<.NAME` — possible nested same-named open or different.
  defp scan_body("<." <> rest, name, depth, acc, lines) do
    case parse_name(rest) do
      {:found, ^name, terminator, after_name} ->
        # Nested same-named open. Account for both self-close and
        # full-open variants.
        head = "<." <> name <> <<terminator>>

        case nested_open_kind(terminator, after_name) do
          {:self_close, after_sc, attrs} ->
            chunk = head <> attrs <> "/>"
            scan_body(after_sc, name, depth, [chunk | acc], lines + count_newlines(chunk))

          {:full_open, after_fo, attrs} ->
            chunk = head <> attrs <> ">"
            scan_body(after_fo, name, depth + 1, [chunk | acc], lines + count_newlines(chunk))

          :unbalanced ->
            :unbalanced
        end

      {:found, other, terminator, after_name} ->
        chunk = "<." <> other <> <<terminator>>
        scan_body(after_name, name, depth, [chunk | acc], lines + count_newlines(chunk))

      :not_a_component ->
        scan_body(rest, name, depth, ["<." | acc], lines)
    end
  end

  defp scan_body(<<?\n, rest::binary>>, name, depth, acc, lines) do
    scan_body(rest, name, depth, [<<?\n>> | acc], lines + 1)
  end

  defp scan_body(<<char::utf8, rest::binary>>, name, depth, acc, lines) do
    scan_body(rest, name, depth, [<<char::utf8>> | acc], lines)
  end

  defp scan_body_eex(rest, prefix, terminator, name, depth, acc, lines) do
    {block, after_block} = take_until(rest, terminator)
    chunk = prefix <> block <> terminator
    scan_body(after_block, name, depth, [chunk | acc], lines + count_newlines(chunk))
  end

  ## ─── attr-list scanner ─────────────────────────────────────────────

  # Walk attrs until `>` or `/>`. Returns {:open|:self_close, rest, captured_attrs_text, line_count}.
  defp scan_attrs(input), do: do_scan_attrs(input, [], :outside, 0)

  defp do_scan_attrs("", _acc, _mode, _lines), do: :unbalanced

  defp do_scan_attrs("/>" <> rest, acc, :outside, lines) do
    text = acc |> Enum.reverse() |> IO.iodata_to_binary()
    {:self_close, rest, text, lines}
  end

  defp do_scan_attrs(">" <> rest, acc, :outside, lines) do
    text = acc |> Enum.reverse() |> IO.iodata_to_binary()
    {:open, rest, text, lines}
  end

  defp do_scan_attrs("\"" <> rest, acc, :outside, lines),
    do: do_scan_attrs(rest, ["\"" | acc], :dq, lines)

  defp do_scan_attrs("\"" <> rest, acc, :dq, lines),
    do: do_scan_attrs(rest, ["\"" | acc], :outside, lines)

  defp do_scan_attrs("'" <> rest, acc, :outside, lines),
    do: do_scan_attrs(rest, ["'" | acc], :sq, lines)

  defp do_scan_attrs("'" <> rest, acc, :sq, lines),
    do: do_scan_attrs(rest, ["'" | acc], :outside, lines)

  defp do_scan_attrs("{" <> rest, acc, :outside, lines),
    do: do_scan_attrs(rest, ["{" | acc], {:curly, 1}, lines)

  defp do_scan_attrs("{" <> rest, acc, {:curly, depth}, lines),
    do: do_scan_attrs(rest, ["{" | acc], {:curly, depth + 1}, lines)

  defp do_scan_attrs("}" <> rest, acc, {:curly, 1}, lines),
    do: do_scan_attrs(rest, ["}" | acc], :outside, lines)

  defp do_scan_attrs("}" <> rest, acc, {:curly, depth}, lines),
    do: do_scan_attrs(rest, ["}" | acc], {:curly, depth - 1}, lines)

  defp do_scan_attrs(<<?\n, rest::binary>>, acc, mode, lines),
    do: do_scan_attrs(rest, [<<?\n>> | acc], mode, lines + 1)

  defp do_scan_attrs(<<char::utf8, rest::binary>>, acc, mode, lines),
    do: do_scan_attrs(rest, [<<char::utf8>> | acc], mode, lines)

  ## ─── helpers ───────────────────────────────────────────────────────

  defp parse_name(<<char::utf8, _::binary>> = input) do
    if name_start?(char), do: do_parse_name(input, []), else: :not_a_component
  end

  defp parse_name(""), do: :not_a_component

  defp do_parse_name(<<char::utf8, rest::binary>>, acc) do
    cond do
      name_char?(char) ->
        do_parse_name(rest, [<<char::utf8>> | acc])

      char in [?\s, ?\n, ?\t, ?/, ?>] ->
        name = acc |> Enum.reverse() |> IO.iodata_to_binary()
        if name == "", do: :not_a_component, else: {:found, name, char, rest}

      true ->
        :not_a_component
    end
  end

  defp do_parse_name("", _acc), do: :not_a_component

  defp parse_close(input) do
    case do_parse_name(input, []) do
      {:found, name, ?>, after_name} ->
        {:found, name, after_name}

      {:found, name, _ws, after_name} ->
        # Allow `</.NAME >` with whitespace before `>`.
        case skip_to_gt(after_name) do
          {:ok, after_gt, _consumed} -> {:found, name, after_gt}
          :not_found -> :not_a_component
        end

      _ ->
        :not_a_component
    end
  end

  # Determine whether `<.NAME<terminator>...>` is self-close or full-open.
  defp nested_open_kind(?/, after_term) do
    case skip_to_gt(after_term) do
      {:ok, after_gt, _} -> {:self_close, after_gt, ""}
      :not_found -> :unbalanced
    end
  end

  defp nested_open_kind(?>, after_term), do: {:full_open, after_term, ""}

  defp nested_open_kind(_ws, after_term) do
    case scan_attrs(after_term) do
      {:open, after_open, attrs, _lines} -> {:full_open, after_open, attrs}
      {:self_close, after_sc, attrs, _lines} -> {:self_close, after_sc, attrs}
      :unbalanced -> :unbalanced
    end
  end

  defp skip_to_gt(input), do: skip_to_gt(input, 0)
  defp skip_to_gt("", _), do: :not_found
  defp skip_to_gt(">" <> rest, n), do: {:ok, rest, n + 1}
  defp skip_to_gt(<<?\s, rest::binary>>, n), do: skip_to_gt(rest, n + 1)
  defp skip_to_gt(<<?\t, rest::binary>>, n), do: skip_to_gt(rest, n + 1)
  defp skip_to_gt(<<?\n, rest::binary>>, n), do: skip_to_gt(rest, n + 1)
  defp skip_to_gt(_, _), do: :not_found

  defp name_start?(char) do
    (char >= ?a and char <= ?z) or (char >= ?A and char <= ?Z) or char == ?_
  end

  defp name_char?(char) do
    name_start?(char) or (char >= ?0 and char <= ?9) or char in [?_, ?-]
  end

  defp count_newlines(text) when is_binary(text) do
    text |> :binary.matches("\n") |> length()
  end

  defp take_until(source, terminator) do
    case :binary.split(source, terminator) do
      [content, rest] -> {content, rest}
      [_unsplit] -> {source, ""}
    end
  end

  ## ─── parent-directive enrichment ───────────────────────────────────

  # Re-tokenize the original source via `Phoenix.LiveView.Tokenizer` and
  # build an open-tag stack. For each captured chelekom invocation,
  # find the position in the token stream that corresponds to its
  # opening tag, walk the stack at that point, and grab any enclosing
  # `:for=`/`:if=` directives. Rewrap the captured `source` so the
  # snippet renders self-contained.
  #
  # Falls through silently if Phoenix.LiveView.Tokenizer isn't loaded
  # (e.g. someone vendors this module without the LV dep). The
  # extractor's pre-enrichment behavior is preserved.
  defp enrich_with_parent_directives(extractions, _text)
       when not is_list(extractions) or extractions == [],
       do: extractions

  defp enrich_with_parent_directives(extractions, text) do
    if Code.ensure_loaded?(Phoenix.LiveView.Tokenizer) and
         function_exported?(Phoenix.LiveView.Tokenizer, :tokenize, 5) do
      ancestors_by_line = build_ancestor_index(text)

      Enum.map(extractions, fn ext ->
        case Map.get(ancestors_by_line, ext.line) do
          nil ->
            ext

          [] ->
            ext

          ancestors ->
            # `ancestors` is innermost-last. Wrap from outside in: open
            # outer first, then inner, then snippet, then close inner,
            # then close outer.
            opens = Enum.map_join(ancestors, "", fn {open, _close} -> open end)

            closes =
              ancestors |> Enum.reverse() |> Enum.map_join("", fn {_open, close} -> close end)

            %{ext | source: opens <> ext.source <> closes}
        end
      end)
    else
      extractions
    end
  end

  # Returns `%{line_number => [ancestor_directive_pairs, …]}` where
  # each pair is `{open_text, close_text}`. Only ancestors carrying
  # `:for=`/`:if=` directives are recorded — others are tracked on the
  # stack but elided from the wrapping output (no need to wrap with a
  # plain `<div>` if it adds nothing).
  defp build_ancestor_index(text) do
    try do
      state = Phoenix.LiveView.Tokenizer.init(0, "extractor", text, Phoenix.LiveView.HTMLEngine)

      {tokens, _cont} =
        Phoenix.LiveView.Tokenizer.tokenize(
          text,
          [line: 1, column: 1],
          [],
          {:text, :enabled},
          state
        )

      # Tokens come back in REVERSE source order (Phoenix's prepend
      # accumulator). Reverse for a left-to-right walk.
      walk_tokens(Enum.reverse(tokens), [], %{})
    rescue
      _ -> %{}
    catch
      _, _ -> %{}
    end
  end

  defp walk_tokens([], _stack, acc), do: acc

  # `Phoenix.LiveView.Tokenizer` emits four tag-shaped token kinds:
  #
  #   {:tag, "div", attrs, meta}                — plain HTML tag
  #   {:local_component, "X", attrs, meta}      — `<.X>` (`X` resolved
  #                                                in the surrounding
  #                                                module)
  #   {:remote_component, "Mod.X", attrs, meta} — `<Mod.X>`
  #   {:slot, "X", attrs, meta}                 — `<:X>` slot
  #
  # And matching close variants `{:close, kind, name, meta}`. We push
  # all of them onto the open-tag stack; user libraries are tracked
  # the same way as kit components and HTML tags.
  defp walk_tokens([token | rest], stack, acc) do
    case token do
      {kind, name, attrs, meta}
      when kind in [:tag, :local_component, :remote_component, :slot] ->
        acc = maybe_record_component_line(acc, kind, meta, stack)

        # Phoenix.LiveView.Tokenizer marks self-closing tags
        # (`<.icon … />`, `<input/>`) with `closing: :self` in meta —
        # those don't emit a matching `:close` token, so don't push.
        if Map.get(meta, :closing) == :self do
          walk_tokens(rest, stack, acc)
        else
          entry = ancestor_entry(kind, name, attrs)
          walk_tokens(rest, [entry | stack], acc)
        end

      {:close, _kind, _name, _meta} ->
        walk_tokens(rest, tl_safe(stack), acc)

      _ ->
        walk_tokens(rest, stack, acc)
    end
  end

  # Record `<.X>`-shape tags (local & remote components) as candidate
  # extraction lines. Plain HTML and slot tokens aren't extraction
  # targets so we don't index them.
  defp maybe_record_component_line(acc, kind, meta, stack)
       when kind in [:local_component, :remote_component] do
    line = Map.get(meta, :line, 1)

    ancestors =
      stack
      |> Enum.reject(&is_nil/1)
      |> Enum.reverse()

    Map.put(acc, line, ancestors)
  end

  defp maybe_record_component_line(acc, _kind, _meta, _stack), do: acc

  defp tl_safe([]), do: []
  defp tl_safe([_ | t]), do: t

  # Build the open/close text pair for an ancestor element. If the
  # element has no `:for`/`:if` directive we return `nil` so the entry
  # is filtered out (we don't wrap with empty `<div>`s — only
  # directive-bearing wrappers). The leading-dot prefix for local
  # components and the bare module path for remote components are
  # reproduced so the wrapper stays renderable.
  defp ancestor_entry(kind, name, attrs) do
    directives = directive_attrs(attrs)

    if directives == [] do
      nil
    else
      directive_text = Enum.map_join(directives, " ", fn {k, v} -> "#{k}={#{v}}" end)

      tag_name =
        case kind do
          :local_component -> "." <> name
          :remote_component -> name
          # plain HTML tag and `<:slot>` use the bare name; `<:slot>`
          # shouldn't carry `:for`/`:if` directives in practice but we
          # keep the branch for completeness.
          _ -> name
        end

      open = "<#{tag_name} #{directive_text}>"
      close = "</#{tag_name}>"

      {open, close}
    end
  end

  defp directive_attrs(attrs) do
    Enum.flat_map(attrs, fn
      {":" <> _ = key, {:expr, value, _meta}, _} -> [{key, value}]
      _ -> []
    end)
  end
end
