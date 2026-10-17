defmodule MishkaChelekom.TailwindV4ClassesTest do
  @moduledoc """
  Chelekom supports Tailwind CSS v4 only. This reads every class string the kit ships and fails on
  a class that still has its v3 spelling or its v3 meaning.

  Everything is derived from the files: the styled and headless templates, the demos, the showcase
  examples, the usage rules, the JS hooks and the exported CMS bundles. A string counts as a class
  list when most of its words look like utilities, so documentation prose is not read as classes.
  `shadow-sm` and `rounded-sm` are not listed: they are valid v4 names, with v4's size.
  """
  use ExUnit.Case, async: true

  # `{pattern, what to write instead}` for a utility with no variants, `!` or `/opacity`.
  defp removed_rules do
    [
      {~r/^(?:bg|text|border|divide|ring|placeholder)-opacity-\d+$/, "the /opacity modifier"},
      {~r/^flex-shrink(?:-\d+)?$/, "shrink-*"},
      {~r/^flex-grow(?:-\d+)?$/, "grow-*"},
      {~r/^overflow-ellipsis$/, "text-ellipsis"},
      {~r/^decoration-(?:slice|clone)$/, "box-decoration-slice / box-decoration-clone"},
      {~r/^outline-none$/, "outline-hidden"},
      {~r/^transform-none$/, "translate-none, scale-none or rotate-none"},
      {~r/^bg-gradient-to-(?:t|tr|r|br|b|bl|l|tl)$/, "bg-linear-to-*"},
      {~r/^rounded-(?:t|b|s|e|l|r|tl|tr|bl|br|ss|se|es|ee)$/, "rounded-<side>-sm"}
    ]
  end

  # Names that are a v3 size only when they stand without a step; checked in a class list.
  defp bare_rules do
    [
      {~r/^rounded$/, "rounded-sm"},
      {~r/^shadow$/, "shadow-sm"},
      {~r/^drop-shadow$/, "drop-shadow-sm"},
      {~r/^blur$/, "blur-sm"},
      {~r/^backdrop-blur$/, "backdrop-blur-sm"},
      {~r/^ring$/, "ring-3"}
    ]
  end

  @utility_words ~w(flex block hidden inline grid relative absolute fixed sticky border rounded
    shadow blur ring outline transition transform truncate underline italic uppercase lowercase
    capitalize grow shrink visible invisible static container isolate)

  @sources [
    "priv/components/*.eex",
    "priv/headless/*.eex",
    "priv/demos/*",
    "priv/assets/js/*.js",
    "usage-rules.md",
    "usage-rules/**/*.md",
    "README.md"
  ]

  @json_sources [
    "priv/showcase/*.json",
    "priv/cms_ui_kits/*.json",
    "priv/components/chelekom.json",
    "priv/headless/chelekom_headless.json"
  ]

  defp files(patterns) do
    patterns |> Enum.flat_map(&Path.wildcard/1) |> Enum.filter(&File.regular?/1) |> Enum.sort()
  end

  defp strings(text) do
    single = ~r/"((?:[^"\\\n]|\\.)*)"/
    multi = ~r/class="([^"]*\n[^"]*)"/

    lines =
      for {line, number} <- text |> String.split("\n") |> Enum.with_index(1),
          [prefix, string] <- string_matches(single, line),
          do: {number, prefix, string}

    lines ++ for [_all, string] <- Regex.scan(multi, text), do: {0, "", string}
  end

  defp string_matches(regex, line) do
    for [{start, _length}, {from, length}] <- Regex.scan(regex, line, return: :index) do
      [binary_part(line, 0, start), binary_part(line, from, length)]
    end
  end

  defp json_strings(path) do
    path |> File.read!() |> Jason.decode!() |> collect([])
  end

  defp collect(value, acc) when is_binary(value), do: [value | acc]
  defp collect(value, acc) when is_list(value), do: Enum.reduce(value, acc, &collect/2)
  defp collect(value, acc) when is_map(value), do: value |> Map.values() |> collect(acc)
  defp collect(_value, acc), do: acc

  # `{variants, last segment, utility}`: the variants of a class, what follows them, and that
  # without `!` or `/opacity`.
  defp split(class) do
    {segments, current} = parse(class, 0, "", [])

    utility =
      current
      |> String.trim_leading("!")
      |> String.trim_trailing("!")
      |> String.replace(~r"/(?:\d+|\[[^\]]*\]|\([^)]*\))$", "")

    {Enum.reverse(segments), current, utility}
  end

  defp parse(<<>>, _depth, current, segments), do: {segments, current}

  defp parse(<<char, rest::binary>>, depth, current, segments) when char in [?[, ?(],
    do: parse(rest, depth + 1, <<current::binary, char>>, segments)

  defp parse(<<char, rest::binary>>, depth, current, segments) when char in [?], ?)],
    do: parse(rest, depth - 1, <<current::binary, char>>, segments)

  defp parse(<<?:, rest::binary>>, 0, current, segments),
    do: parse(rest, 0, "", [current | segments])

  defp parse(<<char, rest::binary>>, depth, current, segments),
    do: parse(rest, depth, <<current::binary, char>>, segments)

  defp utility_like?(word) do
    {_segments, _raw, utility} = split(word)

    utility in @utility_words or
      Regex.match?(~r/^-?[a-z][a-z0-9]*(?:-[\w.\/\[\]():%#,&>*'=+~-]+)+$/, utility) or
      String.contains?(word, ":")
  end

  defp class_list?(words) do
    length(words) >= 2 and Enum.count(words, &utility_like?/1) / length(words) >= 0.6
  end

  # What is wrong with one class, as `"class: write this"`.
  defp problems(class, in_list?) do
    {segments, raw, utility} = split(class)

    removed =
      for {pattern, instead} <- removed_rules(), Regex.match?(pattern, utility), do: instead

    bare =
      for {pattern, instead} <- bare_rules(),
          Regex.match?(pattern, utility),
          in_list? or segments != [],
          do: instead

    important =
      if String.starts_with?(raw, "!") and Regex.match?(~r/^!-?[a-z]/, raw) and
           (in_list? or segments != [] or String.contains?(raw, "-")),
         do: ["a trailing ! (#{String.trim_leading(raw, "!")}!)"],
         else: []

    variable =
      if Regex.match?(~r/-\[--[A-Za-z]/, utility), do: ["(--name) instead of [--name]"], else: []

    stacking =
      case Enum.find_index(segments, &(&1 == "*")) do
        index when is_integer(index) and index > 0 -> ["*: before the other variants"]
        _ -> []
      end

    for instead <- removed ++ bare ++ important ++ variable ++ stacking,
        do: "#{class}: #{instead}"
  end

  # `outline` with `outline-<n>` under the same variants: v4's outline-<n> already sets the style.
  defp outline_pairs(words) do
    split_words = Enum.map(words, &split/1)

    for {variants, _raw, "outline"} <- split_words,
        {^variants, _other, <<"outline-", digit, _::binary>>} <- split_words,
        digit in ?0..?9,
        do: "#{Enum.join(variants ++ ["outline"], ":")}: drop it, outline-<n> sets the style"
  end

  # Words that can be a v3 class at all; everything else is skipped before the real checks.
  @hints ~w(rounded shadow blur ring outline flex- overflow- decoration- opacity- transform- gradient ! [-- *:)

  defp violations(path, strings) do
    Enum.flat_map(strings, fn {number, prefix, string} ->
      words = String.split(string)

      if Enum.any?(words, &String.contains?(&1, @hints)) do
        size_helper? =
          Regex.match?(~r/defp?\s+\w*(?:rounded|shadow|blur|filter|ring)\w*\(.*do:\s*$/, prefix)

        in_list? = size_helper? or class_list?(words)

        for problem <- Enum.flat_map(words, &problems(&1, in_list?)) ++ outline_pairs(words),
            do: "#{path}:#{number}: #{problem}"
      else
        []
      end
    end)
  end

  defp base_variant_shadows(path, text) do
    ~r/defp color_variant\("base"[^\n]*\) do\n(.*?)\n  end/s
    |> Regex.scan(text, capture: :all_but_first)
    |> List.flatten()
    |> Enum.filter(&Regex.match?(~r/(?<![\w-])shadow-sm(?![\w-])/, &1))
    |> Enum.map(fn _ ->
      "#{path}: a base variant uses shadow-sm, v3's small shadow is shadow-xs"
    end)
  end

  describe "the files the kit ships" do
    test "there are class strings to read" do
      assert length(files(@sources)) > 300
      assert length(files(@json_sources)) > 100
    end

    test "no template, demo, rule or hook uses a v3 class" do
      violations =
        for path <- files(@sources), reduce: [] do
          acc ->
            text = File.read!(path)
            acc ++ violations(path, strings(text))
        end

      assert violations |> Enum.uniq() |> Enum.take(20) == []
    end

    test "no showcase example or exported bundle uses a v3 class" do
      violations =
        files(@json_sources)
        |> Task.async_stream(
          fn path ->
            strings =
              for string <- path |> json_strings() |> Enum.uniq(),
                  {_number, prefix, inner} <- strings(string),
                  do: {0, prefix, inner}

            violations(path, strings)
          end,
          timeout: :infinity
        )
        |> Enum.flat_map(fn {:ok, found} -> found end)

      assert violations |> Enum.uniq() |> Enum.take(20) == []
    end

    test "a base variant's shadow is the small v4 shadow, shadow-xs" do
      violations =
        for path <- Path.wildcard("priv/components/*.eex"),
            problem <- base_variant_shadows(path, File.read!(path)),
            do: problem

      assert violations |> Enum.uniq() |> Enum.take(20) == []
    end
  end

  describe "clickable elements" do
    # Tailwind v3 gave `button` and `[role=button]` a pointer cursor; v4 leaves the browser's.
    defp clickable_without_pointer(path, text) do
      for tag <- opening_tags(text),
          clickable?(tag),
          not pointer?(tag, text),
          do: "#{path}: #{tag |> String.replace(~r/\s+/, " ") |> String.slice(0, 90)}"
    end

    defp opening_tags(text) do
      for [{start, _length}] <- Regex.scan(~r/<[a-z][a-z0-9]*\b/, text, return: :index) do
        rest = binary_part(text, start, byte_size(text) - start)
        binary_part(rest, 0, tag_end(rest, 0, 0, nil) + 1)
      end
    end

    defp tag_end(<<>>, position, _depth, _quote), do: max(position - 1, 0)

    defp tag_end(<<char, rest::binary>>, position, depth, quote) when quote == char,
      do: tag_end(rest, position + 1, depth, nil)

    defp tag_end(<<_char, rest::binary>>, position, depth, quote) when not is_nil(quote),
      do: tag_end(rest, position + 1, depth, quote)

    defp tag_end(<<char, rest::binary>>, position, depth, nil) when char in [?", ?'],
      do: tag_end(rest, position + 1, depth, char)

    defp tag_end(<<?{, rest::binary>>, position, depth, nil),
      do: tag_end(rest, position + 1, depth + 1, nil)

    defp tag_end(<<?}, rest::binary>>, position, depth, nil),
      do: tag_end(rest, position + 1, depth - 1, nil)

    defp tag_end(<<?>, _rest::binary>>, position, 0, nil), do: position

    defp tag_end(<<_char, rest::binary>>, position, depth, nil),
      do: tag_end(rest, position + 1, depth, nil)

    defp clickable?(tag),
      do: String.starts_with?(tag, "<button") or String.contains?(tag, ~s(role="button"))

    # The tag names `cursor-pointer`, or builds its classes in a helper of the template that does.
    defp pointer?(tag, text) do
      String.contains?(tag, "cursor-pointer") or
        tag
        |> helper_calls()
        |> Enum.any?(&(&1 |> helper_body(text) |> String.contains?("cursor-pointer")))
    end

    defp helper_calls(tag) do
      case Regex.run(~r/\bclass=\{(.*)\}/s, tag, capture: :all_but_first) do
        [classes] ->
          ~r/\b([a-z_][a-z0-9_]*)\(/
          |> Regex.scan(classes, capture: :all_but_first)
          |> List.flatten()
          |> Enum.uniq()

        _ ->
          []
      end
    end

    defp helper_body(name, text) do
      case Regex.run(~r/\n  defp #{name}\(.*?(?=\n  defp (?!#{name}\()|\n  def |\z)/s, text) do
        [body] -> body
        _ -> ""
      end
    end

    test "every button and role=button in a styled template has a pointer cursor" do
      violations =
        for path <- Path.wildcard("priv/components/*.eex"),
            problem <- clickable_without_pointer(path, File.read!(path)),
            do: problem

      assert Enum.take(violations, 20) == []
    end

    # An example a reader copies: its buttons name the class themselves. Inline code is prose, and
    # a button that is always disabled shows no pointer.
    defp example_buttons_without_pointer(path, text) do
      for tag <- text |> String.replace(~r/`[^`\n]*`/, "") |> opening_tags(),
          clickable?(tag),
          not String.contains?(tag, "cursor-pointer"),
          not Regex.match?(~r/\sdisabled(?=[\s>\/])/, tag),
          do: "#{path}: #{tag |> String.replace(~r/\s+/, " ") |> String.slice(0, 90)}"
    end

    test "every button and role=button in a demo or a usage rule has a pointer cursor" do
      paths =
        Path.wildcard("priv/demos/*.{ex,heex}") ++
          Path.wildcard("usage-rules/**/*.md") ++ ["usage-rules.md"]

      violations =
        for path <- paths,
            problem <- example_buttons_without_pointer(path, File.read!(path)),
            do: problem

      assert length(paths) > 150
      assert Enum.take(violations, 20) == []
    end

    test "an example button without cursor-pointer is found" do
      assert example_buttons_without_pointer("t.md", ~s(<button phx-click="x">Go</button>)) != []
      assert example_buttons_without_pointer("t.md", ~s(<div role="button" class="a">)) != []
      assert example_buttons_without_pointer("t.md", ~s(<button class="a cursor-pointer">)) == []
      assert example_buttons_without_pointer("t.md", ~s(<button disabled>Off</button>)) == []
      assert example_buttons_without_pointer("t.md", "A `<button>` is plain.") == []
    end

    test "a button without cursor-pointer is found" do
      assert clickable_without_pointer("t.eex", ~s(<button type="button" class={["a", @class]}>)) !=
               []

      assert clickable_without_pointer("t.eex", ~s(<div role="button" class="a">)) != []

      assert clickable_without_pointer("t.eex", ~s(<button class={["a cursor-pointer", @class]}>)) ==
               []

      assert clickable_without_pointer("t.eex", ~s(<div class="a">)) == []

      helper = """
      <button class={[pick(@a)]}>

        defp pick(_a), do: "cursor-pointer"
      """

      assert clickable_without_pointer("t.eex", helper) == []

      assert clickable_without_pointer("t.eex", String.replace(helper, "cursor-pointer", "x")) !=
               []
    end
  end

  describe "the check" do
    test "reads a v3 class and a v4 class apart" do
      v3 =
        ~w{focus:outline-none flex-shrink-0 bg-gradient-to-br rounded-t [&_.x]:!top-0 bg-[--brand]
          first:*:pt-0 bg-opacity-50 overflow-ellipsis transform-none}

      v4 =
        ~w{focus:outline-hidden shrink-0 bg-linear-to-br rounded-t-sm [&_.x]:top-0! bg-(--brand)
          *:first:pt-0 bg-black/50 text-ellipsis shadow-xs rounded-sm outline-2 translate-none}

      assert Enum.flat_map(v4, &problems(&1, true)) == []
      assert Enum.all?(v3, &(problems(&1, true) != []))
    end

    test "reads a bare name only in a class list" do
      assert problems("rounded", true) == ["rounded: rounded-sm"]
      assert problems("rounded", false) == []
      assert problems("hover:rounded", false) == ["hover:rounded: rounded-sm"]
      refute class_list?(["rounded", "corners", "of", "the", "card"])
      assert class_list?(["rounded", "border", "p-2"])
    end

    test "a bare outline beside outline-<n> is found" do
      assert outline_pairs(~w(outline outline-2 outline-blue-400)) != []

      assert outline_pairs(
               ~w(has-[:focus-visible]:outline-2 has-[:focus-visible]:outline-blue-400)
             ) == []
    end

    test "a base variant with shadow-sm is found" do
      text = """
        defp color_variant("base", _) do
          "bg-white shadow-sm"
        end
      """

      assert base_variant_shadows("t.eex", text) != []
      assert base_variant_shadows("t.eex", String.replace(text, "shadow-sm", "shadow-xs")) == []
    end
  end
end
