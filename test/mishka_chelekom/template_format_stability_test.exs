defmodule MishkaChelekom.TemplateFormatStabilityTest do
  @moduledoc """
  The generators write every component through the project's formatter, and the files they write
  must pass `mix format --check-formatted` on every Elixir the kit supports.

  A function clause with a guard and a keyword `do:` is the one shape those versions lay out
  differently once it no longer fits on a line: Elixir 1.18 puts `do:` on a line of its own, 1.19
  and later keep it after the guard. A clause written with `do ... end` is laid out the same by
  all of them.

  This reads the styled and headless templates and fails on a guard clause written with `do:`
  that is longer than the formatter's line.
  """
  use ExUnit.Case, async: true

  @line_length 98
  @indent 2

  defp templates,
    do: Path.wildcard(Path.expand("../../priv/{components,headless}/*.eex", __DIR__))

  test "there are component templates to check" do
    refute Enum.empty?(templates())
  end

  test "a guard clause written with do: fits on one line" do
    violations =
      for path <- templates(),
          {number, clause} <- keyword_guard_clauses(File.read!(path)),
          @indent + String.length(clause) > @line_length do
        "#{Path.relative_to_cwd(path)}:#{number}: #{String.slice(clause, 0, 70)}..."
      end

    assert violations == [],
           "These clauses do not fit on one line, so Elixir 1.18 and 1.19+ lay them out " <>
             "differently. Write them with `do ... end`:\n  " <> Enum.join(violations, "\n  ")
  end

  # `{line number, the clause on one line}` of every `def`/`defp` clause that has a guard and takes
  # `do:`. A clause that opens a `do` block, or holds an EEx tag, is not one.
  defp keyword_guard_clauses(text) do
    text
    |> String.split("\n")
    |> Enum.with_index(1)
    |> clauses([])
    |> Enum.flat_map(fn {number, lines} ->
      clause = lines |> Enum.map(&String.trim/1) |> Enum.join(" ")

      if guard_with_keyword_do?(clause) and not Enum.any?(lines, &block_head?/1) do
        [{number, clause}]
      else
        []
      end
    end)
  end

  defp clauses([], acc), do: Enum.reverse(acc)

  defp clauses([{line, number} | rest], acc) do
    if String.match?(line, ~r/^  defp? /) do
      {continuation, rest} =
        Enum.split_while(rest, fn {next, _} -> String.match?(next, ~r/^    /) end)

      clauses(rest, [{number, [line | Enum.map(continuation, &elem(&1, 0))]} | acc])
    else
      clauses(rest, acc)
    end
  end

  defp guard_with_keyword_do?(clause) do
    String.contains?(clause, " when ") and String.match?(clause, ~r/,\s*do:/) and
      not String.contains?(clause, "<%")
  end

  defp block_head?(line), do: String.match?(String.trim_trailing(line), ~r/\sdo$/)
end
