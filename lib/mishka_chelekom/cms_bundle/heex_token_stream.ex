defmodule MishkaChelekom.CmsBundle.HeexTokenStream do
  @moduledoc """
  Compose `EEx.tokenize/1` with `Phoenix.LiveView.Tokenizer.tokenize/5`
  to obtain a unified token stream for **raw** `.html.heex`/`.heex`
  source.

  This is the same recipe `Phoenix.LiveView.HTMLFormatter` (the official
  `mix format` plugin for HEEx) uses internally. Neither tokenizer
  alone handles raw HEEx:

    * `EEx.tokenize/1` only carves EEx delimiters; HTML tags and
      `<.local_component>` calls stay opaque inside `:text` chunks.
    * `Phoenix.LiveView.Tokenizer.tokenize/5` parses HTML + HEEx
      components correctly, but raises on raw `<%= … %>` mid-content
      because it expects the EEx blocks to already have been removed.

  Composing them gives a stream of:

      {:tag, name, attrs, meta}              — `<div>`, `<input/>`, …
      {:local_component, name, attrs, meta}  — `<.button>`, `<.icon/>`
      {:remote_component, "Mod.X", attrs, …} — `<MyMod.button>`
      {:slot, name, attrs, meta}             — `<:inner_block>`
      {:close, kind, name, meta}             — matching close tags
      {:text, raw, meta}                     — text content (between tags)
      {:eex, type, expr, meta}               — `<%= … %>` and friends
      {:eex_comment, body, meta}             — `<%!-- … --%>` comments

  Every token carries a `meta` map with `:line` and `:column` keys, so
  consumers can slice the original source via
  `MishkaChelekom.CmsBundle.SourceSlicer`.

  Returns `:error` (with the parse-error message) instead of raising,
  so callers can fall back to a lenient strategy if needed.
  """

  @type token :: tuple()

  @doc """
  Tokenize raw HEEx source. Returns `{:ok, tokens}` on success or
  `{:error, message}` on parse failure. Tokens are returned in source
  order.
  """
  @spec tokenize(String.t(), keyword()) :: {:ok, [token()]} | {:error, String.t()}
  def tokenize(source, opts \\ []) when is_binary(source) do
    file = Keyword.get(opts, :file, "nofile")

    with {:ok, eex_nodes} <- safe_eex_tokenize(source) do
      try do
        {tokens, cont} =
          Enum.reduce(eex_nodes, {[], {:text, :enabled}}, &reduce_node(&1, &2, source, file))

        # `Phoenix.LiveView.Tokenizer.finalize/4` already reverses the
        # prepend-accumulator into source order — return as-is.
        {:ok, Phoenix.LiveView.Tokenizer.finalize(tokens, file, cont, source)}
      rescue
        e in Phoenix.LiveView.Tokenizer.ParseError -> {:error, Exception.message(e)}
        e -> {:error, Exception.message(e)}
      catch
        kind, reason -> {:error, "#{inspect(kind)}: #{inspect(reason)}"}
      end
    end
  end

  defp safe_eex_tokenize(source) do
    case EEx.tokenize(source, []) do
      {:ok, tokens} -> {:ok, tokens}
      {:error, line, col, msg} -> {:error, "EEx parse error at #{line}:#{col} — #{msg}"}
      {:error, msg} -> {:error, "EEx parse error — #{inspect(msg)}"}
    end
  rescue
    e -> {:error, Exception.message(e)}
  end

  # `:text` — feed the HTML chunk into the LV tokenizer to get
  # `:tag` / `:local_component` / `:close` / `:text` tokens.
  defp reduce_node({:text, chars, meta}, {tokens, cont}, source, file) do
    text = List.to_string(chars)
    pos = [line: meta.line, column: meta.column]
    state = Phoenix.LiveView.Tokenizer.init(0, file, source, Phoenix.LiveView.HTMLEngine)
    Phoenix.LiveView.Tokenizer.tokenize(text, pos, tokens, cont, state)
  end

  # `<%!-- comment --%>`
  defp reduce_node({:comment, chars, meta}, {tokens, cont}, _source, _file) do
    {[{:eex_comment, List.to_string(chars), meta} | tokens], cont}
  end

  # `<% … %>`, `<%= … %>`, etc. Splice as a synthetic `:eex` token so
  # the consumer can ignore EEx blocks (or scan for `if`/`for`) without
  # re-parsing the source.
  defp reduce_node({type, opt, expr, %{column: column, line: line}}, {tokens, cont}, _source, _file)
       when type in [:start_expr, :expr, :end_expr, :middle_expr] do
    meta = %{opt: opt, line: line, column: column}
    expr_string = expr |> List.to_string() |> String.trim()
    {[{:eex, type, expr_string, meta} | tokens], cont}
  end

  # Anything else (`:eof`, unknown future shapes) — drop silently;
  # `Tokenizer.finalize/4` adds the synthetic eof.
  defp reduce_node(_other, acc, _source, _file), do: acc
end
