defmodule MishkaChelekom.ComponentAttrsTest do
  @moduledoc """
  What the styled templates and their documentation declare, read from the files themselves.

  Everything is derived from `priv/components` and `usage-rules`, so a new component is covered
  the moment it lands. The rendering of the same facts is tested in `development/web`, against
  the generated components.
  """
  use ExUnit.Case, async: true

  @templates Path.wildcard(Path.expand("../../priv/components/*.eex", __DIR__))
  @catalogs Path.wildcard(Path.expand("../../priv/components/*.exs", __DIR__))
  @rules Path.wildcard(Path.expand("../../usage-rules/components/*.md", __DIR__))
  @demos Path.wildcard(Path.expand("../../priv/demos/*_live.{ex,html.heex}", __DIR__))

  # The HTML boolean attributes: present or absent, never a string.
  @html_booleans ~w(ismap autoplay loop muted playsinline disabled readonly required
    multiple autofocus checked hidden open selected reversed novalidate)

  defp read(path), do: File.read!(path)

  # `{name, declaration}` of every top-level `attr` of a template.
  defp attrs(text) do
    for chunk <- String.split(text, ~r/\n(?=  (?:attr|slot|def|defp|@doc|@spec) )/),
        [_, name] <- [Regex.run(~r/\A  attr :(\w+),/, chunk)],
        do: {name, chunk |> String.split("\n\n") |> hd()}
  end

  defp names(text, pattern),
    do: pattern |> Regex.scan(text, capture: :all_but_first) |> List.flatten()

  defp variants do
    in_catalogs = for path <- @catalogs, do: names(read(path), ~r/variant:\s*\[([^\]]*)\]/)
    in_clauses = for path <- @templates, do: names(read(path), ~r/defp color_variant\("(\w+)"/)

    lists = in_catalogs |> List.flatten() |> Enum.flat_map(&names(&1, ~r/"(\w+)"/))
    MapSet.new(lists ++ List.flatten(in_clauses))
  end

  describe "rounded" do
    test "every rounded helper has a clause for none" do
      helpers =
        for path <- @templates,
            text = read(path),
            helper <- text |> names(~r/defp (rounded\w*)\(/) |> Enum.uniq(),
            do: {Path.basename(path), helper, text}

      assert length(helpers) > 40

      missing =
        for {file, helper, text} <- helpers,
            not (text =~ ~s|defp #{helper}("none"|),
            do: "#{file}: #{helper}"

      assert missing == []
    end

    test "every rounded value a helper has a clause for is in the component's catalog" do
      unlisted =
        for path <- @templates,
            [list] <- [names(read(Path.rootname(path) <> ".exs"), ~r/rounded:\s*\[([^\]]*)\]/)],
            listed = names(list, ~r/"(\w+)"/),
            value <- names(read(path), ~r/defp (?:dropdown_)?rounded\w*\("(\w+)"/) |> Enum.uniq(),
            value not in listed,
            do: "#{Path.basename(path)}: #{value}"

      assert unlisted == []
    end
  end

  describe "positions" do
    test "border_position names the edge the border is drawn on" do
      edges = %{"top" => "border-t", "bottom" => "border-b"}
      clause = ~r/defp border_class\("\w+", "(top|bottom)", _\), do: "([^"]+)"/

      wrong =
        for path <- @templates,
            text = read(path),
            text =~ "@border_position",
            [position, class] <- Regex.scan(clause, text, capture: :all_but_first),
            not String.starts_with?(class, edges[position]),
            do: "#{Path.basename(path)}: #{position} draws #{class}"

      assert wrong == []
    end

    test "rounded_position names the edge whose corners are rounded" do
      edges = %{"top" => "rounded-t", "bottom" => "rounded-b"}
      clause = ~r/defp rounded_size\("\w+", "(top|bottom)"\), do: "([^"]+)"/

      wrong =
        for path <- @templates,
            text = read(path),
            text =~ "@rounded_position",
            [position, class] <- Regex.scan(clause, text, capture: :all_but_first),
            not String.starts_with?(class, edges[position]),
            do: "#{Path.basename(path)}: #{position} rounds #{class}"

      assert wrong == []
    end
  end

  describe "attributes" do
    test "an HTML boolean attribute is a boolean" do
      wrong =
        for path <- @templates,
            {name, declaration} <- attrs(read(path)),
            name in @html_booleans,
            not (declaration =~ ~r/\A  attr :\w+, :boolean/),
            do: "#{Path.basename(path)}: #{name}"

      assert wrong == []
    end

    test "a name or value with a default is never filled in by assign_new" do
      shadowed =
        for path <- @templates,
            text = read(path),
            {name, declaration} <- attrs(text),
            name in ~w(name value),
            declaration =~ "default:",
            text =~ "assign_new(:#{name}",
            do: "#{Path.basename(path)}: #{name}"

      assert shadowed == []
    end
  end

  describe "documentation" do
    test "an example names a variant some component accepts" do
      known = variants()
      assert MapSet.member?(known, "bordered")

      unknown =
        for path <- @templates ++ @rules,
            Path.basename(path) not in ["shape.eex", "shape.md"],
            variant <- names(read(path), ~r/variant(?:=|:\s*)"(\w+)"/),
            not MapSet.member?(known, variant),
            uniq: true,
            do: "#{Path.basename(path)}: #{variant}"

      assert unknown == []
    end

    test "the demos name only variants some component accepts" do
      known = variants()

      unknown =
        for path <- @demos,
            not (Path.basename(path) =~ "shape_live"),
            variant <- names(read(path), ~r/variant(?:=|:\s*)"(\w+)"/),
            not MapSet.member?(known, variant),
            uniq: true,
            do: "#{Path.basename(path)}: #{variant}"

      assert unknown == []
    end

    test "no example gives a slot a trigger_id" do
      slot = ~r/<:\w+[^>]*\btrigger_id=/

      wrong =
        for path <- @templates ++ @demos ++ @rules,
            read(path) =~ slot,
            do: Path.basename(path)

      assert wrong == []
    end
  end
end
