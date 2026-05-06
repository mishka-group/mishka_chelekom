defmodule MishkaChelekom.CmsBundle.SourceSlicer do
  @moduledoc """
  Slice substrings from a source by **line/column** coordinates the way
  `Phoenix.LiveView.Tokenizer` reports them (1-based line, 1-based
  column).

  Token-driven extraction needs to round-trip the *original* bytes of
  the file (preserving whitespace, EEx interpolations, and unparsed
  user attribute values). The tokenizer gives you semantic structure,
  not raw substrings — so we keep this slicer alongside it.

  ## Usage

      table = MishkaChelekom.CmsBundle.SourceSlicer.build(source)
      slice = MishkaChelekom.CmsBundle.SourceSlicer.slice!(
        source, table,
        from: %{line: 4, column: 3},
        to:   %{line: 7, column: 14}  # exclusive end column
      )

  `to:` is exclusive, matching `String.slice/2` semantics so a
  half-open range `[from, to)` is what you pass.
  """

  @type offset_table :: tuple()
  @type pos :: %{line: pos_integer(), column: pos_integer()}

  @doc """
  Pre-compute the byte offset of the start of each line. O(n) once,
  O(1) lookup per slice. Returned as a tuple for fast indexed access.
  """
  @spec build(String.t()) :: offset_table()
  def build(source) when is_binary(source) do
    lines = String.split(source, "\n", trim: false)

    {offsets, _} =
      Enum.map_reduce(lines, 0, fn line, offset ->
        {offset, offset + byte_size(line) + 1}
      end)

    List.to_tuple(offsets)
  end

  @doc """
  Slice `[from, to)` from `source`. Both `from` and `to` are
  `%{line: …, column: …}` (1-based). `to` is exclusive.
  """
  @spec slice!(String.t(), offset_table(), keyword()) :: String.t()
  def slice!(source, table, opts) do
    %{line: from_line, column: from_col} = Keyword.fetch!(opts, :from)
    %{line: to_line, column: to_col} = Keyword.fetch!(opts, :to)

    from_byte = byte_offset(table, from_line, from_col)
    to_byte = byte_offset(table, to_line, to_col)

    binary_part(source, from_byte, max(0, to_byte - from_byte))
  end

  defp byte_offset(table, line, column) do
    line_start = elem(table, line - 1)
    line_start + (column - 1)
  end
end
