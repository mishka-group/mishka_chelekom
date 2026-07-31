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
  | `trigger` | boolean | `false` | Render a ▾ that opens and closes the list. |
  | `on_toggle` | event tag (atom) | — | `{:tap, tag}` from the ▾. |
  | `creatable` | boolean | `false` | Offer "Create …" for a query that matches nothing. |
  | `on_create` | event tag (atom) | — | `{:tap, tag}` from that row. |
  | `on_remove` | event tag (atom) | — | `{:tap, {tag, id}}` from a chip's ✕. |
  | `create_label` | string | `"Create"` | Prefix on the create row. |
  | `id` | string | `nil` | Test tags for the input, chips, options and buttons. |

  Options are built with `option/3`, which takes `:disabled` and `:group`.

  ## Chips, groups and create

  In `multiple` mode the chosen options render as removable chips **inside the
  control**, above the query field, because a multi-select whose selection is
  invisible until you reopen the list is a guessing game. They wrap by the same
  estimate `MishkaMob.Components.MishkaTagsInput` uses — nothing here can measure
  text.

  Groups come from `MishkaSelect.group_runs/1`, so a grouped combobox, a grouped
  select and a grouped menu are the same list. Filtering runs first and empty
  runs disappear with their heading.

  `creatable` adds one row when the query matches no option EXACTLY — matching
  the web, which offers to create "Pear" even while "Pears" is on screen. The
  component only offers; adding to the list is the screen's job, which is why
  `on_create` carries no payload beyond the tag and the screen already holds the
  query.

  Not ported: `name` / `form` (form plumbing), `auto_highlight` (there is no
  focus ring to highlight) and the `*_class` attrs.
  """

  import Mob.Sigil

  alias MishkaMob.Components.{Event, MishkaMenu, MishkaPill, MishkaSelect, MishkaTagsInput}

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
      Enum.filter(options, &matches?(fold(label_of(&1)), needle, mode))
    end
  end

  # Options arrive as {id, label} pairs from a caller and as full option maps
  # from the component, which needs `group` and `disabled` to survive filtering.
  defp label_of({_id, label}), do: label
  defp label_of(%{label: label}), do: label

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

    # Keep the whole option map, not just {id, label}: `group` and `disabled`
    # have to survive filtering, and mapping to pairs threw both away — which is
    # why a disabled option was indistinguishable from any other.
    options =
      children |> Enum.filter(&match?(%{type: :mishka_select_option}, &1)) |> Enum.map(& &1.props)

    matches = filter(options, Map.get(props, :query), mode: Map.get(props, :filter, :contains))

    ~MOB"""
    <Column fill_width={true}>
      {control(props, options, disabled?)}
      <Spacer size={6} :if={open?(props)} />
      {list(props, matches, disabled?)}
    </Column>
    """
  end

  defp open?(props), do: truthy?(Map.get(props, :open, false))

  # One control holding the chips, the query field and the buttons — the web
  # draws a single box and so does this. The chips sit ABOVE the field rather
  # than beside it: a Row cannot wrap, and a chip row that runs off the edge
  # hides the very selection it exists to show.
  defp control(props, options, disabled?) do
    ~MOB"""
    <Box
      fill_width={true}
      background={Map.get(props, :background, :surface)}
      corner_radius={Map.get(props, :corner_radius, :radius_sm)}
      padding={Map.get(props, :padding, :space_sm)}
      border_color={Map.get(props, :border_color, :border)}
      border_width={Map.get(props, :border_width, 1)}
    >
      <Column fill_width={true}>
        {chips(props, options, disabled?)}
        <Row fill_width={true}>
          <Box weight={1}>
            {input(props, disabled?)}
          </Box>
          {button("✕", :on_clear, props, disabled?, truthy?(Map.get(props, :clear, false)))}
          {button(if(open?(props), do: "▴", else: "▾"), :on_toggle, props, disabled?,
             truthy?(Map.get(props, :trigger, false)))}
        </Row>
      </Column>
    </Box>
    """
  end

  # A chosen option is shown as a removable chip. Without this the selection is
  # invisible until you reopen the list, which is a guessing game.
  defp chips(props, options, disabled?) do
    chosen = List.wrap(Map.get(props, :value))

    if truthy?(Map.get(props, :multiple, false)) and chosen != [] do
      labels =
        Enum.map(chosen, fn id ->
          case Enum.find(options, &(Map.get(&1, :id) == id)) do
            nil -> {id, to_string(id)}
            option -> {id, Map.get(option, :label)}
          end
        end)

      # Reuse the tags input's packing rule rather than inventing a second one:
      # wrap the LABELS, then cut the {id, label} list to the same row lengths.
      budget = Map.get(props, :wrap_chars, 28)

      rows =
        labels
        |> Enum.map(&elem(&1, 1))
        |> MishkaTagsInput.wrap(budget)
        |> Enum.map(&length/1)
        |> chunk_like(labels)
        |> Enum.map(fn row ->
          pills =
            row
            |> Enum.map(&chip(&1, props, disabled?))
            |> Enum.intersperse(~MOB(<Spacer size={6} />))

          ~MOB"""
          <Row fill_width={true}>
            {pills}
          </Row>
          """
        end)
        |> Enum.intersperse(~MOB(<Spacer size={6} />))

      ~MOB"""
      <Column fill_width={true}>
        {rows}
        <Spacer size={8} />
      </Column>
      """
    else
      ~MOB(<Column />)
    end
  end

  # Cut `items` into runs of the given lengths.
  defp chunk_like(lengths, items) do
    {rows, _rest} =
      Enum.map_reduce(lengths, items, fn n, rest ->
        {Enum.take(rest, n), Enum.drop(rest, n)}
      end)

    rows
  end

  defp chip({id, label}, props, disabled?) do
    node =
      MishkaPill.pill(
        label: label,
        with_remove: true,
        disabled: disabled?,
        on_remove: widen(props, :on_remove, id, disabled?)
      )

    tag(node, Map.get(props, :id), "chip-#{id}")
  end

  defp input(props, disabled?) do
    node = ~MOB"""
    <TextField
      value={Map.get(props, :query, "")}
      placeholder={Map.get(props, :placeholder, "Search…")}
      fill_width={true}
      background={:transparent}
      enabled={not disabled?}
      underline={false}
    />
    """

    node = tag(node, Map.get(props, :id), "input")

    case handler(props, :on_query, disabled?) do
      nil -> node
      tap -> %{node | props: Map.put(node.props, :on_change, tap)}
    end
  end

  defp button(_glyph, _key, _props, _disabled?, false), do: ~MOB(<Row />)

  defp button(glyph, key, props, disabled?, true) do
    node = ~MOB"""
    <Box width={36} height={36} align={:center} background={:transparent}>
      <Text
        text={glyph}
        text_size={:base}
        text_color={if(disabled?, do: :muted, else: :on_surface)}
      />
    </Box>
    """

    node = tag(node, Map.get(props, :id), to_string(key))

    case handler(props, key, disabled?) do
      nil -> node
      tap -> %{node | props: Map.put(node.props, :on_tap, tap)}
    end
  end

  # An empty result gets a row saying so, rather than a panel collapsing to
  # nothing — "no matches" is information the user needs.
  defp list(props, matches, disabled?) do
    if open?(props) do
      rows = option_rows(props, matches) ++ create_row(props, matches, disabled?)

      case rows do
        [] ->
          MishkaMenu.menu(%{open: true}, [
            MishkaMenu.item(:__empty__, Map.get(props, :empty_text, "No matches"), disabled: true)
          ])

        rows ->
          MishkaMenu.menu(%{open: true, on_select: Map.get(props, :on_select)}, rows)
      end
    else
      ~MOB(<Column />)
    end
  end

  defp option_rows(props, matches) do
    chosen = List.wrap(Map.get(props, :value))
    id = Map.get(props, :id)

    matches
    |> MishkaSelect.group_runs()
    |> Enum.flat_map(fn {group, run} ->
      heading = if is_binary(group), do: [MishkaMenu.label(group)], else: []

      heading ++
        Enum.map(run, fn option ->
          option_id = Map.get(option, :id)
          picked? = option_id in chosen

          MishkaMenu.item(option_id, Map.get(option, :label),
            icon: if(picked?, do: "✓", else: nil),
            disabled: truthy?(Map.get(option, :disabled, false)),
            test_id: option_tag(id, option_id, picked?)
          )
        end)
    end)
  end

  # Offered only when nothing matches the query EXACTLY — the web offers to
  # create "Pear" even while "Pears" is on screen, and so does this.
  defp create_row(props, matches, disabled?) do
    query = String.trim(Map.get(props, :query, "") || "")

    exact? = Enum.any?(matches, &(fold(Map.get(&1, :label)) == fold(query)))

    if truthy?(Map.get(props, :creatable, false)) and query != "" and not exact? and not disabled? do
      label = Map.get(props, :create_label, "Create")

      [
        MishkaMenu.item(:__create__, ~s(#{label} "#{query}"),
          icon: "+",
          test_id: option_tag(Map.get(props, :id), "create", false)
        )
      ]
    else
      []
    end
  end

  defp option_tag(nil, _option_id, _picked?), do: nil

  defp option_tag(id, option_id, picked?),
    do: "#{id}-option-#{option_id}-#{if picked?, do: "selected", else: "idle"}"

  defp tag(node, nil, _suffix), do: node
  defp tag(node, id, suffix), do: %{node | props: Map.put(node.props, :id, "#{id}-#{suffix}")}

  defp widen(props, key, value, disabled?) do
    case handler(props, key, disabled?) do
      nil -> nil
      {pid, name} -> {pid, {name, value}}
    end
  end

  defp handler(_props, _key, true), do: nil
  defp handler(props, key, _), do: Event.handler(Map.get(props, key))

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
