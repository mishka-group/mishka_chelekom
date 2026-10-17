defmodule DevelopmentWeb.BorderColourTest do
  @moduledoc """
  A border or divider that a generated component draws has a colour of its own.

  Tailwind v4 draws a border and `divide-*` in `currentColor`; v3 drew them gray-200. Every
  component is rendered with each variant and colour its catalog lists, and each border width
  class must meet a border colour class that styles the same element in the same render.
  """
  use ExUnit.Case, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  @catalogs Path.expand("../../../../priv/components", __DIR__)

  @width ~r/^(?:border|divide)-(?:[xytblrse]-)?(?:\d+|\[\d[^\]]*\])$|^(?:border|divide-x|divide-y)(?:-[xytblrse])?$/
  @not_colour ~r/^(?:solid|dashed|dotted|double|hidden|none|collapse|separate|spacing.*|reverse|[xy]|[xy]-reverse|0)$/

  @states ~w(hover focus focus-within focus-visible active disabled enabled checked open invalid
    required optional odd even first last only empty target)
  @ignored ~w(rtl ltr sm md lg xl 2xl)

  # Parts that a parent component colours through an arbitrary variant, so on their own they have
  # a width and no colour.
  @parts [{"Stepper", :stepper_section}, {"Timeline", :timeline_section}]

  defp catalog_values(module, key) do
    name = module |> Module.split() |> List.last() |> Macro.underscore()
    path = Path.join(@catalogs, name <> ".exs")

    if File.exists?(path) do
      {entries, _binding} = Code.eval_file(path)

      entries
      |> Enum.flat_map(fn {_key, config} ->
        config |> Keyword.get(:args, []) |> Keyword.get(key, [])
      end)
      |> Enum.uniq()
    else
      []
    end
  end

  defp components do
    {:ok, modules} = :application.get_key(:development, :modules)

    for module <- modules,
        String.starts_with?(Atom.to_string(module), "Elixir.DevelopmentWeb.Components."),
        not String.contains?(Atom.to_string(module), ".Headless."),
        Code.ensure_loaded?(module),
        function_exported?(module, :__components__, 0),
        {name, info} <- module.__components__(),
        function_exported?(module, name, 1),
        {module |> Module.split() |> List.last(), name} not in @parts,
        do: {module, name, info}
  end

  defp placeholder(%{type: :boolean}), do: true
  defp placeholder(%{type: :list}), do: []
  defp placeholder(%{type: :atom}), do: :x
  defp placeholder(%{type: :integer}), do: 1
  defp placeholder(%{type: :map}), do: %{}
  defp placeholder(_attr), do: "x"

  defp slot_entries(name, attrs) do
    entry = for attr <- attrs, attr.required, into: %{}, do: {attr.name, placeholder(attr)}
    [Map.merge(entry, %{__slot__: name, inner_block: fn _, _ -> "x" end})]
  end

  defp required_assigns(info) do
    attrs = for attr <- info.attrs, attr.required, into: %{}, do: {attr.name, placeholder(attr)}

    slots =
      for slot <- info.slots, slot.required, into: %{} do
        {slot.name, slot_entries(slot.name, slot.attrs)}
      end

    attrs
    |> Map.merge(slots)
    |> Map.put_new(:inner_block, slot_entries(:inner_block, []))
  end

  defp combinations(module, info) do
    names = MapSet.new(info.attrs, & &1.name)
    pick = fn key -> if MapSet.member?(names, key), do: catalog_values(module, key), else: [] end

    for variant <- axis(pick.(:variant)), color <- axis(pick.(:color)) do
      [variant: variant, color: color]
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)
      |> Map.new()
    end
  end

  defp axis([]), do: [nil]
  defp axis(values), do: values

  defp class_list(html) do
    html
    |> doc()
    |> LazyHTML.query("[class]")
    |> LazyHTML.attribute("class")
    |> Enum.flat_map(&String.split/1)
  end

  # A variant or colour a component has no clause for falls through as a class of its own name.
  defp unsupported?(tokens, assigns) do
    Enum.any?(assigns, fn {key, value} -> key in [:variant, :color] and value in tokens end)
  end

  defp split_variants(class) do
    {segments, current, _depth} =
      class
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

    {Enum.reverse(segments), current |> String.trim_leading("!") |> String.trim_trailing("!")}
  end

  # The element a variant chain styles, as far as pairing a width with a colour goes: arbitrary
  # selectors without their `:not()` / `:has()` / extra-class conditions, and pseudo-elements.
  # `nil` for a chain that only applies in dark mode or in a state, which is no base colour.
  defp target(segments) do
    if Enum.any?(segments, &(&1 == "dark" or state?(&1))) do
      nil
    else
      segments
      |> Enum.reject(&(&1 in @ignored or String.starts_with?(&1, "has-")))
      |> Enum.map(&normalize/1)
      |> Enum.reject(&(&1 == ""))
    end
  end

  defp state?(segment) do
    base = segment |> String.replace(~r/^(group|peer)-/, "") |> String.replace(~r/[\[(].*/, "")
    base in @states or String.starts_with?(segment, ["aria-", "data-"])
  end

  # `[&:not(.a)_.b:hover]` styles `.b`; `[&.a]` styles the element itself; `[:where(&)>*]` styles
  # every child.
  defp normalize("[" <> _ = segment) do
    stripped = segment |> String.replace(":where(&)", "&") |> strip_conditions()

    cond do
      match = Regex.run(~r/[_>+~]\s*([.#]?[A-Za-z0-9_-]+|\*)[^_>+~]*\]$/, stripped) ->
        "[& " <> List.last(match) <> "]"

      Regex.match?(~r/[_>+~]\]$/, stripped) ->
        "[& *]"

      String.starts_with?(stripped, "[&") ->
        ""

      true ->
        segment
    end
  end

  defp normalize(segment), do: segment

  defp strip_conditions(segment) do
    stripped = Regex.replace(~r/:(?:not|has|is|where)\((?:[^()]|\([^()]*\))*\)/, segment, "")
    if stripped == segment, do: segment, else: strip_conditions(stripped)
  end

  defp width?(utility), do: Regex.match?(@width, utility)

  defp family("border" <> _), do: "border"
  defp family("divide" <> _), do: "divide"
  defp family(_utility), do: nil

  defp colour?(utility) do
    family = family(utility)

    with true <- not is_nil(family),
         "-" <> rest <- String.replace_prefix(utility, family, ""),
         false <- width?(utility) do
      not Regex.match?(@not_colour, Regex.replace(~r/^(?:[xytblrse]-)?(?=.)/, rest, ""))
    else
      _ -> false
    end
  end

  defp zero?(utility), do: Regex.match?(~r/-0$/, utility)

  # `{family, key}` of every width class an element ends up with, and of every base colour:
  # its own classes, plus those an ancestor aims at it with an arbitrary `[&_.selector]` variant.
  defp effective(element, ancestors) do
    own = Enum.reject(tokens(element), fn {key, _utility} -> match?(["[& " <> _ | _], key) end)

    inherited =
      for ancestor <- ancestors,
          token <- tokens(ancestor),
          {selector, rest} <- aimed(token),
          matches?(selector, element),
          do: rest

    own ++ inherited
  end

  defp tokens({_tag, attrs, _children}) do
    attrs
    |> List.keyfind("class", 0, {"class", ""})
    |> elem(1)
    |> String.split()
    |> Enum.map(&split_variants/1)
    |> Enum.flat_map(fn {segments, utility} ->
      case target(segments) do
        nil -> []
        key -> [{key, utility}]
      end
    end)
  end

  defp aimed({["[& " <> selector | rest], utility}),
    do: [{String.trim_trailing(selector, "]"), {rest, utility}}]

  defp aimed(_token), do: []

  defp matches?("*", _element), do: true
  defp matches?("." <> class, {_tag, attrs, _}), do: class in classes(attrs)
  defp matches?("#" <> id, {_tag, attrs, _}), do: List.keyfind(attrs, "id", 0) == {"id", id}
  defp matches?(tag, {tag, _attrs, _}), do: true
  defp matches?(_selector, _element), do: false

  defp classes(attrs) do
    attrs |> List.keyfind("class", 0, {"class", ""}) |> elem(1) |> String.split()
  end

  defp walk({_tag, _attrs, children} = element, ancestors, fun) do
    fun.(element, ancestors) ++
      Enum.flat_map(children, fn
        {_, _, _} = child -> walk(child, [element | ancestors], fun)
        _text -> []
      end)
  end

  defp walk(_other, _ancestors, _fun), do: []

  defp descendants({_tag, _attrs, children}) do
    for {_, _, _} = child <- children, element <- [child | descendants(child)], do: element
  end

  # Widths an element aims at descendants the render does not contain cannot be checked on
  # those; they must meet a colour aimed the same way.
  defp aimed_widths(element) do
    aimed =
      for {["[& " <> selector | rest], utility} <- tokens(element),
          do: {String.trim_trailing(selector, "]"), rest, utility}

    coloured =
      for {selector, rest, utility} <- aimed,
          colour?(utility),
          into: MapSet.new(),
          do: {selector, rest, family(utility)}

    present = descendants(element)

    for {selector, rest, utility} <- aimed,
        width?(utility),
        not zero?(utility),
        not Enum.any?(present, &matches?(selector, &1)),
        not MapSet.member?(coloured, {selector, rest, family(utility)}),
        do: Enum.join(["[& " <> selector <> "]" | rest] ++ [utility], ":")
  end

  defp bare_widths(html) do
    html
    |> doc()
    |> LazyHTML.to_tree()
    |> Enum.flat_map(fn root ->
      walk(root, [], fn element, ancestors ->
        effective = effective(element, ancestors)

        coloured =
          for {key, utility} <- effective,
              colour?(utility),
              into: MapSet.new(),
              do: {family(utility), key}

        own =
          for {key, utility} <- effective,
              width?(utility),
              not zero?(utility),
              not MapSet.member?(coloured, {family(utility), key}),
              do: Enum.join(key ++ [utility], ":")

        own ++ aimed_widths(element)
      end)
    end)
    |> Enum.uniq()
  end

  test "no component draws a border or divider without a colour" do
    found =
      for {module, name, info} <- components(),
          assigns <- combinations(module, info),
          reduce: %{} do
        acc ->
          html =
            try do
              module
              |> Function.capture(name, 1)
              |> render_component(Map.merge(required_assigns(info), assigns))
            rescue
              _error -> ""
            end

          widths = if unsupported?(class_list(html), assigns), do: [], else: bare_widths(html)

          Enum.reduce(widths, acc, fn class, acc ->
            Map.update(acc, {inspect(module), name, class}, [assigns], &[assigns | &1])
          end)
      end

    report =
      for {{module, name, class}, hits} <- found do
        keys = fn key -> hits |> Enum.map(&Map.get(&1, key)) |> Enum.uniq() |> Enum.sort() end

        "#{module}.#{name} #{class} variant=#{inspect(keys.(:variant))} color=#{inspect(keys.(:color))}"
      end

    assert Enum.sort(report) == []
  end
end
