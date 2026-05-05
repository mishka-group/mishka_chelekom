defmodule MishkaChelekom.HeexTagRewriter do
  @moduledoc """
  Rewrites HEEx component tag references in a template string.

  Given a `~H\""" \"""` content body, a set of sibling-function names, and
  a kit name, this rewriter finds every occurrence of:

      <.NAME ... />        → <.component component_name="<kit>-<NAME-slug>" .../>
      <.NAME ...>...</.NAME>
                           → opening rewritten as above
                             closing `</.NAME>` rewritten to `</.component>`

  Other constructs (HTML tags, EEx interpolations, string literals,
  HTML comments, `phx-no-curly-interpolation` regions) are left
  untouched.

  This is a hand-rolled scanner — no regex, no Phoenix HEEx tokenizer
  dependency. The state machine tracks:

    * `:text` — default; looks for `<` to enter a tag
    * `:open_tag` — saw `<`, looking for tag name (including `.` prefix)
    * `:in_tag` — inside a tag's attribute list
    * `:in_attr_dq` / `:in_attr_sq` — attribute string (`""` / `''`)
    * `:in_curly` — `{...}` HEEx attribute or interpolation
    * `:in_html_comment` — `<!-- ... -->`
    * `:in_eex` — `<%= ... %>` / `<% ... %>` / `<%! ... %>`
    * `:in_no_curly_block` — between an opening tag with
       `phx-no-curly-interpolation` and its matching closing tag

  Slug rewrite (`button_indicator` → `button-indicator`) is applied to
  the component_name attribute value so the runtime helper resolves
  the AshSlug-stored row.
  """

  @type sibling_set :: MapSet.t(String.t())

  @doc """
  Rewrite a template string. Returns the rewritten string.
  Leaves input unchanged if no sibling references are found.
  """
  @spec rewrite(String.t(), sibling_set(), String.t()) :: String.t()
  def rewrite(nil, _siblings, _kit), do: nil
  def rewrite("", _siblings, _kit), do: ""

  def rewrite(template, siblings, kit_name) when is_binary(template) do
    if MapSet.size(siblings) == 0 do
      template
    else
      do_rewrite(template, siblings, kit_name)
    end
  end

  defp do_rewrite(input, siblings, kit_name) do
    state = %{
      output: [],
      mode: :text,
      siblings: siblings,
      kit: kit_name,
      no_curly_depth: 0
    }

    state
    |> scan(input)
    |> Map.fetch!(:output)
    |> Enum.reverse()
    |> IO.iodata_to_binary()
  end

  defp scan(state, "") do
    state
  end

  # `<!-- ... -->` HTML comment
  defp scan(state, "<!--" <> rest) when state.mode == :text do
    {comment, after_comment} = take_until(rest, "-->")
    emit(state, ["<!--", comment, "-->"]) |> scan(after_comment)
  end

  # `<%= ...`, `<% ...`, `<%! ...` EEx
  defp scan(state, "<%=" <> rest) when state.mode == :text do
    {block, after_block} = take_until(rest, "%>")
    emit(state, ["<%=", block, "%>"]) |> scan(after_block)
  end

  defp scan(state, "<%!" <> rest) when state.mode == :text do
    {block, after_block} = take_until(rest, "%>")
    emit(state, ["<%!", block, "%>"]) |> scan(after_block)
  end

  defp scan(state, "<%" <> rest) when state.mode == :text do
    {block, after_block} = take_until(rest, "%>")
    emit(state, ["<%", block, "%>"]) |> scan(after_block)
  end

  # `<.NAME` — possible sibling component tag
  defp scan(state, "<." <> rest) when state.mode == :text do
    case parse_component_tag_name(rest) do
      {:found, name, terminator, after_name} ->
        if MapSet.member?(state.siblings, name) do
          # Rewrite to `<.component component_name="<kit>-<slug>"
          #             site={assigns[:site]}<terminator>`.
          #
          # The site propagation matters for the runtime helper:
          # `LiveViewHelpers.component/1` hashes `name + site` to find
          # the compiled module. Without forwarding the parent's site,
          # the rewritten call defaults to `nil` and lookups for global
          # components installed under "Global" miss.
          #
          # Use `assigns[:site]` (Access protocol) instead of `@site`
          # so siblings called from inside private helpers (e.g.
          # `banner_dismiss` calls `<.icon>`) don't crash. The helper
          # has its own narrow assigns without `:site` declared, and
          # `@site` raises KeyError on the missing key while
          # `assigns[:site]` cleanly returns `nil`.
          slug = slug(name)
          target = state.kit <> "-" <> slug
          # Use `assigns[:site]` (Access protocol). Slot inner_block
          # scopes don't inherit the parent's `:site` attr, so `@site`
          # would raise inside a slot. The Access form returns `nil`
          # when missing, and the runtime helper coerces nil → "Global".
          replacement = ~s|<.component component_name="#{target}" site={assigns[:site]}|

          state
          |> emit(replacement)
          |> emit(<<terminator>>)
          |> scan(after_name)
        else
          state
          |> emit("<.")
          |> emit(name)
          |> emit(<<terminator>>)
          |> scan(after_name)
        end

      :not_a_component ->
        state |> emit("<.") |> scan(rest)
    end
  end

  # `</.NAME>` — possible sibling closing tag
  defp scan(state, "</." <> rest) when state.mode == :text do
    case parse_closing_tag_name(rest) do
      {:found, name, after_close} ->
        if MapSet.member?(state.siblings, name) do
          state |> emit("</.component>") |> scan(after_close)
        else
          state |> emit("</.") |> emit(name) |> emit(">") |> scan(after_close)
        end

      :not_a_component ->
        state |> emit("</.") |> scan(rest)
    end
  end

  # Plain `<` — could be a normal HTML tag start; just emit and continue
  defp scan(state, <<char::utf8, rest::binary>>) when state.mode == :text do
    emit(state, <<char::utf8>>) |> scan(rest)
  end

  # Parse `NAME` after `<.` ; NAME must start with [a-zA-Z_] and consist
  # of word chars. Returns `{:found, name_string, terminator_byte, rest}`
  # where terminator is the char (space / newline / `/` / `>`) that ends
  # the tag name.
  defp parse_component_tag_name(input) do
    do_parse_name(input, [])
  end

  defp do_parse_name(<<char::utf8, _::binary>> = input, []) do
    if name_start_char?(char) do
      do_parse_name_chars(input, [])
    else
      :not_a_component
    end
  end

  defp do_parse_name_chars(<<char::utf8, rest::binary>>, acc) do
    cond do
      name_char?(char) ->
        do_parse_name_chars(rest, [<<char::utf8>> | acc])

      char in [?\s, ?\n, ?\t, ?/, ?>] ->
        name = acc |> Enum.reverse() |> IO.iodata_to_binary()

        if name == "" do
          :not_a_component
        else
          {:found, name, char, rest}
        end

      true ->
        :not_a_component
    end
  end

  defp do_parse_name_chars("", _acc), do: :not_a_component

  defp parse_closing_tag_name(input) do
    case do_parse_closing(input, []) do
      {:found, name, rest} -> {:found, name, rest}
      :not_a_component -> :not_a_component
    end
  end

  defp do_parse_closing(<<char::utf8, _::binary>> = input, []) do
    if name_start_char?(char), do: do_parse_closing_chars(input, []), else: :not_a_component
  end

  defp do_parse_closing_chars(<<char::utf8, rest::binary>>, acc) do
    cond do
      name_char?(char) ->
        do_parse_closing_chars(rest, [<<char::utf8>> | acc])

      char == ?> ->
        name = acc |> Enum.reverse() |> IO.iodata_to_binary()
        if name == "", do: :not_a_component, else: {:found, name, rest}

      char in [?\s, ?\n, ?\t] ->
        name = acc |> Enum.reverse() |> IO.iodata_to_binary()
        rest_no_ws = String.trim_leading(rest)

        case rest_no_ws do
          ">" <> tail when name != "" -> {:found, name, tail}
          _ -> :not_a_component
        end

      true ->
        :not_a_component
    end
  end

  defp do_parse_closing_chars("", _), do: :not_a_component

  defp name_start_char?(char) do
    (char >= ?a and char <= ?z) or (char >= ?A and char <= ?Z) or char == ?_
  end

  defp name_char?(char) do
    name_start_char?(char) or (char >= ?0 and char <= ?9) or char in [?_, ?-]
  end

  defp slug(name) do
    name |> String.downcase() |> String.replace("_", "-")
  end

  defp emit(state, chunk) when is_binary(chunk) do
    %{state | output: [chunk | state.output]}
  end

  defp emit(state, list) when is_list(list) do
    %{state | output: [IO.iodata_to_binary(list) | state.output]}
  end

  defp take_until(source, terminator) do
    case :binary.split(source, terminator) do
      [content, rest] -> {content, rest}
      [_unsplit] -> {source, ""}
    end
  end
end
