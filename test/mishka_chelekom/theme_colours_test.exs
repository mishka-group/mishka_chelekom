defmodule MishkaChelekom.ThemeColoursTest do
  @moduledoc """
  Every theme colour a template names is one `priv/assets/css/theme.css` defines.

  Tailwind draws nothing for a colour the theme does not define, and says nothing about it either:
  `hover:bg-primary-bordered-hover-light` on the accordion and `to-progress-bg` on the gradient
  progress bar compiled to no CSS at all. A theme colour is read off its shape — a colour utility
  whose value starts with one of the theme's own colour families, or ends in `-light` / `-dark`.
  """
  use ExUnit.Case, async: true

  alias MishkaChelekom.Generators.Core

  @templates Path.wildcard("priv/{components,headless}/*.eex")
  @theme File.read!("priv/assets/css/theme.css")

  @utilities ~w(bg text border border-t border-b border-l border-r border-x border-y border-s border-e
                outline ring ring-offset divide from via to fill stroke accent caret decoration shadow
                placeholder)

  defp defined, do: MapSet.new(Regex.scan(~r/--color-([a-z0-9-]+)\s*:/, @theme), &Enum.at(&1, 1))

  defp families(defined), do: MapSet.new(defined, &(&1 |> String.split("-") |> hd()))

  # Tailwind's own values that happen to start with a theme family: `text-base`, `bg-gradient-to-r`.
  defp tailwind_value?(value), do: value == "base" or String.starts_with?(value, "gradient-to-")

  defp theme_colour?(value, families) do
    not tailwind_value?(value) and
      (hd(String.split(value, "-")) in families or String.ends_with?(value, ["-light", "-dark"]))
  end

  # The utility of a class, without its variants (`dark:`, `[&_.x]:`), its `!` and its `/opacity`.
  defp utility(class) do
    class
    |> String.split(~r/:(?![^\[]*\])/)
    |> List.last()
    |> String.trim_leading("!")
    |> String.split("/")
    |> hd()
  end

  test "there are templates to check" do
    igniter = Igniter.new()

    shipped =
      for layer <- [:styled, :headless],
          name <- Core.all_component_names(igniter, layer),
          do: "priv/#{Path.basename(Core.template_dir(layer))}/#{name}.eex"

    assert length(@templates) > 100
    assert Enum.sort(@templates) == Enum.sort(shipped)
  end

  test "every theme colour a template names is defined" do
    defined = defined()
    families = families(defined)

    prefix =
      ~r/^(#{@utilities |> Enum.sort_by(&(-String.length(&1))) |> Enum.join("|")})-([a-z][a-z0-9-]*)$/

    missing =
      for path <- @templates,
          {line, number} <- path |> File.read!() |> String.split("\n") |> Enum.with_index(1),
          class <- String.split(line, ~r/[\s"'`{}(),]+/, trim: true),
          [_, _utility, value] <- [Regex.run(prefix, utility(class))],
          theme_colour?(value, families),
          not MapSet.member?(defined, value),
          do: "#{Path.basename(path)}:#{number} #{class}"

    assert missing == [], "theme colours the theme does not define:\n" <> Enum.join(missing, "\n")
  end
end
