defmodule MishkaMob.Components.MishkaHighlight do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Highlight** — text with
  matching substrings marked, as in search results.

  Splits the text on its queries and renders the pieces in a `Row`: plain runs as
  `Text`, matched runs through `MishkaMob.Components.MishkaMark`.

  ## The wrapping limitation, stated plainly

  Mob's `Text` takes a single string and exposes no attributed-string or span
  API, so a partially highlighted sentence has to be several nodes laid out in a
  `Row`. A `Row` does not wrap, so this is right for the short strings a
  highlight is normally used on — a search result title, a filename, a label —
  and will run off the edge on a long paragraph. Highlighting inside flowing
  body text needs span support in the framework; nothing at this layer can fake
  it, so the port does not pretend to.

  ## Matching

  `split/2` mirrors the web component: case-insensitive, multiple queries, empty
  and `nil` queries ignored, and the matched text rendered as it appears in the
  source rather than as it was typed.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `text` | string | `""` | The full text. |
  | `highlight` | string or list | `[]` | Substring(s) to mark. |
  | `background` | color token / ARGB int | Mark's amber | Highlight fill. |
  | `color` | color token / ARGB int | Mark's ink | Marked text colour. |
  | `text_color` | color token / ARGB int | `:on_surface` | Unmarked text colour. |
  | `text_size` | size token | `:base` | Size for both. |
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
    size = Map.get(props, :text_size, :base)
    plain = Map.get(props, :text_color, :on_surface)

    parts =
      props
      |> Map.get(:text, "")
      |> split(Map.get(props, :highlight, []))
      |> Enum.map(&part(&1, props, size, plain))

    ~MOB"""
    <Row>
      {parts}
    </Row>
    """
  end

  @doc """
  Split `text` into `{:mark, run}` / `{:text, run}` parts, case-insensitively,
  for one or many queries. Blank and nil queries are ignored; with no usable
  query the whole string is a single plain run.

      iex> MishkaMob.Components.MishkaHighlight.split("Mishka Chelekom", "chel")
      [{:text, "Mishka "}, {:mark, "Chel"}, {:text, "ekom"}]

      iex> MishkaMob.Components.MishkaHighlight.split("one two", [])
      [{:text, "one two"}]

      iex> MishkaMob.Components.MishkaHighlight.split("one two", ["", nil])
      [{:text, "one two"}]
  """
  @spec split(String.t(), String.t() | [String.t() | nil]) :: [{:mark | :text, String.t()}]
  def split(text, queries) do
    queries =
      queries
      |> List.wrap()
      |> Enum.reject(&(&1 in [nil, ""]))

    if queries == [] do
      [{:text, text}]
    else
      pattern = Enum.map_join(queries, "|", &Regex.escape/1)
      splitter = Regex.compile!("(" <> pattern <> ")", "iu")
      whole = Regex.compile!("\\A(?:" <> pattern <> ")\\z", "iu")

      splitter
      |> Regex.split(text, include_captures: true, trim: false)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(fn run ->
        if Regex.match?(whole, run), do: {:mark, run}, else: {:text, run}
      end)
    end
  end

  defp part({:mark, run}, props, size, _plain) do
    MishkaMark.mark(
      text: run,
      text_size: size,
      background: Map.get(props, :background, MishkaMark.default_fill()),
      color: Map.get(props, :color, MishkaMark.default_ink())
    )
  end

  defp part({:text, run}, _props, size, plain) do
    ~MOB(<Text text={run} text_size={size} text_color={plain} />)
  end
end
