defmodule MishkaChelekom.ComponentAttrsTest do
  @moduledoc """
  What the styled templates and their documentation declare, read from the files themselves.

  Everything is derived from `priv/components` and `usage-rules`, so a new component is covered
  the moment it lands. The rendering of the same facts is tested in `development/web`, against
  the generated components.
  """
  use ExUnit.Case, async: true

  @templates Path.wildcard(Application.app_dir(:mishka_chelekom, "priv/components/*.eex"))
  @catalogs Path.wildcard(Application.app_dir(:mishka_chelekom, "priv/components/*.exs"))
  @rules Path.wildcard(Path.expand("../../usage-rules/components/*.md", __DIR__))
  @demos Path.wildcard(Application.app_dir(:mishka_chelekom, "priv/demos/*_live.{ex,html.heex}"))

  # The HTML boolean attributes: present or absent, never a string.
  @html_booleans ~w(ismap autoplay loop muted playsinline disabled readonly required
    multiple autofocus checked hidden open selected reversed novalidate)

  # A class without a step names the step Tailwind v4 gave it. v3 gave the bare name a larger step
  # than it has now, so `rounded` and `rounded-sm` are the same value in v4.
  @bare_steps %{
    "rounded" => "sm",
    "shadow" => "sm",
    "drop-shadow" => "sm",
    "blur" => "sm",
    "backdrop-blur" => "sm",
    "ring" => "1"
  }

  @scale ~r/^(rounded(?:-(?:t|b|s|e|l|r|tl|tr|bl|br|ss|se|es|ee))?|shadow|drop-shadow|blur|backdrop-blur|ring)(?:-([a-z0-9]+))?$/

  @sizes ~w(extra_small small medium large extra_large double_large triple_large quadruple_large)

  defp read(path), do: File.read!(path)

  # `{name, declaration}` of every top-level `attr` of a template.
  defp attrs(text) do
    for chunk <- String.split(text, ~r/\n(?=  (?:attr|slot|def|defp|@doc|@spec) )/),
        [_, name] <- [Regex.run(~r/\A  attr :(\w+),/, chunk)],
        do: {name, chunk |> String.split("\n\n") |> hd()}
  end

  # `{variants, utility, step}` of a class on a v4 scale, or nil.
  defp scale(class) do
    {variants, utility} = split_variants(class)

    case Regex.run(@scale, utility) do
      [_, utility] -> {variants, utility, @bare_steps[bare_utility(utility)]}
      [_, utility, step] -> {variants, utility, step}
      nil -> nil
    end
  end

  defp bare_utility("rounded-" <> _side), do: "rounded"
  defp bare_utility(utility), do: utility

  defp split_variants(class) do
    {_depth, cut} =
      class
      |> String.to_charlist()
      |> Enum.with_index(1)
      |> Enum.reduce({0, 0}, fn
        {?[, _index}, {depth, cut} -> {depth + 1, cut}
        {?], _index}, {depth, cut} -> {depth - 1, cut}
        {?:, index}, {0, _cut} -> {0, index}
        _char, acc -> acc
      end)

    String.split_at(class, cut)
  end

  # The template as the generator writes it with every option on, parsed.
  defp source(path) do
    assigns = %{module: "Probe.Mod", component_prefix: "", web_module: Probe.Web}
    tag = ~r/<%(?!%).*?%>/s
    text = Regex.replace(tag, read(path), &Regex.replace(~r/@(\w+)/, &1, "assigns[:\\1]"))

    text
    |> EEx.eval_string(assigns: Map.put(assigns, :module_prefix_camel, ""))
    |> Code.string_to_quoted!()
  end

  # `{name, arguments, scale classes}` of every private function; an argument that is not a string
  # is `:_`.
  defp helpers(path) do
    {_ast, clauses} =
      Macro.prewalk(source(path), [], fn
        {:defp, _meta, [head, [do: body]]} = node, acc -> {node, [clause(head, body) | acc]}
        node, acc -> {node, acc}
      end)

    clauses
  end

  defp clause({:when, _meta, [head, _guard]}, body), do: clause(head, body)

  defp clause({name, _meta, args}, body) do
    {_body, strings} =
      Macro.prewalk(body, [], fn
        string, acc when is_binary(string) -> {string, [string | acc]}
        node, acc -> {node, acc}
      end)

    classes = strings |> Enum.flat_map(&String.split/1) |> Enum.map(&scale/1)

    {name, Enum.map(args || [], &if(is_binary(&1), do: &1, else: :_)),
     MapSet.new(classes) |> MapSet.delete(nil)}
  end

  # Pairs of clauses of one function that differ in one size.
  defp size_pairs(path) do
    clauses = helpers(path)

    for {{name, args, classes}, index} <- Enum.with_index(clauses),
        {^name, other_args, other_classes} <- Enum.drop(clauses, index + 1),
        length(args) == length(other_args),
        [{size, other_size}] <- [differing(args, other_args)],
        size in @sizes and other_size in @sizes,
        do: {name, {size, other_size}, classes, other_classes}
  end

  defp differing(args, other_args) do
    case Enum.zip(args, other_args) |> Enum.reject(fn {a, b} -> a == b end) do
      [pair] -> [pair]
      _ -> []
    end
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

  describe "sizes" do
    test "a v4 class with no step is the step it names" do
      assert scale("rounded") == scale("rounded-sm")
      assert scale("rounded-t") == scale("rounded-t-sm")
      assert scale("[&_.x]:hover:shadow") == scale("[&_.x]:hover:shadow-sm")
      assert scale("blur") == scale("blur-sm")
      assert scale("ring") == scale("ring-1")

      refute scale("rounded-xs") == scale("rounded-sm")
      refute scale("rounded-sm") == scale("shadow-sm")
      refute scale("shadow") == scale("hover:shadow-sm")
      assert scale("rounded-[2px]") == nil
    end

    test "no two sizes of one helper produce the same v4 classes" do
      pairs = for path <- @templates, pair <- size_pairs(path), do: {Path.basename(path), pair}
      assert length(pairs) > 100

      same =
        for {file, {name, sizes, classes, other_classes}} <- pairs,
            MapSet.size(classes) > 0,
            classes == other_classes,
            do: "#{file}: #{name} #{inspect(sizes)}"

      assert same == []
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
