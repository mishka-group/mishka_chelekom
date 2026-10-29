defmodule MishkaChelekom.CallerDisplayTest do
  @moduledoc """
  A styled component's own display utility reaches an element that also takes the caller's
  `class` only through `display_class/2`.

  Tailwind writes display utilities in name order, not in class-list order, so a default
  `inline-flex` beside a caller's `hidden` always wins. `display_class/2` drops the default when
  the caller names a display. This reads the templates' class lists for literal display utilities
  that bypass it; a display a helper returns is wrapped at the call site and is covered by the
  rendering tests in `development/web`.
  """
  use ExUnit.Case, async: true

  @templates Path.wildcard(Application.app_dir(:mishka_chelekom, "priv/components/*.eex"))

  @displays ~w(block inline-block inline flex inline-flex table inline-table table-caption
    table-cell table-column table-column-group table-footer-group table-header-group
    table-row-group table-row flow-root grid inline-grid contents list-item hidden)

  # The modal is hidden until it is shown; a caller's display class must not open it.
  @state %{"modal.eex" => ["hidden"]}

  defp class_expressions(text) do
    for {start, length} <- :binary.matches(text, "class={") do
      offset = start + length
      text |> binary_part(offset, byte_size(text) - offset) |> balanced("{", "}")
    end
  end

  defp balanced(text, open, close), do: balanced(text, open, close, 1, [])

  defp balanced(<<char::utf8, rest::binary>>, open, close, depth, acc) do
    char = <<char::utf8>>

    cond do
      char == close and depth == 1 -> acc |> Enum.reverse() |> IO.iodata_to_binary()
      char == close -> balanced(rest, open, close, depth - 1, [char | acc])
      char == open -> balanced(rest, open, close, depth + 1, [char | acc])
      true -> balanced(rest, open, close, depth, [char | acc])
    end
  end

  defp without_display_class(expression) do
    case :binary.split(expression, "display_class(") do
      [before, rest] ->
        call = balanced(rest, "(", ")")
        after_call = binary_part(rest, byte_size(call) + 1, byte_size(rest) - byte_size(call) - 1)
        before <> without_display_class(after_call)

      [expression] ->
        expression
    end
  end

  defp literal_displays(expression) do
    for [_, literal] <- Regex.scan(~r/"([^"]*)"/, without_display_class(expression)),
        token <- String.split(literal),
        token in @displays,
        do: token
  end

  test "there are class lists with the caller's class to check" do
    assert Enum.any?(@templates, fn path ->
             path |> File.read!() |> class_expressions() |> Enum.any?(&(&1 =~ ~r/@class\b/))
           end)
  end

  test "no default display sits beside the caller's class outside display_class/2" do
    offenders =
      for path <- @templates,
          name = Path.basename(path),
          expression <- path |> File.read!() |> class_expressions(),
          expression =~ ~r/@class\b/,
          display <- literal_displays(expression),
          display not in Map.get(@state, name, []),
          do: {name, display}

    assert offenders == []
  end
end
