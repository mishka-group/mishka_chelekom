defmodule MishkaMob.Components.MishkaCombobox do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Combobox** — a text field that
  filters a list of options, single or multiple.

  ## Filtering is a pure function the screen calls

  The web engine filters in JS as you type. Here `filter/3` does it, and the
  screen calls it from `handle_change/3` — the same division the Toast and Mask
  Input use, and for the same reason: it makes the behaviour testable and keeps
  the component a pure function of its props.

  `filter/3` supports the two modes the web component names, `:contains` and
  `:starts_with`, and is **case- and accent-insensitive**, so typing `"ir"`
  finds `"Iran"` and typing `"cafe"` finds `"Café"`. Diacritic folding matters
  more on a phone than on a desktop, where a physical keyboard makes accents
  easy — it is the difference between a working search and a dead one.

  ## Selection reuses Select

  Once the list is filtered, choosing from it is exactly
  `MishkaMob.Components.MishkaSelect`'s job, so the option list and the
  `{value, close?}` transition come from there rather than being written twice.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | option id, list, or `nil` | `nil` | The current choice(s). |
  | `query` | string | `""` | The text field's contents. |
  | `open` | boolean | `false` | Whether the list is shown. |
  | `multiple` | boolean | `false` | Allow several choices. |
  | `placeholder` | string | `"Search…"` | Field placeholder. |
  | `clear` | boolean | `false` | Render a ✕ that clears the query. |
  | `empty_text` | string | `"No matches"` | Shown when nothing matches. |
  | `disabled` | boolean | `false` | Mutes and unwires. |
  | `on_query` | event tag (atom) | — | `{:change, tag, text}` as you type. |
  | `on_select` | event tag (atom) | — | `{:tap, {tag, option_id}}`. |
  | `on_clear` | event tag (atom) | — | `{:tap, tag}` from the ✕. |

  Not ported: `name` / `form` (form plumbing), `auto_highlight` (no focus ring
  to highlight), `creatable` (the screen can add to its own option list), and
  `id` / `*_class`.
  """

  import Mob.Sigil

  alias MishkaMob.Components.{Event, MishkaMenu, MishkaSelect}

  @doc "Composite expander (`<MishkaCombobox>`). Children are options."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: combobox(props, children)

  @doc "Build one option node (shares `MishkaSelect.option/3`)."
  @spec option(term(), String.t(), keyword()) :: map()
  defdelegate option(id, label, opts \\ []), to: MishkaSelect

  @doc """
  Filter `{id, label}` pairs by `query`.

  Case- and accent-insensitive, so a phone keyboard's missing accents do not
  make a list unsearchable. An empty query matches everything.

      iex> alias MishkaMob.Components.MishkaCombobox, as: C
      ...> C.filter([{:ir, "Iran"}, {:uk, "United Kingdom"}], "ir")
      [{:ir, "Iran"}]

      iex> alias MishkaMob.Components.MishkaCombobox, as: C
      ...> C.filter([{:a, "Café"}], "cafe")
      [{:a, "Café"}]

      iex> alias MishkaMob.Components.MishkaCombobox, as: C
      ...> C.filter([{:a, "Alpha"}, {:b, "Beta"}], "")
      [{:a, "Alpha"}, {:b, "Beta"}]

      iex> alias MishkaMob.Components.MishkaCombobox, as: C
      ...> C.filter([{:a, "Alpha"}, {:b, "Beta"}], "a", mode: :starts_with)
      [{:a, "Alpha"}]
  """
  @spec filter([{term(), String.t()}], String.t() | nil, keyword()) :: [{term(), String.t()}]
  def filter(options, query, opts \\ []) do
    needle = fold(query)

    if needle == "" do
      options
    else
      mode = Keyword.get(opts, :mode, :contains)
      Enum.filter(options, &matches?(fold(elem(&1, 1)), needle, mode))
    end
  end

  @doc """
  Case-fold and strip diacritics, so "Café" and "cafe" compare equal.

      iex> MishkaMob.Components.MishkaCombobox.fold("Café")
      "cafe"
      iex> MishkaMob.Components.MishkaCombobox.fold(nil)
      ""
  """
  @spec fold(String.t() | nil) :: String.t()
  def fold(nil), do: ""

  def fold(text) do
    text
    |> String.trim()
    |> String.normalize(:nfd)
    |> String.replace(~r/\p{Mn}/u, "")
    |> String.downcase()
  end

  defp matches?(haystack, needle, :starts_with), do: String.starts_with?(haystack, needle)
  defp matches?(haystack, needle, _contains), do: String.contains?(haystack, needle)

  @doc "The combobox node."
  @spec combobox(map() | keyword(), [map()]) :: map()
  def combobox(props \\ %{}, children \\ []) do
    props = Map.new(props)
    disabled? = truthy?(Map.get(props, :disabled, false))

    pairs =
      children
      |> Enum.filter(&match?(%{type: :mishka_select_option}, &1))
      |> Enum.map(&{Map.get(&1.props, :id), Map.get(&1.props, :label)})

    matches = filter(pairs, Map.get(props, :query), mode: Map.get(props, :filter, :contains))

    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box weight={1}>
          {input(props, disabled?)}
        </Box>
        {clear(props, disabled?)}
      </Row>
      <Spacer size={6} :if={truthy?(Map.get(props, :open, false))} />
      {list(props, matches, disabled?)}
    </Column>
    """
  end

  defp input(props, disabled?) do
    node = ~MOB"""
    <TextField
      value={Map.get(props, :query, "")}
      placeholder={Map.get(props, :placeholder, "Search…")}
      fill_width={true}
      background={:surface}
      corner_radius={:radius_sm}
      padding={:space_sm}
      border_color={:border}
      border_width={1}
    />
    """

    case handler(props, :on_query, disabled?) do
      nil -> node
      tap -> %{node | props: Map.put(node.props, :on_change, tap)}
    end
  end

  defp clear(props, disabled?) do
    if truthy?(Map.get(props, :clear, false)) do
      node = ~MOB"""
      <Row>
        <Spacer size={8} />
        <Box
          width={40}
          height={40}
          align={:center}
          background={:surface_raised}
          corner_radius={:radius_sm}
        >
          <Text text="✕" text_size={:base} text_color={:on_surface} />
        </Box>
      </Row>
      """

      case handler(props, :on_clear, disabled?) do
        nil -> node
        tap -> %{node | props: Map.put(node.props, :on_tap, tap)}
      end
    else
      ~MOB(<Row />)
    end
  end

  # An empty result gets a row saying so, rather than a panel collapsing to
  # nothing — "no matches" is information the user needs.
  defp list(props, matches, _disabled?) do
    cond do
      not truthy?(Map.get(props, :open, false)) ->
        ~MOB(<Column />)

      matches == [] ->
        MishkaMenu.menu(%{open: true}, [
          MishkaMenu.item(:__empty__, Map.get(props, :empty_text, "No matches"), disabled: true)
        ])

      true ->
        chosen = List.wrap(Map.get(props, :value))

        items =
          Enum.map(matches, fn {id, label} ->
            MishkaMenu.item(id, label, icon: if(id in chosen, do: "✓", else: nil))
          end)

        MishkaMenu.menu(%{open: true, on_select: Map.get(props, :on_select)}, items)
    end
  end

  defp handler(_props, _key, true), do: nil
  defp handler(props, key, _), do: Event.handler(Map.get(props, key))

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
