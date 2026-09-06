defmodule MishkaMob.Components.MishkaHighlight do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Highlight** — text with
  matching substrings marked, as in search results.

  Splits the text on its queries and renders the pieces in a `Row`: plain runs as
  `Text`, matched runs through `MishkaMob.Components.MishkaMark`.

  ## Why a sentence is many nodes, and what that costs

  Mob's `Text` takes a single string and exposes no attributed-string or span
  API, so a partially highlighted sentence has to be several nodes laid out in a
  `Row` — and a `Row` does not wrap. On its own that is fine for the short
  strings a highlight is normally used on (a search result title, a filename, a
  label) and runs straight off the edge on a sentence.

  `wrap_at` is the way out: a **character budget per line**, which the parts are
  packed into before rendering. It has to be declared rather than measured
  because no geometry is reported back to `render/1` — the same trade
  `MishkaMob.Components.MishkaOverflowList` makes with `visible`. Leave it unset
  and you get today's single `Row`.

  Breaks land after whitespace, so a wrapped line never begins with a space, and
  a mark is never split across lines — it is one `Box`.

  ## Matching

  `split/3` mirrors the web component: multiple queries, empty and `nil` queries
  ignored, and the matched text rendered as it appears in the source rather than
  as it was typed. Matching is case-insensitive unless `case_sensitive` says
  otherwise (Mantine spells the same switch `caseInsensitive={false}`).

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `text` | string | `""` | The full text. |
  | `highlight` | string or list | `[]` | Substring(s) to mark. |
  | `case_sensitive` | boolean | `false` | Match casing exactly. |
  | `wrap_at` | integer or `nil` | `nil` | Characters per line; unset is one `Row`. |
  | `line_space` | number | `4` | Gap between wrapped lines. |
  | `background` | color token / ARGB int | Mark's amber | Highlight fill. |
  | `color` | color token / ARGB int | Mark's ink | Marked text colour. |
  | `text_color` | color token / ARGB int | `:on_surface` | Unmarked text colour. |
  | `text_size` | size token | `:base` | Size for both. |

  A single fill applies to every match. For a line where each match carries its
  own colour — an `Error` in red beside a `Success` in green — compose
  `MishkaMob.Components.MishkaMark` and `Text` directly; that is what the mark is
  for, and the web component draws the same line (it has one `mark_class`).
  """

  import Mob.Sigil

  alias MishkaMob.Components.MishkaMark

  @doc "Composite expander (`<MishkaHighlight />`). Delegates to `highlight/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: highlight(props)

  @doc """
  The highlight node.

      highlight(text: "Mishka Chelekom", highlight: "chel")
      highlight(text: "one two three", highlight: ["one", "three"])
  """
  @spec highlight(map() | keyword()) :: map()
  def highlight(props \\ %{}) do
    props = Map.new(props)

    parts =
      props
      |> Map.get(:text, "")
      |> split(Map.get(props, :highlight) || [],
        case_sensitive: Map.get(props, :case_sensitive, false)
      )

    case Map.get(props, :wrap_at) do
      budget when is_integer(budget) and budget > 0 -> lines(parts, budget, props)
      _ -> line(parts, props)
    end
  end

  defp line(parts, props) do
    size = Map.get(props, :text_size) || :base
    plain = Map.get(props, :text_color) || :on_surface
    nodes = Enum.map(parts, &part(&1, props, size, plain))

    ~MOB"<Row>
  {nodes}
</Row>"
  end

  defp lines(parts, budget, props) do
    space = Map.get(props, :line_space) || 4

    rows =
      parts
      |> wrap(budget)
      |> Enum.map(&line(&1, props))
      |> Enum.intersperse(~MOB(<Spacer size={space} />))

    ~MOB"<Column>
  {rows}
</Column>"
  end

  @doc """
  Split `text` into `{:mark, run}` / `{:text, run}` parts for one or many
  queries. Blank and nil queries are ignored; with no usable query the whole
  string is a single plain run.

  Matching is case-insensitive unless `case_sensitive: true`, and the run is
  always returned with the casing it has in `text`, never the casing that was
  searched for.

      iex> MishkaMob.Components.MishkaHighlight.split("Mishka Chelekom", "chel")
      [{:text, "Mishka "}, {:mark, "Chel"}, {:text, "ekom"}]

      iex> MishkaMob.Components.MishkaHighlight.split("This and THIS", "this")
      [{:mark, "This"}, {:text, " and "}, {:mark, "THIS"}]

      iex> MishkaMob.Components.MishkaHighlight.split("This and THIS", "this", case_sensitive: true)
      [{:text, "This and THIS"}]

      iex> MishkaMob.Components.MishkaHighlight.split("one two", [])
      [{:text, "one two"}]

      iex> MishkaMob.Components.MishkaHighlight.split("one two", ["", nil])
      [{:text, "one two"}]
  """
  @spec split(String.t(), String.t() | [String.t() | nil], keyword()) :: [
          {:mark | :text, String.t()}
        ]
  def split(text, queries, opts \\ []) do
    queries =
      queries
      |> List.wrap()
      |> Enum.reject(&(&1 in [nil, ""]))

    if queries == [] do
      [{:text, text}]
    else
      flags = if Keyword.get(opts, :case_sensitive, false), do: "u", else: "iu"
      pattern = Enum.map_join(queries, "|", &Regex.escape/1)
      splitter = Regex.compile!("(" <> pattern <> ")", flags)
      whole = Regex.compile!("\\A(?:" <> pattern <> ")\\z", flags)

      splitter
      |> Regex.split(text, include_captures: true, trim: false)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(fn run ->
        if Regex.match?(whole, run), do: {:mark, run}, else: {:text, run}
      end)
    end
  end

  @doc """
  Pack `parts` into lines of at most `budget` characters.

  Plain runs break after whitespace, so a wrapped line never starts with a space.
  A mark is never split — it is one `Box` — so a mark wider than the budget takes
  a line to itself rather than looping forever.

  The separating space stays at the END of the line it broke after, where it is
  invisible, rather than being carried down as an indent.

      iex> alias MishkaMob.Components.MishkaHighlight
      iex> MishkaHighlight.wrap([{:text, "one "}, {:mark, "two"}, {:text, " three"}], 8)
      [[{:text, "one "}, {:mark, "two"}, {:text, " "}], [{:text, "three"}]]
  """
  @spec wrap([{:mark | :text, String.t()}], pos_integer()) :: [[{:mark | :text, String.t()}]]
  def wrap(parts, budget) do
    parts
    |> Enum.flat_map(&tokens/1)
    |> Enum.reduce([[]], fn token, [line | done] ->
      if line != [] and width(line) + width([token]) > budget do
        [[token], line | done]
      else
        [line ++ [token] | done]
      end
    end)
    |> Enum.reverse()
    |> Enum.reject(&(&1 == []))
  end

  defp tokens({:mark, run}), do: [{:mark, run}]

  defp tokens({:text, run}) do
    ~r/(?<=\s)/
    |> Regex.split(run)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&{:text, &1})
  end

  defp width(parts), do: Enum.reduce(parts, 0, fn {_, run}, sum -> sum + String.length(run) end)

  defp part({:mark, run}, props, size, _plain) do
    MishkaMark.mark(
      text: run,
      text_size: size,
      background: Map.get(props, :background) || MishkaMark.default_fill(),
      color: Map.get(props, :color) || MishkaMark.default_ink()
    )
  end

  defp part({:text, run}, _props, size, plain) do
    ~MOB(<Text text={run} text_size={size} text_color={plain} />)
  end
end
