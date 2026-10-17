defmodule DevelopmentWeb.OutlineRingTest do
  @moduledoc """
  A focus ring drawn with `outline-<n>` shows up in Tailwind v4.

  v4's `outline-none` and `outline-hidden` set the outline style to none, and `outline-<n>` only
  sets a width in the style that is current, so `focus:outline-none focus-visible:outline-2` on
  one element never draws the ring. The element also needs `outline-solid` under the variants
  of the width class. A width class aimed at another element (`[&_input]:outline-none` on a
  wrapper that has `focus-within:outline-2`) is not read.
  """
  use ExUnit.Case, async: true

  @files Path.wildcard(Path.expand("../../lib/development_web/**/*.ex", __DIR__))

  defp variants(word) do
    {segments, _current, _depth} =
      word
      |> String.graphemes()
      |> Enum.reduce({[], "", 0}, fn
        char, {segments, current, depth} when char in ["[", "("] ->
          {segments, current <> char, depth + 1}

        char, {segments, current, depth} when char in ["]", ")"] ->
          {segments, current <> char, depth - 1}

        ":", {segments, current, 0} ->
          {[current | segments], "", 0}

        char, {segments, current, depth} ->
          {segments, current <> char, depth}
      end)

    Enum.reverse(segments)
  end

  defp utility(word) do
    word |> String.split(~r/:(?![^\[]*\])/) |> List.last() |> String.trim("!")
  end

  defp arbitrary?(segments), do: Enum.any?(segments, &String.starts_with?(&1, "["))

  defp rings_without_style(string) do
    words = for word <- String.split(string), do: {variants(word), utility(word), word}

    hidden =
      for {segments, utility, _} <- words,
          utility in ["outline-none", "outline-hidden"],
          do: segments

    for {segments, utility, word} <- words,
        Regex.match?(~r/^outline-(?:\d+|\[\d)/, utility),
        Enum.any?(hidden, &(not arbitrary?(&1) and not arbitrary?(segments))),
        not Enum.any?(words, fn {other, style, _} ->
          style in ["outline-solid", "outline-dashed", "outline-dotted", "outline-double"] and
            other == segments
        end),
        do: word
  end

  test "an element that hides its outline draws its ring with outline-solid" do
    found =
      for path <- @files,
          [_all, string] <-
            Regex.scan(~r/"((?:[^"\\\n]|\\.)*outline-[^"\\\n]*)"/, File.read!(path)),
          word <- rings_without_style(string),
          do: "#{Path.relative_to_cwd(path)}: #{word}"

    assert Enum.take(Enum.uniq(found), 20) == []
  end

  test "reads a ring that cannot show" do
    assert rings_without_style("focus:outline-none focus-visible:outline-2") == [
             "focus-visible:outline-2"
           ]

    assert rings_without_style(
             "focus:outline-none focus-visible:outline-2 focus-visible:outline-solid"
           ) == []

    assert rings_without_style("[&_input]:outline-none focus-within:outline-2") == []
  end
end
